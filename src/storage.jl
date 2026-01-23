#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofman, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

abstract type BaseStorage end

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

function get_all_study_names(storage::BaseStorage)
    return optuna.get_all_study_names(storage.storage)
end
