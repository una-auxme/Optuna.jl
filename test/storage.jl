#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function test_storage_type(
    storage::Optuna.BaseStorage, storage_type::Type{T}
) where {T<:Optuna.BaseStorage}
    @testset "storage type" begin
        @test storage isa storage_type
        @test storage isa Optuna.BaseStorage
        @test storage.storage !== nothing
    end
end

function test_get_all_study_names(test_dir, storage)
    artifacts = FileSystemArtifactStore(joinpath(test_dir, "artifacts"))
    @testset "get_all_study_names" begin
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
end

@testset "storage" begin
    @testset "RDBStorage" begin
        @testset "SQLite" begin
            test_dir = mktempdir()
            url = create_sqlite_url(test_dir, "test_storage")
            @testset "create_sqlite_url" begin
                @test startswith(url, "sqlite:///")
                @test endswith(url, "test_storage.db")
                @test isdir(test_dir)
            end

            storage = RDBStorage(url)
            test_storage_type(storage, RDBStorage)
            test_get_all_study_names(test_dir, storage)
        end

        @testset "MySQL" begin
            test_dir = mktempdir()
            @testset "create_mysql_url" begin
                # basic url
                url = create_mysql_url(; host="localhost", database_name="optuna")
                @test url == "mysql://localhost/optuna"

                # with port
                url2 = create_mysql_url(;
                    host="localhost", port="3306", database_name="optuna"
                )
                @test url2 == "mysql://localhost:3306/optuna"

                # with credentials
                url3 = create_mysql_url(;
                    user_name="user",
                    password="pass",
                    host="localhost",
                    database_name="optuna",
                )
                @test url3 == "mysql://user:pass@localhost/optuna"

                # with query params
                url4 = create_mysql_url(;
                    host="localhost",
                    database_name="optuna",
                    query=Dict{String,Any}("charset" => "utf8"),
                )
                @test url4 == "mysql://localhost/optuna?charset=utf8"

                # missing host should error
                @test_throws ErrorException create_mysql_url(; database_name="optuna")

                # missing database_name should error
                @test_throws ErrorException create_mysql_url(; host="localhost")
            end

            if !success(`docker --version`)
                @warn "docker is not installed on this machine. " *
                    "Skipping MySQL database access tests."
            else
                @testset "Database access" begin
                    compose_file = joinpath(@__DIR__, "docker", "docker-compose-mysql.yml")
                    run(`docker compose -f $compose_file up -d --wait`)

                    url = create_mysql_url(;
                        host="localhost",
                        port="3306",
                        user_name="root",
                        database_name="optuna",
                    )
                    try
                        storage = RDBStorage(url)
                        test_storage_type(storage, RDBStorage)
                        test_get_all_study_names(test_dir, storage)
                    finally
                        run(`docker compose -f $compose_file down`)
                    end
                end
            end
        end
    end

    @testset "InMemoryStorage" begin
        test_dir = mktempdir()
        storage = InMemoryStorage()
        test_storage_type(storage, InMemoryStorage)
        test_get_all_study_names(test_dir, storage)
    end

    @testset "JournalStorage" begin
        @testset "JournalFileBackend" begin
            if Sys.iswindows()
                @warn "Skipping JournalFileSymlinkLock on Windows."
            else
                @testset "JournalFileSymlinkLock" begin
                    test_dir = mktempdir()
                    journal_file = joinpath(test_dir, "journal_storage.log")
                    storage = JournalStorage(
                        JournalFileBackend(
                            journal_file; lock_obj=JournalFileSymlinkLock(journal_file)
                        ),
                    )
                    test_storage_type(storage, JournalStorage)
                    test_get_all_study_names(test_dir, storage)
                end
            end

            @testset "JournalFileOpenLock" begin
                test_dir = mktempdir()
                journal_file = joinpath(test_dir, "journal_storage.log")
                storage = JournalStorage(
                    JournalFileBackend(
                        journal_file; lock_obj=JournalFileOpenLock(journal_file)
                    ),
                )
                test_storage_type(storage, JournalStorage)
                test_get_all_study_names(test_dir, storage)
            end
        end

        @testset "JournalRedisBackend" begin
            @testset "create_redis_url" begin
                # basic url
                url = create_redis_url(; host="localhost")
                @test url == "redis://localhost:6379/0"

                # with port and database_index
                url2 = create_redis_url(; host="localhost", port="1000", database_index="1")
                @test url2 == "redis://localhost:1000/1"

                # with credentials
                url3 = create_redis_url(;
                    user_name="user", password="pass", host="localhost"
                )
                @test url3 == "redis://user:pass@localhost:6379/0"

                # empty host should error
                @test_throws ErrorException create_redis_url()
            end

            if !success(`docker --version`)
                @warn "docker is not installed on this machine. " *
                    "Skipping Redis database access tests."
            else
                @testset "Database access" begin
                    test_dir = mktempdir()
                    url = create_redis_url(; host="localhost", user_name="root")

                    compose_file = joinpath(@__DIR__, "docker", "docker-compose-redis.yml")
                    run(`docker compose -f $compose_file up -d --wait`)
                    try
                        storage = JournalStorage(JournalRedisBackend(url))
                        test_storage_type(storage, JournalStorage)
                        test_get_all_study_names(test_dir, storage)
                    finally
                        run(`docker compose -f $compose_file down`)
                    end
                end
            end
        end
    end
end
