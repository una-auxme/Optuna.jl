#
# Copyright (c) 2026 Julian Trommer, Valentin Höpfner, Andreas Hofmann, Josef Kircher, Tobias Thummerer, and contributors
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function test_sampler(sampler::Optuna.BaseSampler; finite_search_space::Bool=false)
    study, test_dir = create_test_study(; sampler=sampler)

    # run a few trials and verify parameter suggestions work
    for _ in 1:10
        trial = ask(study)

        x = 1.0
        if !finite_search_space
            x = suggest_float(trial, "x", 0.0, 10.0)
        end

        y = suggest_int(trial, "y", 1, 100)
        z = suggest_categorical(trial, "z", ["a", "b", "c"])

        @test 0.0 <= x <= 10.0
        @test 1 <= y <= 100
        @test z in ["a", "b", "c"]

        tell(study, trial, x + y)
    end
    return nothing
end

function test_sampler_reproducibility(sampler_constructor)
    # same seed should produce same suggestions
    # This should be tested upstream, but we convert the seed so its here as well
    results1 = Int[]
    results2 = Int[]
    seed = rand(UInt32)
    for (results, run) in [(results1, 1), (results2, 2)]
        sampler = sampler_constructor(seed)

        study, test_dir = create_test_study(; sampler=sampler, study_name="repro_test_$run")
        for _ in 1:3
            trial = ask(study)
            push!(results, suggest_int(trial, "y", 1, 100))
            tell(study, trial, 1.0)
        end
    end

    @test results1 == results2
    return nothing
end

@testset "samplers" begin
    @testset "RandomSampler" begin
        sampler = RandomSampler(42)
        @test sampler isa RandomSampler
        test_sampler(sampler)

        test_sampler_reproducibility(RandomSampler)
    end

    @testset "TPESampler" begin
        sampler = TPESampler(; seed=42)
        @test sampler isa TPESampler
        test_sampler(sampler)

        constructor(seed) = TPESampler(; seed=seed)
        test_sampler_reproducibility(constructor)

        # TODO: Test constraints_func and categorical_distance_func
        @testset "kwargs" begin
            function gamma(x::Integer)
                return min(math.ceil(0.1 * x), 25)
            end
            function weights(x::Integer)
                if x == 0
                    return Float64[]
                elseif x < 25
                    return ones(x)
                else
                    ramp = range(1.0 / x, 1.0; length=x - 25)
                    flat = ones(25)
                    return vcat(collect(ramp), flat)
                end
            end
            sampler = TPESampler(; seed=42, gamma=gamma, weights=weights)
            test_sampler(sampler)

            constructor_kwargs(seed) = TPESampler(; seed=seed, gamma=gamma, weights=weights)
            test_sampler_reproducibility(constructor_kwargs)
        end
    end

    @testset "GPSampler" begin
        sampler = GPSampler(; seed=42)
        @test sampler isa GPSampler
        test_sampler(sampler)

        constructor(seed) = GPSampler(; seed=seed)
        test_sampler_reproducibility(constructor)

        # TODO: Test constraints_func
        @testset "kwargs" begin
            sampler = GPSampler(; seed=42, independent_sampler=RandomSampler(42))
            test_sampler(sampler)

            constructor_kwargs(seed) =
                GPSampler(; seed=seed, independent_sampler=RandomSampler(seed))
            test_sampler_reproducibility(constructor_kwargs)
        end
    end

    @testset "CmaEsSampler" begin
        sampler = CmaEsSampler(nothing, nothing, 1, nothing, true, 42)
        @test sampler isa CmaEsSampler
        test_sampler(sampler)

        constructor(seed) = CmaEsSampler(nothing, nothing, 1, nothing, true, seed)
        test_sampler_reproducibility(constructor)

        # TODO Test source_trials
        @testset "kwargs" begin
            sampler = CmaEsSampler(
                Dict{String,Any}("x" => 5.0, "y" => 5, "z" => ["a"]),
                0.1,
                1,
                RandomSampler(42),
                true,
                42;
                restart_strategy="ipop",
                popsize=50,
            )
            test_sampler(sampler)

            constructor_kwargs(seed) = CmaEsSampler(
                Dict{String,Any}("x" => 5.0, "y" => 5, "z" => ["a"]),
                0.1,
                1,
                RandomSampler(seed),
                true,
                seed;
                restart_strategy="ipop",
                popsize=50,
            )
            test_sampler_reproducibility(constructor_kwargs)
        end
    end

    @testset "NSGAIISampler" begin
        sampler = NSGAIISampler(; seed=42)
        @test sampler isa NSGAIISampler
        test_sampler(sampler)

        constructor(seed) = NSGAIISampler(; seed=seed)
        test_sampler_reproducibility(constructor)

        # TODO: Test constraints_func, elite_population_selection_strategy,
        #       child_generation_strategy, after_trial_strategy
        @testset "kwargs with Crossover" begin
            for crossover in [
                UniformCrossover(),
                BLXAlphaCrossover(),
                SPXCrossover(),
                SBXCrossover(),
                VSBXCrossover(),
                UNDXCrossover(),
            ]
                sampler = NSGAIISampler(; mutation_prob=0.9, crossover=crossover, seed=42)
                test_sampler(sampler)

                function constructor_kwargs(seed)
                    return NSGAIISampler(;
                        mutation_prob=0.9, crossover=crossover, seed=seed
                    )
                end
                test_sampler_reproducibility(constructor_kwargs)
            end
        end
    end

    @testset "NSGAIIISampler" begin
        sampler = NSGAIIISampler(; seed=42)
        @test sampler isa NSGAIIISampler
        test_sampler(sampler)

        constructor(seed) = NSGAIIISampler(; seed=seed)
        test_sampler_reproducibility(constructor)

        # TODO: Test constraints_func, elite_population_selection_strategy,
        #       child_generation_strategy, after_trial_strategy
        @testset "kwargs with Crossover" begin
            for crossover in [
                UniformCrossover(),
                BLXAlphaCrossover(),
                SPXCrossover(),
                SBXCrossover(),
                VSBXCrossover(),
                UNDXCrossover(),
            ]
                sampler = NSGAIIISampler(;
                    mutation_prob=0.9,
                    crossover=crossover,
                    seed=42,
                    reference_points=rand(Float64, 2, 2),
                )
                test_sampler(sampler)

                function constructor_kwargs(seed)
                    return NSGAIIISampler(;
                        mutation_prob=0.9,
                        crossover=crossover,
                        seed=seed,
                        reference_points=rand(Float64, 2, 2),
                    )
                end
                test_sampler_reproducibility(constructor_kwargs)
            end
        end
    end

    @testset "GridSampler" begin
        search_space = Dict("x" => [0.0, 1.0, 10.0], "y" => [1, 5, 100], "z" => ["a", "b"])
        sampler = GridSampler(search_space, 42)
        @test sampler isa GridSampler
        test_sampler(sampler)

        constructor(seed) = GridSampler(search_space, seed)
        test_sampler_reproducibility(constructor)
    end

    @testset "QMCSampler" begin
        sampler = QMCSampler(; seed=42)
        @test sampler isa QMCSampler
        test_sampler(sampler)

        constructor(seed) = QMCSampler(; seed=seed)
        test_sampler_reproducibility(constructor)

        @testset "kwargs" begin
            sampler = QMCSampler(; seed=42, independent_sampler=RandomSampler(42))
            test_sampler(sampler)

            constructor_kwargs(seed) =
                QMCSampler(; seed=seed, independent_sampler=RandomSampler(seed))
            test_sampler_reproducibility(constructor_kwargs)
        end
    end

    @testset "BruteForceSampler" begin
        sampler = BruteForceSampler(42)
        @test sampler isa BruteForceSampler
        test_sampler(sampler; finite_search_space=true)

        test_sampler_reproducibility(BruteForceSampler)
    end

    @testset "PartialFixedSampler" begin
        base_sampler = RandomSampler(42)
        fixed_params = Dict{String,Any}("x" => 5.0, "z" => "a")

        sampler = PartialFixedSampler(fixed_params, base_sampler)
        @test sampler isa PartialFixedSampler
        test_sampler(sampler)

        function constructor(seed)
            base_sampler = RandomSampler(seed)
            return PartialFixedSampler(fixed_params, base_sampler)
        end
        test_sampler_reproducibility(constructor)
    end
end
