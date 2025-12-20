	#input info: origin pdb, chain ID , ref pdb ID
	
	$complex_pdb = $ARGV[0];
	@crt_cID = ();
	push @crt_cID, $ARGV[1];

	open INPUT, "chain_$crt_cID[0]_raw_vs_em_resi_num.txt" or die "can not open 4!\n" ;
	$line_c=0;
	@em_resi_num_list = ();
	@raw_resi_num_list = ();
	while(chomp($line=<INPUT>)){
		$line_c++;
		if ($line_c>1){
			@em_raw_vlist = split /\s+/, $line;
			push @em_resi_num_list, $em_raw_vlist[1];
			push @raw_resi_num_list, $em_raw_vlist[2];
		}
	}
	close INPUT;


 %aa_name = (
        "ARG" => "R",
        "HIS" => "H",
        "LYS" => "K",
        "ASP" => "D",
        "GLU" => "E",
        "SER" => "S",
        "THR" => "T",
        "ASN" => "N",
        "GLN" => "Q",
        "CYS" => "C",
        "GLY" => "G",
        "PRO" => "P",
        "ALA" => "A",
        "VAL" => "V",
        "ILE" => "I",
        "LEU" => "L",
        "MET" => "M",
        "PHE" => "F",
        "TYR" => "Y",
        "TRP" => "W",
);
	@template_pdb_list = ();
	@template_ID_list = ();
	open INPUT, "6rank_template_output_forss.txt" or die "can not open!\n";
	while(chomp($line=<INPUT>)){
		@items = split /\s+/, $line;
		push @template_pdb_list, $items[0];
		push @template_ID_list, $items[1];
	}
	close INPUT;


	#@origin_ssbond = ();
	open INPUT, "$complex_pdb" or die "can not open!\n";
	open OUTPUT, ">ssbond_filter_model_$crt_cID[0].txt" or die "can not create!\n";
	print OUTPUT "SSBOND XXX CYS $crt_cID[0] XXXX    CYS $crt_cID[0] XXXX\n";
	while(chomp($line=<INPUT>)){
		if ($line=~"^SSBOND.*"){
			@gezis = split //, $line;
			$cys_a = undef;
			for ($gezis_i = 17; $gezis_i <= 20 ; $gezis_i++){
				$cys_a .= $gezis[$gezis_i];
			}
			$cys_b = undef;
			for ($gezis_i = 31; $gezis_i <= 34 ; $gezis_i++){
				$cys_b .= $gezis[$gezis_i];
			}
			if (($gezis[15] eq $crt_cID[0]) && ($gezis[29] eq $crt_cID[0]))  {
				for ($num_i = 0; $num_i<@em_resi_num_list; $num_i++){
					if ($cys_a == $em_resi_num_list[$num_i]){
						$cys_a_raw = $raw_resi_num_list[$num_i];
					}
					if ($cys_b == $em_resi_num_list[$num_i]){
						$cys_b_raw = $raw_resi_num_list[$num_i];
					}
				}
				printf OUTPUT "SSBOND XXX CYS $crt_cID[0] %4g    CYS $crt_cID[0] %4g\n", $cys_a_raw, $cys_b_raw;
			}
		}
	}
	close INPUT;




	
	close OUTPUT;


	print  "#################################################\n";
	print  "#                  By Liu Qing                  #\n";
	print  "# University of Science and Technology of China #\n";
	print  "#################################################\n";
