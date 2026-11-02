# Explicitly append library paths to handle modular code structure cleanly
push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))

module RunTestsSuite

using Test
using LinearAlgebra
using Random
using Printf

# Import code assets directly from the primary simulation engine
using TernarySymplecticArrays

function run_all_diagnostics()
    println("========================================================================")
    println("INITIALIZING ARTIFACT 3.2: INTEGRATED ALLOCATION & FFI TEST HARNESS")
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
        @test M[1,2] == Ternary(0)
        @test M[2,1] == Ternary(-1)
    end
    println("[✓] Structural array invariants verified.")

    @testset "Zero-Allocation Kernel Auditing" begin
        # Initialize stack-allocated static registers
        x = TernaryVector{3}([1, -1, 0])
        y = TernaryVector{3}([-1, 1, 1])
        
        # Warmup execution to trigger JIT compilation before audit tracking
        _ = x + y
        
        allocated_bytes = @allocated begin
            _ = x + y
        end
        
        @printf("-> Vector addition allocation footprint: %d bytes\n", allocated_bytes)
        @test allocated_bytes == 0
    end
    println("[✓] Register-level arithmetic audited at absolute zero heap overhead.")

    @testset "Base-3 Compression & Register Packing" begin
        # Test exact lossless compression limits across all 27 triplet permutations
        for x1 in [-1, 0, 1], x2 in [-1, 0, 1], x3 in [-1, 0, 1]
            t1, t2, t3 = Ternary(x1), Ternary(x2), Ternary(x3)
            byte = pack_ternary_triplet(t1, t2, t3)
            
            # 3^3 = 27 choices -> byte value must reside within [0, 26]
            @test byte >= 0x00 && byte <= 0x1a
            
            r1, r2, r3 = unpack_ternary_triplet(byte)
            @test r1 == t1
            @test r2 == t2
            @test r3 == t3
        end
    end
    println("[✓] Lossless bit-packing register compression verified.")

    @testset "Cross-Language FFI Buffer Exchange (wave_v2.rs Simulation)" begin
        # Construct an 80-dimensional continuous context tensor sample
        raw_tensor = rand(Int8[-1, 0, 1], 80)
        v_stack = TernaryVector{80}([Ternary(x) for x in raw_tensor])
        
        # Export the memory allocation across the FFI boundary
        c_pointer = export_packed_vector(v_stack)
        @test typeof(c_pointer) == Ptr{UInt8}
        @test c_pointer != C_NULL
        
        # Simulate Rust-side memory capture and reconstruction
        ingested_bytes = verify_ffi_buffer_exchange(c_pointer)
        @test length(ingested_bytes) == 27 # 80 dimensions crushed to 27 bytes
        
        # Unpack and verify absolute identity conservation
        recovered_elements = Vector{Ternary}(undef, 80)
        idx = 1
        for i in 1:26
            t1, t2, t3 = unpack_ternary_triplet(ingested_bytes[i])
            recovered_elements[idx]   = t1
            recovered_elements[idx+1] = t2
            recovered_elements[idx+2] = t3
            idx += 3
        end
        # Handle trailing elements (79, 80) padded at position 81
        t79, t80, _ = unpack_ternary_triplet(ingested_bytes[27])
        recovered_elements[79] = t79
        recovered_elements[80] = t80
        
        for i in 1:80
            @test recovered_elements[i] == v_stack[i]
        end
        
        # Safe memory cleanup release
        @test free_ffi_buffer(c_pointer) == true
    end
    println("[✓] Cross-language FFI pointer exchange executed losslessly.")

    @testset "Geometric Enclave Pullback Enforcement" begin
        const DIM_SIZE = 80
        ω_raw = canonical_symplectic_matrix(DIM_SIZE)
        invariant_form = SymplecticInvariant{DIM_SIZE}(ω_raw)
        
        # Valid volume-preserving shear transformation matrix layout (det = 1.0)
        Ψ_valid = Matrix{Float64}(I, DIM_SIZE, DIM_SIZE)
        Ψ_valid[1, div(DIM_SIZE, 2) + 1] = 0.5
        
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
