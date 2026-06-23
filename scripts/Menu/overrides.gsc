int_overides() {
    level.callbackplayerdamage  = ::app_override_player_damage;
    level.overridevehicledamage = ::app_overide_vehicle_damage;
    level.callbackplayerkilled  = ::app_overide_player_killed;
}

onPlayerDisconnect()
{
    if(self IsHost())
        return;
    
    foreach(player in level.players)
    {
        if(!IsDefined(player) || !IsPlayer(player) || player == self || !player hasMenu())
            continue;
        
        //If a player is navigating another players options, and that player disconnects, it will kick them back to the player menu
        if(IsDefined(player.menu_parent) && isInArray(player.menu_parent, "Players") && player.SelectedPlayer == self)
        {
            openMenu = player isInMenu(false);

            if(openMenu)
                player thread closeMenu1();
            
            player.menu_parent = [];
            player.currentMenu = "Players";
            player.menu_parent[player.menu_parent.size] = "Main";

            if(openMenu)
            {
                player thread openMenu1();
                player iPrintlnBold("^1ERROR: ^7Player Has Disconnected");
            }
        }
        else if(player isInMenu() && player getCurrent() == "Players") //If a player is viewing the player menu when a player disconnects, it will refresh the player list
        {
            player RefreshMenu();
        }
    }
}

app_override_player_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, boneindex, vsurfacenormal) {
    self endon("kill_damage_calc");
    if(isDefined(eattacker.max_damage)) idamage = (idamage + (self.health/3));
    if(isDefined(self.nerfed_damage)) idamage = self CalNerfedDamage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, boneindex, vsurfacenormal);
    if(isDefined(eattacker.ChanceToShellShock)) {
        chance = RandomIntRange(0, 20);
        if(chance == 3) self thread ApplyShellShockHarsh(15, eattacker);
    }
    weaponclass = util::getweaponclass(weapon);
    if(is_true(level.do_snipers_only) && weaponclass != "weapon_sniper") {
        idamage = int(0);
        self thread ForcePlayerSnipersOnly(eattacker);
        return;
    }
    if(is_true(level.do_no_snipers) && weaponclass == "weapon_sniper") {
        idamage = int(0);
        self thread ForcePlayerRemoveSniper(eattacker);
        return;
    }

    if(is_true(self.reflect_damage_enabled)) idamage = self ReflectDamage(idamage, eattacker);
    if(Is_True(self.BSDamageImmune)) idamage = self AntiBSDamage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, boneindex, vsurfacenormal);
    if( eattacker IsHost() && !eattacker IsTestClient()) globallogic_score::_setplayermomentum(eattacker, -100);
    if( eattacker IsTestClient()) globallogic_score::_setplayermomentum(eattacker, -1);
    //smeansofdeath = "MOD_HEAD_SHOT";
    SD("Damage Debug: ^1" + weapon.name);
    return globallogic_player::callback_playerdamage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, boneindex, vsurfacenormal);
}

app_overide_player_killed(einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime, deathanimduration, enteredresurrect = 0) {
    globallogic_player::callback_playerkilled(einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime, deathanimduration, enteredresurrect);
    
    if(is_true(level.do_instant_respawn)) { self thread [[ level.spawnplayer ]](); return; }
}

app_overide_vehicle_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, damagefromunderneath, modelindex, partname, vsurfacenormal) {
    if(!eattacker IsHost()) {
        TrollVehicleDestroyer(eattacker);
        idamage = int(0);
    } else {
        idamage = int(999999);
    }

    return idamage;
}

CalNerfedDamage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, boneindex, vsurfacenormal) {
   
    if(!isDefined(self.NerfDamageOffSet)) self.NerfDamageOffSet = int(0);
    idamage = idamage - int(idamage/3 - RandomIntRange(6, 16)) - int(self.NerfDamageOffSet);

    null_chance = RandomIntRange(0, 5);
    if(null_chance == 2) idamage = int(0); 

    if(idamage > 25) idamage = (idamage - 10); 

    return idamage;
}

AntiBSDamage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, boneindex, vsurfacenormal) {
    weaponclass = util::getweaponclass(weapon);
    // self is player taking damage
    if(weaponclass == "weapon_sniper") {
        idamage = int(0);
        eattacker.health = 1;
        eattacker.maxhealth = eattacker.health;
        eattacker iPrintLnBold("Immune to One-Shot Damage");
        eattacker Shellshock("flashbang", 15, 0);
        eattacker ShellShock("concussion_grenade_mp", 15, 0);
        self iPrintLnBold("Sniper Damage Null");
        self notify("kill_damage_calc");
    }

    if(weaponclass == "weapon_shotgun") {
        idamage = int(idamage/3);
    }

    if( IsSpecialistWeapon(weapon) || IsExplosiveDamage( smeansofdeath ) ) {
        idamage = int(0);
        self notify("kill_damage_calc");
        eattacker iPrintLnBold("Immune to One-Shot Damage");
    }

    return idamage;
}

TrollVehicleDestroyer( player ) {
    if(player IsHost()) return;
    weapon = player GetCurrentWeapon();
    player TakeWeapon(weapon);
    player Shellshock("flashbang", 15, 0);
    player ShellShock("concussion_grenade_mp", 15, 0);
    player iPrintLnBold("Leave my streak alone");
}

ReflectDamage( idamage, attacker ) {
    self thread ThreadedDoDamage(attacker, idamage);
    return int(0);
}

Callback_UpdateContinuousOptions( player = self ) {

    if(Is_True(player.ConstantUAV)) {
        player SetClientUIVisibilityFlag("radar_client", 1);
        player.hassatellite = 1;
    }
    if(Is_True(player.InfiniteJumpBoost)) {
        player resetdoublejumprechargetime();
        player setdoublejumpenergy(200);
    }

    if(Is_True(player.UnlimitedSpecialist)) {
        if(player GadgetIsActive(0))
            player GadgetPowerSet(0, 99);
        else if(player GadgetPowerGet(0) < 100)
            player GadgetPowerSet(0, 100);
    }

    if(IsDefined(player.MovementSpeed) && player.MovementSpeed != 1)
        player SetMoveSpeedScale(player.MovementSpeed);
    
    if(is_true(level.print_active_threads)) {
        level.hostplayer iPrintLn(level.app_active_threads);
    }

    if(Is_True(player.UnlimitedEquipment)) {
        offhand = player GetCurrentOffhand();
        if(IsDefined(offhand) && offhand != level.weaponnone)
            player GiveMaxAmmo(offhand);
    }

    if(player.MovementSpeed > 1) {
        player.g_speed = player.MovementSpeed;
    }

    if(isDefined(level.spawneduavs) && level.spawneduavs.size >= 1) {
        foreach(uav in level.spawneduavs) {
            uav notify("damage", 9999999, player);
        }
    }

    self.callback_timer = int(0);
    //iPrintLn("thread completed");
}