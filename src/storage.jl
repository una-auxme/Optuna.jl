#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#
abstract type BaseStorage end

"""
    RDBStorage(url::String)

Storage class for RDB backends.

## Arguments
- `url::String`: URL of the database (e.g. directory and filename for SQLite).
"""
struct RDBStorage <: BaseStorage
    storage::Any

    function RDBStorage(url::String)
        if startswith(url, "mysql")
            add_conda_pkg("mysqlclient")
        end
        storage = optuna.storages.RDBStorage(url)
        return new(storage)
    end
end

"""
    InMemoryStorage()

Storage class that stores data in memory of the running process.
"""
struct InMemoryStorage <: BaseStorage
    storage::Any

    function InMemoryStorage()
        return new(optuna.storages.InMemoryStorage())
    end
end

"""
    JournalStorage(backend::BaseJournalBackend)

Storage class for Journal storage backend.

## Arguments
- `backend::BaseJournalBackend`: Backend that determines where the data is stored.
"""
struct JournalStorage <: BaseStorage
    storage::Any

    function JournalStorage(backend::BaseJournalBackend)
        return new(optuna.storages.JournalStorage(backend.backend))
    end
end

"""
    get_all_study_names(storage::BaseStorage)

Returns all study names stored in the given storage.

## Arguments
- `storage::BaseStorage`: Storage backend to query.

## Returns
- `Vector{String}`: List of study names.
"""
function get_all_study_names(storage::BaseStorage)
    return optuna.get_all_study_names(storage.storage)
end

"""
    create_sqlite_url(database_path::String, database_name::String)

Returns a valid URL for a SQLite database with the given arguments.

## Arguments
- `database_path::String`: Path to the directory where the database is stored.
- `database_name::String`: Name of the database file.

## Returns
- `String`: URL for the SQLite database.
"""
function create_sqlite_url(database_path::String, database_name::String)
    mkpath(abspath(database_path))

    return "sqlite:///" * abspath(joinpath(database_path, "$database_name.db"))
end

"""
    create_mysql_url(; user_name::String, password::String, host::String, port::String, database_name::String, query::Dict{String,Any})

Returns a valid URL for a MySQL database with the given arguments.

## Keyword Arguments
- `user_name::String`: Name of the database user.
- `password::String`: Password of the database user.
- `host::String`: Host where the database server is running.
- `port::String`: Port of the database server.
- `database_name::String`: Name of the database.
- `query::Dict{String,Any}`: Query string with keys and either strings or additional query strings as values.

## Returns
- `String`: URL to the MySQL database.
"""
function create_mysql_url(;
    user_name::String="",
    password::String="",
    host::String="",
    port::String="",
    database_name::String="",
    query::Dict{String,Any}=Dict{String,Any}(),
)
    if isempty(host)
        error("No host of the MySQL server was provided.")
    end
    if isempty(database_name)
        error("No name of the MySQL database was provided.")
    end

    if !isempty(user_name) && !isempty(password)
        user_string = "$user_name:$password@"
    else
        user_string = ""
    end

    if !isempty(port)
        port = ":$port"
    end

    query_string = ""
    for (k, v) in query
        if v isa Vector{String}
            for iv in v
                query_string *= "$k=$iv&"
            end
        else
            query_string *= "$k=$v&"
        end
    end
    if !isempty(query_string)
        query_string = "?$(query_string[1:(end - 1)])"
    end

    return "mysql://$user_string$host$port/$database_name$query_string"
end

"""
    create_redis_url(; user_name::String, password::String, host::String, port::String, database_name::String, query::Dict{String,Any})

Returns a valid URL for a Redis server with the given arguments.

## Keyword Arguments
- `user_name::String`: Name of the Redis user.
- `password::String`: Password of the Redis user.
- `host::String`: Host where the Redis server is running.
- `port::String`: Port of the Redis server.
- `database_name::String`: Index of the database.

## Returns
- `String`: URL to the Redis database.
"""
function create_redis_url(;
    user_name::String="",
    password::String="",
    host::String="",
    port::String="6379",
    database_index::String="0",
)
    if isempty(host)
        error("No host of the Redis server was provided.")
    end

    if !isempty(user_name) && !isempty(password)
        user_string = "$user_name:$password@"
    else
        user_string = ""
    end

    if !isempty(port)
        port = ":$port"
    end
    if !isempty(database_index)
        db_idx = "/$database_index"
    end

    return "redis://$user_string$host$port$db_idx"
end
