using Documenter
using Literate

const literate_dir = joinpath(@__DIR__, "literate")
const generated_dir = joinpath(@__DIR__, "src", "generated")

@info "Loading RegNets"
using RegNets, RegNets.ASKEMRegNets, RegNets.SignedPetriNets

const no_literate = "--no-literate" in ARGS
if !no_literate
  @info "Building Literate.jl docs"

  # Set Literate.jl config if not being compiled on recognized service.
  config = Dict{String,String}()
  if !(haskey(ENV, "GITHUB_ACTIONS") || haskey(ENV, "GITLAB_CI"))
    config["nbviewer_root_url"] = "https://nbviewer.jupyter.org/github/AlgebraicJulia/RegNets.jl/blob/gh-pages/dev"
    config["repo_root_url"] = "https://github.com/AlgebraicJulia/RegNets.jl/blob/master/docs"
  end

  for (root, dirs, files) in walkdir(literate_dir)
    out_dir = joinpath(generated_dir, relpath(root, literate_dir))
    for file in files
      f,l = splitext(file)
      if l == ".jl" && !startswith(f, "_")
        Literate.markdown(joinpath(root, file), out_dir;
          config=config, documenter=true, credit=false)
        Literate.notebook(joinpath(root, file), out_dir;
          execute=true, documenter=true, credit=false)
      end
    end
  end
end

@info "Building Documenter.jl docs"
makedocs(
  modules   = [RegNets],
  format    = Documenter.HTML(
    assets = ["assets/analytics.js"],
  ),
  sitename  = "RegNets.jl",
  doctest   = false,
  checkdocs = :none,
  pages     = Any[
    "RegNets.jl" => "index.md",
    "Examples" => Any[
      "generated/ASKEMRegNets.md",
    ],
    "Library Reference" => "api.md",
  ]
)

@info "Deploying docs"
deploydocs(
  target = "build",
  repo   = "github.com/AlgebraicJulia/RegNets.jl.git",
  branch = "gh-pages"
)
