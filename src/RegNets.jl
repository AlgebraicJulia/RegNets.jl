module RegNets
export SignedGraph

using Catlab, Catlab.CategoricalAlgebra
using Catlab.Graphs

@present SchSignedGraph(FreeSchema) begin
  V::Ob
  E::Ob
  src::Hom(E, V)
  tgt::Hom(E, V)

  Sign::AttrType
  sgn::Attr(E, Sign)
end

@acset_type SignedGraph(SchSignedGraph, index=[:src, :tgt]) <: AbstractGraph

end
