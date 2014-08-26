from django.contrib import admin
from rh.models import Heroine

class HeroineAdmin(admin.ModelAdmin):
  # readonly_fields = ('grid_image_thumbnail', 'timeline_image_thumbnail',)
  prepopulated_fields = {'slug': ('name',)}
  fieldsets = (
    ('Details', {
      'fields': ('name', 'slug', 'top_offset', 'title', 'nickname', 'is_public', 'birthdate', 'birthdate_is_approximate', 'deathdate', 'country', 'description',),
    }),
    ('Imagery', {
      'fields': ('hero_image','animation_pack'),
    }),
  )

  list_display = ('name', 'slug', 'is_public')
  list_editable = ['is_public']
  list_filter = ['is_public', 'country']
  search_fields = ['name']

admin.site.register(Heroine, HeroineAdmin)
