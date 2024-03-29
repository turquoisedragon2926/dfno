@with_kw struct DataConfig
    ntrain::Int = 1000
    nvalid::Int = 100
    perm_key::String = "perm"
    perm_file::String = datadir(model_name, "perm_gridspacing15.0.jld2")
    conc_key::String = "conc"
    conc_file::String = datadir(model_name, "conc_gridspacing15.0.jld2")
    modelConfig::ModelConfig
end

function loadDistData(config::DataConfig;
    dist_read_x_tensor=UTILS.dist_read_tensor,
    dist_read_y_tensor=UTILS.dist_read_tensor,
    comm=MPI.COMM_WORLD)
    # TODO: maybe move seperating train and valid to trainconfig ? 
    # TODO: Abstract this for 2D and 3D (dimension agnostic ?) and support uneven partition
    @assert config.modelConfig.partition[1] == 1 # Creating channel dimension here
    @assert config.modelConfig.nx % config.modelConfig.partition[2] == 0
    @assert config.modelConfig.ny % config.modelConfig.partition[3] == 0
    @assert config.modelConfig.nt % config.modelConfig.partition[4] == 0

    comm_cart = MPI.Cart_create(comm, config.modelConfig.partition)
    coords = MPI.Cart_coords(comm_cart)

    nx_start, nx_end = UTILS.get_dist_indices(config.modelConfig.nx, config.modelConfig.partition[2], coords[2])
    ny_start, ny_end = UTILS.get_dist_indices(config.modelConfig.ny, config.modelConfig.partition[3], coords[3])
    nt_start, nt_end = UTILS.get_dist_indices(config.modelConfig.nt, config.modelConfig.partition[4], coords[4])
    
    x_indices = (nx_start:nx_end, ny_start:ny_end, 1:config.ntrain+config.nvalid)
    y_indices = (nx_start:nx_end, ny_start:ny_end, nt_start:nt_end, 1:config.ntrain+config.nvalid)

    x_data = dist_read_x_tensor(config.perm_file, config.perm_key, x_indices)
    y_data = dist_read_y_tensor(config.conc_file, config.conc_key, y_indices)

    # x is (1, nx, ny, n) make this (c, nx, ny, nt, n)
    x_data = reshape(x_data, size(x_data, 1), size(x_data, 2), size(x_data, 3), 1, size(x_data, 4))
    target_zeros = zeros(config.modelConfig.dtype, 1, nx_end-nx_start+1, ny_end-ny_start+1, nt_end-nt_start+1, config.ntrain+config.nvalid)

    x_data = target_zeros .+ x_data
    x_indices = target_zeros .+ reshape(nx_start:nx_end, (1, :, 1, 1, 1))
    y_indices = target_zeros .+ reshape(ny_start:ny_end, (1, 1, :, 1, 1))
    t_indices = target_zeros .+ reshape(nt_start:nt_end, (1, 1, 1, :, 1))

    x_data = cat(x_data, x_indices, y_indices, t_indices, dims=1)

    train_indices = (:, :, :, :, 1:config.ntrain)
    valid_indices = (:, :, :, :, config.ntrain+1:config.ntrain+config.nvalid)

    return x_data[train_indices...], y_data[train_indices...], x_data[valid_indices...], y_data[valid_indices...]
end
