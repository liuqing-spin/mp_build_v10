	
	open INPUT, "$ARGV[0]" or die "can not open!\n";
	while(chomp($line=<INPUT>)){
		if ($line=~"^HEADER.*"){
			@header_list = split /\s+/, $line;
			$target_pdb_id = $header_list[-1];
		}
	}
	close INPUT;
	

	open INPUT, "build_profile.prf" or die "can not open!\n";
	@ID_list = ();
	@simi_list = ();
	@sig_list = ();
	while(chomp($line=<INPUT>)){
		if ($line=~"^#"){
			#print "$line\n";
			next;
		}
		else{
			@items = split /\s+/, $line;
			if ($items[1] > 1){
				#print "$items[2]\n";
				push  @ID_list,  $items[2]; 
			       	push  @simi_list, $items[11];
				push  @sig_list, $items[12];
			}
		}
	}
	close INPUT;

	#open OUTPUT, ">temp.txt" or die "can not create!\n";
	#for ($temp_i4 = 0; $temp_i4 < @ID_list; $temp_i4++){
	#	print OUTPUT "$ID_list[$temp_i4]\n";
	#}
	#close OUTPUT;
	#print "@ID_list\n@simi_list\n@sig_list\n";
	#print "@ID_list\n";

	@svi_1 = @ID_list;
	@svi_2 = @simi_list;
	@svi_3 = @sig_list;
	@ord_ID = ();
	@ord_simi = ();
	@ord_sig = ();

	
	for ($temp_i = 0; $temp_i < @simi_list; $temp_i++){
		$max_index = 0;
		$max_simi = $svi_2[$max_index];
		for ($temp_i2 = 1; $temp_i2 < @svi_2; $temp_i2++){
			if ($svi_2[$temp_i2] > $max_simi){
				$max_index = $temp_i2;
				$max_simi = $svi_2[$max_index];
			}
		}
		push @ord_ID, $svi_1[$max_index];
		push @ord_simi, $svi_2[$max_index];
		push @ord_sig, $svi_3[$max_index];

		@temp_1 = @svi_1;
		@temp_2 = @svi_2;
		@temp_3 = @svi_3;
		@svi_1 = ();
		@svi_2 = ();
		@svi_3 = ();
		for ($temp_i3 = 0; $temp_i3 < @temp_2; $temp_i3++){
			if ($temp_i3 != $max_index){
				push @svi_1, $temp_1[$temp_i3];		
				push @svi_2, $temp_2[$temp_i3];		
				push @svi_3, $temp_3[$temp_i3];		
			}
		}
	
	}

	open OUTPUT, ">template_order_list.txt" or die "can not create!\n";
	for ($temp_i4 = 0; $temp_i4 < @ord_ID; $temp_i4++){
		print OUTPUT "$ord_ID[$temp_i4]\t$ord_simi[$temp_i4]\t$ord_sig[$temp_i4]\n";
	}
	close OUTPUT;

	$tmm_idx = 1;
	@top2_temp = ();
	@top2_temp_chain = ();
	push @top2_temp, $target_pdb_id;
	push @top2_temp_chain, "A";
	for ($temp_i4 = 0; $temp_i4 < @ord_ID; $temp_i4++){
		if ($ord_ID[$temp_i4] =~ "^ZT0.*"){
			@gezis = split //, $ord_ID[$temp_i4];
			$temp_pdbid = undef;
			for ($gezis_i = 0; $gezis_i <= 3; $gezis_i++){
				$temp_pdbid.= $gezis[$gezis_i];
			}
			push @top2_temp, $temp_pdbid;
			push @top2_temp_chain, $gezis[4];
			system("cp ../$temp_pdbid.pdb ./");
			$tmm_idx = 2;
			last;
		}
	}
	for ($temp_i4 = 0; $temp_i4 < @ord_ID; $temp_i4++){
		if (@top2_temp < 3){
			@gezis = split //, $ord_ID[$temp_i4];
			$temp_pdbid = undef;
			for ($gezis_i = 0; $gezis_i <= 3; $gezis_i++){
				$temp_pdbid.= $gezis[$gezis_i];
			}
			$match_mark = 0;
			for ($temp_i5 = 0; $temp_i5 < @top2_temp; $temp_i5++){
				if ($top2_temp[$temp_i5] eq $temp_pdbid){
					$match_mark = 1;
					last;
				}
			}
			if ($match_mark == 0){
				push @top2_temp, $temp_pdbid;
				push @top2_temp_chain, $gezis[4];
				system("rm pdb$temp_pdbid.ent.gz*");
				system("rm pdb$temp_pdbid.ent*");
				if ($temp_pdbid =~ "^ZT0.*" ){
					system("cp ../$temp_pdbid.pdb ./");
				}
				else{
					system("wget https://files.wwpdb.org/pub/pdb/data/structures/all/pdb/pdb$temp_pdbid.ent.gz");
					system("gunzip pdb$temp_pdbid.ent.gz");
					system("cp pdb$temp_pdbid.ent $temp_pdbid.pdb");
				}
			}
		}
		if (@top2_temp >= 3){
			last;
		}

	}

	
	open OUTPUT, ">6rank_template_output.txt" or die "can not create!\n";
	print OUTPUT "$top2_temp[1]\t$top2_temp_chain[1]\n";
	close OUTPUT;
	open OUTPUT, ">6rank_template_output_forss.txt" or die "can not create!\n";
	print OUTPUT "$top2_temp[1]\t$top2_temp_chain[1]\n$top2_temp[2]\t$top2_temp_chain[2]\n";
	close OUTPUT;
	print "top2 template:#### \n$top2_temp[1]\t$top2_temp_chain[1]\n$top2_temp[2]\t$top2_temp_chain[2]\n";
	
	opendir (OPM, "$ARGV[-1]/databases/opm_pdbs/") or die "can not open opmdir!\n";
	@opm_db = readdir OPM;
	closedir OPM;
	
	
	open OUTPUT, ">>../tmm_id_list.txt" or die "can not create!\n";
	for ($id_i = 2 ; $id_i < @ARGV-1 ; $id_i++){
		if ($ARGV[1] eq $ARGV[$id_i]){
			$opm_match = 0;
			for ($pdb_i = 0 ; $pdb_i < @opm_db; $pdb_i++){
				@temp_arr_3 = split /\./, $opm_db[$pdb_i];
				if ($temp_arr_3[0] eq $top2_temp[$tmm_idx]){
					$opm_match = 1;
					system("cp $ARGV[-1]/databases/opm_pdbs/$top2_temp[$tmm_idx].pdb ../$top2_temp[$tmm_idx]_opm.pdb");
					print OUTPUT "$top2_temp[$tmm_idx]\t$ARGV[1]\n";
					last;
				}
			}
			#$opm_match = 0;
			if ($opm_match == 0){
				system("rm -rf temp");
				system("rm pair_wise_align_score.txt");
				system("mkdir temp");

				open INPUT, "$ARGV[-1]/scripts/homo_build/opm_seq.fasta" or die "can not open!\n";
				$fasta_c = 0;
				$fasta_file_c = 0;
				@fasta_name_list = ();
				while(chomp($line=<INPUT>)){
					$fasta_c++;
					if ($fasta_c==2){
						print OUTPUT1 "$line\n";
						system("cat chain_$ARGV[1]_raw.fasta >> ./temp/$fasta_name.fasta");
						close OUTPUT1;
						$fasta_c=0;
					}
					elsif ($fasta_c==1){
						$fasta_file_c++;
						@gezi = split //, $line;
						$fasta_name = undef;
						for ($gezi_i = 1; $gezi_i <= 5 ; $gezi_i++){
							$fasta_name.=$gezi[$gezi_i];
						}
						push @fasta_name_list, $fasta_name;
						open OUTPUT1, ">./temp/$fasta_name.fasta";
						print OUTPUT1 "$line\n";
					}
					
				}
				close INPUT;

				for ($fas_i = 0; $fas_i < @fasta_name_list; $fas_i++){
					system("../clustalw2 ./temp/$fasta_name_list[$fas_i].fasta >> pair_wise_align_score.txt");
					#print "../clustalw2 ./temp/$fasta_name_list[$fas_i].fasta >> pair_wise_align_score.txt\n";
				}

				open INPUT, "pair_wise_align_score.txt" or die "can not open!\n";
				$align_mark = 0;
				@score_list = ();
				@fas_list = ();
				while(chomp($line=<INPUT>)){
					if ($line=~"^Start of Pairwise alignments.*"){
						$align_mark++ ;
						next;
					}
					if (($line=~"^Alignment Score.*")  && ($align_mark == 1)){
						@score_list_temp = split /\s+/, $line;
						push @score_list, $score_list_temp[-1];
						$align_mark++;
						next;
					}
					if (($line=~"^CLUSTAL-Alignment file created.*")  && ($align_mark == 2)){
						@file_temp_a = split /\s+/, $line;
						@file_temp_b = split //, $file_temp_a[-1];
						$fasta_temp = undef;
						for ($gezi_i = 1; $gezi_i < @file_temp_b-4; $gezi_i++){
							$fasta_temp.=$file_temp_b[$gezi_i];
						}
						push @fas_list, $fasta_temp;
						$align_mark = 0;
					}
				}
				close INPUT;
				
				$score_max = $score_list[0];
				$id_max = 0;
				for ($score_i = 1;$score_i < @score_list; $score_i++){
					if ($score_list[$score_i]>$score_max){
						$score_max = $score_list[$score_i];
						$id_max = $score_i;
					}
				}
				print "$fas_list[$id_max]fasta\n";
				open INPUT, "$fas_list[$id_max]fasta" or die "can not open 1!\n";
				while(chomp($line=<INPUT>)){
					@gezi = split //, $line;
					$tar_opm_id = undef;
					for ($gezi_i = 1; $gezi_i <= 4 ; $gezi_i++){
						$tar_opm_id.=$gezi[$gezi_i];
					}
					last;
				}
				close INPUT;
				$tar_opm_id_2 = $tar_opm_id."_opm";
				system("cp $ARGV[-1]/databases/opm_pdbs/$tar_opm_id.pdb ../$tar_opm_id_2.pdb");
				print OUTPUT "$tar_opm_id\t$ARGV[1]\n";
			}

		}
	}
	close OUTPUT;
	print  "#################################################\n";
	print  "#                  By Liu Qing                  #\n";
	print  "# University of Science and Technology of China #\n";
	print  "#################################################\n";
