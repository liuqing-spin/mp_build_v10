	sub pdb2fasta {
               %xaa_namex = (
                    "ARG"   => "R",
                    "HIS"   => "H",
                    "LYS"   => "K",
                    "ASP"   => "D",
                    "GLU"   => "E",
                    "SER"   => "S",
                    "THR"   => "T",
                    "ASN"   => "N",
                    "GLN"   => "Q",
                    "CYS"   => "C",
                    "GLY"   => "G",
                    "PRO"   => "P",
                    "ALA"   => "A",
                    "VAL"   => "V",
                    "ILE"   => "I",
                    "LEU"   => "L",
                    "MET"   => "M",
                    "PHE"   => "F",
                    "TYR"   => "Y",
                    "TRP"   => "W",
		);
		@input_pdbs = @_;
		open XINPUTX, "$input_pdbs[0]" or die "can not open xinpux!\n";
		$resi_count = 0;
		$crt_resi_num = -9999;
		$crt_chain_id = undef;
		@aa_tsw = ();
		$ter_mark = 0;
		while(chomp($xlinex=<XINPUTX>)){
			@gezis = split //, $xlinex;
			$atom_mark = undef;
			for ($gezis_i = 0; $gezis_i <= 5 ; $gezis_i++){
				$atom_mark .= $gezis[$gezis_i];
			}
			$resi_num = undef;
			for ($gezis_i = 22; $gezis_i <= 25 ; $gezis_i++){
				$resi_num .= $gezis[$gezis_i];
			}
			$resi_name = undef;
			for ($gezis_i = 17; $gezis_i <= 19 ; $gezis_i++){
				$resi_name .= $gezis[$gezis_i];
			}
			if ((($atom_mark eq "TER   ") || ($xlinex =~ "^TER.*"))  &&  ($ter_mark == 0) ) {
				$ter_mark = 1;
				print ">$input_pdbs[0]\t$crt_chain_id\t$resi_count\n";
				for ($aa_i = 0; $aa_i < @aa_tsw; $aa_i++){
					print "$aa_tsw[$aa_i]";
				}
				print "\n";
				$resi_count = 0;
				$crt_resi_num = -9999;
				$crt_chain_id = undef;
				@aa_tsw = ();
			}
			elsif (($atom_mark eq "ATOM  ") && ($resi_num != $crt_resi_num) && ($ter_mark == 1)){
				$ter_mark = 0;
				$resi_count++;
				$crt_resi_num = $resi_num;
				$crt_chain_id = $gezis[21];
				push @aa_tsw, "$xaa_namex{$resi_name}";
			}
			elsif (($atom_mark eq "ATOM  ") && ($resi_num != $crt_resi_num)){
				$resi_count++;
				$crt_resi_num = $resi_num;
				$crt_chain_id = $gezis[21];
				push @aa_tsw, "$xaa_namex{$resi_name}";
			}
		
		}
		if ($ter_mark == 0){
			$ter_mark = 1;
			print ">$input_pdbs[0]\t$crt_chain_id\t$resi_count\n";
			for ($aa_i = 0; $aa_i < @aa_tsw; $aa_i++){
				print "$aa_tsw[$aa_i]";
			}
			print "\n";
			$resi_count = 0;
			$crt_resi_num = -9999;
			$crt_chain_id = undef;
			@aa_tsw = ();
			
		}
		close XINPUTX;
	}


	&pdb2fasta($ARGV[0]);
