# # Regulatory Networks with Lotka-Volterra Semantics

# ## Step 0. Load necessary packages

using RegNets, RegNets.ASKEMRegNets
using HTTP, OrdinaryDiffEq, Plots

# ## Step 1. Load the model

lotka_volterra = HTTP.get(
  "https://raw.githubusercontent.com/DARPA-ASKEM/Model-Representations/main/regnet/examples/lotka_volterra.json"
).body |> String |> parse_askem_model

# ## Step 2. Simulate the model

ODEProblem(
  vectorfield(lotka_volterra), # generate the vectorfield
  lotka_volterra[:initial],    # get the initial concentrations
  (0.0, 100.0),                # set the time period
  lotka_volterra,              # pass in model which contains the rate parameters
  alg=Tsit5()
) |> solve |> plot
