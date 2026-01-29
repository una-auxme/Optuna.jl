#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# helpers
function convert_seed(seed::Integer)
    try
        return convert(UInt32, seed)
    catch
        @assert false "Can't convert seed $(seed)!"
    end
end
convert_seed(seed::UInt32) = seed
convert_seed(::Nothing) = PythonCall.pybuiltins.None
