// Use to play custom image on screen
// Watcher can be world,mob, or a list of mobs

/client/proc/show_on_screen()
	set category = "Event.Fun"
	set name = "Show On Screen (Global)"
	ShowOnScreen(world)

/client/proc/show_on_screen_local(mob/T in GLOB.mob_list) // Mob as Target (T)
	set category = "Event.Fun"
	set name = "Show On Screen (Local)"
	var/range = input("Range:", "Show to mobs within how many tiles:", 7) as num|null
	var/watchers = list()
	for(var/mob/M in view(range,T))
		watchers += M
	ShowOnScreen(watchers)

/client/proc/show_on_screen_target(mob/T in GLOB.mob_list) // Mob as Target (T)
	set category = null
	set name = "Show On Screen (Target)"
	var/watchers = list()
	watchers += T
	ShowOnScreen(watchers)

/client/proc/show_on_screen_global_force_del()
	set category = "Event.Fun"
	set name = "Show On Screen Del (Global)"
	for(var/MM in GLOB.mob_list)
		var/mob/M = MM
		M.clear_fullscreen("custom")

/client/proc/show_on_screen_target_force_del(mob/T in GLOB.mob_list)
	set category = null
	set name = "Show On Screen Del (Target)"
	T.clear_fullscreen("custom")

/proc/ShowOnScreen(watcher)
	var/image = input(usr,"Image:","Choose image") as icon
	var/time = input(usr,"Duration","Write duration") as num
	var/show_when_dead = input(usr,"Show when dead?") in list(TRUE,FALSE)
	var/datum/custom_screen/playing = new /datum/custom_screen
	if(!playing)
		CRASH("Screen not created")
	if(watcher == world)
		watcher = GLOB.mob_list
	playing.time = time
	playing.show_when_dead = show_when_dead
	playing.image = image
	playing.play(watcher)
	qdel(playing)

/mob/proc/overlay_fullscreen_custom(category, type, var/datum/custom_screen/playing, severity)
	var/atom/movable/screen/fullscreen/custom/screen = overlay_fullscreen(category, type, severity)
	screen.icon = playing.image
	screen.show_when_dead = playing.show_when_dead
	if(screen.show_when_dead == TRUE)
		screen = overlay_fullscreen(category, type, severity)

/atom/movable/screen/fullscreen/custom
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "flash"
	plane = SPLASHSCREEN_PLANE

/datum/custom_screen
	var/list/watching = list() //List of clients watching this
	var/locking = FALSE
	var/image
	var/show_when_dead = FALSE
	var/closing_uis = FALSE
	var/list/locked = list() //Who had notransform set during the cinematic
	var/time = 100 //How long for the final screen to remain

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

/datum/custom_screen/proc/play(watcher)
	if(!islist(watcher))
		CRASH("Watcher is not list")
	for(var/MM in watcher)
		var/mob/M = MM
		if(show_to(M, M.client, image))
			RegisterSignal(M, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(show_to))
			if(closing_uis)
				SStgui.close_user_uis(M)

	sleep(time)

/datum/custom_screen/proc/show_to(mob/M, client/C)
	if(locking && !M.notransform)
		locked += M
		M.notransform = TRUE
	if(!C)
		return
	watching += C
	M.overlay_fullscreen_custom("custom",/atom/movable/screen/fullscreen/custom, src)
