# API Reference

## Storage

```@docs
RDBStorage
InMemoryStorage
JournalStorage
get_all_study_names
create_sqlite_url
create_mysql_url
create_redis_url
```

## Journal

```@docs
JournalFileBackend
JournalRedisBackend
JournalFileSymlinkLock
JournalFileOpenLock
```

## Artifacts

```@docs
FileSystemArtifactStore
ArtifactMeta
upload_artifact
get_all_artifact_meta
download_artifact
```

## Sampler

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

## Crossover

```@docs
UniformCrossover
BLXAlphaCrossover
SPXCrossover
SBXCrossover
VSBXCrossover
UNDXCrossover
```

## Study

```@docs
Study
load_study
delete_study
copy_study
directions
ask
tell
best_trial
best_trials
best_params
best_params_all
best_value
best_values
```

## Trial

```@docs
Trial
FixedTrial
is_frozen
suggest_int
suggest_float
suggest_categorical
report
should_prune
```

## Optimization

```@docs
optimize
```

## Utils

```@docs
is_conda_pkg_installed
add_conda_pkg
```
