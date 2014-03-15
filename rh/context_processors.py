from django.conf import settings

def navigation(request):
    context = {}
    context['current_page'] = request.resolver_match.url_name

    return context