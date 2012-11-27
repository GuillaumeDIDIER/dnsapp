class DbRouter(object):
    DJANGO_APPS = ('auth', 'contenttypes', 'sessions', 'admin')
    def db_for_read(self, model, **hints):
        if model._meta.app_label not in self.DJANGO_APPS:
            return 'dns'
        return None

    def db_for_write(self, model, **hints):
        if model._meta.app_label not in self.DJANGO_APPS:
            return 'dns'
        return None

    def allow_syncdb(self, db, model):
        if db == 'dns':
            return model._meta.app_label not in self.DJANGO_APPS
        elif model._meta.app_label not in self.DJANGO_APPS:
            return False
        return None
