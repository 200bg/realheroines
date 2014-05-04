# -*- coding: utf-8 -*-
from south.utils import datetime_utils as datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding model 'Heroine'
        db.create_table('rh_heroine', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=140)),
            ('title', self.gf('django.db.models.fields.CharField')(max_length=140)),
            ('nickname', self.gf('django.db.models.fields.CharField')(max_length=140,null=True,blank=True)),
            ('slug', self.gf('django.db.models.fields.SlugField')(max_length=150)),
            ('birthdate', self.gf('django.db.models.fields.DateField')()),
            ('deathdate', self.gf('django.db.models.fields.DateField')(null=True, blank=True)),
            ('country', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('is_public', self.gf('django.db.models.fields.BooleanField')(default=False)),
            ('hero_image', self.gf('django.db.models.fields.files.ImageField')(max_length=100)),
            ('description', self.gf('django.db.models.fields.TextField')()),
            ('description_html', self.gf('django.db.models.fields.TextField')()),
            ('description_text', self.gf('django.db.models.fields.TextField')()),
        ))
        db.send_create_signal('rh', ['Heroine'])


    def backwards(self, orm):
        # Deleting model 'Heroine'
        db.delete_table('rh_heroine')


    models = {
        'rh.heroine': {
            'Meta': {'ordering': "['birthdate', 'name']", 'object_name': 'Heroine'},
            'birthdate': ('django.db.models.fields.DateField', [], {}),
            'country': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'deathdate': ('django.db.models.fields.DateField', [], {'null': 'True', 'blank': 'True'}),
            'description': ('django.db.models.fields.TextField', [], {}),
            'description_html': ('django.db.models.fields.TextField', [], {}),
            'description_text': ('django.db.models.fields.TextField', [], {}),
            'hero_image': ('django.db.models.fields.files.ImageField', [], {'max_length': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_public': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '140'}),
            'title': ('django.db.models.fields.CharField', [], {'max_length': '140'}),
            'nickname': ('django.db.models.fields.CharField', [], {'max_length': '140'}),
            'slug': ('django.db.models.fields.SlugField', [], {'max_length': '150'})
        }
    }

    complete_apps = ['rh']