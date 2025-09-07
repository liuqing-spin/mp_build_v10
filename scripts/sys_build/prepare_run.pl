	system("mkdir -p ../traj_1");
	open OUTPUT, ">../traj_1/run_cpu.sh" or die "can not create!\n";
	print OUTPUT "#!/bin/bash

source /home/liuqing/Downloads/software/amber20/amber.sh
source $ARGV[0]
export CUDA_VISIBLE_DEVICES=0

export prmtop=system_start.prmtop
export name=system_start

mpirun -np 20 \$AMBERHOME/bin/pmemd.MPI -O -i 01_Min.in -o 01_Min.out -p \$prmtop -c \${name}.inpcrd -r 01_Min.rst 

mpirun -np 20 \$AMBERHOME/bin/pmemd.MPI -O -i 02_Min2.in -o 02_Min2.out -p \$prmtop -c 01_Min.rst -r 02_Min2.rst 

mpirun -np 20 \$AMBERHOME/bin/pmemd.MPI -O -i 03_Heat.in -o 03_Heat.out -p \$prmtop -c 02_Min2.rst -r 03_Heat.rst -x 03_Heat.nc -ref 02_Min2.rst


mpirun -np 20 \$AMBERHOME/bin/pmemd.MPI -O -i 04_Heat2.in -o 04_Heat2.out -p \$prmtop -c 03_Heat.rst -r 04_Heat2.rst -x 04_Heat2.nc -ref 03_Heat.rst

mpirun -np 20 \$AMBERHOME/bin/pmemd.MPI -O -i 05_Back.in -o 05_Back.out -p \$prmtop -c 04_Heat2.rst -r 05_Back.rst -x 05_Back.nc -ref 04_Heat2.rst -inf 05_Back.mdinfo

mpirun -np 20 \$AMBERHOME/bin/pmemd.MPI -O -i 06_Calpha.in -o 06_Calpha.out -p \$prmtop -c 05_Back.rst -r 06_Calpha.rst -x 06_Calpha.nc -ref 05_Back.rst 


export name=1
mpirun -np 20 \$AMBERHOME/bin/pmemd.MPI -O -i 07_Prod.in -o 07_Prod_\$name.out -p \$prmtop -c 06_Calpha.rst -r 07_Prod_\$name.rst -x 07_Prod_\$name.nc -inf 07_Prod_\$name.mdinfo

	";
	close OUTPUT;

	open OUTPUT, ">../traj_1/run_gpu.sh" or die "can not create!\n";
	print OUTPUT "#!/bin/bash
	
source /home/liuqing/Downloads/software/amber20/amber.sh
source $ARGV[0]
export CUDA_VISIBLE_DEVICES=0

export prmtop=system_start.prmtop
export name=system_start
\$AMBERHOME/bin/pmemd.cuda -O -i 01_Min.in -o 01_Min.out -p \$prmtop -c \${name}.inpcrd -r 01_Min.rst

\$AMBERHOME/bin/pmemd.cuda -O -i 02_Min2.in -o 02_Min2.out -p \$prmtop -c 01_Min.rst -r 02_Min2.rst

mpirun -np 20 \$AMBERHOME/bin/pmemd.MPI -O -i 03_Heat.in -o 03_Heat.out -p \$prmtop -c 02_Min2.rst -r 03_Heat.rst -x 03_Heat.nc -ref 02_Min2.rst


mpirun -np 20 \$AMBERHOME/bin/pmemd.MPI -O -i 04_Heat2.in -o 04_Heat2.out -p \$prmtop -c 03_Heat.rst -r 04_Heat2.rst -x 04_Heat2.nc -ref 03_Heat.rst

\$AMBERHOME/bin/pmemd.cuda -O -i 05_Back.in -o 05_Back.out -p \$prmtop -c 04_Heat2.rst -r 05_Back.rst -x 05_Back.nc -ref 04_Heat2.rst -inf 05_Back.mdinfo

\$AMBERHOME/bin/pmemd.cuda -O -i 06_Calpha.in -o 06_Calpha.out -p \$prmtop -c 05_Back.rst -r 06_Calpha.rst -x 06_Calpha.nc -ref 05_Back.rst


export name=1
\$AMBERHOME/bin/pmemd.cuda -O -i 07_Prod_\$name.in -o 07_Prod_\$name.out -p \$prmtop -c 06_Calpha.rst -r 07_Prod_\$name.rst -x 07_Prod_\$name.nc -inf 07_Prod_\$name.mdinfo

	";
	close OUTPUT;


	open OUTPUT, ">../traj_1/01_Min.in" or die "can not create!\n";
	print OUTPUT "minimize
 &cntrl
  imin=1,maxcyc=1000,ncyc=500,
  ntb=1,ntp=0,
  ntf=1,ntc=1,
  ntpr=50,
  ntwr=2000,
  cut=10.0,
 /";
	close OUTPUT;

	open OUTPUT, ">../traj_1/02_Min2.in" or die "can not create!\n";
	print OUTPUT "minimize
 &cntrl
  imin=1,maxcyc=10000,ncyc=5000,
  ntb=1,ntp=0,
  ntf=1,ntc=1,
  ntpr=50,
  ntwr=2000,
  cut=10.0,
 /";
	close OUTPUT;


	open OUTPUT, ">../traj_1/03_Heat.in" or die "can not create!\n";
	print OUTPUT "heating LIPID 128 100K
 &cntrl
   imin=0, ntx=1, irest=0,
   ntc=2, ntf=2, tol=0.0000001,
   nstlim=5000, ntt=3, gamma_ln=1.0,
   ntr=0, ig=-1,
   ntpr=100, ntwr=100,ntwx=100,
   dt=0.0005,nmropt=1,
   ntb=1,ntp=0,cut=10.0,ioutfm=1,ntxo=2,
   tempi = 0, temp0 = 100,
 /
 &wt type='TEMP0', istep1=0, istep2=4000, value1=0.0, value2=100.0 /
 &wt type='TEMP0', istep1=4001, istep2=5000, value1=100.0, value2=100.0 /
 &wt type='END' /";
 	close OUTPUT;


	open OUTPUT, ">../traj_1/04_Heat2.in" or die "can not create!\n";
	print OUTPUT "heating LIPID 128 303K
 &cntrl
   imin=0, ntx=5, irest=1,
   ntc=2, ntf=2,tol=0.0000001,
   nstlim=50000, ntt=3, gamma_ln=1.0,
   ntr=1, ig=-1,
   ntpr=10000, ntwr=10000,ntwx=10000,
   dt=0.002,nmropt=1,
   ntb=2,taup=2.0,cut=10.0,ioutfm=1,ntxo=2,
   ntp=2,
   restraint_wt=5.0, restraintmask='!:WAT,Na+,K+,Cl-',
   iwrap = 1
 /
 &wt type='TEMP0', istep1=0, istep2=50000,
                   value1=100.0, value2=303.0 /
 &wt type='END' /";
	close OUTPUT;

	open OUTPUT, ">../traj_1/05_Back.in" or die "can not create!\n";
	print OUTPUT "pro 1ns LIPID 303K backbone atoms
 &cntrl
   imin=0, ntx=5, irest=1,
   ntc=2, ntf=2, tol=0.0000001,
   nstlim=500000, ntt=3, gamma_ln=1.0,
   temp0=303.0,
   ntpr=50000, ntwr=500000, ntwx=50000,
   dt=0.002, ig=-1,
   ntr=1, ntb=2, cut=10.0, ioutfm=1, ntxo=2,
   ntp=3, csurften=3, gamma_ten=0.0, ninterface=2,
   restraint_wt=5.0, restraintmask=':\@CA,C,N'
   iwrap = 1
 /
 /
 &ewald
  skinnb=3.0,
 /";
	close OUTPUT;

	open OUTPUT, ">../traj_1/06_Calpha.in" or die "can not create!\n";
	print OUTPUT "pro 1ns LIPID 303K alpha carbons only
 &cntrl
   imin=0, ntx=5, irest=1,
   ntc=2, ntf=2, tol=0.0000001,
   nstlim=500000, ntt=3, gamma_ln=1.0,
   temp0=303.0,
   ntpr=5000, ntwr=500000, ntwx=5000,
   dt=0.002, ig=-1,
   ntr=1, ntb=2, cut=10.0, ioutfm=1, ntxo=2,
   ntp=3, csurften=3, gamma_ten=0.0, ninterface=2,
   restraint_wt=5.0, restraintmask=':\@CA'
   iwrap = 1
 /
 /
 &ewald
  skinnb=3.0,
 /";
 	close OUTPUT;

	open OUTPUT, ">../traj_1/07_Prod_1.in" or die "can not create!\n";
	print OUTPUT "pro 100ns LIPID 303K
 &cntrl
   imin=0, ntx=5, irest=1,
   ntc=2, ntf=2, tol=0.0000001,
   nstlim=100000000, ntt=3, gamma_ln=1.0,
   temp0=303.0,
   ntpr=50000, ntwr=50000, ntwx=50000,
   dt=0.002, ig=-1,
   ntb=2, cut=10.0, ioutfm=1, ntxo=2,
   ntp=3, csurften=3, gamma_ten=0.0, ninterface=2,
   iwrap = 1
 /
 /
 &ewald
  skinnb=3.0,
 /";
	close OUTPUT;

	system("cp system_start.prmtop ../traj_1/");
	system("cp system_start.inpcrd ../traj_1/");
