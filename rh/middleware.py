import re
from django.conf import settings
from django.core import urlresolvers
from django.http import HttpResponse

class MaintenanceModeMiddleware(object):
    def process_request(self, request):
        if not getattr(settings, 'MAINTENANCE', False):
            return None

        # Allow access if the user doing the request is logged in and a
        # staff member.
        if hasattr(request, 'user') and request.user.is_staff:
            return None

        # Check if a path is explicitly excluded from maintenance mode
        if request.path_info.startswith('/admin'):
            return None

        # Otherwise show the user the 503 page
        resolver = urlresolvers.get_resolver(None)
        maintenance_page = open(settings.STATIC_ROOT + '/maintenance.html')
        maintenance_page_string = maintenance_page.read()
        maintenance_page.close()

        return HttpResponse(maintenance_page_string, status=503)