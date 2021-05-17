

/datum/event	//NOTE: Times are measured in master controller ticks!
	var/startWhen		= 0	//When in the lifetime to call start().
	var/announceWhen	= 0	//When in the lifetime to call announce().
	var/endWhen			= 0	//When in the lifetime the event should end.

	var/severity		= 0 //Severity. Lower means less severe, higher means more severe. Does not have to be supported. Is set on New().
	var/activeFor		= 0	//How long the event has existed. You don't need to change this.
	var/isRunning		= 1 //If this event is currently running. You should not change this.
	var/startedAt		= 0 //When this event started.
	var/endedAt			= 0 //When this event ended.
	var/datum/event_meta/event_meta = null
	var/list/affecting_z


/datum/event/New(var/datum/event_meta/EM)
	// event needs to be responsible for this, as stuff like APLUs currently make their own events for curious reasons
	SSevent.active_events += src

	event_meta = EM
	severity = event_meta.severity
	if(severity < EVENT_LEVEL_MUNDANE) severity = EVENT_LEVEL_MUNDANE
	if(severity > EVENT_LEVEL_MAJOR) severity = EVENT_LEVEL_MAJOR

	startedAt = world.time

	if(!affecting_z)
		affecting_z = GLOB.using_map.station_levels

	setup()
	..()

/datum/event/nothing

//Called first before processing.
//Allows you to setup your event, such as randomly
//setting the startWhen and or announceWhen variables.
//Only called once.
/datum/event/proc/setup()
	return

//Called when the tick is equal to the startWhen variable.
//Allows you to start before announcing or vice versa.
//Only called once.
/datum/event/proc/start()
	return

//Called when the tick is equal to the announceWhen variable.
//Allows you to announce before starting or vice versa.
//Only called once.
/datum/event/proc/announce()
	return

//Called on or after the tick counter is equal to startWhen.
//You can include code related to your event or add your own
//time stamped events.
//Called more than once.
/datum/event/proc/tick()
	return

//Called on or after the tick is equal or more than endWhen
//You can include code related to the event ending.
//Do not place spawn() in here, instead use tick() to check for
//the activeFor variable.
//For example: if(activeFor == myOwnVariable + 30) doStuff()
//Only called once.
/datum/event/proc/end()
	return

//Returns the latest point of event processing.
/datum/event/proc/lastProcessAt()
	return max(startWhen, max(announceWhen, endWhen))

//Do not override this proc, instead use the appropiate procs.
//This proc will handle the calls to the appropiate procs.
/datum/event/proc/process()
	if(activeFor > startWhen && activeFor < endWhen)
		tick()

	if(activeFor == startWhen)
		isRunning = 1
		start()

	if(activeFor == announceWhen)
		announce()

	if(activeFor == endWhen)
		isRunning = 0
		end()

	// Everything is done, let's clean up.
	if(activeFor >= lastProcessAt())
		kill()

	activeFor++

//Called when start(), announce() and end() has all been called.
/datum/event/proc/kill()
	// If this event was forcefully killed run end() for individual cleanup
	if(isRunning)
		isRunning = 0
		end()

	endedAt = world.time
	SSevent.event_complete(src)



/datum/event/proc/location_name()
	if(!GLOB.using_map.use_overmap)
		return station_name()

	var/obj/effect/overmap/O = map_sectors["[pick(affecting_z)]"]
	return O ? O.name : "Unknown Location"