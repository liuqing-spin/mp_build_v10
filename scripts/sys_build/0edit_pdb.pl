#system("mv $ARGV[0] origin_$ARGV[0]");
	open INPUT, "$ARGV[0]" or die "can not open!\n";
	@cyx_a_list = ();
	@cyx_b_list = ();
	@cyx_a_chain_list = ();
	@cyx_b_chain_list = ();
	@remark465 = ();

	@resi_num_list = ();
	@atom_num_list = ();
	@atom_name_list = ();
	@resi_name_list = ();
	@chain_id_list = ();
	@con_a_list = ();
	@con_b_list = ();
	while(chomp($line=<INPUT>)){
		@gezis = split //, $line;
		$atom_mark = undef;
		for ($gezis_i = 0; $gezis_i <= 5 ; $gezis_i++){
			$atom_mark .= $gezis[$gezis_i];
		}
		if (($atom_mark eq "ATOM  ") || ($atom_mark eq "HETATM")){
			$resi_num = undef;
			for ($gezis_i = 22; $gezis_i <= 25 ; $gezis_i++){
				$resi_num .= $gezis[$gezis_i];
			}
			push @resi_num_list, $resi_num;
			$atom_num = undef;
			for ($gezis_i = 6; $gezis_i <= 10 ; $gezis_i++){
				$atom_num .= $gezis[$gezis_i];
			}
			push @atom_num_list, $atom_num;
			$atom_name = undef;
			for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
				$atom_name .= $gezis[$gezis_i];
			}
			push @atom_name_list, $atom_name;
			$resi_name = undef;
			for ($gezis_i = 17; $gezis_i <= 19 ; $gezis_i++){
				$resi_name .= $gezis[$gezis_i];
			}
			push @resi_name_list, $resi_name;
                        
			push @chain_id_list, $gezis[21];
		
		}

		if ($atom_mark eq "CONECT"){
			$con_a = undef;
			for ($gezis_i = 6; $gezis_i <= 10 ; $gezis_i++){
				$con_a .= $gezis[$gezis_i];
			}
			push @con_a_list, $con_a;
			$con_b = undef;
			for ($gezis_i = 11; $gezis_i <= 15 ; $gezis_i++){
				$con_b .= $gezis[$gezis_i];
			}
			push @con_b_list, $con_b;
			
		}

		if ($atom_mark eq "SSBOND"){
			$cyx_a = undef;
			for ($gezis_i = 17; $gezis_i <= 20 ; $gezis_i++){
				$cyx_a .= $gezis[$gezis_i];
			}
			push @cyx_a_list, $cyx_a;
			$cyx_b = undef;
			for ($gezis_i = 31; $gezis_i <= 34 ; $gezis_i++){
				$cyx_b .= $gezis[$gezis_i];
			}
			push @cyx_b_list, $cyx_b;
			push @cyx_a_chain_list, $gezis[15];
			push @cyx_b_chain_list, $gezis[29];
		}

		@items = split /\s+/, $line;
		if ($atom_mark eq"HEADER"){
			push @remark465, $line;
		}
		if (($atom_mark eq "REMARK") && ($items[1] == 465)){
			push @remark465, $line;
		}
	}
	close INPUT;

	for ($con_i = 0; $con_i < @con_a_list; $con_i++){
		$con_a_mark = 0;
		$con_b_mark = 0;
		for ($atom_i = 0; $atom_i < @atom_num_list; $atom_i++){
			if (($atom_num_list[$atom_i] == $con_a_list[$con_i]) && ($atom_name_list[$atom_i] eq " SG ") && (($resi_name_list[$atom_i] eq "CYX") || ($resi_name_list[$atom_i] eq "CYS"))) {
				$con_a_mark = 1;
				$resi_num_a = $resi_num_list[$atom_i];
				$chain_id_a = $chain_id_list[$atom_i];
			}
			if (($atom_num_list[$atom_i] == $con_b_list[$con_i]) && ($atom_name_list[$atom_i] eq " SG ") && (($resi_name_list[$atom_i] eq "CYX") || ($resi_name_list[$atom_i] eq "CYS"))) {
				$con_b_mark = 1;
				$resi_num_b = $resi_num_list[$atom_i];
				$chain_id_b = $chain_id_list[$atom_i];
			}
		}
		if (($con_a_mark == 1) && ($con_b_mark == 1)) {
			$exist_match = 0;
			for ($cyx_i = 0; $cyx_i < @cyx_a_list; $cyx_i++){
				if (($cyx_a_list[$cyx_i] == $resi_num_a) && ($cyx_b_list[$cyx_i] == $resi_num_b) && ($cyx_a_chain_list[$cyx_i] eq  $chain_id_a) && ($cyx_b_chain_list[$cyx_i] eq  $chain_id_b)){
					$exist_match = 1;
				}
			}
			if ($exist_match == 0){
				push @cyx_a_list, $resi_num_a;
				push @cyx_b_list, $resi_num_b;
				push @cyx_a_chain_list, $chain_id_a;
				push @cyx_b_chain_list, $chain_id_b;
			}
			
		}
	}


	print "@cyx_a_list\n@cyx_b_list\n@cyx_a_chain_list\n@cyx_b_chain_list\n";

	open INPUT, "$ARGV[0]" or die "can not open!\n";
	$crt_resi_num = -9999999999;
	$crt_resi_name = "XXXXX";
	$atom_info_mark = 0;
	@origin_lines = ();
	while(chomp($line=<INPUT>)){
		@gezis = split //, $line;
		$atom_mark = undef;
		for ($gezis_i = 0; $gezis_i <= 5 ; $gezis_i++){
			$atom_mark .= $gezis[$gezis_i];
		}
		$resi_num = undef;
		for ($gezis_i = 22; $gezis_i <= 25 ; $gezis_i++){
			$resi_num .= $gezis[$gezis_i];
		}
		$atom_num = undef;
		for ($gezis_i = 6; $gezis_i <= 10 ; $gezis_i++){
			$atom_num .= $gezis[$gezis_i];
		}
		$atom_name = undef;
		for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
			$atom_name .= $gezis[$gezis_i];
		}
		$resi_name = undef;
		for ($gezis_i = 17; $gezis_i <= 19 ; $gezis_i++){
			$resi_name .= $gezis[$gezis_i];
		}
		if (($atom_mark eq "ATOM  ") || ($atom_mark eq "HETATM")){
			$atom_info_mark = 1;
			if ($gezis[16] ne " "){
				if ($gezis[16] eq "A"){
					$part_A = undef;
					for ($gezis_i = 0; $gezis_i <= 15  ; $gezis_i++){
						$part_A .= $gezis[$gezis_i];
					}
					$part_B = undef;
					for ($gezis_i = 17; $gezis_i < @gezis ; $gezis_i++){
						$part_B .= $gezis[$gezis_i];
					}
					$output_line = $part_A . " " . $part_B;
					push @origin_lines , $output_line;
					
				}
			}
			else {
				push @origin_lines , $line;
			}
		}
		elsif ((($atom_mark eq "TER   ") || ($atom_mark eq "TER") || ($line =~ "^TER .*")) && ($atom_info_mark == 1))  {
			$atom_info_mark = 0;
			push @origin_lines , $line;
		}
	}
	close INPUT;


	open OUTPUT, ">./edit_$ARGV[0]" or die "can not create!\n";
	$crt_resi_num = -9999999999;
	$crt_resi_name = "XXXXX";
	$atom_info_mark = 0;
	$resi_num_c = 0;
	for ($line_i = 0; $line_i < @origin_lines; $line_i++){
	
		@gezis = split //, $origin_lines[$line_i];
		$atom_mark = undef;
		for ($gezis_i = 0; $gezis_i <= 5 ; $gezis_i++){
			$atom_mark .= $gezis[$gezis_i];
		}
		$resi_num = undef;
		for ($gezis_i = 22; $gezis_i <= 25 ; $gezis_i++){
			$resi_num .= $gezis[$gezis_i];
		}
		$atom_num = undef;
		for ($gezis_i = 6; $gezis_i <= 10 ; $gezis_i++){
			$atom_num .= $gezis[$gezis_i];
		}
		$atom_name = undef;
		for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
			$atom_name .= $gezis[$gezis_i];
		}
		$resi_name = undef;
		for ($gezis_i = 17; $gezis_i <= 19 ; $gezis_i++){
			$resi_name .= $gezis[$gezis_i];
		}
		if (($atom_mark eq "ATOM  ") || ($atom_mark eq "HETATM")){
			$atom_info_mark = 1;
			if (($resi_num != $crt_resi_num) || ($resi_name ne $crt_resi_name)){
				$crt_resi_num = $resi_num;
				$crt_resi_name = $resi_name;
				$resi_num_c++;
			}
			$part_A = undef;
			for ($gezis_i = 6; $gezis_i <= 21  ; $gezis_i++){
				$part_A .= $gezis[$gezis_i];
			}
			$part_B = undef;
			for ($gezis_i = 30; $gezis_i < @gezis ; $gezis_i++){
				$part_B .= $gezis[$gezis_i];
			}
			if ($resi_name eq "CYS"){
				for ($cyx_i = 0; $cyx_i < @cyx_a_list; $cyx_i++){
					if (($cyx_a_list[$cyx_i] ==  $resi_num) && ($cyx_a_chain_list[$cyx_i] eq $gezis[21])){
						$cyx_a_list[$cyx_i] = $resi_num_c;
					}
					if (($cyx_b_list[$cyx_i] ==  $resi_num) && ($cyx_b_chain_list[$cyx_i] eq $gezis[21])){
						$cyx_b_list[$cyx_i] = $resi_num_c;
					}
				}
				push @part_A_list, $part_A;
				push @part_B_list, $part_B;
				push @resi_num_c_list, $resi_num_c;
			}
			else{
				push @part_A_list, $part_A;
				push @part_B_list, $part_B;
				push @resi_num_c_list, $resi_num_c;
			}
		}
		elsif ((($atom_mark eq "TER   ") || ($atom_mark eq "TER") || ($line =~ "^TER .*")) && ($atom_info_mark == 1))  {
			$atom_info_mark = 0;
			$resi_num_c = 0;
			push @part_A_list, "TER";
			push @part_B_list, "  ";
			push @resi_num_c_list, " ";
		}


	}
	for ($line_i = 0; $line_i < @remark465; $line_i++){
		print OUTPUT "$remark465[$line_i]\n";
	}
	for ($cyx_i = 0; $cyx_i < @cyx_a_list; $cyx_i++){
		printf OUTPUT "SSBOND XXX CYS %1s %4g    CYS %1s %4g\n", $cyx_a_chain_list[$cyx_i], $cyx_a_list[$cyx_i], $cyx_b_chain_list[$cyx_i], $cyx_b_list[$cyx_i];
	}

	for ($line_i = 0; $line_i < @part_A_list; $line_i++){
		if ($part_A_list[$line_i] eq "TER"){
			print OUTPUT "TER\n";
			
		}
		else{
			printf OUTPUT "ATOM  $part_A_list[$line_i]%4g    $part_B_list[$line_i]\n", $resi_num_c_list[$line_i];
		}
	}
	close OUTPUT;




               %xaa_namex = (
                    "ARG"   => "ARG" ,
                    "HIS"   => "HIS" ,
                    "HID"   => "HIS" ,
                    "HIE"   => "HIS" ,
                    "HIP"   => "HIS" ,
                    "HSD"   => "HIS" ,
                    "HSE"   => "HIS" ,
                    "HSP"   => "HIS" ,
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


	system("mv edit_$ARGV[0]  edit_$ARGV[0]_bak ");
	open INPUT, "./edit_$ARGV[0]_bak" or die "can not create!\n";
	open OUTPUT, ">./edit_$ARGV[0]" or die "can not create!\n";
	while(chomp($line=<INPUT>)){
		@gezis = split //, $line;
		$atom_mark = undef;
		for ($gezis_i = 0; $gezis_i <= 5; $gezis_i++){
		        $atom_mark .= "$gezis[$gezis_i]";
		}
		if ($atom_mark eq "ATOM  ")  {
			$resi_name = undef;
			for ($gezis_i = 17; $gezis_i <= 19 ; $gezis_i++){
				$resi_name .= $gezis[$gezis_i];
			}
			$part_A = undef;
			for ($gezis_i = 0; $gezis_i <= 16 ; $gezis_i++){
				$part_A .= $gezis[$gezis_i];
			}
			$part_B = undef;
			for ($gezis_i = 20; $gezis_i < @gezis ; $gezis_i++){
				$part_B .= $gezis[$gezis_i];
			}
			$resi_name_match = 0;
			foreach $key (keys %xaa_namex){
				if ($key eq $resi_name){
					$resi_name_match = 1;
				}
			}
			if ($resi_name_match == 1){
				printf OUTPUT "$part_A%3s$part_B\n", $xaa_namex{$resi_name};
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
