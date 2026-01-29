#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    add_conda_pkg()

Test if the given package with the given version is installed and adds it to the conda environment if not.
Julia needs to be restarted in order to use the newly installed package.

## Arguments
- `pkg_name::String`: Name of the package.

## Keyword Arguments
- `version::String`: Version of the package.
"""
function add_conda_pkg(pkg_name::String; version::Union{Nothing,String}=nothing)
    dfile = CondaPkg.cur_deps_file()
    dtoml = CondaPkg.read_deps(; file=dfile)
    pkgs, _, _ = CondaPkg.parse_deps(dtoml)

    pkg_string = isnothing(version) ? "$pkg_name@v$version" : "$pkg_name"
    if !any(pkg -> if isnoting(version)
        pkg.name == pkg_string
    else
        "$(pkg.name)@v$(pkg.version)" == pkg_string
    end, pkgs)
        @info "The package `$pkg_string` is required for this functionality. " *
            "Adding `$pkg_string` to the conda environment..."
        if isnothing(version)
            CondaPkg.add(pkg_name)
        else
            CondaPkg.add(pkg_name; version=version)
        end
        throw(
            ErrorException(
                "You need to restart Julia to use the new `$pkg_string` package."
            ),
        )
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
