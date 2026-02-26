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

    @testset "suggest internal objective" begin
        study1, test_dir1 = create_test_study(;
            study_name="optimize_test", sampler=RandomSampler(), pruner=MedianPruner()
        )
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
    # test optimize with kwargs-style objective
    @testset "kwargs objective" begin
        study2, test_dir2 = create_test_study(;
            study_name="optimize_kwargs_test",
            sampler=RandomSampler(),
            pruner=MedianPruner(),
        )
        # objective function with parameters as kwargs
        function objective_kwargs(trial::Trial; x, y, z)
            result = 0.0
            for step in 1:10
                result = z ? x * (y - param) : x * (y + param)
                report(trial, result, step)
                if should_prune(trial)
                    return nothing
                end
            end
            upload_artifact(
                study2, trial, Dict("x" => x, "y" => y, "z" => z, "param" => param)
            )
            return result
        end

        # test that optimize throws an error if the objective does not accept the parameters
        @test_throws ErrorException optimize(
            study2,
            objective_kwargs,
            (x=:error, y=y_i, z=z_i);
            n_trials=5,
            n_jobs=1,
            verbose=false,
        )
        optimize(
            study2,
            objective_kwargs,
            (x=x_i, y=y_i, z=z_i);
            n_trials=5,
            n_jobs=1,
            verbose=false,
        )

        @test best_value(study2) isa Float64
        @test best_params(study2) isa Dict{String,Any}
        @test best_trial(study2) isa Trial

        best_x = best_params(study2)["x"]
        best_y = best_params(study2)["y"]
        best_z = best_params(study2)["z"]

        @test best_x isa Int
        @test best_y isa Float64
        @test best_z isa Bool

        best_obj = best_z ? best_x * (best_y - param) : best_x * (best_y + param)
        @test best_value(study2) == best_obj
    end

    # test optimize with NamedTuple-style objective
    @testset "NamedTuple objective" begin
        study3, test_dir3 = create_test_study(;
            study_name="optimize_namedtuple_test",
            sampler=RandomSampler(),
            pruner=MedianPruner(),
        )

        # define objective here so it captures study3
        function objective_namedtuple(trial::Trial, params::NamedTuple)
            result = 0.0
            for step in 1:10
                result = if params.z
                    params.x * (params.y - param)
                else
                    params.x * (params.y + param)
                end
                report(trial, result, step)
                if should_prune(trial)
                    return nothing
                end
            end
            upload_artifact(
                study3,
                trial,
                Dict("x" => params.x, "y" => params.y, "z" => params.z, "param" => param),
            )
            return result
        end

        optimize(
            study3,
            objective_namedtuple,
            (x=x_i, y=y_i, z=z_i);
            n_trials=5,
            n_jobs=1,
            verbose=false,
        )

        @test best_value(study3) isa Float64
        @test best_params(study3) isa Dict{String,Any}
        @test best_trial(study3) isa Trial

        best_x = best_params(study3)["x"]
        best_y = best_params(study3)["y"]
        best_z = best_params(study3)["z"]

        @test best_x isa Int
        @test best_y isa Float64
        @test best_z isa Bool

        best_obj = best_z ? best_x * (best_y - param) : best_x * (best_y + param)
        @test best_value(study3) == best_obj
    end
end
