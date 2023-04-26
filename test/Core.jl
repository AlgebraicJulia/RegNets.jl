module TestCore

using Test

using RegNets
using Catlab, Catlab.CategoricalAlgebra
using Catlab.Graphs


@test SignedGraph <: AbstractGraph

sg = @acset SignedGraph{Bool} begin
  V=3
  E=3

  src = [1,    2,    3]
  tgt = [2,    3,    1]
  sgn = [true, true, false]
end

@test nv(sg) == 3
@test ne(sg) == 3

end
