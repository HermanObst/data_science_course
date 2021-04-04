### A Pluto.jl notebook ###
# v0.12.21

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

# ╔═╡ cf73b8cc-94ec-11eb-1319-f187362bb4b2
2 + 2 

# ╔═╡ 219089a0-94ed-11eb-1e0b-f96c01210802
π * 2

# ╔═╡ c8177a72-94ed-11eb-328b-0dde7bbbc82a
π/sqrt(2)

# ╔═╡ 2c482dce-94ed-11eb-30eb-d525ba4aea64
vector = [1,2,3,4,5]

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

# ╔═╡ 72a25914-94ee-11eb-2df9-bdc220c1b0c5
md"## Graficación"

# ╔═╡ 84f3e0ea-94ee-11eb-0f96-a9e094716389
begin
    sequence = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
	
    p1 = scatter(sequence, xlabel="n", ylabel="Fibonacci(n)", color="purple", label=false)

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

# ╔═╡ ea62a4f0-94f5-11eb-3b92-678fb6c684d7
rename!(df, ["uno", "dos", "tres", "cuatro", "cinco"])

# ╔═╡ 816ec820-94f8-11eb-1223-f54d2eb81c33
df.uno

# ╔═╡ 903b8e58-94f8-11eb-128e-b95a26c712ea
df[1,:]

# ╔═╡ 9e9999ea-94f8-11eb-2e53-3911d1a018e9
for fila in eachrow(df) 
	println(fila.uno)
end

# ╔═╡ Cell order:
# ╟─2193673c-94e1-11eb-175e-4df58b84eb75
# ╠═7ef1f5ee-94ec-11eb-0437-3352923aeeba
# ╟─9c2f695c-94ec-11eb-065d-593cc71022c2
# ╠═cf73b8cc-94ec-11eb-1319-f187362bb4b2
# ╠═219089a0-94ed-11eb-1e0b-f96c01210802
# ╠═c8177a72-94ed-11eb-328b-0dde7bbbc82a
# ╠═2c482dce-94ed-11eb-30eb-d525ba4aea64
# ╠═48fce862-94ed-11eb-029b-b3349bae42ee
# ╠═536e8f58-94ed-11eb-1607-cbf0af0e6084
# ╠═574c51e6-94ed-11eb-2fa6-335ec7d6ba5c
# ╠═9d198bda-94ed-11eb-2f26-a1363789c034
# ╠═ad442e20-94ed-11eb-13c4-079668f92aa4
# ╟─72a25914-94ee-11eb-2df9-bdc220c1b0c5
# ╠═192df0ba-94f7-11eb-2b4d-1739ff47c98c
# ╠═84f3e0ea-94ee-11eb-0f96-a9e094716389
# ╠═d270ba98-94f3-11eb-18a3-f567cfe13b99
# ╠═291f0f68-94f3-11eb-1ff5-1b9e20e4632e
# ╠═389eee64-94f4-11eb-3135-11cc76e45a7f
# ╟─732bce26-94f4-11eb-359e-0d521ed62399
# ╠═5cb8035c-94f5-11eb-3c6e-35978f6a9c7f
# ╠═ea62a4f0-94f5-11eb-3b92-678fb6c684d7
# ╠═816ec820-94f8-11eb-1223-f54d2eb81c33
# ╠═903b8e58-94f8-11eb-128e-b95a26c712ea
# ╠═9e9999ea-94f8-11eb-2e53-3911d1a018e9
