# TernarySymplecticArrays.jl

TernarySymplecticArrays.jl is a Julia package for discrete, allocation-free linear algebra over the balanced ternary alphabet

\[
\mathcal{T} = \{-1, 0, +1\}.
\]

The package is designed for deterministic arithmetic, fixed-size tensor-style containers, base-3 packing, and structurally guarded matrix checks in a constrained numerical setting.

## Scope and mathematical model

This repository is intentionally conservative about its mathematical claims.

- The discrete element set is the balanced ternary alphabet \(\{-1, 0, +1\}\).
- A canonical symplectic form is represented by the standard block matrix
  \[
  J = \begin{bmatrix} 0 & I \\ -I & 0 \end{bmatrix}.
  \]
- A real matrix \(\Psi\) is symplectic precisely when it satisfies the invariant
  \[
  \Psi^T J \Psi = J.
  \]
- The scalar condition \(\det(\Psi) = \pm 1\) is a useful sanity check, but it is not the definition of symplecticity.
- This package does not claim a full Lie-theoretic symplectic Lie algebra implementation; it focuses on deterministic discrete map-preservation checks and numerical invariants for a bounded array layer.

## Features

- Fixed-size ternary scalar and static-array types
- Zero-allocation arithmetic patterns for compact fixed-size vectors
- Base-3 packing/unpacking helpers for ternary triplets
- Symplectic-form validation with actual pullback checks
- Deterministic structural guards on matrix dimensions and invariants
- Lean 4 proof files as algebraic sanity checks, not a claim of full geometric classification

## Package layout

- `src/Types.jl` — ternary scalar and static array definitions
- `src/Operators.jl` — arithmetic and packing operators
- `src/Pullbacks.jl` — symplectic-form preservation checks
- `src/Bindings.jl` — FFI-oriented serialization boundary
- `proofs/Lean/` — Lean 4 algebraic validation fragments
- `tests/RunTests.jl` — package validation harness

## Installation

From the repository root:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

Then run the test suite:

```bash
julia --project=. tests/RunTests.jl
```

## Verification notes

This project is deliberately framed as a discrete, bounded, deterministic linear-algebra substrate rather than a general-purpose continuum symplectic engine. The symplectic checks are implemented as explicit matrix invariants rather than broad Lie-theoretic statements.

## License

This project is distributed under the Kinetic-Collapse Autonomous Safeguard and Humanitarian Non-Harm License (Version 1.0).

## Release notes

See `CHANGELOG.md` for the current release history.
