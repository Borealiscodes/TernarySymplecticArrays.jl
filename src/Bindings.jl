module Bindings

using ..Types
using ..Operators

export export_packed_vector, verify_ffi_buffer_exchange

"""
    export_packed_vector(v::TernaryVector{80})::Ptr{UInt8}

Serializes an 80-dimensional static context vector into a 27-byte base-3 packed buffer
and returns a raw C-compatible pointer to the heap-allocated memory chunk.
This is explicitly designed to cross the FFI boundary into wave_v2.rs.
"""
function export_packed_vector(v::TernaryVector{80})::Ptr{UInt8}
    # Pack the vector using our integrated base-3 compression engine
    packed_data = pack_vector_80(v)
    
    # Allocate a continuous, unmanaged memory block matching the 27-byte layout
    # This prevents the Julia Garbage Collector from prematurely sweeping the buffer
    buffer_ptr = Libc.malloc(27)
    
    # Unsafely copy the packed bytes into the raw C-allocated pointer destination
    unsafe_copyto!(convert(Ptr{UInt8}, buffer_ptr), pointer(packed_data), 27)
    
    return convert(Ptr{UInt8}, buffer_ptr)
end

"""
    free_ffi_buffer(ptr::Ptr{UInt8})

Safely releases the C-allocated FFI memory chunk, preventing structural memory leaks
after the Rust wave_v2.rs tracking engine completes its execution cycle.
"""
function free_ffi_buffer(ptr::Ptr{UInt8})
    if ptr != C_NULL
        Libc.free(ptr)
    end
    return true
end

"""
    verify_ffi_buffer_exchange(ptr::Ptr{UInt8})::Vector{UInt8}

A validation routine simulating Rust-side memory access. Materializes a raw pointer 
back into a managed array to check provenance and bitwise accuracy.
"""
function verify_ffi_buffer_exchange(ptr::Ptr{UInt8})::Vector{UInt8}
    if ptr == C_NULL
        throw(ArgumentError("FFI Error: Null pointer passed to verification matrix."))
    end
    
    # Read exactly 27 continuous bytes directly from the raw pointer tracking layer
    result_stream = Vector{UInt8}(undef, 27)
    unsafe_copyto!(pointer(result_stream), ptr, 27)
    
    return result_stream
end

end # module Bindings

# Comprehensive cross-language execution simulation block
if abspath(PROGRAM_FILE) == @__FILE__
    using .Bindings
    using ..Types
    using ..Operators
    using Test
    using Printf

    @printf("========================================================================\n")
    @printf("INITIALIZING ARTIFACT 1.3: CROSS-LANGUAGE FFI BINDING SUITE\n")
    @printf("========================================================================\n\n")

    @printf("[STEP 1] Initializing random 80D context vector on the CPU stack...\n")
    raw_elements = rand((-1, 0, 1), 80)
    v_stack = TernaryVector{80}([Ternary(x) for x in raw_elements])
    @printf("-> Stack vector successfully initialized.\n\n")

    @printf("[STEP 2] Compressing vector and exporting to raw pointer tracking layer...\n")
    c_pointer = export_packed_vector(v_stack)
    @printf("-> Packed buffer generated at raw memory address: %s\n\n", repr(c_pointer))

    @printf("[STEP 3] Simulating Rust-side wave_v2.rs memory ingest & validation...\n")
    # Read the data back out through the simulated FFI memory exchange boundary
    ingested_bytes = verify_ffi_buffer_exchange(c_pointer)
    @printf("-> Ingested packed memory footprint: %d bytes\n", length(ingested_bytes))
    
    # Unpack the FFI stream back into our high-level semantic types to verify absolute identity match
    recovered_elements = Vector{Ternary}(undef, 80)
    idx = 1
    for i in 1:26
        t1, t2, t3 = unpack_ternary_triplet(ingested_bytes[i])
        recovered_elements[idx]   = t1
        recovered_elements[idx+1] = t2
        recovered_elements[idx+2] = t3
        idx += 3
    end
    # Handle the trailing 79, 80 edge case components
    t79, t80, _ = unpack_ternary_triplet(ingested_bytes[27])
    recovered_elements[79] = t79
    recovered_elements[80] = t80

    @testset "FFI Bound Interoperability Verification" begin
        @test length(ingested_bytes) == 27
        @test typeof(c_pointer) == Ptr{UInt8}
        
        # Verify completely lossless conversion across the cross-language layer
        for i in 1:80
            @test recovered_elements[i] == v_stack[i]
        end
    end
    @printf("[✓] Cross-language buffer validation: 100%% Lossless Exchange.\n\n")

    @printf("[STEP 4] Releasing unmanaged memory allocations...\n")
    free_ffi_buffer(c_pointer)
    @printf("[✓] Memory cleared cleanly. FFI tracking loop closed.\n")
    @printf("========================================================================\n")
end
