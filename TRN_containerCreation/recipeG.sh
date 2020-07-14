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
#mysql
yum -y install initscripts-9.49.49-1.el7.x86_64
yum -y install mariadb-server
yum -y install mariadb-devel
ps -ef | grep mysql
#/usr/libexec/mysqld --user=root &
#systemctl enable mariadb
#mysql_install_db
#/usr/libexec/mysqld --user=root restart &
#cd '/usr' ; /usr/bin/mysqld_safe --datadir='/var/lib/mysql'
ps -ef | grep mysql
#ls /var/lib/mysql/mysql.sock
#mysqladmin -u root password 'password'
#mysqladmin -u root -h vagrant password 'password' -ppassword



yum -y install java-1.7.0-openjdk-1.7.0.251-2.6.21.1.el7.x86_64
yum -y install java-1.7.0-openjdk-devel-1.7.0.251-2.6.21.1.el7.x86_64
yum -y install libstdc++-static
yum -y install wget




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

# required perl packages for it to play nice
#perl -MCPAN -e 'install DBI'
#perl -MCPAN -e 'install DBD::mysql

#install meme 4.10
cd /opt
wget http://meme-suite.org/meme-software/4.10.1/meme_4.10.1_4.tar.gz
tar -zxvf meme_4.10.1_4.tar.gz
cd meme_4.10.1
./configure --prefix=$HOME/meme --with-url=http://meme-suite.org/ --enable-build-libxml2 --enable-build-libxslt
make
make install

## install blast legacy

cd /usr
wget https://anaconda.org/biocore/blast-legacy/2.2.26/download/linux-64/blast-legacy-2.2.26-2.tar.bz2
tar -jxvf blast-legacy-2.2.26-2.tar.bz2

## install Integrate
cd /opt
wget https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4344238/bin/pcbi.1004103.s024.zip
unzip pcbi.1004103.s024.zip
mv S1\ Dataset/ S1

cd /opt/S1/Integrate_v1.0/bin/src
javac *.java  # this recompiles all the classes using this java version
mv *.class ..
cd /opt/S1/Integrate_v1.0
javac Integrate.java

cd /root


#kill -9 21725
#sleep 5
#kill -9 21582
#sleep 5
#ps -ef | grep mysql


## do these commands after
#systemctl enable mariadb
#mysqld_safe --user=root &
#sleep 10
#ps -ef | grep mysql

#mysqladmin -u root password 'password'
#mysqladmin -u root -h vagrant password 'password' -ppassword
# /opt/spack/opt/spack/linux-centos7-sandybridge/gcc-4.8.5/perl-5.30.3-bzlnqjd5cukpm5ud4m3rhf66noiyt7dj/bin/perl -MCPAN -e 'install DBI'
# /opt/spack/opt/spack/linux-centos7-sandybridge/gcc-4.8.5/perl-5.30.3-bzlnqjd5cukpm5ud4m3rhf66noiyt7dj/bin/perl -MCPAN -e 'install DBD::mysql'



%runscript
#echo "This container contains a runscript for Integrate_v1.0"
#exec java -cp ".:/opt/S1/Integrate_v1.0/" Integrate

mysql_install_db
mysqld_safe --user=root &
sleep 10  #Sleep command required to let the mysql daemon to load
echo "installing perl modules"
/opt/spack/opt/spack/linux-centos7-sandybridge/gcc-4.8.5/perl-5.30.3-bzlnqjd5cukpm5ud4m3rhf66noiyt7dj/bin/perl -MCPAN -e 'install DBI'
/opt/spack/opt/spack/linux-centos7-sandybridge/gcc-4.8.5/perl-5.30.3-bzlnqjd5cukpm5ud4m3rhf66noiyt7dj/bin/perl -MCPAN -e 'install DBD::mysql'

mysqladmin -u root password 'password'
mysqladmin -u root -h vagrant password 'password' -ppassword
echo "mysqladmin password updated"
echo "Starting Integrate"
java -cp ".:/opt/S1/Integrate_v1.0/" Integrate
