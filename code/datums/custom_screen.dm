// Use to play custom image on screen
// Watcher can be world,mob, or a list of mobs

/client/proc/show_on_screen(I as icon)
	set category = "Event.Fun"
	set name = "Show On Screen"
	ShowOnScreen(I,world)

/proc/ShowOnScreen(image,watcher)
	var/datum/custom_screen/playing = new /datum/custom_screen
	if(!playing)
		CRASH("Screen not created")
	if(watcher == world)
		watcher = GLOB.mob_list
	playing.play(watcher,image)
	qdel(playing)

/mob/proc/overlay_fullscreen_custom(category, type, image, severity)
	var/atom/movable/screen/fullscreen/custom/screen = overlay_fullscreen(category, type, severity)
	screen.icon = image

/atom/movable/screen/fullscreen/custom
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "flash"
	plane = FULLSCREEN_PLANE

/datum/custom_screen
	var/list/watching = list() //List of clients watching this
	var/locking = FALSE
	var/closing_uis = FALSE
	var/list/locked = list() //Who had notransform set during the cinematic
	var/is_global = FALSE //Global cinematics will override mob-specific ones
	var/time = 100 //How long for the final screen to remain
	var/stop_ooc = FALSE //Turns off ooc when played globally.

/datum/custom_screen/Destroy()
	for(var/CC in watching)
		if(!CC)
			continue
		var/client/C = CC
		C.mob.clear_fullscreen("custom")
	watching = null
	for(var/MM in locked)
		if(!MM)
			continue
		var/mob/M = MM
		M.notransform = FALSE
	locked = null
	return ..()

/datum/custom_screen/proc/play(watchers,image)
	//Place /atom/movable/screen/cinematic into everyone's screens, prevent them from moving
	for(var/MM in watchers)
		var/mob/M = MM
		if(show_to(M, M.client, image))
			RegisterSignal(M, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(show_to))
			if(closing_uis)
				SStgui.close_user_uis(M)

	sleep(time)

/datum/custom_screen/proc/show_to(mob/M, client/C, image)
	if(locking && !M.notransform)
		locked += M
		M.notransform = TRUE
	if(!C)
		return
	watching += C
	M.overlay_fullscreen_custom("custom",/atom/movable/screen/fullscreen/custom, image)
