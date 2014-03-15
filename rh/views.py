from django.shortcuts import render
from django.template import loader
from django.template.response import TemplateResponse
from django.conf import settings

from rh.models import Heroine


# Create your views here.
def home(request):
  context = {}
  template = loader.get_template('index.jade')

  if request.user.is_staff:
    context['heroines'] = Heroine.objects.all()
  else:
    context['heroines'] = Heroine.objects.filter(is_public=True).all()

  return TemplateResponse(request, template, context)