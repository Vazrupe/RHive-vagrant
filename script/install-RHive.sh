#!/bin/sh

R CMD javareconf
R -e "chooseCRANmirror(ind=16); install.packages(c('rJava', 'Rserve'))"

git clone https://github.com/nexr/RHive.git
cd RHive

ant build
R CMD build RHive
R CMD INSTALL RHive_*.tar.gz

cd ..
rm -rf RHive