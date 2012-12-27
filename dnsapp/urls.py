from django.conf import settings
from django.conf.urls import patterns, include, url
from django.contrib import admin
from django.views.generic import TemplateView

# admin.autodiscover()

urlpatterns = patterns('',
    url(r'static/(?P<path>.*)', 'django.views.static.serve', {'document_root': settings.STATIC_ROOT}),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^404', TemplateView.as_view(template_name='dnsapp/404.html')),
    url(r'^500', TemplateView.as_view(template_name='dnsapp/500.html')),
    url(r'^$', TemplateView.as_view(template_name='dnsapp/home.html'), name='home'),
    url(r'^about-ip', TemplateView.as_view(template_name='dnsapp/404.html'), name='about-ip'),
    url(r'^dns-list', TemplateView.as_view(template_name='dnsapp/404.html'), name='dns-list'),
    url(r'^rdns-list', TemplateView.as_view(template_name='dnsapp/404.html'), name='rdns-list'),
)
