	@resi_pka_list = ("ASP","GLU","HIS","CYS","TYR","ARG","LYS");

	if ($ARGV[1] eq "0"){
		@resi_name_list = ();
		@resi_num_list = ();
		@chain_id_list = ();
		@pka_list = ();

		@hbond_charge_list = ();
		@hbond_resi_list = ();
		@hbond_num_list = ();
		@hbond_chain_list = ();

		@colb_charge_list = ();
		@colb_resi_list = ();
		@colb_num_list = ();
		@colb_chain_list = ();
		open INPUT, "$ARGV[0]_prep.pka" or die "can not open!\n";
		$pka_data_mark = 0;
		while(chomp($line=<INPUT>)){
			@gezis = split //, $line;
			if ($line=~"^ RESIDUE    pKa    BURIED     REGULAR      RE        HYDROGEN BON.*"){
				$pka_data_mark++;
				print "$line\n";
				next;
			}
			if (($line=~"^---------.*") && ($pka_data_mark==1)){
				$pka_data_mark++;
				print "$line\n";
				next;
			}
			if (($line=~"^---------.*") && ($pka_data_mark==2)){
				$pka_data_mark=0;
				print "$line\n";
				last;
			}
			$resi_name = undef;
			for ($gezis_i = 0; $gezis_i<=2; $gezis_i++){
				$resi_name.= $gezis[$gezis_i];
			}
			$resi_mark = 0;
			for ($resi_i = 0; $resi_i < @resi_pka_list; $resi_i++){
				if ($resi_pka_list[$resi_i] eq $resi_name){
					$resi_mark = 1;
					last;
				}
			}
			if (($resi_mark == 1) && ($pka_data_mark == 2)){
				$resi_num = undef;
				for ($gezis_i = 3; $gezis_i<=6; $gezis_i++){
					$resi_num.= $gezis[$gezis_i];
				}
				$chain_id = $gezis[8];
				$pka = undef;
				for ($gezis_i = 11; $gezis_i<=15; $gezis_i++){
					$pka.= $gezis[$gezis_i];
				}

				$hbond_charge = undef;
				for ($gezis_i = 52; $gezis_i<=56; $gezis_i++){
					$hbond_charge.= $gezis[$gezis_i];
				}
				$hbond_resi = undef;
				for ($gezis_i = 58; $gezis_i<=60; $gezis_i++){
					$hbond_resi.= $gezis[$gezis_i];
				}
				$hbond_num = undef;
				for ($gezis_i = 61; $gezis_i<=64; $gezis_i++){
					$hbond_num.= $gezis[$gezis_i];
				}
				$hbond_chain = $gezis[66];

				$colb_charge = undef;
				for ($gezis_i = 88; $gezis_i<=92; $gezis_i++){
					$colb_charge.= $gezis[$gezis_i];
				}
				$colb_resi = undef;
				for ($gezis_i = 94; $gezis_i<=96; $gezis_i++){
					$colb_resi.= $gezis[$gezis_i];
				}
				$colb_num = undef;
				for ($gezis_i = 97; $gezis_i<=100; $gezis_i++){
					$colb_num.= $gezis[$gezis_i];
				}
				$colb_chain = $gezis[102];

				push @resi_name_list, $resi_name;
				push @resi_num_list, $resi_num;
				push @chain_id_list, $chain_id;
				push @pka_list, $pka;

				push @hbond_charge_list, $hbond_charge;
				push @hbond_resi_list, $hbond_resi;
				push @hbond_num_list, $hbond_num;
				push @hbond_chain_list, $hbond_chain;

				push @colb_charge_list, $colb_charge;
				push @colb_resi_list, $colb_resi;
				push @colb_num_list, $colb_num;
				push @colb_chain_list, $colb_chain;
			}
		}
		close INPUT;
		#print "@resi_name_list\n";
		#print "@chain_id_list\n";
		#print "@hbond_chain_list\n";
		#print "@colb_chain_list\n";
		#print "@pka_list\n";


		open INPUT, "$ARGV[0]_prep.pdb" or die "can not open!\n";
		@list_resi_name = ();
		@list_atom_name = ();
		@list_resi_num = ();
		@list_chain_ID = ();
		@pos_x_list = ();
		@pos_y_list = ();
		@pos_z_list = ();
		while(chomp($line=<INPUT>)){
			@gezis = split //, $line;
			$resi_name = undef;
			for ($gezis_i = 17; $gezis_i<=19; $gezis_i++){
				$resi_name.= $gezis[$gezis_i];
			}
			$atom_name = undef;
			for ($gezis_i = 12; $gezis_i<=15; $gezis_i++){
				$atom_name.= $gezis[$gezis_i];
			}
			$atom_name_clear = undef;
			for ($gezis_i = 12; $gezis_i<=15; $gezis_i++){
				if ($gezis[$gezis_i] ne " "){
					$atom_name_clear.= $gezis[$gezis_i];
				}
			}
			$resi_num = undef;
			for ($gezis_i = 22; $gezis_i<=25; $gezis_i++){
				$resi_num.= $gezis[$gezis_i];
			}
			$chain_ID = $gezis[21];
			$pos_x = undef;
			for ($gezis_i = 30; $gezis_i <= 37 ; $gezis_i++){
				$pos_x .= $gezis[$gezis_i];
			}

			$pos_y = undef;
			for ($gezis_i = 38; $gezis_i <= 45 ; $gezis_i++){
				$pos_y .= $gezis[$gezis_i];
			}

			$pos_z = undef;
			for ($gezis_i = 46; $gezis_i <= 53 ; $gezis_i++){
				$pos_z .= $gezis[$gezis_i];
			}

			push @pos_x_list, $pos_x;
			push @pos_y_list, $pos_y;
			push @pos_z_list, $pos_z;
			push @list_resi_name, $resi_name;
			push @list_atom_name, $atom_name_clear;
			push @list_resi_num, $resi_num;
			push @list_chain_ID, $chain_ID;
        	}
		close INPUT;
		#print "@pos_x_list\n";

		#print "@resi_name_list\n";
		#print "@colb_charge_list\n";
		$output_file = "$ARGV[0]"."_hstate_his.txt";
		open OUTPUT, ">$output_file" or die "can not create!\n";
		@hstate_resi_list = ();
		@hstate_state_list = ();
		@hstate_dist_list = ();
		@hstate_num_list = ();
		@hstate_chain_list = ();
		@hstate_pka_list = ();
		@hstate_hbond_mark_list = ();
		#$last_resi_pattern = undef;
		for ($resi_i = 0; $resi_i < @resi_name_list; $resi_i++){
			if ($resi_name_list[$resi_i] eq "HIS"){
				#print "$colb_charge_list[$resi_i]\n";
				#print "mark!\n";
				if ($pka_list[$resi_i] ne "     " ){
					$resi_pka_2 = $pka_list[$resi_i];
				}
				$hbond_mark = 0;
				if ($hbond_resi_list[$resi_i] ne "XXX" )  {
					$hbond_mark = 1;
					@hbond_surpos_list = ();
					for ($atom_i = 0; $atom_i < @list_atom_name; $atom_i++){
						if (($list_atom_name[$atom_i] eq "ND1") && ($list_resi_name[$atom_i] eq "HIS")  && ($list_resi_num[$atom_i] == $resi_num_list[$resi_i] )  && ($list_chain_ID[$atom_i] eq $chain_id_list[$resi_i])){
							#print "$list_chain_ID[$atom_i]  $chain_id_list[$resi_i]\n";
							@ND1_pos = ($pos_x_list[$atom_i], $pos_y_list[$atom_i],  $pos_z_list[$atom_i]);
						}
						if (($list_atom_name[$atom_i] eq "NE2") && ($list_resi_name[$atom_i] eq "HIS")  && ($list_resi_num[$atom_i] == $resi_num_list[$resi_i] )  && ($list_chain_ID[$atom_i] eq $chain_id_list[$resi_i])){
							#print "$list_chain_ID[$atom_i]  $chain_id_list[$resi_i]\n";
							@NE2_pos = ($pos_x_list[$atom_i], $pos_y_list[$atom_i],  $pos_z_list[$atom_i]);
						}
						if ((($list_atom_name[$atom_i] =~ "^N.*")  || ($list_atom_name[$atom_i] =~ "^O.*") ||  ($list_atom_name[$atom_i] =~ "^S.*"))  && ($list_resi_name[$atom_i] eq $hbond_resi_list[$resi_i])  && ($list_resi_num[$atom_i] == $hbond_num_list[$resi_i] )  && ($list_chain_ID[$atom_i] eq $hbond_chain_list[$resi_i])){
							push @hbond_surpos_list ,$pos_x_list[$atom_i];
							push @hbond_surpos_list ,$pos_y_list[$atom_i];
							push @hbond_surpos_list ,$pos_z_list[$atom_i];
						}
					}
					$ND1_min_dist_temp = 99999;
					$NE2_min_dist_temp = 99999;
					for ($pos_i = 0; $pos_i < @hbond_surpos_list; $pos_i+=3){
						$ND1_dist = sqrt(($ND1_pos[0] - $hbond_surpos_list[$pos_i])**2 + ($ND1_pos[1] - $hbond_surpos_list[$pos_i+1])**2 + ($ND1_pos[2] - $hbond_surpos_list[$pos_i+2])**2 );
						$NE2_dist = sqrt(($NE2_pos[0] - $hbond_surpos_list[$pos_i])**2 + ($NE2_pos[1] - $hbond_surpos_list[$pos_i+1])**2 + ($NE2_pos[2] - $hbond_surpos_list[$pos_i+2])**2 );
						if ($ND1_dist < $ND1_min_dist_temp){
							$ND1_min_dist_temp = $ND1_dist;
						}
						if ($NE2_dist < $NE2_min_dist_temp){
							$NE2_min_dist_temp = $NE2_dist;
						}
					}


					if ($hbond_charge_list[$resi_i] >= 0){
						if ($ND1_min_dist_temp < $NE2_min_dist_temp){
							push @hstate_resi_list, $resi_name_list[$resi_i];	
							push @hstate_num_list, $resi_num_list[$resi_i];	
							push @hstate_chain_list, $chain_id_list[$resi_i];	
							push @hstate_state_list, "HID";
							push @hstate_dist_list, $ND1_min_dist_temp;	
							push @hstate_pka_list, $resi_pka_2;	
							push @hstate_hbond_mark_list, $hbond_mark;	
							print OUTPUT "$resi_name_list[$resi_i]\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t$resi_pka_2\tHID\t$ND1_min_dist_temp\t$hbond_mark\n";
						}
						else{
							push @hstate_resi_list, $resi_name_list[$resi_i];	
							push @hstate_num_list, $resi_num_list[$resi_i];	
							push @hstate_chain_list, $chain_id_list[$resi_i];	
							push @hstate_state_list, "HIE";
							push @hstate_dist_list, $NE2_min_dist_temp;	
							push @hstate_pka_list, $resi_pka_2;	
							push @hstate_hbond_mark_list, $hbond_mark;	
							print OUTPUT "$resi_name_list[$resi_i]\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t$resi_pka_2\tHIE\t$ND1_min_dist_temp\t$hbond_mark\n";
						}
					}
					else{
						if ($ND1_min_dist_temp >= $NE2_min_dist_temp){
							push @hstate_resi_list, $resi_name_list[$resi_i];	
							push @hstate_num_list, $resi_num_list[$resi_i];	
							push @hstate_chain_list, $chain_id_list[$resi_i];	
							push @hstate_state_list, "HID";
							push @hstate_dist_list, $ND1_min_dist_temp;	
							push @hstate_pka_list, $resi_pka_2;	
							push @hstate_hbond_mark_list, $hbond_mark;	
							print OUTPUT "$resi_name_list[$resi_i]\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t$resi_pka_2\tHID\t$ND1_min_dist_temp\t$hbond_mark\n";
						}
						else{
							push @hstate_resi_list, $resi_name_list[$resi_i];	
							push @hstate_num_list, $resi_num_list[$resi_i];	
							push @hstate_chain_list, $chain_id_list[$resi_i];	
							push @hstate_state_list, "HIE";
							push @hstate_dist_list, $NE2_min_dist_temp;	
							push @hstate_pka_list, $resi_pka_2;	
							push @hstate_hbond_mark_list, $hbond_mark;	
							print OUTPUT "$resi_name_list[$resi_i]\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t$resi_pka_2\tHIE\t$ND1_min_dist_temp\t$hbond_mark\n";
						}
					
					}
				}
				else  {
					@colb_surpos_list = ();
					for ($atom_i = 0; $atom_i < @list_atom_name; $atom_i++){
						if (($list_atom_name[$atom_i] eq "ND1") && ($list_resi_name[$atom_i] eq "HIS")  && ($list_resi_num[$atom_i] == $resi_num_list[$resi_i] )  && ($list_chain_ID[$atom_i] eq $chain_id_list[$resi_i])){
							#print "$list_chain_ID[$atom_i]  $chain_id_list[$resi_i]\n";
							@ND1_pos = ($pos_x_list[$atom_i], $pos_y_list[$atom_i],  $pos_z_list[$atom_i]);
						}
						if (($list_atom_name[$atom_i] eq "NE2") && ($list_resi_name[$atom_i] eq "HIS")  && ($list_resi_num[$atom_i] == $resi_num_list[$resi_i] )  && ($list_chain_ID[$atom_i] eq $chain_id_list[$resi_i])){
							@NE2_pos = ($pos_x_list[$atom_i], $pos_y_list[$atom_i],  $pos_z_list[$atom_i]);
						}
						if ((($list_atom_name[$atom_i] =~ "^N.*")  || ($list_atom_name[$atom_i] =~ "^O.*") ||  ($list_atom_name[$atom_i] =~ "^S.*"))  && ($list_resi_name[$atom_i] eq $colb_resi_list[$resi_i])  && ($list_resi_num[$atom_i] == $colb_num_list[$resi_i] )  && ($list_chain_ID[$atom_i] eq $colb_chain_list[$resi_i])){
							push @colb_surpos_list ,$pos_x_list[$atom_i];
							push @colb_surpos_list ,$pos_y_list[$atom_i];
							push @colb_surpos_list ,$pos_z_list[$atom_i];
						}
					}
					$ND1_min_dist_temp = 99999;
					$NE2_min_dist_temp = 99999;
					for ($pos_i = 0; $pos_i < @colb_surpos_list; $pos_i+=3){
						$ND1_dist = sqrt(($ND1_pos[0] - $colb_surpos_list[$pos_i])**2 + ($ND1_pos[1] - $colb_surpos_list[$pos_i+1])**2 + ($ND1_pos[2] - $colb_surpos_list[$pos_i+2])**2 );
						$NE2_dist = sqrt(($NE2_pos[0] - $colb_surpos_list[$pos_i])**2 + ($NE2_pos[1] - $colb_surpos_list[$pos_i+1])**2 + ($NE2_pos[2] - $colb_surpos_list[$pos_i+2])**2 );
						if ($ND1_dist < $ND1_min_dist_temp){
							$ND1_min_dist_temp = $ND1_dist;
						}
						if ($NE2_dist < $NE2_min_dist_temp){
							$NE2_min_dist_temp = $NE2_dist;
						}
					}


					if ($colb_charge_list[$resi_i] >= 0){
						if ($ND1_min_dist_temp < $NE2_min_dist_temp){
							push @hstate_resi_list, $resi_name_list[$resi_i];	
							push @hstate_num_list, $resi_num_list[$resi_i];	
							push @hstate_chain_list, $chain_id_list[$resi_i];	
							push @hstate_state_list, "HID";
							push @hstate_dist_list, $ND1_min_dist_temp;	
							push @hstate_pka_list, $resi_pka_2;	
							push @hstate_hbond_mark_list, $hbond_mark;	
							print OUTPUT "$resi_name_list[$resi_i]\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t$resi_pka_2\tHID\t$ND1_min_dist_temp\t$hbond_mark\n";
						}
						else{
							push @hstate_resi_list, $resi_name_list[$resi_i];	
							push @hstate_num_list, $resi_num_list[$resi_i];	
							push @hstate_chain_list, $chain_id_list[$resi_i];	
							push @hstate_state_list, "HIE";
							push @hstate_dist_list, $NE2_min_dist_temp;	
							push @hstate_pka_list, $resi_pka_2;	
							push @hstate_hbond_mark_list, $hbond_mark;	
							print OUTPUT "$resi_name_list[$resi_i]\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t$resi_pka_2\tHIE\t$ND1_min_dist_temp\t$hbond_mark\n";
						}
					}
					else{
						if ($ND1_min_dist_temp >= $NE2_min_dist_temp){
							push @hstate_resi_list, $resi_name_list[$resi_i];	
							push @hstate_num_list, $resi_num_list[$resi_i];	
							push @hstate_chain_list, $chain_id_list[$resi_i];	
							push @hstate_state_list, "HID";
							push @hstate_dist_list, $ND1_min_dist_temp;	
							push @hstate_pka_list, $resi_pka_2;	
							push @hstate_hbond_mark_list, $hbond_mark;	
							print OUTPUT "$resi_name_list[$resi_i]\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t$resi_pka_2\tHID\t$ND1_min_dist_temp\t$hbond_mark\n";
						}
						else{
							push @hstate_resi_list, $resi_name_list[$resi_i];	
							push @hstate_num_list, $resi_num_list[$resi_i];	
							push @hstate_chain_list, $chain_id_list[$resi_i];	
							push @hstate_state_list, "HIE";
							push @hstate_dist_list, $NE2_min_dist_temp;	
							push @hstate_pka_list, $resi_pka_2;	
							push @hstate_hbond_mark_list, $hbond_mark;	
							print OUTPUT "$resi_name_list[$resi_i]\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t$resi_pka_2\tHIE\t$ND1_min_dist_temp\t$hbond_mark\n";
						}
					
					}
				}
			}
		}
		close OUTPUT;

		for ($resi_i = 0; $resi_i < @hstate_resi_list; $resi_i++){
			$resi_pattern = $hstate_resi_list[$resi_i]." ".$hstate_num_list[$resi_i]." ".$hstate_chain_list[$resi_i];
			if ($hstate_uni_dist{$resi_pattern}){
				if ($hstate_hbond_mark_list[$resi_i] < $hstate_uni_hbond_mark{$resi_pattern}){
					next;
				}
				if ($hstate_uni_dist{$resi_pattern} > $hstate_dist_list[$resi_i]){
					$hstate_uni_dist{$resi_pattern}  = $hstate_dist_list[$resi_i];
					$hstate_uni_state{$resi_pattern}  = $hstate_state_list[$resi_i];
				}
			}
			else{
				$hstate_uni_pka{$resi_pattern} = $hstate_pka_list[$resi_i];
				if ($hstate_pka_list[$resi_i] > 7){
					$hstate_uni_dist{$resi_pattern}  = -100;
					$hstate_uni_state{$resi_pattern}  = "HIP";
					$hstate_uni_hbond_mark{$resi_pattern} = 1;
				}
				else{
					$hstate_uni_dist{$resi_pattern}  = $hstate_dist_list[$resi_i];
					$hstate_uni_state{$resi_pattern}  = $hstate_state_list[$resi_i];
					$hstate_uni_hbond_mark{$resi_pattern} = $hstate_hbond_mark_list[$resi_i];
				}
			}
		}

		$output_file = "$ARGV[0]"."_hstate.txt";
		open OUTPUT, ">$output_file" or die "can not create!\n";
		print OUTPUT "Residue  SeqIDd  ChainID  GromacsOption\n";
		foreach $my_pattern (keys %hstate_uni_state){
			@pattern_items = split /\s+/, $my_pattern;
			if ($hstate_uni_state{$my_pattern} eq "HID"){
				$state_select_num = 0;
			}
			elsif ($hstate_uni_state{$my_pattern} eq "HIE"){
				$state_select_num = 1;
			}
			elsif ($hstate_uni_state{$my_pattern} eq "HIP"){
				$state_select_num = 2;
			}
			print OUTPUT "$hstate_uni_state{$my_pattern}\t$pattern_items[1]\t$pattern_items[2]\t$state_select_num\n";
		}

		
		for ($resi_i = 0; $resi_i < @resi_name_list; $resi_i++){
			if ($resi_name_list[$resi_i] eq "ASP"){
				if ($pka_list[$resi_i] ne "     " ){
					if ($pka_list[$resi_i] > 7 ){
						print OUTPUT "ASH\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t1\n";
					}
					else{
						print OUTPUT "ASP\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t0\n";
					}
				}
			}
			if ($resi_name_list[$resi_i] eq "GLU"){
				if ($pka_list[$resi_i] ne "     " ){
					if ($pka_list[$resi_i] > 7 ){
						print OUTPUT "GLH\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t1\n";
					}
					else{
						print OUTPUT "GLU\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t0\n";
					}
				}
			}
			if ($resi_name_list[$resi_i] eq "LYS"){
				if ($pka_list[$resi_i] ne "     " ){
					if ($pka_list[$resi_i] > 7 ){
						print OUTPUT "LYS\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t1\n";
					}
					else{
						print OUTPUT "LYN\t$resi_num_list[$resi_i]\t$chain_id_list[$resi_i]\t0\n";
					}
				}
			}
		}	

		close OUTPUT;
	}
	else{
	
		while($ARGV[1]){
			system("sleep 10s");
			open INPUT, "$ARGV[0].log" or die "can not open!\n" ;
			while(chomp($line=<INPUT>)){
				$log_line = $line;
			}
			close INPUT;
			if ($log_line=~/^DONE.*/){
				print "schrodinger prep is completed!\n";
				last;
			}
        
		}
        
		print  "#################################################\n";
		print  "#                  By Liu Qing                  #\n";
		print  "#   Macau University of Science and Technology  #\n";
		print  "#################################################\n";
		
		open INPUT, "$ARGV[0]_prep.pdb" or die "can not open!\n";
		#@name_split = split /\./, $ARGV[0];
		$output_file = "$ARGV[0]"."_hstate.txt";
		open OUTPUT, ">$output_file" or die "can not create!\n";
        
        
		print OUTPUT "Residue  SeqIDd  ChainID  GromacsOption\n";
		@hstate_resi = ("HIS","HSD","HSE","HSP","HID","HIE","HIP","LYS","GLU","ASP");
		$current_resi_num = 0;
		$mark0 = 0;
		$mark1 = 0;
		@list_resi_name = ();
		@list_atom_name = ();
		@list_resi_num = ();
		@list_chain_ID = ();
        
		while(chomp($line=<INPUT>)){
			@gezis = split //, $line;
			$resi_name = undef;
			for ($gezis_i = 17; $gezis_i<=19; $gezis_i++){
				$resi_name.= $gezis[$gezis_i];
			}
			$atom_name = undef;
			for ($gezis_i = 12; $gezis_i<=15; $gezis_i++){
				$atom_name.= $gezis[$gezis_i];
			}
			$resi_num = undef;
			for ($gezis_i = 22; $gezis_i<=25; $gezis_i++){
				$resi_num.= $gezis[$gezis_i];
			}
			#$chain_ID = undef;
			#for ($gezis_i = 72; $gezis_i<=75; $gezis_i++){
			#	$chain_ID.= $gezis[$gezis_i];
			#}
			$chain_ID = $gezis[21];
        
			for ($hresi_i = 0; $hresi_i < @hstate_resi; $hresi_i++){
				if ($resi_name eq $hstate_resi[$hresi_i]){
					push @list_resi_name, $resi_name;
					push @list_atom_name, $atom_name;
					push @list_resi_num, $resi_num;
					push @list_chain_ID, $chain_ID;
				}
			}
		}
		close INPUT;
        
		@list_HIS = ();
		@list_LYS = ();
		@list_GLU = ();
		@list_ASP = ();
		$temp_resi_num = $list_resi_num[0];
		$temp_chain_ID = $list_chain_ID[0];
		for ($list_i = 0; $list_i < @list_resi_name; $list_i++){
			if (($list_resi_num[$list_i] > $temp_resi_num) || ($list_chain_ID[$list_i] ne $temp_chain_ID) || ($list_i == @list_resi_name -1) ){
				if (($list_resi_name[$list_i-1] eq "HIS") || ($list_resi_name[$list_i-1] eq "HID") || ($list_resi_name[$list_i-1] eq "HIE") || ($list_resi_name[$list_i-1] eq "HIP")){
					push @list_HIS, "$list_resi_num[$list_i-1]"."_$list_chain_ID[$list_i-1]";
				}
				if ($list_resi_name[$list_i-1] eq "LYS"){
					push @list_LYS, "$list_resi_num[$list_i-1]"."_$list_chain_ID[$list_i-1]";
				}
				if ($list_resi_name[$list_i-1] eq "GLU"){
					push @list_GLU, "$list_resi_num[$list_i-1]"."_$list_chain_ID[$list_i-1]";
				}
				if ($list_resi_name[$list_i-1] eq "ASP"){
					push @list_ASP, "$list_resi_num[$list_i-1]"."_$list_chain_ID[$list_i-1]";
				}
				$temp_resi_num = $list_resi_num[$list_i];
				$temp_chain_ID = $list_chain_ID[$list_i];
			}
		}
        
		for ($list_i = 0; $list_i < @list_HIS; $list_i++){
			@item = split /_/, $list_HIS[$list_i];
			for ($list_i2 = 0; $list_i2 < @list_resi_name; $list_i2++){
				if ((($list_resi_name[$list_i2] eq "HIS" ) || ($list_resi_name[$list_i2] eq "HID" ) || ($list_resi_name[$list_i2] eq "HIE" )  || ($list_resi_name[$list_i2] eq "HIP" )) && ($list_resi_num[$list_i2] == $item[0]) && ($list_chain_ID[$list_i2] eq $item[1])){
					if ($list_atom_name[$list_i2] eq " HD1"){
						$mark0 = 1;
					}
					elsif ($list_atom_name[$list_i2] eq " HE2"){
						$mark1 = 1;
					}
					
				}
			}
			if (($mark0 == 1) && ($mark1 == 0)) {
				print OUTPUT "HID @item 0\n";
			}
			elsif (($mark0 == 0) && ($mark1 == 1)) {
				print OUTPUT "HIE @item 1\n";
			}
			elsif (($mark0 == 1) && ($mark1 == 1)) {
				print OUTPUT "HIP @item 2\n";
			}
			$mark0 = 0;
			$mark1 = 0;
		}
        
		for ($list_i = 0; $list_i < @list_LYS; $list_i++){
			@item = split /_/, $list_LYS[$list_i];
			for ($list_i2 = 0; $list_i2 < @list_resi_name; $list_i2++){
				if (($list_resi_name[$list_i2] eq "LYS" ) && ($list_resi_num[$list_i2] == $item[0]) && ($list_chain_ID[$list_i2] eq $item[1])){
					if ($list_atom_name[$list_i2] eq " HZ1"){
						$mark1 = 1;
					}
				}
			}
			if($mark1 == 1){
				print OUTPUT "LYS @item 1\n";
			}
			else {
				print OUTPUT "LYN @item 0\n";
			}
			$mark1 = 0;
		}
                
		for ($list_i = 0; $list_i < @list_ASP; $list_i++){
			@item = split /_/, $list_ASP[$list_i];
			for ($list_i2 = 0; $list_i2 < @list_resi_name; $list_i2++){
				if (($list_resi_name[$list_i2] eq "ASP" ) && ($list_resi_num[$list_i2] == $item[0]) && ($list_chain_ID[$list_i2] eq $item[1])){
					if ($list_atom_name[$list_i2] eq " HD2"){
						$mark1 = 1;
					}
				}
			}
			if($mark1 == 1){
				print OUTPUT "ASH @item 1\n";
			}
			else {
				print OUTPUT "ASP @item 0\n";
			}
			$mark1 = 0;
		}
                
		for ($list_i = 0; $list_i < @list_GLU; $list_i++){
			@item = split /_/, $list_GLU[$list_i];
			for ($list_i2 = 0; $list_i2 < @list_resi_name; $list_i2++){
				if (($list_resi_name[$list_i2] eq "GLU" ) && ($list_resi_num[$list_i2] == $item[0]) && ($list_chain_ID[$list_i2] eq $item[1])){
					if ($list_atom_name[$list_i2] eq " HE2"){
						$mark1 = 1;
					}
				}
			}
			if($mark1 == 1){
				print OUTPUT "GLH @item 1\n";
			}
			else {
				print OUTPUT "GLU @item 0\n";
			}
			$mark1 = 0;
		}
        
		close OUTPUT;
		print  "#################################################\n";
		print  "#                  By Liu Qing                  #\n";
		print  "# University of Science and Technology of China #\n";
		print  "#################################################\n";
	}
