// Ported from BayStation12

/obj/item/device/cooler
	name = "portable cooling unit"
	desc = "PCU is a large portable heat sink with liquid cooled radiator packaged into a modified backpack. \
	It has an internal power unit with power rating of 10 MJ, which can be charge with APCs or power cells with magnetic charger on top of PCU. \
	System of strapes allows it to be worn on back or strapped to an engineering hazard vest."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'modular_bluemoon/cooling_device/cooling_device.dmi'
	mob_overlay_icon = 'modular_bluemoon/cooling_device/cooling_device_back.dmi'
	anthro_mob_worn_overlay = 'modular_bluemoon/cooling_device/cooling_device_back.dmi'

	icon_state = "suitcooler0"
	slot_flags = ITEM_SLOT_BACK //todo - добавить размещение на пояс, но забалансить, чтобы синт-СБшник с этой штукой не бегал в аблятивке по обшивке, не снимая сумки

	flags_1 = CONDUCT_1
	force = 8 // heavy
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	actions_types = list(/datum/action/item_action/toggle)

	custom_materials = list(/datum/material/iron = 15000, /datum/material/glass = 3500)

	var/on = FALSE						//is it turned on?
	var/max_cooling = 18			// in degrees per second - probably don't need to mess with heat capacity here
	var/charge_consumption = 5.5	//КВт, energy usage at full power (около 30 минут при заряде в 10000)
	var/charge = 0					// Мы не используем батарейки, чтобы не было халявных накопителей высокой мощности из любого техфаба
	var/roundstart_charged = FALSE		// Для размещения на карте с начала раунда, заряженный вариант
	var/max_charge = 10000			// 10 МВт
	var/thermostat = T20C			// Какой температуре стремиться

/obj/item/device/cooler/charged
	roundstart_charged = TRUE

/obj/item/device/cooler/lavaland
	name = "mining cooling unit"
	desc = "PCU is a large portable heat sink with liquid cooled radiator packaged into a modified backpack. \
	It has an internal power unit with rating of 6 MJ, which can be charge with APCs or power cells with magnetic charger on top of PCU. \
	This one was modified to be strapped on belt and mining suit, but cooling efficient was significantly reduced. It still can be used for planetary operations."
	slot_flags = ITEM_SLOT_BELT
	force = 5 // smaller, but still bulky
	max_cooling = 4
	charge_consumption = 3.3 // 30 минут работы при полном заряде
	max_charge = 6000

/obj/item/device/cooler/lavaland/charged
	roundstart_charged = TRUE

/obj/item/device/cooler/ui_action_click(mob/living/user)
	toggle(usr)

/obj/item/device/cooler/Initialize()
	. = ..()
	if(roundstart_charged)
		charge = max_charge
	update_icon()

/obj/item/device/cooler/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/device/cooler/process()
	if(charge <= 0)
		turn_off(1)
		return

	if(!is_in_slot())
		charge -= charge_consumption
		return

	var/mob/living/carbon/human/H = loc

	var/temp_adj = min(H.bodytemperature - thermostat, max_cooling)

	if (temp_adj < 0.5)	//only cools, doesn't heat, also we don't need extreme precision
		charge -= charge_consumption
		return

	var/charge_usage = (temp_adj/max_cooling)*charge_consumption

	H.bodytemperature -= temp_adj

	charge -= charge_usage
	update_icon()

// Checks whether the cooling unit is being worn on the back/suit slot.
// That way you can't carry it in your hands while it's running to cool yourself down.
/obj/item/device/cooler/proc/is_in_slot()
	var/mob/living/carbon/human/H = loc
	if(!istype(H))
		return 0

	return (H.back == src) || (H.s_store == src) || (H.belt == src)

/obj/item/device/cooler/proc/turn_on()
	if(charge <= 0)
		return

	on = TRUE
	START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/device/cooler/proc/turn_off(failed)
	if(failed)
		visible_message(span_warning("\The [src] clicks and whines as it powers down."))
	on = FALSE
	STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/item/device/cooler/attack_self(mob/user)
	toggle(user)

/obj/item/device/cooler/proc/toggle(mob/user)
	if(charge <= 0)
		to_chat(user, span_warning("You press switch button on \the [src], but it doesn't respond. Perhaps it is out of charge."))
		return

	if(on)
		turn_off()
	else
		turn_on()

	to_chat(user, span_notice("You switch \the [src] [on ? "on" : "off"]."))

/obj/item/device/cooler/attack_obj(atom/target, mob/user)
	var/maxcapacity = FALSE //Safety check for batteries
	var/maxdrain = 0 // Проверка, чтобы из АПЦ не выкачивало более половины энергии
	var/drain = 0 //Drain amount from batteries

	if(istype(target, /obj/item/stock_parts/cell) || istype(target, /obj/machinery/power/apc))
		user.DelayNextAction(CLICK_CD_MELEE)
		var/in_apc = FALSE
		if(istype(target, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc = target
			if(apc.cell)
				target = apc.cell
				maxdrain = apc.cell.maxcharge / 2
			else
				user.visible_message(span_notice("[user] puts \the [src]'s magnetic charger on the APC, but nothing happens."), span_warning("You hold the magnetic charger over the APC but nothing happens. Its cell seems to be out of charge."))
				return
		var/obj/item/stock_parts/cell/cell = target
		if(cell.charge)
			if(maxdrain > 0 && cell.charge - 500 <= maxdrain)
				user.visible_message(span_notice("[user] puts \the [src]'s magnetic charger on the APC, but nothing happens."), span_warning("You hold the magnetic charger over the APC but nothing happens. A safety protocol prevents charge if the APC's power lower than half."))
				return

			user.visible_message(span_notice("[user] puts \the [src]'s magnetic charger on [in_apc ? "the APC" : "\a [target]"]."), span_notice("You hold the magnetic charger over [in_apc ? "the APC" : "\a [target]"]. It's getting hotter."))
			while(cell.charge > 0 && !maxcapacity)
				drain = rand(500, 1000)

				if(cell.charge < drain)
					drain = cell.charge

				if(maxdrain)
					if(cell.charge - drain <= maxdrain)
						user.visible_message(span_notice("[user] takes back \the [src]'s magnetic charger as it buzzes."), span_notice("The magnetic charger buzzes - APC cannot give it more charge. You take it back and place it in socket on \the [src]."))
						break

				if(charge + drain > max_charge)
					drain = max_charge - charge
					maxcapacity = TRUE
					playsound(src.loc, 'sound/machines/beep.ogg', 50, 0)

				if(do_after(user, 1.5 SECONDS, target = src))
					cell.charge -= drain
					charge += drain
					target.update_icon()
					if(maxcapacity)
						user.visible_message(span_notice("[user] takes back \the [src]'s magnetic charger."), span_notice("You take back the magnetic charger as it beep and place it in socket on \the [src]."))

				else
					user.visible_message(span_notice("[user] takes back \the [src]'s magnetic charger."), span_notice("You take back the magnetic charger and place it in socket on \the [src]."))
					break
		return
	. = ..()

/obj/item/device/cooler/update_icon()
	cut_overlays()
	icon_state = "suitcooler0"

	if(!on)
		return

	switch(round(100*charge/max_charge))
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

/obj/item/device/cooler/examine(user, distance)
	. = ..()
	if(distance >= 1)
		return

	if(on)
		. += span_info("It's switched on and running.")
	else
		. += span_info("It is switched off.")

	if(charge)
		. += span_info("The charge meter reads [round(100*charge/max_charge)]%.")
	else
		. += span_warning("The charge meter is blank.")

/*
Сборка через техфаб
*/

/datum/design/cooler
	name = "Portable Cooling Unit"
	desc = "A large portable heat sink with liquid cooled radiator packaged into a modified backpack. Useful for IPCs and other synthetics during EVA operations."
	id = "cooler"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 3500)
	build_path = /obj/item/device/cooler // печатаются пустые, чтобы не было проще выбросить старый и напечатать новый
	category = list("Misc")

/datum/design/cooler/lavaland
	name = "Mining Cooling Unit"
	desc = "A large portable heat sink with liquid cooled radiator packaged into a modified backpack. \
	This one can be strapped on belt, but lost in efficiency due reduced size. Useful for IPCs and other synthetics during mininig operations."
	id = "cooler_mining"
	materials = list(/datum/material/iron = 12000, /datum/material/glass = 2500)
	build_path = /obj/item/device/cooler/lavaland
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO
