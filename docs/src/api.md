# Reference

This page groups the public Optuna.jl API by workflow. Each section starts with how the pieces are normally used, followed by the detailed docstrings.

## Study workflow

Create a `Study` when you want Optuna to manage a group of trials for one objective. Use `optimize` for the standard loop, or use `ask` and `tell` when you need full control over trial execution.

```@docs
Study
optimize
ask
tell
load_study
delete_study
copy_study
best_trial
best_trials
best_params
best_params_all
best_value
best_values
directions
```

## Trial search spaces

Trial suggestion functions define the parameter search space. Put them inside the objective when the space is conditional or dynamic. Report intermediate values when you want pruners to make early-stopping decisions.

```@docs
Trial
FixedTrial
suggest_int
suggest_float
suggest_categorical
report
should_prune
is_frozen
set_user_attr
```

## Storage

Storage backends keep Optuna study metadata and trial history. Use `InMemoryStorage` for short experiments, `RDBStorage` for persistent relational storage, and `JournalStorage` for Optuna journal backends.

```@docs
RDBStorage
InMemoryStorage
JournalStorage
get_all_study_names
create_sqlite_url
create_mysql_url
create_redis_url
```

## Journal storage

Journal backends are useful when you want Optuna's append-only journal storage. File locks coordinate access when multiple processes write to the same journal file.

```@docs
JournalFileBackend
JournalRedisBackend
JournalFileSymlinkLock
JournalFileOpenLock
```

## Artifacts

Artifacts store trial-associated data separately from scalar objective values. Optuna.jl writes artifact dictionaries as JLD2 files through a filesystem artifact store.

```@docs
FileSystemArtifactStore
ArtifactMeta
upload_artifact
get_all_artifact_meta
download_artifact
```

## Sampler

Samplers decide which parameter values are suggested next. `RandomSampler` is useful as a baseline, `TPESampler` is a practical default for many single-objective searches, and the other samplers cover Gaussian-process, evolutionary, grid, quasi-Monte-Carlo, brute-force, and partially fixed workflows.

```@docs
RandomSampler
TPESampler
GPSampler
CmaEsSampler
NSGAIISampler
NSGAIIISampler
GridSampler
QMCSampler
BruteForceSampler
PartialFixedSampler
```

## Pruner

Pruners decide whether a trial should stop early from intermediate values reported with `report`. Choose a conservative pruner when trial results are noisy, and a more aggressive pruner when each trial is expensive and early signals are reliable.

```@docs
MedianPruner
NopPruner
PatientPruner
PercentilePruner
SuccessiveHalvingPruner
HyperbandPruner
ThresholdPruner
WilcoxonPruner
```

## Multi-objective crossover

These crossover strategies are used with Optuna's evolutionary multi-objective samplers.

```@docs
UniformCrossover
BLXAlphaCrossover
SPXCrossover
SBXCrossover
VSBXCrossover
UNDXCrossover
```

## Utilities

Optuna.jl uses CondaPkg for Python dependencies. These helpers are available when optional Python packages must be checked or added.

```@docs
is_conda_pkg_installed
add_conda_pkg
```
