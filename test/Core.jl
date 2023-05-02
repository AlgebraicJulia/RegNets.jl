module TestCore

using Test

using RegNets
using Catlab, Catlab.CategoricalAlgebra
using Catlab.Graphs


@test SignedGraph <: AbstractGraph

sg = @acset SignedGraph begin
  V=3
  E=3

  src = [1,    2,    3]
  tgt = [2,    3,    1]
  sgn = [true, true, false]
end

@test nv(sg) == 3
@test ne(sg) == 3

@test RateSignedGraph <: AbstractSignedGraph

fsg = @acset RateSignedGraph{Number} begin
  V=3
  E=3

  vrate = [1, 1, 1]

  src =  [1,    2,    3]
  tgt =  [2,    3,    1]
  sgn =  [true, true, false]
  erate = [.1, .1, 1]
end

@test nv(fsg) == 3
@test ne(fsg) == 3

end
