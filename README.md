# MPBuild v10: Automated Membrane Protein System Construction Toolkit
________________________________________
## 1. Introduction
MPBuild v10 is a specialized computational pipeline designed to address critical challenges in membrane protein drug discovery. Leveraging molecular dynamics (MD) simulations for analyzing ligand-target interactions requires high-fidelity system preparation. Existing tools like CHARMM-GUI suffer from limitations including network dependency, manual preprocessing requirements, and poor scalability for high-throughput studies. MPBuild v10 overcomes these through:
•	Fully localizable architecture: Eliminates cloud dependency
•	Automated structural repair: Corrects mutations, fills missing domains, and reconstructs disulfide bonds
•	Batch-processing capability: Enables large-scale virtual screening
•	Multi-force field support: Compatible with AMBER/CHARMM workflows
Developed through integration of robust computational tools (AmberTools24, Modeller 10.6, PROPKA3, PyMOL, Gaussian, Schrodinger Suites), this toolkit provides an end-to-end solution from structural preparation to binding free energy calculations.
________________________________________
## 2. Installation and Setup

 **2.1 Dependencies** 

Mandatory components  
- AmberTools24      # Force field parametrization & system assembly  
- Modeller 10.6     # Homology-based structural repair  
- PyMOL 2.5+        # Structural alignment & visualization  
- PROPKA3           # Protonation state assignment. It is typically installed with AmberTools24 and requires no separate installation.

Optional components  
- Schrodinger Suites  # Advanced protein preparation (alternative to AmberTools)  
- Gaussian 16         # RESP charge calculations for ligands/nonstandard residues  

 **2.2 Deployment Procedure** 

Clone repository and initialize databases  
```
git clone https://gitee.com/liuqingspin/mp_build_v10  
cd mp_build_v10
```  

Create required directories  
```
mkdir -p databases/opm_pdbs databases/nonaa  
```

Download structural databases  
```
wget -P databases https://opm.phar.umich.edu/opm_pdbs.tar.gz  
tar -xvf databases/opm_pdbs.tar.gz -C databases/opm_pdbs  
wget -P databases https://salilab.org/modeller/pdball.pir  
```

 **2.3 ​​AmberTools24 Installation​​** 

​​Download AmberTools24 from the official AMBER website​​.
Install system dependencies
```
sudo apt install build-essential libglu1-mesa libxi-dev libxmu-dev \
     libglu1-mesa-dev freeglut3-dev gcc g++ make cmake bison flex \
     openmpi-bin openmpi-doc libopenmpi-dev bc csh flex gfortran g++ \
     xorg-dev zlib1g-dev libbz2-dev patch vim python-pip libjpeg-dev \
     zlib1g-dev octave python3-sphinx libssl-dev libclang-dev \
     libgconf-2-4 python3-pip pymol
```
Install Python packages
```
pip3 install numpy scipy matplotlib pandas pillow mpi4py cython pymol
```
Extract source files
```
tar -xvf AmberTools24.tar.bz2
```
Extract Amber24.tar.gz if present
```
tar -xvf Amber24.tar.bz2     
```
Compile and install
```
cd amber24_src/build/
./run_cmake
make install
```
Configure environment
```
source ~/Downloads/software/amber24/amber.sh
```
Enable MPI support
```
vi run_cmake  # Change "mpi=FALSE" to "mpi=TRUE"
./run_cmake
make install
```

 **​​2.4 MODELLER Installation** 

​​Download modeller_10.4 from the official MODELLER website​​.
Replace 'your_key' with actual license key
```
sudo env KEY_MODELLER=your_key dpkg -i modeller_10.4-1_amd64.deb
```

________________________________________
## 3. Core Functionality

 **3.1 System Construction Command** 
```
bash build.sh \  
  -m_path [MPBuild_directory] \  # Absolute path to mp_build_v10  
  -p_com [target.pdb] \          # Input PDB with hydrogens  
  -p_tmm [transmembrane_chain] \  # Chain ID of transmembrane domain  
  # Optional parameters  
  -s_path [schrodinger_path] \   # Schrodinger Suites installation  
  -p_cid [chain_IDs] \            # Specify domains to include  
  -p_seq [wildtype.fasta] \       # Template for mutation reversal  
  -p_tpt [alphafold.pdb] \        # Structural template for gap filling  
  -c_lig [ligand.pdb] \           # Pre-parametrized ligand  
  -c_pep [peptide.pdb] \          # Noncanonical residue parameters  
  -w_inh [0/1/water.pdb] \        # Transmembrane hydration control  
  -n_num [threads] \              # Parallel threads for minimization  
  -o_lip [lipid_types] \         # Membrane composition (e.g., POPC:CHL1//POPE)  
  -r_lip [lipid_ratios] \         # Lipid ratios (e.g., 4:3//1) 
  -d_opt [0/1]                    # 0 (keep intermediate files) or 1 (remove intermediate files, default)
``` 
 **3.2 Critical Parameter Specifications** 

Structural Repair Workflow. When provided with -p_tpt, MPBuild uses AlphaFold-predicted structures as homology templates while preserving experimental protein-protein interaction interfaces. The pipeline automatically identifies and reconstructs disulfide bonds through conserved bonding pattern analysis.

Hydration Optimization. The -w_inh parameter enables transmembrane cavity hydration prediction:
```
o	0: Skip hydration (default)
o	1: Generate cavity water molecules (4-8 hours computation)
o	[file.pdb]: Reuse precomputed hydration sites
```
Force Field Flexibility. Protonation states are assigned via PROPKA3 when -s_path is omitted. Ligand parameters are generated using Gaussian-derived RESP charges with GAFF2/ff14SB force fields.
________________________________________
## 4. Case Studies: Building 11 Membrane Protein Systems

Below are the construction steps for 11 membrane protein systems. The corresponding files are located in your_path/mp_build_v10/sample. Membrane protein structures were downloaded from the PDB Data Bank (www.rcsb.org). Template sequence files (complex_seq.txt) and template structure files (template.pdb) were obtained from UniProt (www.uniprot.org). Template sequence files must include sequence information and domain IDs for all structural domains used in system construction. Format examples can be found in the following case studies. Peptides and small-molecule ligands were extracted from PDB files and processed accordingly. Preparation of AMBER-compatible force field files for ligands/non-standard residues requires pre-installed Gaussian16. For CHARMM-compatible parameters, users must generate strfiles via CGenFF and place them in your_path/mp_build_v10/tools/toppar/lig_manual/, ensuring filenames and molecule names match system identifiers.


 
 **4.1 ABCB1 (PDB ID: 6QEX)** 

​​Generate AMBER parameters for ligand TA1:​​

```
cp your_path/mp_build_v10/scripts/make_nonaa_lig/make_lig_v6.pl ./
perl make_lig_v6.pl -pdb TA1.pdb -mol2 TA1.mol2 -name TA1 -gau g16 -np 6 -ac 0
cp TA1.prepin TA1.lib TA1.frcmod your_path/mp_build_v10/databases/nonaa/
```

​​Build system:​​

```
cp your_path/mp_build_v10/build.sh ./
bash build.sh -p_com 6qex.pdb -m_path your_path/mp_build_v10 -p_tmm A -p_cid A -p_seq complex_seq.txt -p_tpt template.pdb -c_lig TA1_m.pdb
```

 **4.2 ASIC (PDB ID: 7CFT)** 

​​Build system:​​

```
cp your_path/mp_build_v10/build.sh ./
bash build.sh -p_com 7cft.pdb -m_path your_path/mp_build_v10 -p_tmm A -p_tmm B -p_tmm C -p_cid A -p_cid B -p_cid C -p_cid D -p_cid E -p_cid F -p_seq complex_seq.txt -p_tpt template.pdb
```

 **4.3 CaSR (PDB ID: 8WPU)** 

​​Generate AMBER parameters for ligands PO4/YP4:​​

```
cp your_path/mp_build_v10/scripts/make_nonaa_lig/make_lig_v6.pl ./
perl make_lig_v6.pl -pdb PO4.pdb -mol2 PO4.mol2 -name PO4 -gau g16 -np 1 -ac -3
cp PO4.prepin PO4.lib PO4.frcmod your_path/mp_build_v10/databases/nonaa/

perl make_lig_v6.pl -pdb YP4.pdb -mol2 YP4.mol2 -name YP4 -gau g16 -np 6 -ac 0
cp YP4.prepin YP4.lib YP4.frcmod your_path/mp_build_v10/databases/nonaa/
```

​​Build system with peptides/ligands:​​

```
cp your_path/mp_build_v10/build.sh ./
bash build.sh -p_com 8WPU.pdb -m_path your_path/mp_build_v10 -p_tmm A -p_tmm B -p_cid A -p_cid B -p_cid D -p_cid G -p_cid C -p_seq complex_seq.txt -p_tpt template.pdb \
  -c_lig CA1.pdb -c_lig CA2.pdb -c_lig CA3.pdb -c_lig CA4.pdb -c_lig PO4A_m.pdb -c_lig PO4B_m.pdb \
  -c_pep TRPA.pdb -c_pep TRPB.pdb -c_lig YP4A_m.pdb -c_lig YP4B_m.pdb
```

 **4.4 GABA_B_R (PDB ID: 7EB2)** 

​​Generate AMBER parameters for ligand 2C0:​​

```
cp your_path/mp_build_v10/scripts/make_nonaa_lig/make_lig_v6.pl ./
perl make_lig_v6.pl -pdb 2C0.pdb -mol2 2C0.mol2 -name 2C0 -gau g16 -np 6 -ac 0
cp 2CO.prepin 2CO.lib 2CO.frcmod your_path/mp_build_v10/databases/nonaa/
```

​​Build system:​​

```
cp your_path/mp_build_v10/build.sh ./
bash build.sh -p_com 7EB2.pdb -m_path your_path/mp_build_v10 -p_tmm C -p_tmm D -p_cid C -p_cid D -p_cid A -p_cid B -p_cid Y -p_seq complex_seq.txt -p_tpt template.pdb -c_lig 2CO_m.pdb
```

 **4.5 GCGR_beta (PDB ID: 8JRV)** 

​​Build system:​​

```
cp your_path/mp_build_v10/build.sh ./
bash build.sh -p_com 8JRV.pdb -p_cid R -p_cid A -p_cid G -p_tmm R -m_path your_path/mp_build_v10/ -w_inh 0 -p_seq complex_seq.txt -p_tpt template.pdb
```

 **4.6 GCGR_Gi (PDB ID: 6LML)** 

​​Build system:​​

```
cp your_path/mp_build_v10/build.sh ./
bash build.sh -p_com 6LML.pdb -m_path your_path/mp_build_v10 -p_tmm R -p_cid R -p_cid A -p_cid B -p_cid C -p_cid E -p_seq complex_seq.txt -p_tpt template.pdb
```

 **4.7 GPR97 (PDB ID: 7D76)** 

​​Generate AMBER parameters for ligand GXR:​​

```
cp your_path/mp_build_v10/scripts/make_nonaa_lig/make_lig_v6.pl ./
perl make_lig_v6.pl -pdb GXR_raw.pdb -mol2 GXR_raw.mol2 -name GXR -gau g16 -ac 0 -np 10
cp GXR.prepin GXR.lib GXR.frcmod your_path/mp_build_v10/databases/nonaa/
```

​​Build system:​​

```
cp your_path/mp_build_v10/build.sh ./
bash build.sh -p_com 7D76.pdb -m_path your_path/mp_build_v10 -p_tmm R -p_cid R -p_cid A -p_cid B -p_cid G -p_seq complex_seq.txt -p_tpt template.pdb -c_lig GXR.pdb
```

 **4.8 TRPV1 (PDB ID: 8X94)** 

​​Generate AMBER parameters for ligand EZI:​​

```
cp your_path/mp_build_v10/scripts/make_nonaa_lig/make_lig_v6.pl ./
perl make_lig_v6.pl -pdb EZl.pdb -mol2 EZl.mol2 -name EZl -gau g16 -np 6 -ac 0
cp EZI.prepin EZI.lib EZI.frcmod your_path/mp_build_v10/databases/nonaa/
```

​​Build system:​​

```
cp your_path/mp_build_v10/build.sh ./
bash build.sh -p_com 8X94.pdb -m_path your_path/mp_build_v10 -p_tmm A -p_tmm B -p_tmm C -p_tmm D -p_cid A -p_cid B -p_cid C -p_cid D \
  -c_lig EZIA_m.pdb -c_lig EZIB_m.pdb -c_lig EZIC_m.pdb -c_lig EZID_m.pdb -p_seq complex_seq.txt -p_tpt template.pdb
```

 **4.9 GPR68 (PDB ID: 9BI6)** 

​​Generate transmembrane cavity water:​​

```
bash build.sh -m_path your_path/mp_build_v10 -p_com 9bi6_gq.pdb -p_tmm R -p_cid R -p_tpt template.pdb -p_seq complex_seq.txt -w_inh 1
```

​​Build system with cavity water:​​

```
bash build.sh -m_path your_path/mp_build_v10 -p_com 9bi6_gq.pdb -p_tmm R -p_cid R -p_cid A -p_cid B -p_cid G -p_tpt template.pdb -p_seq complex_seq.txt -w_inh wats_inhole_del_2.pdb
```

 **4.10 SSTR2 (PDB ID: 7XAU)** 

​​Generate AMBER parameters for non-standard residue TOH of octreotide:​​

```
cp your_path/mp_build_v10/scripts/make_nonaa_lig/make_nonaa_ct_v6.pl ./
perl make_nonaa_ct_v6.pl -pdb TOH_rename_min.pdb -mol2 TOH_rename_min_nocap.mol2 -name TOH -gau g16 -np 8 -ac 0
cp TOH.prepin TOH.lib TOH.frcmod your_path/mp_build_v10/databases/nonaa/
```

​​Generate cavity water and build system:​​

```
cp your_path/mp_build_v10/build.sh ./
bash build.sh -p_com 7xau_sstr2_Oct.pdb -p_seq complex_seq.txt -p_tpt template.pdb -p_cid A -p_tmm A -c_pep oct_min_align.pdb -m_path your_path/mp_build_v10
bash build.sh -p_com 7xau_sstr2_Oct.pdb -p_seq complex_seq.txt -p_tpt template.pdb -p_cid A -p_tmm A -c_pep oct_min_align.pdb -m_path your_path/mp_build_v10 -w_inh wats_inhole_del_2.pdb
```

 **4.11 SSTR5 (PDB ID: 8ZBE)** 

​​Build system with predefined cavity water:​​

```
cp your_path/mp_build_v10/build.sh ./
bash build.sh -p_com 8zbe_sstr5_oct.pdb -p_seq complex_seq.txt -p_tpt template.pdb -p_cid A -p_tmm A -c_pep oct_min_align.pdb -m_path your_path/mp_build_v10 -w_inh wats_inhole_del_2.pdb
```


 The case file is located at the path your_path/mp_build_v10/sample. The above commands are documented within the file 0step.txt The constructed AMBER and CHARMM systems are located in the traj_1 and traj_namd_1 directories, respectively.

 **4.12 Binding Analysis** 

Calculate MM-PBSA binding free energy 
```
perl run_mmpbsa_v6.pl \  
  -r 1 286 \              # Receptor residues number from 1 to 286  
  -l 287 294 \            # Ligand residues number from 287 294
  -y 06_Prod_1.nc \   # Production trajectory  
  -p system_start.prmtop \  #Initial topology file of AMBER systems.
  -c system_start.inpcrd \  	#Initial structure file of CHARMM systems 
  -m 1                    # Membrane system flag  
```
________________________________________

## 5. Advanced Implementation Notes

 **5.1 High-Throughput Optimization** 
 
For virtual screening applications:
1.	Perform initial structural repair with -w_inh 1
2.	Save cavity water PDB files
3.	Reuse hydration files (-w_inh waters.pdb) for homologous systems
4.	Leverage decomposed domain PDBs for sub-minute system reconstruction

 **5.2 Computational Efficiency** 
•	Structural Repair: 17-273 minutes (system-dependent)

All MPBuild-repaired structures demonstrate:
•	Heavy-atom RMSD ≤ 0.8 Å versus experimental structure


## Note
Currently, MPBuild_v10 does not support the construction of systems with non-standard residues based on the CHARMM force field.
The supported phospholipid types in MPBuild_v10 are continuously expanding.
