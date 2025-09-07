
	
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
	
               %xaa_namex = (
                    "ARG"   => "ARG" ,
                    "HIS"   => "HSD" ,
                    "HID"   => "HSD" ,
                    "HIE"   => "HSE" ,
                    "HIP"   => "HSP" ,
                    "HSD"   => "HSD" ,
                    "HSE"   => "HSE" ,
                    "HSP"   => "HSP" ,
                    "LYS"   => "LYS" ,
                    "LYN"   => "LYS" ,
                    "ASP"   => "ASP" ,
                    "ASH"   => "ASP" ,
                    "GLU"   => "GLU" ,
                    "GLH"   => "GLU" ,
                    "SER"   => "SER" ,
                    "THR"   => "THR" ,
                    "ASN"   => "ASN" ,
                    "GLN"   => "GLN" ,
                    "CYS"   => "CYS" ,
                    "CYX"   => "CYS" ,
                    "GLY"   => "GLY" ,
                    "PRO"   => "PRO" ,
                    "ALA"   => "ALA" ,
                    "VAL"   => "VAL" ,
                    "ILE"   => "ILE" ,
                    "LEU"   => "LEU" ,
                    "MET"   => "MET" ,
                    "PHE"   => "PHE" ,
                    "TYR"   => "TYR" ,
                    "TRP"   => "TRP" ,
		);

		%xion_namex = (
			"Cl-" => "CLA" ,
			"Na+" => "SOD" ,
			"K+"  => "POT" ,
			"CA"  => "CAL" ,
			"MG"  => "MG " ,
			"ZN"  => "ZN " ,
		);

               %aa_psf = (
                    "LYN"   => "LSN" ,
                    "ASH"   => "ASPP" ,
                    "GLH"   => "GLUP" ,
		);

	@lig_pep_pdb_list = ();
	@lig_name_list = ();
	for ($lig_i = 0; $lig_i < @lig_list; $lig_i++){
		@lig_name_temp = split /\./, $lig_list[$lig_i];
		push @lig_pep_pdb_list, $lig_name_temp[0];
		push @lig_name_list, $lig_name_temp[0];
	}
	@pep_name_list = ();
	for ($pep_i = 0; $pep_i < @pep_list; $pep_i++){
		@pep_name_temp = split /\./, $pep_list[$pep_i];
		push @lig_pep_pdb_list, $pep_name_temp[0];
		push @pep_name_list, $pep_name_temp[0];
	}


	sub near_int{
		$num1 = shift;
		if ($num1 >= 0){
			$num2 = int($num1);
			$num3 = $num1 - $num2;
			if ($num3 >= 0.5){
				$near_int_num = $num2+1;
			}
			else{
				$near_int_num = $num2;
			}
		}
		else{
			$num2 = int($num1);
			$num3 = $num2 - $num1;
			if ($num3 >= 0.5){
				$near_int_num = $num2-1;
			}
			else{
				$near_int_num = $num2;
			}
		}
		return $near_int_num;
	}


        

	$resi_count = 0;
	$crt_resi_num = -9999;
	
	@NTER_list = ("NTER","ACE","PROP","GLYP","ACED","ACP","ACPD");
	@CTER_list = ("CTER","CT3");

	open OUTPUT0, ">psfgen_prot.sh" or die "can not create!\n";
	print OUTPUT0 "topology toppar/top_all22_prot.rtf
topology toppar/top_all36_carb.rtf
topology toppar/top_all36_lipid.rtf
topology toppar/top_all36_prot.rtf
topology toppar/top_all36_cgenff.rtf
topology toppar/toppar_water_ions_edit.str
pdbalias atom ILE CD1 CD
pdbalias residue HIS HSD\n";
	for ($chain_i = 0; $chain_i < @cid_list ; $chain_i++){

		$crt_resi_num = -9999;
		open INPUT, "aligned_prep_ss_$cid_list[$chain_i].pdb" or die "can not open 4!\n";
		open OUTPUT, ">aligned_forpsf_$cid_list[$chain_i].pdb" or die "can not create!\n";
		@cyx_resi_num_list = ();
		@sg_atom_num_list = ();
		@sul_patch_a = ();
		@sul_patch_b = ();
		$psfgen_lines = "segment PR$cid_list[$chain_i] {
 pdb	aligned_forpsf_$cid_list[$chain_i].pdb\n";
		$psfgen_patches = "";
 		@seg_resi_name_list = ();
		while(chomp($line=<INPUT>)){
			@gezis = split //, $line;
			$atom_mark = undef;
			for ($gezis_i = 0; $gezis_i <= 5; $gezis_i++){
			        $atom_mark .= "$gezis[$gezis_i]";
			}
			if (($atom_mark eq "ATOM  ") ||  ($atom_mark eq "HETATM"))  {
				$resi_name = undef;
				for ($gezis_i = 17; $gezis_i <= 19 ; $gezis_i++){
					$resi_name .= $gezis[$gezis_i];
				}
			
				if (($resi_name eq "ACE") || ($resi_name eq "NME")){
					next;
				}

				$resi_num = undef;
				for ($gezis_i = 22; $gezis_i <= 25 ; $gezis_i++){
					$resi_num .= $gezis[$gezis_i];
				}
				if ($resi_num != $crt_resi_num){
					$crt_resi_num = $resi_num;
					$resi_count++;
					push @seg_resi_name_list , $resi_name;
				}
				$resi_num_clear = undef;
				for ($gezis_i = 22; $gezis_i <= 25 ; $gezis_i++){
					if ($gezis[$gezis_i] ne " "){
						$resi_num_clear .= $gezis[$gezis_i];
					}
				}

				if (($resi_inseg_c==1) && ($resi_name eq "PRO")) {
					$nter_n = 2;
					
				}

				$atom_name = undef;
				for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
					$atom_name .= $gezis[$gezis_i];
				}
				$atom_name_clear = undef;
				for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
					if ($gezis[$gezis_i] ne " "){
						$atom_name_clear .= $gezis[$gezis_i];
					}
				}
				$atom_num = undef;
				for ($gezis_i = 6; $gezis_i <= 10 ; $gezis_i++){
					$atom_num .= $gezis[$gezis_i];
				}
				if (($atom_name_clear eq "SG") && ($resi_name eq "CYX")) {
					push @cyx_resi_num_list, $resi_count;
					push @sg_atom_num_list, $atom_num;
				} 

				$part_A = undef;
				for ($gezis_i = 0; $gezis_i <= 16 ; $gezis_i++){
					$part_A .= $gezis[$gezis_i];
				}
				$part_B = undef;
				for ($gezis_i = 20; $gezis_i <= 21 ; $gezis_i++){
					$part_B .= $gezis[$gezis_i];
				}
				$part_C = undef;
				for ($gezis_i = 26; $gezis_i < @gezis ; $gezis_i++){
					$part_C .= $gezis[$gezis_i];
				}
				printf OUTPUT "$part_A%3s$part_B%4g$part_C\n", $xaa_namex{$resi_name},$resi_count ;
				if (($aa_psf{$resi_name}) && ($atom_name_clear eq "CA"))  {
					$psfgen_patches.="patch $aa_psf{$resi_name} PR$cid_list[$chain_i]:$resi_count\n";
				}


			}
			if ($atom_mark eq "CONECT")  {
				$cnc_a = undef;
				for ($gezis_i = 6; $gezis_i <= 10; $gezis_i++){
					$cnc_a.=$gezis[$gezis_i];
				}
				$cnc_b = undef;
				for ($gezis_i = 11; $gezis_i <= 15; $gezis_i++){
					$cnc_b.=$gezis[$gezis_i];
				}
				for ($num_i = 0; $num_i < @cyx_resi_num_list; $num_i++){
					if ($sg_atom_num_list[$num_i] == $cnc_a){
						push @sul_patch_a , $cyx_resi_num_list[$num_i];
					}
					if ($sg_atom_num_list[$num_i] == $cnc_b){
						push @sul_patch_b , $cyx_resi_num_list[$num_i];
					}
				}
			}
		}
		#@NTER_list = ("NTER","ACE","PROP","GLYP","ACED","ACP","ACPD");
		#@CTER_list = ("CTER","CT3");
		$seg_len = @seg_resi_name_list;
		$nter_n = 0;
		$cter_n = 0;
		if ($seg_len == 2){
			if ($eg_resi_name_list[0] eq "ACE"){
				if ($eg_resi_name_list[1] eq "PRO"){
					$nter_n  = 6;
				}
				else {
					$nter_n  = 4;
				}
			}  
			elsif ($eg_resi_name_list[0] eq "PRO"){
				$nter_n = 2;
			}
			elsif ($eg_resi_name_list[0] eq "GLY"){
				$nter_n = 3;
			}
			else{
				$nter_n = 0;
			}

			if ($eg_resi_name_list[-1] eq "NME"){
				$cter_n = 1
			}
			else {
				$cter_n = 0;
			}
		}
		else {
			if ($eg_resi_name_list[0] eq "ACE"){
				if ($eg_resi_name_list[1] eq "PRO"){
					$nter_n  = 5;
				}
				else {
					$nter_n  = 1;
				}
			}  
			elsif ($eg_resi_name_list[0] eq "PRO"){
				$nter_n = 2;
			}
			elsif ($eg_resi_name_list[0] eq "GLY"){
				$nter_n = 3;
			}
			else{
				$nter_n = 0;
			}

			if ($eg_resi_name_list[-1] eq "NME"){
				$cter_n = 1
			}
			else {
				$cter_n = 0;
			}
		}
		$psfgen_lines .= " first $NTER_list[$nter_n]
 last $CTER_list[$cter_n]
}\n";


		for ($sul_i = 0; $sul_i < @sul_patch_a; $sul_i++){
			$psfgen_patches .= "patch DISU PR$cid_list[$chain_i]:$sul_patch_a[$sul_i] PR$cid_list[$chain_i]:$sul_patch_b[$sul_i]\n";
		}
		close INPUT;
		print OUTPUT "TER\n";
		close OUTPUT;


		print OUTPUT0 "$psfgen_lines";
		print OUTPUT0 "$psfgen_patches";
		print OUTPUT0 "coordpdb aligned_forpsf_$cid_list[$chain_i].pdb PR$cid_list[$chain_i]\n\n";
	}
	print OUTPUT0 "guesscoord\nwritepsf prot_psf.psf\nwritepdb prot_psf.pdb\n";
	close OUTPUT0;

	system("./psfgen psfgen_prot.sh > psfgen_prot.log");


	
	open INPUT, "nonprotein_forbuild.pdb" or die "can not open 4!\n";
	open OUTPUT1, ">memb_forbuild.pdb" or die "can not create!\n";
	open OUTPUT2, ">solv_forbuild.pdb" or die "can not create!\n";
	$memb_end_mark = 0;
	while(chomp($line=<INPUT>)){
		@gezis = split //, $line;
		$atom_mark = undef;
		for ($gezis_i = 0; $gezis_i <= 5; $gezis_i++){
		        $atom_mark .= "$gezis[$gezis_i]";
		}
		if (($atom_mark eq "ATOM  ") ||  ($atom_mark eq "HETATM"))  {
			$resi_name_clear = undef;
			for ($gezis_i = 17; $gezis_i <= 19 ; $gezis_i++){
				if ($gezis[$gezis_i] ne " "){
					$resi_name_clear .= $gezis[$gezis_i];
				}
			}
			$atom_name_clear = undef;
			for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
				if ($gezis[$gezis_i] ne " "){
					$atom_name_clear .= $gezis[$gezis_i];
				}
			}
			if ($resi_name_clear eq "WAT"){
				$memb_end_mark = 1;
				if ($atom_name_clear eq "O"){
					$part_A = undef;
					for ($gezis_i = 0; $gezis_i <= 11 ; $gezis_i++){
						$part_A .= $gezis[$gezis_i];
					}
					$part_B = undef;
					for ($gezis_i = 22; $gezis_i < @gezis ; $gezis_i++){
						$part_B .= $gezis[$gezis_i];
					}
					printf OUTPUT2 "$part_A%4s %4s $part_B\n", " OH2", "TIP3";
				}
				else{
					$part_A = undef;
					for ($gezis_i = 0; $gezis_i <= 16 ; $gezis_i++){
						$part_A .= $gezis[$gezis_i];
					}
					$part_B = undef;
					for ($gezis_i = 22; $gezis_i < @gezis ; $gezis_i++){
						$part_B .= $gezis[$gezis_i];
					}
					printf OUTPUT2 "$part_A%4s $part_B\n",  "TIP3";
					
				}
			}
			elsif ($xion_namex{$resi_name_clear}){
				$part_A = undef;
				for ($gezis_i = 0; $gezis_i <= 11 ; $gezis_i++){
					$part_A .= $gezis[$gezis_i];
				}
				$part_B = undef;
				for ($gezis_i = 22; $gezis_i < @gezis ; $gezis_i++){
					$part_B .= $gezis[$gezis_i];
				}
				printf OUTPUT2 "$part_A %3s %3s  $part_B\n",$xion_namex{$resi_name_clear}, $xion_namex{$resi_name_clear} ;
			}
			#elsif ($resi_name_clear eq "Na+"){
			#	$part_A = undef;
			#	for ($gezis_i = 0; $gezis_i <= 11 ; $gezis_i++){
			#		$part_A .= $gezis[$gezis_i];
			#	}
			#	$part_B = undef;
			#	for ($gezis_i = 22; $gezis_i < @gezis ; $gezis_i++){
			#		$part_B .= $gezis[$gezis_i];
			#	}
			#	printf OUTPUT2 "$part_A %3s %3s  $part_B\n",  "SOD", "SOD";
			#}
			#elsif ($resi_name_clear eq "Cl-"){
			#	$part_A = undef;
			#	for ($gezis_i = 0; $gezis_i <= 11 ; $gezis_i++){
			#		$part_A .= $gezis[$gezis_i];
			#	}
			#	$part_B = undef;
			#	for ($gezis_i = 22; $gezis_i < @gezis ; $gezis_i++){
			#		$part_B .= $gezis[$gezis_i];
			#	}
			#	printf OUTPUT2 "$part_A %3s %3s  $part_B\n",  "CLA", "CLA";
			#}
			elsif ($memb_end_mark == 0){
				print OUTPUT1 "$line\n";
			}
		}
		if ((($atom_mark eq "TER   ") ||  ($atom_mark =~ "^TER.*")) && ($memb_end_mark == 0))  {
			print OUTPUT1 "$line\n";
		}
		if ((($atom_mark eq "TER   ") ||  ($atom_mark =~ "^TER.*")) && ($memb_end_mark == 1))  {
			print OUTPUT2 "$line\n";
		}
	}
	close OUTPUT1;
	close OUTPUT2;
	close INPUT;


	open INPUT, "$m_path/scripts/sys_build/lipid_amber2charmm.txt" or die "can not open 4!\n";
	$lipid_mark = 0;
	while(chomp($line=<INPUT>)){
		if (($line=~"^>.*") && ($lipid_mark==0))  {
			$lipid_mark++;
			$lipid_head = $line;
			next;
		}
		elsif (($line=~"^>.*") && ($lipid_mark==1)) {
			$lipid_mark = 0;
			$lipid_covert{$lipid_head} = $atom_corres;
			$atom_corres = undef;
			$lipid_head = undef;
			redo;
		}
		elsif ($lipid_mark == 1){
			$atom_corres.="$line ";
		}
	}
	close INPUT;
	$lipid_covert{$lipid_head} = $atom_corres;

	open OUTPUT, ">memb_forpsf_0.pdb" or die "can not create!\n";
	open INPUT, "memb_forbuild.pdb" or die "can not open 4!\n";
	@amber_resi_name = ();
	@atom_name_list = ();
	@resi_name_list = ();
	@part_A_list = ();
	@part_B_list = ();
	$lipid_resi_c = 0;
	$mem_file_c = 0;
	$lipid_atom_c = 0;
	while(chomp($line=<INPUT>)){
		@gezis = split //, $line;
		$atom_mark = undef;
		for ($gezis_i = 0; $gezis_i <= 5; $gezis_i++){
		        $atom_mark .= "$gezis[$gezis_i]";
		}
		if (($atom_mark eq "ATOM  ") ||  ($atom_mark eq "HETATM"))  {
			if (($gezis[12] eq "H")  ||  ($gezis[13] eq "H") ) {
				next;
			}
			$resi_name_clear = undef;
			for ($gezis_i = 17; $gezis_i <= 19 ; $gezis_i++){
				if ($gezis[$gezis_i] ne " "){
					$resi_name_clear .= $gezis[$gezis_i];
				}
			}
			push @resi_name_list , $resi_name_clear;

			$amber_resi_match = 0;
			for ($resi_i = 0; $resi_i < @amber_resi_name; $resi_i++){
				if ($amber_resi_name[$resi_i] eq $resi_name_clear){
					$amber_resi_match = 1;
					last;
				}
			}
			if ($amber_resi_match == 0){
				push @amber_resi_name, $resi_name_clear;
			}

			$atom_name_clear = undef;
			for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
				if ($gezis[$gezis_i] ne " "){
					$atom_name_clear .= $gezis[$gezis_i];
				}
			}
			push @atom_name_list , $atom_name_clear;
			$part_A = undef;
			for ($gezis_i = 0; $gezis_i <= 11 ; $gezis_i++){
				$part_A .= $gezis[$gezis_i];
			}
			push @part_A_list, $part_A;
			$part_B = undef;
			for ($gezis_i = 26; $gezis_i < @gezis ; $gezis_i++){
				$part_B .= $gezis[$gezis_i];
			}
			push @part_B_list, $part_B;
		}
		elsif (($atom_mark eq "TER   ") ||  ($atom_mark =~ "^TER.*")) {
			$lipid_name_match = 0;
			foreach $lipid_head (keys %lipid_covert){
				@lipid_head_sp = split /\s+/, $lipid_head;
				$len_a = @lipid_head_sp;
				$len_b = @amber_resi_name;
				if ($len_a -1 == $len_b ){
					#print "@lipid_head_sp\n@amber_resi_name\n";
					$name_match = 0;
					for ($name_i = 1; $name_i < @lipid_head_sp; $name_i++){
						#for ($name_i2 = 0; $name_i2 < @amber_resi_name; $name_i2++){
						#	if ($lipid_head_sp[$name_i] eq $amber_resi_name[$name_i2]){
						#		$name_match++;
						#		last;
						#	}
						#}
						if ($lipid_head_sp[$name_i] eq $amber_resi_name[$name_i-1]){
							$name_match++;
						}
					}
					if ($name_match == $len_b){
						$lipid_resi_c++;
						if ($lipid_resi_c>400){
							$lipid_resi_c = 1;
							$lipid_atom_c = 0;
							close OUTPUT;
							$mem_file_c++;
							open OUTPUT, ">memb_forpsf_$mem_file_c.pdb" or die "can not create!\n";
						}
						$lipid_name_match = 1;
						@covert_list = split /\s+/, $lipid_covert{$lipid_head};
						%lipid_spi = ();
						for ($name_i = 0; $name_i < @covert_list; $name_i+=3){
							$amber_pattern = $covert_list[$name_i]."-".$covert_list[$name_i+2];
							$lipid_spi{$amber_pattern} = $covert_list[$name_i+1];
						}
						@lipid_name_temp1 = split //, $lipid_head_sp[0];
						$lipid_name_2=undef;
						for ($name_i = 1; $name_i < @lipid_name_temp1; $name_i++){
							$lipid_name_2.=$lipid_name_temp1[$name_i];
						}
						for ($line_i = 0; $line_i < @part_A_list; $line_i++){
							$lipid_atom_c++;
							$amber_pattern = $atom_name_list[$line_i]."-".$resi_name_list[$line_i];
							$charmm_atom_name = $lipid_spi{$amber_pattern};
							@charmm_atom_name_sp = split //, $charmm_atom_name;
							$atom_name_gezi = @charmm_atom_name_sp;
							if ($atom_name_gezi < 4){
								printf OUTPUT "ATOM  %5g  %-3s %4s %4s$part_B_list[$line_i]\n",$lipid_atom_c, $charmm_atom_name, $lipid_name_2, $lipid_resi_c;
							}
							else{
								printf OUTPUT "ATOM  %5g %4s %4s %4s$part_B_list[$line_i]\n", $lipid_atom_c, $charmm_atom_name, $lipid_name_2, $lipid_resi_c;
							}
						}
						print OUTPUT "TER\n";
					}
				}
				if ($lipid_name_match == 1){
					last;
				}
			}
			if ($lipid_name_match == 1){
				@amber_resi_name = ();
				@atom_name_list = ();
				@resi_name_list = ();
				@part_A_list = ();
				@part_B_list = ();
			}
			else{
				die "lipid name not match!\n";
			}
			
		}
	
	}
	close INPUT;
	close OUTPUT;

	open OUTPUT0, ">psfgen_memb.sh" or die "can not create!\n";
	print OUTPUT0 "topology toppar/top_all22_prot.rtf
topology toppar/top_all36_carb.rtf
topology toppar/top_all36_lipid.rtf
topology toppar/top_all36_prot.rtf
topology toppar/top_all36_cgenff.rtf
topology toppar/toppar_water_ions_edit.str\n";
	
	for ($mem_i = 0; $mem_i <= $mem_file_c; $mem_i++){
		print OUTPUT0 "
segment M$mem_i {
 pdb    memb_forpsf_$mem_i.pdb
}
coordpdb memb_forpsf_$mem_i.pdb M$mem_i\n"
	}

	print OUTPUT0 "
regenerate angles dihedrals
guesscoord

writepdb memb_psf.pdb
writepsf memb_psf.psf

\n";

	close OUTPUT0;
	system("./psfgen psfgen_memb.sh > psfgen_memb.log");


	open OUTPUT, ">solv_forpsf_0.pdb" or die "can not create!\n";
	open INPUT, "solv_forbuild.pdb" or die "can not open 4!\n";
	@part_A_list = ();
	@part_B_list = ();
	$solv_resi_c = 1;
	$solv_file_c = 0;
	$solv_atom_c = 1;
	while(chomp($line=<INPUT>)){
		@gezis = split //, $line;
		$atom_mark = undef;
		for ($gezis_i = 0; $gezis_i <= 5; $gezis_i++){
		        $atom_mark .= "$gezis[$gezis_i]";
		}
		if (($atom_mark eq "ATOM  ") ||  ($atom_mark eq "HETATM"))  {
			$resi_num = undef;
			for ($gezis_i = 22; $gezis_i <= 25 ; $gezis_i++){
				$resi_num .= $gezis[$gezis_i];
			}
			$atom_num = undef;
			for ($gezis_i = 6; $gezis_i <= 10 ; $gezis_i++){
				$atom_num .= $gezis[$gezis_i];
			}
			$part_A = undef;
			for ($gezis_i = 11; $gezis_i <= 21 ; $gezis_i++){
				$part_A .= $gezis[$gezis_i];
			}
			push @part_A_list, $part_A;
			$part_B = undef;
			for ($gezis_i = 26; $gezis_i < @gezis ; $gezis_i++){
				$part_B .= $gezis[$gezis_i];
			}
			push @part_B_list, $part_B;
		}
		elsif (($atom_mark eq "TER   ") ||  ($atom_mark =~ "^TER.*")) {
			$solv_resi_c++;
			if ($solv_resi_c > 5000){
				$solv_resi_c = 1;
				$solv_atom_c = 0;
				$solv_file_c++;
				close OUTPUT;
				open OUTPUT, ">solv_forpsf_$solv_file_c.pdb" or die "can not create!\n";
			}
			for ($line_i = 0; $line_i < @part_A_list; $line_i++){
				$solv_atom_c++;
				printf OUTPUT "ATOM  %5g$part_A_list[$line_i]%4g$part_B_list[$line_i]\n", $solv_atom_c, $solv_resi_c;
			}
			print OUTPUT "TER\n";
			@part_A_list = ();
			@part_B_list = ();
		}
	}
	close OUTPUT;
	close INPUT;




	open OUTPUT0, ">psfgen_solv.sh" or die "can not create!\n";
	print OUTPUT0 "topology toppar/top_all22_prot.rtf
topology toppar/top_all36_carb.rtf
topology toppar/top_all36_lipid.rtf
topology toppar/top_all36_prot.rtf
topology toppar/top_all36_cgenff.rtf
topology toppar/toppar_water_ions_edit.str\n";
	for ($solv_i = 0; $solv_i <= $solv_file_c; $solv_i++){
		print OUTPUT0 "
segment S$solv_i {
 pdb    solv_forpsf_$solv_i.pdb
}
coordpdb solv_forpsf_$solv_i.pdb S$solv_i\n"
	}

	print OUTPUT0 "
regenerate angles dihedrals
guesscoord

writepdb solv_psf.pdb
writepsf solv_psf.psf

\n";

	close OUTPUT0;
	system("./psfgen psfgen_solv.sh > psfgen_solv.log");




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

	open OUTPUT0, ">psfgen_lig.sh" or die "can not create!\n";
	print OUTPUT0 "topology toppar/top_all22_prot.rtf
topology toppar/top_all36_carb.rtf
topology toppar/top_all36_lipid.rtf
topology toppar/top_all36_prot.rtf
topology toppar/top_all36_cgenff.rtf
topology toppar/toppar_water_ions_edit.str\n";
	
	for ($lig_i = 0; $lig_i < @lig_str_list; $lig_i++){
		print OUTPUT0 "topology toppar/lig_manual/$lig_str_list[$lig_i].str\n";
	}






	for ($lig_i = 0; $lig_i < @lig_name_list; $lig_i++){
		open INPUT, "aligned_ss_$lig_name_list[$lig_i].pdb" or die "can not open!\n";
		open OUTPUT, ">aligned_ss_forpsf_$lig_name_list[$lig_i].pdb" or die "can not open!\n";
		while(chomp($line=<INPUT>)){
			@gezis = split //, $line;
			$atom_mark = undef;
			for ($gezis_i = 0; $gezis_i <= 5; $gezis_i++){
			        $atom_mark .= "$gezis[$gezis_i]";
			}
			if (($atom_mark eq "ATOM  ") ||  ($atom_mark eq "HETATM"))  {
				$resi_name_clear = undef;
				for ($gezis_i = 17; $gezis_i <= 19 ; $gezis_i++){
					if ($gezis[$gezis_i] ne " "){
						$resi_name_clear .= $gezis[$gezis_i];
					}
				}
				if ($xion_namex{$resi_name_clear}){
					$part_A = undef;
					for ($gezis_i = 0; $gezis_i <= 11 ; $gezis_i++){
						$part_A .= $gezis[$gezis_i];
					}
					$part_B = undef;
					for ($gezis_i = 22; $gezis_i < @gezis ; $gezis_i++){
						$part_B .= $gezis[$gezis_i];
					}
					printf OUTPUT "$part_A %3s %3s  $part_B\n",$xion_namex{$resi_name_clear}, $xion_namex{$resi_name_clear} ;
				}
				else{
					print OUTPUT "$line\n";
				}
			}
			else{
				print OUTPUT "$line\n";
			}
		}
		close INPUT;
		close OUTPUT;
		print OUTPUT0 "segment LI$lig_i {
 pdb    aligned_ss_forpsf_$lig_name_list[$lig_i].pdb
}
coordpdb aligned_ss_forpsf_$lig_name_list[$lig_i].pdb LI$lig_i
 \n";
	
	}


	for ($pep_i = 0; $pep_i < @pep_name_list; $pep_i++){
		open INPUT, "aligned_ss_$pep_name_list[$pep_i].pdb" or die "can not open!\n";
		open OUTPUT, ">aligned_ss_forpsf_$pep_name_list[$pep_i].pdb" or die "can not open!\n";
		$crt_resi_num = -9999;
		@cyx_resi_num_list = ();
		@sg_atom_num_list = ();
		@sul_patch_a = ();
		@sul_patch_b = ();
		$psfgen_lines = "segment PE$pep_i {
 pdb	aligned_ss_forpsf_$pep_name_list[$pep_i].pdb\n";
		$psfgen_patches = "";
 		@seg_resi_name_list = ();
		while(chomp($line=<INPUT>)){
			@gezis = split //, $line;
			$atom_mark = undef;
			for ($gezis_i = 0; $gezis_i <= 5; $gezis_i++){
			        $atom_mark .= "$gezis[$gezis_i]";
			}
			if (($atom_mark eq "ATOM  ") ||  ($atom_mark eq "HETATM"))  {
				$resi_name = undef;
				for ($gezis_i = 17; $gezis_i <= 19 ; $gezis_i++){
					$resi_name .= $gezis[$gezis_i];
				}
			
				if (($resi_name eq "ACE") || ($resi_name eq "NME")){
					next;
				}

				$resi_num = undef;
				for ($gezis_i = 22; $gezis_i <= 25 ; $gezis_i++){
					$resi_num .= $gezis[$gezis_i];
				}
				if ($resi_num != $crt_resi_num){
					$crt_resi_num = $resi_num;
					$resi_count++;
					push @seg_resi_name_list , $resi_name;
				}
				$resi_num_clear = undef;
				for ($gezis_i = 22; $gezis_i <= 25 ; $gezis_i++){
					if ($gezis[$gezis_i] ne " "){
						$resi_num_clear .= $gezis[$gezis_i];
					}
				}

				if (($resi_inseg_c==1) && ($resi_name eq "PRO")) {
					$nter_n = 2;
					
				}

				$atom_name = undef;
				for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
					$atom_name .= $gezis[$gezis_i];
				}
				$atom_name_clear = undef;
				for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
					if ($gezis[$gezis_i] ne " "){
						$atom_name_clear .= $gezis[$gezis_i];
					}
				}
				$atom_num = undef;
				for ($gezis_i = 6; $gezis_i <= 10 ; $gezis_i++){
					$atom_num .= $gezis[$gezis_i];
				}
				if (($atom_name_clear eq "SG") && ($resi_name eq "CYX")) {
					push @cyx_resi_num_list, $resi_count;
					push @sg_atom_num_list, $atom_num;
				} 

				$part_A = undef;
				for ($gezis_i = 0; $gezis_i <= 16 ; $gezis_i++){
					$part_A .= $gezis[$gezis_i];
				}
				$part_B = undef;
				for ($gezis_i = 20; $gezis_i <= 21 ; $gezis_i++){
					$part_B .= $gezis[$gezis_i];
				}
				$part_C = undef;
				for ($gezis_i = 26; $gezis_i < @gezis ; $gezis_i++){
					$part_C .= $gezis[$gezis_i];
				}
				printf OUTPUT "$part_A%3s$part_B%4g$part_C\n", $xaa_namex{$resi_name},$resi_count ;
				if (($aa_psf{$resi_name}) && ($atom_name_clear eq "CA"))  {
					$psfgen_patches.="patch $aa_psf{$resi_name} PE$pep_name_list[$pep_i]:$resi_count\n";
				}


			}
			if ($atom_mark eq "CONECT")  {
				$cnc_a = undef;
				for ($gezis_i = 6; $gezis_i <= 10; $gezis_i++){
					$cnc_a.=$gezis[$gezis_i];
				}
				$cnc_b = undef;
				for ($gezis_i = 11; $gezis_i <= 15; $gezis_i++){
					$cnc_b.=$gezis[$gezis_i];
				}
				for ($num_i = 0; $num_i < @cyx_resi_num_list; $num_i++){
					if ($sg_atom_num_list[$num_i] == $cnc_a){
						push @sul_patch_a , $cyx_resi_num_list[$num_i];
					}
					if ($sg_atom_num_list[$num_i] == $cnc_b){
						push @sul_patch_b , $cyx_resi_num_list[$num_i];
					}
				}
			}
		}
		#@NTER_list = ("NTER","ACE","PROP","GLYP","ACED","ACP","ACPD");
		#@CTER_list = ("CTER","CT3");
		$seg_len = @seg_resi_name_list;
		$nter_n = 0;
		$cter_n = 0;
		if ($seg_len == 2){
			if ($eg_resi_name_list[0] eq "ACE"){
				if ($eg_resi_name_list[1] eq "PRO"){
					$nter_n  = 6;
				}
				else {
					$nter_n  = 4;
				}
			}  
			elsif ($eg_resi_name_list[0] eq "PRO"){
				$nter_n = 2;
			}
			elsif ($eg_resi_name_list[0] eq "GLY"){
				$nter_n = 3;
			}
			else{
				$nter_n = 0;
			}

			if ($eg_resi_name_list[-1] eq "NME"){
				$cter_n = 1
			}
			else {
				$cter_n = 0;
			}
		}
		else {
			if ($eg_resi_name_list[0] eq "ACE"){
				if ($eg_resi_name_list[1] eq "PRO"){
					$nter_n  = 5;
				}
				else {
					$nter_n  = 1;
				}
			}  
			elsif ($eg_resi_name_list[0] eq "PRO"){
				$nter_n = 2;
			}
			elsif ($eg_resi_name_list[0] eq "GLY"){
				$nter_n = 3;
			}
			else{
				$nter_n = 0;
			}

			if ($eg_resi_name_list[-1] eq "NME"){
				$cter_n = 1
			}
			else {
				$cter_n = 0;
			}
		}
		$psfgen_lines .=  " first $NTER_list[$nter_n]
 last $CTER_list[$cter_n]
}\n";


		for ($sul_i = 0; $sul_i < @sul_patch_a; $sul_i++){
			$psfgen_patches .= "patch DISU PE$pep_name_list[$pep_i]:$sul_patch_a[$sul_i] PE$pep_name_list[$pep_i]:$sul_patch_b[$sul_i]\n";
		}
		close INPUT;
		print OUTPUT "TER\n";
		close OUTPUT;


		print OUTPUT0 "$psfgen_lines";
		print OUTPUT0 "$psfgen_patches";
		print OUTPUT0 "coordpdb aligned_ss_forpsf_$pep_name_list[$pep_i].pdb PE$pep_name_list[$pep_i]\n\n";
	}



	
	print OUTPUT0 "regenerate angles dihedrals
guesscoord

writepdb lig_psf.pdb
writepsf lig_psf.psf
 ";
	close OUTPUT0;
	system("./psfgen psfgen_lig.sh > psfgen_lig.log");

	
	open OUTPUT0, ">psfgen_complex.sh" or die "can not create!\n";
	print OUTPUT0 "resetpsf
readpsf prot_psf.psf
coordpdb prot_psf.pdb\n";
	
	$lig_file_num = @lig_pep_pdb_list;
	if ($lig_file_num){
	print OUTPUT0 "
readpsf lig_psf.psf
coordpdb lig_psf.pdb\n"

	}
	
	print OUTPUT0 "
readpsf memb_psf.psf
coordpdb memb_psf.pdb
readpsf solv_psf.psf
coordpdb solv_psf.pdb
regenerate angles dihedrals
guesscoord

writepsf complex_start.psf
writepdb complex_start.pdb

	";
	close OUTPUT0;
	system("./psfgen psfgen_complex.sh > psfgen_complex.log");
