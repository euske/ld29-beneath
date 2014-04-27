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

##
PYTHON=python
LAME=lame
CSV2PNG=$(PYTHON) tools/csv2png.py

.SUFFIXES: .png .csv .wav .mp3

.csv.png:
	$(CSV2PNG) $< $@

.wav.mp3:
	$(LAME) $< $@

assets: assets/levels/tilemap.png \
	assets/levels/dirtmap.png \
	assets/sounds/dig.mp3 \
	assets/sounds/jump.mp3 \
	assets/sounds/hurt.mp3 \
	assets/sounds/bombtick.mp3 \
	assets/sounds/explosion.mp3

assets/levels/tilemap.png: assets/levels/tilemap.csv
assets/levels/dirtmap.png: assets/levels/dirtmap.csv

assets/sounds/dig.mp3: assets/sounds/dig.wav
assets/sounds/jump.mp3: assets/sounds/jump.wav
assets/sounds/hurt.mp3: assets/sounds/hurt.wav
assets/sounds/bombtick.mp3: assets/sounds/bombtick.wav
assets/sounds/explosion.mp3: assets/sounds/explosion.wav
