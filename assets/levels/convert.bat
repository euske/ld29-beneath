REM How to use:
REM Install Python 2.7 and Pygame 1.9! 
REM https://www.python.org/download/releases/2.7.6/
REM http://pygame.org/ftp/pygame-1.9.1.win32-py2.7.msi

python ..\..\tools\csv2png.py -T tilemap0.png mapCSV_Group1_tilemap0.csv mapCSV_Group1_dirtmap0.csv
python ..\..\tools\csv2png.py -D dirtmap0.png mapCSV_Group1_tilemap0.csv mapCSV_Group1_dirtmap0.csv

python ..\..\tools\csv2png.py -T tilemap1.png mapCSV_Group1_tilemap1.csv mapCSV_Group1_dirtmap1.csv
python ..\..\tools\csv2png.py -D dirtmap1.png mapCSV_Group1_tilemap1.csv mapCSV_Group1_dirtmap1.csv

python ..\..\tools\csv2png.py -T tilemap2.png mapCSV_Group1_tilemap2.csv mapCSV_Group1_dirtmap2.csv
python ..\..\tools\csv2png.py -D dirtmap2.png mapCSV_Group1_tilemap2.csv mapCSV_Group1_dirtmap2.csv

python ..\..\tools\csv2png.py -T tilemap3.png mapCSV_Group1_tilemap3.csv mapCSV_Group1_dirtmap3.csv
python ..\..\tools\csv2png.py -D dirtmap3.png mapCSV_Group1_tilemap3.csv mapCSV_Group1_dirtmap3.csv

pause
