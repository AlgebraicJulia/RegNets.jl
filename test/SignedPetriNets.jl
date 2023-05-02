module TestSignedPetriNets

using Test

using RegNets.SignedPetriNets
using AlgebraicPetri


@test SignedPetriNet <: AbstractPetriNet

lsir = LabelledPetriNet([:S, :I, :R], (:inf, (:S,:I)=>(:I,:I)), (:rec, :I=>:R))

@test SignedLabelledPetriNet(lsir) |> LabelledPetriNet == lsir
@test SignedPetriNet(lsir) |> PetriNet == PetriNet(lsir)

end
