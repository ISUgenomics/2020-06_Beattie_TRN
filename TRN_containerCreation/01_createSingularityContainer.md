
# Instructions to create a Singularity container for Integrate



```
sudo singularity build Integrate2.simg recipeF
```

#### create the sandbox

```
sudo singularity build --sandbox IntegrateSandbox Integrate2.simg
```
```
source /environment
mysql_install_db
mysqld_safe --user=root &


mysqladmin -u root password 'password'
mysqladmin -u root -h vagrant password 'password' -ppassword
perl -MCPAN -e 'install DBI'
perl -MCPAN -e 'install DBD::mysql'
```

#### Test the installation using the test dataset

```
sudo singularity exec --bind $PWD ../IntegrateSandbox java -cp ".:/opt/S1/Integrate_v1.0/" Integrate

Run started at :Tue Jul 07 14:00:23 UTC 2020
Extracting IGRs...
Calculating bg distribution......
Running orthomcl...... (This may take a while depending on the number and sizes of your genomes...)
Parsing gff......
Running MEME......
Finished reading sequences...
Making FASTA directory
Eligible groups : 66
Running mast analysis with phylo motifs...
Running MEME...
Running tomtom analysis...
Running MEME...
Running tomtom analysis...
Running gene set enrichment analysis (GO)...
Number of ORFs (genes) : 4140
Number clusters with significant GO terms : 47
Building motif matrix for DISTILLER
Normalizing expression matrix...
Running DISTILLER...
Running DISTILLER... phase2
Parsing DISTILLER results
Number of unique motifs: 36
Number of unique genes: 219
No. of interactions: 263
No. of motifs: 36
Seed extending...
No. of interactions: 263
No. of motifs: 36
Operon extension (only if valid operon file provided...)
No. of interactions: 487
No. of motifs: 36
Do you have results of your pfam analysis of TF sequences ready, appropriately named and placed in the Data directory? [y/n]: y
Proceeding with analysis...
Running tomtom analysis...
Calculating DBD scores...
Computing distance scores... This may take a while...
Computing correlation scores... This may take a while...
9252	9252	9252	9252
9252	9252	9252	9252	9252
Started corr thread
Calculating R_score...
Number of ORFs (genes) : 4140
Number clusters with significant GO terms : 33
Summarizing...
Run finished at :Tue Jul 07 15:20:27 UTC 2020
```


## convert back to an image.

```
sudo singularity build Integrate.simg IntegrateSandbox/
```


## Test using the singularity image rather than the writable folder

* Execute the following command from the folder that contains the bin and data folder and Parameters.txt file.
```
sudo singularity exec --bind $PWD ../Integrate.simg java -cp ".:/opt/S1/Integrate_v1.0/" Integrate
```

This failed.  For some reason, mysql or some other dependency requires to be in the writable sandbox version of the singularity image for it to work.

bin contains

```
bin
All_motifs_Ecoli             DISTILLER_extend_corr_operons.class     gff_parse.class      meme_bash                   Merge_motifs.class            regulator_predict_distance.class  TF_seq_retrieve.class
AUPR_preprocessing.class     DISTILLER_motif_matrix.class            GO_descriptions.txt  MemeParse_clusters.class    Motif_bindsite_overlap.class  regulator_predict_merge.class     Tomtom_parse.class
commands                     DISTILLER_parse.class                   GO_enrichment.class  MemeParse_forMast.class     orthomcl.config               src                               Unique_interactions.class
CreateFasta_for_MEME.class   DISTILLER-V2                            initialize.class     MemeParse_forTOMTOM2.class  orthomclSoftware-v2.0.9       Summary2.class
deleteFolder.class           Extract_upstream_regions_revcomp.class  mast_bash            MemeParse_forTOMTOM3.class  Pfam_TF_results.txt           Summary.class
DISTILLER_extend_corr.class  gene_cluster_map.class                  Mean_SD.class        Merge_motifs2.class         regulator_predict_corr.class  TF_Domain_family.class
```
