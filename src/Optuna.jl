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

include("types.jl")
include("utils.jl")
include("pruners.jl")
include("journal.jl")
include("storage.jl")
include("artifacts.jl")
include("trial.jl")
include("crossover.jl")
include("samplers.jl")
include("study.jl")
include("optimize.jl")

# pruners.jl
export MedianPruner, NopPruner, PatientPruner, PercentilePruner
export SuccessiveHalvingPruner, HyperbandPruner, ThresholdPruner, WilcoxonPruner
# crossover.jl
export UniformCrossover,
    BLXAlphaCrossover, SPXCrossover, SBXCrossover, VSBXCrossover, UNDXCrossover
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
# journal.jl
export JournalFileSymlinkLock, JournalFileOpenLock, JournalFileBackend, JournalRedisBackend
# storage.jl
export RDBStorage, InMemoryStorage, JournalStorage
# artifacts.jl
export FileSystemArtifactStore, ArtifactMeta
# trial.jl
export Trial
# study.jl
export Study
# optimize.jl
export TrialState

# utils.jl
export is_conda_pkg_installed, add_conda_pkg
# storage.jl
export get_all_study_names, create_sqlite_url, create_mysql_url, create_redis_url
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
