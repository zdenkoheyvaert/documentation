#!/bin/bash

version=6.2.8
# IMPORTANT: staging is not cross-mounted, so the baselibs are installed at a
# different location on Tier-1!

# Load modules and set paths for Tier-1 or Tier-2
node=`uname -n`
module purge
if [[ $node == "r0"* ]] || [[ $node == "login"* ]]; then
    echo "Loading modules for Tier-1 (broadwell)..."
    root=/scratch/leuven/projects/lt1_2020_es_pilot/project_input/ldas/GEOSldas_libraries
    module unuse /apps/leuven/broadwell/2016a/modules/all
    module unuse /apps/leuven/broadwell/2018a/modules/all
elif [[ $node == "r1"* ]]; then
    echo "Loading modules for Tier-1 (skylake)..."
    root=/scratch/leuven/projects/lt1_2020_es_pilot/project_input/ldas/GEOSldas_libraries
    module unuse /apps/leuven/skylake/2016a/modules/all
    module unuse /apps/leuven/skylake/2018a/modules/all
else
    echo "Loading modules for Tier-2..."
    root=/staging/leuven/stg_00024/GEOSldas_libraries
    module unuse /apps/leuven/skylake/2018a/modules/all
    module unuse /apps/leuven/cascadelake/2018a/modules/all
    module unuse /apps/leuven/cascadelake/2019b/modules/all
    module use /apps/leuven/skylake/2019b/modules/all
fi
module load foss flex Bison CMake Autotools texinfo

# Download Baselibs from GitHub
cd $root
wget https://github.com/GEOS-ESM/ESMA-Baselibs/releases/download/v${version}/ESMA-Baselibs-v${version}.COMPLETE.tar.xz
tar -xf ESMA-Baselibs-v${version}.COMPLETE.tar.xz
rm -f ESMA-Baselibs-v${version}.COMPLETE.tar.xz
cd ESMA-Baselibs-v${version}/src
mkdir Linux

# Build Baselibs
export FC=gfortran
make install ESMF_COMM=openmpi prefix=$root/ESMA-Baselibs-v${version}/src/Linux

# This is just to check if the installation succeeded for all the modules.
export ESMF_COMM=openmpi
make verify
