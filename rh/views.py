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

  if request.user.is_staff:
    context['heroines'] = Heroine.objects.all()
    if slug is not None:
      try:
        context['selected_heroine'] = Heroine.objects.get(slug=slug)
      except Heroine.DoesNotExist:
        raise Http404
  else:
    context['heroines'] = Heroine.objects.filter(is_public=True).all()
    if slug is not None:
      try:
        context['selected_heroine'] = Heroine.objects.get(slug=slug,is_public=True)
      except Heroine.DoesNotExist:
        raise Http404

  return TemplateResponse(request, template, context)