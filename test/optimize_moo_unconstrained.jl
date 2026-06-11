@testset "moo_unconstrained_test" begin
    storage = InMemoryStorage()
    artifact_store = FileSystemArtifactStore(mktempdir())
    study = Study(
        "moo_unconstrained_test",
        artifact_store,
        storage;
        sampler=NSGAIISampler(; population_size=10),
        directions=["minimize", "minimize"],
    )

    obj1(x) = x^2
    obj2(x) = (x - 2)^2

    schaffer(trial::Trial) =
        let x = suggest_float(trial, "x", -10.0, 10.0)
            [obj1(x), obj2(x)]
        end

    optimize(study, schaffer; n_trials=5, n_jobs=1, verbose=false)

    @test length(best_trials(study)) >= 1
    @test all(length(v) == 2 for v in best_values(study))

    @test_throws ErrorException best_value(study)
    @test_throws ErrorException best_params(study)
    @test_throws ErrorException best_trial(study)

    @test best_values(study) isa Vector{Vector{Float64}}
    @test best_params_all(study) isa Vector{Dict{String,Any}}
    @test best_trials(study) isa Vector

    @test length(best_trials(study)) ==
        length(best_values(study)) ==
        length(best_params_all(study))

    best_x = best_params_all(study)[1]["x"]
    @test best_x isa Float64
    @test all(-10.0 <= p["x"] <= 10.0 for p in best_params_all(study))
    @test all(all(v >= 0.0 for v in vals) for vals in best_values(study))
    @test all(all(isfinite(v) for v in vals) for vals in best_values(study))
end
