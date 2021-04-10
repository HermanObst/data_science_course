### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 192df0ba-94f7-11eb-2b4d-1739ff47c98c
using Plots

# ╔═╡ 5cb8035c-94f5-11eb-3c6e-35978f6a9c7f
begin
    using DataFrames, Random
	
    Random.seed!(123)

    data = rand(5, 5) 

    df = DataFrame(data)
end

# ╔═╡ e9b8cff2-94fa-11eb-3dbc-5d213b9ffcc8
using CSV, Statistics

# ╔═╡ 2193673c-94e1-11eb-175e-4df58b84eb75
md"""# Clase 1: Julia y primeras nociones de programación

## ¿Por qué Julia?

- Lenguaje Multipropósito 
- Diseñado para [análisis numérico](https://en.wikipedia.org/wiki/Numerical_analysis) y [computación científica](https://en.wikipedia.org/wiki/Computational_science) 
- Lenguaje de alto nivel (capacidad de abstracción y sintaxis simple)
- Performante

## Instalación

- https://julialang.org/downloads/platform/

## Primeros Pasos



"""

# ╔═╡ 7ef1f5ee-94ec-11eb-0437-3352923aeeba
println("Hola Mundo")

# ╔═╡ 9c2f695c-94ec-11eb-065d-593cc71022c2
md"### Operadores Lógicos"

# ╔═╡ e6df3128-6204-437e-ae1f-78dd15bb9029
md"##### Enteros"

# ╔═╡ cf73b8cc-94ec-11eb-1319-f187362bb4b2
2 + 2 

# ╔═╡ 219089a0-94ed-11eb-1e0b-f96c01210802
π * 2

# ╔═╡ c8177a72-94ed-11eb-328b-0dde7bbbc82a
π/sqrt(2)

# ╔═╡ 5d58b629-a3ad-474c-9d5c-14f99986eda4
md"##### Vectores"

# ╔═╡ 2c482dce-94ed-11eb-30eb-d525ba4aea64
vector = [1,2,3,4,5]

# ╔═╡ b02663bc-d722-488b-a384-939f9f80cc73
size(vector)

# ╔═╡ 48fce862-94ed-11eb-029b-b3349bae42ee
vector*2

# ╔═╡ 536e8f58-94ed-11eb-1607-cbf0af0e6084
vector + 2

# ╔═╡ 574c51e6-94ed-11eb-2fa6-335ec7d6ba5c
vector .+ 2

# ╔═╡ 9d198bda-94ed-11eb-2f26-a1363789c034
vector_ = [9,8,7,6,5]

# ╔═╡ ad442e20-94ed-11eb-13c4-079668f92aa4
vector + vector_

# ╔═╡ 9537e766-94f9-11eb-03f8-d77a09477d33
vector_cuadrado = []

# ╔═╡ 5a4588b6-94f9-11eb-2e47-fb9ce77c45c8
for numero in vector
	push!(vector_cuadrado, numero^2)
end

# ╔═╡ 7cc25720-94f9-11eb-12ef-1be2a137ccf3
vector_cuadrado

# ╔═╡ eb025511-99da-4626-8b50-8428d9857524
vector_fila = [1 2 3 4] 

# ╔═╡ fc7e02c7-8d51-4f9c-8e1d-1d5f844db2e0
size(vector_fila)

# ╔═╡ b0c8b7fc-8bcd-45ce-80f9-9c1e25eab5d1
md"##### Matrices"

# ╔═╡ 2252dcfc-065c-4c1c-b16c-b17593f9a723
a = [1 2; 3 4]

# ╔═╡ a937ddd1-61b3-4f99-8f9e-eb5070b60bce
size(a)

# ╔═╡ 4aea46dc-e035-4a2a-ab93-094a1095e33d
a * 2

# ╔═╡ d279e94e-6387-45e7-86dd-8ab2e05078ee
a - 2

# ╔═╡ 90c395a2-f7b4-40e9-a117-c0acf04c9aa1
a .- 2

# ╔═╡ f9903c09-da66-413b-a536-d61de8071bbc
a - [2 2;2 2]

# ╔═╡ b00e6b7b-0f60-423e-a62f-79bd01667b89
b = [1 0; 0 1]

# ╔═╡ eaa4d223-9b77-4128-aac5-e191f68e4a69
a * b

# ╔═╡ 75330790-1705-4994-a7ec-5a354387932b
a * [1 1;1 1]

# ╔═╡ 6e0bb9ce-cc30-488d-a368-33399474588b
[1 1; 1 1] * a

# ╔═╡ 72a25914-94ee-11eb-2df9-bdc220c1b0c5
md"## Graficación"

# ╔═╡ 68d02096-03aa-4870-bf14-a28f244ce5de
md"[Documentación Plots.jl](http://docs.juliaplots.org/latest/)"

# ╔═╡ 84f3e0ea-94ee-11eb-0f96-a9e094716389
begin
    secuencia = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
	
    p1 = scatter(secuencia, xlabel="n", ylabel="Fibonacci(n)", color="purple", label=false)

end

# ╔═╡ d270ba98-94f3-11eb-18a3-f567cfe13b99
begin
	x = 0:10
	y = x.^2
end

# ╔═╡ 291f0f68-94f3-11eb-1ff5-1b9e20e4632e
begin
	plot(y, label=false, xlabel="x", ylabel="x^2")
	p2 = scatter!(y, label=false)
end

# ╔═╡ 389eee64-94f4-11eb-3135-11cc76e45a7f
plot(p1, p2)

# ╔═╡ 732bce26-94f4-11eb-359e-0d521ed62399
md"## DataFrames"

# ╔═╡ b5bfdf36-0e84-4f45-a10c-27878d66b465
md"[Documentación DataFrames](https://dataframes.juliadata.org/stable/)"

# ╔═╡ ea62a4f0-94f5-11eb-3b92-678fb6c684d7
rename!(df, ["uno", "dos", "tres", "cuatro", "cinco"])

# ╔═╡ 816ec820-94f8-11eb-1223-f54d2eb81c33
df.uno

# ╔═╡ 903b8e58-94f8-11eb-128e-b95a26c712ea
df[1,:]

# ╔═╡ bbb96fec-94f9-11eb-094f-6547d1582fbb
df[3:5, ["dos", "cuatro", "cinco"]]

# ╔═╡ 9e9999ea-94f8-11eb-2e53-3911d1a018e9
for fila in eachrow(df) 
	println(fila.uno)
end

# ╔═╡ 55f0ba08-94fa-11eb-13ea-914410b7c02a
md"#### Funciones de alto nivel"

# ╔═╡ e33fd8ec-94f9-11eb-0f67-b10c30f82beb
describe(df)

# ╔═╡ a3d4f27c-9617-11eb-36df-7b334c63b9a9
filter(row -> row[1] < 0.5, df)

# ╔═╡ 633024a8-94fa-11eb-1ce5-6b6f90335ea1
filter(:uno => uno -> uno < 0.5, df)

# ╔═╡ 8598931e-956c-11eb-134c-33af4c68dbc1
iris_df = CSV.File("Iris.csv") |> DataFrame

# ╔═╡ 389a6094-956d-11eb-0b5b-1fb2b9d4c91e
md"Agrupamos el data frame por especies"

# ╔═╡ 4929d4ca-956d-11eb-0131-a1283e495db3
gdf = groupby(iris_df, :Species)

# ╔═╡ c4544b1a-956d-11eb-260c-d54a008b6c2b
combine(gdf, :PetalLengthCm => mean)

# ╔═╡ 8badd92e-956e-11eb-2a5d-938b8332aece
filter!(row -> row.Species != "Iris-setosa", iris_df)

# ╔═╡ Cell order:
# ╟─2193673c-94e1-11eb-175e-4df58b84eb75
# ╠═7ef1f5ee-94ec-11eb-0437-3352923aeeba
# ╟─9c2f695c-94ec-11eb-065d-593cc71022c2
# ╟─e6df3128-6204-437e-ae1f-78dd15bb9029
# ╠═cf73b8cc-94ec-11eb-1319-f187362bb4b2
# ╠═219089a0-94ed-11eb-1e0b-f96c01210802
# ╠═c8177a72-94ed-11eb-328b-0dde7bbbc82a
# ╟─5d58b629-a3ad-474c-9d5c-14f99986eda4
# ╠═2c482dce-94ed-11eb-30eb-d525ba4aea64
# ╠═b02663bc-d722-488b-a384-939f9f80cc73
# ╠═48fce862-94ed-11eb-029b-b3349bae42ee
# ╠═536e8f58-94ed-11eb-1607-cbf0af0e6084
# ╠═574c51e6-94ed-11eb-2fa6-335ec7d6ba5c
# ╠═9d198bda-94ed-11eb-2f26-a1363789c034
# ╠═ad442e20-94ed-11eb-13c4-079668f92aa4
# ╠═9537e766-94f9-11eb-03f8-d77a09477d33
# ╠═5a4588b6-94f9-11eb-2e47-fb9ce77c45c8
# ╠═7cc25720-94f9-11eb-12ef-1be2a137ccf3
# ╠═eb025511-99da-4626-8b50-8428d9857524
# ╠═fc7e02c7-8d51-4f9c-8e1d-1d5f844db2e0
# ╟─b0c8b7fc-8bcd-45ce-80f9-9c1e25eab5d1
# ╠═2252dcfc-065c-4c1c-b16c-b17593f9a723
# ╠═a937ddd1-61b3-4f99-8f9e-eb5070b60bce
# ╠═4aea46dc-e035-4a2a-ab93-094a1095e33d
# ╠═d279e94e-6387-45e7-86dd-8ab2e05078ee
# ╠═90c395a2-f7b4-40e9-a117-c0acf04c9aa1
# ╠═f9903c09-da66-413b-a536-d61de8071bbc
# ╠═b00e6b7b-0f60-423e-a62f-79bd01667b89
# ╠═eaa4d223-9b77-4128-aac5-e191f68e4a69
# ╠═75330790-1705-4994-a7ec-5a354387932b
# ╠═6e0bb9ce-cc30-488d-a368-33399474588b
# ╟─72a25914-94ee-11eb-2df9-bdc220c1b0c5
# ╟─68d02096-03aa-4870-bf14-a28f244ce5de
# ╠═192df0ba-94f7-11eb-2b4d-1739ff47c98c
# ╠═84f3e0ea-94ee-11eb-0f96-a9e094716389
# ╠═d270ba98-94f3-11eb-18a3-f567cfe13b99
# ╠═291f0f68-94f3-11eb-1ff5-1b9e20e4632e
# ╠═389eee64-94f4-11eb-3135-11cc76e45a7f
# ╟─732bce26-94f4-11eb-359e-0d521ed62399
# ╟─b5bfdf36-0e84-4f45-a10c-27878d66b465
# ╠═5cb8035c-94f5-11eb-3c6e-35978f6a9c7f
# ╠═ea62a4f0-94f5-11eb-3b92-678fb6c684d7
# ╠═816ec820-94f8-11eb-1223-f54d2eb81c33
# ╠═903b8e58-94f8-11eb-128e-b95a26c712ea
# ╠═bbb96fec-94f9-11eb-094f-6547d1582fbb
# ╠═9e9999ea-94f8-11eb-2e53-3911d1a018e9
# ╟─55f0ba08-94fa-11eb-13ea-914410b7c02a
# ╠═e33fd8ec-94f9-11eb-0f67-b10c30f82beb
# ╠═a3d4f27c-9617-11eb-36df-7b334c63b9a9
# ╠═633024a8-94fa-11eb-1ce5-6b6f90335ea1
# ╠═e9b8cff2-94fa-11eb-3dbc-5d213b9ffcc8
# ╠═8598931e-956c-11eb-134c-33af4c68dbc1
# ╟─389a6094-956d-11eb-0b5b-1fb2b9d4c91e
# ╠═4929d4ca-956d-11eb-0131-a1283e495db3
# ╠═c4544b1a-956d-11eb-260c-d54a008b6c2b
# ╠═8badd92e-956e-11eb-2a5d-938b8332aece
