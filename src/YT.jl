module YT

# Datasets, Indices

export Dataset
export print_stats, get_smallest_dx
export find_min, find_max, get_field_list
export get_derived_field_list

# YTArrays, YTQuantities, units

export YTArray, YTQuantity, YTUnit
export in_units, in_cgs, in_mks, from_hdf5, write_hdf5
export to_equivalent, list_equivalencies, has_equivalent
export ones_like, zeros_like

# load

export load, load_uniform_grid, load_amr_grids, load_particles

# DataContainers

export DataContainer, CutRegion, Disk, Ray, Slice, Region, Point
export Sphere, AllData, Proj, CoveringGrid, Grids, Cutting
export set_field_parameter, get_field_parameter, get_field_parameters
export has_field_parameter, quantities, list_quantities

# Fixed resolution

export FixedResolutionBuffer, to_frb

# Profiles

export YTProfile, add_fields, variance
export set_field_unit, set_x_unit, set_y_unit, set_z_unit

# Plotting

export SlicePlot, ProjectionPlot
export show_plot

# DatasetSeries

export DatasetSeries

# Other

export enable_plugins, ytcfg

import PyCall: @pyimport, PyError, pycall, PyObject

include("../deps/yt_check.jl")

check_for_yt()

@pyimport yt
@pyimport yt.convenience as ytconv
@pyimport yt.frontends.stream.api as ytstream
@pyimport yt.config as ytconfig

include("array.jl")
include("images.jl")
include("data_objects.jl")
include("physical_constants.jl")
include("dataset_series.jl")
include("plots.jl")
include("profiles.jl")

import .array: YTArray, YTQuantity, in_units, in_cgs, in_mks, YTUnit,
    from_hdf5, write_hdf5, to_equivalent, list_equivalencies,
    ones_like, zeros_like, has_equivalent
import .data_objects: Dataset, Grids, Sphere, AllData, Proj, Slice,
    CoveringGrid, to_frb, print_stats, get_smallest_dx, Disk, Ray,
    Cutting, CutRegion, DataContainer, Region, has_field_parameter,
    set_field_parameter, get_field_parameter, get_field_parameters,
    Point, find_min, find_max, quantities, list_quantities, get_field_list,
    get_derived_field_list
import .plots: SlicePlot, ProjectionPlot, show_plot
import .images: FixedResolutionBuffer
import .profiles: YTProfile, set_x_unit, set_y_unit, set_z_unit,
    set_field_unit, variance
import .dataset_series: DatasetSeries
import Base: show

enable_plugins = yt.enable_plugins

type YTConfig
    ytcfg::PyObject
end

function setindex!(ytcfg::YTConfig, value::String, section::String, param::String)
    pycall(ytcfg.ytcfg["__setitem__"], PyObject, (section, param), value)
    return nothing
end

function getindex(ytcfg::YTConfig, section::String, param::String)
    pycall(ytcfg.ytcfg["get"], String, section, param)
end

show(ytcfg::YTConfig) = typeof(ytcfg)

ytcfg = YTConfig(ytconfig.ytcfg)

load(fn::String; args...) = Dataset(ytconv.load(fn; args...))

# Stream datasets

function load_uniform_grid(data::Dict, domain_dimensions::Array; args...)
    ds = ytstream.load_uniform_grid(data, domain_dimensions; args...)
    return Dataset(ds)
end

function load_amr_grids(data::Array, domain_dimensions::Array; args...)
    ds = ytstream.load_amr_grids(data, domain_dimensions; args...)
    return Dataset(ds)
end

function load_particles(data::Dict; args...)
    ds = ytstream.load_particles(data; args...)
    return Dataset(ds)
end

end
