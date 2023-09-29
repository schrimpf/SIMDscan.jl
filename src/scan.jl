@doc raw"""
    scan_serial!(f::F,x::AbstractVector) where {F <: Function}

Replaces the vector `x` with the scan of `x` using `f`. That is,
```math
\begin{bmatrix}
x[1] \\
f(x[2],x[1]) \\
f(x[3],f(x[2],x[1])) \\
⋮
\end{bmatrix}

# Examples
```jl-doctest
julia> scan_serial!(+,[1,2,3,4])
4-element Vector{Int64}:
  1
  3
  6
 10
```
"""
function scan_serial!(f::F,x::AbstractVector) where {F <: Function}
  for i=2:length(x)
    x[i] = f(x[i],x[i-1])
  end
  return(x)
end

@doc raw"""
    scan_serial!(f::F,x::NTuple{K, AbstractVector{T}}) where {F <: Function, K, T}

In place scan for a function that takes two `K` tuples as arguments. 
Replaces the tuple of vectors `x` with the scan. 

# Examples
```jl-doctest
julia> scan_serial!((x,y)->(x[1]+y[1], x[2]*y[2]),([1,2,3,4],[1,2,3,4]))
([1, 3, 6, 10], [1, 2, 6, 24])
```
"""
function scan_serial!(f::F,x::NTuple{K, AbstractVector{T}}) where {F <: Function, K, T}
  @assert length(unique(length.(x)))==1
  for i=2:length(x[1])
    setindex!.(x, f(getindex.(x,i-1),getindex.(x,i)), i)
  end
  return(x)
end


m_to_n(::Val{N},::Val{N}) where N = (N,)
function m_to_n(::Val{M},::Val{N}) where {M, N}
  @assert M < N
  (m_to_n(Val(M),Val(N-1))..., N)
end
function shiftleftmask(::Val{N}, ::Val{S}) where {N,S}
  @assert S>0
  Val((m_to_n(Val(N),Val(N+S-1))...,m_to_n(Val(0),Val(N-S-1))...))
end

@generated function scan_vec(f::F, x::NTuple{K, Vec{N,T}},identity::NTuple{K, Vec{N,T}}) where {F, K, N, T}
  @assert N & (N-1) == 0 # check that N is a power of 2
  ex= :(
    shx=shufflevector.(x,identity, shiftleftmask(Val(N),Val(1)));
    x=f(shx,x);
    )
  for j=1:(ceil(Int,log2(N))-1)
    ex= :($(ex);
    shx=shufflevector.(x,identity, shiftleftmask(Val(N),Val($(2^j))));
    x = f(shx,x);
    ) 
  end
  return(ex)
end
@generated function scan_vec(f::F, x::Vec{N,T},identity::Vec{N,T}) where {F, N, T}
  @assert N & (N-1) == 0 # check that N is a power of 2
  ex= :(x = f(shufflevector(x,identity, shiftleftmask(Val(N),Val(1))),x))
  for j=1:(ceil(Int,log2(N))-1)
    ex = :($(ex); x = f(shufflevector(x,identity, shiftleftmask(Val(N),Val($(2^j)))),x))
  end
  return(ex)
end

@doc raw"""
    scan_simd!(f::F, x::NTuple{K, AbstractVector{T}}, v::Val{N}=Val(8); identity::NTuple{K,T}=ntuple(i->zero(T),Val(K))) where {F, K, T, N}

In place scan for an associative function that takes two `K` tuples as arguments. 
Replaces the tuple of vectors `x` with the scan. 

`identity` should be a left identity under `f`. That is, `f(identity, y) = y` for all `y`.

`T`, must be a type that can be loaded onto registers, i.e. one of `SIMD.VecTypes`. 

`f` must be associative. Otherwise, this will give incorrect results.

`Val(N)` specifies the SIMD vector width used. The default of `8` should give good performance on CPUs with AVX512 for which 8 Float64s fill the 512 bits available. 

# Examples
```jl-doctest
julia> scan_simd!((x,y)->(x[1]+y[1], x[2]*y[2]),([1,2,3,4],[1,2,3,4]))
([1, 3, 6, 10], [1, 2, 6, 24])
```
"""
function scan_simd!(f::F, x::NTuple{K, AbstractVector{T}}, v::Val{N}=Val(8);
                    identity::NTuple{K,T}=ntuple(i->zero(T),Val(K))) where {F, K, T, N}
  remainder = length(x[1]) % N
  s = Vec{N,T}.(identity)
  @inbounds for i=1:N:(length(x[1]) - remainder)
    xvec=vload.(Vec{N,T},x,i)
    xvec = scan_vec(f,xvec,s)
    vstore.(xvec,x,i)
  end
  @inbounds for i=1:N:(length(x[1])-remainder)
    lastx = Vec{N,T}.(getindex.(x,i+N-1))
    xvec=vload.(Vec{N,T},x,i)
    xvec=f(s,xvec)
    vstore.(xvec,x,i)
    s = f(s,lastx)
  end
  @inbounds for i=max(length(x[1])-remainder+1,2):length(x[1])
    setindex!.(x,f(getindex.(x,i-1),getindex.(x,i)),i)
  end
  return(x)
end

@doc raw"""
    scan_simd!(f::F, x::AbstractVector{T}, v::Val{N}=Val(8);identity::T=zero(T)) where {F, T, N}
    
In place scan for an associative function. 

`identity` should be a left identity under `f`. That is, `f(identity, y) = y` for all `y`.

`T`, must be a type that can be loaded onto registers, i.e. one of `SIMD.VecTypes`. 

`f` must be associative. Otherwise, this will give incorrect results.

`Val(N)` specifies the SIMD vector width used. The default of `8` should give good performance on CPUs with AVX512 for which 8 Float64s fill the 512 bits available. 

# Examples
```jl-doctest
julia> scan_simd!(+,[1,2,3,4])
4-element Vector{Int64}:
  1
  3
  6
 10
```
"""
function scan_simd!(f::F, x::AbstractVector{T}, v::Val{N}=Val(8);
                    identity::T=zero(T)) where {F, T, N}              
  remainder = length(x) % N
  s = Vec{N,T}(identity)
  @show s
  @inbounds for i=1:N:(length(x) - remainder)
    xvec=vload(Vec{N,T},x,i)    
    xvec = scan_vec(f,xvec,s)
    vstore(xvec,x,i)
  end
  @inbounds for i=1:N:(length(x)-remainder)
    lastx = Vec{N,T}(getindex(x,i+N-1))
    xvec=vload(Vec{N,T},x,i)
    xvec=f(s,xvec)
    vstore(xvec,x,i)
    s = f(lastx,s)
  end
  @show x
  @inbounds for i=max(length(x)-remainder+1,2):length(x)
    setindex!(x,f(getindex(x,i-1),getindex(x,i)),i)
    @show x
  end
  return(x)
end
