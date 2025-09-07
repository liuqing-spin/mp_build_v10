	
	
	opendir (OPM, "../../databases/opm_pdbs/") or die "can not open opmdir!\n";
	@opm_db = readdir OPM;
	closedir OPM;
	
	system("rm opm_seq_raw.txt");
	for ($pdb_i = 0 ; $pdb_i < @opm_db; $pdb_i++){
		if (($opm_db[$pdb_i] eq "\.")  || ($opm_db[$pdb_i] eq "\.\.")){
			next;
		} 
		system("perl pdb2fasta.pl  ../../databases/opm_pdbs/$opm_db[$pdb_i] >> opm_seq_raw.txt");
	}

	open INPUT, "opm_seq_raw.txt" or die "can not open!\n";
	open OUTPUT, ">opm_seq_full.txt" or die "can not open!\n";
	$id_mark = 0;
	while(chomp($line=<INPUT>)){
		if ($line=~"^>.*"){
			@items = split /\s+/, $line;
			@pdb_full_a = split /\//, $items[0];
			@pdb_full_b = split /\./, $pdb_full_a[-1];
			$id_new = $pdb_full_b[0].$items[1];
			print OUTPUT ">$id_new\n";
			$id_mark = 1;
			next;
		}
		if ($id_mark == 1){
			print OUTPUT "$line\n";
			$id_mark = 0;
		}
	}
	close INPUT;
	close OUTPUT;

	open INPUT, "opm_seq_full.txt" or die "can not open!\n";
	@opm_seq_list = ();
	while(chomp($line=<INPUT>)){
		push @opm_seq_list, $line;
	}
	close INPUT;

	@opm_seq_uni_list = ();
	push @opm_seq_uni_list, $opm_seq_list[0];
	push @opm_seq_uni_list, $opm_seq_list[1];

	for ($seq_i = 3; $seq_i < @opm_seq_list; $seq_i+=2){
		$opm_match = 0;
		for ($seq_i2 = 1; $seq_i2 < @opm_seq_uni_list; $seq_i2+=2){
			@opm_seq_len = split //, $opm_seq_list[$seq_i];
			$opm_seq_len_num = @opm_seq_len;
			if (($opm_seq_list[$seq_i] eq $opm_seq_uni_list[$seq_i2]) || ($opm_seq_list[$seq_i-1] eq $opm_seq_uni_list[$seq_i2-1]) || ($opm_seq_len_num == 0)) {
				$opm_match = 1;
				last;
			}	
		}
		if ($opm_match == 0){
			push @opm_seq_uni_list, $opm_seq_list[$seq_i-1];
			push @opm_seq_uni_list, $opm_seq_list[$seq_i];
		}
	}

	open OUTPUT, ">opm_seq.fasta" or die "can not open!\n";

	for ($seq_i2 = 0; $seq_i2 < @opm_seq_uni_list; $seq_i2++){
		print OUTPUT "$opm_seq_uni_list[$seq_i2]\n";
	}
	close OUTPUT;
