# -*- coding: utf-8 -*-
from south.utils import datetime_utils as datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding field 'Heroine.birthdate_is_approximate'
        db.add_column('rh_heroine', 'birthdate_is_approximate',
                      self.gf('django.db.models.fields.BooleanField')(default=False),
                      keep_default=False)


    def backwards(self, orm):
        # Deleting field 'Heroine.birthdate_is_approximate'
        db.delete_column('rh_heroine', 'birthdate_is_approximate')


    models = {
        'rh.heroine': {
            'Meta': {'ordering': "['birthdate', 'name']", 'object_name': 'Heroine'},
            'animation_pack': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True', 'blank': 'True'}),
            'birthdate': ('django.db.models.fields.DateField', [], {}),
            'birthdate_is_approximate': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'country': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'deathdate': ('django.db.models.fields.DateField', [], {'null': 'True', 'blank': 'True'}),
            'description': ('django.db.models.fields.TextField', [], {}),
            'description_html': ('django.db.models.fields.TextField', [], {}),
            'description_text': ('django.db.models.fields.TextField', [], {}),
            'hero_image': ('django.db.models.fields.files.ImageField', [], {'max_length': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_public': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '140'}),
            'nickname': ('django.db.models.fields.CharField', [], {'max_length': '140'}),
            'slug': ('django.db.models.fields.SlugField', [], {'max_length': '150'}),
            'title': ('django.db.models.fields.CharField', [], {'max_length': '140'}),
            'top_offset': ('django.db.models.fields.FloatField', [], {'default': "'-12'", 'null': 'True', 'blank': 'True'})
        }
    }

    complete_apps = ['rh']