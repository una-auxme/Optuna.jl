#
# Copyright (c) 2026 Julian Trommer
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module Optuna

using CondaPkg
using PythonCall

const optuna = PythonCall.pynew()

function __init__()
    PythonCall.pycopy!(optuna, pyimport("optuna"))
end

include("pruners.jl")
include("samplers.jl")
include("storage.jl")
include("artifacts.jl")
include("trial.jl")
include("study.jl")
include("optimize.jl")

# pruners.jl
export MedianPruner
# samplers.jl
export RandomSampler
# storage.jl
export RDBStorage
# artifacts.jl
export FileSystemArtifactStore, ArtifactMeta
# trial.jl
export Trial
# study.jl
export Study
# optimize.jl
export TrialState

# storage.jl
export get_all_study_names
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
