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

    @testset "upload and download artifact" begin
        study, test_dir = create_test_study(; study_name="artifact_test")

        # create a trial and upload artifact
        trial = ask(study)
        data = Dict("model_weights" => [1.0, 2.0, 3.0], "epoch" => 10)
        upload_artifact(study, trial, data)
        tell(study, trial, 1.0)

        # get artifact metadata
        metas = get_all_artifact_meta(study)
        @test length(metas) == 1
        @test metas[1] isa ArtifactMeta
        @test !isempty(metas[1].artifact_id)

        # download artifact (file_path prefix + artifact_id + .jld2)
        download_prefix = joinpath(test_dir, "artifact_")
        download_artifact(study, metas[1].artifact_id, download_prefix)

        downloaded_file = abspath(download_prefix) * metas[1].artifact_id * ".jld2"
        @test isfile(downloaded_file)
    end
end
