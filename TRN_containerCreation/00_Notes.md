# Notes

This notebook contains instructions on how to recreate the container from scratch.

## Installed the latest version of vagrant

* 06/19/2020
* https://www.vagrantup.com/downloads.html

The version I had was so out of date I needed to reinstall plugins

```
vagrant plugin expunge --reinstall
```

Start the virtual machine.

```
vagrant init singularityware/singularity-2.4
vagrant up
vagrant ssh
```


## Create a recipe file

```



Bootstrap:docker
From:centos:7

%labels
MAINTAINER severin@iastate.edu

$help
echo "This container contains a runscript for snpPhylo"

%environment
source /etc/profile.d/modules.sh
SPACK_ROOT=/opt/spack
export SPACK_ROOT
export PATH=$SPACK_ROOT/bin:$PATH
source $SPACK_ROOT/share/spack/setup-env.sh
export PATH=$SPACK_ROOT/isugif/snpPhylo/bin:$SPACK_ROOT/isugif/snpPhylo/wrappers:$PATH
#for d in /opt/spack/opt/spack/linux-centos7-sandybridge/gcc-4.8.5/*/bin; do export PATH="$PATH:$d"; done


module load meme-4.12.0-gcc-4.8.5-no7hbxx
module load perl-5.30.3-gcc-4.8.5-bzlnqjd
module load blast-plus-2.9.0-gcc-4.8.5-j2qz76m
module load mcl-14-137-gcc-4.8.5-tiabgt7

%post
export SPACK_ROOT=/opt/spack
export SPACK_ROOT
export PATH=$SPACK_ROOT/bin:$PATH

yum -y install git python \
gcc gcc-c++ gcc-gfortran curl \
gnupg2 sed patch \
unzip gzip bzip2 \
findutils make vim \
environment-modules

yum clean all


if [ ! -d "$SPACK_ROOT" ]; then
  git clone https://github.com/spack/spack.git $SPACK_ROOT
  spack compiler find $(which gcc)
  spack compiler find $(which g++)
  spack compiler find $(which gfortran)

  #because i'm buildiing as root
  export FORCE_UNSAFE_CONFIGURE=1

  source $SPACK_ROOT/share/spack/setup-env.sh
  spack install java
  spack install meme
#  spack install blast-plus
  spack install mcl
  spack install perl
fi




%runscript
#echo "This container contains a runscript for snpPhylo"
#exec java integrate "$@"

```


## Build the image

```
sudo singularity build test.simg recipe
```


## Manual install of a couple problemmatic programs

Had some difficulty having spack install blast-plus and mysql so commented them out in the recipe file and will add them manually as follows




## find the vagrant machine that I am running singuluarity on and transfer the file

```
vagrant global-status
id       name    provider   state   directory                                    
---------------------------------------------------------------------------------
eb60097  default virtualbox running /Users/severin/singularity/singularity-vmTRN
```

```
vagrant scp eb60097:/home/vagrant/test.simg .
```



## How to increase the size of the Vagrant VM

[increase disk size](https://medium.com/@thucnc/how-to-increase-disk-size-on-a-vagrant-vm-using-virtualbox-c3d24acee3f4)

That didn't work instead I created a sandbox

```
sudo singularity build --sandbox test/ test2.simg
sudo singularity shell --writable test
```

## convert back to an image.
```
singularity build test3.simg test/
```

## Install MySQL manually as spack installation doesn't work

* https://dev.mysql.com/doc/mysql-installation-excerpt/5.7/en/binary-installation.html

```
yum install libaio
yum install mysql
yum install java
yum install java-sdk

mysql --version
mysql  Ver 15.1 Distrib 5.5.65-MariaDB, for Linux (x86_64) using readline 5.1

Installed:
  java-1.8.0-openjdk.x86_64 1:1.8.0.252.b09-2.el7_8    

perl --version
This is perl 5, version 16, subversion 3 (v5.16.3) built for x86_64-linux-thread-multi
(with 40 registered patches, see perl -V for more detail)

```

* 06/26/2020
overcame error `cannot find static libstdc++`  [here](https://github.com/rordenlab/dcm2niix/issues/137)

```
yum install libstdc++-static
spack install blast-plus

```


## install Integrate

* 06/30/2020

```
yum install wget
cd /opt
wget https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4344238/bin/pcbi.1004103.s024.zip
unzip pcbi.1004103.s024.zip
mv S1\ Dataset/ S1
cd /opt/S1/Integrate_v1.0
javac Integrate.java


```

## make it so it runs as a jar file

```
jar -cvf Integrate.jar Integrate.class   #create the jar file so you don't have to run it inside the folder
echo "Manifest-version: 1.0" > manifest.mf
echo "Main-Class: Integrate" >> manifest.mf
jar cfm Integrate.jar manifest.mf Integrate.class
```

Works if you have the bin folder and the Parameters file at least within the container.  Need a test dataset to verify mysql is working.

```
sudo singularity exec --bind $PWD ../test java -jar /opt/S1/Integrate_v1.0/Integrate.jar
```

```
sudo singularity shell --writable test
yum whatprovides service
yum install initscripts-9.49.49-1.el7.x86_64
yum install mariadb-server
systemctl enable mariadb
mysqld_safe --user=root &
```


```
%files
/home/vagrant/Imam/Data /root
```


```
sudo singularity exec --bind $PWD ../test2 java -jar /opt/S1/Integrate_v1.0/Integrate.jar
```


```
sudo singularity build --sandbox test/ test3
sudo singularity shell --writable test3
```


```
mysqladmin -u root password 'password'
mysqladmin -u root -h vagrant password 'password' -ppassword


```

This got me passed the last error of `Exception in thread "main" java.lang.NoClassDefFoundError: bin/initialize`

```
sudo singularity exec --bind $PWD ../test3 java -cp ".:/opt/S1/Integrate_v1.0/" Integrate
```


## Blast is legacy blast

Needs the blastall command not blast-plus.  Found a place to download it.

```
  cd /usr
  wget https://anaconda.org/biocore/blast-legacy/2.2.26/download/linux-64/blast-legacy-2.2.26-2.tar.bz2
  tar -jxvf blast-legacy-2.2.26-2.tar.bz2
```


## New error

07/01/2020

```
Running orthomcl...... (This may take a while depending on the number and sizes of your genomes...)
java.io.FileNotFoundException: Results/Miscellaneous/Orthologous_groups.txt (No such file or directory)
	at java.io.FileInputStream.open0(Native Method)
	at java.io.FileInputStream.open(FileInputStream.java:195)
	at java.io.FileInputStream.<init>(FileInputStream.java:138)
	at java.io.FileInputStream.<init>(FileInputStream.java:93)
	at java.io.FileReader.<init>(FileReader.java:58)
	at Integrate.main(Integrate.java:272)

```

## try executing commands after blastall that finished successfully in bin/commands

```sudo singularity exec --bind $PWD ../test3 ./test.sh
Connecting to localhost
Selecting database orthomcl
Loading data from LOCAL file: /home/vagrant/Imam/Data/Proteomes/SimilarSequences.txt into SimilarSequences
orthomcl.SimilarSequences: Records: 3779866  Deleted: 0  Skipped: 0  Warnings: 0
Disconnecting from localhost
Can't locate DBI.pm in @INC
```


## Add DBI to perl
```
source /environment
perl -MCPAN -e 'install DBI'
```

## Try commands again


```
sudo singularity exec --bind $PWD ../test3 ./test.sh
Can't locate DBD/mysql.pm
```

Fix

Requried the installation of mariadb-devel too [solution](https://stackoverflow.com/posts/56358362/edit)

```
yum -y install mariadb-devel #added already
perl -MCPAN -e 'install DBD::mysql
```

## Success!

```
sudo singularity exec --bind $PWD ../test3 ./test.sh
[mcl] jury pruning marks: <99,99,99>, out of 100
[mcl] jury pruning synopsis: <99.0 or perfect> (cf -scheme, -do log)
[mcl] output is in Results/Miscellaneous/mclOutput
[mcl] 7105 clusters found
[mcl] output is in Results/Miscellaneous/mclOutput
```

I don't see the motif results though.  Going to run through the Integrate program from the beginning and see if it completes.


## Still more errors

* 07/01/2020

```
sudo singularity exec --bind $PWD ../test3 java -cp ".:/opt/S1/Integrate_v1.0/" Integrate

Run started at :Wed Jul 01 19:16:59 UTC 2020
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
java.io.FileNotFoundException: Results/Motif_finding/tomtom_out/tomtom.txt (No such file or directory)
	at java.io.FileInputStream.open0(Native Method)
	at java.io.FileInputStream.open(FileInputStream.java:195)
	at java.io.FileInputStream.<init>(FileInputStream.java:138)
	at java.io.FileInputStream.<init>(FileInputStream.java:93)
	at java.io.FileReader.<init>(FileReader.java:58)
	at bin.Tomtom_parse.parse(Tomtom_parse.java:21)
	at Integrate.main(Integrate.java:395)
java.io.FileNotFoundException: Results/Miscellaneous/mclOut2.txt (No such file or directory)
	at java.io.FileInputStream.open0(Native Method)
	at java.io.FileInputStream.open(FileInputStream.java:195)
	at java.io.FileInputStream.<init>(FileInputStream.java:138)
	at java.io.FileInputStream.<init>(FileInputStream.java:93)
	at java.io.FileReader.<init>(FileReader.java:58)
	at bin.Merge_motifs2.merge(Merge_motifs2.java:21)
	at Integrate.main(Integrate.java:413)
Error while merging motifs... Exiting

```

## Full dataset

* 07/01/2020
* Vagrant VM

Decided to run on the full dataset in case there was an error because there wasn't enough information.

```
Run started at :Wed Jul 01 21:37:39 UTC 2020
Extracting IGRs...
Calculating bg distribution......
Running orthomcl...... (This may take a while depending on the number and sizes of your genomes...)
Parsing gff......
Running MEME......
Finished reading sequences...
Making FASTA directory
Eligible groups : 2160
Running mast analysis with phylo motifs...
Running MEME...
Running tomtom analysis...
java.io.FileNotFoundException: Results/Motif_finding/tomtom_out/tomtom.txt (No such file or directory)
	at java.io.FileInputStream.open0(Native Method)
	at java.io.FileInputStream.open(FileInputStream.java:195)
	at java.io.FileInputStream.<init>(FileInputStream.java:138)
	at java.io.FileInputStream.<init>(FileInputStream.java:93)
	at java.io.FileReader.<init>(FileReader.java:58)
	at bin.Tomtom_parse.parse(Tomtom_parse.java:21)
	at Integrate.main(Integrate.java:395)
java.io.FileNotFoundException: Results/Miscellaneous/mclOut2.txt (No such file or directory)
	at java.io.FileInputStream.open0(Native Method)
	at java.io.FileInputStream.open(FileInputStream.java:195)
	at java.io.FileInputStream.<init>(FileInputStream.java:138)
	at java.io.FileInputStream.<init>(FileInputStream.java:93)
	at java.io.FileReader.<init>(FileReader.java:58)
	at bin.Merge_motifs2.merge(Merge_motifs2.java:21)
	at Integrate.main(Integrate.java:413)
Error while merging motifs... Exiting
```

Still have the same error.  going to make a back up of these folders and see if I can figure out where the error is coming from.


There is no tomtom directory, so no output for tomtom.  But tom tom runs.


I am wondering if it can't find the class paths for the other classes in the bin folder. perhaps I need to add that folder  

```
sudo singularity exec --bind $PWD ../test3 java -cp ".:/opt/S1/Integrate_v1.0/:/opt/S1/Integrate_v1.0/bin/:/opt/S1/Integrate_v1.0/bin/src/" Integrate
```

* /07/04/2020

I got ahold of the author, Saheed Imam, and have been communicating with him but it is hard when he can't see directly what is going on.  I will continue to communicate what is going on as I test out a few more ideas.

I haven't been able to find a way to add these classes into the path so they will work, so I am going to try to directly softlink them into the fold that the integrate.class file is located and see if that works.

```
sudo singularity shell --bind $PWD --writable ../test3
ls bin/*class | xargs -I xx ln -s xx
exit
sudo singularity exec --bind $PWD ../test3 java -cp ".:/opt/S1/Integrate_v1.0/:/opt/S1/Integrate_v1.0/bin/:/opt/S1/Integrate_v1.0/bin/src/" Integrate

```

That didn't work and in fact at the top of the integrate.java script there is an import bin.* which I think is importing the classes from the bin directory.  

Looks like he was using java 1.72, I am using 1.8 and he has some precompiled classes in the bin folder that are not running.  I am going to recompile them and see if that will make it work.  Ie, compiling the classes that are used using the 1.8 compiler may make a difference.

```
sudo singularity shell --bind $PWD --writable ../test3
cd /opt/S1/Integrate_v1.0/bin
javac *.java
mv *.class /opt/S1/Integrate_v1.0/
exit
```

That failed. I guess I will try changing the singularity recipe to use an earlier version of java


```
yum remove java-1.8.0-openjdk-headless.x86_64

yum install java-1.7.0-openjdk-1.7.0.251-2.6.21.1.el7.x86_64
yum install java-1.7.0-openjdk-devel-1.7.0.251-2.6.21.1.el7.x86_64
cd /opt/S1/Integrate_v1.0/bin/src
javac *.java
mv *.class ..
cd /opt/S1/Integrate_v1.0
javac Integrate.java
exit
sudo singularity exec --bind $PWD ../test3 java -cp ".:/opt/S1/Integrate_v1.0/" Integrate
```

I was able to use the writable version of the singularity container to remove the java verion 1.8 and replace it with java version 1.7 then I recompiled all of the Integrate java class functions before restarting.


* 07/04/2020

Testing if there is a problem with this file

*

Changed this line to look at the 7th column instead of the 4th

```
if(Double.parseDouble(result[4])>900.0)// only consider motifs with a match score of upto 900 (hits below this are often bogus)

if(Double.parseDouble(result[7])>900.0)// only consider motifs with a match score of upto 900 (hits below this are often bogus)
sudo singularity exec --bind $PWD ../test3 java -cp ".:/opt/S1/Integrate_v1.0/" Integrate

Singularity test3:/opt/S1/Integrate_v1.0/bin/src> javac Motif_bindsite_overlap.java
mv Motif_bindsite_overlap.class ..
exit
sudo singularity exec --bind $PWD ../test3 java -cp ".:/opt/S1/Integrate_v1.0/" Integrate
Run started at :Sun Jul 05 02:53:41 UTC 2020
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
java.io.FileNotFoundException: Results/Motif_finding/tomtom_out/tomtom.txt (No such file or directory)
	at java.io.FileInputStream.open(Native Method)
	at java.io.FileInputStream.<init>(FileInputStream.java:146)
	at java.io.FileInputStream.<init>(FileInputStream.java:101)
	at java.io.FileReader.<init>(FileReader.java:58)
	at bin.Tomtom_parse.parse(Tomtom_parse.java:21)
	at Integrate.main(Integrate.java:395)
java.io.FileNotFoundException: Results/Miscellaneous/mclOut2.txt (No such file or directory)
	at java.io.FileInputStream.open(Native Method)
	at java.io.FileInputStream.<init>(FileInputStream.java:146)
	at java.io.FileInputStream.<init>(FileInputStream.java:101)
	at java.io.FileReader.<init>(FileReader.java:58)
	at bin.Merge_motifs2.merge(Merge_motifs2.java:21)
	at Integrate.main(Integrate.java:413)
Error while merging motifs... Exiting
```

* 07/05/2020
* severin@laptop ~/singularity/singularity-vmTRN
The author suggests installing `meme 4.10.1` as the mast output has changed in `meme 4.12.0`


```
cd /opt
wget http://meme-suite.org/meme-software/4.10.1/meme_4.10.1_4.tar.gz
tar -zxvf meme_4.10.1_4.tar.gz
cd meme_4.10.1
./configure --prefix=$HOME/meme --with-url=http://meme-suite.org/ --enable-build-libxml2 --enable-build-libxslt
make
make install

#place this in /environment file
export PATH=$HOME/meme/bin:$PATH
```

looks like Meme 4.10 installed successfully.

```
sudo singularity exec --bind $PWD ../test3 java -cp ".:/opt/S1/Integrate_v1.0/" Integrate
Run started at :Sun Jul 05 13:11:51 UTC 2020
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
java.io.FileNotFoundException: bin/DISTILLER-V2/Data/DISTILLER_matrix.txt (No such file or directory)
at java.io.FileOutputStream.open(Native Method)
at java.io.FileOutputStream.<init>(FileOutputStream.java:221)
at java.io.FileOutputStream.<init>(FileOutputStream.java:110)
at java.io.FileWriter.<init>(FileWriter.java:63)
at bin.DISTILLER_motif_matrix.build(DISTILLER_motif_matrix.java:27)
at Integrate.main(Integrate.java:475)
Error: Exiting run...
```

It got past Meme and tomtom this is on the very small dataset keep in mind no the full dataset. looks like it is looking for a DISTILLER_matrix.txt file now.



### Need to make sure that the Data folder exists

```
mkdir bin/DISTILLER-V2/Data
```

Got past that step now new error

```
Run started at :Sun Jul 05 13:47:36 UTC 2020
Extracting IGRs...
Calculating bg distribution......
Running orthomcl...... (This may take a while depending on the number and sizes of your genomes...)
Parsing gff......
Running MEME......
Finished reading sequences...
Making FASTA directory
Eligible groups : 2160
Running mast analysis with phylo motifs...
Running MEME...
Running tomtom analysis...
Running MEME...
Running tomtom analysis...
Running gene set enrichment analysis (GO)...
Number of ORFs (genes) : 4140
Number clusters with significant GO terms : 436
Building motif matrix for DISTILLER
Normalizing expression matrix...
Running DISTILLER...
java.io.FileNotFoundException: bin/DISTILLER-V2/outputInitial.m (No such file or directory)
	at java.io.FileInputStream.open(Native Method)
	at java.io.FileInputStream.<init>(FileInputStream.java:146)
	at java.io.FileInputStream.<init>(FileInputStream.java:101)
	at java.io.FileReader.<init>(FileReader.java:58)
	at Integrate.main(Integrate.java:498)
```


## Rebuild the image with all the changes.

```
sudo singularity build Integrate.simg recipeF
```


So was able to get it to build but without mysql fully functioning.  Had to do the following after the container was built for it to be running


#### create the sandbox

```
sudo singularity build --sandbox IntegrateSandbox Integrate.simg
```

```
sudo singularity shell --writable IntegrateSandbox/
kill -9 32442
root     32442     1  0 18:15 pts/1    00:00:06 /usr/libexec/mysqld --user=root
systemctl enable mariadb
mysqld_safe --user=root &
mysqladmin -u root password 'password'
mysqladmin -u root -h vagrant password 'password' -ppassword
perl -MCPAN -e 'install DBI'
perl -MCPAN -e 'install DBD::mysql
```

#### testing to see if it worked
```
sudo singularity exec --bind $PWD ../IntegrateSandbox java -cp ".:/opt/S1/Integrate_v1.0/" Integrate
Run started at :Mon Jul 06 21:40:10 UTC 2020
Extracting IGRs...
Calculating bg distribution......
Running orthomcl...... (This may take a while depending on the number and sizes of your genomes...)
Orthomcl analyses failed... Check error output and make necessary modifications

```

* 07/07/2020

See 01_createSignularityContainer for final steps that worked.


#### get the container sandbox off the vagrant VM and upload to box.
```
vagrant sudo-rsync -avz eb60097:/home/vagrant/IntegrateSandbox .
tar -cvfz IntegrateSandbox.tar.gz IntegrateSandbox/

tar: Can't open `shadow-': Permission denied
tar: Error exit delayed from previous errors.
```

I am worried that this may not be the full folder or that it didn't zip properly.  May need to create it directly on the machine they are going to use it on.


#### get some of the other files

```
vagrant sudo-rsync eb60097:/home/vagrant/Imam/Parameters.txt Parameters.small

```
