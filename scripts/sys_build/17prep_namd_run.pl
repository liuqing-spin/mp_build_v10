
	system("mkdir traj_namd_1");
	
	@cid_list = ();
	@lig_list = ();
	@pep_list = ();
	$wt_inh = undef;
	$orig_pdb = undef;
	$m_path = undef;
	for ($argv_i = 0; $argv_i < @ARGV ; $argv_i++){
		if ($ARGV[$argv_i] eq "-h"){
			print "		-ci	the list of chain IDs.
	-lg	the list of ligand pdbs.
	-lp	the list of peptide pdbs.
	-wt	the water inhole signal, 1 or 0.
	-at	the main path.
	-p	original structure pdb file.
       	";
		die "	-h	print above information\n";
		}
		if ($ARGV[$argv_i] eq "-ci"){
			for ($argv_i2 = $argv_i+1; $argv_i2 < @ARGV; $argv_i2++){
				if ($ARGV[$argv_i2] =~ "^-"){
					last;
				}
				else{
					push @cid_list, $ARGV[$argv_i2];
				}
			}
		}
		if ($ARGV[$argv_i] eq "-lg"){
			for ($argv_i2 = $argv_i+1; $argv_i2 < @ARGV; $argv_i2++){
				if ($ARGV[$argv_i2] =~ "^-"){
					last;
				}
				else{
					push @lig_list, $ARGV[$argv_i2];
				}
			}
		}
		if ($ARGV[$argv_i] eq "-lp"){
			for ($argv_i2 = $argv_i+1; $argv_i2 < @ARGV; $argv_i2++){
				if ($ARGV[$argv_i2] =~ "^-"){
					last;
				}
				else{
					push @pep_list, $ARGV[$argv_i2];
				}
			}
		}
		if ($ARGV[$argv_i] eq "-wt"){
			for ($argv_i2 = $argv_i+1; $argv_i2 < @ARGV; $argv_i2++){
				if ($ARGV[$argv_i2] =~ "^-"){
					last;
				}
				else{
					$wt_inh = $ARGV[$argv_i2];
				}
			}
		}
		if ($ARGV[$argv_i] eq "-at"){
			for ($argv_i2 = $argv_i+1; $argv_i2 < @ARGV; $argv_i2++){
				if ($ARGV[$argv_i2] =~ "^-"){
					last;
				}
				else{
					$m_path = $ARGV[$argv_i2];
				}
			}
		}
		if ($ARGV[$argv_i] eq "-p"){
			for ($argv_i2 = $argv_i+1; $argv_i2 < @ARGV; $argv_i2++){
				if ($ARGV[$argv_i2] =~ "^-"){
					last;
				}
				else{
					$orig_pdb = $ARGV[$argv_i2];
				}
			}
		}
	}
	
	open INPUT, "complex_start.pdb" or die "can not create!\n";
	open OUTPUT, ">./traj_namd_1/prot_posres.ref" or die "can not create!\n";
	$line_c = 0;
	while(chomp($line=<INPUT>)){
		@gezis = split //, $line;
		$atom_mark = undef;
		for ($gezis_i = 0; $gezis_i <= 5; $gezis_i++){
			$atom_mark .= "$gezis[$gezis_i]";
		}
		if ($atom_mark eq "ATOM  "){
			$line_c++;
			$atom_name_clear = undef;
			for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
				if ($gezis[$gezis_i] ne " "){
					$atom_name_clear .= $gezis[$gezis_i];
				}
			}
			if ($atom_name_clear eq "CA") {
				$part_A = undef;
				for ($gezis_i = 0; $gezis_i <= 61 ; $gezis_i++){
					$part_A .= $gezis[$gezis_i];
				}
				$part_B = undef;
				for ($gezis_i = 66; $gezis_i < @gezis ; $gezis_i++){
					$part_B .= $gezis[$gezis_i];
				}
				$output_line = $part_A."1.00".$part_B;
				printf OUTPUT "$output_line\n";
			}
			else{
				print OUTPUT "$line\n";
			}

			$pos_x = undef;
			for ($gezis_i = 30; $gezis_i <= 37; $gezis_i++){
				$pos_x .= "$gezis[$gezis_i]";
			}
			
			$pos_y = undef;
			for ($gezis_i = 38; $gezis_i <= 45; $gezis_i++){
				$pos_y .= "$gezis[$gezis_i]";
			}
			
			$pos_z = undef;
			for ($gezis_i = 46; $gezis_i <= 53; $gezis_i++){
				$pos_z .= "$gezis[$gezis_i]";
			}
			if ($line_c == 1){
				$up_x = $pos_x;
				$down_x = $pos_x;
				$up_y = $pos_y;
				$down_y = $pos_y;
				$up_z = $pos_z;
				$down_z = $pos_z;
			}
			else{
				if ($up_x < $pos_x){
					$up_x = $pos_x;
				}
				if ($down_x > $pos_x){
					$down_x = $pos_x;
				}
				if ($up_y < $pos_y){
					$up_y = $pos_y;
				}
				if ($down_y > $pos_y){
					$down_y = $pos_y;
				}
				if ($up_z < $pos_z){
					$up_z = $pos_z;
				}
				if ($down_z > $pos_z){
					$down_z = $pos_z;
				}
			}
		}
	
	}
	close INPUT;
	$len_x = $up_x - $down_x;
	$len_y = $up_y - $down_y;
	$len_z = $up_z - $down_z;

	$cen_x = ($up_x + $down_x)/2;
	$cen_y = ($up_y + $down_y)/2;
	$cen_z = ($up_z + $down_z)/2;

	close OUTPUT;
	
	open OUTPUT, ">./traj_namd_1/00_input.str" or die "can not create!\n";
	print OUTPUT " set boxtype  rect
 set xtltype  tetragonal
 set a        $len_x
 set b        $len_y
 set c        $len_z
 set alpha    90.0
 set beta     90.0
 set gamma    90.0
 set xcen     $cen_x
 set ycen     $cen_y
 set zcen     $cen_z\n";
	close OUTPUT;

	open INPUT, "build_leap.in" or die "can not open 4!\n";
	@lig_str_list = ();
	while(chomp($line=<INPUT>)){
		if ($line=~"^loadoff.*"){
			@items_a = split /\//, $line;
			@items_b = split /\./, $items_a[-1];
			push @lig_str_list , $items_b[0];
		}
	}
	close INPUT;

	system("cp complex_start.psf complex_start.pdb ./traj_namd_1/");
	system("cp $m_path/tools/charmm_inp/run_gpu.sh ./traj_namd_1/");
	system("cp -r  $m_path/tools/toppar ./traj_namd_1/");

	#for ($lig_i = 0; $lig_i < @lig_str_list; $lig_i++){
	#	system("cp $m_path/databases/nonaa/$lig_str_list[$lig_i].str ./traj_namd_1/toppar/");
	#}

	opendir (INP, "$m_path/tools/charmm_inp/") or die "can not open opmdir!\n";
	@inp_files = readdir INP;
	closedir INP;

	for ($file_i  = 0; $file_i < @inp_files ; $file_i++){
		if ($inp_files[$file_i] =~ ".*inp"){
			open INPUT, "$m_path/tools/charmm_inp/$inp_files[$file_i]" or die "can not open 4!\n";
			open OUTPUT, ">./traj_namd_1/$inp_files[$file_i]" or die "can not open 4!\n";
			while(chomp($line=<INPUT>)){
				if ($line=~"^parameters              toppar/toppar_water_ions.str.*"){
					print OUTPUT "$line\n";
					for ($lig_i = 0; $lig_i < @lig_str_list; $lig_i++){
						print OUTPUT "parameters              toppar/lig_manual/$lig_str_list[$lig_i].str\n";
					}
				}
				else{
					print OUTPUT "$line\n";
				}
			}
			close INPUT;
			close OUTPUT;
		}
	}

	print  "#################################################\n";
	print  "#                  By Liu Qing                  #\n";
	print  "# University of Science and Technology of China #\n";
	print  "#################################################\n";
