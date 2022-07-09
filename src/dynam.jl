using Catlab
using Catlab.CategoricalAlgebra
using Catlab.Theories
#using Catlab.CategoricalAlgebra.FinFunctions

struct VectorField{F}
    domain::FinSet
    field::F
end

domain(U::VectorField) = U.domain
tanspace(U::VectorField) = U.domain
vfield(U::VectorField) = U.field

(U::VectorField)(u) = begin
    FinSet(length(u)) == domain(U) || error("Domain Mismatch: state vector has length $(length(u)) was expecting $(domain(U))")
    vfield(U)(u)
end

"""    VectorFieldHom

The structure for storing a homomorphism between VectorField objects. The key axiom is that

    restrict(f, simulate(f, v) - f.v(v)) == 0:domain(f.u)

this means that you can see a version of v inside u by applying the `f_state` map to restrict states of v to a state of u.
Then apply the vector field for u to get a tangent vector for u. Then you can apply the `f_tangent` map to get a tangent vector for v.

    u::VectorField
    v::VectorField
    f_state:   domain(u) → domain(v)
    f_tangent: tan(v) → tan(u)

"""
struct VectorFieldHom
    v::VectorField
    u::VectorField
    f_state::Function
    f_tangent::Function
end

pullback(f::FinFunction) = u -> u[collect(f)]
pushforward(f::FinFunction) = u̇ -> map(codom(f)) do i
    sum(u̇[j] for j in preimage(f, i);init=0.0)
end

""" Pullback{F} wraps F in a struct to make a callable for the action of pulling a function back along `f::F`. 
For `F <: FinFunction`, f: N → M sends Xᴹ to Xᴺ by precomposition.
"""
struct Pullback{F}
    f::F
end

(fꜛ::Pullback{F})(u) where F <: FinFunction = u[collect(f)]

""" PushForward{F} wraps F in a struct to make a callable for the action of pushing a function forward along `f::F`. 
For `F <: FinFunction`, f: N → M sends Xᴺ to Xᴹ by adding over preimages. 
Requires that X be a commutative additive monoid. The method `zero∘eltype(u::Xᴹ)` should return the unit and sum, should use the addition operator. 
"""
struct PushForward{F}
    f::F
end

(fꜜ::PushForward{F})(u̇) where F <: FinFunction = map(codom(f)) do i
    sum(u̇[j] for j in preimage(f, i);init=zero(eltype(u̇)))
end

VectorFieldHom(U, V, f::FinFunction) = begin
    domain(U) == codom(f) || error("FinFunctions induce VectorFieldHoms contravariantly")
    domain(V) == dom(f)    || error("FinFunctions induce VectorFieldHoms contravariantly")
    f_state = pullback(f)
    f_tangent = pushforward(f)
    return VectorFieldHom(U,V,f_state, f_tangent)
end

VectorFieldHom(U, f::Function) = begin
    V = VectorField(codom(f), PushForward(f)∘field(U)∘Pullback(f))
    VectorFieldHom(U, V, f)
end

"""    restrict(f::VectorFieldHom, v::AbstractVector)

Apply f.f_state to send states/tangents in `domain(f.v)` to states/tangents in `domain(f.u)`.
Uses the fact that the state space of a VectorField is a Euclidean Space to treat states and tangents as vectors. 
"""
restrict(f::VectorFieldHom, u::AbstractVector) = f.f_state(u)


"""    pushforward(f::VectorFieldHom, u::AbstractVector)

Apply f.f_tangent to send tangent vectors over `domain(f.u)` to tangent vectors over `domain(f.v)`.
"""
pushforward(f::VectorFieldHom, u::AbstractVector) = f.f_tangent(u)

"""    simulate(f::VectorFieldHom, v::AbstractVector)

Uses f.u to simulate f.v by pulling back the state and pushing forward the tangents.

This name is confusing in the context of numerical simulation.

axiom: restrict(f, simulate(f, v) - f.v(v)) == 0:domain(f.u)
"""
simulate(f::VectorFieldHom, v::AbstractVector) = pushforward(f, f.u(restrict(f, v)))



using Test
X = FinSet(3)
Y = FinSet(2)
f = FinFunction([1,2,2], X, Y)

v = VectorField(X, x->[x[1] - x[2], x[2]])

u = VectorField(Y, y -> [y[1], -y[2]])

ϕ = VectorFieldHom(u, v, y->y[[1,2,2]], ẋ->[ẋ[1], ẋ[2]+ẋ[3]])


LV(α,β,γ,δ) = VectorField(FinSet(2),
    u -> [α*u[1] - β*u[1]*u[2],
          γ*u[1]*u[2] + δ*u[2]])

LV₃(α,β,γ,δ,η) = VectorField(FinSet(3),
u -> [α*u[1] - β*u[1]*u[2],
      γ*u[1]*u[2] + δ*u[2],
      η*u[3]])
ϕₗᵥ(α,β,γ,δ,η) = VectorFieldHom(LV₃(α,β,γ,δ,η),
                 LV(α,β,γ,δ),
                 FinFunction([1,2],FinSet(3)))

f = ϕₗᵥ(1,0.5,0.3,-0.2,0.01)

v₀ = [10.,2,1]
f.f_tangent(f.u(f.f_state(v₀)))

@test f.f_state(v₀) == v₀[[1,2]]
f.u(f.f_state(v₀)) == [0, 5.6]
f.f_tangent(f.u(f.f_state(v₀)))

v₀ = [10.,2.1,1]

@test all(restrict(f, simulate(f, v₀) - f.v(v₀)) .<= 1e-4)

@testset "Inclusion Map" begin
for i in 1:10
    r = rand(domain(f.v).n)
    # @show simulate(f, r)
    # @show f.v(r)
    @test all(restrict(f, simulate(f, r) - f.v(r)) .<= 1e-4)
end
end

