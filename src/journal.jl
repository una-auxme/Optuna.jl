#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    JournalFileSymlinkLock(
        file_path::String, 
        grace_period::Union{Nothing,Int}=30
    )

Lock class for synchronizing processes for NFSv2 or later.
For further information see the [JournalFileSymlinkLock](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.storages.journal.JournalFileSymlinkLock.html) in the Optuna python documentation.

## Arguments
- `file_path::String`: The path of the file whose race condition must be protected.
- `grace_period::Union{Nothing,Int}=30`: Grace period before an existing lock is forcibly released.
"""
struct JournalFileSymlinkLock <: BaseJournalFileLock
    lock_obj::Any

    function JournalFileSymlinkLock(file_path::String, grace_period::Union{Nothing,Int}=30)
        return new(optuna.storages.journal.JournalFileSymlinkLock(file_path, grace_period))
    end
end

"""
    JournalFileOpenLock(
        file_path::String, 
        grace_period::Union{Nothing,Int}=30}
    )

Lock class for synchronizing processes for NFSv3 or later.
For further information see the [JournalFileOpenLock](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.storages.journal.JournalFileOpenLock.html) in the Optuna python documentation.

## Arguments
- `file_path::String`: The path of the file whose race condition must be protected.
- `grace_period::Union{Nothing,Int}=30`: Grace period before an existing lock is forcibly released.
"""
struct JournalFileOpenLock <: BaseJournalFileLock
    lock_obj::Any

    function JournalFileOpenLock(file_path::String, grace_period::Union{Nothing,Int}=30)
        return new(optuna.storages.journal.JournalFileOpenLock(file_path, grace_period))
    end
end

"""
    JournalFileBackend(
        file_path::String; 
        lock_obj::Union{Nothing,BaseJournalFileLock}=nothing
    )

File storage class for Journal log backend.
For further information see the [JournalFileBackend](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.storages.journal.JournalFileBackend.html) in the Optuna python documentation.

## Arguments
- `file_path::String`: Path of file to persist the log to.

## Keyword Arguments
- `lock_obj::Union{Nothing,BaseJournalFileLock}=nothing`: Lock object for process exclusivity. An instance of [JournalFileSymlinkLock](@ref) and [JournalFileOpenLock](@ref) can be passed.
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
    JournalRedisBackend(
        url::String, 
        use_cluster::Bool=false, 
        prefix::String=""
    )

Redis storage class for Journal log backend.
For further information see the [JournalRedisBackend](https://optuna.readthedocs.io/en/stable/reference/generated/optuna.storages.journal.JournalRedisBackend.html) in the Optuna python documentation.

## Arguments
- `url::String`: URL of the redis storage.
- `use_cluster::Bool=false`: Flag whether you use the Redis cluster.
- `prefix::String=""`: Prefix of the preserved key of logs. This is useful when multiple users work on one Redis server.
"""
struct JournalRedisBackend <: BaseJournalBackend
    backend::Any

    function JournalRedisBackend(url::String, use_cluster::Bool=false, prefix::String="")
        add_conda_pkg("redis-py"; version=">=7,<8")
        return new(optuna.storages.journal.JournalRedisBackend(url, use_cluster, prefix))
    end
end
