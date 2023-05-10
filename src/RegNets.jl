module RegNets
export AbstractSignedGraph, SchSignedGraph, SignedGraphUntyped, SignedGraph,
  SchRateSignedGraph, RateSignedGraphUntyped, RateSignedGraph,
  vectorfield

using Catlab, Catlab.CategoricalAlgebra
using Catlab.Graphs

@present SchSignedGraph <: SchGraph begin
  Sign::AttrType
  sign::Attr(E,Sign)
end

@abstract_acset_type AbstractSignedGraph <: AbstractGraph
@acset_type SignedGraphUntyped(SchSignedGraph, index=[:src, :tgt]) <: AbstractSignedGraph
const SignedGraph = SignedGraphUntyped{Bool}

@present SchRateSignedGraph <: SchSignedGraph begin
  A::AttrType
  vrate::Attr(V,A)
  erate::Attr(E,A)
end

@acset_type RateSignedGraphUntyped(SchRateSignedGraph, index=[:src, :tgt]) <: AbstractSignedGraph
const RateSignedGraph{R} = RateSignedGraphUntyped{Bool,R}

function (::Type{T})(sg::AbstractSignedGraph) where T <: AbstractSignedGraph
  sg′ = T()
  copy_parts!(sg′, sg)
  sg′
end

function vectorfield(sg::AbstractSignedGraph)
  (u, p, t) -> [
    p[:vrate][i]*u[i] + sum(
        (sg[e,:sign] ? 1 : -1)*p[:erate][e]*u[i]u[sg[e, :src]]
      for e in incident(sg, i, :tgt); init=0.0)
    for i in 1:nv(sg)
  ]
end

include("SignedPetriNets.jl")
include("ASKEMRegNets.jl")

end
