import os
from collections import OrderedDict
from django.core.management.base import BaseCommand, CommandError
from django.utils import translation
from django.db.models import Q


class Command(BaseCommand):

    def handle(self, *args, **options):
        if len(args) > 0:
            print('`composite_all` Doesn\'t takes any arguments.')
            exit()

        from django.conf import settings
        from rh.compositer import composite_pack
        from rh.models import Heroine
        heroines = Heroine.objects.all()

        for heroine in heroines:
            packs_dir = os.path.join(settings.MEDIA_ROOT, 'packs', heroine.slug)

            if not os.path.exists(packs_dir):
                print('Directory "{0}" doesn\'t exist. No images to composite for "{1}".'.format(packs_dir, heroine.name))
                continue
            
            composite_path = composite_pack(packs_dir)

            print('Saved to "{0}".'.format(composite_path))





