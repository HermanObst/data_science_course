### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ c22050a8-193b-45d3-9955-a64e2bca65d2
using Distributions, Plots, StatsPlots

# ╔═╡ bdfa8154-0a1b-4a80-b147-70f076d7eac2
using Turing

# ╔═╡ 8fe1e658-f674-4bcd-88b8-b4611b231b5a
using CSV, DataFrames

# ╔═╡ 04db4d81-90bd-48ee-a0f9-7101cddec9ae
begin
	using Random 
	
	Random.seed!(123)
	
	data = vcat([i <= 36 ? rand(Poisson(10), 1)[1] : rand(Poisson(15), 1)[1] for i in 1:74])
	
	data_df = DataFrame(col1 = data)
	
	#CSV.write("data.csv", data_df, writeheader=false)
end;

# ╔═╡ 1b6013d8-9fc0-11eb-198a-c709f6caab97
md"# Segunda clase del curso de ciencia de datos del MLI

## Plan de Trabajo

### Primera clase (ok)
- ¿Por qué Julia?
- Primeros pasos
- Herramientas básicas para ciencia de datos

### Segunda clase
- Introducción a la estadística bayesiana
- Introducción a la programación probabilistica 
- Algunas nociones de distribuciones de probabilidad 
- **Aplicación**: detección y ubicación temporal para el cambio en la tasa de arrivo de clientes a un local

### Tercera clase
- Profundización conceptual de la estadística bayesiana
- Cuantificación de la incertidumbre del modelo
- **Aplicación**: Modelo para elección del precio óptimo de un producto contando con una prueba piloto. Análisis ingreso/varianza.

### Cuarta clase
- Modelos bayesianos jerárquicos
- **Aplicación**: Modelado en deportes. Modelo analítico para la premier league. Simulación de partidos y predicción.
"

# ╔═╡ 415aa9c5-0fa4-4af3-910c-3eb2ebc5f13c
md"""### Estadística Bayesiana

##### Conceptos generales

- **Noción de probabilidad**: Grado de certeza (o incerteza) que tenemos ante algún evento.

- Como en "la vida real", se comienza un grado de certeza (o probabilidad) a *priori* de dicho evento.

- Se contrasta con los datos y se actualiza nuestra creencia. Se obtiene así la nueva probabilidad (creencia) a *posteriori*.

##### Y otros un poco más técnicos

- El mismo proceso se puede dar con **distribuciones de probabilidad**
	
- Se cree que algún proceso de la realidad sigue una determinada distribución a priori
- Se contrasta con los datos y se obtiene una distribución a posteriori
"""

# ╔═╡ f9e829ed-ed1b-40ca-9f42-6503c3960163
md"### ¿Está la moneda cargada?"

# ╔═╡ 04883759-9066-4838-87b2-48e57f0b6c03
md"La pregunta que queremos responder: ¿es igualmente probable sacar cara o ceca?"

# ╔═╡ ca547033-0f21-41fb-b264-66c9a60927c7
md"##### Distribución Binomial

- Modeliza una seguidilla de experimentos donde hay dos posibilidades con una probabilidad de ocurrencia $p$ para *éxito* y $1-p$ para *fracaso*, en nuestro caso, cara o ceca.

- La cuestión aquí es que justamente **no** sabemos la probabilidad $p$ de éxito, que en el caso de que la moneda no estuviera adulterada sería $p = 1 - p = 0.5$."

# ╔═╡ 6bbe995a-04ca-4217-a027-6c31d22951f5
plot(Binomial(100,0.5), legend=false)

# ╔═╡ 6832b13d-01dc-4fa4-ba87-18ad985e5e81
md"
- Como no confiamos en que la moneda este equilibrada, vamos a suponer una distribución uniforme(0,1) para la probabilidad de éxito."

# ╔═╡ 5bb9c585-6e88-4375-8209-ea82b1733a68
begin
	p_valores_priori = rand(Uniform(0, 1), 100000)
	
	histogram(p_valores_priori, normalized=true, bin=10, legend=false,
			  size=(400, 250), ylabel="Probabilidad", xlabel="p")
end

# ╔═╡ 0e64f052-6aae-4f03-bce0-6c9851bc0c81
md"##### Armemos nuestro modelo"

# ╔═╡ 37e83672-7d9d-471b-8c40-750e7b0a902b
begin
	@model tirada_moneda(y) = begin
		# Nuestra creencia a priori sobre la probabilidad que salga cara
		p ~ Uniform(0, 1)

		# Número de veces que la vamos a tirar para estimar la probabilidad
		N = length(y)
		for n in 1:N
			# Tiradas de moneda se modeliza con una bernoulli
			y[n] ~ Bernoulli(p)
		end
	end
end

# ╔═╡ 8de48e1c-3fb8-4a02-a838-50a471847db9
tiradas_moneda = [0, 1, 1, 0, 1, 0, 0, 1, 1, 1]

# ╔═╡ 282e63f7-2a8c-44fc-9ad3-703e1c2902cf
begin
	# Settings of the Hamiltonian Monte Carlo (HMC) sampler.
	iterations = 1000
	ϵ = 0.05
	τ = 10

	# Start sampling.
	chain = sample(tirada_moneda(tiradas_moneda[1]), HMC(ϵ, τ), iterations, progress=false);
end;

# ╔═╡ d1988a04-12cd-4b87-9b3e-7514f8cf0917
histogram(chain[:p], normed=true, legend=false, size=(500, 300), 
			title="Distribución a posteriori luego de sacar ceca",
			ylabel="Probabilidad", xlabel="p")

# ╔═╡ 1aef4447-e44e-4243-abec-fce1f3d7141b
begin
	posterioris = []
	for i in 2:10	
		global cadena_
		cadena_ = sample(tirada_moneda(tiradas_moneda[1:i]), HMC(ϵ, τ), iterations, 							progress=false)
		
		push!(posterioris, cadena_[:p])
	end
end;

# ╔═╡ d085f9ec-9505-4555-976f-ff1ec3515257
tiradas_moneda

# ╔═╡ 934fd4a1-878f-4c62-b40a-48d1cefc48b6
begin
	plots = histogram.(posterioris, normalized=true, legend=false, bins=10)
	
	p_ = plot(plots[1], plots[2], plots[3], plots[4], plots[5], plots[6], 						  plots[7],plots[8], plots[9], layout = 9, 
			  title = ["$i tiradas" for j in 1:1, i in 2:10], 
			  titleloc = :right, titlefont = font(8), xlim=(0,1))
end

# ╔═╡ c78828bf-fee8-4c6b-a4b6-89cf6571a348
mean(posterioris[9])

# ╔═╡ b9f6ef67-89f4-484a-9b90-fd31d003970d
md"##### **Aplicación**: detección y ubicación temporal para el cambio en la tasa de arrivo de clientes a un local"

# ╔═╡ ed2bb374-862d-4d20-adf8-c302f34b0a17
arrivos_df = DataFrame(CSV.File("data.csv", header=false))

# ╔═╡ c6742698-ccb2-4444-8a8a-a6e061da3e97
arrivos = arrivos_df.Column1

# ╔═╡ a387635e-8a42-4e32-96c0-5dec3d9c2ab6
begin 
	dias = collect(1:74)
	bar(dias, arrivos, legend=false, xlabel="Día", ylabel="Arrivos diarios de clientes", alpha=0.8)
end

# ╔═╡ 754ab16a-fb82-4a7b-8482-381892adc9e0
@model function deteccion_cambio(x)
  N = length(x)
  μ1 ~ Exponential()
  μ2 ~ Exponential()
  τ ~ Uniform(0, N)
	for j in eachindex(x)
		if τ<j 
        	x[j] ~ Poisson(μ1)
		else 
        	x[j] ~ Poisson(μ2)
		end
    end
end

# ╔═╡ a4c22fd1-fea1-42a1-b399-11fd978d6890
sampleo = sample(deteccion_cambio(arrivos), NUTS(), 1000);

# ╔═╡ 1ba8188a-39fb-4925-b4df-d7c8359e70d0
valores_posteriori = get(sampleo, [:μ1, :μ2, :τ]);

# ╔═╡ 7390bc19-d5e2-4de5-b634-05ce9356e893
begin
	mu1 = histogram(valores_posteriori.μ1, normed=true, bin=10, color="green", xlabel="μ1", ylabel="Probabilidad", legend=false,title="Posterior de μ1", alpha=0.8, xlim=(0,25))
	
	mu2 = histogram(valores_posteriori.μ2, bin=10, normed=true, color="red", xlabel="μ2", ylabel="Probabilidad", legend=false, title="Posterior de µ2", alpha=0.7, xlim=(0,25))
	
	tau = histogram(valores_posteriori.τ, bins=25, normed=true, xlabel="Día", ylabel="Probabilidad", legend=false, title="Posterior de τ" ,alpha=0.7, xlim=(0,74))
	
	plot(mu1, mu2, tau, layout=(3,1))
end

# ╔═╡ 6ab0b48c-9436-4756-838e-eab8e50b72c8
md"### Referencias

- [Documentación Turing](https://turing.ml/stable/)
- [Data Science in Julia for Hackers, cap 5](https://datasciencejuliahackers.com/05_prob_prog_intro.jl.html)"

# ╔═╡ Cell order:
# ╟─1b6013d8-9fc0-11eb-198a-c709f6caab97
# ╟─415aa9c5-0fa4-4af3-910c-3eb2ebc5f13c
# ╟─f9e829ed-ed1b-40ca-9f42-6503c3960163
# ╟─04883759-9066-4838-87b2-48e57f0b6c03
# ╠═c22050a8-193b-45d3-9955-a64e2bca65d2
# ╠═bdfa8154-0a1b-4a80-b147-70f076d7eac2
# ╟─ca547033-0f21-41fb-b264-66c9a60927c7
# ╠═6bbe995a-04ca-4217-a027-6c31d22951f5
# ╟─6832b13d-01dc-4fa4-ba87-18ad985e5e81
# ╠═5bb9c585-6e88-4375-8209-ea82b1733a68
# ╟─0e64f052-6aae-4f03-bce0-6c9851bc0c81
# ╠═37e83672-7d9d-471b-8c40-750e7b0a902b
# ╠═8de48e1c-3fb8-4a02-a838-50a471847db9
# ╠═282e63f7-2a8c-44fc-9ad3-703e1c2902cf
# ╠═d1988a04-12cd-4b87-9b3e-7514f8cf0917
# ╠═1aef4447-e44e-4243-abec-fce1f3d7141b
# ╠═d085f9ec-9505-4555-976f-ff1ec3515257
# ╠═934fd4a1-878f-4c62-b40a-48d1cefc48b6
# ╠═c78828bf-fee8-4c6b-a4b6-89cf6571a348
# ╟─b9f6ef67-89f4-484a-9b90-fd31d003970d
# ╠═8fe1e658-f674-4bcd-88b8-b4611b231b5a
# ╠═ed2bb374-862d-4d20-adf8-c302f34b0a17
# ╠═c6742698-ccb2-4444-8a8a-a6e061da3e97
# ╠═a387635e-8a42-4e32-96c0-5dec3d9c2ab6
# ╠═754ab16a-fb82-4a7b-8482-381892adc9e0
# ╠═a4c22fd1-fea1-42a1-b399-11fd978d6890
# ╠═1ba8188a-39fb-4925-b4df-d7c8359e70d0
# ╠═7390bc19-d5e2-4de5-b634-05ce9356e893
# ╠═04db4d81-90bd-48ee-a0f9-7101cddec9ae
# ╟─6ab0b48c-9436-4756-838e-eab8e50b72c8
