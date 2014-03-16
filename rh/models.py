import markdown
import json

from django.conf import settings
from django.db import models
from django.utils.html import strip_tags
from imagekit.models import ImageSpecField
from imagekit.processors import ResizeToFill

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
  nickname = models.CharField(max_length=140)
  slug = models.SlugField(max_length=150)
  birthdate = models.DateField()
  # what if they're not dead?
  deathdate = models.DateField(null=True,blank=True)
  country = models.CharField(max_length=100)
  is_public = models.BooleanField(default=False)

  # TODO: break this into layers
  hero_image = models.ImageField(upload_to='heroines/portraits',help_text='The image in portrait mode.')

  # TODO: make these composite from the layers
  grid_image_thumbnail = ImageSpecField(source='hero_image',
                                      processors=[ResizeToFill(150, 150)],
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

  def save(self, *args, **kwargs):
    self.description_html = markdown.markdown(self.description, extensions=['extra', 'admonition', 'headerid', 'sane_lists'])
    # Remove tags which was generated with the markup processor
    text = strip_tags(self.description_html)
    # Unescape entities which was generated with the markup processor
    self.description_text = unescape(text)

    super(Heroine, self).save(*args, **kwargs)

    heroines = Heroine.objects.all()
    public_heroines = []
    all_heroines = []

    for h in heroines:
      birthdate_string = None
      if h.birthdate:
        birthdate_string = h.birthdate.strftime('%Y-%m-%d')
      deathdate_string = None
      if h.deathdate:
        deathdate_string = h.birthdate.strftime('%Y-%m-%d')

      heroine_object = {
        'name': h.name,
        'nickname': h.nickname,
        'slug': h.slug,
        'birthdate': birthdate_string,
        'deathdate': deathdate_string,
        'country': h.country,
        'hero_image': h.hero_image.url,
        'grid_image_thumbnail': h.grid_image_thumbnail.url,
        'timeline_image_thumbnail': h.timeline_image_thumbnail.url,
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
      fh = open(public_json_filename, 'w')
      private_json_filename = json.dump(all_heroines, fh)
      fh.close()
    except IOError:
      print('Failed to write json updates for heroines at {0}'.format(private_json_filename))


  class Meta:
    ordering = ['birthdate','name']
    app_label = 'real_heroines'
    db_table = 'rh_heroine'
  