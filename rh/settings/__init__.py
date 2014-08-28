"""
Django settings for rh project.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.6/ref/settings/
"""

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os
BASE_DIR = os.path.dirname(os.path.dirname(__file__))
from django.conf import global_settings

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.6/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'THIS IS MY SECRET'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False

TEMPLATE_DEBUG = DEBUG

ALLOWED_HOSTS = ['realheroines.com','www.realheroines.com']


# Application definition

INSTALLED_APPS = (
    'pipeline',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'south',
    'imagekit',
    'rh',
)

MIDDLEWARE_CLASSES = (
    'rh.middleware.MaintenanceModeMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

TEMPLATE_LOADERS = (
    ('pyjade.ext.django.Loader',(
        'django.template.loaders.filesystem.Loader',
        'django.template.loaders.app_directories.Loader',
    )),
)

# I hate STATICFILES_DIRS anyway.
# STATICFILES_DIRS = (
#     os.path.normpath('{0}/static'.format(BASE_DIR)),
# )

TEMPLATE_DIRS = (
    os.path.normpath('{0}/templates'.format(BASE_DIR)),
)

TEMPLATE_CONTEXT_PROCESSORS = global_settings.TEMPLATE_CONTEXT_PROCESSORS + (
    'rh.context_processors.navigation',
)

ROOT_URLCONF = 'rh.urls'

WSGI_APPLICATION = 'rh.wsgi.application'

# Database
# https://docs.djangoproject.com/en/1.6/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db/realheroines.sqlite3'),
    }
}

# Internationalization
# https://docs.djangoproject.com/en/1.6/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.6/howto/static-files/
STATIC_ROOT = '/var/www/realheroines.com/rh/static/'
MEDIA_ROOT = '/var/www/realheroines.com/rh/static/media/'

STATIC_URL = 'http://static.realheroines.com/'
MEDIA_URL = 'http://static.realheroines.com/media/'

STATICFILES_FINDERS = (
    'pipeline.finders.FileSystemFinder',
    'pipeline.finders.AppDirectoriesFinder',
    'pipeline.finders.PipelineFinder',
    'pipeline.finders.CachedFileFinder',
)


STATICFILES_STORAGE = 'pipeline.storage.PipelineCachedStorage'

PIPELINE_COMPILERS = (
  'pipeline.compilers.less.LessCompiler',
  'pipeline.compilers.coffee.CoffeeScriptCompiler',
)
# compressor args
# don't be fooled. these don't run in dev
# this happens when you run collectstatic on the live server
PIPELINE_CSS = {
  'styles': {
    'source_filenames': ('css/base.css','css/skeleton.css','css/layout.less',),
    'output_filename': 'css/styles.css',
    'extra_context': {
      'media': 'screen,projection'
    },
  },
}

PIPELINE_JS = {
  'rh': {
    'source_filenames': ('js/lib.js','js/easypeasy.coffee','js/rh.coffee',),
    'output_filename': 'js/rh.js',
  },
}

PIPELINE_CSS_COMPRESSOR = 'pipeline.compressors.cssmin.CSSMinCompressor'
PIPELINE_CSSMIN_BINARY = 'cssmin'


# load local stuff
local_settings_file = os.path.join(BASE_DIR, 'settings/local_settings.py')
exec(compile(open(os.path.abspath(local_settings_file)).read(), local_settings_file, 'exec'), globals(), locals())