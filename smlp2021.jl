### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 3837e757-3676-419b-b443-7a55a3323a49
begin
	using PlutoUI
	TableOfContents()
end

# ╔═╡ a4c58af2-2bbd-4732-bf6a-2047555222ad
begin
	using MixedModels
	using DataFrames
end

# ╔═╡ c6823866-89ae-4968-a54a-f2e94a5170eb
begin
	using Chain
	using DataFrameMacros
	using CSV
	using StatsBase
	using Dates
	using Arrow
	using Downloads
	using MacroTools: prettify
end


# ╔═╡ 6594dafa-0ee3-11ec-2913-8124854ce8e6
md"""
# SMLP 2021 

Advanced Frequentist stream

Taught by Reinhold Kliegl, Doug Bates & Phillip Alday
"""

# ╔═╡ 1b153a84-7fc7-4cb6-abed-0ec2d3188aa3
md"""
### Day 1, 06.09.21
1. Doug Bates (DB) presents sleepstudy.jl as full example of LMM workflow, incl. zerocorr models, caterpillar & shrinkage plots, geomdof, etc. 
2. Julius Krumbiegel shows the DataFramesMacro & Chain packages for data wrangling in Julia 
3. Reinhold Kliegl (RK) presents MixedModelsTutorial_basics.jl as workflow example on larger dataset (sport science paper)
	
	
### Day 2, 07.09.21
1. RK presents workflow in VS Code
2. RK presents sports science example from MixedModelsTutorial_basics.jl
3. DB presents participant data from /SMLP2021datasets/instructors/Dorothea_Pregla/analysis.jl
"""

# ╔═╡ 26c8a6dd-b56f-49ea-8e3d-277d95dbf997
md"""
# Julia basics

- To do an operation element-wise, i.e. on a vector, you have to broadcast with . 
	array = [1, 2, 3]
	sqrt.(array)
	array .+ 2
- "Symbols" are represented with a colon, ex. :subj, and are used within the MixedModels/DataFrames framework to represent column names 
"""

# ╔═╡ e8d16b19-e7b2-4836-8b4e-cc02e7730a3f
md"""
# Development environments
## Pluto Notebooks

- Open Pluto through the Julia terminal with "using Pluto", "Pluto.run()" and typing the path in the text box.
- A Pluto cell can only contain one statement. If you want to include more than one (for example, when loading more than one package), you have to enclose the lines in 'begin' and 'end'
- To write text, enclose it in md and three "s (i.e. multi-line string preceded with md for Markdown) -- you can use Markdown syntax like **bold**, *italics* and headers with hashtags.
- Embed Julia code in Markdown with string interpolation within your markdown call with the dollar sign, i.e. $(1+1)
- You can output a Pluto notebook as a notebook file, or static HTML/PDF

### DisplayAs & PlutoUI
- DisplayAs.Text() for a purely texual output of tables/model output like youd get in the Julia REPL
- PlutoUI allows you to add a table of contents: TableOfContents()

## VS Code
- Install the Julia extension and (optionally) the R in Julia code highlighting extension 
- Julia markdown files (.jmd) work like R-markdown files, with chunks of text in MD and in Julia, chunks are denoted with three backticks 
- Ctrl/Cmd Enter runs one line, Alt Enter runs the logical block
- create package environment with activate . (the dot means current location) and add packages to that location (the terminal line will show that name in the line)
- you can then select the julia environment at the bottom line of VS code and it will launch Julia in that environment
- Track your project.toml in Git but not your Manifest.toml 

"""

# ╔═╡ 942a740d-77fe-4b95-8b5d-da0cff35e3a7
md"""
# Using R & Python
## RCall
- Macros @rget and @rput
- JellyMe4 for lme4-like objects
- To use R in-line in Julia, use the R string type: R" " (or with three " for multi-line strings)
"""

# ╔═╡ 72d6b331-1fc6-4ff5-9720-b40cbcfc8135
md"""
## PyCall
- pymulti = @pyimport multiprocessing
- pymulti.Worker (or whatever from that package)
- You can also do Python in strings: py" "
- There's also a wrapper for calling EEG package mne in Julia
"""

# ╔═╡ f554e99e-1bbd-4693-824a-b2321275b10e
md"""
# LMM basics

- Standard deviation in the LMM output is in the same scale / unit as the response variable. (Square root of the variance.) 

## Caterpillar plots
- Caterpillar plots visualize the correlation between random slopes and random intercepts
- Caterpillar plots tell you if you have a lot of variation in the subjects -> if everything is very consistent, you might not need that term

## Shrinkage plots
- Shrinkage plots: How much do the points reduce down towards zero -- if it clumps down to the origins, you might not need the random effects
- If it's going down to a horizontal line, you might need the term on the x-axis (often the intercept) but not the term on the y-axis (which may be a slope)
- Participants whose data fits a line very well (337 in sleep study data) don't have as much shrinkage becuase there's not as much room to wiggle the line around, whereas other participants may be shrunk more because their individual lines can be wiggled more without losing so much fit.

## Zerocorr models
- Leaving in a correlation term when its not needed (or otherwise having parameters in a model that aren't necessary) increases the risk of overfitting and adds a source of variability that is not necessary

## Bootstrapping
- Bootstrapping assumes the model is true, generates data and then checks where the values fall. So we assume that the model values are true, and generate data from these, then model these new datasets and extract the parameter values and see the range in which they fall
- Shortest coverage interval shows the most dense (smallest base) interval with 95% of the data, so you can see what range of values 
- Sleepstudy example: See how the range of the correlation term goes from -.4 to 1.0, so you can see that a zero corr model may be better.

## geomdof
- Geometric degrees of freedom: goes beyond just checking how many parameters are in a model -- sometimes removing one term may actually add more DoF / variance 
"""

# ╔═╡ e210b065-219c-4ec9-889f-3d738f69085a
md"""
# Example LMM: Sleepstudy
"""

# ╔═╡ c46ea987-362a-48b6-acfa-23a94a4da3ce
sleepstudy = MixedModels.dataset("sleepstudy")

# ╔═╡ ee87653a-3f2c-498a-a9f6-8b126956ac8c
md"## Basic model"

# ╔═╡ 7abaeca2-1438-454a-902e-e019489d8585
m = fit(MixedModel, @formula(reaction ~ days + (1|subj)), sleepstudy)

# ╔═╡ e81ef784-5858-4803-97e6-099396ebd081
VarCorr(m)

# ╔═╡ fc3b33c6-d86c-481a-84a7-4cf71120924c
md"## Zerocorr model"

# ╔═╡ d7cd2822-2a13-42d8-82f8-e82dafe36fe0
m2 = fit(MixedModel, @formula(reaction ~ 1+days+zerocorr(1+days|subj)), sleepstudy)

# ╔═╡ 5392e206-968b-48f3-a7be-6ba91bdca7a0
url = "https://github.com/RePsychLing/SMLP2021/raw/main/notebooks/data/fggk21.arrow"

# ╔═╡ e5c5583b-eb65-496e-9805-b7c8da218838
df = url |>
	Downloads.download |>
	Arrow.Table |>
	DataFrame;

# ╔═╡ 11661dcd-bfa8-43f7-95f7-3d8b03010bf7
df2 = @chain url begin
	Downloads.download
	Arrow.Table
	DataFrame
end;

# ╔═╡ 6386d5a9-2d24-41af-a443-c21f04310e6a
md"""
- Reference the previous step at any location in a future call with underscore: 

	@chain url begin 
	Downloads.download
	Arrow.Table
	DataFrame
	CSV.write("test.csv", _)

"""

# ╔═╡ f9c68d4a-f141-43ad-8267-5fd3178fdde1
md"""
# DataFramesMacro

-  presentation by Julius Krumbiegel, contributor to Chain and DataFramesMacro

"""

# ╔═╡ aa2645e2-c639-4114-aad2-88bf013293de
md"""

## Chain
- You can use the inline pipe |> when the item before can be taken as the first argument and you don't need additional arguments
- To do that, you could make an anonymous function as a step in the pipeline
	x -> CSV.write("test.csv", x)
- The chain package fixes this problem: 
"""

# ╔═╡ 40bf7d9b-dddd-43b0-bab6-1eaaa01f640a
md"""
### @aside
- Does an operation within a chain but does not keep sending it along the pipeline, i.e. for writing to disk in the middle of a pipeline
"""

# ╔═╡ 445c7416-91a3-4658-a99a-0a5645d933a4
md"""
## Data Wrangling
- transform (= mutate)
- select (= select)
- groupby (= group_by)
- combine (= summarize)
- subset (= filter)
"""

# ╔═╡ 4389e77d-799c-497c-8015-c726938df571
md"""
### transform

- transform takes as first argument a dataframe, then a column (symbol), then a rowwise operator (like an ifelse) and then an output (new column)
- Teritary operator is like an ifelse (the following prints yes if 3 is greater than 1 and no if it is not):
	3 > 1 ? "yes" : "no"
- The rowwise operator should be an anonymous function (in the example below, "x" could be replaced by any label, i.e. "sex" or "row_value")
"""

# ╔═╡ 3534eeee-7c4e-4280-9d74-339967dd49db
transform(df, :Sex =>
	ByRow(x -> x == "female" ? "girl" : "boy") =>
	:type);

# ╔═╡ 76340b70-883b-4f4a-8a18-a1432072e245
md"""
The above will copy the df and make a new column called "Type" 

Below is the short format, via the macro
"""

# ╔═╡ 18f4926f-9fcb-4cfc-8381-792b9bb7df37
@transform(df, :type = :Sex == "female" ? "girl" : "boy");

# ╔═╡ d64e25c9-385e-4a74-af63-928f8a090049
transform(df, :age => (col -> col .+ 1) => :ageplus);

# ╔═╡ 67b2e0f5-041a-4eba-ad5f-ee4ce12d73db
@transform(df, :age + 1);

# ╔═╡ 4b68540c-8100-4bcf-b422-e9b2382309d1
@transform(df, @c :age .- mean(:age));

# ╔═╡ a404eca5-7261-46d0-9b63-f75b3e19277d
md"""
- @c inside of the @transform macro means that its not rowwise (column flag c)
"""

# ╔═╡ 00b8600c-db94-4db5-8f3a-79f82a7f3f11
md"""
### groupby
"""

# ╔═╡ 5df54abb-d69a-4d7b-9e10-a03f07ae3903
summary_table = @chain df begin
	@transform(:type = :Sex == "female" ? "girl" : "boy")
	@groupby(:half = :zScore > 0 ? "upper" : "lower", :type)
	combine(nrow => :n)
end;

# ╔═╡ c68f3f86-78d4-49c6-9652-1c0318c658ee
summary_table

# ╔═╡ 09487ce8-1d61-47b3-b870-4502ef477c1e
md"""
### @transform vs transform
- i.e. the advantages of DataFrameMacros
- (roughly) the transform macro automatically does operations rowwise, whereas if you use transform you have to use ByRow and an anonymous function or broadcast function
"""

# ╔═╡ 88a2208a-7c5e-4aa0-8751-503248363566
md"""
### Saving wrangled dataframes
- @transform! etc. for in-place steps, you'd have to do it in each step (I think)
- you can also do a non-mutating first step so that you have a safe copy, then continuing by changing in place 
"""

# ╔═╡ e75f102a-0fdb-4814-9316-0b33c5bf6824
md"""
### recode
	recode!(df, "Run" => "Endurance", "Star_r" => "Coordination")

Also look up: levels() for releveling
"""

# ╔═╡ 71f77e0c-cd7f-4e51-821b-ed949692bde6
md"""
# LMM Theory

## Orthogonal contrasts
- Sequential difference, sum contrast and treatment constrast coding are not orthogonal because multiple levels contain the same information (i.e. level one of a sequential difference coding takes level 2 compared to level 1, whereas the second level takes level 3 compared to level 2)
- Disadvantages of non-orthogonal contrasts: they are correlated in how they're constructed, so it's sometimes not possible to tell which factor level the variance is coming from -- this variance must then be discarded
- Visual aid of a venn diagramm: orthogonal contrasts both overlap with the DV -- they explain separatable parts of the variance; non-orthogonal contrasts share variance with the DV but also with each other and this space where all three overlap (variance in the DV plus variance in more than one level of the contrasts) must be discarded. This discarding leads to a loss in statistical power.
- The more levels of the predictor you have, i.e. the more indicator variables that come from your contrast coding, the more of these overlapping areas of variance you have that have to be discarded and thus the more power lost.
- The variance described by orthogonal contrasts (by the indicator variables that represent the levels of the orthogonal contrasts) sums up to the R2, the variance described by the model. 

## Correlation parameters
- Correlations between random effects show not "does a kid who runs fast also jump high", that would be at the level of the data. 
- With non-orthogonal coding schemes, watch for if the levels/indicator variables are (negatively) artefactually correlated, because the same underlying levels are in multiple comparisons/levels (ex of star run -- either it's closer to endurance, in which case it will negatively correlate with the difference to sprint speed, or vice versa). 
- ... (still need more info here)

## Comparing nested and non-nested models
- 

"""

# ╔═╡ a6c010dc-f52b-4027-af1f-6bd29671599b
md"""

# Defining LMM models in Julia
- You can assign a column as a Grouping factor (in your contrasts Dict), which will speed up the computation because it tells the model to ignore that column when trying to create contrasts. This is useful for large datasets where there are a lot of levels of the grouping variables (i.e. 10,000 individuals)

"""

# ╔═╡ a6849926-fcb1-485f-b287-e187060a915d
md"""
# Insights from Pregla data
- Some string manipulation, here starting with S, left-padding 0s of the number of digits of the maximum number. Here this was necessary because subject was read in as an integer.
	df.subj = string.('S', lpad.(df.subj, ndigits(maximum(df.subj)), '0'));
- You can filter subsets of data within the MixedModel fit call: 
	m1 = fit(MixedModel, formula,
	filter(:region => ==("2"), df);
	contrasts = cntrsts))
"""

# ╔═╡ e4096878-6523-4d2e-a382-5094fd064657
md"""
# Open questions 
- How do you interpret correlation of random effects? In general, what does it mean if you have a strong correlation between random effects. And if you bootstrap to find the coverage interval, when would this be significant and when would the range be too wide (i.e. if the range is (.2 - .5) vs. (.1 - .9). 
	- RKs paper: https://doi.org/10.3389/fpsyg.2010.00238

- When would you consider removing correlation parameters from some but not all random effect terms?

- How do you interpret caterpillar and shrinkage plots theoretically? What are you looking for to determine whether a term is adding to the fit? And what conclusions can you draw about your model from them?

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Arrow = "69666777-d1a9-59fb-9406-91d4454c9d45"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
Chain = "8be319e6-bccf-4806-a6f7-6fae938471bc"
DataFrameMacros = "75880514-38bc-4a95-a458-c2aea5a3a702"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
MacroTools = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
MixedModels = "ff71e718-51f3-5ec2-a782-8ffcbfa3c316"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
Arrow = "~1.6.2"
CSV = "~0.8.5"
Chain = "~0.4.8"
DataFrameMacros = "~0.1.0"
DataFrames = "~1.2.2"
MacroTools = "~0.5.7"
MixedModels = "~4.1.1"
PlutoUI = "~0.7.9"
StatsBase = "~0.33.10"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Arrow]]
deps = ["ArrowTypes", "BitIntegers", "CodecLz4", "CodecZstd", "DataAPI", "Dates", "Mmap", "PooledArrays", "SentinelArrays", "Tables", "TimeZones", "UUIDs"]
git-tree-sha1 = "b00e6eaba895683867728e73af78a00218f0db10"
uuid = "69666777-d1a9-59fb-9406-91d4454c9d45"
version = "1.6.2"

[[ArrowTypes]]
deps = ["UUIDs"]
git-tree-sha1 = "a0633b6d6efabf3f76dacd6eb1b3ec6c42ab0552"
uuid = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
version = "1.2.1"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "42ac5e523869a84eac9669eaceed9e4aa0e1587b"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.1.4"

[[BitIntegers]]
deps = ["Random"]
git-tree-sha1 = "f50b5a99aa6ff9db7bf51255b5c21c8bc871ad54"
uuid = "c3b6d118-76ef-56ca-8cc7-ebb389d030a1"
version = "0.2.5"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

[[Chain]]
git-tree-sha1 = "cac464e71767e8a04ceee82a889ca56502795705"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.4.8"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "30ee06de5ff870b45c78f529a6b093b3323256a3"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.3.1"

[[CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "2e62a725210ce3c3c2e1a3080190e7ca491f18d7"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.7.2"

[[CodecLz4]]
deps = ["Lz4_jll", "TranscodingStreams"]
git-tree-sha1 = "59fe0cb37784288d6b9f1baebddbf75457395d40"
uuid = "5ba52731-8f18-5e0d-9241-30f10d1ec561"
version = "0.4.0"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[CodecZstd]]
deps = ["TranscodingStreams", "Zstd_jll"]
git-tree-sha1 = "d19cd9ae79ef31774151637492291d75194fc5fa"
uuid = "6b39b394-51ab-5f42-8807-6242bab2b4c2"
version = "0.7.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "727e463cfebd0c7b999bbf3e9e7e16f254b94193"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.34.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "bec2532f8adb82005476c141ec23e921fc20971b"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.8.0"

[[DataFrameMacros]]
deps = ["DataFrames"]
git-tree-sha1 = "508d57ef7b78551cf69c2837d80af5017ce57217"
uuid = "75880514-38bc-4a95-a458-c2aea5a3a702"
version = "0.1.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "f4efaa4b5157e0cdb8283ae0b5428bc9208436ed"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.16"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[ExprTools]]
git-tree-sha1 = "b7e3d17636b348f005f11040025ae8c6f645fe92"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.6"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "a3b7b041753094f3b17ffa9d2e2e07d8cace09cd"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.3"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "f564ce4af5e79bb88ff1f4488e64363487674278"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.5.1"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "60ed5f1643927479f845b0135bb369b031b541fa"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.14"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "b3e5984da3c6c95bcf6931760387ff2e64f508f3"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.1"

[[JSONSchema]]
deps = ["HTTP", "JSON", "URIs"]
git-tree-sha1 = "2f49f7f86762a0fbbeef84912265a1ae61c4ef80"
uuid = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"
version = "0.3.4"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "3d682c07e6dd250ed082f883dc88aee7996bf2cc"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.0"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Lz4_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5d494bc6e85c4c9b626ee0cab05daa4085486ab1"
uuid = "5ced341a-0733-55b8-9ab6-a4889d929147"
version = "1.9.3+0"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "0fb723cd8c45858c22169b2e42269e53271a6df7"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.7"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "JSON", "JSONSchema", "LinearAlgebra", "MutableArithmetics", "OrderedCollections", "SparseArrays", "Test", "Unicode"]
git-tree-sha1 = "575644e3c05b258250bb599e57cf73bbf1062901"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "0.9.22"

[[MathProgBase]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9abbe463a1e9fc507f12a69e7f29346c2cdc472c"
uuid = "fdba3010-5040-5b88-9595-932c9decdf73"
version = "0.7.8"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "2ca267b08821e86c5ef4376cffed98a46c2cb205"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.1"

[[MixedModels]]
deps = ["Arrow", "DataAPI", "Distributions", "GLM", "JSON3", "LazyArtifacts", "LinearAlgebra", "Markdown", "NLopt", "PooledArrays", "ProgressMeter", "Random", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "StatsFuns", "StatsModels", "StructTypes", "Tables"]
git-tree-sha1 = "f318e42a48ec0a856292bafeec6b07aed3f6d600"
uuid = "ff71e718-51f3-5ec2-a782-8ffcbfa3c316"
version = "4.1.1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Mocking]]
deps = ["ExprTools"]
git-tree-sha1 = "748f6e1e4de814b101911e64cc12d83a6af66782"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.2"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "3927848ccebcc165952dc0d9ac9aa274a87bfe01"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "0.2.20"

[[NLopt]]
deps = ["MathOptInterface", "MathProgBase", "NLopt_jll"]
git-tree-sha1 = "d80cb3327d1aeef0f59eacf225e000f86e4eee0a"
uuid = "76087f3c-5699-56af-9a33-bf431cd00edd"
version = "0.6.3"

[[NLopt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "2b597c46900f5f811bec31f0dcc88b45744a2a09"
uuid = "079eb43e-fd8e-5478-9966-2cf3e3edb778"
version = "2.7.0+0"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "bfd7d8c7fd87f04543810d9cbd3995972236ba1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a193d6ad9c45ada72c14b731a318bedd3c2f00cf"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.3.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "12fbe86da16df6679be7521dfb39fbc861e1dc7b"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.1"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "54f37736d8934a12a200edea2f9206b03bdf3159"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.7"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[ShiftedArrays]]
git-tree-sha1 = "22395afdcf37d6709a5a0766cc4a5ca52cb85ea0"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "1.0.0"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "a322a9493e49c5f3a10b50df3aedaf1cdb3244b7"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.1"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3240808c6d463ac46f1c1cd7638375cd22abbccb"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.12"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8cbbc098554648c84f79a463c9ff0fd277144b6c"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.10"

[[StatsFuns]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "46d7ccc7104860c38b11966dd1f72ff042f382e4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.10"

[[StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "ShiftedArrays", "SparseArrays", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "3fa15c1f8be168e76d59097f66970adc86bfeb95"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.6.25"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "8445bf99a36d703a09c601f9a57e2f83000ef2ae"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.7.3"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "d0c690d37c73aeb5ca063056283fde5585a41710"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TimeZones]]
deps = ["Dates", "Future", "LazyArtifacts", "Mocking", "Pkg", "Printf", "RecipesBase", "Serialization", "Unicode"]
git-tree-sha1 = "6c9040665b2da00d30143261aea22c7427aada1c"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.5.7"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─3837e757-3676-419b-b443-7a55a3323a49
# ╟─6594dafa-0ee3-11ec-2913-8124854ce8e6
# ╟─1b153a84-7fc7-4cb6-abed-0ec2d3188aa3
# ╠═26c8a6dd-b56f-49ea-8e3d-277d95dbf997
# ╟─e8d16b19-e7b2-4836-8b4e-cc02e7730a3f
# ╠═942a740d-77fe-4b95-8b5d-da0cff35e3a7
# ╟─72d6b331-1fc6-4ff5-9720-b40cbcfc8135
# ╟─f554e99e-1bbd-4693-824a-b2321275b10e
# ╟─e210b065-219c-4ec9-889f-3d738f69085a
# ╠═a4c58af2-2bbd-4732-bf6a-2047555222ad
# ╠═c46ea987-362a-48b6-acfa-23a94a4da3ce
# ╟─ee87653a-3f2c-498a-a9f6-8b126956ac8c
# ╠═7abaeca2-1438-454a-902e-e019489d8585
# ╠═e81ef784-5858-4803-97e6-099396ebd081
# ╟─fc3b33c6-d86c-481a-84a7-4cf71120924c
# ╠═d7cd2822-2a13-42d8-82f8-e82dafe36fe0
# ╠═c6823866-89ae-4968-a54a-f2e94a5170eb
# ╠═5392e206-968b-48f3-a7be-6ba91bdca7a0
# ╠═e5c5583b-eb65-496e-9805-b7c8da218838
# ╠═11661dcd-bfa8-43f7-95f7-3d8b03010bf7
# ╟─6386d5a9-2d24-41af-a443-c21f04310e6a
# ╟─f9c68d4a-f141-43ad-8267-5fd3178fdde1
# ╟─aa2645e2-c639-4114-aad2-88bf013293de
# ╟─40bf7d9b-dddd-43b0-bab6-1eaaa01f640a
# ╟─445c7416-91a3-4658-a99a-0a5645d933a4
# ╟─4389e77d-799c-497c-8015-c726938df571
# ╠═3534eeee-7c4e-4280-9d74-339967dd49db
# ╟─76340b70-883b-4f4a-8a18-a1432072e245
# ╠═18f4926f-9fcb-4cfc-8381-792b9bb7df37
# ╠═d64e25c9-385e-4a74-af63-928f8a090049
# ╠═67b2e0f5-041a-4eba-ad5f-ee4ce12d73db
# ╠═4b68540c-8100-4bcf-b422-e9b2382309d1
# ╟─a404eca5-7261-46d0-9b63-f75b3e19277d
# ╟─00b8600c-db94-4db5-8f3a-79f82a7f3f11
# ╠═5df54abb-d69a-4d7b-9e10-a03f07ae3903
# ╠═c68f3f86-78d4-49c6-9652-1c0318c658ee
# ╟─09487ce8-1d61-47b3-b870-4502ef477c1e
# ╟─88a2208a-7c5e-4aa0-8751-503248363566
# ╟─e75f102a-0fdb-4814-9316-0b33c5bf6824
# ╠═71f77e0c-cd7f-4e51-821b-ed949692bde6
# ╟─a6c010dc-f52b-4027-af1f-6bd29671599b
# ╠═a6849926-fcb1-485f-b287-e187060a915d
# ╠═e4096878-6523-4d2e-a382-5094fd064657
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
