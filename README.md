# SIMDscan

A fast scan using SIMD instructions.

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://schrimpf.github.io/SIMDscan.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://schrimpf.github.io/SIMDscan.jl/dev/)

[![Build Status](https://github.com/schrimpf/SIMDscan.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/schrimpf/SIMDscan.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/schrimpf/SIMDscan.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/schrimpf/SIMDscan.jl)

A scan or prefix operation is a generalization of a cumulative sum.
Given a sequence $x_1, x_2, ... , x_n$, and an associative operator, $\oplus$, the the scan is
$$
x_1, x_1 \oplus x_2, x_3 \oplus x_2 \oplus x_1, ... , x_n \oplus x_{n-1} \oplus \cdots \oplus x_1
$$


## Usage

## Benchmarks

## Warnings
