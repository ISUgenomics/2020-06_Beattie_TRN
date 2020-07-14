# How to use the singularity container.


## Building the container

```
sudo singularity build Integrate4.simg RecipeG
```

## Running the container

The container has a run script that first starts the mysql daemon, installs a couple of perl modules and then runs the Integrate code.

You will need to be in the data directory

* bin folder

```
ls bin
All_motifs_Ecoli            deleteFolder.class                   DISTILLER_parse.class                   gff_parse.class      mast_bash                 MemeParse_forMast.class     Merge_motifs.class            Pfam_TF_results.txt               src                     TF_seq_retrieve.class
AUPR_preprocessing.class    DISTILLER_extend_corr.class          DISTILLER-V2                            GO_descriptions.txt  Mean_SD.class             MemeParse_forTOMTOM2.class  Motif_bindsite_overlap.class  regulator_predict_corr.class      Summary2.class          Tomtom_parse.class
commands                    DISTILLER_extend_corr_operons.class  Extract_upstream_regions_revcomp.class  GO_enrichment.class  meme_bash                 MemeParse_forTOMTOM3.class  orthomcl.config               regulator_predict_distance.class  Summary.class           Unique_interactions.class
CreateFasta_for_MEME.class  DISTILLER_motif_matrix.class         gene_cluster_map.class                  initialize.class     MemeParse_clusters.class  Merge_motifs2.class         orthomclSoftware-v2.0.9       regulator_predict_merge.class     TF_Domain_family.class
```

* Data folder

```
ls Data/
bg  Expression  Genomes  Gffs  GO_terms  IGRs  Operons  Proteomes  TF_domains.txt  TF_protein_seqs.txt  TFs.txt
```

* Parameters.txt file

You will need to modify this file for your genomes of interest or use the testing Parameters.txt file provided in this gitrepo.


## Running the container

```
singularity run --bind $PWD ../Integrate4.simg
```
