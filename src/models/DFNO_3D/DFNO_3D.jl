module DFNO_3D

using MAT
using MPI
using Flux
using JLD2
using HDF5
using FileIO
using PyPlot
using Printf
using Random
using Zygote
using DrWatson
using Parameters
using ProgressMeter
using ParametricOperators

using CUDA

global model_name = "DFNO_3D"
global gpu_flag = parse(Bool, get(ENV, "DFNO_3D_GPU", "0"))
global plot_path = plotsdir(model_name)
gpu_flag && (global gpu = ParametricOperators.gpu)
global cpu = ParametricOperators.cpu

@info "DFNO_3D is using " * (gpu_flag ? "GPU" : "CPU")

include("model.jl")
include("forward.jl")
include("data.jl")
include("train.jl")
include("plot.jl")
include("weights.jl")
include("../../utils.jl")

using .UTILS

export Model, ModelConfig, DataConfig, TrainConfig, initModel, loadData, train, plotLoss, plotEvaluation, loss, saveWeights, loadWeights!, collectWeights, print_storage_complexity, loadDistData, gpu_flag

end
