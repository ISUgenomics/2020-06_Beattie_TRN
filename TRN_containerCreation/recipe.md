```
Bootstrap:docker
From:centos:7

%labels
MAINTAINER severin@iastate.edu

$help
echo "This container contains a runscript for snpPhylo"

%environment
#This section is to set up the environment
source /etc/profile.d/modules.sh #let's us use modules
SPACK_ROOT=/opt/spack
export SPACK_ROOT
export PATH=$SPACK_ROOT/bin:$PATH
source $SPACK_ROOT/share/spack/setup-env.sh
export PATH=$SPACK_ROOT/isugif/snpPhylo/bin:$SPACK_ROOT/isugif/snpPhylo/wrappers:$PATH
export PATH=$HOME/meme/bin:$PATH #installed Meme manually so had to set it in the PATH

# load the modules that we installed with spack
module load perl-5.30.3-gcc-4.8.5-bzlnqjd
module load mcl-14-137-gcc-4.8.5-tiabgt7

%post
export SPACK_ROOT=/opt/spack
export SPACK_ROOT
export PATH=$SPACK_ROOT/bin:$PATH

#Install some useful tools
yum -y install git python \
gcc gcc-c++ gcc-gfortran curl \
gnupg2 sed patch \
unzip gzip bzip2 \
findutils make vim \
environment-modules

#Install all of the dependencies we need that couldn't be installed with spack.
yum -y install libaio
yum -y install mysql
yum -y install java-1.7.0-openjdk-1.7.0.251-2.6.21.1.el7.x86_64
yum -y install java-1.7.0-openjdk-devel-1.7.0.251-2.6.21.1.el7.x86_64
yum -y install libstdc++-static
yum -y install wget

#mysql
yum -y install initscripts-9.49.49-1.el7.x86_64
yum -y install mariadb-server
yum -y install mariadb-devel
systemctl enable mariadb
mysql_install_db
mysqld_safe --user=root &
mysqladmin -u root password 'password'
mysqladmin -u root -h vagrant password 'password' -ppassword

# required perl packages for it to play nice
perl -MCPAN -e 'install DBI'
perl -MCPAN -e 'install DBD::mysql


yum clean all


if [ ! -d "$SPACK_ROOT" ]; then
  git clone https://github.com/spack/spack.git $SPACK_ROOT
  spack compiler find $(which gcc)
  spack compiler find $(which g++)
  spack compiler find $(which gfortran)

  #because i'm buildiing as root
  export FORCE_UNSAFE_CONFIGURE=1

# use spack to install mcl and perl
  source $SPACK_ROOT/share/spack/setup-env.sh
  spack install mcl
  spack install perl

fi


#install meme 4.10
cd /opt
wget http://meme-suite.org/meme-software/4.10.1/meme_4.10.1_4.tar.gz
tar -zxvf meme_4.10.1_4.tar.gz
cd meme_4.10.1
./configure --prefix=$HOME/meme --with-url=http://meme-suite.org/ --enable-build-libxml2 --enable-build-libxslt
make
make install

cd /opt
wget https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4344238/bin/pcbi.1004103.s024.zip
unzip pcbi.1004103.s024.zip
mv S1\ Dataset/ S1

cd /opt/S1/Integrate_v1.0/bin/src
javac *.java  # this recompiles all the classes using this java version
mv *.class ..
cd /opt/S1/Integrate_v1.0
javac Integrate.java

#make it so it runs as a jar file  <- I don't think I need this section
##jar -cvf Integrate.jar Integrate.class   #create the jar file so you don't have to run it inside the folder
##echo "Manifest-version: 1.0" > manifest.mf
##echo "Main-Class: Integrate" >> manifest.mf
##jar cfm Integrate.jar manifest.mf Integrate.class




%runscript
#echo "This container contains a runscript for Integrate_v1.0"
#exec java -cp ".:/opt/S1/Integrate_v1.0/" Integrate

```
