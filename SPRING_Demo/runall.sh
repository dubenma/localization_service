#!/bin/bash
#SBATCH  --mem=128G
<<<<<<< Updated upstream
<<<<<<< HEAD
#SBATCH --time=0-35:00:00
=======
#SBATCH --time=0-45:00:00
>>>>>>> d3788b04951a8d1fceb00825391fc727f095766c
=======
#SBATCH --time=0-35:00:00
>>>>>>> Stashed changes
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-gpu=16
#SBATCH --job-name=Tervenapeaset_%j.log

__conda_setup="$('/opt/apps/software/Anaconda3/2020.02/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
	echo Pruser
	exit 1
    if [ -f "/opt/apps/software/Anaconda3/2020.02/etc/profile.d/conda.sh" ]; then
        . "/opt/apps/software/Anaconda3/2020.02/etc/profile.d/conda.sh"
    else
        export PATH="/opt/apps/software/Anaconda3/2020.02/bin:$PATH"
    fi
fi
unset __conda_setup 


nvidia-smi
#conda init bash
source activate inlocul
type -a python
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/seberma3/gflags-2.2.2/build/lib:/home/seberma3/InLoc_demo/functions/vlfeat/toolbox/mex/mexa64:/home/seberma3/.conda/envs/inlocul/lib
which python

set -e
ml purge
ml load MATLAB 
ml load SuiteSparse/5.1.2-foss-2018b-METIS-5.1.0
ml load LLVM/6.0.0-GCCcore-7.3.0
ml load CUDA
module load CUDA/9.1.85
module load cuDNN/7.0.5-CUDA-9.1.85

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/lucivpav/gflags-2.2.2/build/lib:/home/lucivpav/InLoc_demo/functions/vlfeat/toolbox/mex/mexa64:/home/seberma3/.conda/envs/inlocul/lib
matlab -batch inloc_demo