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
    url(r'^$', TemplateView.as_view(template_name='dnsapp/home.html'),
        name='home'),

    # Zone description
    url(r'^zones/(?P<pk>.+)', dnsapp.views.ZoneDetailView.as_view(),
        name='zone'),
    # IP description
    url(r'^ip/(?P<ip>[0-9.]+)?', dnsapp.views.ip, name='dns-ip'),

    # A Record
    url(r'^a-records', dnsapp.views.ARecordListView.as_view(),
        name='arec-list'),
    # CNAME Records
    url(r'^cname-records', dnsapp.views.CNAMERecordListView.as_view(),
        name='cnrec-list'),
    # MX Record
    url(r'^mx-records', dnsapp.views.MXRecordListView.as_view(),
        name='mxrec-list'),
    # Zones
    url(r'^zones', dnsapp.views.ZoneListView.as_view(), name='zone-list'),
)
