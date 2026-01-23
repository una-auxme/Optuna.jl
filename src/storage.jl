#
# Copyright (c) 2026 Julian Trommer
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

    function RDBStorage(database_path::String, database_name::String)
        mkpath(abspath(database_path))

        storage = optuna.storages.RDBStorage(
            "sqlite:///" * abspath(joinpath(database_path, "$database_name.db"))
        )
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
