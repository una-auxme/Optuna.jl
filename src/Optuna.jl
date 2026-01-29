#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module Optuna

using CondaPkg
using PythonCall

const optuna = PythonCall.pynew()

function __init__()
    return PythonCall.pycopy!(optuna, pyimport("optuna"))
end

# multithreading locks
const lk = ReentrantLock()
function thread_safe(f)
    res = nothing
    lock(lk)
    try
        PythonCall.GIL.lock() do
            res = f()
        end
    finally
        unlock(lk)
    end
    return res
end

include("utils.jl")
include("pruners.jl")
include("samplers.jl")
include("storage.jl")
include("artifacts.jl")
include("trial.jl")
include("study.jl")
include("optimize.jl")

# pruners.jl
export MedianPruner, NopPruner, PatientPruner, PercentilePruner
export SuccessiveHalvingPruner, HyperbandPruner, ThresholdPruner, WilcoxonPruner
# samplers.jl
export RandomSampler,
    TPESampler,
    GPSampler,
    CmaEsSampler,
    NSGAIISampler,
    NSGAIIISampler,
    GridSampler,
    QMCSampler,
    BruteForceSampler,
    PartialFixedSampler
# storage.jl
export RDBStorage, InMemoryStorage
# artifacts.jl
export FileSystemArtifactStore, ArtifactMeta
# trial.jl
export Trial
# study.jl
export Study
# optimize.jl
export TrialState

# storage.jl
export get_all_study_names, create_sqlite_url, create_mysql_url
# trial.jl
export suggest_int, suggest_float, suggest_categorical, report, should_prune
# study.jl
export load_study, delete_study, copy_study
export ask, tell
export best_trial, best_params, best_value
export upload_artifact, get_all_artifact_meta, download_artifact
# optimize.jl
export optimize

end
