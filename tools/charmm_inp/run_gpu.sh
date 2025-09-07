#!/bin/bash
np_n=`nproc`
np_n2=$(($np_n/2-4))
#np_n2=28

export gpuid=0
namd2 +p$np_n2 +devices $gpuid  01_Min.inp > 01_Min.out 
sleep 3s

namd2 +p$np_n2 +devices $gpuid 02_Heat.inp > 02_Heat.out
sleep 3s

namd2 +p$np_n2 +devices $gpuid 03_NPT.inp > 03_NPT.out 
sleep 3s

namd3 +p$np_n2 +devices $gpuid 04_Hold_1.inp > 04_Hold_1.out
sleep 3s

for i in {2..10};
do	
	namd3 +p$np_n2 +devices $gpuid 04_Hold_$i.inp > 04_Hold_$i.out
	sleep 3s
done

namd3 +p$np_n2 +devices $gpuid 05_Prod_1.inp > 05_Prod_1.out
	
