#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# artifacts.jl
abstract type BaseArtifactStore end

#journal.jl
abstract type BaseJournalFileLock end

abstract type BaseJournalBackend end

# pruners.jl
abstract type BasePruner end

# samplers.jl
abstract type BaseSampler end

# storage.jl
abstract type BaseStorage end

# study.jl
"""
    Study(study, artifact_stpre, storage)

This data structure represents an Optuna study and its corresponding artifact and data storage. A study is a collection of trials that share the same optimization objective.
"""
struct Study
    study::Any
    artifact_store::Any
    storage::Any
end

# trial.jl

"""
    Trial(trial)

Trial is a data structure wrapper for an Optuna trial.
"""
struct Trial{multithreading}
    trial::Any
end