import os
from collections import OrderedDict
from django.core.management.base import BaseCommand, CommandError
from django.utils import translation
from django.db.models import Q


class Command(BaseCommand):

    def handle(self, *args, **options):
        if len(args) > 1:
            print('Composite only takes one argument: Either slug or name of the heroine to composite.')
            exit()

        from django.conf import settings
        from rh.compositer import composite_pack
        from rh.models import Heroine
        heroine = Heroine.objects.get(Q(name=args[0]) | Q(slug=args[0]))

        packs_dir = os.path.join(settings.MEDIA_ROOT, 'packs', heroine.slug)

        if not os.path.exists(packs_dir):
            print('Directory "{0}" doesn\'t exist. No images to composite.'.format(packs_dir))
            exit(1)
        
        composite_path = composite_pack(packs_dir)

        print('Saved to "{0}".'.format(composite_path))





