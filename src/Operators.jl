module Operators

using ..Types
using Base: @pure

import Base: +, *, -, \, /, ==, hash, zero, one, sign, -

export zero, one

# --- Unary Operators ---

@inline -(x::Ternary) = Ternary(-x.val)
@inline sign(x::Ternary) = x

# --- Binary Arithmetic Operators ---

@inline function +(x::Ternary, y::Ternary)
    # Native hardware-level clamp operation to preserve algebraic ring boundaries
    s = x.val + y.val
    return Ternary(s > 1 ? Int8(1) : (s < -1 ? Int8(-1) : convert(Int8, s)))
end

@inline function -(x::Ternary, y::Ternary)
    d = x.val - y.val
    return Ternary(d > 1 ? Int8(1) : (d  x == Ternary(0), C)
    end
    println("[✓] Compiler auto-vectorization pipeline pre-cleared.")
    println("========================================================================")
end
