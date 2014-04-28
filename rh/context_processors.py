from django.conf import settings

def navigation(request):
    context = {}
    if request.path == '/':
      context['current_page'] = 'grid'
    else:
      context['current_page'] = request.resolver_match.url_name

    return context