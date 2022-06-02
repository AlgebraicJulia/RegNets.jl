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

@present SchStockFlow(FreeSchema) begin
  S::Ob
  F::Ob
  L::Ob
  up::Hom(F, S)
  down::Hom(F, S)
  src::Hom(L,S)
  tgt::Hom(L,F)
end

@acset_type StockFlow(SchStockFlow, index=[:up, :down, :src, :tgt])

end
