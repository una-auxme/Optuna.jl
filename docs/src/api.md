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
```

## Sampler

```@docs
RandomSampler
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

## Study

```@docs
Study
load_study
delete_study
copy_study
ask
tell
best_trial
best_params
best_value
upload_artifact
get_all_artifact_meta
download_artifact
```

## Trial

```@docs
Trial
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
add_conda_pkg
```
