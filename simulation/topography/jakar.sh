# Default values
nprocs=40

module load compiler-rt/2024.0.0 ifort/2024.0.0 mpi/2021.13

mkdir -p ./output

fname="topo_1up_100m"
mpirun -np $nprocs ../../build/./waveqlab3d ./input/${fname}.in | tee ./output/${fname}.out

fname="topo_2up_100m"
mpirun -np $nprocs ../../build/./waveqlab3d ./input/${fname}.in | tee ./output/${fname}.out

fname="topo_3up_100m"
mpirun -np $nprocs ../../build/./waveqlab3d ./input/${fname}.in | tee ./output/${fname}.out

fname="topo_4up_100m"
mpirun -np $nprocs ../../build/./waveqlab3d ./input/${fname}.in | tee ./output/${fname}.out

fname="topo_5up_100m"
mpirun -np $nprocs ../../build/./waveqlab3d ./input/${fname}.in | tee ./output/${fname}.out
