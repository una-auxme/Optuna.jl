#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

@testset "study" begin
    @testset "Study construction" begin
        create_test_study(; study_name="construct_test") do study, _
            @test study isa Study
        end
    end

    @testset "Study direction" begin
        # minimize (default)
        create_test_study(; study_name="minimize_test", direction="minimize") do study, _
            @test study isa Study
        end

        # maximize
        create_test_study(; study_name="maximize_test", direction="maximize") do study, _
            @test study isa Study
        end

        # invalid direction should error
        @test_throws ErrorException create_test_study(
            (_, _) -> nothing; study_name="invalid_test", direction="invalid"
        )
    end

    @testset "ask/tell workflow" begin
        create_test_study(; study_name="ask_tell_test") do study, _
            trial = ask(study)
            @test trial isa Trial

            x = suggest_float(trial, "x", 0.0, 10.0)
            tell(study, trial, x)
        end
    end

    @testset "best_trial, best_params, best_value" begin
        create_test_study(; study_name="best_test") do study, _
            # run a few trials
            for value in [5.0, 3.0, 7.0]
                trial = ask(study)
                suggest_float(trial, "x", 0.0, 10.0)
                tell(study, trial, value)
            end

            @test best_value(study) == 3.0  # minimize, so lowest is best
            @test best_value(study) isa Float64
            @test best_params(study) isa Dict{String,Any}
            @test best_trial(study) isa Trial
        end
    end

    @testset "load_study" begin
        test_dir = mktempdir()
        storage = RDBStorage(create_sqlite_url(test_dir, "load_test"))
        artifacts = FileSystemArtifactStore(joinpath(test_dir, "artifacts"))

        # create study and add a trial
        study1 = Study("load_test", artifacts, storage)
        trial = ask(study1)
        tell(study1, trial, 42.0)

        # load the same study
        study2 = load_study(
            "load_test", storage, artifacts; sampler=RandomSampler(42), pruner=NopPruner()
        )
        @test best_value(study2) == 42.0

        if Sys.iswindows()
            study1.study._storage._backend.engine.dispose()
            study2.study._storage._backend.engine.dispose()
        end
        rm(test_dir; recursive=true)
    end

    @testset "delete_study" begin
        test_dir = mktempdir()
        storage = RDBStorage(create_sqlite_url(test_dir, "delete_test"))
        artifacts = FileSystemArtifactStore(joinpath(test_dir, "artifacts"))

        Study("to_delete", artifacts, storage)
        @test "to_delete" in get_all_study_names(storage)

        delete_study("to_delete", storage)
        @test !("to_delete" in get_all_study_names(storage))
    end

    @testset "copy_study" begin
        test_dir = mktempdir()
        storage1 = RDBStorage(create_sqlite_url(test_dir, "copy_src"))
        storage2 = RDBStorage(create_sqlite_url(test_dir, "copy_dst"))
        artifacts = FileSystemArtifactStore(joinpath(test_dir, "artifacts"))

        # create study with a trial
        study1 = Study("original", artifacts, storage1)
        trial = ask(study1)
        tell(study1, trial, 99.0)

        # copy to new storage
        copy_study("original", storage1, storage2)
        study2 = load_study("original", storage2, artifacts)
        @test best_value(study2) == 99.0

        if Sys.iswindows()
            study1.study._storage._backend.engine.dispose()
            study2.study._storage._backend.engine.dispose()
        end
        rm(test_dir; recursive=true)
    end

    @testset "tell with prune" begin
        create_test_study(; study_name="prune_tell_test") do study, _
            trial = ask(study)
            tell(study, trial; prune=true)

            # pruned trial should not have a value, so best_value should error
            # (no completed trials)
            @test_throws Exception best_value(study)
        end
    end
end
