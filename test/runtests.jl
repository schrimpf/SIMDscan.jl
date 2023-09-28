using SIMDscan
using Test

@testset "SIMDscan.jl" begin
  @testset "vector scans" begin
    N = 1000
    x = rand(N)
    for (op, opidentity) ∈ zip([+, *], [0.0, 1.0])
      scanxserial = copy(x)
      scan_serial!(op,scanxserial)
      scanxsimd = copy(x)
      scan_simd!(op,scanxsimd, identity=opidentity)
      @test isapprox(scanxserial, scanxsimd, rtol=sqrt(eps()))
    end
  end

end
