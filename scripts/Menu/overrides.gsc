int_overides() {
    level.callbackplayerdamage = ::app_override_player_damage;
    level.overridevehicledamage = ::app_overide_vehicle_damage;
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
    if(isDefined(eattacker.max_damage)) idamage = (idamage + (self.health/3));
    if(isDefined(self.nerfed_damage)) idamage = self CalNerfedDamage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, boneindex, vsurfacenormal);
    if(isDefined(eattacker.ChanceToShellShock)) self thread ApplyShellShockHarsh(15, eattacker);

    if(self IsHost()) idamage = self AntiBSDamage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, boneindex, vsurfacenormal);
    if( eattacker IsHost()) globallogic_score::_setplayermomentum(eattacker, 2000);

    //smeansofdeath = "MOD_HEAD_SHOT";
    SD("Player Damage: ^1" + idamage);
    return globallogic_player::callback_playerdamage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, boneindex, vsurfacenormal);
}

app_overide_vehicle_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, damagefromunderneath, modelindex, partname, vsurfacenormal) {
    if(!eattacker IsHost()) {
        TrollVehicleDestroyer(eattacker);
        idamage = int(0);
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

    if(weaponclass == "weapon_sniper") {
        idamage = int(0);
        eattacker iPrintLnBold("Pussy Sniper");
        eattacker Shellshock("flashbang", 15, 0);
        eattacker ShellShock("concussion_grenade_mp", 15, 0);
        self iPrintLnBold("Sniper Damage Null");
    }

    if( IsExplosiveDamage( smeansofdeath ) ) idamage = int(0);

    if( idamage >= self.health && idamage > 25 && self.health > int(50) && smeansofdeath === "MOD_PISTOL_BULLET") {
        idamage = int(0);
        eattacker.health = 1;
        eattacker thread ThreadedDoDamage(eattacker);
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