#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#
# This Test Mimics functionality in the "optimize"-Example
@testset "optimize" begin
    # parameter search space
    x_i = [0, 100]
    y_i = [-10.0, 10.0]
    z_i = [true, false]
    param = 5.0

    create_test_study(;
        study_name="optimize_test", sampler=RandomSampler(), pruner=MedianPruner()
    ) do study1, test_dir1
        # objective function with internal suggest functions
        function objective(trial::Trial)
            x = suggest_int(trial, "x", x_i[1], x_i[2])
            y = suggest_float(trial, "y", y_i[1], y_i[2])
            z = suggest_categorical(trial, "z", z_i)

            result = 0.0
            for step in 1:10
                result = z ? x * (y - param) : x * (y + param)
                report(trial, result, step)
                if should_prune(trial)
                    return nothing
                end
            end
            upload_artifact(
                study1, trial, Dict("x" => x, "y" => y, "z" => z, "param" => param)
            )
            return result
        end

        optimize(study1, objective; n_trials=5, n_jobs=1, verbose=false)

        @test best_value(study1) isa Float64
        @test best_params(study1) isa Dict{String,Any}
        @test best_trial(study1) isa Trial

        best_x = best_params(study1)["x"]
        best_y = best_params(study1)["y"]
        best_z = best_params(study1)["z"]

        @test best_x isa Int
        @test best_y isa Float64
        @test best_z isa Bool

        best_obj = best_z ? best_x * (best_y - param) : best_x * (best_y + param)
        @test best_value(study1) == best_obj
    end
end
