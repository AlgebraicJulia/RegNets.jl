module ASKEMRegNets
export parse_askem_model, read_askem_model,
  SchASKEMRegNet, ASKEMRegNetUntyped, ASKEMRegNet

using RegNets
using Catlab
using JSON

@present SchASKEMRegNet <: SchRateSignedGraph begin
  C::AttrType
  Name::AttrType
  initial::Attr(V,C)
  vname::Attr(V,Name)
  ename::Attr(E,Name)
end

@abstract_acset_type AbstractASKEMRegNet <: AbstractSignedGraph
@acset_type ASKEMRegNetUntyped(SchASKEMRegNet, index=[:src, :tgt]) <: AbstractASKEMRegNet
const ASKEMRegNet = ASKEMRegNetUntyped{Bool,Float64,Float64,Symbol}

function parse_askem_model(input::AbstractDict)
  regnet = ASKEMRegNet()
  param_vals = Dict(p["id"]=>p["value"] for p in input["model"]["parameters"])
  resolve_val(x) = typeof(x) == String ? param_vals[x] : x

  vertice_idxs = Dict(vertice["id"]=> add_part!(regnet, :V;
    vname=Symbol(vertice["id"]),
    vrate=haskey(vertice, "rate_constant") ? (vertice["sign"] ? 1 : -1) * resolve_val(vertice["rate_constant"]) : 0,
    initial=haskey(vertice, "initial") ? resolve_val(vertice["initial"]) : 0
  ) for vertice in input["model"]["vertices"])

  for edge in input["model"]["edges"]
    rate = 0
    if haskey(edge, "properties") && haskey(edge["properties"], "rate_constant")
      rate = resolve_val(edge["properties"]["rate_constant"])
      rate >= 0 || error("Edge rates must be strictly positive")
    end
    add_part!(regnet, :E; src=vertice_idxs[edge["source"]],
                          tgt=vertice_idxs[edge["target"]],
                          sign=edge["sign"],
                          ename=Symbol(edge["id"]),
                          erate=rate)
  end

  regnet
end
parse_askem_model(input::AbstractString) = parse_askem_model(JSON.parse(input))

function read_askem_model(fname::AbstractString)
  parse_askem_model(JSON.parsefile(fname))
end

end
