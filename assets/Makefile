# Makefile for assets

PYTHON=python
LAME=lame
CSV2PNG=$(PYTHON) ../tools/csv2png.py
CATIMAGE=$(PYTHON) ../tools/catimage.py

.SUFFIXES: .png .csv .wav .mp3

.wav.mp3:
	$(LAME) $< $@

ASSETS=levels/tilemap1.png \
	levels/dirtmap1.png \
	skinset.png \
	sounds/dig.mp3 \
	sounds/jump.mp3 \
	sounds/hurt.mp3 \
	sounds/collect.mp3 \
	sounds/bombtick.mp3 \
	sounds/explosion.mp3 \
	sounds/unbreakable.mp3 \
	sounds/diggrave.mp3 \
	sounds/powerup.mp3

all: $(ASSETS)

clean:
	-$(RM) $(ASSETS)

skinset.png: characters/necrobot_*.png
	$(CATIMAGE) -p -o $@ characters/necrobot_front.png \
		characters/necrobot_nodig.png \
		characters/necrobot_walk.png \
		characters/necrobot_ladder.png \
		characters/necrobot_damage.png \
		characters/necrobot_cheer.png \
		characters/mole_wheel.png \
		characters/robocake_blink.png \
		characters/spinbat.png

sounds/dig.mp3: sounds/dig.wav
sounds/jump.mp3: sounds/jump.wav
sounds/hurt.mp3: sounds/hurt.wav
sounds/collect.mp3: sounds/collect.wav
sounds/bombtick.mp3: sounds/bombtick.wav
sounds/explosion.mp3: sounds/explosion.wav
sounds/unbreakable.mp3: sounds/unbreakable.wav
sounds/diggrave.mp3: sounds/diggrave.wav
sounds/powerup.mp3: sounds/powerup.wav
