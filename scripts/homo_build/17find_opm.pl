	
	open INPUT, "$ARGV[0]" or die "can not open!\n";
	$line_c = 0;
	@raw_complex_pdbid = ();
	while(chomp($line=<INPUT>)){
		if (($line=~"^HEADER.*") || ($line_c == 0)){
			@header_list = split /\s+/, $line;
			$target_pdb_id = $header_list[-1];
			push @raw_complex_pdbid, lc($header_list[-1]);
		}
		$line_c++;
	}
	close INPUT;
	@temp_arr = split /\./, $ARGV[0];
	push @raw_complex_pdbid, lc($temp_arr[0]);
	
	
	open OUTPUT, ">6rank_template_output.txt" or die "can not create!\n";
	print OUTPUT "$top2_temp[1]\t$top2_temp_chain[1]\n";
	close OUTPUT;
	open OUTPUT, ">6rank_template_output_forss.txt" or die "can not create!\n";
	print OUTPUT "$top2_temp[1]\t$top2_temp_chain[1]\n$top2_temp[2]\t$top2_temp_chain[2]\n";
	close OUTPUT;
	print "top2 template:#### \n$top2_temp[1]\t$top2_temp_chain[1]\n$top2_temp[2]\t$top2_temp_chain[2]\n";
	
	opendir (OPM, "$ARGV[-1]/databases/opm_pdbs/") or die "can not open opmdir!\n";
	@opm_db_raw = readdir OPM;
	closedir OPM;
	
	@opm_db = ();
	for ($pdb_i = 0 ; $pdb_i < @opm_db_raw; $pdb_i++){
		if (($opm_db_raw[$pdb_i] eq "\.") || ($opm_db_raw[$pdb_i] eq "\.\.") || (!$opm_db_raw[$pdb_i])) {
			next;
		}
		else{
			push @opm_db, $opm_db_raw[$pdb_i];
		}
	}
		
	@user_opm = split /\./, $ARGV[-2];
	open OUTPUT, ">>../tmm_id_list.txt" or die "can not create!\n";
	for ($id_i = 2 ; $id_i < @ARGV-2 ; $id_i++){
		if ($ARGV[1] eq $ARGV[$id_i]){
			if ($ARGV[-2] ne "0"){
				print OUTPUT "$user_opm[0]\t$ARGV[1]\n";
				last;
			}
			$opm_match = 0;
			for ($pdb_i = 0 ; $pdb_i < @opm_db; $pdb_i++){
				@temp_arr_3 = split /\./, $opm_db[$pdb_i];
				for ($pdb_i2 = 0; $pdb_i2 < @raw_complex_pdbid; $pdb_i2++){
					if ($temp_arr_3[0] eq $raw_complex_pdbid[$pdb_i2]){
						$opm_match = 1;
						system("cp $ARGV[-1]/databases/opm_pdbs/$temp_arr_3[0].pdb ../$temp_arr_3[0]_opm.pdb");
						print OUTPUT "$temp_arr_3[0]\t$ARGV[1]\n";
						last;
					}
				}
				if ($opm_match == 1){
					last;
				}
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

	open INPUT, "chain_$ARGV[1].pdb" or die "can not open 3!\n";
	$line_c = 0;
	while(chomp($line=<INPUT>)){
		@gezis = split //, $line;
		$atom_mark = undef;
		for ($gezis_i = 0; $gezis_i <= 5 ; $gezis_i++){
			$atom_mark .= $gezis[$gezis_i];
		}
		if ($atom_mark eq "ATOM  "){
			$line_c++;
			$resi_num = undef;
			for ($gezis_i = 22; $gezis_i <= 25 ; $gezis_i++){
				$resi_num .= $gezis[$gezis_i];
			}
			if ($line_c == 1){
				$start_seq_num = $resi_num;
			}
			else{
				$end_seq_num = $resi_num;
			}
		}
	}
	close INPUT;

	$seq_len = $end_seq_num - ($start_seq_num - 1);

	open OUTPUT, ">chain_$ARGV[1]_itv.txt" or die "can not create!\n";
	$itv_seq=0;
	print OUTPUT "$itv_seq\t$seq_len\n";
	close OUTPUT;

	print  "#################################################\n";
	print  "#                  By Liu Qing                  #\n";
	print  "# University of Science and Technology of China #\n";
	print  "#################################################\n";
