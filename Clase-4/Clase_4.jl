### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ add40067-e4fd-463a-af40-ebb8452b9aca
begin
	using JSON
	using DataFrames
end

# ╔═╡ d0f2202e-ea5a-4bc9-b7b1-d52ed628f48a
using Turing

# ╔═╡ 2b99e438-8848-449b-af30-3c5f68c32606
using LinearAlgebra

# ╔═╡ 814ee63a-ad3d-11eb-2e73-f5f95c27e1fc
md"""

# Cuarta clase del curso de ciencia de datos del MLI

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

### Tercera clase (ok)

- Profundización conceptual de la estadística bayesiana
- Cuantificación de la incertidumbre del modelo
- **Aplicación**: Modelo para elección del precio óptimo de un producto contando con una prueba piloto. Análisis ingreso/varianza.

### Cuarta clase

- Modelos bayesianos jerárquicos
- **Aplicación**: Modelado en deportes. Modelo analítico para la premier league. Simulación de partidos y predicción."""

# ╔═╡ c12d3d77-25d5-4561-9172-0e9db8ad119b
md"""#### Modelos Jerárquicos

- Nos permiten modelar relaciones más abstractas 
- Hasta ahora, siempre hubo una distribución que "generaba" los datos". Esa distribución tenía parámetros a los que le asignábamos distribuciones prior.
- Ahora, a los parámetros de nuestra distribución prior para los parámetros de la distribución que genera los datos de la "realidad", se le asigna otra distribución prior.
- Nos permite inferir variables **letentes**: Por ejemplo, en economía, "calidad de vida" """

# ╔═╡ 62b21692-c9b7-4cd7-bc9a-fafab68b1d05
begin
england_league = JSON.parsefile("matches_England.json")
matches_df = DataFrame(home = [], away = [], score_home = [], score_away = [])
end;

# ╔═╡ 00bd28b6-737a-4291-854f-d6b7bc3c6b2a
begin
	matches = []
	for match in england_league
		push!(matches, split(match["label"], ","))
end
end

# ╔═╡ 8bc3335e-27f3-4dc8-b010-b54b4192c835
begin
for match in matches
	home, away = split(match[1], " - ")
	score_home, score_away = split(match[2], " - ")
	
	push!(matches_df,[home, away, parse(Int,score_home), parse(Int,score_away)])
end
end	

# ╔═╡ eaaa7424-facd-4020-af15-b105e59741b1
matches_df

# ╔═╡ ab3d8089-e549-4a8e-b4e9-302b6cdec268
teams = unique(collect(matches_df[:,1]))

# ╔═╡ d514149e-de9b-4b58-8655-58790a97100c
md"- Para nuestro modelo, vamos a modelar a los goles realizados por un equipo mediante una distribución de $Poisson$"

# ╔═╡ 82b4487f-ebf6-4fc3-9ebb-bc7552643f12
begin
	@model function football_matches(home_teams, away_teams, score_home, score_away, teams)
	#hyper priors
	σatt ~ Exponential(1)
	σdeff ~ Exponential(1)
	μatt ~ Normal(0,0.1)
	μdef ~ Normal(0,0.1)
	
	home ~ Normal(0,1)
		
	#Team-specific effects	
	att ~ filldist(Normal(μatt, σatt), length(teams))
	def ~ filldist(Normal(μatt, σdeff), length(teams))
	
	dict = Dict{String, Int64}()
	for (i, team) in enumerate(teams)
		dict[team] = i
	end
		
	#Zero-sum constrains
	offset = mean(att) + mean(def)
	
	log_θ_home = Vector{Real}(undef, length(home_teams))
	log_θ_away = Vector{Real}(undef, length(home_teams))
		
	#Modeling score-rate and scores (as many as there were games in the league) 
	for i in 1:length(home_teams)
		#score-rate
		log_θ_home[i] = home + att[dict[home_teams[i]]] + def[dict[away_teams[i]]] - offset
		log_θ_away[i] = att[dict[away_teams[i]]] + def[dict[home_teams[i]]] - offset
		#scores
		score_home[i] ~ LogPoisson(log_θ_home[i])
		score_away[i] ~ LogPoisson(log_θ_away[i])
	end
	
	end
end

# ╔═╡ 4abd669a-cf74-48ce-9362-b7e6ae2e04d7
model = football_matches(matches_df[:,1], matches_df[:,2], matches_df[:,3], matches_df[:,4], teams)

# ╔═╡ f20cb54d-da70-401c-9d05-4a4badf8d80d
posterior = sample(model, NUTS(),3000);

# ╔═╡ 26dbb558-6a0d-4d46-b103-38624b02ff54
begin
	table_positions = 
	[11, 5, 9, 4, 13, 14, 1, 15, 12, 6, 2, 16, 10, 17, 20, 3, 7, 8, 19, 18]
	
	games_won = 
	[32, 25, 23, 21, 21, 19, 14, 13, 12, 12, 11, 11, 10, 11, 9, 9, 7, 8, 7, 6]
	
	teams_ = []
	for i in table_positions
		push!(teams_, teams[i])
	end
	
	table_position_df = DataFrame(Table_of_positions = teams_, Wins = games_won)

end

# ╔═╡ 94fd4533-5cd3-4533-a951-c3fc6c1748cd
begin
	post_att = collect(get(posterior, :att)[1])
	post_def = collect(get(posterior, :def)[1])
	post_home = collect(get(posterior, :home)[1])
end;

# ╔═╡ 1250bf45-a687-485d-b2fb-fa2e0cc59da5
begin
	using Plots
	gr()
histogram(post_home, legend=false, title="Posterior distribution of home parameter")
end

# ╔═╡ c17f7e9b-ade1-4056-9505-c662ea30e62a
mean(post_home)

# ╔═╡ 394cb607-db4c-4276-b234-fca65dc2a53a
begin
	teams_att = []
	teams_def = []
	for i in 1:length(post_att)
		push!(teams_att, post_att[i])
		push!(teams_def, post_def[i])
	end
end

# ╔═╡ 54163b71-ad66-404b-ad3a-d6e1719df7ec
teams_att

# ╔═╡ e057c589-45c0-4224-840a-835941fe8c1a
teams[1]

# ╔═╡ cfe96e6e-fa9b-421a-aba0-ba2f58366528
histogram(teams_att[1], legend=false, title="Posterior distribution of Burnley´s attack power")

# ╔═╡ 44a15b43-d2b9-49c6-9baf-586509889e7b
teams[11]

# ╔═╡ f591a93e-499a-40d7-ade9-12ff139718b9
begin
	histogram(teams_att[11], legend=false, title="Posterior distribution of Manchester City´s attack power")
end

# ╔═╡ a020deb0-40e6-4a9b-abf1-7722712235d7
mean(teams_att[11])

# ╔═╡ 8be72413-3450-45f5-b493-c1970e67895d
begin
	teams_att_μ = mean.(teams_att)
	teams_def_μ = mean.(teams_def)
	teams_att_σ = std.(teams_att)
	teams_def_σ = std.(teams_def)
end;

# ╔═╡ da8731ef-f963-429d-b184-642827239f04
begin #ocultar
	teams_att_μ
	sorted_att = sortperm(teams_att_μ)
	abbr_names = [t[1:3] for t in teams]
end;

# ╔═╡ e0475968-868b-4af6-b09b-c4e7e32a46a8
sorted_names = abbr_names[sorted_att]

# ╔═╡ 6be2a414-78cd-4fac-b438-17141d4acf4c
begin
	scatter(1:20, teams_att_μ[sorted_att], grid=false, legend=false, yerror=teams_att_σ[sorted_att], color=:blue, title="Premier league 17/18 teams attack power")
	annotate!([(x, y + 0.238, text(team, 8, :center, :black)) for (x, y, team) in zip(1:20, teams_att_μ[sorted_att], sorted_names)])

	ylabel!("Mean team attack")
end

# ╔═╡ fb67b249-a276-485a-967f-e347adda3118
begin #ocultar
	sorted_def = sortperm(teams_def_μ)
	sorted_names_def = abbr_names[sorted_def]
end

# ╔═╡ afb45641-c8cb-4ed7-a8ba-a6c1b2c8b427
begin
	scatter(1:20, teams_def_μ[sorted_def], grid=false, legend=false, yerror=teams_def_σ[sorted_def], color=:blue, title="Premier league 17/18 teams defence power")
	annotate!([(x, y + 0.2, text(team, 8, :center, :black)) for (x, y, team) in zip(1:20, teams_def_μ[sorted_def], sorted_names_def)])
	ylabel!("Mean team defence")
end

# ╔═╡ e6c1b2a7-dbf4-42b0-af03-03688d773e34
begin #ocultar
	table_position = 
	[11, 5, 9, 4, 13, 14, 1, 15, 12, 6, 2, 16, 10, 17, 20, 3, 7, 8, 19, 18]
	position = sortperm(table_position)
end

# ╔═╡ 35620e16-5737-4786-9fb2-2b40153844b4
begin
	scatter(teams_att_μ, teams_def_μ, legend=false)
	annotate!([(x, y + 0.016, text(team, 6, :center, :black)) for (x, y, team) in zip(teams_att_μ, teams_def_μ, abbr_names)])
	
	annotate!([(x, y - 0.016, text(team, 5, :center, :black)) for (x, y, team) in zip(teams_att_μ, teams_def_μ, position)])

	xlabel!("Mean team attack")
	ylabel!("Mean team defence")
end

# ╔═╡ cb9bf807-72e5-48ad-8169-4d1e26ce834e
md"### Simulando posibles realidades"

# ╔═╡ 8b2c385a-ff24-45bd-b591-822232645f9f
begin
	mci_att_post = collect(get(posterior, :att)[:att])[11][:,1];
	mci_def_post = collect(get(posterior, :def)[:def])[11][:,1];
	liv_att_post = collect(get(posterior, :att)[:att])[4][:,1];
	liv_def_post = collect(get(posterior, :def)[:def])[4][:,1];
end

# ╔═╡ c32c8de1-59ec-42c1-a328-b51b06948dc6
begin
	ha1 = histogram(mci_att_post, title="Manchester City attack", legend=false)
	ha2 = histogram(liv_att_post, title="Liverpool attack", legend=false)
	plot(ha1, ha2, layout=(1,2))
end

# ╔═╡ 94f3714e-5589-4722-9a77-72b51d38e6b2
begin
	hd1 = histogram(mci_def_post, title="Manchester City defense", legend=false)
	hd2 = histogram(liv_def_post, title="Liverpool defense", legend=false)
	plot(hd1, hd2, layout=(1,2))
end

# ╔═╡ 6e9b0748-9266-46b1-bb17-2b2a4804c3f5
# This function simulates matches given the attack, defense and home parameters.
# The first pair of parameters alwas correspond to the home team.

function simulate_matches_(att₁, def₁, att₂, def₂, home, n_matches, home_team = 1)
    if home_team == 1
        logθ₁ = home + att₁ + def₂
        logθ₂ = att₂ + def₁

    elseif home_team == 2
        logθ₁ = att₁ + def₂
        logθ₂ = home + att₂ + def₁
    else
        return DomainError(home_team, "Invalid home_team value")
    end
    
    scores₁ = rand(LogPoisson(logθ₁), n_matches)
    scores₂ = rand(LogPoisson(logθ₂), n_matches)
    
    results = [(s₁, s₂) for (s₁, s₂) in zip(scores₁, scores₂)]
    
    return results
end

# ╔═╡ 3209f5b4-f46b-46c8-8a0c-a02e535b9448
simulate_matches_(0.75, -0.53, 0.1, 0.1, 0.3, 10)

# ╔═╡ fa821028-0f1f-48ad-b829-12e15a9c1c05
function simulate_matches(team1_att_post, team1_def_post, team2_att_post, team2_def_post, home_post, n_matches)
    
    team1_as_home_results = Tuple{Int64,Int64}[]
    team2_as_home_results = Tuple{Int64,Int64}[]
    
    for (t1_att, t1_def, t2_att, t2_def, home) in zip(team1_att_post, team1_def_post, 
                                                      team2_att_post, team2_def_post,
                                                      home_post)
        
        team1_as_home_results = vcat(team1_as_home_results, 
									 simulate_matches_(t1_att, t1_def, t2_att,
													   t2_def, home, n_matches, 1))
        
        team2_as_home_results = vcat(team2_as_home_results,
									 simulate_matches_(t1_att, t1_def, t2_att, 															   t2_def, home, n_matches, 2))
    end
    
    max_t1_as_home = maximum(map(x -> x[1], team1_as_home_results))
    max_t2_as_away = maximum(map(x -> x[2], team1_as_home_results))
    
    max_t1_as_away = maximum(map(x -> x[1], team2_as_home_results))
    max_t2_as_home = maximum(map(x -> x[2], team2_as_home_results))

    matrix_t1_as_home = zeros(Float64, (max_t1_as_home + 1, max_t2_as_away + 1))
    matrix_t2_as_home = zeros(Float64, (max_t1_as_away + 1, max_t2_as_home + 1))
    
    for match in team1_as_home_results
        matrix_t1_as_home[match[1] + 1, match[2] + 1] += 1
    end
    
	normalize!(matrix_t1_as_home, 1)
    
    for match in team2_as_home_results
        matrix_t2_as_home[match[1] + 1, match[2] + 1] += 1
    end
    
	normalize!(matrix_t2_as_home, 1)
    
    return matrix_t1_as_home, matrix_t2_as_home
end

# ╔═╡ dd94c11d-963a-4b68-b226-d64b90833b5b
simulate_matches_(0.75, -0.35, 0.55, -0.2, 0.33, 1000, 2)

# ╔═╡ fab1a81b-0e47-4d4c-847e-3a5c743f2639
mci_as_home_simulations, 
liv_as_home_simulations = simulate_matches(mci_att_post, mci_def_post, 
										   liv_att_post, liv_def_post,                                                            post_home, 1000)

# ╔═╡ 1c4a8804-b681-44ed-ab26-0ef7460604fa
function match_heatmaps(matrix_t1_as_home, matrix_t2_as_home,
                        team1_name="Team 1", team2_name="Team 2")    
    gr()   

    x_t1_home = string.(0:10)
    y_t1_home = string.(0:10)
    heat_t1_home = heatmap(x_t1_home,
                           y_t1_home,
                           matrix_t1_as_home[1:11, 1:11],
                           xlabel="$team2_name score", ylabel="$team1_name score",
                           title="$team1_name as home")
    
    x_t2_home = string.(0:10)
    y_t2_home = string.(0:10)
    heat_t2_home = heatmap(x_t2_home,
                           y_t2_home,
                           matrix_t2_as_home[1:11, 1:11],
                           xlabel="$team2_name score", ylabel="$team1_name score",
                           title="$team2_name as home")
    
    plot(heat_t1_home, heat_t2_home, layout=(1,2), size=(900, 300))
    current()   
end

# ╔═╡ 396ec5a4-d02a-4b9f-8771-497b95c90e5e
match_heatmaps(mci_as_home_simulations, liv_as_home_simulations, "Manchester City", "Liverpool")

# ╔═╡ 015b70a7-efe4-4009-8cbd-bf8e98e28033
function win_and_lose_probability(simulation)
    
    team1_winning_prob = 0
    team2_winning_prob = 0
    draw_prob = 0
    
    for i in 1:size(simulation, 1)
        for j in 1:size(simulation, 2)
            if i > j
                team1_winning_prob += simulation[i,j]
            elseif i < j
                team2_winning_prob += simulation[i,j]
            else
                draw_prob += simulation[i,j]
            end
        end
    end
    
    return team1_winning_prob, team2_winning_prob, draw_prob
end

# ╔═╡ 44938842-0d30-45de-969b-50e8148b9778
win_and_lose_probability(liv_as_home_simulations)

# ╔═╡ 8d2b3fa7-d5fa-4070-87f6-732430788364
win_and_lose_probability(mci_as_home_simulations)

# ╔═╡ Cell order:
# ╟─814ee63a-ad3d-11eb-2e73-f5f95c27e1fc
# ╟─c12d3d77-25d5-4561-9172-0e9db8ad119b
# ╠═add40067-e4fd-463a-af40-ebb8452b9aca
# ╠═62b21692-c9b7-4cd7-bc9a-fafab68b1d05
# ╠═00bd28b6-737a-4291-854f-d6b7bc3c6b2a
# ╠═8bc3335e-27f3-4dc8-b010-b54b4192c835
# ╠═eaaa7424-facd-4020-af15-b105e59741b1
# ╠═ab3d8089-e549-4a8e-b4e9-302b6cdec268
# ╟─d514149e-de9b-4b58-8655-58790a97100c
# ╠═d0f2202e-ea5a-4bc9-b7b1-d52ed628f48a
# ╠═82b4487f-ebf6-4fc3-9ebb-bc7552643f12
# ╠═4abd669a-cf74-48ce-9362-b7e6ae2e04d7
# ╠═f20cb54d-da70-401c-9d05-4a4badf8d80d
# ╠═26dbb558-6a0d-4d46-b103-38624b02ff54
# ╠═94fd4533-5cd3-4533-a951-c3fc6c1748cd
# ╠═1250bf45-a687-485d-b2fb-fa2e0cc59da5
# ╠═c17f7e9b-ade1-4056-9505-c662ea30e62a
# ╠═394cb607-db4c-4276-b234-fca65dc2a53a
# ╠═54163b71-ad66-404b-ad3a-d6e1719df7ec
# ╠═e057c589-45c0-4224-840a-835941fe8c1a
# ╠═cfe96e6e-fa9b-421a-aba0-ba2f58366528
# ╠═44a15b43-d2b9-49c6-9baf-586509889e7b
# ╠═f591a93e-499a-40d7-ade9-12ff139718b9
# ╠═a020deb0-40e6-4a9b-abf1-7722712235d7
# ╠═8be72413-3450-45f5-b493-c1970e67895d
# ╠═da8731ef-f963-429d-b184-642827239f04
# ╠═e0475968-868b-4af6-b09b-c4e7e32a46a8
# ╠═6be2a414-78cd-4fac-b438-17141d4acf4c
# ╠═fb67b249-a276-485a-967f-e347adda3118
# ╠═afb45641-c8cb-4ed7-a8ba-a6c1b2c8b427
# ╠═e6c1b2a7-dbf4-42b0-af03-03688d773e34
# ╠═35620e16-5737-4786-9fb2-2b40153844b4
# ╟─cb9bf807-72e5-48ad-8169-4d1e26ce834e
# ╠═8b2c385a-ff24-45bd-b591-822232645f9f
# ╠═c32c8de1-59ec-42c1-a328-b51b06948dc6
# ╠═94f3714e-5589-4722-9a77-72b51d38e6b2
# ╠═2b99e438-8848-449b-af30-3c5f68c32606
# ╠═6e9b0748-9266-46b1-bb17-2b2a4804c3f5
# ╠═3209f5b4-f46b-46c8-8a0c-a02e535b9448
# ╠═fa821028-0f1f-48ad-b829-12e15a9c1c05
# ╠═dd94c11d-963a-4b68-b226-d64b90833b5b
# ╠═fab1a81b-0e47-4d4c-847e-3a5c743f2639
# ╠═1c4a8804-b681-44ed-ab26-0ef7460604fa
# ╠═396ec5a4-d02a-4b9f-8771-497b95c90e5e
# ╠═015b70a7-efe4-4009-8cbd-bf8e98e28033
# ╠═44938842-0d30-45de-969b-50e8148b9778
# ╠═8d2b3fa7-d5fa-4070-87f6-732430788364
