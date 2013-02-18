MANAGE_PY = python manage.py

all:
	$(MANAGE_PY) validate

run:
	$(MANAGE_PY) runserver

shell:
	$(MANAGE_PY) shell

test:
	$(MANAGE_PY) test

resetdb:
	@# Keep django.db because it contains user credentials for admin
	@[ ! -f django.db ] || echo "Keeping django.db file"
	rm -f dns.db
	$(MANAGE_PY) syncdb
	$(MANAGE_PY) syncdb --database=dns

# Load example data
loadexample:
	echo 'exec(open("fixtures/example.py"))' |$(MANAGE_PY) shell
