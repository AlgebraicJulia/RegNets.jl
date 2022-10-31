using Catlab
using Catlab.CategoricalAlgebra
using Catlab.Theories
import Catlab.Theories: id, dom, codom, compose
using Catlab.CategoricalAlgebra.Categories

import Catlab.CategoricalAlgebra.Categories: CatSize, ob, hom
import Catlab.CategoricalAlgebra: terminal
struct TerminalCatSize <: CatSize end
struct TerminalOb end
struct TerminalHom end
struct TerminalCat <: Cat{TerminalOb, TerminalHom, TerminalCatSize} end

using Catlab.CategoricalAlgebra.Matrices

ob(t::TerminalCat, x) = TerminalOb()
hom(t::TerminalCat, f) = TerminalHom()

dom(f::TerminalHom) = TerminalOb()
codom(f::TerminalHom) = TerminalOb()
id(x::TerminalOb) = TerminalHom()

compose(t::TerminalCat, f, g) = TerminalHom()

""" ElOb{C}

Struct for storing elements of C, that is morphisms from the terminal object in C.
"""
struct ElOb{C, HomC}
    f::HomC
end

ElOb(C::Cat, f) = begin
    dom(C, f) == terminal(C) || error("the hom you provided is not an element. dom $(dom(f))is not terminal.")
    ElOb{C, typeof(f)}(f)
end


CFinSets = TypeCat(FinSet, FinFunction)
FDVect = TypeCat(MatrixDom, Matrix)
terminal(FDVect) = one(MatrixDom{Matrix{Float64}})
ElOb(FDVect, Matrix([1 2.0]'))

struct ElHom{C, HomC}
    dom::ElOb{C, HomC}
    codom::ElOb{C, HomC}
    f::HomC
end

xmat = Matrix([1 2.0]')
ymat = Matrix([3.]')
fxy = ElHom{FDVect, Matrix{Float64}}(ElOb(FDVect, xmat), ElOb(FDVect, ymat), ones(Float64, 2,1))



# todo define the shape of a coslice as a Cat so that elts can be functors into C from that cat
using SparseArrays


matrix(f::FinFunction) = begin
    J = collect(f)
    I = 1:dom(f).n
    sparse(I,J, 1)
end

matrix(FinFunction([1,2,3,3], 3)) * ones(3)
matrix(FinFunction([1,2,3,3], 3))' * ones(4)

F = Functor(n->n, matrix, CFinSets, FDVect)

# Functor(x->FinSet(3), f->[2 3; 1 2], TerminalCat(), FDVect)
