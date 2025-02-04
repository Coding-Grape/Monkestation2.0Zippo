/datum/round_event_control/alien_infestation
	name = "Alien Infestation"
	typepath = /datum/round_event/ghost_role/alien_infestation
	weight = 5

	min_players = 35 //monkie edit: 10 to 35 (tg what the fuck)

	earliest_start = 60 MINUTES //monkie edit: 20 to 90
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "A xenomorph larva spawns on a random vent."
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT)
	checks_antag_cap = TRUE

/datum/round_event_control/alien_infestation/can_spawn_event(players_amt, allow_magic = FALSE, fake_check = FALSE)
	. = ..()
	if(!.)
		return .

	for(var/mob/living/carbon/alien/A in GLOB.player_list)
		if(A.stat != DEAD)
			return FALSE

/datum/round_event/ghost_role/alien_infestation
	announce_when = 400

	minimum_required = 1
	role_name = "alien larva"

	// 50% chance of being incremented by one
	var/spawncount = 1
	fakeable = TRUE


/datum/round_event/ghost_role/alien_infestation/setup()
	announce_when = rand(announce_when, announce_when + 50)
	if(prob(50))
		spawncount++
	setup = TRUE
/datum/round_event/ghost_role/alien_infestation/announce(fake)
	var/living_aliens = FALSE
	for(var/mob/living/carbon/alien/A in GLOB.player_list)
		if(A.stat != DEAD)
			living_aliens = TRUE

	if(living_aliens || fake)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)


/datum/round_event/ghost_role/alien_infestation/spawn_role()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue//no parent vent
			//Stops Aliens getting stuck in small networks.
			//See: Security, Virology
			if(temp_vent_parent.other_atmos_machines.len > 20)
				vents += temp_vent

	if(!vents.len)
		message_admins("An event attempted to spawn an alien but no suitable vents were found. Shutting down.")
		return MAP_ERROR

	var/list/candidates = get_candidates(ROLE_ALIEN, ROLE_ALIEN)

	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/mob/dead/observer/selected = pick_n_take(candidates)
		var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
		new_xeno.key = selected.key
		new_xeno.move_into_vent(vent)

		spawncount--
		message_admins("[ADMIN_LOOKUPFLW(new_xeno)] has been made into an alien by an event.")
		new_xeno.log_message("was spawned as an alien by an event.", LOG_GAME)
		spawned_mobs += new_xeno

	return SUCCESSFUL_SPAWN
