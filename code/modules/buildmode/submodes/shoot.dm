/datum/buildmode_mode/shoot
	key = "shoot"
	var/atom/projholder = null

/datum/buildmode_mode/shoot/show_help(client/target_client)
	to_chat(target_client, span_purple(boxed_message(
		"[span_bold("Set ammo casing type")] -> Right Mouse Button on buildmode button\n\
		[span_bold("Shoot projectile")] -> Left Mouse Button on turf\n\
		[span_bold("Shoot projectile")] ->  Left Mouse Button + Alt to switch burst mode\n\
		\n\
		Use mouse to shoot."))
	)

/datum/buildmode_mode/shoot/change_settings(client/target_client)
	var/target_path = input(target_client, "Enter typepath:", "Typepath", "/obj/item/ammo_casing/c10mm")
	projholder = text2path(target_path)
	if(!ispath(projholder))
		projholder = pick_closest_path(target_path)
		if(!projholder)
			alert("No path was selected")
			return
		else if(!ispath(projholder, /obj/item/ammo_casing))
			projholder = null
			alert("That path is not allowed.")
			return
	BM.preview_selected_item(projholder)

/datum/buildmode_mode/shoot/handle_click(client/target_client, params, obj/object)
	var/list/modifiers = params2list(params)
	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/alt_click = LAZYACCESS(modifiers, ALT_CLICK)

	if(left_click && alt_click)
		burst_mode = !burst_mode
		to_chat(target_client, "<span class='warning'>Changed Burst mode to [burst_mode].</span>")
	else if(left_click)
		if(ispath(projholder,/obj/item/ammo_casing))
			var/obj/item/ammo_casing/proj = new projholder
			proj.fire_casing(object, usr, params)
			log_admin("Shoot Mode: [key_name(target_client)] shoot [projholder] in [AREACOORD(object)] to [projholder]")
		else
			to_chat(target_client, "<span class='warning'>Select object type first.</span>")
