/datum/round_event_control/blob
	name = "Blob"
	typepath = /datum/round_event/ghost_role/blob
	weight = 5  //monkie edit: 10 to 5
	max_occurrences = 1

	min_players = 35  //monkie edit: 20 to 35

	earliest_start = 60 MINUTES //monkie edit: 20 to 90
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns a new blob overmind."
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT)
	checks_antag_cap = TRUE

/datum/round_event_control/blob/can_spawn_event(players, allow_magic = FALSE, fake_check = FALSE)
	if(EMERGENCY_PAST_POINT_OF_NO_RETURN) // no blobs if the shuttle is past the point of no return
		return FALSE

	return ..()

/datum/round_event/ghost_role/blob
	announce_chance = 0
	role_name = "blob overmind"
	fakeable = TRUE

/datum/round_event/ghost_role/blob/announce(fake)
	if(!fake)
		return //the mob itself handles this.
	priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK5)

/datum/round_event/ghost_role/blob/spawn_role()
	if(!GLOB.blobstart.len)
		return MAP_ERROR
	var/list/candidates = get_candidates(ROLE_BLOB, ROLE_BLOB)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/new_blob = pick(candidates)
	var/mob/camera/blob/BC = new_blob.become_overmind()
	spawned_mobs += BC
	message_admins("[ADMIN_LOOKUPFLW(BC)] has been made into a blob overmind by an event.")
	BC.log_message("was spawned as a blob overmind by an event.", LOG_GAME)
	return SUCCESSFUL_SPAWN
