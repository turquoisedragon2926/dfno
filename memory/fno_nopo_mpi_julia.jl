# source $HOME/.bash_profile
# mpiexecjl --project=./ -n <number_of_tasks> julia examples/scaling/scaling.jl
# mpiexecjl --project=./ -n 1 julia examples/scaling/gradient_scaling.jl 1 1 1 10 10 10 5

using Pkg
Pkg.activate("./")

# include("../src/models/DFNO_3D/DFNO_3D.jl")
# include("../src/utils.jl")

# using .DFNO_3D
# using .UTILS
using MPI
using Zygote
using DrWatson
using CUDA
using Flux
using LinearAlgebra

MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)

nx, ny, nz, nt = parse.(Int, ARGS[1:4])
T = Float32

x = rand(T, 5, nx*ny*nz*nt)
y = rand(T, 1, nx*ny*nz*nt)

weights = Dict(
    :w1 => rand(T, 20, 5),
    :w2 => rand(T, 128, 20),
    :w3 => rand(T, 1, 128)
)
# After initializing the GPU
gpu_id = CUDA.device()
total_mem = CUDA.total_memory()
free_mem = CUDA.free_memory()
used_mem = total_mem - free_mem

x = x |> gpu
y = y |> gpu
weights = Dict(k => gpu(v) for (k, v) in pairs(weights))

# Printing the GPU ID and memory usage for each task
println("Task on GPU ID on $rank: $gpu_id")
println("Total GPU Memory on $rank: $total_mem bytes")
println("Free GPU Memory on $rank: $free_mem bytes")
println("Used GPU Memory on $rank: $used_mem bytes")

function forward(weights, x)
    w1, w2, w3 = weights[:w1], weights[:w2], weights[:w3]
    return norm(relu.(w3 * relu.(w2 * (w1 * x))) - y)
end

forward(weights, x)
gradient_weights = Zygote.gradient(weights -> forward(weights, x), weights)

MPI.Finalize()
