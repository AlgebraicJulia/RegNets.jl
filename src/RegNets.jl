module RegNets
export SignedGraph

using Catlab, Catlab.CategoricalAlgebra
using Catlab.Graphs

@present SchSignedGraph <: SchGraph begin
  Sign::AttrType
  sign::Attr(E,Sign)
end

@acset_type SignedGraphUntyped(SchSignedGraph, index=[:src, :tgt]) <: AbstractGraph
const SignedGraph = SignedGraphUntyped{Bool}

include("SignedPetriNets.jl")

end
