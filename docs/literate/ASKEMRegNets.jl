# # Building Regulatory Networks
#
# Here we will build a modeling framework for regulatory networks with Lotka-Volterra semantics using Catlab.jl

using RegNets, RegNets.ASKEMRegNets
using Catlab
using JSON, HTTP, OrdinaryDiffEq, Plots

# ## Define the schema
#
# ### Graph Schema
#
# Catlab provides a basic Graph schema out of the box
#
# ```julia
# @present SchGraph(FreeSchema) begin
#   V::Ob
#   E::Ob
#   src::Hom(E,V)
#   tgt::Hom(E,V)
# end
# ```

to_graphviz(SchGraph, edge_attrs=Dict(:len=>"1.5"))

# ### Basic Signed Graph Schema
#
# The basic structure of a regulatory network can be represented by a signed graph. We simply want to add signs to each edge
#
# ```julia
# @present SchSignedGraph <: SchGraph begin
#   Sign::AttrType
#   sign::Attr(E,Sign)
# end
# ```

to_graphviz(SchSignedGraph, edge_attrs=Dict(:len=>"1.5"))

# ### Basic Signed Graph Schema with Rates
#
# We also may want to keep track of rates of these interactions as well. Implicit rates on each vertice as well as rates on each edge.
#
# ```julia
# @present SchRateSignedGraph <: SchSignedGraph begin
#   A::AttrType
#   vrate::Attr(V,A)
#   erate::Attr(E,A)
# end
# ```

to_graphviz(SchRateSignedGraph, edge_attrs=Dict(:len=>"1.5"))

# ### ASKEM RegNet Schema
#
# For our regulatory network models in ASKEM we also want to have labels on our edges and vertices as well as capture the initial concentrations along with this. We can easily extend our schema with these added attributes:
#
# ```julia
# @present SchASKEMRegNet <: SchRateSignedGraph begin
#  C::AttrType
#  Name::AttrType
#  initial::Attr(V,C)
#  vname::Attr(V,Name)
#  ename::Attr(E,Name)
# end
# ```

to_graphviz(SchASKEMRegNet, edge_attrs=Dict(:len=>"1.5"))

# ## Load the model
#
# ASKEM's model representation repository defines a common structure for us to share models, we can use a simple JSON parser to load that into our new schema.
#
# ```julia
# function parse_askem_model(input::AbstractDict)
#   regnet = ASKEMRegNet()
#   param_vals = Dict(p["id"]=>p["value"] for p in input["model"]["parameters"])
#   resolve_val(x) = typeof(x) == String ? param_vals[x] : x
# 
#   vertice_idxs = Dict(vertice["id"]=> add_part!(regnet, :V;
#     vname=Symbol(vertice["id"]),
#     vrate = 0
#     if haskey(vertice, "rate_constant")
#       vrate = (vertice["sign"] ? 1 : -1) * resolve_val(vertice["rate_constant"])
#     end
#     initial=haskey(vertice, "initial") ? resolve_val(vertice["initial"]) : 0
#   ) for vertice in input["model"]["vertices"])
# 
#   for edge in input["model"]["edges"]
#     rate = 0
#     if haskey(edge, "properties") && haskey(edge["properties"], "rate_constant")
#       rate = resolve_val(edge["properties"]["rate_constant"])
#       rate >= 0 || error("Edge rates must be strictly positive")
#     end
#     add_part!(regnet, :E; src=vertice_idxs[edge["source"]],
#                           tgt=vertice_idxs[edge["target"]],
#                           sign=edge["sign"],
#                           ename=Symbol(edge["id"]),
#                           erate=rate)
#   end
# 
#   regnet
# end
# ```

lotka_volterra = HTTP.get(
  "https://raw.githubusercontent.com/DARPA-ASKEM/Model-Representations/main/regnet/examples/lotka_volterra.json"
).body |> String |> parse_askem_model

# ### Visualize the model
#
# Catlab provides methods which can be overloaded with our new type to get modeling framework specific visualizations.
#
# ```julia
# function Catlab.Graphics.to_graphviz_property_graph(sg::AbstractSignedGraph; kw...)
#   get_attr_str(attr, i) = String(has_subpart(sg, attr) ? subpart(sg, i, attr) : Symbol(i))
#   # make a new property graph
#   pg = PropertyGraph{Any}(;kw...)
#   # add vertices with labels for the visualization
#   map(parts(sg, :V)) do v
#     add_vertex!(pg, label=get_attr_str(:vname, v))
#   end
#   # add edges with labels and change the arrowhead
#   # based on the sign of the edge for the visualization
#   map(parts(sg, :E)) do e
#     add_edge!(pg,
#       sg[e, :src],
#       sg[e, :tgt],
#       label=get_attr_str(:ename, e),
#       arrowhead=(sg[e,:sign] ? "normal" : "tee")
#     )
#   end
#   pg
# end
# ```
#
# Then we can simply call `to_graphviz` and see our model:

to_graphviz(lotka_volterra)

# ## Simulate the model
#
# Next we want to have a method for calculating the dynamics from the model.
#
# We can simply encode the Lotka-Volterra dynamics as a vectorfield function:
#
# ```julia
# function vectorfield(sg::AbstractSignedGraph)
#   (u, p, t) -> [
#     p[:vrate][i]*u[i] + sum(
#         (sg[e,:sign] ? 1 : -1)*p[:erate][e]*u[i]u[sg[e, :src]]
#       for e in incident(sg, i, :tgt); init=0.0)
#     for i in 1:nv(sg)
#   ]
# end
# ```
#
# And we can use that to pass into an `ODEProblem` using DifferentialEquations.jl

ODEProblem(
  vectorfield(lotka_volterra),         # generate the vectorfield
  Float64.(lotka_volterra[:initial]),  # get the initial concentrations
  (0.0, 100.0),                        # set the time period
  lotka_volterra,                      # pass in model which contains the rate parameters
  alg=Tsit5()
) |> solve |> plot

# ## Autogenerated JSON Serialization
#
# Catlab provides automatic serialization to JSON with these types both the models that fit within a given schema as well as the schema itself.

# ### Serialize the model

JSON.print(generate_json_acset(lotka_volterra), 2)

# ### Serialize the ACSet schema

JSON.print(generate_json_acset_schema(SchASKEMRegNet), 2)
