module SignedPetriNets
export AbstractSignedPetriNet, SignedPetriNetUntyped, SignedPetriNet,
  OpenSignedPetriNetUntyped, OpenSignedPetriNetObUntyped, OpenSignedPetriNet, OpenSignedPetriNetOb,
  AbstractLabelledSignedPetriNet, LabelledSignedPetriNet, LabelledSignedPetriNetUntyped,
  OpenLabelledSignedPetriNetUntyped, OpenLabelledSignedPetriNetObUntyped,
  OpenLabelledSignedPetriNet, OpenLabelledSignedPetriNetOb

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
    add_part!(pn′, :L; ls=snames[ls], lt=tnames[lt], sgn=sign_lookup[sign])
  end
  pn′
end

function (::Type{T})(pn::AbstractPetriNet, signs::Vararg) where T <: AbstractSignedPetriNet
  T(pn, collect(signs))
end

@present SchLabelledSignedPetriNet <: SchSignedPetriNet begin
  Name::AttrType

  tname::Attr(T, Name)
  sname::Attr(S, Name)
end

@abstract_acset_type AbstractLabelledSignedPetriNet <: AbstractSignedPetriNet
@acset_type LabelledSignedPetriNetUntyped(SchLabelledSignedPetriNet, index=[:it, :is, :ot, :os]) <: AbstractLabelledSignedPetriNet
const LabelledSignedPetriNet = LabelledSignedPetriNetUntyped{Bool, Symbol}
const OpenLabelledSignedPetriNetObUntyped, OpenLabelledSignedPetriNetUntyped = OpenACSetTypes(LabelledSignedPetriNetUntyped, :S)
const OpenLabelledSignedPetriNetOb, OpenLabelledSignedPetriNet = OpenLabelledSignedPetriNetObUntyped{Bool, Symbol}, OpenLabelledSignedPetriNetUntyped{Bool, Symbol}

Open(p::LabelledSignedPetriNet) = OpenLabelledSignedPetriNet(p, map(x -> FinFunction([x], ns(p)), 1:ns(p))...)
Open(p::LabelledSignedPetriNet, legs...) = begin
  s_idx = Dict(sname(p, s) => s for s in 1:ns(p))
  OpenLabelledSignedPetriNet(p, map(l -> FinFunction(map(i -> s_idx[i], l), ns(p)), legs)...)
end

end
