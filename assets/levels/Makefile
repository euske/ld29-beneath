# Makefile
RM=rm -f
PYTHON=python
CSV2PNG=$(PYTHON) ../../tools/csv2png.py

all: tilemap0.png dirtmap0.png \
	 tilemap1.png dirtmap1.png \
	 tilemap2.png dirtmap2.png \
	 tilemap3.png dirtmap3.png \
	 tilemap4.png dirtmap4.png

clean: 
	-$(RM) tilemap0.png dirtmap0.png
	-$(RM) tilemap1.png dirtmap1.png
	-$(RM) tilemap2.png dirtmap2.png
	-$(RM) tilemap3.png dirtmap3.png
	-$(RM) tilemap4.png dirtmap4.png
	-$(RM) tilemap5.png dirtmap5.png
	-$(RM) tilemap6.png dirtmap6.png

tilemap0.png: mapCSV_Group1_tilemap0.csv mapCSV_Group1_dirtmap0.csv
	$(CSV2PNG) -T $@ $^
dirtmap0.png: mapCSV_Group1_tilemap0.csv mapCSV_Group1_dirtmap0.csv
	$(CSV2PNG) -D $@ $^

tilemap1.png: mapCSV_Group1_tilemap1.csv mapCSV_Group1_dirtmap1.csv
	$(CSV2PNG) -T $@ $^
dirtmap1.png: mapCSV_Group1_tilemap1.csv mapCSV_Group1_dirtmap1.csv
	$(CSV2PNG) -D $@ $^

tilemap2.png: mapCSV_Group1_tilemap2.csv mapCSV_Group1_dirtmap2.csv
	$(CSV2PNG) -T $@ $^
dirtmap2.png: mapCSV_Group1_tilemap2.csv mapCSV_Group1_dirtmap2.csv
	$(CSV2PNG) -D $@ $^

tilemap3.png: mapCSV_Group1_tilemap3.csv mapCSV_Group1_dirtmap3.csv
	$(CSV2PNG) -T $@ $^
dirtmap3.png: mapCSV_Group1_tilemap3.csv mapCSV_Group1_dirtmap3.csv
	$(CSV2PNG) -D $@ $^

tilemap4.png: mapCSV_Group1_tilemap4.csv mapCSV_Group1_dirtmap4.csv
	$(CSV2PNG) -T $@ $^
dirtmap4.png: mapCSV_Group1_tilemap4.csv mapCSV_Group1_dirtmap4.csv
	$(CSV2PNG) -D $@ $^

tilemap5.png: mapCSV_Group1_tilemap5.csv mapCSV_Group1_dirtmap5.csv
	$(CSV2PNG) -T $@ $^
dirtmap5.png: mapCSV_Group1_tilemap5.csv mapCSV_Group1_dirtmap5.csv
	$(CSV2PNG) -D $@ $^

tilemap6.png: mapCSV_Group1_tilemap6.csv mapCSV_Group1_dirtmap6.csv
	$(CSV2PNG) -T $@ $^
dirtmap6.png: mapCSV_Group1_tilemap6.csv mapCSV_Group1_dirtmap6.csv
	$(CSV2PNG) -D $@ $^
