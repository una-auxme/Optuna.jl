# API Reference

## Storage

```@docs
RDBStorage
get_all_study_names
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
