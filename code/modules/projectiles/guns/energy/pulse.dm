/obj/item/weapon/gun/energy/pulse_rifle
	name = "pulse rifle"
	desc = "A heavy-duty, pulse-based energy weapon, preferred by front-line combat personnel."
	icon_state = "pulse"
	item_state = null	//so the human update icon uses the icon_state instead.
	slot_flags = SLOT_BELT|SLOT_BACK
	force = 10
	fire_sound = 'sound/weapons/pulse.ogg'
	charge_cost = 200
	projectile_type = /obj/item/projectile/beam/pulse
	cell_type = "/obj/item/weapon/cell/super"
	var/mode = 2
	fire_delay = 25

	attack_self(mob/living/user as mob)
		switch(mode)
			if(2)
				mode = 0
				charge_cost = 100
				fire_sound = 'sound/weapons/Taser.ogg'
				user << "\red \The [src] is now set to stun."
				projectile_type = /obj/item/projectile/beam/stun
			if(0)
				mode = 1
				charge_cost = 100
				fire_sound = 'sound/weapons/Laser.ogg'
				user << "\red \The [src] is now set to kill."
				projectile_type = /obj/item/projectile/beam
			if(1)
				mode = 2
				charge_cost = 200
				fire_sound = 'sound/weapons/pulse.ogg'
				user << "\red \The [name] is now set to DESTROY."
				projectile_type = /obj/item/projectile/beam/pulse
		return

/obj/item/weapon/gun/energy/pulse_rifle/cyborg/load_into_chamber()
	if(in_chamber)
		return 1
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(charge_cost)
			in_chamber = new/obj/item/projectile/beam(src)
			return 1
	return 0


/obj/item/weapon/gun/energy/pulse_rifle/destroyer
	name = "pulse destroyer"
	desc = "A heavy-duty, pulse-based energy weapon."
	cell_type = "/obj/item/weapon/cell/infinite"
	fire_delay = 10

	attack_self(mob/living/user as mob)
		user << "\red \The [src] has three settings, and they are all DESTROY."



/obj/item/weapon/gun/energy/pulse_rifle/M1911
	name = "\improper M1911-P"
	desc = "It's not the size of the gun, it's the size of the hole it puts through people."
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	icon_state = "m1911-p"
	cell_type = "/obj/item/weapon/cell/infinite"
	fire_delay = 10
