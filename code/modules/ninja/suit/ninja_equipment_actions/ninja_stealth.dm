/datum/action/item_action/ninja_stealth
	name = "Toggle Stealth"
	desc = "Toggles stealth mode on and off."
	button_icon_state = "ninja_cloak"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"

/**
 * Proc called to toggle ninja stealth.
 *
 * Proc called to toggle whether or not the ninja is in stealth mode.
 * If cancelling, calls a separate proc in case something else needs to quickly cancel stealth.
 */
/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return
	if(stealth)
		cancel_stealth()
	else
		if(cell.charge <= 0)
			to_chat(ninja, "<span class='warning'>You don't have enough power to enable Stealth!</span>")
			return
		stealth = !stealth
		animate(ninja, alpha = 20,time = 12)
		ninja.visible_message("<span class='warning'>[ninja.name] vanishes into thin air!</span>", \
						"<span class='notice'>You are now mostly invisible to normal detection.</span>")

/**
 * Proc called to cancel stealth.
 *
 * Called to cancel the stealth effect if it is ongoing.
 * Does nothing otherwise.
 * Arguments:
 * * Returns false if either the ninja no longer exists or is already visible, returns true if we successfully made the ninja visible.
 */
/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return FALSE
	if(stealth)
		stealth = !stealth
		animate(ninja, alpha = 255, time = 12)
		ninja.visible_message("<span class='warning'>[ninja.name] appears from thin air!</span>", \
						"<span class='notice'>You are now visible.</span>")
		return TRUE
	return FALSE

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/action/item_action/ninja_stealth_wisdom
	name = "Toggle Upgraded Stealth"
	desc = "Toggles Upgraded stealth mode on and off."
	button_icon_state = "ninja_spirit_form_blue"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"

/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth_wisdom()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return
	if(stealth)
		cancel_stealth()
	else
		if(cell.charge <= 0)
			to_chat(ninja, "<span class='warning'>You don't have enough power to enable Stealth!</span>")
			return
		stealth = !stealth
		animate(ninja, alpha = 5, time = 6)
		ninja.visible_message("<span class='warning'>[ninja.name] vanishes into thin air!</span>", \
						"<span class='notice'>You are now mostly invisible to normal detection.</span>")

/////////////////////////////////////////////////////
/datum/action/item_action/ninja_resonance
	name = "Resonance (35E)"
	desc = "Emit a stunning robitic shriek, disabling all neaby carbon and silicon forms."
	button_icon_state = "resonance"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"

/obj/item/clothing/suit/space/space_ninja/ronin/proc/ninja_resonance()
	var/mob/living/carbon/human/ninja = affecting
	if(ninjacost(350,N_STEALTH_CANCEL))
		return
	for(var/mob/living/M in get_hearers_in_view(4, ninja))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!C.mind || !C.mind.has_antag_datum(/datum/antagonist/ninja))
				C.AdjustConfused(8 SECONDS, 10, 20)
				C.adjustEarDamage(10, 20)
				C.Slowed(10 SECONDS)
				C.Jitter(30 SECONDS)
				C.DefaultCombatKnockdown(25)
				C.apply_damage(6, BRUTE)
			else
				SEND_SOUND(C, sound('sound/effects/screech.ogg'))

		if(issilicon(M))
			SEND_SOUND(M, sound('sound/weapons/flash.ogg'))
			M.DefaultCombatKnockdown(rand(30,60))

	for(var/obj/machinery/light/L in range(4, ninja))
		L.on = 1
		INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, break_light_tube))
	playsound(get_turf(ninja), 'sound/effects/resonance.ogg', 75, TRUE, 5)
	s_coold = 10
	return TRUE

/////////////////////////////////////////////////////////////////////////////////////
