module SignedPetriNets
export AbstractSignedPetriNet, SignedPetriNetUntyped, SignedPetriNet,
  OpenSignedPetriNetUntyped, OpenSignedPetriNetObUntyped, OpenSignedPetriNet, OpenSignedPetriNetOb,
  AbstractSignedLabelledPetriNet, SignedLabelledPetriNet, SignedLabelledPetriNetUntyped,
  OpenSignedLabelledPetriNetUntyped, OpenSignedLabelledPetriNetObUntyped, OpenSignedLabelledPetriNet, OpenSignedLabelledPetriNetOb,
  AbstractSignedReactionNet, SignedReactionNet, SignedReactionNetUntyped,
  OpenSignedReactionNetUntyped, OpenSignedReactionNetObUntyped, OpenSignedReactionNet, OpenSignedReactionNetOb,
  AbstractSignedLabelledReactionNet, SignedLabelledReactionNet, SignedLabelledReactionNetUntyped,
  OpenSignedLabelledReactionNetUntyped, OpenSignedLabelledReactionNetObUntyped, OpenSignedLabelledReactionNet, OpenSignedLabelledReactionNetOb

using AlgebraicPetri
using Catlab, Catlab.CategoricalAlgebra

import AlgebraicPetri: Open

@present SchSignedPetriNet <: SchPetriNet begin
  L::Ob
  Z2::AttrType

  ls::Hom(L, S)
  lt::Hom(L, T)

  sign::Attr(L, Z2)
end

@abstract_acset_type AbstractSignedPetriNet <: AbstractPetriNet
@acset_type SignedPetriNetUntyped(SchSignedPetriNet, index=[:it, :is, :ot, :os]) <: AbstractSignedPetriNet
const SignedPetriNet = SignedPetriNetUntyped{Bool}
const OpenSignedPetriNetObUntyped, OpenSignedPetriNetUntyped = OpenACSetTypes(SignedPetriNetUntyped, :S)
const OpenSignedPetriNetOb, OpenSignedPetriNet = OpenSignedPetriNetObUntyped{Bool}, OpenSignedPetriNetUntyped{Bool}

Open(p::AbstractSignedPetriNet) = OpenSignedPetriNet(p, map(x -> FinFunction([x], ns(p)), 1:ns(p))...)
Open(p::AbstractSignedPetriNet, legs...) = OpenSignedPetriNet(p, map(l -> FinFunction(l, ns(p)), legs)...)
Open(n, p::AbstractSignedPetriNet, m) = Open(p, n, m)

const sign_lookup = Dict(
  true => true,
  1 => true,
  :+ => true,
  false => false,
  -1 => false,
  :- => false
)

function (::Type{T})(pn::AbstractPetriNet, signs::AbstractVector) where T <: AbstractSignedPetriNet
  pn′ = T()
  copy_parts!(pn′, pn)
  snames = Dict(sname(pn′, s) => s for s in 1:ns(pn′))
  tnames = Dict(tname(pn′, t) => t for t in 1:nt(pn′))
  for (ls, (lt, sign)) in signs
    add_part!(pn′, :L; ls=snames[ls], lt=tnames[lt], sign=sign_lookup[sign])
  end
  pn′
end

function (::Type{T})(pn::AbstractPetriNet, signs::Vararg) where T <: AbstractSignedPetriNet
  T(pn, collect(signs))
end

@present SchSignedLabelledPetriNet <: SchLabelledPetriNet begin
  L::Ob
  Z2::AttrType

  ls::Hom(L, S)
  lt::Hom(L, T)

  sign::Attr(L, Z2)
end

@abstract_acset_type AbstractSignedLabelledPetriNet <: AbstractSignedPetriNet
@acset_type SignedLabelledPetriNetUntyped(SchSignedLabelledPetriNet, index=[:it, :is, :ot, :os]) <: AbstractSignedLabelledPetriNet
const SignedLabelledPetriNet = SignedLabelledPetriNetUntyped{Symbol, Bool}
const OpenSignedLabelledPetriNetObUntyped, OpenSignedLabelledPetriNetUntyped = OpenACSetTypes(SignedLabelledPetriNetUntyped, :S)
const OpenSignedLabelledPetriNetOb, OpenSignedLabelledPetriNet = OpenSignedLabelledPetriNetObUntyped{Symbol, Bool}, OpenSignedLabelledPetriNetUntyped{Symbol, Bool}

Open(p::SignedLabelledPetriNet) = OpenSignedLabelledPetriNet(p, map(x -> FinFunction([x], ns(p)), 1:ns(p))...)
Open(p::SignedLabelledPetriNet, legs...) = begin
  s_idx = Dict(sname(p, s) => s for s in 1:ns(p))
  OpenSignedLabelledPetriNet(p, map(l -> FinFunction(map(i -> s_idx[i], l), ns(p)), legs)...)
end

@present SchSignedReactionNet <: SchReactionNet begin
  L::Ob
  Z2::AttrType

  ls::Hom(L, S)
  lt::Hom(L, T)

  sign::Attr(L, Z2)

  srate::Attr(S, Rate)
end

@abstract_acset_type AbstractSignedReactionNet <: AbstractSignedPetriNet
@acset_type SignedReactionNetUntyped(SchSignedReactionNet, index=[:it, :is, :ot, :os]) <: AbstractSignedReactionNet
const SignedReactionNet{R,C} = SignedReactionNetUntyped{R,C,Bool}
const OpenSignedReactionNetObUntyped, OpenSignedReactionNetUntyped = OpenACSetTypes(SignedReactionNetUntyped, :S)
const OpenSignedReactionNetOb{R,C} = OpenSignedReactionNetObUntyped{R,C,Bool}
const OpenSignedReactionNet{R,C} = OpenSignedReactionNetUntyped{R,C,Bool}

Open(p::SignedReactionNet{R,C}, legs...) where {R,C} = OpenSignedReactionNet{R,C}(p, map(l -> FinFunction(l, ns(p)), legs)...)
Open(p::SignedReactionNet{R,C}) where {R,C} = OpenSignedReactionNet{R,C}(p, map(x -> FinFunction([x], ns(p)), 1:ns(p))...)

@present SchSignedLabelledReactionNet <: SchLabelledReactionNet begin
  L::Ob
  Z2::AttrType

  ls::Hom(L, S)
  lt::Hom(L, T)

  sign::Attr(L, Z2)

  srate::Attr(S, Rate)
end

@abstract_acset_type AbstractSignedLabelledReactionNet <: AbstractSignedReactionNet
@acset_type SignedLabelledReactionNetUntyped(SchSignedLabelledReactionNet, index=[:it, :is, :ot, :os]) <: AbstractSignedLabelledReactionNet
const SignedLabelledReactionNet{R,C} = SignedLabelledReactionNetUntyped{R,C,Symbol,Bool}
const OpenSignedLabelledReactionNetObUntyped, OpenSignedLabelledReactionNetUntyped = OpenACSetTypes(SignedLabelledReactionNetUntyped, :S)
const OpenSignedLabelledReactionNetOb{R,C} = OpenSignedLabelledReactionNetObUntyped{R,C,Symbol,Bool}
const OpenSignedLabelledReactionNet{R,C} = OpenSignedLabelledReactionNetUntyped{R,C,Symbol,Bool}

Open(p::SignedLabelledReactionNet{R,C}) where {R,C} = OpenSignedLabelledReactionNet{R,C}(p, map(x -> FinFunction([x], ns(p)), 1:ns(p))...)
Open(p::SignedLabelledReactionNet{R,C}, legs...) where {R,C} = begin
  s_idx = Dict(sname(p, s) => s for s in 1:ns(p))
  OpenLabelledSignedPetriNet{R,C}(p, map(l -> FinFunction(map(i -> s_idx[i], l), ns(p)), legs)...)
end

end
