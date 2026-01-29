#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#
abstract type BaseJournalFileLock end

"""
    JournalFileSymlinkLock(file_path::String, grace_period::Union{Nothing,Int})

Lock class for synchronizing processes for NFSv2 or later.

## Arguments
- `file_path::String`: The path of the file whose race condition must be protected.
- `grace_period::Union{Nothing,Int}`: Grace period before an existing lock is forcibly released.
"""
struct JournalFileSymlinkLock <: BaseJournalFileLock
    lock_obj::Any

    function JournalFileSymlinkLock(file_path::String, grace_period::Union{Nothing,Int}=30)
        return new(optuna.storages.journal.JournalFileSymlinkLock(file_path, grace_period))
    end
end

"""
    JournalFileSymlinkLock(file_path::String, grace_period::Union{Nothing,Int})

Lock class for synchronizing processes for NFSv3 or later.

## Arguments
- `file_path::String`: The path of the file whose race condition must be protected.
- `grace_period::Union{Nothing,Int}`: Grace period before an existing lock is forcibly released.
"""
struct JournalFileOpenLock <: BaseJournalFileLock
    lock_obj::Any

    function JournalFileOpenLock(file_path::String, grace_period::Union{Nothing,Int}=30)
        return new(optuna.storages.journal.JournalFileOpenLock(file_path, grace_period))
    end
end

abstract type BaseJournalBackend end

"""
    JournalFileBackend(file_path::String; lock_obj::Union{Nothing,BaseJournalFileLock})

File storage class for Journal log backend.

## Arguments
- `file_path::String`: Path of file to persist the log to.

## Keyword Arguments
- `lock_obj::Union{Nothing,BaseJournalFileLock}`: Lock object for process exclusivity. An instance of JournalFileSymlinkLock and JournalFileOpenLock can be passed.
"""
struct JournalFileBackend <: BaseJournalBackend
    backend::Any

    function JournalFileBackend(
        file_path::String; lock_obj::Union{Nothing,BaseJournalFileLock}=nothing
    )
        return new(
            optuna.storages.journal.JournalFileBackend(
                file_path; lock_obj=isnothing(lock_obj) ? nothing : lock_obj.lock_obj
            ),
        )
    end
end

"""
    JournalRedisBackend(url::String, use_cluster::Bool, prefix::String)

Redis storage class for Journal log backend.

## Arguments
- `url::String`: URL of the redis storage.
- `use_cluster::Bool`: Flag whether you use the Redis cluster.
- `prefix::String`: Prefix of the preserved key of logs. This is useful when multiple users work on one Redis server.
"""
struct JournalRedisBackend <: BaseJournalBackend
    backend::Any

    function JournalRedisBackend(url::String, use_cluster::Bool=false, prefix::String="")
        add_conda_pkg("redis-py")
        return new(optuna.storages.journal.JournalRedisBackend(url, use_cluster, prefix))
    end
end
