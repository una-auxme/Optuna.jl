#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# parameter search space for int(x_i), float(y_i), categorical(z_i) data
x_i = [0, 100]
y_i = [-10.0f0, 10.0f0]
z_i = [true, false]
param = 5.0

function objective(study, trial::Trial; x, y, z)
    result = 0.0
    for step in 1:10
        result = z ? x * (y - param) : x * (y + param)
        # Report the intermediate value to the trial
        report(trial, result, step)
        # Check if the trial should be pruned
        if should_prune(trial)
            return nothing
        end
    end
    # Upload artifacts related to this trial
    upload_artifact(study, trial, Dict("x" => x, "y" => y, "z" => z, "param" => param))
    return result
end

# Optimize the objective function of the study with a set of parameters suggested by the sampler
function test_optimize_permutations(n_jobs, verbose)
    study, test_dir = create_test_study(; study_name="optimize-$(n_jobs)-$(verbose)")

    obj = function (trial; x, y, z)
        return objective(study, trial; x=x, y=y, z=z)
    end

    optimize(study, obj, (x=x_i, y=y_i, z=z_i); n_trials=10, n_jobs=n_jobs, verbose=verbose)

    #@test best_value(study) < 0.0

    return nothing
end

@testset "optimize" begin
    for verbose in (false, true)
        for n_jobs in (1, 4)
            @testset "n_jobs=$(n_jobs), verbose=$(verbose)" begin
                test_optimize_permutations(n_jobs, verbose)
            end
        end
    end
end
