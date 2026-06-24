#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

@testset "artifacts" begin
    @testset "FileSystemArtifactStore" begin
        test_dir = mktempdir()
        artifact_path = joinpath(test_dir, "artifacts")

        store = FileSystemArtifactStore(artifact_path)
        @test store isa FileSystemArtifactStore
        @test store isa Optuna.BaseArtifactStore
        @test isdir(artifact_path)
        @test store.path == abspath(artifact_path)
    end

    @testset "ArtifactMeta" begin
        meta = ArtifactMeta("abc123", "application/octet-stream", nothing)
        @test meta.artifact_id == "abc123"
        @test meta.mimetype == "application/octet-stream"
        @test meta.encoding === nothing

        meta_with_encoding = ArtifactMeta("def456", "text/plain", "utf-8")
        @test meta_with_encoding.encoding == "utf-8"
    end

    @testset "set_user_attr for non-threaded Trial" begin
        create_test_study(; study_name="set_user_attr_trial_false_test") do study, _
            trial = ask(study; multithreading=false)
            @test trial isa Trial{false}

            set_user_attr(trial, "artifact_id", "artifact-123")
            @test Bool(trial.trial.user_attrs.__contains__("artifact_id"))
            @test Optuna.PythonCall.pyconvert(
                String, trial.trial.user_attrs["artifact_id"]
            ) == "artifact-123"

            tell(study, trial, 1.0)
        end
    end

    @testset "upload and download artifact" begin
        create_test_study(; study_name="artifact_test") do study, test_dir
            trial = ask(study)
            data = Dict("model_weights" => [1.0, 2.0, 3.0], "epoch" => 10)
            artifact_id = upload_artifact(study, trial, data)
            @test artifact_id isa String
            @test !isempty(artifact_id)
            @test !Bool(trial.trial.user_attrs.__contains__("artifact_id"))

            set_user_attr(trial, "artifact_id", artifact_id)
            @test Bool(trial.trial.user_attrs.__contains__("artifact_id"))
            @test Optuna.PythonCall.pyconvert(
                String, trial.trial.user_attrs["artifact_id"]
            ) == artifact_id

            tell(study, trial, 1.0)

            metas = get_all_artifact_meta(study)
            @test length(metas) == 1
            @test metas[1] isa ArtifactMeta
            @test metas[1].artifact_id == artifact_id

            julia_trial_metas = get_all_artifact_meta(study, trial)
            @test length(julia_trial_metas) == 1
            @test julia_trial_metas[1].artifact_id == artifact_id

            py_trial = first(study.study.trials)
            py_trial_metas = get_all_artifact_meta(study, py_trial)
            @test length(py_trial_metas) == 1
            @test py_trial_metas[1].artifact_id == artifact_id

            downloaded_file = joinpath(test_dir, "downloaded-artifact.jld2")
            download_artifact(study, artifact_id, downloaded_file)
            @test isfile(downloaded_file)
            @test !isfile(abspath(downloaded_file) * artifact_id * ".jld2")
        end
    end

    @testset "metadata lookup dispatch for Julia trials" begin
        create_test_study(; study_name="artifact_dispatch_test") do study, _
            trial_false = ask(study; multithreading=false)
            @test trial_false isa Trial{false}
            artifact_id_false = upload_artifact(study, trial_false, Dict("trial" => "false"))
            tell(study, trial_false, 1.0)

            trial_true = ask(study; multithreading=true)
            @test trial_true isa Trial{true}
            artifact_id_true = upload_artifact(study, trial_true, Dict("trial" => "true"))
            tell(study, trial_true, 2.0)

            metas_false = get_all_artifact_meta(study, trial_false)
            @test length(metas_false) == 1
            @test metas_false[1].artifact_id == artifact_id_false

            metas_true = get_all_artifact_meta(study, trial_true)
            @test length(metas_true) == 1
            @test metas_true[1].artifact_id == artifact_id_true
        end
    end

    @testset "metadata across trials with uneven artifacts" begin
        create_test_study(; study_name="multi_artifact_test") do study, _
            @test isempty(get_all_artifact_meta(study))

            trial_with_one = ask(study)
            artifact_id_1 = upload_artifact(study, trial_with_one, Dict("trial" => 1))
            tell(study, trial_with_one, 1.0)

            trial_without_artifacts = ask(study)
            tell(study, trial_without_artifacts, 2.0)

            trial_with_two = ask(study)
            artifact_id_2 = upload_artifact(
                study, trial_with_two, Dict("trial" => 3, "idx" => 1)
            )
            artifact_id_3 = upload_artifact(
                study, trial_with_two, Dict("trial" => 3, "idx" => 2)
            )
            tell(study, trial_with_two, 3.0)

            @test isempty(get_all_artifact_meta(study, trial_without_artifacts))

            metas = get_all_artifact_meta(study)
            artifact_ids = Set(meta.artifact_id for meta in metas)
            @test length(metas) == 3
            @test artifact_ids == Set([artifact_id_1, artifact_id_2, artifact_id_3])
        end
    end
end
