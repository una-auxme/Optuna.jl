#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#
# This Test Mimics functionality in the "single_step"-Example
@testset "single_step" begin
    # parameter search space
    x_i = [0, 100]
    y_i = [-10.0, 10.0]
    z_i = [true, false]
    param = 5.0

    # objective function
    function objective(study, trial::Trial; x, y, z)
        result = 0.0
        for step in 1:10
            result = z ? x * (y - param) : x * (y + param)
            report(trial, result, step)
            if should_prune(trial)
                return nothing
            end
        end
        upload_artifact(study, trial, Dict("x" => x, "y" => y, "z" => z, "param" => param))
        return result
    end

    study, test_dir = create_test_study(;
        study_name="single_step_test", sampler=RandomSampler(), pruner=MedianPruner()
    )
    # run multiple single-step trials using ask/tell
    for _ in 1:5
        trial = ask(study)
        x = suggest_int(trial, "x", x_i[1], x_i[2])
        y = suggest_float(trial, "y", y_i[1], y_i[2])
        z = suggest_categorical(trial, "z", z_i)
        score = objective(study, trial; x=x, y=y, z=z)
        if isnothing(score)
            tell(study, trial; prune=true)
        else
            tell(study, trial, score)
        end
    end

    # verify we can retrieve results
    @test best_value(study) isa Float64
    @test best_params(study) isa Dict{String,Any}
    @test best_trial(study) isa Trial
    best_x = best_params(study)["x"]
    best_y = best_params(study)["y"]
    best_z = best_params(study)["z"]

    @test best_x isa Int
    @test best_y isa Float64
    @test best_z isa Bool
    best_obj = best_z ? best_x * (best_y - param) : best_x * (best_y + param)
    @test best_value(study) == best_obj
end
