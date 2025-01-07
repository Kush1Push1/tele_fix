/mob/living/carbon/human
	/// Height of the mob
	VAR_PROTECTED/mob_height = HUMAN_HEIGHT_MEDIUM
	//the ids you can use for your species, if empty, it means default only and not changeable
	VAR_PROTECTED/list/allowed_mob_height = list(HUMAN_HEIGHT_MEDIUM, HUMAN_HEIGHT_TALL)

/mob/living/carbon/human/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, mob_height))
		var/static/list/heights = list(
			HUMAN_HEIGHT_SHORTEST,
			HUMAN_HEIGHT_SHORT,
			HUMAN_HEIGHT_MEDIUM,
			HUMAN_HEIGHT_TALL,
			HUMAN_HEIGHT_TALLEST
		)
		if(!(var_value in heights))
			return
		. = set_mob_height(var_value)
	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return
	return ..()

#define RESOLVE_ICON_STATE(worn_item) (worn_item.worn_icon_state || worn_item.icon_state)

/**
 * Setter for mob height
 *
 * Exists so that the update is done immediately
 *
 * Returns TRUE if changed, FALSE otherwise
 */
/mob/living/carbon/human/proc/set_mob_height(new_height)
	if(mob_height == new_height)
		return FALSE
	if(new_height == HUMAN_HEIGHT_DWARF || new_height == MONKEY_HEIGHT_DWARF)
		CRASH("Don't set height to dwarf height directly, use dwarf trait instead.")
	if(new_height == MONKEY_HEIGHT_MEDIUM)
		CRASH("Don't set height to monkey height directly, use monkified gene/species instead.")

	mob_height = new_height
	regenerate_icons()
	return TRUE

/**
 * Getter for mob height
 *
 * Mainly so that dwarfism can adjust height without needing to override existing height
 *
 * Returns a mob height num
 */
/mob/living/carbon/human/proc/get_mob_height()
	if(HAS_TRAIT(src, TRAIT_DWARF))
		if(ismonkey(src))
			return MONKEY_HEIGHT_DWARF
		else
			return HUMAN_HEIGHT_DWARF
/*
	if(HAS_TRAIT(src, TRAIT_TOO_TALL))
		if(ismonkey(src))
			return MONKEY_HEIGHT_TALL
		else
			return HUMAN_HEIGHT_TALLEST
*/
	else if(ismonkey(src))
		return MONKEY_HEIGHT_MEDIUM

	return mob_height

// Hooks into human apply overlay so that we can modify all overlays applied through standing overlays to our height system.
// Some of our overlays will be passed through a displacement filter to make our mob look taller or shorter.
// Some overlays can't be displaced as they're too close to the edge of the sprite or cross the middle point in a weird way.
// So instead we have to pass them through an offset, which is close enough to look good.
/mob/living/carbon/human/apply_overlay(cache_index)
	if(get_mob_height() == HUMAN_HEIGHT_MEDIUM)
		return ..()

	var/raw_applied = overlays_standing[cache_index]
	var/string_form_index = num2text(cache_index)
	var/offset_type = GLOB.layers_to_offset[string_form_index]
	if(isnull(offset_type))
		if(islist(raw_applied))
			for(var/image/applied_appearance in raw_applied)
				apply_height_filters(applied_appearance)
		else if(isimage(raw_applied))
			apply_height_filters(raw_applied)
	else
		if(islist(raw_applied))
			for(var/image/applied_appearance in raw_applied)
				apply_height_offsets(applied_appearance, offset_type)
		else if(isimage(raw_applied))
			apply_height_offsets(raw_applied, offset_type)

	return ..()

/**
 * Used in some circumstances where appearances can get cut off from the mob sprite from being too tall
 *
 * upper_torso is to specify whether the appearance is locate in the upper half of the mob rather than the lower half,
 * higher up things (hats for example) need to be offset more due to the location of the filter displacement
 */
/mob/living/carbon/human/proc/apply_height_offsets(image/appearance, upper_torso)
	var/height_to_use = num2text(get_mob_height())
	var/final_offset = 0
	switch(upper_torso)
		if(UPPER_BODY)
			final_offset = GLOB.human_heights_to_offsets[height_to_use][1]
		if(LOWER_BODY)
			final_offset = GLOB.human_heights_to_offsets[height_to_use][2]
		else
			return

	appearance.pixel_y += final_offset
	return appearance

/**
 * Applies a filter to an appearance according to mob height
 */
/mob/living/carbon/human/proc/apply_height_filters(mutable_appearance/appearance)
	var/static/icon/cut_torso_mask = icon('modular_bluemoon/modules/height_scaling/icons/cut.dmi', "Cut1")
	var/static/icon/cut_legs_mask = icon('modular_bluemoon/modules/height_scaling/icons/cut.dmi', "Cut2")
	var/static/icon/lenghten_torso_mask = icon('modular_bluemoon/modules/height_scaling/icons/cut.dmi', "Cut3")
	var/static/icon/lenghten_legs_mask = icon('modular_bluemoon/modules/height_scaling/icons/cut.dmi', "Cut4")

	appearance.remove_filter(list(
		"Cut_Torso",
		"Cut_Legs",
		"Lenghten_Legs",
		"Lenghten_Torso",
		"Gnome_Cut_Torso",
		"Gnome_Cut_Legs",
		"Monkey_Torso",
		"Monkey_Legs",
		"Monkey_Gnome_Cut_Torso",
		"Monkey_Gnome_Cut_Legs",
	))

	switch(get_mob_height())
		// Don't set this one directly, use TRAIT_DWARF
		if(MONKEY_HEIGHT_DWARF)
			appearance.add_filters(list(
				list(
					"name" = "Monkey_Gnome_Cut_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 3),
				),
				list(
					"name" = "Monkey_Gnome_Cut_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 4),
				),
			))
		if(MONKEY_HEIGHT_MEDIUM)
			appearance.add_filters(list(
				list(
					"name" = "Monkey_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 2),
				),
				list(
					"name" = "Monkey_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 4),
				),
			))
		// Don't set this one directly, use TRAIT_DWARF
		if(HUMAN_HEIGHT_DWARF)
			appearance.add_filters(list(
				list(
					"name" = "Gnome_Cut_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 2),
				),
				list(
					"name" = "Gnome_Cut_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 3),
				),
			))
		if(HUMAN_HEIGHT_SHORTEST)
			appearance.add_filters(list(
				list(
					"name" = "Cut_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 1),
				),
				list(
					"name" = "Cut_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1),
				),
			))
		if(HUMAN_HEIGHT_SHORT)
			appearance.add_filter("Cut_Legs", 1, displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1))
		if(HUMAN_HEIGHT_TALL)
			appearance.add_filter("Lenghten_Legs", 1, displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 1))
		if(HUMAN_HEIGHT_TALLER)
			appearance.add_filters(list(
				list(
					"name" = "Lenghten_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_torso_mask, x = 0, y = 0, size = 1),
				),
				list(
					"name" = "Lenghten_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 1),
				),
			))
		if(HUMAN_HEIGHT_TALLEST)
			appearance.add_filters(list(
				list(
					"name" = "Lenghten_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_torso_mask, x = 0, y = 0, size = 1),
				),
				list(
					"name" = "Lenghten_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 2),
				),
			))

	// Kinda gross but because many humans overlays do not use KEEP_TOGETHER we need to manually propogate the filter
	// Otherwise overlays, such as worn overlays on icons, won't have the filter "applied", and the effect kinda breaks
	if(!(appearance.appearance_flags & KEEP_TOGETHER))
		for(var/image/overlay in list() + appearance.underlays + appearance.overlays)
			apply_height_filters(overlay)

	return appearance

#undef RESOLVE_ICON_STATE
