from django.db import models


class Zone(models.Model):
    class Meta:
        db_table = 'zone'
        app_label = 'dnsapp'

    zone = models.CharField(max_length=255, primary_key=True)

    # Champs a supprimer, parfaitement inutiles
    id = models.IntegerField()
    name = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
