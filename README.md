# SIMDscan

A fast scan using SIMD instructions.

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://schrimpf.github.io/SIMDscan.jl/stable/) -->
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://schrimpf.github.io/SIMDscan.jl/dev/)

[![Build Status](https://github.com/schrimpf/SIMDscan.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/schrimpf/SIMDscan.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/schrimpf/SIMDscan.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/schrimpf/SIMDscan.jl)

A scan or prefix operation is a generalization of a cumulative sum.
Given a sequence $x_1, x_2, ... , x_n$, and an associative operator, $\oplus$, the the scan is

```math
x_1, x_1 \oplus x_2, x_3 \oplus x_2 \oplus x_1, ... , x_n \oplus x_{n-1} \oplus \cdots \oplus x_1
```

The scan can be parallelized when $\oplus$ is associative. This package provides an in-place scan implementation using SIMD, `scan_simd!(⊕, x)`. 
For testing and performance comparison, there is also a serial implementation, `scan_serial!(⊕, x)`.

## Usage

[See the docs](https://schrimpf.github.io/SIMDscan.jl/dev/)

## Benchmarks

[See the benchmarks section of the docs](https://schrimpf.github.io/SIMDscan.jl/dev/benchmarks/). With 512 bit SIMD vectors, `scan_simd!` appears to be about 4 time faster. With 256 bit SIMD vectors, the gain is smaller, but still notable. The benchmarks run on github actions, so the resuls and CPU will vary from commit to commit. Of course, the performance will also depend on problem size and the $\oplus$ operator. 

