function forward(model::Model, θ, x::Any)

    gpu_flag && (x = x |> gpu)
    # ignore() do
    #     GC.gc(true)
    # end
    x = reshape(x, (Domain(model.lifts), :))
    batch = size(x, 2)

    x = reshape(model.lifts(θ) * x, (model.config.nc_lift, :))
    x = reshape(x + model.biases[1](θ), (:, batch))

    # ignore() do
    #     GC.gc(true)
    # end

    for i in 1:model.config.nblocks
        
        x = reshape((model.sconvs[i](θ) * x) + (model.convs[i](θ) * x), (model.config.nc_lift, :)) + model.sconv_biases[i](θ)
        x = reshape(x, (model.config.nc_lift ÷ model.config.partition[1], model.config.nx ÷ model.config.partition[2], model.config.ny ÷ model.config.partition[3], model.config.nt ÷ model.config.partition[4], :))

        N = ndims(x)
        ϵ = 1f-5

        # ignore() do
        #     GC.gc(true)
        # end

        reduce_dims = collect(2:N)
        scale = batch * model.config.nx * model.config.ny * model.config.nt

        s = sum(x; dims=reduce_dims)
        reduce_mean = ParReduce(eltype(s))
        μ = reduce_mean(s) ./ scale

        s = (x .- μ) .^ 2

        # ignore() do
        #     GC.gc(true)
        # end

        s = sum(s; dims=reduce_dims)
        reduce_var = ParReduce(eltype(s))
        σ² = reduce_var(s) ./ scale

        input_size = (model.config.nc_lift * model.config.nx * model.config.ny * model.config.nt) ÷ prod(model.config.partition)

        x = (x .- μ) ./ sqrt.(σ² .+ ϵ)

        # ignore() do
        #     GC.gc(true)
        # end

        x = reshape(x, (input_size, :))
            
        # ignore() do
        #     GC.gc(true)
        # end

        if i < model.config.nblocks
            x = relu.(x)
        end
    end

    # ignore() do
    #     GC.gc(true)
    # end

    x = reshape(model.projects[1](θ) * x, (model.config.nc_mid, :))
    x = reshape(x + model.biases[2](θ), (:, batch))
    x = relu.(x)

    # ignore() do
    #     GC.gc(true)
    # end

    x = reshape(model.projects[2](θ) * x, (model.config.nc_out, :)) + model.biases[3](θ)
    x = reshape(x, (model.config.nc_out ÷ model.config.partition[1], model.config.nx ÷ model.config.partition[2], model.config.ny ÷ model.config.partition[3], model.config.nt ÷ model.config.partition[4], batch))
    x = 1f0.-relu.(1f0.-relu.(x))

    return x
end
