module RegNets
export SignedGraph

using Catlab, Catlab.CategoricalAlgebra
using Catlab.Graphs

@present SchSignedGraph <: SchGraph begin
  Sign::AttrType
  sgn::Attr(E, Sign)
end

@acset_type SignedGraph(SchSignedGraph, index=[:src, :tgt]) <: AbstractGraph


end
