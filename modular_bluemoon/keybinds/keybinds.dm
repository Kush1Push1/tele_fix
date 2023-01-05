/datum/keybinding/human/quick_equipsuitstorage
	hotkey_keys = list("ShiftQ")
	name = "quick_equipsuitstorage"
	full_name = "Quick suit storage"
	description = "Put held thing in suit storage or take the item from it"

/datum/keybinding/human/quick_equipsuitstorage/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.smart_equipsuitstorage()
	return TRUE

/datum/keybinding/human/quick_equip_lpocket
	hotkey_keys = list("Unbound")
	name = "quick_equip_lpocket"
	full_name = "Quick left pocket"
	description = "Put held thing in left pocket or take the item from it"

/datum/keybinding/human/quick_equip_lpocket/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.smart_equip_lpocket()
	return TRUE

/datum/keybinding/human/quick_equip_rpocket
	hotkey_keys = list("Unbound")
	name = "quick_equip_rpocket"
	full_name = "Quick right pocket"
	description = "Put held thing in right pocket or take the item from it"

/datum/keybinding/human/quick_equip_rpocket/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.smart_equip_rpocket()
	return TRUE

/mob/living/carbon/human/proc/smart_equipsuitstorage() // put held thing in suit storage or take the item from it
	if(incapacitated())
		return
	var/obj/item/thing = get_active_held_item()
	var/obj/item/equipped_suitstorage = get_item_by_slot(ITEM_SLOT_SUITSTORE)
	if(!equipped_suitstorage) // We also let you equip another storage like this
		if(!thing)
			to_chat(src, "<span class='warning'>You haven't anything on your suit!</span>")
			return
		if(equip_to_slot_if_possible(thing, ITEM_SLOT_SUITSTORE))
			update_inv_hands()
		return
	if(!SEND_SIGNAL(equipped_suitstorage, COMSIG_CONTAINS_STORAGE)) // not a storage item
		if(!thing)
			equipped_suitstorage.attack_hand(src)
		else
			to_chat(src, "<span class='warning'>You can't fit anything in!</span>")
		return
	if(thing) // put thing in suit storage
		if(!SEND_SIGNAL(equipped_suitstorage, COMSIG_TRY_STORAGE_INSERT, thing, src))
			to_chat(src, "<span class='warning'>You can't fit anything in!</span>")
		return
	if(!equipped_suitstorage.contents.len) // nothing to take out
		to_chat(src, "<span class='warning'>There's nothing in your belt to take out!</span>")
		return
	var/obj/item/stored = equipped_suitstorage.contents[equipped_suitstorage.contents.len]
	if(!stored || stored.on_found(src))
		return
	stored.attack_hand(src) // take out thing from belt
	return

/mob/living/carbon/human/proc/smart_equip_rpocket() // put held thing in suit storage or take the item from it
	if(incapacitated())
		return
	var/obj/item/thing = get_active_held_item()
	var/obj/item/equipped_rpocket = get_item_by_slot(ITEM_SLOT_RPOCKET)
	if(!equipped_rpocket) // We also let you equip another storage like this
		if(!thing)
			to_chat(src, "<span class='warning'>You haven't anything on your suit!</span>")
			return
		if(equip_to_slot_if_possible(thing, ITEM_SLOT_RPOCKET))
			update_inv_hands()
		return
	if(!SEND_SIGNAL(equipped_rpocket, COMSIG_CONTAINS_STORAGE)) // not a storage item
		if(!thing)
			equipped_rpocket.attack_hand(src)
		else
			to_chat(src, "<span class='warning'>You can't fit anything in!</span>")
		return
	if(thing) // put thing in suit storage
		if(!SEND_SIGNAL(equipped_rpocket, COMSIG_TRY_STORAGE_INSERT, thing, src))
			to_chat(src, "<span class='warning'>You can't fit anything in!</span>")
		return
	if(!equipped_rpocket.contents.len) // nothing to take out
		to_chat(src, "<span class='warning'>There's nothing in your belt to take out!</span>")
		return
	var/obj/item/stored = equipped_rpocket.contents[equipped_rpocket.contents.len]
	if(!stored || stored.on_found(src))
		return
	stored.attack_hand(src) // take out thing from belt
	return

/mob/living/carbon/human/proc/smart_equip_lpocket() // put held thing in suit storage or take the item from it
	if(incapacitated())
		return
	var/obj/item/thing = get_active_held_item()
	var/obj/item/equipped_lpocket = get_item_by_slot(ITEM_SLOT_LPOCKET)
	if(!equipped_lpocket) // We also let you equip another storage like this
		if(!thing)
			to_chat(src, "<span class='warning'>You haven't anything on your suit!</span>")
			return
		if(equip_to_slot_if_possible(thing, ITEM_SLOT_LPOCKET))
			update_inv_hands()
		return
	if(!SEND_SIGNAL(equipped_lpocket, COMSIG_CONTAINS_STORAGE)) // not a storage item
		if(!thing)
			equipped_lpocket.attack_hand(src)
		else
			to_chat(src, "<span class='warning'>You can't fit anything in!</span>")
		return
	if(thing) // put thing in suit storage
		if(!SEND_SIGNAL(equipped_lpocket, COMSIG_TRY_STORAGE_INSERT, thing, src))
			to_chat(src, "<span class='warning'>You can't fit anything in!</span>")
		return
	if(!equipped_lpocket.contents.len) // nothing to take out
		to_chat(src, "<span class='warning'>There's nothing in your belt to take out!</span>")
		return
	var/obj/item/stored = equipped_lpocket.contents[equipped_lpocket.contents.len]
	if(!stored || stored.on_found(src))
		return
	stored.attack_hand(src) // take out thing from belt
	return
