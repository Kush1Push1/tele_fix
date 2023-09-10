// Ported from BayStation12

/obj/item/device/suit_cooling_unit
	name = "portable cooling unit"
	desc = "A large portable heat sink with liquid cooled radiator packaged into a modified backpack. System of strapes allows it to be worn on back \
	or strapped to an engineering hazard vest."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'modular_bluemoon/cooling_device/cooling_device.dmi'
	mob_overlay_icon = 'modular_bluemoon/cooling_device/cooling_device_back.dmi'
	anthro_mob_worn_overlay = 'modular_bluemoon/cooling_device/cooling_device_back.dmi'

	icon_state = "suitcooler0"
	slot_flags = ITEM_SLOT_BACK //todo - добавить размещение на пояс, но забалансить, чтобы синт-СБшник с этой штукой не бегал в аблятивке по обшивке, не снимая сумки

	flags_1 = CONDUCT_1
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	actions_types = list(/datum/action/item_action/toggle)

	custom_materials = list(/datum/material/iron = 15000, /datum/material/glass = 3500)

	var/on = 0								//is it turned on?
	var/cover_open = 0						//is the cover open?
	var/obj/item/stock_parts/cell/cell
	var/max_cooling = 18					// in degrees per second - probably don't need to mess with heat capacity here
	var/charge_consumption = 6000	//6 kilowatts, energy usage at full power
	var/thermostat = T20C

/obj/item/device/suit_cooling_unit/ui_action_click(mob/living/user)
	toggle(usr)

/obj/item/device/suit_cooling_unit/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	cell = new /obj/item/stock_parts/cell/high()		// 10K rated cell.
	cell.forceMove(src)

/obj/item/device/suit_cooling_unit/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/device/suit_cooling_unit/process()
	if (!on || !cell)
		return

	if (!is_in_slot())
		return

	var/mob/living/carbon/human/H = loc

	var/temp_adj = min(H.bodytemperature - thermostat, max_cooling)

	if (temp_adj < 0.5)	//only cools, doesn't heat, also we don't need extreme precision
		return

	var/charge_usage = (temp_adj/max_cooling)*charge_consumption

	H.bodytemperature -= temp_adj

	cell.use(charge_usage * GLOB.CELLRATE)
	update_icon()

	if(cell.charge <= 0)
		turn_off(1)

// Checks whether the cooling unit is being worn on the back/suit slot.
// That way you can't carry it in your hands while it's running to cool yourself down.
/obj/item/device/suit_cooling_unit/proc/is_in_slot()
	var/mob/living/carbon/human/H = loc
	if(!istype(H))
		return 0

	return (H.back == src) || (H.s_store == src) || (H.belt == src)

/obj/item/device/suit_cooling_unit/proc/turn_on()
	if(!cell)
		return
	if(cell.charge <= 0)
		return

	on = 1
	update_icon()

/obj/item/device/suit_cooling_unit/proc/turn_off(failed)
	if(failed)
		visible_message(span_warning("\The [src] clicks and whines as it powers down."))
	on = 0
	update_icon()

/obj/item/device/suit_cooling_unit/attack_self(mob/user)
	if(cover_open && cell)
		if(ishuman(user))
			user.put_in_hands(cell)
		else
			user.dropItemToGround(cell)

		cell.add_fingerprint(user)
		cell.update_icon()

		to_chat(user, "You remove \the [src.cell].")
		src.cell = null
		turn_off(1)
		return

	toggle(user)

/obj/item/device/suit_cooling_unit/proc/toggle(mob/user)
	if(on)
		turn_off()
	else
		turn_on()
	to_chat(user, span_notice("You switch \the [src] [on ? "on" : "off"]."))


/obj/item/device/suit_cooling_unit/attackby(obj/item/tool, mob/user, list/click_params)
	if(is_in_slot) // Сначала нужно снять
		to_chat(user, span_warning("You have to take it off yourself firstly."))
		return

	// Screwdriver - Toggle cover
	if(tool.tool_behaviour == TOOL_SCREWDRIVER)
		cover_open = !cover_open
		playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
		update_icon()
		user.visible_message(
			span_notice("\The [user] [cover_open ? "opens" : "closes"] \a [src]'s panel with \a [tool]."),
			span_notice("You [cover_open ? "open" : "close"] \the [src]'s panel with \the [tool].")
		)
		return TRUE

	// Power Cell - Install cell
	if (istype(tool, /obj/item/stock_parts/cell))
		if (!cover_open)
			to_chat(user, span_warning("\The [src]'s panel is closed."))
			return TRUE
		if (cell)
			to_chat(user, span_warning("\The [src] already has \a [cell] installed."))
			return TRUE
		if(!user.transferItemToLoc(tool, src))
			return
		cell = tool
		update_icon()
		user.visible_message(
			span_notice("\The [user] installs \a [tool] into \a [src]."),
			span_notice("You install \the [tool] into \the [src].")
		)

	return ..()


/obj/item/device/suit_cooling_unit/update_icon()
	cut_overlays()
	if (cover_open)
		if (cell)
			icon_state = "suitcooler1"
		else
			icon_state = "suitcooler2"
		return

	icon_state = "suitcooler0"

	if(!cell || !on)
		return

	switch(round(cell.percent()))
		if(86 to INFINITY)
			overlays.Add("battery-0")
		if(69 to 85)
			overlays.Add("battery-1")
		if(52 to 68)
			overlays.Add("battery-2")
		if(35 to 51)
			overlays.Add("battery-3")
		if(18 to 34)
			overlays.Add("battery-4")
		if(-INFINITY to 17)
			overlays.Add("battery-5")

/obj/item/device/suit_cooling_unit/examine(user, distance)
	. = ..()
	if(distance >= 1)
		return

	if(on)
		. += span_info("It's switched on and running.")
	else
		. += span_info("It is switched off.")

	if(cover_open)
		. += span_warning("The panel is open. [cell ? "You can see \a [cell] inside" : "The power cell socket is empty"].")
	else if(on)
		. += span_info("The charge meter reads [round(cell.percent())]%.")
	else
		. += span_warning("The charge meter is blank.")

/*
Сборка через техфаб
*/

/datum/design/suit_cooling
	name = "Portable Cooling Unit"
	desc = "A large portable heat sink with liquid cooled radiator packaged into a modified backpack. Useful for IPCs and other synthetics."
	id = "suit_cooling"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 3500)
	build_path = /obj/item/device/suit_cooling_unit
	category = list("Misc")
