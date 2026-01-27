#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

@testset "study" begin
    @testset "Study construction" begin
        study, test_dir, _, _ = create_test_study(; name="construct_test")
        @test study isa Study
        rm(test_dir; recursive=true)
    end

    @testset "Study direction" begin
        # minimize (default)
        study, test_dir, _, _ = create_test_study(;
            name="minimize_test", direction="minimize"
        )
        @test study isa Study
        rm(test_dir; recursive=true)

        # maximize
        study, test_dir, _, _ = create_test_study(;
            name="maximize_test", direction="maximize"
        )
        @test study isa Study
        rm(test_dir; recursive=true)

        # invalid direction should error
        @test_throws ErrorException create_test_study(;
            name="invalid_test", direction="invalid"
        )
    end

    @testset "ask/tell workflow" begin
        study, test_dir, _, _ = create_test_study(; name="ask_tell_test")

        trial = ask(study)
        @test trial isa Trial

        x = suggest_float(trial, "x", 0.0, 10.0)
        tell(study, trial, x)

        rm(test_dir; recursive=true)
    end

    @testset "best_trial, best_params, best_value" begin
        study, test_dir, _, _ = create_test_study(; name="best_test")

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

        rm(test_dir; recursive=true)
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
        study2 = load_study("load_test", storage, artifacts)
        @test best_value(study2) == 42.0

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

        rm(test_dir; recursive=true)
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

        rm(test_dir; recursive=true)
    end

    @testset "tell with prune" begin
        study, test_dir, _, _ = create_test_study(; name="prune_tell_test")

        trial = ask(study)
        tell(study, trial; prune=true)

        # pruned trial should not have a value, so best_value should error
        # (no completed trials)
        @test_throws Exception best_value(study)

        rm(test_dir; recursive=true)
    end
end
