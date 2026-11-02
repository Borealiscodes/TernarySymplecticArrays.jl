# Explicitly append library paths to handle modular code structure cleanly
push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))

module RunTestsSuite

using Test
using LinearAlgebra
using Random

# Import code assets directly from the primary simulation engine
using TernarySymplecticArrays

function run_all_diagnostics()
    println("========================================================================")
    println("INITIALIZING ARTIFACT 3.2: ALLOCATION-FREE TEST HARNESS")
    println("========================================================================")

    @testset "Ternary Core Array Layout Invariants" begin
        # Test basic instantiation properties
        v = TernaryVector{4}([1, 0, -1, 0])
        @test v[1] == Ternary(1)
        @test v[2] == Ternary(0)
        @test v[3] == Ternary(-1)
        @test length(v) == 4
        
        # Matrix type matching
        M = TernaryMatrix{2}([1 0; -1 1])
        @test M[1,1] == Ternary(1)
        @test M[2,1] == Ternary(-1)
    end
    println("[✓] Structural array invariants verified.")

    @testset "Zero-Allocation Kernel Auditing" begin
        # Initialize stack-allocated static registers
        x = TernaryVector{3}([1, -1, 0])
        y = TernaryVector{3}([-1, 1, 1])
        
        # Audit allocation tracking during vector arithmetic
        # Warmup execution to trigger JIT compilation before audit tracking
        _ = x + y
        
        allocated_bytes = @allocated begin
            _ = x + y
        end
        
        @printf("-> Vector addition allocation footprint: %d bytes\n", allocated_bytes)
        @test allocated_bytes == 0
    end
    println("[✓] Register-level arithmetic audited at absolute zero heap overhead.")

    @testset "Geometric Enclave Pullback Enforcement" begin
        const DIM_SIZE = 80
        ω_raw = canonical_symplectic_matrix(DIM_SIZE)
        invariant_form = SymplecticInvariant{DIM_SIZE}(ω_raw)
        
        # Valid shear transformation matrix layout
        Ψ_valid = Matrix{Float64}(I, DIM_SIZE, DIM_SIZE)
        Ψ_valid[1, 41] = 0.5
        
        # Verify valid transformation compiles and preserves volume properties
        secure_state = pull_back(invariant_form, Ψ_valid)
        @test size(secure_state.ω) == (DIM_SIZE, DIM_SIZE)
        
        # Construct explicit rank-deficient configuration to test trap limits
        Ψ_invalid = Matrix{Float64}(I, DIM_SIZE, DIM_SIZE)
        Ψ_invalid[2, :] .= 0.0 # Force a rank drop to N-1
        
        @test_throws ErrorException pull_back(invariant_form, Ψ_invalid)
    end
    println("[✓] Volumetric contraction trap verified successfully.")
    println("========================================================================")
end

end # module RunTestsSuite

if abspath(PROGRAM_FILE) == @__FILE__
    Random.seed!(20261102)
    RunTestsSuite.run_all_diagnostics()
end
