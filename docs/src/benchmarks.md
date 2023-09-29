# Benchmarks

## Cumulative Sum

```@example bench
using BenchmarkTools, CpuId, SIMDscan
N = 10_000
x = rand(N);
nothing
```
```@repl bench
cpuinfo()
@benchmark cumsum!($(copy(x)),$x)
@benchmark scan_serial!(+,$(copy(x)))
@benchmark scan_simd!(+,$(copy(x)), Val(16))
```

## AR(1) 

```@example bench
T = 2500
ϵ = randn(T)
y = similar(ϵ)
α = 0.9
function ar1recursize!(y, ϵ, α)
    y[1] = ϵ[1]
    for t = 2:T 
        y[t] = α*y[t-1] + ϵ[t]
    end 
    y
end
ar(y,e) = (e[1] + α*y[1]*e[2], α*y[2]*e[2]);
nothing
```
```@repl bench
@benchmark ar1recursize!($y,$ϵ,$α)
@benchmark scan_serial!($ar, $((copy(ϵ), ones(T))))
@benchmark scan_simd!($ar, $((copy(ϵ), ones(T))), identity=$((0.0,1.0/α)))
```

