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
CATIMAGE=$(PYTHON) tools/catimage.py

.SUFFIXES: .png .csv .wav .mp3

.csv.png:
	$(CSV2PNG) $< $@

.wav.mp3:
	$(LAME) $< $@

assets: assets/levels/tilemap1.png \
	assets/levels/dirtmap1.png \
	assets/skinset.png \
	assets/sounds/dig.mp3 \
	assets/sounds/jump.mp3 \
	assets/sounds/hurt.mp3 \
	assets/sounds/collect.mp3 \
	assets/sounds/bombtick.mp3 \
	assets/sounds/explosion.mp3 \
	assets/sounds/unbreakable.mp3

assets/levels/tilemap1.png: assets/levels/mapCSV_Group1_tilemap1.csv
	$(CSV2PNG) $< $@
assets/levels/dirtmap1.png: assets/levels/mapCSV_Group1_dirtmap1.csv
	$(CSV2PNG) $< $@

assets/skinset.png: assets/characters/necrobot_*.png
	$(CATIMAGE) -p -o $@ assets/characters/necrobot_front.png \
		assets/characters/necrobot_nodig.png \
		assets/characters/necrobot_walk.png \
		assets/characters/necrobot_ladder.png \
		assets/characters/necrobot_damage.png \
		assets/characters/necrobot_cheer.png \
		assets/characters/robocake_blink.png

assets/sounds/dig.mp3: assets/sounds/dig.wav
assets/sounds/jump.mp3: assets/sounds/jump.wav
assets/sounds/hurt.mp3: assets/sounds/hurt.wav
assets/sounds/collect.mp3: assets/sounds/collect.wav
assets/sounds/bombtick.mp3: assets/sounds/bombtick.wav
assets/sounds/explosion.mp3: assets/sounds/explosion.wav
assets/sounds/unbreakable.mp3: assets/sounds/unbreakable.wav
