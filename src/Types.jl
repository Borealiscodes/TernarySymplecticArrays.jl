module Types

using StaticArrays

export Ternary, TernaryVector, TernaryMatrix

"""
    Ternary

A bitstype-aligned data primitive wrapping a single byte of memory to store 
the discrete balanced ternary alphabet {-1, 0, +1}.
"""
struct Ternary
    val::Int8

    @inline function Ternary(v::Integer)
        # Strict structural boundary validation executed during constructor initialization
        @boundscheck if v < -1 || v > 1
            throw(DomainError(v, "Ternary elements must reside strictly within the balanced alphabet {-1, 0, +1}."))
        end
        new(convert(Int8, v))
    end
end

# Define standard type-casting conversions and baseline promotion parameters
Base.convert(::Type{Ternary}, x::Integer) = Ternary(x)
Base.convert(::Type{Int}, x::Ternary) = convert(Int, x.val)
Base.convert(::Type{Float64}, x::Ternary) = convert(Float64, x.val)

Base.promote_rule(::Type{Ternary}, ::Type{<:Integer}) = Int

# Expose standard output formatting for clean visual layout tracing
function Base.show(io::IO, t::Ternary)
    if t.val == 1
        print(io, "+1")
    else
        print(io, string(t.val))
    end
end

# Define stack-allocated, fixed-size mathematical containers 
# leveraging parametric sizing parameters to eliminate heap tracking overhead.
const TernaryVector{N} = SVector{N, Ternary}
const TernaryMatrix{N} = SMatrix{N, N, Ternary}

end # module Types

# Self-contained structural verification block
if abspath(PROGRAM_FILE) == @__FILE__
    using .Types
    using Test
    using StaticArrays

    println("========================================================================")
    println("INITIALIZING ARTIFACT 1.1 RUNTIME TYPE INTEGRITY SUITE")
    println("========================================================================")

    @testset "Ternary Element Validation" begin
        # Test valid instantiation bounds
        t_pos = Ternary(1)
        t_nul = Ternary(0)
        t_neg = Ternary(-1)
        
        @test t_pos.val == 1
        @test t_nul.val == 0
        @test t_neg.val == -1
        
        # Verify boundary enforcement limits
        @test_throws DomainError Ternary(2)
        @test_throws DomainError Ternary(-2)
    end
    println("[✓] Element boundary tracking verified successfully.")

    @testset "Static Tensor Allocation Verification" begin
        # Initialize an 80-dimensional stack vector directly using parametric macros
        raw_data = rand((-1, 0, 1), 80)
        ternary_elements = [Ternary(x) for x in raw_data]
        
        v_80 = TernaryVector{80}(ternary_elements)
        
        @test length(v_80) == 80
        @test eltype(v_80) == Ternary
        
        # Verify that memory is stored inline as a continuous bitstype array
        @test sizeof(v_80) == 80 # 80 elements * 1 byte per element
    end
    println("[✓] Stack-allocated static array geometry verified successfully.")
    println("========================================================================")
end
