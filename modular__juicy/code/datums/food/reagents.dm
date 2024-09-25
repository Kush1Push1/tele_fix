/datum/reagent/consumable/bonito
	name = "bonito flakes"
	description = "Also known as \"Katsuobushi\", apparently!"
	color = "#fce2c7"
	taste_description = "Umami"
	taste_mult = 1.5

/datum/reagent/consumable/nutriment/protein
	name = "Protein"
	description = "A natural polyamide made up of amino acids. An essential constituent of mosts known forms of life."
	nutriment_factor = 9 //45% as calorie dense as oil.
	brute_heal = 0.8 //Rewards the player for eating a balanced diet.
	// chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	color = "#305a66" // rgb: 30, 67, 66

/datum/reagent/water/salt
	name = "Saltwater"
	description = "Water, but salty. Smells like... the station infirmary?"
	color = "#aaaaaa9d" // rgb: 170, 170, 170, 77 (alpha)
	// chemical_flags = REAGENT_CAN_BE_SYNTHESIZED | REAGENT_CLEANS
	glass_desc = "the sea"
	cooling_temperature = 3
