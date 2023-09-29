```@meta
CurrentModule = SIMDscan
```

# SIMDscan

Documentation for [SIMDscan](https://github.com/schrimpf/SIMDscan.jl).

This package provides code for doing a scan using SIMD instructions. Scans are also known as prefix operations.  
The Base Julia function `accumulate` performs the same operation. 

Given a sequence $x_1, x_2, ... , x_n$, and an associative operator, $\oplus$, the the scan is
```math
x_1, x_1 \oplus x_2, x_3 \oplus x_2 \oplus x_1, ... , x_n \oplus x_{n-1} \oplus \cdots \oplus x_1
```

For parallelization, it is essential that $\oplus$ be associative. The function `scan_simd!(⊕, x)` 
computes the scan of `x` in place. 

## Warnings

- `x` must be indexed from `1` to `length(x)`. 

- `⊕` must be associative for `scan_simd!` 

## Multivariate Operations

There is also a method for scanning $⊕: \mathbbm{R}ᴷ→\mathbbm{R}ᴷ$. In this case, `⊕` should accept two `K` tuples as arguments and a `K`-tuple. 
`x` should be a `NTuple{K,AbstractVector}` where each element of the tuple is the sequence of values.  

The multivariate scan can be used to simulate an AR(1) model.
```@example
using SIMDscan  # hide
T = 10
ϵ = randn(T)
# simple recursive version for comparison
y = similar(ϵ)
y[1] = ϵ[1]
α = 0.5
for t = 2:T 
  y[t] = α*y[t-1] + ϵ[t]
end 

# to make ⊕ associative, augment ϵ[t] with a second element that keeps track of the appropriate power of α
⊕(y,e) = (e[1] + α*y[1]*e[2], α*y[2]*e[2])
id = (0.0,1.0/α) # a left identity; ⊕(id,x) = x ∀ x
yscansimd,at = scan_simd!(⊕, (copy(ϵ), ones(T)), identity=id)
[y yscansimd]
```

## Acknowledgements

The following sources were helpful while developing this package:

- [slotin2022](@cite) describes an SIMD implementation for prefix sum with C code
- [nash2021](@cite) has example code for a threaded scan (prefix sum) in Julia,


```@index
```

## Functions

```@autodocs
Modules = [SIMDscan]
```
