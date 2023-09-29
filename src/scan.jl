using .Threads: @threads

function scan_threads!(f::F, y::AbstractVector) where {F <:Function}
  l = length(y)
  k = ceil(Int, log2(l))
  # do reduce phase
  for j = 1:k
    @threads for i = 2^j:2^j:min(l, 2^k)
      @inbounds y[i] = f(y[i - 2^(j - 1)], y[i])
    end
  end
  # do expand phase
  for j = (k - 1):-1:1
    @threads for i = (3*2^(j - 1)):2^j:min(l, 2^k)
      @inbounds y[i] = f(y[i - 2^(j - 1)], y[i])
    end
  end
  return y
end

function scan_serial!(f::F,x::AbstractVector) where {F <: Function}
  for i=2:length(x)
    x[i] = f(x[i],x[i-1])
  end
  return(x)
end

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
  @inbounds for i=(length(x[1])-remainder+1):length(x[1])
    setindex!.(x,f(getindex.(x,i-1),getindex.(x,i)),i)
  end
  return(x)
end

function scan_simd!(f::F, x::AbstractVector{T}, v::Val{N}=Val(8);
                    identity::T=zero(T)) where {F, T, N}
  remainder = length(x) % N
  s = Vec{N,T}(identity)
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
  @inbounds for i=(length(x)-remainder+1):length(x)
    setindex!(x,f(getindex(x,i-1),getindex(x,i)),i)
  end
  return(x)
end
