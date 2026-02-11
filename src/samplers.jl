#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    RandomSampler(seed=nothing::Union{Nothing,Integer})

An independent sampler that samples randomly.
For further information see the [RandomSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.RandomSampler.html#optuna-samplers-randomsampler) in the Optuna python documentation.

## Arguments
- `seed::Union{Nothing,Integer}=nothing`: Seed for the random number generator.
"""
struct RandomSampler <: BaseSampler
    sampler::Any

    function RandomSampler(seed::Union{Nothing,Integer}=nothing)
        sampler = optuna.samplers.RandomSampler(convert_seed(seed))
        return new(sampler)
    end
end

"""
    TPESampler(;
        consider_prior::Bool=true,
        prior_weight::Float64=1.0,
        consider_magic_clip::Bool=true,
        consider_endpoints::Bool=false,
        n_startup_trials::Integer=10,
        n_ei_candidates::Integer=24,
        gamma::Union{Nothing,Function}=nothing,
        weights::Union{Nothing,Function}=nothing,
        seed::Union{Nothing,Integer}=nothing,
        multivariate::Bool=false,
        group::Bool=false,
        warn_independent_sampling::Bool=true,
        constant_liar::Bool=false,
        constraints_func::Union{Nothing,Function}=nothing,
        categorical_distance_func::Union{Nothing,Function}=nothing,
    )

Sampler using TPE (Tree-structured Parzen Estimator) algorithm.
For further information see the [TPESampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.TPESampler.html#optuna-samplers-tpesampler) in the Optuna python documentation.

## Keyword Arguments
- `consider_prior::Bool=true`: Enhance the stability of Parzen estimator by imposing a Gaussian prior when `true`. The prior is only effective if the sampling distribution is either `FloatDistribution`, or `IntDistribution`. Deprecated in v4.3.0. Will be removed in v6.0.0.
- `prior_weight::Float64=1.0`: The weight of the prior. This argument is used in `FloatDistribution`, `IntDistribution`, and `CategoricalDistribution`.
- `consider_magic_clip::Bool=true`: Enable a heuristic to limit the smallest variances of Gaussians used in the Parzen estimator.
- `consider_endpoints::Bool=false`: Take endpoints of domains into account when calculating variances of Gaussians in Parzen estimator. See the original paper for details on the heuristics to calculate the variances.
- `n_startup_trials::Integer=10`: The random sampling is used instead of the TPE algorithm until the given number of trials finish in the same study.
- `n_ei_candidates::Integer=24`: Number of candidate samples used to calculate the expected improvement.
- `gamma::Union{Nothing,Function}=nothing`: A function that takes the number of finished trials and returns the number of trials to form a density function for samples with low grains. See the original paper for more details.
- `weights::Union{Nothing,Function}=nothing`: A function that takes the number of finished trials and returns a weight for them. See [Making a Science of Model Search: Hyperparameter Optimization in Hundreds of Dimensions for Vision Architectures](https://proceedings.mlr.press/v28/bergstra13.pdf) for more details.
- `seed::Union{Nothing,Integer}=nothing`: Seed for random number generator.
- `multivariate::Bool=false`: If this is `true`, the multivariate TPE is used when suggesting parameters. The multivariate TPE is reported to outperform the independent TPE. See [BOHB: Robust and Efficient Hyperparameter Optimization at Scale](http://proceedings.mlr.press/v80/falkner18a.html) and [the article of the Optuna dev team](https://medium.com/optuna/multivariate-tpe-makes-optuna-even-more-powerful-63c4bfbaebe2) for more details.
- `group::Bool=false`: If this and multivariate are `true`, the multivariate TPE with the group decomposed search space is used when suggesting parameters. The sampling algorithm decomposes the search space based on past trials and samples from the joint distribution in each decomposed subspace. The decomposed subspaces are a partition of the whole search space. Each subspace is a maximal subset of the whole search space, which satisfies the following: for a trial in completed trials, the intersection of the subspace and the search space of the trial becomes subspace itself or an empty set. Sampling from the joint distribution on the subspace is realized by multivariate TPE. If group is `true`, multivariate must be `true` as well.
- `warn_independent_sampling::Bool=true`: If this is `true` and `multivariate=true`, a warning message is emitted when the value of a parameter is sampled by using an independent sampler. If `multivariate=false`, this flag has no effect.
- `constant_liar::Bool=false`: If `true`, penalize running trials to avoid suggesting parameter configurations nearby.
- `constraints_func::Union{Nothing,Function}=nothing`: An optional function that computes the objective constraints. It must take a `FrozenTrial` and return the constraints. The return value must be a sequence of floats. A value strictly larger than 0 means that a constraints is violated. A value equal to or smaller than 0 is considered feasible. If constraints_func returns more than one value for a trial, that trial is considered feasible if and only if all values are equal to 0 or smaller. The constraints_func will be evaluated after each successful trial. The function won’t be called when trials fail or they are pruned, but this behavior is subject to change in the future releases.
- `categorical_distance_func::Union{Nothing,Function}=nothing`: A dictionary of distance functions for categorical parameters. The key is the name of the categorical parameter and the value is a distance function that takes two CategoricalChoiceTypes and returns a float value. The distance function must return a non-negative value. While categorical choices are handled equally by default, this option allows users to specify prior knowledge on the structure of categorical parameters. When specified, categorical choices closer to current best choices are more likely to be sampled.
"""
struct TPESampler <: BaseSampler
    sampler::Any

    function TPESampler(;
        consider_prior::Bool=true,
        prior_weight::Float64=1.0,
        consider_magic_clip::Bool=true,
        consider_endpoints::Bool=false,
        n_startup_trials::Integer=10,
        n_ei_candidates::Integer=24,
        gamma::Union{Nothing,Function}=nothing,
        weights::Union{Nothing,Function}=nothing,
        seed::Union{Nothing,Integer}=nothing,
        multivariate::Bool=false,
        group::Bool=false,
        warn_independent_sampling::Bool=true,
        constant_liar::Bool=false,
        constraints_func::Union{Nothing,Function}=nothing,
        categorical_distance_func::Union{Nothing,Function}=nothing,
    )
        sampler = optuna.samplers.TPESampler(;
            consider_prior=consider_prior,
            prior_weight=prior_weight,
            consider_magic_clip=consider_magic_clip,
            consider_endpoints=consider_endpoints,
            n_startup_trials=n_startup_trials,
            n_ei_candidates=n_ei_candidates,
            gamma=isnothing(gamma) ? nothing : gamma,
            weights=isnothing(weights) ? nothing : weights,
            seed=convert_seed(seed),
            multivariate=multivariate,
            group=group,
            warn_independent_sampling=warn_independent_sampling,
            constant_liar=constant_liar,
            constraints_func=constraints_func,
            categorical_distance_func=categorical_distance_func,
        )
        return new(sampler)
    end
end

"""
    GPSampler(;
        seed::Union{Nothing,Integer}=nothing,
        independent_sampler::Union{Nothing,BaseSampler}=nothing,
        n_startup_trials::Integer=10,
        deterministic_objective::Bool=false,
        constraints_func::Union{Nothing,Function}=nothing,
        warn_independent_sampling::Bool=true,
    )

Sampler using Gaussian process-based Bayesian optimization.
For further information see the [GPSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.GPSampler.html#optuna-samplers-gpsampler) in the Optuna python documentation.

## Keyword Arguments
- `seed::Union{Nothing,Integer}=nothing`: Random seed to initialize internal random number generator. Defaults to `nothing` (a seed is picked randomly).
- `independent_sampler::Union{Nothing,BaseSampler}=nothing`: Sampler used for initial sampling (for the first `n_startup_trials` trials) and for conditional parameters. Defaults to `nothing` (a random sampler with the same seed is used).
- `n_startup_trials::Integer=10`: Number of initial trials.
- `deterministic_objective::Bool=false`: Whether the objective function is deterministic or not. If `true`, the sampler will fix the noise variance of the surrogate model to the minimum value (slightly above 0 to ensure numerical stability). Defaults to `false`. Currently, all the objectives will be assume to be deterministic if `true`.
- `constraints_func::Union{Nothing,Function}=nothing`: An optional function that computes the objective constraints. It must take a `FrozenTrial` and return the constraints. The return value must be a sequence of floats. A value strictly larger than 0 means that a constraints is violated. A value equal to or smaller than 0 is considered feasible. If `constraints_func` returns more than one value for a trial, that trial is considered feasible if and only if all values are equal to 0 or smaller.
- `warn_independent_sampling::Bool=true`:  If this is `true`, a warning message is emitted when the value of a parameter is sampled by using an independent sampler, meaning that no GP model is used in the sampling. Note that the parameters of the first trial in a study are always sampled via an independent sampler, so no warning messages are emitted in this case.
"""
struct GPSampler <: BaseSampler
    sampler::Any

    function GPSampler(;
        seed::Union{Nothing,Integer}=nothing,
        independent_sampler::Union{Nothing,BaseSampler}=nothing,
        n_startup_trials::Integer=10,
        deterministic_objective::Bool=false,
        constraints_func::Union{Nothing,Function}=nothing,
        warn_independent_sampling::Bool=true,
    )
        sampler = optuna.samplers.GPSampler(;
            seed=convert_seed(seed),
            independent_sampler=if isnothing(independent_sampler)
                nothing
            else
                independent_sampler.sampler
            end,
            n_startup_trials=n_startup_trials,
            constraints_func=constraints_func,
            deterministic_objective=deterministic_objective,
            warn_independent_sampling=warn_independent_sampling,
        )
        return new(sampler)
    end
end

"""
    CmaEsSampler(
        x0::Union{Nothing,Dict{String,Any}}=nothing,
        sigma0::Union{Nothing,Float64}=nothing,
        n_startup_trials::Int=1,
        independent_sampler::Union{Nothing,BaseSampler}=nothing,
        warn_independent_sampling::Bool=true,
        seed::Union{Nothing,Integer}=nothing;
        consider_pruned_trials::Bool=false,
        restart_strategy::Union{Nothing,String}=nothing,
        popsize::Union{Nothing,Integer}=nothing,
        inc_popsize::Int=-1,
        use_separable_cma::Bool=false,
        with_margin::Bool=false,
        lr_adapt::Bool=false,
        source_trials::Union{Nothing,Vector{Trial}}=nothing,
    )

A sampler using cmaes as the backend.
For further information see the [CmaEsSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.CmaEsSampler.html#optuna-samplers-cmaessampler) in the Optuna python documentation.

## Arguments
- `x0::Union{Nothing,Dict{String,Any}}=nothing`: A dictionary of an initial parameter values for CMA-ES. By default, the mean of low and high for each distribution is used. Note that `x0` is sampled uniformly within the search space domain for each restart if you specify restart_strategy argument.
- `sigma0::Union{Nothing,Float64}=nothing`: Initial standard deviation of CMA-ES. By default, `sigma0` is set to min_range / 6, where min_range denotes the minimum range of the distributions in the search space.   
- `n_startup_trials::Int=1`: The independent sampling is used instead of the CMA-ES algorithm until the given number of trials finish in the same study.
- `independent_sampler::Union{Nothing,BaseSampler}=nothing`: A BaseSampler instance that is used for independent sampling. The parameters not contained in the relative search space are sampled by this sampler. The search space for CmaEsSampler is determined by `intersection_search_space()`. If `nothing` is specified, [RandomSampler](@ref) is used as the default.
- `warn_independent_sampling::Bool=true`: If this is `true`, a warning message is emitted when the value of a parameter is sampled by using an independent sampler. Note that the parameters of the first trial in a study are always sampled via an independent sampler, so no warning messages are emitted in this case.
- `seed::Union{Nothing,Integer}=nothing`: A random seed for CMA-ES.

## Keyword Arguments
- `consider_pruned_trials::Bool=false`: If this is `true`, the PRUNED trials are considered for sampling.
- `restart_strategy::Union{Nothing,String}=nothing`: Strategy for restarting CMA-ES optimization when converges to a local minimum. If `nothing` is given, CMA-ES will not restart (default). If `ipop` is given, CMA-ES will restart with increasing population size. if `bipop` is given, CMA-ES will restart with the population size increased or decreased. Please see also `inc_popsize` parameter. Deprecated in v4.4.0. Will be removed in v6.0.0.
- `popsize::Union{Nothing,Integer}=nothing`: A population size of CMA-ES.
- `inc_popsize::Int=-1`: Multiplier for increasing population size before each restart. This argument will be used when `restart_strategy = 'ipop'` or `restart_strategy = 'bipop'` is specified. Deprecated in v4.4.0. Will be removed in v6.0.0.
- `use_separable_cma::Bool=false`: If this is `true`, the covariance matrix is constrained to be diagonal. Due to reduce the model complexity, the learning rate for the covariance matrix is increased. Consequently, this algorithm outperforms CMA-ES on separable functions.
- `with_margin::Bool=false`: If this is `true`, CMA-ES with margin is used. This algorithm prevents samples in each discrete distribution (`FloatDistribution` with step and `IntDistribution`) from being fixed to a single point. Currently, this option cannot be used with `use_separable_cma=true`.
- `lr_adapt::Bool=false`: If this is `true`, CMA-ES with learning rate adaptation is used. This algorithm focuses on working well on multimodal and/or noisy problems with default settings. Currently, this option cannot be used with `use_separable_cma=true` or `with_margin=true`.
- `source_trials::Union{Nothing,Vector{Trial}}=nothing`: This option is for Warm Starting CMA-ES, a method to transfer prior knowledge on similar HPO tasks through the initialization of CMA-ES. This method estimates a promising distribution from source_trials and generates the parameter of multivariate gaussian distribution. Please note that it is prohibited to use `x0`, `sigma0`, or `use_separable_cma` argument together.
"""
struct CmaEsSampler <: BaseSampler
    sampler::Any

    # TODO: Check that the source trials are frozen
    function CmaEsSampler(
        x0::Union{Nothing,Dict{String,Any}}=nothing,
        sigma0::Union{Nothing,Float64}=nothing,
        n_startup_trials::Int=1,
        independent_sampler::Union{Nothing,BaseSampler}=nothing,
        warn_independent_sampling::Bool=true,
        seed::Union{Nothing,Integer}=nothing;
        consider_pruned_trials::Bool=false,
        restart_strategy::Union{Nothing,String}=nothing,
        popsize::Union{Nothing,Integer}=nothing,
        inc_popsize::Int=-1,
        use_separable_cma::Bool=false,
        with_margin::Bool=false,
        lr_adapt::Bool=false,
        source_trials::Union{Nothing,Vector{Trial}}=nothing,
    )
        add_conda_pkg("cmaes"; version=">=0.12,<1")
        if !isnothing(source_trials)
            @warn "source_trials are currently not supported. " *
                "Setting source_trails to nothing."
            source_trials = nothing
        end
        sampler = optuna.samplers.CmaEsSampler(
            x0,
            sigma0,
            n_startup_trials,
            isnothing(independent_sampler) ? nothing : independent_sampler.sampler,
            warn_independent_sampling,
            convert_seed(seed);
            consider_pruned_trials=consider_pruned_trials,
            restart_strategy=restart_strategy,
            popsize=popsize,
            inc_popsize=inc_popsize,
            use_separable_cma=use_separable_cma,
            with_margin=with_margin,
            lr_adapt=lr_adapt,
            source_trials=source_trials,
        )
        return new(sampler)
    end
end

"""
    NSGAIISampler(;
        population_size::Int=50,
        mutation_prob::Union{Nothing,Float64}=nothing,
        crossover::Union{Nothing,BaseCrossover}=nothing,
        crossover_prob::Float64=0.9,
        swapping_prob::Float64=0.5,
        seed::Union{Nothing,Integer}=nothing,
        constraints_func::Union{Nothing,Function}=nothing,
        elite_population_selection_strategy::Union{Nothing,Function}=nothing,
        child_generation_strategy::Union{Nothing,Function}=nothing,
        after_trial_strategy::Union{Nothing,Function}=nothing,
    )

Multi-objective sampler using the NSGA-II algorithm.
For further information see the [NSGAIISampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.NSGAIISampler.html#optuna-samplers-nsgaiisampler) in the Optuna python documentation.

## Keyword Arguments
- `population_size::Int=50`: Number of individuals (trials) in a generation. `population_size` must be greater than or equal to `crossover.n_parents`. For [UNDXCrossover](@ref) and [SPXCrossover](@ref), `n_parents=3`, and for the other algorithms, `n_parents=2`.
- `mutation_prob::Union{Nothing,Float64}=nothing`: Probability of mutating each parameter when creating a new individual. If `nothing` is specified, the value 1.0 / len(parent_trial.params) is used where `parent_trial` is the parent trial of the target individual.
- `crossover::Union{Nothing,BaseCrossover}=nothing`: Crossover to be applied when creating child individuals. The available crossovers are listed [here](https://optuna.readthedocs.io/en/stable/reference/samplers/nsgaii.html). `UniformCrossover` is always applied to parameters sampled from `CategoricalDistribution`, and by default for parameters sampled from other distributions unless this argument is specified. For more information on each of the crossover method, please refer to specific crossover documentation.
- `crossover_prob::Float64=0.9`: Probability that a crossover (parameters swapping between parents) will occur when creating a new individual.
- `swapping_prob::Float64=0.5`: Probability of swapping each parameter of the parents during crossover.
- `seed::Union{Nothing,Integer}=nothing`: Seed for random number generator.
- `constraints_func::Union{Nothing,Function}=nothing`: An optional function that computes the objective constraints. It must take a `FrozenTrial` and return the constraints. The return value must be a sequence of floats. A value strictly larger than 0 means that a constraints is violated. A value equal to or smaller than 0 is considered feasible. If `constraints_func` returns more than one value for a trial, that trial is considered feasible if and only if all values are equal to 0 or smaller. The `constraints_func` will be evaluated after each successful trial. The function won’t be called when trials fail or they are pruned, but this behavior is subject to change in the future releases.
                                                                The constraints are handled by the constrained domination. A trial x is said to constrained-dominate a trial y, if any of the following conditions is true:
                                                                        Trial x is feasible and trial y is not.
                                                                        Trial x and y are both infeasible, but trial x has a smaller overall violation.
                                                                        Trial x and y are feasible and trial x dominates trial y.
- `elite_population_selection_strategy::Union{Nothing,Function}=nothing`: The selection strategy for determining the individuals to survive from the current population pool. Default to `nothing`.
- `child_generation_strategy::Union{Nothing,Function}=nothing`: The strategy for generating child parameters from parent trials. Defaults to `nothing`.
- `after_trial_strategy::Union{Nothing,Function}=nothing`: A set of procedure to be conducted after each trial. Defaults to `nothing`.
"""
struct NSGAIISampler <: BaseSampler
    sampler::Any

    function NSGAIISampler(;
        population_size::Int=50,
        mutation_prob::Union{Nothing,Float64}=nothing,
        crossover::Union{Nothing,BaseCrossover}=nothing,
        crossover_prob::Float64=0.9,
        swapping_prob::Float64=0.5,
        seed::Union{Nothing,Integer}=nothing,
        constraints_func::Union{Nothing,Function}=nothing,
        elite_population_selection_strategy::Union{Nothing,Function}=nothing,
        child_generation_strategy::Union{Nothing,Function}=nothing,
        after_trial_strategy::Union{Nothing,Function}=nothing,
    )
        sampler = optuna.samplers.NSGAIISampler(;
            population_size=population_size,
            mutation_prob=mutation_prob,
            crossover=isnothing(crossover) ? nothing : crossover.crossover,
            crossover_prob=crossover_prob,
            swapping_prob=swapping_prob,
            seed=seed,
            constraints_func=constraints_func,
            elite_population_selection_strategy=elite_population_selection_strategy,
            child_generation_strategy=child_generation_strategy,
            after_trial_strategy=after_trial_strategy,
        )
        return new(sampler)
    end
end

"""
    NSGAIIISampler(;
        population_size::Int=50,
        mutation_prob::Union{Nothing,Float64}=nothing,
        crossover::Union{Nothing,BaseCrossover}=nothing,
        crossover_prob::Float64=0.9,
        swapping_prob::Float64=0.5,
        seed::Union{Nothing,Integer}=nothing,
        constraints_func::Union{Nothing,Function}=nothing,
        reference_points::Union{Nothing,AbstractArray{T,2}}=nothing,
        dividing_parameter::Int=3,
        elite_population_selection_strategy::Union{Nothing,Function}=nothing,
        child_generation_strategy::Union{Nothing,Function}=nothing,
        after_trial_strategy::Union{Nothing,Function}=nothing,
    ) where {T}

Multi-objective sampler using the NSGA-III algorithm.
For further information see the [NSGAIIISampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.NSGAIIISampler.html#optuna-samplers-nsgaiiisampler) in the Optuna python documentation.

## Keyword Arguments
- `population_size::Int=50`: Number of individuals (trials) in a generation. `population_size` must be greater than or equal to `crossover.n_parents`. For [UNDXCrossover](@ref) and [SPXCrossover](@ref), `n_parents=3`, and for the other algorithms, `n_parents=2`.
- `mutation_prob::Union{Nothing,Float64}=nothing`: Probability of mutating each parameter when creating a new individual. If `nothing` is specified, the value 1.0 / len(parent_trial.params) is used where `parent_trial` is the parent trial of the target individual.
- `crossover::Union{Nothing,BaseCrossover}=nothing`: Crossover to be applied when creating child individuals. The available crossovers are listed [here](https://optuna.readthedocs.io/en/stable/reference/samplers/nsgaii.html). `UniformCrossover` is always applied to parameters sampled from `CategoricalDistribution`, and by default for parameters sampled from other distributions unless this argument is specified. For more information on each of the crossover method, please refer to specific crossover documentation.
- `crossover_prob::Float64=0.9`: Probability that a crossover (parameters swapping between parents) will occur when creating a new individual.
- `swapping_prob::Float64=0.5`: Probability of swapping each parameter of the parents during crossover.
- `seed::Union{Nothing,Integer}=nothing`: Seed for random number generator.
- `constraints_func::Union{Nothing,Function}=nothing`: An optional function that computes the objective constraints. It must take a `FrozenTrial` and return the constraints. The return value must be a sequence of floats. A value strictly larger than 0 means that a constraints is violated. A value equal to or smaller than 0 is considered feasible. If `constraints_func` returns more than one value for a trial, that trial is considered feasible if and only if all values are equal to 0 or smaller. The `constraints_func` will be evaluated after each successful trial. The function won’t be called when trials fail or they are pruned, but this behavior is subject to change in the future releases.
                                                                The constraints are handled by the constrained domination. A trial x is said to constrained-dominate a trial y, if any of the following conditions is true:
                                                                        Trial x is feasible and trial y is not.
                                                                        Trial x and y are both infeasible, but trial x has a smaller overall violation.
                                                                        Trial x and y are feasible and trial x dominates trial y.
- `reference_points::Union{Nothing,AbstractArray{T,2}}=nothing`: A 2 dimension array with objective dimension columns. Represents a list of reference points which is used to determine who to survive. After non-dominated sort, who out of borderline front are going to survived is determined according to how sparse the closest reference point of each individual is. In the default setting the algorithm uses uniformly spread points to diversify the result. It is also possible to reflect your preferences by giving an arbitrary set of target points since the algorithm prioritizes individuals around reference points.
- `dividing_parameter::Int=3`: A parameter to determine the density of default reference points. This parameter determines how many divisions are made between reference points on each axis. The smaller this value is, the less reference points you have. The default value is 3. Note that this parameter is not used when `reference_points` is not `nothing`.
- `elite_population_selection_strategy::Union{Nothing,Function}=nothing`: The selection strategy for determining the individuals to survive from the current population pool. Default to `nothing`.
- `child_generation_strategy::Union{Nothing,Function}=nothing`: The strategy for generating child parameters from parent trials. Defaults to `nothing`.
- `after_trial_strategy::Union{Nothing,Function}=nothing`: A set of procedure to be conducted after each trial. Defaults to `nothing`.
"""
struct NSGAIIISampler <: BaseSampler
    sampler::Any

    function NSGAIIISampler(;
        population_size::Int=50,
        mutation_prob::Union{Nothing,Float64}=nothing,
        crossover::Union{Nothing,BaseCrossover}=nothing,
        crossover_prob::Float64=0.9,
        swapping_prob::Float64=0.5,
        seed::Union{Nothing,Integer}=nothing,
        constraints_func::Union{Nothing,Function}=nothing,
        reference_points::Union{Nothing,AbstractArray{T,2}}=nothing,
        dividing_parameter::Int=3,
        elite_population_selection_strategy::Union{Nothing,Function}=nothing,
        child_generation_strategy::Union{Nothing,Function}=nothing,
        after_trial_strategy::Union{Nothing,Function}=nothing,
    ) where {T}
        sampler = optuna.samplers.NSGAIIISampler(;
            population_size=population_size,
            mutation_prob=mutation_prob,
            crossover=isnothing(crossover) ? nothing : crossover.crossover,
            crossover_prob=crossover_prob,
            swapping_prob=swapping_prob,
            seed=seed,
            constraints_func=constraints_func,
            reference_points=reference_points,
            dividing_parameter=dividing_parameter,
            elite_population_selection_strategy=elite_population_selection_strategy,
            child_generation_strategy=child_generation_strategy,
            after_trial_strategy=after_trial_strategy,
        )
        return new(sampler)
    end
end

"""
    GridSampler(
        search_space::Dict{String,Vector}, 
        seed::Union{Nothing,Integer}=nothing
    )

Sampler using grid search.
For further information see the [GridSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.GridSampler.html#optuna-samplers-gridsampler) in the Optuna python documentation.

## Arguments
- `search_space::Dict{String, Vector}`: A dictionary whose key and value are a parameter name and the corresponding candidates of values, respectively.
- `seed::Union{Nothing,Integer}=nothing`: A seed to fix the order of trials as the grid is randomly shuffled. This shuffle is beneficial when the number of grids is larger than `n_trials` in `optimize()` to suppress suggesting similar grids. Please note that fixing `seed` for each process is strongly recommended in distributed optimization to avoid duplicated suggestions.
"""
struct GridSampler <: BaseSampler
    sampler::Any

    function GridSampler(
        search_space::Dict{String,Vector}, seed::Union{Nothing,Integer}=nothing
    )
        sampler = optuna.samplers.GridSampler(PyDict(search_space), convert_seed(seed))
        return new(sampler)
    end
end

"""
    QMCSampler(;
        qmc_type::String="sobol",
        scramble::Bool=false,
        seed::Union{Nothing,Integer}=nothing,
        independent_sampler::Union{Nothing,BaseSampler}=nothing,
        warn_asynchronous_seeding::Bool=true,
        warn_independent_sampling::Bool=true,
    )

A Quasi Monte Carlo Sampler that generates low-discrepancy sequences.
For further information see the [QMCSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.QMCSampler.html#optuna-samplers-qmcsampler) in the Optuna python documentation.

## Keyword Arguments
- `qmc_type::String="sobol"`: The type of QMC sequence to be sampled. This must be one of “halton” and “sobol”. Default is “sobol”.
- `scramble::Bool=false`: If this option is `true`, scrambling (randomization) is applied to the QMC sequences.
- `seed::Union{Nothing,Integer}`: A seed for `QMCSampler`. This argument is used only when scramble is `true`. If this is `nothing`, the `seed` is initialized randomly. Default is `nothing`.
- `independent_sampler::Union{Nothing,BaseSampler}=nothing`: A `BaseSampler` instance that is used for independent sampling. The first trial of the study and the parameters not contained in the relative search space are sampled by this sampler. If `nothing` is specified, [RandomSampler](@ref) is used as the default.
- `warn_asynchronous_seeding::Bool=true`: If this is `true`, a warning message is emitted when the scrambling (randomization) is applied to the QMC sequence and the random seed of the sampler is not set manually.
- `warn_independent_sampling::Bool=true`: If this is `true`, a warning message is emitted when the value of a parameter is sampled by using an independent sampler. Note that the parameters of the first trial in a study are sampled via an independent sampler in most cases, so no warning messages are emitted in such cases.
"""
struct QMCSampler <: BaseSampler
    sampler::Any

    function QMCSampler(;
        qmc_type::String="sobol",
        scramble::Bool=false,
        seed::Union{Nothing,Integer}=nothing,
        independent_sampler::Union{Nothing,BaseSampler}=nothing,
        warn_asynchronous_seeding::Bool=true,
        warn_independent_sampling::Bool=true,
    )
        sampler = optuna.samplers.QMCSampler(;
            qmc_type=qmc_type,
            scramble=scramble,
            seed=convert_seed(seed),
            independent_sampler=if isnothing(independent_sampler)
                nothing
            else
                independent_sampler.sampler
            end,
            warn_asynchronous_seeding=warn_asynchronous_seeding,
            warn_independent_sampling=warn_independent_sampling,
        )

        return new(sampler)
    end
end

"""
    BruteForceSampler(
        seed::Union{Nothing,Integer}=nothing, 
        avoid_premature_stop::Bool=false
    )

Sampler using brute force. This sampler performs exhaustive search on the defined search space.
For further information see the [BruteForceSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.BruteForceSampler.html#optuna-samplers-bruteforcesampler) in the Optuna python documentation.

## Arguments
- `seed::Union{Nothing,Integer}=nothing`: A seed to fix the order of trials as the search order randomly shuffled. Please note that it is not recommended using this option in distributed optimization settings since this option cannot ensure the order of trials and may increase the number of duplicate suggestions during distributed optimization.
- `avoid_premature_stop::Bool=false`:If `true`, the sampler performs a strict exhaustive search. Please note that enabling this option may increase the likelihood of duplicate sampling. When this option is not enabled (default), the sampler applies a looser criterion for determining when to stop the search, which may result in incomplete coverage of the search space. For more information, see https://github.com/optuna/optuna/issues/5780.
"""
struct BruteForceSampler <: BaseSampler
    sampler::Any

    function BruteForceSampler(
        seed::Union{Nothing,Integer}=nothing, avoid_premature_stop::Bool=false
    )
        sampler = optuna.samplers.BruteForceSampler(
            convert_seed(seed), avoid_premature_stop
        )

        return new(sampler)
    end
end

"""
    PartialFixedSampler(
        fixed_params::Dict{String,Any}, 
        base_sampler::BaseSampler)

Sampler with partially fixed parameters.
For further information see the [PartialFixedSampler](https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.PartialFixedSampler.html#optuna-samplers-partialfixedsampler) in the Optuna python documentation.

## Arguments
- `fixed_params::Dict{String,Any}`: A dictionary of parameters to be fixed.
- `base_sampler::BaseSampler`: A sampler which samples unfixed parameters.
"""
struct PartialFixedSampler <: BaseSampler
    sampler::Any

    function PartialFixedSampler(fixed_params::Dict{String,Any}, base_sampler::BaseSampler)
        add_conda_pkg("scipy"; version=">=1,<2")
        sampler = optuna.samplers.PartialFixedSampler(
            PyDict{String,Any}(fixed_params), base_sampler.sampler
        )

        return new(sampler)
    end
end
