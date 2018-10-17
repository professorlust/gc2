###

Shiny Goomy effects

Effect             Prob.     Description
-------------      ------    -----------
Goomy Bonus        60.00%    Give a huge bonus of Goomies.
Rain Dance         33.50%    Gives both clicking and GpS a x12 boost for 70.4 seconds.
Click Frenzy        5.00%    Gives clicking a x704 GpC boost for 7.04 seconds.
Click EXP Frenzy    0.95%    Gives clicking a x10 EXP/click boost for 20 seconds.
Level Up            0.45%    Levels a random generator up once.
                    0.10%

###

init_cooldown_time = 200000

shiny_goomy =

	enabled: false
	appeared: false
	opacity: 0
	x: 0
	y: 0
	effect: "none" # one of "goomies", "raindance", "clickmult", "levelup"

	time_left: 0  # for timed effects.
	cooldown_time: init_cooldown_time  # for cooldown time.

	clicks: 0
	total_clicks: 0

	update: (ms) ->
		if not @enabled
			@enabled = true  # Prevent a shiny Goomy from "always" appearing upon loading a new window due to the long wait time.
		else if @time_left > 0
			@time_left -= ms
			if @time_left <= 0
				# cancel out the initial effect.
				if @effect == "raindance"
					basedata.raindance_mult = 1.0
					$("#shiny_goomy_rain_dance").hide()
					recalc()
				if @effect == "clickmult"
					basedata.frenzy_clickmult = 1.0
					$("#shiny_goomy_click_frenzy").hide()
					recalc()
				if @effect == "clickexp"
					basedata.exp_clickmult = 1.0
					$("#shiny_goomy_exp_click_frenzy").hide()
					recalc()
		else if @appeared
			if @opacity < 1
				@opacity = Math.min(1, @opacity + ms / 2000)
				$("#shiny_goomy").css({opacity: @opacity})
		else # if yet to appear
			if @cooldown_time > 0
				@cooldown_time -= ms
			else if Math.random() > Math.pow(0.995, ms / 1000)
				@appeared = true
				@x = Math.random() * ($(window).width() - $("#shiny_goomy").width())
				@y = Math.random() * ($(window).height() - $("#shiny_goomy").height())

				spinner = Math.random()

				if spinner < 0.6
					@effect = "goomies"
				else if spinner < 0.935
					@effect = "raindance"
				else if spinner < 0.985
					@effect = "clickmult"
				else if spinner < 0.9945
					@effect = "clickexp"
				else if spinner < 0.999
					@effect = "levelup"
				else
					@effect = "goomies"

				$("#shiny_goomy").show()
				$("#shiny_goomy").css({left: @x, top: @y, opacity: 0})

				$("#shiny_goomy").click (e) => @click e.pageX, e.pageY

	click: (x, y) ->
		
		$("#shiny_goomy").unbind()
		$("#shiny_goomy").hide()
		@appeared = false
		@opacity = 0
		basedata.clicks += 1
		basedata.total_clicks += 1
		@cooldown_time = init_cooldown_time

		if @effect == "goomies"
			# Approximately 140 seconds worth of Goomies.
			# award = 120 seconds of Goomy production + 200 clicks worth of Goomies
			gain = basedata.gps * 120 + basedata.gpc * 200
			shiny_plus_marker = new PlusMarker(langs[lang]["shiny_goomies_pre"] + reprnum(Math.floor(gain), "long") + langs[lang]["shiny_goomies_post"], x, y, 3000)
			basedata.earn(gain)
			return gain

		else if @effect == "raindance"
			# bonus = 774.4 seconds worth of Goomies + clicking.
			@time_left = 70400
			basedata.raindance_mult = 12.0
			recalc()
			$("#shiny_goomy_rain_dance").show()
			shiny_plus_marker = new PlusMarker(langs[lang]["shiny_raindance"], x, y, 3000)

		else if @effect == "clickmult"
			# approximately 5,000 seconds worth of Goomies
			@time_left = 7040
			basedata.frenzy_clickmult = 704.0
			recalc()
			$("#shiny_goomy_click_frenzy").show()
			shiny_plus_marker = new PlusMarker(langs[lang]["shiny_clickmult"], x, y, 3000)

		else if @effect == "clickexp"
			@time_left = 20000
			basedata.exp_clickmult = 12.0
			recalc()
			$("#shiny_goomy_exp_click_frenzy").show()
			shiny_plus_marker = new PlusMarker(langs[lang]["shiny_clickexp"], x, y, 3000)


@click_on_shiny_goomy = shiny_goomy.click
