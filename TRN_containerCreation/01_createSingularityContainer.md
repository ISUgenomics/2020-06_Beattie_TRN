
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
