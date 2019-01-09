#!/bin/bash

### Arguements
### 1) Binary 2) Process 3) Param 4) Run Card 5) Delphes Card 6) process number

echo "================================================================"
echo "=========================== WELCOME! ==========================="
hostname
pwd
whoami
/bin/ls -ltrh

echo "================================================================"
echo "================================================================"
echo "Setting up the environment (mostly empty for now)"
bin=${1}
process=${2}
param=${3}
run=${4}
delphes=${5}
jobNo=${6}
# Print config
echo -e "\tJob Number:   ${jobNo}"
echo -e "\tBin:          ${bin}"
echo -e "\tGene Process: ${process}"
echo -e "\tParam Card:   ${param}"
echo -e "\tRun Card:     ${run}"
echo -e "\tDelphes Card: ${delphes}"

### Re-construct the job name
runC=${run##*/}
runC=${runC%.*}
#
processC=${process##*/}
processC=${processC%.*}
#
paramC=${param##*/}
paramC=${paramC%.*}
#
delphesC=${delphes##*/}
delphesC=${delphesC%.*}
#
jobName="${processC}_${paramC}_${runC}_${delphesC}.${jobNo}"
# Dummy PROC name so that I can find it later
dummyName="PROC_HAZ"

### Make the MG5 job configuration and print it
echo "================================================================"
echo "================================================================"
echo "Preparing MG job script"
jobScript=${PWD}/mg5Job.${jobNo}.mg5
cat ${process} > ${jobScript}
echo "output ${dummyName}" >> ${jobScript}
echo "launch ${dummyName}" >> ${jobScript}
echo "shower=Pythia8" >> ${jobScript}
echo "detector=Delphes" >> ${jobScript}
if [ ${param} != "SM" ]; then
    echo ${param} >> ${jobScript}
fi
echo ${run} >> ${jobScript}
echo "set iseed $((1222*(1+jobNo)))" >> ${jobScript}
echo ${delphes} >> ${jobScript}
echo "" >> ${jobScript}
echo ">>>"
cat ${jobScript}
echo ">>>"

### DO IT!
echo "================================================================"
echo "================================================================"
echo "Running MG5"
echo "Running: ${bin} ${jobScript}"
${bin} ${jobScript}
echo ">>>> DONE!"

### Still todo really
echo "================================================================"
echo "================================================================"
echo "Post Processing"
# Extract the LHE files, etc (wildcard the run dir, just in case)
echo "Moving event outputs..."
mv -v ${dummyName}/Events/*/unweighted_events.lhe.gz      ./unweighted_events.${jobNo}.lhe.gz
mv -v ${dummyName}/Events/*/tag_1_pythia8_events.hepmc.gz ./pythia8_events.${jobNo}.hepmc.gz
mv -v ${dummyName}/Events/*/tag_1_delphes_events.root     ./delphes_events.${jobNo}.root
# tar/zip the remains in the PROC dir
echo "Tar'ing the PROC directory..."
tar czvf ${jobName}.tar.gz ${dummyName}
echo "Final snapshot of workdir:"
/bin/ls -ltrh
echo "================================================================"
echo "================================================================"
echo "DONE! GOODBYE"
