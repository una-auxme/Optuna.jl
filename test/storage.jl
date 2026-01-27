#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

@testset "storage" begin
    @testset "RDBStorage" begin
        test_dir = mktempdir()
        url = create_sqlite_url(test_dir, "test_storage")

        storage = RDBStorage(url)
        @test storage isa RDBStorage
        @test storage isa Optuna.BaseStorage
        @test storage.storage !== nothing
    end

    @testset "sqlite" begin
        @testset "get_all_study_names" begin
            test_dir = mktempdir()
            storage = RDBStorage(create_sqlite_url(test_dir, "names_test"))
            artifacts = FileSystemArtifactStore(joinpath(test_dir, "artifacts"))

            # initially empty
            @test isempty(get_all_study_names(storage))

            # create some studies
            Study("study1", artifacts, storage)
            Study("study2", artifacts, storage)

            names = get_all_study_names(storage)
            @test "study1" in names
            @test "study2" in names
            @test length(names) == 2
        end

        @testset "create_sqlite_url" begin
            test_dir = mktempdir()
            url = create_sqlite_url(test_dir, "mydb")

            @test startswith(url, "sqlite:///")
            @test endswith(url, "mydb.db")
            @test isdir(test_dir)
        end
    end

    @testset "MySQL" begin
        @testset "create_mysql_url" begin
            # basic url
            url = create_mysql_url(; host="localhost", database_name="optuna")
            @test url == "mysql://localhost/optuna"

            # with port
            url = create_mysql_url(; host="localhost", port="3306", database_name="optuna")
            @test url == "mysql://localhost:3306/optuna"

            # with credentials
            url = create_mysql_url(;
                user_name="user", password="pass", host="localhost", database_name="optuna"
            )
            @test url == "mysql://user:pass@localhost/optuna"

            # with query params
            url = create_mysql_url(;
                host="localhost",
                database_name="optuna",
                query=Dict{String,Any}("charset" => "utf8"),
            )
            @test url == "mysql://localhost/optuna?charset=utf8"

            # missing host should error
            @test_throws ErrorException create_mysql_url(; database_name="optuna")

            # missing database_name should error
            @test_throws ErrorException create_mysql_url(; host="localhost")
        end
    end
end
