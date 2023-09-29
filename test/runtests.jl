using SIMDscan
using Test, TestItemRunner

@testitem  "vector scans" begin
  N = 1000
  x = rand(N)    
  for (op, opidentity) ∈ zip([+, *], [0.0, 1.0])
    scanxserial = copy(x)
    scan_serial!(op,scanxserial)
    scanxsimd = copy(x)
    scan_simd!(op,scanxsimd, identity=opidentity)
    @test isapprox(scanxserial, scanxsimd, rtol=sqrt(eps()))
    @test isapprox(accumulate(op, x), scanxserial, rtol=sqrt(eps()))
  end
end

@testitem "autoregressive" begin
    T = 250
    ϵ = randn(T)
    y = similar(ϵ)
    y[1] = ϵ[1]
    α = 0.9
    for t = 2:T 
      y[t] = α*y[t-1] + ϵ[t]
    end 
    ar(y,e) = (e[1] + α*y[1]*e[2], α*y[2]*e[2])
    e=collect(zip(ϵ, rand(T)))
    @test all(ar(ar(ar(e[1],e[2]),e[3]),e[4]) .≈ ar(ar(e[1],ar(e[2],e[3])),e[4]) )
    @test all(ar(ar(e[1],e[2]),ar(e[3],e[4])) .≈ ar(ar(ar(e[1],e[2]),e[3]),e[4]) )

    yacc = [x[1] for x in accumulate(ar,zip(ϵ, Iterators.Repeated(1.0)))]
    @test isapprox(y, yacc, rtol=sqrt(eps()))
    yscanserial,as = scan_serial!(ar, (copy(ϵ), ones(T)))
    @test yscanserial ≈ y    
    yscansimd,at = scan_simd!(ar, (copy(ϵ), ones(T)), identity=(0.0,1.0/α))
    @test yscansimd ≈ y
end

@run_package_tests