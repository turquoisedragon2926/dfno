## Running on Perlmutter things

1. https://docs.nersc.gov/development/languages/julia/
2. https://stackoverflow.com/questions/30555225/how-to-upgrade-julia-to-a-new-release `updateJulia("1.8.5", systemwide=false)`
3. julia-1.8
4. ENV["PYTHON"] = "/global/common/software/nersc/pe/conda-envs/23.10.0/python-3.11/nersc-python/bin/python"
5. scp -i ~/.ssh/nersc richardr@dtn01.nersc.gov:/code/dfno/plots/DFNO_3D/myfile.txt /local/path
6. `ssh richardr@dtn01.nersc.gov tar cz /pscratch/sd/r/richardr/dfno/plots/DFNO_3D | tar zxv -C /Users/richardr2926/Desktop/Research/Code/dfno/plots/DFNO_3D`
7. `ssh -l richardr -i ~/.ssh/nersc perlmutter.nersc.gov`
8. 6. `ssh -l richardr -i ~/.ssh/nersc perlmutter.nersc.gov tar cz /pscratch/sd/r/richardr/dfno/plots/DFNO_3D | tar zxv -C /Users/richardr2926/Desktop/Research/Code/dfno/plots/DFNO_3D`

## Creating 1 day keys

1. `~/sshproxy.sh -u richardr`
2. `ssh -l richardr -i ~/.ssh/nersc perlmutter.nersc.gov`

## Move plot folder of DFNO_3D

1. `ssh -l richardr -i ~/.ssh/nersc perlmutter.nersc.gov "cd /pscratch/sd/r/richardr/dfno/plots/ && tar cz DFNO_3D" | tar zxv -C /Users/richardr2926/Desktop/Research/Code/dfno/plots/`
2. `ssh -l richardr -i ~/.ssh/nersc perlmutter.nersc.gov "cd /pscratch/sd/r/richardr/dfno/examples/scaling/ && tar cz results" | tar zxv -C /Users/richardr2926/Desktop/Research/Code/dfno/examples/scaling/`

## Move weights folder of DFNO_3D

1. `ssh -l richardr -i ~/.ssh/nersc perlmutter.nersc.gov "cd /pscratch/sd/r/richardr/dfno/weights/ && tar cz DFNO_3D" | tar zxv -C /Users/richardr2926/Desktop/Research/Code/dfno/weights/`

## Move some samples to test locally

1. `ssh -l richardr -i ~/.ssh/nersc perlmutter.nersc.gov "cd /pscratch/sd/r/richardr/v5/20³ && tar cz FOLDERNAME" | tar zxv -C /Users/richardr2926/Desktop/Research/Code/dfno/data/DFNO_3D/v5/20³`

## Move movies folder of DFNO_3D

1. `ssh -l richardr -i ~/.ssh/nersc perlmutter.nersc.gov "cd /pscratch/sd/r/richardr/dfno/movies/ && tar cz DFNO_3D" | tar zxv -C /Users/richardr2926/Desktop/Research/Code/dfno/movies/`
