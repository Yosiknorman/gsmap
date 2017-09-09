#!/bin/bash


for i in `ls data | grep .dat.gz`
do
	cd data
	gunzip < ${i} > `echo $i | sed -e 's/.gz//g'`
	ff=`echo $i | sed -e 's/.gz//g'`
	dmy=`echo $ff | sed s/gsmap_nrt.//g | sed s/00.dat.gz//g`  # 20081010.14
	tahun=${dmy:0:4}
	bulan=${dmy:4:2}
	tanggal=${dmy:6:2}
	jam=${dmy:9:2}
	
	# <<<<<<< MEMBUAT CTL >>>>>>> #
	echo "DSET `echo $i | sed -e 's/.gz//g'`" > bacadat.ctl
	echo "TITLE  GSMaP_NRT 0.1deg Hourly" >> bacadat.ctl
	echo "OPTIONS YREV LITTLE_ENDIAN" >> bacadat.ctl
	echo "UNDEF  -99.0" >> bacadat.ctl
	echo "XDEF   3600 LINEAR  0.05 0.1" >> bacadat.ctl
	echo "YDEF   1200  LINEAR -59.95 0.1" >> bacadat.ctl
	echo "ZDEF     1 LEVELS 1013" >> bacadat.ctl
	echo "TDEF   87600 LINEAR ${jam}Z${tanggal}oct${tahun} 1hr" >> bacadat.ctl
	echo "VARS    1" >> bacadat.ctl
	echo "precip    0  99   hourly averaged rain rate [mm/hr]" >> bacadat.ctl
	echo "ENDVARS" >> bacadat.ctl
	
	# <<<<<<< MEMBUAT GS >>>>>>>> #
	echo "'""open bacadat.ctl""'" > baca_nc.gs
	echo "'""set lat -10 10""'" >> baca_nc.gs
	echo "'""set lon 90 120""'" >> baca_nc.gs
	echo "'""set time ${jam}Z${tanggal}oct${tahun}""'"  >> baca_nc.gs
	echo "'""define pcp=precip""'" >> baca_nc.gs
	echo "'""set sdfwrite ../output/gsmap.${dmy}.nc""'" >> baca_nc.gs
	echo "'""sdfwrite pcp""'" >> baca_nc.gs
	
	# <<<<<<< RUNNING GRADS >>>>>> #
	grads -lbxc baca_nc.gs

	rm `echo $i | sed s/.dat.gz/.dat/g`
	cd ..
	
	mv data/bacadat.ctl file_ctl_perfile/${tahun}${bulan}${tanggal}${jam}.ctl
	mv data/baca_nc.gs file_gs/${tahun}${bulan}${tanggal}${jam}.gs
	
done