from django.conf import settings
from django.conf.urls import patterns, include, url
from django.contrib import admin
from django.views.generic import TemplateView

import dnsapp.views

# admin.autodiscover()

handler404 = TemplateView.as_view(template_name='dnsapp/404.html')
handler500 = TemplateView.as_view(template_name='dnsapp/500.html')

urlpatterns = patterns('',
    url(r'static/(?P<path>.*)',
        'django.views.static.serve',
        {'document_root': settings.STATIC_ROOT}),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^404', handler404),
    url(r'^500', handler500),
    url(r'^$', TemplateView.as_view(template_name='dnsapp/home.html'), name='home'),
    url(r'^dns-list', handler404, name='dns-list'),
    url(r'^rdns-list', handler404, name='rdns-list'),
    url(r'^ip/(?P<ip>[0-9.]+)?', dnsapp.views.ip, name='dns-ip'),
)
