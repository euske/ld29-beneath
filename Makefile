# Makefile
RSYNC=/usr/bin/rsync \
	--exclude NOBACKUP/ \
	--exclude LOCAL/ \
	--exclude local/ \
	--exclude tmp/ \
	--exclude obj/ \
	--exclude screenshots/ \
	--exclude Makefile \
	--exclude '.??*' \
	--exclude '*.bak' \
	--exclude '*~'

PROJECT=beneath_post-compo

DROPBOXBASE=$$HOME/Dropbox/ld29
WWWBASE=tabesugi:public/file/ludumdare.tabesugi.net/necrobot_postcompo

all: 

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
