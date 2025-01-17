/turf/space
	plane = SPACE_PLANE
	icon = 'icons/turf/space.dmi'
	//when this be added to vis_contents of something it be associated with something on clicking, important for visualisation of turf in openspace and interraction with openspace that show you turf.
	vis_flags = VIS_INHERIT_ID
	name = "\proper space"
	icon_state = "default"
	light_power = 0.25
	always_lit = TRUE
	temperature = T20C
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	var/static/list/dust_cache

	is_hole = TRUE
	explosion_resistance = 0.5 //Impedes blasts less than any other tile, though not zero
	var/solid_below

/turf/space/proc/build_dust_cache()
	LAZYINITLIST(dust_cache)
	for (var/i in 0 to 25)
		var/image/im = image('icons/turf/space_dust.dmi',"[i]")
		im.plane = DUST_PLANE
		im.alpha = 80
		im.blend_mode = BLEND_ADD
		dust_cache["[i]"] = im


/turf/space/Initialize()
	. = ..()
	icon_state = "white"
	update_starlight()
	if (!dust_cache)
		build_dust_cache()
	overlays += dust_cache["[((x + y) ^ ~(x * y) + z) % 25]"]

	if(!HasBelow(z))
		return
	var/turf/below = GetBelow(src)

	if(istype(below, /turf/space))
		return
	var/area/A = below.loc

	solid_below = GetSolidBelow(src)

	if(!below.density && (A.area_flags & AREA_FLAG_EXTERNAL))
		return

	return INITIALIZE_HINT_LATELOAD // oh no! we need to switch to being a different kind of turf!

/turf/space/LateInitialize()
	if(GLOB.using_map.base_floor_area)
		var/area/new_area = locate(GLOB.using_map.base_floor_area) || new GLOB.using_map.base_floor_area
		ChangeArea(src, new_area)
	ChangeTurf(GLOB.using_map.base_floor_type)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		O.hide(0)

/turf/space/is_solid_structure()
	return locate(/obj/structure/lattice, src) || locate(/obj/structure/catwalk, src) //counts as solid structure if it has a lattice or catwalk

/turf/space/proc/update_starlight()
	if(CONFIG_GET(number/starlight))
		for(var/t in RANGE_TURFS(src, 1)) //RANGE_TURFS is in code\__HELPERS\game.dm
			if(isspaceturf(t))
				//let's NOT update this that much pls
				continue
			set_light(2)
			return
		set_light(0)

/turf/space/attackby(obj/item/C as obj, mob/user as mob)

	if (istype(C, /obj/item/stack/rods))
		var/obj/structure/L = locate(/obj/structure/lattice, src) || locate(/obj/structure/catwalk, src)
		if(L)
			return L.attackby(C, user)
		var/obj/item/stack/rods/R = C
		if (R.use(1))
			to_chat(user, "<span class='notice'>Constructing support lattice ...</span>")
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			ReplaceWithLattice()
		return

	if (istype(C, /obj/item/stack/tile/floor))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/floor/S = C
			if (!S.use(1))
				return
			qdel(L)
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			ChangeTurf(/turf/simulated/floor/airless, keep_air = TRUE)
			return
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support.</span>")
	return


// Ported from unstable r355

/turf/space/Entered(atom/movable/A as mob|obj)
	..()
	if(A && A.loc == src)
		if (A.x <= TRANSITIONEDGE || A.x >= (world.maxx - TRANSITIONEDGE + 1) || A.y <= TRANSITIONEDGE || A.y >= (world.maxy - TRANSITIONEDGE + 1))
			A.touch_map_edge()

/turf/space/ChangeTurf(turf/N, tell_universe = TRUE, force_lighting_update = FALSE, keep_air = FALSE)
	return ..(N, tell_universe, TRUE, keep_air)

//Bluespace turfs for shuttles and possible future transit use
/turf/space/bluespace
	name = "bluespace"
	icon_state = "bluespace"
