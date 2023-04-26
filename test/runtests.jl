using Test

@testset "Core" begin
  include("Core.jl")
end

@testset "SignedPetriNets" begin
  include("SignedPetriNets.jl")
end
