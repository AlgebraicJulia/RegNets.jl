module RegNets
export AbstractSignedGraph, SchSignedGraph, SignedGraphUntyped, SignedGraph,
  SchRateSignedGraph, RateSignedGraphUntyped, RateSignedGraph

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

include("SignedPetriNets.jl")

end
