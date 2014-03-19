from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # coffeescript app handles the layout so we just load home.
    url(r'^$', 'rh.views.home', name='home'),
    url(r'^grid/$', 'rh.views.home', name='grid'),
    url(r'^portrait/$', 'rh.views.home', name='portrait'),
    url(r'^portrait/(?P<slug>.+?)/$', 'rh.views.home', name='heroine'),
    url(r'^timeline/$', 'rh.views.home', name='timeline'),
    url(r'^about/$', 'rh.views.home', name='about'),
    # url(r'^blog/', include('blog.urls')),

    url(r'^admin/', include(admin.site.urls)),
)
