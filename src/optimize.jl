#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofman, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function optimize(study::Study, objective::Function, params::NamedTuple; n_trials=100::Int)
    for _ in 1:n_trials
        trial = ask(study)

        args_fn = Dict{Symbol,Any}()
        for k in keys(params)
            v = params[k]
            if v[1] isa Signed
                args_fn[k] = suggest_int(trial, string(k), v[1], v[2])
            elseif v[1] isa AbstractFloat
                args_fn[k] = suggest_float(trial, string(k), v[1], v[2])
            elseif v isa Vector
                args_fn[k] = suggest_categorical(trial, string(k), v)
            else
                error(
                    "Unsupported parameter type for key: $k => value $(typeof(v)). Possible types are Int, AbstractFloat, and Vector.",
                )
            end
        end

        score = objective(trial; args_fn...)
        if isnothing(score)
            tell(study, trial; prune=true)
        else
            tell(study, trial, score)
        end
    end
    return study
end
