import markdown
import json
import zipfile
import os
import os.path

from django.conf import settings
from django.core.urlresolvers import reverse
from django.db import models
from django.utils.html import strip_tags
from imagekit.models import ImageSpecField
from imagekit.processors import ResizeToFill
from rh.compositer import composite_pack

# la la la ladeez

def unescape(text):
    """
    Do reverse escaping.
    """
    return text.replace('&amp;', '&').replace('&lt;', '<').replace('&gt;', '>').replace('&quot;', '"').replace('&#39;', '\'')

class Heroine(models.Model):
  """All the data for a heroine goes here."""
  name = models.CharField(max_length=140)
  title = models.CharField(max_length=140)
  nickname = models.CharField(max_length=140,null=True,blank=True)
  slug = models.SlugField(max_length=150)
  birthdate = models.DateField()
  birthdate_is_approximate = models.BooleanField(default=False,help_text='Check to display the birthdate as "c. YYYY".')
  # what if they're not dead?
  deathdate = models.DateField(null=True,blank=True)
  country = models.CharField(max_length=100)
  is_public = models.BooleanField(default=False)

  top_offset = models.FloatField(null=True,blank=True,default='-12')

  animation_pack = models.FileField(upload_to='packs',help_text='A zip with all the layers for animation.',null=True,blank=True)

  # TODO: break this into layers
  hero_image = models.ImageField(upload_to='portraits',help_text='The image in grid mode (non-animating). Leave blank to have it generated from the animation pack layers.',null=True,blank=True)

  # TODO: make these composite from the layers
  # grid_image_thumbnail = models.ImageField(upload_to='portraits',help_text='',null=True,blank=True)
  # timeline_image_thumbnail = models.ImageField(upload_to='portraits',help_text='',null=True,blank=True)
  grid_image_thumbnail = ImageSpecField(source='hero_image',
                                      processors=[ResizeToFill(320, 320)],
                                      format='PNG',
                                      options={'quality': 100})

  timeline_image_thumbnail = ImageSpecField(source='hero_image',
                                      processors=[ResizeToFill(75, 75)],
                                      format='PNG',
                                      options={'quality': 100})

  description = models.TextField(
    help_text='Uses <a href="http://daringfireball.net/projects/markdown/" '
               'target="_blank">Markdown</a>')
  description_html = models.TextField('HTML version')
  description_text = models.TextField('Plain text version')

  def __str__(self):
    return self.name

  def get_absolute_url(self):
    if self.slug:
      return reverse('heroine', None, [self.slug])
    else:
      return reverse('grid', None)

  def save(self, *args, **kwargs):
    quick_save = kwargs.pop('quick_save', False)
    if quick_save:
      super(Heroine, self).save(*args, **kwargs)
      return
      
    self.description_html = markdown.markdown(self.description, extensions=['extra', 'nl2br', 'admonition', 'headerid', 'sane_lists'])
    # Remove tags which was generated with the markup processor
    text = strip_tags(self.description_html)
    # Unescape entities which was generated with the markup processor
    self.description_text = unescape(text)

    super(Heroine, self).save(*args, **kwargs)
    # unzip the file, then delete it
    should_resave = False
    packs_dir = os.path.join(settings.MEDIA_ROOT, 'packs', self.slug)
    if self.animation_pack:
      #delete the old file.
      zip_path = os.path.join(settings.MEDIA_ROOT, 'packs/{0}.zip'.format(self.slug))
      try:
        if zip_path != self.animation_pack.path:
          os.unlink(zip_path)
          should_resave = True
      except:
        # only delete it if it doesn't exist
        pass

      try:
        os.rename(self.animation_pack.path, zip_path)
        self.animation_pack = zip_path.replace(settings.MEDIA_ROOT + '/', '')
      except:
        zip_path = self.animation_pack.path

      if zipfile.is_zipfile(zip_path):
        if not os.path.exists(packs_dir):
          os.mkdir(packs_dir)
        pack_zip = zipfile.ZipFile(zip_path)
        files = pack_zip.namelist()
        # if it's in a subfolder, remove the subfolder
        allowed_files = [
          'eyes-closed.png',
          'eyes-opened.png',
          'torso.png',
          'head.png',
          'mouth.png',
          'hair.png',
        ]

        for f in files:
          for allowed_file in allowed_files:
            # extra bit for the __MACOSX
            if f.endswith(allowed_file) and not f.startswith('__'):
              source = pack_zip.open(f)
              contents = source.read()
              target_path = os.path.join(packs_dir, allowed_file)
              target = open(target_path, 'wb')
              target.write(contents)
              target.close()
              source.close()
              
        pack_zip.close()

    # if there isn't a grid image provided, just set it to this
    if not self.hero_image or self.hero_image.path.endswith('composite.png'):
      # composite the images together
      composite_path = composite_pack(packs_dir)
      self.hero_image = composite_path.replace(settings.MEDIA_ROOT + '/', '')
      should_resave = True

    if should_resave:
      self.save(quick_save=True)

    heroines = Heroine.objects.all()
    public_heroines = []
    all_heroines = []

    for h in heroines:
      birthdate_string = None
      if h.birthdate:
        if h.birthdate_is_approximate:
          birthdate_string = h.birthdate.strftime('c. %Y')
        else:
          birthdate_string = h.birthdate.strftime('%Y-%m-%d')
      deathdate_string = None
      if h.deathdate:
        deathdate_string = h.deathdate.strftime('%Y-%m-%d')

      try:
        hero_image_url = h.hero_image.url
      except ValueError:
        hero_image_url = None

      heroine_object = {
        'name': h.name,
        'title': h.title,
        'nickname': h.nickname,
        'slug': h.slug,
        'topOffset': h.top_offset,
        'birthdate': birthdate_string,
        'deathdate': deathdate_string,
        'country': h.country,
        'descriptionHtml': h.description_html,
        'descriptionText': h.description_text,
        'heroImage': hero_image_url,
        'gridImageThumbnail': h.grid_image_thumbnail.url,
        'timelineImageThumbnail': h.timeline_image_thumbnail.url,
      }

      if h.is_public:
        public_heroines.append(heroine_object)
      all_heroines.append(heroine_object)

    public_json_filename = '{0}/heroines.json'.format(settings.MEDIA_ROOT)
    private_json_filename = '{0}/heroines-preview.json'.format(settings.MEDIA_ROOT)
    try:
      fh = open(public_json_filename, 'w')
      public_heroines_json = json.dump(public_heroines, fh)
      fh.close()
    except IOError:
      print('Failed to write json updates for heroines at {0}'.format(public_json_filename))

    try:
      fh = open(private_json_filename, 'w')
      private_json_filename = json.dump(all_heroines, fh)
      fh.close()
    except IOError:
      print('Failed to write json updates for heroines at {0}'.format(private_json_filename))


  class Meta:
    ordering = ['birthdate','name']
    app_label = 'real_heroines'
    db_table = 'rh_heroine'
  