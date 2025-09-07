
	if ($ARGV[-1] == 0){
		die "not add waters into the pocket!";
	}
	elsif ($ARGV[-1] == 1){
		print "generate the waters into pocket!";
	}
	else {
		system("cp $ARGV[-1] wats_inhole_del_2.pdb ");
		die "water pdb is provided!\n";
	}
	
	@cid_list = ();
	for ($ag_i = 0; $ag_i < @ARGV-1; $ag_i++){
		push @cid_list,  $ARGV[$ag_i];
	}



	for ($chain_i = 0; $chain_i < @cid_list ; $chain_i++){
		$atom_count = 0;
		open INPUT, "complex_prep_hs.pdb" or die "can not open!\n";
		open OUTPUT, ">chain_$cid_list[$chain_i]_prep_hs.pdb" or die "can not create!\n";
		while(chomp($line=<INPUT>)){
			@gezis = split //, $line;
			if (($gezis[12] eq "H")  || ($gezis[13] eq "H") ) {
				next;
			}
			if ($gezis[21] ne $cid_list[$chain_i]) {
				next;
			}
			$atom_name_clear = undef;
			for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
				if ($gezis[$gezis_i] ne " "){
					$atom_name_clear .= $gezis[$gezis_i];
				}
			}
			if ($atom_name_clear eq "OXT"){
				next;
			}
			$atom_mark = undef;
			for ($gezis_i = 0; $gezis_i <= 5; $gezis_i++){
			        $atom_mark .= "$gezis[$gezis_i]";
			}
			if (($atom_mark eq "ATOM  ") ||  ($atom_mark eq "HETATM"))  {
				$atom_count++;
				$part_A = undef;
				for ($gezis_i = 11; $gezis_i <= 20 ; $gezis_i++){
					$part_A .= $gezis[$gezis_i];
				}
				$part_B = undef;
				for ($gezis_i = 22; $gezis_i < @gezis ; $gezis_i++){
					$part_B .= $gezis[$gezis_i];
				}
				printf OUTPUT "$atom_mark%5g$part_A%1s$part_B\n", $atom_count, $cid_list[$chain_i];
			}
		}
		close INPUT;
		print OUTPUT "TER\n";
		close OUTPUT;

	}

	
	########################################################################################prepare CONECT for each domain
	$C_N_dist_max = 1.6;  #this is 1.3 measured by pymol. 
	open OUTPUT1, ">10ssinfo_match.txt" or die "can not create!\n";

	$domain_count = 0;
	$itv_a = 0;
	for ($chain_i = 0; $chain_i < @cid_list ; $chain_i++){
		$domain_count++;

		open INPUT, "chain_$cid_list[$chain_i]_prep_hs.pdb" or die "can not open!\n";
		open OUTPUT, ">chain_$cid_list[$chain_i]_for_rism.pdb" or die "can not open!\n";
		@atomre_lines = ();
		while(chomp($line=<INPUT>)){
			push @atomre_lines, $line;
			@gezis = split //, $line;
			$atom_mark = undef;
			for ($gezis_i = 0; $gezis_i <= 5; $gezis_i++){
			        $atom_mark .= "$gezis[$gezis_i]";
			}
			if (($atom_mark eq "ATOM  ") ||  ($atom_mark eq "HETATM"))  {
				print OUTPUT "$line\n";	
			}
		}
		close INPUT;
		print OUTPUT "TER\n";

		#$line_ini = 0;
		@resi_num_list_2 = (); 
		@atom_num_list_2 = (); 
		@atom_name_list_2 = ();
		@chain_ID_list_2 = (); 
		@pos_x_list_2 = ();
		@pos_y_list_2 = ();
		@pos_z_list_2 = ();
		$crt_resi_num = -99999;
		$resi_count = 0;
		#for ($line_i = $line_ini; $line_i < @atomre_lines; $line_i++){
		for ($line_i = 0; $line_i < @atomre_lines; $line_i++){
			
			@gezis = split //, $atomre_lines[$line_i];
			$atom_mark = undef;
			for ($gezis_i = 0; $gezis_i <= 5 ; $gezis_i++){
				$atom_mark .= $gezis[$gezis_i];
			}
			$resi_num = undef;
			for ($gezis_i = 22; $gezis_i <= 25 ; $gezis_i++){
				$resi_num .= $gezis[$gezis_i];
			}
			if ($resi_num > $crt_resi_num){
				$resi_count++;
				$crt_resi_num = $resi_num;
			}
			$atom_num = undef;
			for ($gezis_i = 6; $gezis_i <= 10 ; $gezis_i++){
				$atom_num .= $gezis[$gezis_i];
			}
			$atom_name = undef;
			for ($gezis_i = 12; $gezis_i <= 15 ; $gezis_i++){
				$atom_name .= $gezis[$gezis_i];
			}
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
			if ($atom_mark eq "ATOM  "){
				push @resi_num_list_2, $resi_num;
				push @atom_num_list_2, $atom_num;
				push @atom_name_list_2, $atom_name;
				push @chain_ID_list_2, $gezis[21];
				push @pos_x_list_2, $pos_x;
				push @pos_y_list_2, $pos_y;
				push @pos_z_list_2, $pos_z;
			}
			#if ($atom_mark eq "TER   "){
				#$domain_count++;
				#$line_ini = $line_i+1;
				#last;
			#}
		}
		print OUTPUT1 "domain $domain_count\nresi_count: $resi_count\nlabel: $chain_$cid_list[$chain_i]\n";
		#$itv_a+=$resi_count;
		

		@ss_a = ();
		@ss_b = ();
		@ss_label = ();
		@conect_list = ();
		@conect_label_list = ();
		@conect_list_2 = ();
		@conect_label_list_2 = ();
		$em_seq = undef;
		$md_seq = undef;
		open INPUT, "./chain_$cid_list[$chain_i]/chain_$cid_list[$chain_i]_mm.aln" or die "can not open 2!\n";
		while(chomp($line=<INPUT>)){
			@re_item = split /\s+/, $line;
			if ($re_item[0] eq "chain_$cid_list[$chain_i]_em"){
				$em_seq.=$re_item[1];
			}
			if ($re_item[0] eq "chain_$cid_list[$chain_i]_md"){
				$md_seq.=$re_item[1];
			}
		}
        
		@md_seq_list = split //, $md_seq;
		@em_seq_list = split //, $em_seq;
		@fix_region = ();
		for ($em_i = 0; $em_i < @em_seq_list; $em_i++){
			if ($em_seq_list[$em_i] eq "-") {
				push @fix_region, $em_i + 1;
			}
		}
		close INPUT; 
		
		$model_resi_count = @md_seq_list;
		print OUTPUT1 "model_resi_count: $model_resi_count\nresi_count: $resi_count\n";
		print "fix_region: @fix_region\n";
		print OUTPUT1 "fix_region: @fix_region\n";
        
		#open INPUT, "./chain_$cid_list[$chain_i]/chain_$cid_list[$chain_i]_itv.txt" or die "can not open 5!\n";
		#while(chomp($line=<INPUT>)){
		#	@itv_input = split /\s+/, $line;
		#	$itv_a = $itv_input[0];
		#}
		#close INPUT;

		push @conect_list, $fix_region[0] + $itv_a;
		push @conect_label_list, $cid_list[$chain_i];
		for ($fix_i = 1; $fix_i < @fix_region; $fix_i++){
			if ($fix_region[$fix_i] > $fix_region[$fix_i-1] + 1){
				push @conect_list, $fix_region[$fix_i-1] + $itv_a;
				push @conect_label_list, $cid_list[$chain_i];
				push @conect_list, $fix_region[$fix_i] + $itv_a;
				push @conect_label_list, $cid_list[$chain_i];
			}
		}
		push @conect_list, $fix_region[-1] + $itv_a;
		push @conect_label_list, $cid_list[$chain_i];
		print OUTPUT1 "fix region itv : @conect_list\n";
		
		$input_cnc_file = "./chain_$cid_list[$chain_i]/chain_$cid_list[$chain_i]"."_resi_CN_cnc.txt";
		open INPUT, "$input_cnc_file" or die "can not open 4!\n" ;
		$line_c = 0;
		while(chomp($line=<INPUT>)){
			$line_c++;
			if ($line_c > 1){
				@cncs = split /\s+/, $line;
				push @conect_list_2, $cncs[0] + $itv_a;
				push @conect_label_list_2, $cid_list[$chain_i];
				push @conect_list_2, $cncs[1] + $itv_a;
				push @conect_label_list_2, $cid_list[$chain_i];
			}
		}
		close INPUT;
		print OUTPUT1 "CN cnc : @conect_list_2\n";


		open INPUT, "./chain_$cid_list[$chain_i]/ssbond_filter_model_$cid_list[$chain_i].txt" or die "can not open!\n";
		$line_c = 0;
		while(chomp($line=<INPUT>)){
			$line_c++;
			if ($line_c > 0){
				@ss_info = split /\s+/, $line;
				push @ss_a, $ss_info[4] + $itv_a;
				push @ss_b, $ss_info[7] + $itv_a;
				push @ss_label, $ss_info[3];
			}
			
		}
		close INPUT;
		print OUTPUT1 "s-s bond a: @ss_a\n";
		print OUTPUT1 "s-s bond b: @ss_b\n";

		print "@ss_a\n@ss_b\n@ss_label\n";
		print "@conect_list\n@conect_label_list\n";
		print "@conect_list_2\n@conect_label_list_2\n";


		for ($cne_i = 0; $cne_i <= 1; $cne_i+=2){
			@conect_pair_b = ();
			$mark_3 = 0;
			$mark_4 = 0;
			$mark_5 = 0;
			$C_atom_idx = undef;
			$N_atom_idx = undef;
			$cndist = -9999;
			for ($ret_i = 0; $ret_i < @resi_num_list_2; $ret_i++){
				if (($conect_list[$cne_i + 1] == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " C  ") && ($conect_label_list[$cne_i+1] eq $chain_ID_list_2[$ret_i])){
					push @conect_pair_b, $atom_num_list_2[$ret_i];
					$mark_3 = 1;
					$C_atom_idx = $ret_i;
					print OUTPUT1 "$pos_x_list_2[$ret_i]\t$pos_y_list_2[$ret_i]\t$pos_z_list_2[$ret_i]\n";
				}
				if (($conect_list[$cne_i + 1] + 1 == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " N  ")  && ($conect_label_list[$cne_i+1] eq $chain_ID_list_2[$ret_i])  ){
					push @conect_pair_b, $atom_num_list_2[$ret_i];
					$mark_4 = 1;
					$N_atom_idx = $ret_i;
					print OUTPUT1 "$pos_x_list_2[$ret_i]\t$pos_y_list_2[$ret_i]\t$pos_z_list_2[$ret_i]\n";
				}
				if (($mark_3 == 1)  && ($mark_4 == 1) ){
					$cndist = sqrt(($pos_x_list_2[$C_atom_idx] - $pos_x_list_2[$N_atom_idx])**2 + ($pos_y_list_2[$C_atom_idx] - $pos_y_list_2[$N_atom_idx])**2 + ($pos_z_list_2[$C_atom_idx] - $pos_z_list_2[$N_atom_idx])**2) ;
					if ($cndist > $C_N_dist_max ){
						$mark_5 = 1;
					}
				}
			}
			if (($mark_3 == 1)  && ($mark_4 == 1)  && ($mark_5 == 1) ){
				print "loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i+1]!\n";
				print OUTPUT1 "loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i+1]! $cndist $C_N_dist_max $C_atom_idx $N_atom_idx\n";
				printf OUTPUT "CONECT%5d%5d\n", $conect_pair_b[0],$conect_pair_b[1];
				}
			else{
				print "NO loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i+1]! mark : $mark_3 $mark_4 $mark_5\n";
				print OUTPUT1 "NO loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i+1]! mark : $mark_3 $mark_4 $mark_5\n";
			}
		}
		for ($cne_i = @conect_list-2; $cne_i < @conect_list; $cne_i+=2){
			@conect_pair_a = ();
			$mark_1 = 0;
			$mark_2 = 0;
			$mark_5 = 0;
			$C_atom_idx = undef;
			$N_atom_idx = undef;
			$cndist = -9999;
			for ($ret_i = 0; $ret_i < @resi_num_list_2; $ret_i++){
				if (($conect_list[$cne_i] == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " N  ") && ($conect_label_list[$cne_i] eq $chain_ID_list_2[$ret_i])){
					push @conect_pair_a, $atom_num_list_2[$ret_i];
					$mark_1 = 1;
					$N_atom_idx = $ret_i;
				}
				if (($conect_list[$cne_i] - 1 == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " C  ") && ($conect_label_list[$cne_i] eq $chain_ID_list_2[$ret_i])){
					push @conect_pair_a, $atom_num_list_2[$ret_i];
					$mark_2 = 1;
					$C_atom_idx = $ret_i;
				}
				if (($mark_1 == 1)  && ($mark_2 == 1) ){
					$cndist = sqrt(($pos_x_list_2[$C_atom_idx] - $pos_x_list_2[$N_atom_idx])**2 + ($pos_y_list_2[$C_atom_idx] - $pos_y_list_2[$N_atom_idx])**2 + ($pos_z_list_2[$C_atom_idx] - $pos_z_list_2[$N_atom_idx])**2) ;
					if ($cndist > $C_N_dist_max ){
						$mark_5 = 1;
					}
				}
			}
			if (($mark_1 == 1) && ($mark_2 == 1)   && ($mark_5 == 1) ){
				print "loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i+1]!\n";
				print OUTPUT1 "loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i+1]!\n";
				printf OUTPUT "CONECT%5d%5d\n", $conect_pair_a[0],$conect_pair_a[1];
				}
			else{
				print "NO loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i+1]! mark : $mark_1 $mark_2 $mark_5\n";
				print OUTPUT1 "NO loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i+1]! mark : $mark_1 $mark_2 $mark_5\n";
			}
		}
		for ($cne_i = 2; $cne_i < @conect_list-2; $cne_i+=2){
			@conect_pair_a = ();
			@conect_pair_b = ();
			$mark_1 = 0;
			$mark_2 = 0;
			$mark_3 = 0;
			$mark_4 = 0;
			$mark_5 = 0;
			$mark_6 = 0;
			$C_atom_idx_a = undef;
			$N_atom_idx_a = undef;
			$C_atom_idx_b = undef;
			$N_atom_idx_b = undef;
			$cndist_1 = -9999;
			$cndist_2 = -9999;
			for ($ret_i = 0; $ret_i < @resi_num_list_2; $ret_i++){
				if (($conect_list[$cne_i] == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " N  ") && ($conect_label_list[$cne_i] eq $chain_ID_list_2[$ret_i])){
					push @conect_pair_a, $atom_num_list_2[$ret_i];
					$mark_1 = 1;
					$N_atom_idx_a = $ret_i;
				}
				if (($conect_list[$cne_i] - 1 == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " C  ") && ($conect_label_list[$cne_i] eq $chain_ID_list_2[$ret_i])){
					push @conect_pair_a, $atom_num_list_2[$ret_i];
					$mark_2 = 1;
					$C_atom_idx_a = $ret_i;
				}
				if (($mark_1 == 1)  && ($mark_2 == 1) ){
					$cndist_1 = sqrt(($pos_x_list_2[$C_atom_idx_a] - $pos_x_list_2[$N_atom_idx_a])**2 + ($pos_y_list_2[$C_atom_idx_a] - $pos_y_list_2[$N_atom_idx_a])**2 + ($pos_z_list_2[$C_atom_idx_a] - $pos_z_list_2[$N_atom_idx_a])**2) ;
					if ($cndist_1 > $C_N_dist_max ){
						$mark_5 = 1;
					}
				}
				if (($conect_list[$cne_i + 1] == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " C  ") && ($conect_label_list[$cne_i+1] eq $chain_ID_list_2[$ret_i])){
					push @conect_pair_b, $atom_num_list_2[$ret_i];
					$mark_3 = 1;
					$C_atom_idx_b = $ret_i;
				}
				if (($conect_list[$cne_i + 1] + 1 == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " N  ") && ($conect_label_list[$cne_i+1] eq $chain_ID_list_2[$ret_i])){
					push @conect_pair_b, $atom_num_list_2[$ret_i];
					$mark_4 = 1;
					$N_atom_idx_b = $ret_i;
				}
				if (($mark_3 == 1)  && ($mark_4 == 1) ){
					$cndist_2 = sqrt(($pos_x_list_2[$C_atom_idx_b] - $pos_x_list_2[$N_atom_idx_b])**2 + ($pos_y_list_2[$C_atom_idx_b] - $pos_y_list_2[$N_atom_idx_b])**2 + ($pos_z_list_2[$C_atom_idx_b] - $pos_z_list_2[$N_atom_idx_b])**2) ;
					if ($cndist_2 > $C_N_dist_max ){
						$mark_6 = 1;
					}
				}
			}
			if (($mark_1 == 1) && ($mark_2 == 1)  && ($mark_5 == 1)){
				print "loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i]-1!\n";
				print OUTPUT1 "loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i]-1!\n";
				printf OUTPUT "CONECT%5d%5d\n", $conect_pair_a[0],$conect_pair_a[1];
				}
			else{
				print "NO loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i]-1! mark : $mark_1 $mark_2 $mark_5\n\n";
				print OUTPUT1 "NO loop terminals match: $conect_list[$cne_i]  $conect_list[$cne_i]-1! mark : $mark_1 $mark_2 $mark_5\n\n";
			}
			if (($mark_3 == 1) && ($mark_4 == 1)  && ($mark_6 == 1)){
				print "loop terminals match: $conect_list[$cne_i+1]  $conect_list[$cne_i+1]+1!\n";
				print OUTPUT1 "loop terminals match: $conect_list[$cne_i+1]  $conect_list[$cne_i+1]+1!\n";
				printf OUTPUT "CONECT%5d%5d\n", $conect_pair_b[0],$conect_pair_b[1];
				}
			else{
				print "NO loop terminals match: $conect_list[$cne_i+1]  $conect_list[$cne_i+1]+1! mark : $mark_3 $mark_4 $mark_6\n\n";
				print OUTPUT1 "NO loop terminals match: $conect_list[$cne_i+1]  $conect_list[$cne_i+1]+1! mark : $mark_3 $mark_4 $mark_6\n\n";
			}
		}
		for ($cne_i = 0; $cne_i < @conect_list_2; $cne_i+=2){
			@conect_pair_b = ();
			$mark_3 = 0;
			$mark_4 = 0;
			$mark_5 = 0;
			$C_atom_idx = undef;
			$N_atom_idx = undef;
			$cndist = -9999;
			for ($ret_i = 0; $ret_i < @resi_num_list_2; $ret_i++){
				if (($conect_list_2[$cne_i] == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " C  ") && ($conect_label_list[$cne_i] eq $chain_ID_list_2[$ret_i])){
					push @conect_pair_b, $atom_num_list_2[$ret_i];
					$mark_3 = 1;
					$C_atom_idx = $ret_i;
				}
				if (($conect_list_2[$cne_i + 1] == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " N  ") && ($conect_label_list[$cne_i+1] eq $chain_ID_list_2[$ret_i])){
					push @conect_pair_b, $atom_num_list_2[$ret_i];
					$mark_4 = 1;
					$N_atom_idx = $ret_i;
				}
				if (($mark_3 == 1)  && ($mark_4 == 1) ){
					$cndist = sqrt(($pos_x_list_2[$C_atom_idx] - $pos_x_list_2[$N_atom_idx])**2 + ($pos_y_list_2[$C_atom_idx] - $pos_y_list_2[$N_atom_idx])**2 + ($pos_z_list_2[$C_atom_idx] - $pos_z_list_2[$N_atom_idx])**2) ;
					if ($cndist > $C_N_dist_max ){
						$mark_5 = 1;
					}
				}
			}
			if (($mark_3 == 1)  && ($mark_4 == 1)   && ($mark_5 == 1) ){
				print "loop terminals match2: $conect_list_2[$cne_i]  $conect_list_2[$cne_i+1]!\n";
				print OUTPUT1 "loop terminals match2: $conect_list_2[$cne_i]  $conect_list_2[$cne_i+1]!\n";
				printf OUTPUT "CONECT%5d%5d\n", $conect_pair_b[0],$conect_pair_b[1];
				}
			else{
				print "NO loop terminals match2: $conect_list_2[$cne_i]  $conect_list_2[$cne_i+1]! mark : $mark_3 $mark_4 $mark_5\n\n";
				print OUTPUT1 "NO loop terminals match2: $conect_list_2[$cne_i]  $conect_list_2[$cne_i+1]! mark : $mark_3 $mark_4 $mark_5\n\n";
			}
		}
        
        
        
        
		#@ssbond_list_w = @ssbond_list;
		#open INPUT, "bilayer_complex_prep_hs.pdb" or die "can not open!\n";
		for ($ss_i = 0; $ss_i < @ss_a; $ss_i++){
			@ss_pair = ();
			$mark_1 = 0;
			$mark_2 = 0;
			for ($ret_i = 0; $ret_i < @resi_num_list_2; $ret_i++){
				if (($ss_a[$ss_i] == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " SG ") && ($chain_ID_list_2[$ret_i] eq $ss_label[$ss_i]) ){
					push @ss_pair, $atom_num_list_2[$ret_i];
					$mark_1 = 1;
				}
				if (($ss_b[$ss_i] == $resi_num_list_2[$ret_i]) && ($atom_name_list_2[$ret_i] eq " SG ") && ($chain_ID_list_2[$ret_i] eq $ss_label[$ss_i]) ){
					push @ss_pair, $atom_num_list_2[$ret_i];
					$mark_2 = 1;
				}
			}
			if (($mark_1 == 1) && ($mark_2 == 1) ){
				print "s-s bond match: $ss_a[$ss_i]  $ss_b[$ss_i]!\n";
				print OUTPUT1 "s-s bond match: $ss_a[$ss_i]  $ss_b[$ss_i]!\n";
				printf OUTPUT "CONECT%5d%5d\n", $ss_pair[0],$ss_pair[1];
			}
			else{
				print "NO s-s bond match: $ss_a[$ss_i]  $ss_b[$ss_i]! mark : $mark_1 $mark_2 \n";
				print OUTPUT1 "NO s-s bond match: $ss_a[$ss_i]  $ss_b[$ss_i]! mark : $mark_1 $mark_2 \n";
			}
			
		}

		close OUTPUT;
	}
	close OUTPUT1;
	########################################################################################prepare CONECT for each domain
	

	#system("pdb4amber -i chain_$tm_ids[0]_prep_hs.pdb -o chain_$tm_ids[0]_for_rism.pdb -y -d --reduce");
	open OUTPUT, ">leap_for_rism.in" or die "can not create leap file!\n";
	print OUTPUT "
source leaprc.gaff
source leaprc.protein.ff14SB
source leaprc.water.tip3p
loadamberparams frcmod.ionsjc_tip3p\n";

	for ($chain_i = 0; $chain_i < @cid_list ; $chain_i++){
		print OUTPUT "re$cid_list[$chain_i] = loadpdb chain_$cid_list[$chain_i]_for_rism.pdb\n";
	}
	$len_cid = @cid_list;
	if ($len_cid > 1){
		print OUTPUT "rec = combine {";
		for ($chain_i = 0; $chain_i < @cid_list - 1; $chain_i++){
			print OUTPUT "re$cid_list[$chain_i] ";
		}
		print OUTPUT "re$cid_list[-1]}\n";
	}
	else {
		print OUTPUT "rec = combine {re$cid_list[0]}\n";
	}

	@tm_ids = ();
	for ($chain_i = 0; $chain_i < @cid_list ; $chain_i++){
		$tm_ids[0] .= $cid_list[$chain_i];
	}

	print OUTPUT "solvatebox rec TIP3PBOX 11.0 iso
saveAmberParm rec chain_$tm_ids[0]_for_rism.prmtop chain_$tm_ids[0]_for_rism.inpcrd
quit\n";
	close OUTPUT;

	system("tleap -s -f leap_for_rism.in");
	system(" ambpdb -p chain_$tm_ids[0]_for_rism.prmtop -c chain_$tm_ids[0]_for_rism.inpcrd > chain_$tm_ids[0]_for_rism_box.pdb");


	open OUTPUT, ">mdin.rism" or die "can not create rism file!\n";
	print OUTPUT " single-point 3D-RISM calculation using the sander interface
&cntrl
   ntx=1, nstlim=0, irism=1,
/
&rism
   periodic='pme',
   closure='kh', tolerance=1e-6,
   grdspc=0.35,0.35,0.35, centering=0,
   mdiis_del=0.4, mdiis_nvec=20, maxstep=5000, mdiis_restart=50,
   solvcut=9.0,
   verbose=2, npropagate=0,
   apply_rism_force=0,
   volfmt='dx', ntwrism=1,
/\n";
	close OUTPUT;

	system("sander -O -i mdin.rism -o chain_$tm_ids[0]_for_rism.kh.r3d -p chain_$tm_ids[0]_for_rism.prmtop -c chain_$tm_ids[0]_for_rism.inpcrd -xvv cSPCE_kh.xvv -guv chain_$tm_ids[0]_for_rism.kh");
	system("metatwist --dx chain_$tm_ids[0]_for_rism.kh.O.0.dx --species O --convolve 4 --sigma 1.0 --odx chain_$tm_ids[0]_for_rism.kh.O.dx > chain_$tm_ids[0]_for_rism.lp");
	system("metatwist --dx chain_$tm_ids[0]_for_rism.kh.O.0.dx --ldx chain_$tm_ids[0]_for_rism.kh.O.dx --map blobsper --species O WAT --bulk 55.55 --threshold 0.5 > chain_$tm_ids[0]_for_rism.blobs");
	system("grep -v TER chain_$tm_ids[0]_for_rism.kh.O.0-chain_$tm_ids[0]_for_rism.kh.O-blobs-centroid.pdb > wats.pdb");


	print  "#################################################\n";
	print  "#                  By Liu Qing                  #\n";
	print  "# University of Science and Technology of China #\n";
	print  "#################################################\n";
