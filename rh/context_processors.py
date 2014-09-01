from django.conf import settings

def navigation(request):
    context = {}
    if request.path == '/':
      context['current_page'] = 'grid'
    else:
      context['current_page'] = request.resolver_match.url_name
      
    about_face_range = list(range(0,35))
    for n in about_face_range:
      if n < 9:
        about_face_range[n] = '0' + str(n+1)
      else:
        about_face_range[n] = str(n+1)
        
    context['about_face_range'] = about_face_range

    return context