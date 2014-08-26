import os
from collections import OrderedDict
from PIL import Image

PART_TYPES = [
    'hair',
    'torso',
    'head',
    'mouth',
    'eyes-opened',
    # 'eyes-closed',
]

def composite_pack(path_to_pack):
    parts = OrderedDict({})

    for pt in PART_TYPES:
        try:
            img = Image.open(os.path.join(path_to_pack, '{0}.png'.format(pt)), 'r')
            parts[pt] = img
        except IOError:
            # if we can't find the image, it might have not been provided, skip it.
            continue

    size = img.size

    composite = Image.new('RGBA', size, (255, 0, 0 ,0))

    for k, p in parts.items():
        # for GC
        # old_composite = composite
        composite = Image.alpha_composite(composite, p)

    composite_path = os.path.join(path_to_pack, 'composite.png')
    composite.save(composite_path, 'PNG')

    return composite_path
