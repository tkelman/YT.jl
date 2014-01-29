using PyCall
@pyimport yt
import Base.show

# Dataset

type DataSet
    ds::PyObject
    h::PyObject
    parameters::PyDict
    domain_center::YTArray
    domain_left_edge::YTArray
    domain_right_edge::YTArray
    domain_width::YTArray
    domain_dimensions::Array
    dimensionality::Integer
    current_time::YTQuantity
    current_redshift::Real
end

function get_smallest_dx(ds::DataSet)
    pycall(ds.h["get_smallest_dx"], YTArray)
end

# Data containers

abstract DataContainer

# All Data

type AllData <: DataContainer
    cont::PyObject
    ds::DataSet
    function AllData(ds::DataSet; args...)
        new(ds.h[:all_data](args...))
    end
end

# Region

type Region <: DataContainer
    cont::PyObject
    ds::DataSet
    center
    left_edge
    right_edge

    function Region(ds::DataSet, center::Array, left_edge::Array,
                    right_edge::Array; args...)
        reg = ds.h[:region](center, left_edge, right_edge; args...)
        new(reg, ds, reg[:center], reg[:left_edge], reg[:right_edge])
    end
    function Region(ds::DataSet, center::String, left_edge::Array,
                    right_edge::Array; args...)
        reg = ds.h[:region](center, left_edge, right_edge; args...)
        new(reg, ds, reg[:center], reg[:left_edge], reg[:right_edge])
    end

end

# Projection

type Projection <: DataContainer
    cont::PyObject
    ds::DataSet
    axis
    weight_field
    center
    data_source
end

# Slice

type Slice <: DataContainer
    cont::PyObject
    ds::DataSet
    axis
    center
    data_source
end

# Sphere

type Sphere <: DataContainer
    cont::PyObject
    ds::DataSet
    center
    radius

    function Sphere(ds::DataSet, center::String, radius::Real; args...)
        sp = ds.h[:sphere](center, radius; args...)
        new(sp, ds, sp[:center], sp[:radius])
    end
    function Sphere(ds::DataSet, center::String, radius::(Real,String); args...)
        sp = ds.h[:sphere](center, radius; args...)
        new(sp, ds, sp[:center], sp[:radius])
    end
    function Sphere(ds::DataSet, center::Array, radius::(Real,String); args...)
        sp = ds.h[:sphere](center, radius; args...)
        new(sp, ds, sp[:center], sp[:radius])
    end
    function sphere(ds::DataSet, center::Array, radius::Real; args...)
        sp = ds.h[:sphere](center, radius; args...)
        new(sp, ds, sp[:center], sp[:radius])
    end
end

# Grids

type Grids <: AbstractArray
    grids::Array
    function Grids(ds::DataSet)
        new(ds.h[:grids])
    end
    function Grids(grid_array::Array)
        new(grid_array)
    end
    function Grids(grid::PyObject)
        new([grid])
    end
    function Grids(nothing)
        new([])
    end
end

type Grid <: DataContainer
    cont::PyObject
    left_edge::YTArray
    right_edge::YTArray
    level::Integer
    number_of_particles::Integer
    active_dimensions::Array
    Parent::Grids
    Children::Grids
end

# Field parameters

function set_field_parameter(dc::DataContainer, key::String, value)
    dc.cont[:set_field_parameter](key, value)
end

function has_field_parameter(dc::DataContainer, key::String)
    dc.cont[:has_field_parameter](key)
end

function get_field_parameter(dc::DataContainer, key::String)
    dc.cont[:get_field_parameter](key)
end

# Indices

function getindex(dc::DataContainer, key::String)
    YTArray(get(dc.cont, PyObject, key))
end

function getindex(grids::Grids, i::Int)
    g = grids.grids[i]
    Grid(g,
         YTArray(g["LeftEdge"]),
         YTArray(g["RightEdge"]),
         g[:Level][1],
         g[:NumberOfParticles][1],
         g[:ActiveDimensions],
         Grids(g[:Parent]),
         Grids(g[:Children]))
end

# Show

function show(io::IO, ds::DataSet)
    println(io,ds.ds[:__repr__]())
end

function show(io::IO, dc::DataContainer)
    println(io,dc.cont[:__repr__]())
end

show(io::IO, grids::Grids) = show(io, grids.grids)
