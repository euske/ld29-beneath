# Makefile
RSYNC=/usr/bin/rsync \
	--exclude NOBACKUP/ \
	--exclude LOCAL/ \
	--exclude local/ \
	--exclude tmp/ \
	--exclude obj/ \
	--exclude Makefile \
	--exclude '.??*' \
	--exclude '*~'

PROJECT=beneath

DROPBOXBASE=$$HOME/Dropbox/ld29
WWWBASE=tabesugi:public/file/ludumdare.tabesugi.net/$(PROJECT)

all:

clean:

upload: bin
	$(RSYNC) -rutv bin/ $(WWWBASE)/

put:
	$(RSYNC) -n --delete -rutv ./ $(DROPBOXBASE)/$(PROJECT)/
put_f:
	$(RSYNC) -rutv ./ $(DROPBOXBASE)/$(PROJECT)/

get:
	$(RSYNC) -n --delete -rutv $(DROPBOXBASE)/$(PROJECT)/ ./
get_f:
	$(RSYNC) -rutv $(DROPBOXBASE)/$(PROJECT)/ ./
