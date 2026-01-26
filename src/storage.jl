#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#
abstract type BaseStorage end

"""
    RDBStorage(database_path::String, database_name::String)

Storage class for RDB backends.

## Arguments
- `database_path::String`: Path to the directory where the database is stored.
- `database_name::String`: Name of the database file.
"""
struct RDBStorage <: BaseStorage
    storage::Any

    function RDBStorage(url::String)
        storage = optuna.storages.RDBStorage(url)
        return new(storage)
    end
end

"""
    get_all_study_names(storage::BaseStorage)

returns all study names stored in the given storage.

## Arguments
- `storage::BaseStorage`: Storage backend to query.

## Returns
- `Vector{String}`: List of study names.
"""
function get_all_study_names(storage::BaseStorage)
    return optuna.get_all_study_names(storage.storage)
end

function create_sqlite_url(database_path::String, database_name::String)
    mkpath(abspath(database_path))

    return "sqlite:///" * abspath(joinpath(database_path, "$database_name.db"))
end

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
        user_string = "$(user_name):$password@"
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

    return "mysql://$(user_string)$host$port/$(database_name)$(query_string)"
end
