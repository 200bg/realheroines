from django.shortcuts import render
from django.template import loader
from django.template.response import TemplateResponse
from django.http import Http404
from django.conf import settings

from rh.models import Heroine


# Create your views here.
def home(request, slug=None):
  context = {}
  template = loader.get_template('index.jade')
  selected_heroine = None
  previous_heroine = None
  next_heroine = None

  if request.user.is_staff and request.GET.get('preview', False):
    context['heroines'] = Heroine.objects.all()
    context['heroines_json'] = settings.MEDIA_URL + 'heroines-preview.json'
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
    context['heroines_json'] = settings.MEDIA_URL + 'heroines.json'
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