#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    add_conda_pkg(pkg_name::String; version::Union{Nothing,String})

Test if the given package with the given version is installed in the conda environment.

## Arguments
- `pkg_name::String`: Name of the package.

## Keyword Arguments
- `version::Union{Nothing,String}`: Version of the package.
"""
function is_conda_pkg_installed(pkg_name::String; version::Union{Nothing,String}=nothing)
    dfile = CondaPkg.cur_deps_file()
    dtoml = CondaPkg.read_deps(; file=dfile)
    pkgs, _, _ = CondaPkg.parse_deps(dtoml)

    pkg_string = isnothing(version) ? "$pkg_name" : "$pkg_name@v$version"
    return any(pkg -> if isnothing(version)
        pkg.name == pkg_string
    else
        "$(pkg.name)@v$(pkg.version)" == pkg_string
    end, pkgs)
end

"""
    add_conda_pkg(pkg_name::String; version::Union{Nothing,String})

Adds the given package with the given version in the conda environment if it is not installed.

## Arguments
- `pkg_name::String`: Name of the package.

## Keyword Arguments
- `version::Union{Nothing,String}`: Version of the package.
"""
function add_conda_pkg(pkg_name::String; version::Union{Nothing,String}=nothing)
    if !is_conda_pkg_installed(pkg_name; version=version)
        pkg_string = isnothing(version) ? "$pkg_name" : "$pkg_name@v$version"
        @info "The package `$pkg_string` is required for this functionality. " *
            "Adding `$pkg_string` to the conda environment..."
        if isnothing(version)
            CondaPkg.add(pkg_name)
        else
            CondaPkg.add(pkg_name; version=version)
        end
    end
end

function convert_seed(seed::Integer)
    try
        return convert(UInt32, seed)
    catch e
        if e isa InexactError
            throw(ArgumentError("Can't convert seed $(seed) to UInt32: $(e)"))
        else
            rethrow(e)
        end
    end
end
convert_seed(seed::UInt32) = seed
convert_seed(::Nothing) = PythonCall.pybuiltins.None
