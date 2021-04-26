### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ d6a37b99-ab94-4d41-9147-ef7c0b695704
using Plots

# ╔═╡ acc3e9f5-5ddd-4fab-8536-471aee398eb2
using Turing

# ╔═╡ e38aca18-0098-4cb5-9229-1f639c8243ca
using StatsPlots

# ╔═╡ 6364fa28-0737-43f2-b5d4-5f743ce64ea1
begin
using LaTeXStrings
s = latexstring("\\mu_{Profit}")
s2 = latexstring("\\mu_{Profit} \\pm \\sigma_{Profit}")
s3 = latexstring("ArgMax(\\mu_{Profit})")
end;

# ╔═╡ c42c63d2-a615-11eb-094c-07ffc56e14b0
md"""

# Tercera clase del curso de ciencia de datos del MLI

## Plan de Trabajo

### Primera clase (ok)

- ¿Por qué Julia?
- Primeros pasos
- Herramientas básicas para ciencia de datos

### Segunda clase (ok)

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

### Incretidumbre del modelo

Al ser los parámetros de nuestros modelos **distribuciones** de probabilidad, el modelado bayesiano nos permite incluir la incertidumbre de manera integral.

#### Aplicación: Modelo para elección del precio óptimo de un producto contando con una prueba piloto.
"""

# ╔═╡ 93ea39ee-6aa6-41f2-8ece-7b3715a9a060
md"""La idea de este problema es que tenemos un nuevo producto que lanzar. Sabemos nuestros costos de producción, pero no sabemos el precio óptimo para maximizar nuestras ganancias.

Como sabemos que:

$Ventas = Cantidad * Precio$

y que al subir el precio, las cantidades que nos compran van a tender a disminuir, nos gustaría saber el precio óptimo para maximizar las ventas. 

Para esto, vamos a querer construir la curva de demanda de nuestro producto utilizando una prueba piloto. En esta caso usaremos el modelo clásico P vs Q:

$Q = aP^{c}$"""

# ╔═╡ ae70c258-249f-4a1e-9bcc-f778dad4146e
begin

a = 5000
c = -0.9
P = 1:100
Q = a.*(P.^c)

plot(P, Q, legend=false, title="Modelo de Cantidad vs Precio")

xlabel!("Precio")
ylabel!("Cantidad")
end

# ╔═╡ e8856141-2d30-41c6-80af-e05f434f69fd
md"Para facilitar el trabajo, vamos a linealizar la relación propuesta:

$log(Q)=log(a) + c*log(P)$" 

# ╔═╡ 55100ed9-c4dc-4b3f-9832-e412b6299149
md"Definamos nuestro modelo:"

# ╔═╡ 4605184e-a890-44ce-b51f-751f10cdc1e7
begin
	@model function demanda(qval,p0)
	loga ~ Cauchy()
	c ~ Cauchy()
	logμ0 = loga .+ c*(log.(p0) .- mean(log.(p0)))
	μ0 = exp.(logμ0)
	for i in eachindex(µ0)
		qval[i] ~ Poisson(μ0[i])
	end
end
end

# ╔═╡ 6d14330d-134b-44e7-b929-d3328d32889d
begin
plot(-10:0.01:10,Cauchy(), xlim=(-10,10),label="Cauchy(0,1)")
plot!(Normal(), xlim=(-10,10), label="Normal(0,1)")
end

# ╔═╡ 6b5f7859-8f6d-48f2-b027-0df88f504ea0
md"#### Una vez definido el modelo ¡tomemos datos!"

# ╔═╡ f6546947-a5f0-43b1-bc18-bd7bad36b82a
begin
	#Nuestros puntos obtenidos de la prueba piloto
	precio = [1500, 2500, 4000, 5000] 
	cantidad = [590, 259, 231, 117]
	
	scatter(precio, cantidad, markersize=6, color="orange", legend=false, xlim=(1000,6000), ylim=(0,1100))
	xlabel!("Precio")
	ylabel!("Cantidad")
end

# ╔═╡ f45fbaf8-02d0-4cd4-971f-a1b058d011cd
begin
	modelo = demanda(cantidad, precio)
	posterior = sample(modelo, NUTS(),1000)
end;

# ╔═╡ 3fb416de-79eb-4950-a0b2-040c04619228
begin
	post_loga = collect(get(posterior, :loga))
	post_c = collect(get(posterior, :c))
	
	hist_loga = histogram(post_loga, normed=true, bins=20, label=false, xlabel="log a")
	hist_c = histogram(post_c, normed=true, legend=false, bins=20, xlabel="c")
	plot(hist_loga, hist_c, layout=(1,2))
end

# ╔═╡ 8a08fe88-184f-4d64-9fc5-abe87a9c8422
mean(post_loga[1])

# ╔═╡ 8fe80c8a-023e-486d-bcbd-bb2244a26356
mean(post_c[1])

# ╔═╡ 27fd6af3-0864-4276-a7c6-a4ee2896dcbe
md"Okey!! 

Podríamos entonces suponer que nuestro modelo tiene esta función:

$Log(Q)=5.55 - 1.18Log(P)$

¿Tendría esto sentido?

Ni de cerca! Haciendo esto, estamos perdiendo toda la preciosa información de la incertidumbre de nuestro modelo!"

# ╔═╡ 8f3f610c-cc20-4f74-ba90-8af10cbf74bc
md"#### Incorporando a la incertibumbre para la toma de decisiones"

# ╔═╡ a41ed419-0fd0-4d0f-8ea9-5f9347fca281
begin
p = range(1000,9000,step = 10);
q = zeros(length(p),length(post_c[1]))
	
for i in collect(1:length(post_c[1]))
	q[:,i] = exp.(post_loga[1][i] .+ post_c[1][i] .* (log.(p) .- mean(log.(precio))))
end
end

# ╔═╡ 9e2d40f3-d971-4b21-8f75-e22fe8e1bc43
begin
	plot(p,q[:,1], xlim=(1000,6000))
	for i in collect(1:length(post_c[1]))
		plot!(p,q[:,i], color="blue", legend=false, alpha = 0.1)
	end
	
	plot!(p, mean(q, dims=2), color="red", lw=2)
	scatter!(precio, cantidad, color="orange", markersize=5)
	ylabel!("Cantidad")
	xlabel!("Precio")
end

# ╔═╡ 3675d864-5169-46fb-b4fd-4191a84e33a3
md"""#### Maximización de la ganancia

Teniendo en cuenta que:

$Ganancia = Precio * Cantidad - Costos$

$Ganancia=Precio * Cantidad - (CostosVariable * Cantidad + CostosFijos)$

Podemos contruir nuestra curva de ganancias
"""

# ╔═╡ c6e0c9ef-86c8-4d8e-9d08-82beb3d03668
begin
costo_fijo = 10000
costo_var_unit = 700
costo_variable = costo_var_unit .* q
costo_total = costo_variable .+ costo_fijo
ganancia = p .* q .- costo_total
end;

# ╔═╡ 6105a2c4-9e3f-4e4f-a028-3bac8a758bf3
mxval, mxindx = findmax(mean(ganancia, dims=2); dims=1);

# ╔═╡ 402d63a8-cf38-4a1e-8e24-0c8e72d1f8f2
mxval[1]

# ╔═╡ 2848ff96-39ce-4b98-a58c-0021971743a9
unfav = mxval[1] - std(ganancia[mxindx[1][1], : ])

# ╔═╡ 280f65a6-9ef6-4b34-9b9c-d22d7d141183
fav = mxval[1] + std(ganancia[mxindx[1][1], : ])

# ╔═╡ 3f7e3b90-f964-4819-966f-c3190b1f428f
begin
plot()
for i in collect(1:length(post_c[1]))
	plot!(p,ganancia[:,i], color="blue", label=false, alpha = 0.1)
end

plot!(p,mean(ganancia, dims=2) + std(ganancia, dims=2),  color = "orange", lw=2, label =s2)

plot!(p,mean(ganancia, dims=2), color = "red", lw=4, label=s)

plot!(p,mean(ganancia, dims=2) - std(ganancia, dims=2),  color = "orange", lw=2, label="")

vline!(p[mxindx], p[mxindx], line = (:black, 3), label=s3)
	
xlabel!("Precio")
ylabel!("Ganancia")
end

# ╔═╡ 839f838d-b2fe-48bb-a47d-79c7f71ff7a3
std_p = [std(ganancia[i, : ]) for i in collect(1:length(p))]

# ╔═╡ 43f52222-be42-4042-b9da-a95bd61a86e8
plot(p,std_p, legend=false, xlabel = "Price", ylabel= "Desviación standard de la ganancia", lw=2)

# ╔═╡ 3ccc725b-e1bf-48eb-8a77-f63eedbb1aab


# ╔═╡ Cell order:
# ╟─c42c63d2-a615-11eb-094c-07ffc56e14b0
# ╟─93ea39ee-6aa6-41f2-8ece-7b3715a9a060
# ╠═d6a37b99-ab94-4d41-9147-ef7c0b695704
# ╠═ae70c258-249f-4a1e-9bcc-f778dad4146e
# ╟─e8856141-2d30-41c6-80af-e05f434f69fd
# ╠═acc3e9f5-5ddd-4fab-8536-471aee398eb2
# ╟─55100ed9-c4dc-4b3f-9832-e412b6299149
# ╠═4605184e-a890-44ce-b51f-751f10cdc1e7
# ╠═e38aca18-0098-4cb5-9229-1f639c8243ca
# ╠═6d14330d-134b-44e7-b929-d3328d32889d
# ╟─6b5f7859-8f6d-48f2-b027-0df88f504ea0
# ╠═f6546947-a5f0-43b1-bc18-bd7bad36b82a
# ╠═f45fbaf8-02d0-4cd4-971f-a1b058d011cd
# ╠═3fb416de-79eb-4950-a0b2-040c04619228
# ╠═8a08fe88-184f-4d64-9fc5-abe87a9c8422
# ╠═8fe80c8a-023e-486d-bcbd-bb2244a26356
# ╟─27fd6af3-0864-4276-a7c6-a4ee2896dcbe
# ╟─8f3f610c-cc20-4f74-ba90-8af10cbf74bc
# ╠═a41ed419-0fd0-4d0f-8ea9-5f9347fca281
# ╠═9e2d40f3-d971-4b21-8f75-e22fe8e1bc43
# ╟─3675d864-5169-46fb-b4fd-4191a84e33a3
# ╠═c6e0c9ef-86c8-4d8e-9d08-82beb3d03668
# ╠═6105a2c4-9e3f-4e4f-a028-3bac8a758bf3
# ╠═402d63a8-cf38-4a1e-8e24-0c8e72d1f8f2
# ╠═2848ff96-39ce-4b98-a58c-0021971743a9
# ╠═280f65a6-9ef6-4b34-9b9c-d22d7d141183
# ╠═6364fa28-0737-43f2-b5d4-5f743ce64ea1
# ╠═3f7e3b90-f964-4819-966f-c3190b1f428f
# ╠═839f838d-b2fe-48bb-a47d-79c7f71ff7a3
# ╠═43f52222-be42-4042-b9da-a95bd61a86e8
# ╠═3ccc725b-e1bf-48eb-8a77-f63eedbb1aab
