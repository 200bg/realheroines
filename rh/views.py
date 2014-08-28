import os
from django.shortcuts import render
from django.template import loader
from django.template.response import TemplateResponse
from django.http import Http404, HttpResponse
from django.conf import settings
from django.core.urlresolvers import reverse

from rh.models import Heroine

def json(request):
  fh = open(os.path.join(settings.MEDIA_ROOT, 'heroines.json'))
  r = HttpResponse()
  r['Content-Type'] = 'application/json'
  # r['Access-Control-Allow-Origin'] = 'http://' + request.META['HTTP_HOST']
  r.write(fh.read())
  return r

def json_preview(request):
  fh = open(os.path.join(settings.MEDIA_ROOT, 'heroines-preview.json'))
  r = HttpResponse()
  r['Content-Type'] = 'application/json'
  # r['Access-Control-Allow-Origin'] = 'http://' + request.META['HTTP_HOST']
  r.write(fh.read())
  return r

def home(request, slug=None):
  context = {}
  template = loader.get_template('index.jade')
  selected_heroine = None
  previous_heroine = None
  next_heroine = None

  if request.user.is_staff and request.GET.get('preview', False):
    context['heroines'] = Heroine.objects.all()
    context['heroines_json'] = '/static/media/heroines-preview.json'
    # context['heroines_json'] = reverse('json_preview')
    if slug is not None:
      try:
        selected_heroine = Heroine.objects.get(slug=slug)
        try:
          previous_heroine = Heroine.objects.filter(birthdate__lt=selected_heroine.birthdate).order_by('-birthdate')[0]
        except IndexError:
          previous_heroine = None
        try:
          next_heroine = Heroine.objects.filter(birthdate__gt=selected_heroine.birthdate).order_by('birthdate')[0]
        except IndexError:
          next_heroine = None
      except Heroine.DoesNotExist:
        raise Http404
  else:
    context['heroines'] = Heroine.objects.filter(is_public=True).all()
    context['heroines_json'] = '/static/media/heroines.json'
    # context['heroines_json'] =  reverse('json')
    if slug is not None:
      try:
        selected_heroine = Heroine.objects.get(slug=slug,is_public=True)
        try:
          previous_heroine = Heroine.objects.filter(birthdate__lt=selected_heroine.birthdate,is_public=True).order_by('-birthdate')[0]
        except IndexError:
          previous_heroine = None
        try:
          next_heroine = Heroine.objects.filter(birthdate__gt=selected_heroine.birthdate,is_public=True).order_by('birthdate')[0]
        except IndexError:
          next_heroine = None
      except Heroine.DoesNotExist:
        raise Http404

  context['selected_heroine'] = selected_heroine
  context['previous_heroine'] = previous_heroine
  context['next_heroine'] = next_heroine

  return TemplateResponse(request, template, context)