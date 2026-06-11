PopulateBasicScripts(menu, player)
{
    switch(menu)
    {
        case "Basic Scripts":
            self addMenu("Basic Scripts");
                self addOptBool(player.playerGodmode, "God Mode", ::Godmode, player);
                self addOptBool(player.Noclip, "Noclip", ::Noclip1, player);
                self addOptBool(player.NoclipBind1, "Bind Noclip To [{+frag}]", ::BindNoclip, player);
                self addOptBool(player.UFOMode, "UFO Mode", ::UFOMode, player);
                self addOptSlider("Unlimited Ammo", ::UnlimitedAmmo, Array("Continuous", "Reload", "Disable"), player);
                self addOptBool(player.UnlimitedEquipment, "Unlimited Equipment", ::UnlimitedEquipment, player);
                self addOptBool(player.InfiniteJumpBoost, "Unlimited Jump Boost", ::InfiniteJumpBoost, player);
                self addOptBool(player.UnlimitedSpecialist, "Unlimited Specialist", ::UnlimitedSpecialist, player);
                self addOptBool(player.nerfed_damage, "Take Reduced Damage", ::ToggleNerfedDamage, player);
                self addOptIncSlider("Reduced Damage Offset", ::SetNerfDamageOffSet, 0, 5, 50, 5, player);
                self addOptBool(player.BSDamageImmune, "BS Damage Immune", ::BSDamageImmune, player);
                self addOpt("Perk Menu", ::newMenu, "Perk Menu");
                self addOptBool(player.ThirdPerson, "Third Person", ::ThirdPerson, player);
                self addOptIncSlider("Movement Speed", ::SetMovementSpeed, 0, 1, 3, 0.5, player);
                self addOptSlider("Clone", ::PlayerClone, Array("Clone", "Dead"), player);
                self addOptBool(player.Invisibility, "Invisibility", ::Invisibility, player);
                self addOpt("Change Classes", ::ChangeClassesPlayer, player);

                if(IsDefined(level.teamBased) && level.teamBased)
                    self addOptSlider("Change Teams", ::ChangeTeamsPlayer, Array("Allies", "Axis"), player);
                
                self addOptBool(player.ReducedSpread, "Reduced Spread", ::ReducedSpread, player);
                self addOptBool(player.MultiJump, "Multi-Jump", ::MultiJump, player);
                self addOpt("Visual Effects", ::newMenu, "Visual Effects");
                self addOptBool(player.DisablePlayerHUD, "Disable HUD", ::DisablePlayerHUD, player);
                self addOptBool(player HasPerk("specialty_sprintfire"), "Shoot While Sprinting", ::ShootWhileSprinting, player);
                self addOptBool(player HasPerk("specialty_unlimitedsprint"), "Unlimited Sprint", ::UnlimitedSprint, player);
                self addOptBool(player.ConstantUAV, "Advanced UAV", ::ConstantAdvancedUAV, player);
                self addOptBool((GetdvarInt("LoadDevConfig", 0) == 1), "Dev Init Config", ::ToggleDevConfig, player);
                self addOpt("Suicide", ::PlayerDeath, player);
            break;
        
        case "Perk Menu":
            self addMenu("Perk Menu");
                self addOptBool(player HasAllPerks(), "All Perks", ::PlayerAllPerks, player);

                for(a = 148; a < 177; a++)
                {
                    if(StatsTableType(a) != "specialty")
                        continue;
                    
                    raw = StatsTableRaw(a);
                    localized = StatsTableLocalized(a);

                    if(raw == "specialty_earnmoremomentum") //Fucks Up Killstreaks (Giving/Earning)
                        continue;

                    self addOptBool(player HasPerk1(raw), localized, ::GivePlayerPerk, raw, player);
                }
            break;
        
        case "Visual Effects":
            if(!IsDefined(player.ClientVisualEffect))
                player.ClientVisualEffect = "None";

            types = Array("visionset", "overlay");
            visuals = [];

            self addMenu("Visual Effects");

                for(a = 0; a < types.size; a++)
                {
                    Keys = GetArrayKeys(level.vsmgr[types[a]].info);

                    for(b = 0; b < Keys.size; b++)
                    {
                        if(isInArray(visuals, Keys[b]) || Keys[b] == "none" || Keys[b] == "__none" || IsSubStr(Keys[b], "last_stand") || IsSubStr(Keys[b], "_death") || IsSubStr(Keys[b], "thrasher"))
                            continue;
                        
                        visuals[visuals.size] = Keys[b];
                        self addOptBool(player GetVisualEffectState(Keys[b]), CleanString(Keys[b]), ::SetClientVisualEffects, Keys[b], player);
                    }
                }
            break;
    }
}

Godmode(player)
{
    player.playerGodmode = BoolVar(player.playerGodmode);

    if(Is_True(player.playerGodmode))
        player EnableInvulnerability();
    else
        player DisableInvulnerability();
}

Noclip1(player)
{
    player endon("disconnect");
    level endon("Kill_All_Active_Threads");

    if(!Is_True(player.Noclip) && player isPlayerLinked())
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    player.Noclip = BoolVar(player.Noclip);
    
    if(Is_True(player.Noclip))
    {
        if(player hasMenu() && player isInMenu(true))
            player closeMenu1();

        //player DisableWeapons();
        //player DisableOffHandWeapons();

        player.nocliplinker = SpawnScriptModel(player.origin, "tag_origin");
        player PlayerLinkTo(player.nocliplinker, "tag_origin");
        player.DisableMenuControls = true;
        CheckActiveThreads();

        player SetMenuInstructions("[{+attack}] - Move Forward\n[{+speed_throw}] - Move Backwards\n[{+melee}] - Exit");
        
        while(Is_True(player.Noclip) && Is_Alive(player) && !player isPlayerLinked(player.nocliplinker))
        {
            if(player AttackButtonPressed())
                player.nocliplinker.origin = player.nocliplinker.origin + AnglesToForward(player GetPlayerAngles()) * 60;
            else if(player AdsButtonPressed())
                player.nocliplinker.origin = player.nocliplinker.origin - AnglesToForward(player GetPlayerAngles()) * 60;

            if(player MeleeButtonPressed())
                break;

            wait 0.01;
        }

        if(Is_True(player.Noclip))
            player Noclip1(player);
    }
    else
    {
        player Unlink();
        player.nocliplinker Delete();
        SetThreadInactive();

        player EnableWeapons();
        player EnableOffHandWeapons();

        if(Is_True(player.DisableMenuControls))
            player.DisableMenuControls = BoolVar(player.DisableMenuControls);
        
        player SetMenuInstructions();
    }
}

BindNoclip(player)
{
    player endon("disconnect");
    level endon("Kill_All_Active_Threads");
    

    if(Is_True(player.Jetpack) && !Is_True(player.NoclipBind1))
        return self iPrintlnBold("^1ERROR: ^7Player Has Jetpack Enabled");
    
    if(Is_True(player.SpecNade) && !Is_True(player.NoclipBind1))
        return self iPrintlnBold("^1ERROR: ^7Player Has Spec-Nade Enabled");
    
    player.NoclipBind1 = BoolVar(player.NoclipBind1);

    if(Is_True(player.NoclipBind1)) CheckActiveThreads();
    else SetThreadInactive();
    
    while(Is_True(player.NoclipBind1))
    {
        if(player FragButtonPressed() && !Is_True(player.DisableMenuControls))
        {
            player thread Noclip1(player);
            wait 0.2;
        }

        wait 0.025;
    }
}

UFOMode(player)
{
    player endon("disconnect");
    level endon("Kill_All_Active_Threads");

    if(!Is_True(player.UFOMode) && player isPlayerLinked())
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    player.UFOMode = BoolVar(player.UFOMode);
    
    if(Is_True(player.UFOMode))
    {
        if(player hasMenu() && player isInMenu(true))
            player closeMenu1();

        player DisableWeapons();
        player DisableOffHandWeapons();

        player.ufolinker = SpawnScriptModel(player.origin, "tag_origin");
        player PlayerLinkTo(player.ufolinker, "tag_origin");
        player.DisableMenuControls = true;
        CheckActiveThreads();
        player SetMenuInstructions("[{+attack}] - Move Up\n[{+speed_throw}] - Move Down\n[{+frag}] - Move Forward\n[{+melee}] - Exit");
        
        while(Is_True(player.UFOMode) && Is_Alive(player) && !player isPlayerLinked(player.ufolinker))
        {
            player.ufolinker.angles = (player.ufolinker.angles[0], player GetPlayerAngles()[1], player.ufolinker.angles[2]);

            if(player AttackButtonPressed())
                player.ufolinker.origin = player.ufolinker.origin + AnglesToUp(player.ufolinker.angles) * 60;
            else if(player AdsButtonPressed())
                player.ufolinker.origin = player.ufolinker.origin - AnglesToUp(player.ufolinker.angles) * 60;

            if(player FragButtonPressed())
                player.ufolinker.origin = player.ufolinker.origin + AnglesToForward(player.ufolinker.angles) * 60;
            
            if(player MeleeButtonPressed())
                break;

            wait 0.01;
        }

        if(Is_True(player.UFOMode))
            player thread UFOMode(player);
    }
    else
    {
        player Unlink();
        player.ufolinker Delete();
        SetThreadInactive();
        player EnableWeapons();
        player EnableOffHandWeapons();

        if(Is_True(player.DisableMenuControls))
            player.DisableMenuControls = BoolVar(player.DisableMenuControls);
        
        player SetMenuInstructions();
    }
}

UnlimitedAmmo(type, player)
{
    player notify("EndUnlimitedAmmo");
    player endon("EndUnlimitedAmmo");
    player endon("disconnect");
    level endon("Kill_All_Active_Threads");

    if(type != "Disable")
    {
        CheckActiveThreads();
        while(1)
        {
            weapon = player GetCurrentWeapon();

            if(IsDefined(weapon) && weapon != level.weaponnone)
            {
                player GiveMaxAmmo(weapon);

                if(type == "Continuous")
                    player SetWeaponAmmoClip(weapon, weapon.clipsize);
            }

            player util::waittill_any("weapon_fired", "weapon_change");
        }
    }
    SetThreadInactive();
}

UnlimitedEquipment(player)
{
    player endon("disconnect");

    player.UnlimitedEquipment = BoolVar(player.UnlimitedEquipment);

    if(Is_True(player.UnlimitedEquipment)) CheckActiveThreads();
    else SetThreadInactive();

    while(Is_True(player.UnlimitedEquipment))
    {
        offhand = player GetCurrentOffhand();

        if(IsDefined(offhand) && offhand != level.weaponnone)
            player GiveMaxAmmo(offhand);
        
        player waittill("grenade_fire");
    }
}

PlayerAllPerks(player)
{
    allPerks = player HasAllPerks();

    for(a = 148; a < 177; a++)
    {
        if(StatsTableType(a) != "specialty")
            continue;
        
        raw = StatsTableRaw(a);

        if(raw == "specialty_earnmoremomentum")
            continue;

        if(IsSubStr(raw, "|"))
        {
            toks = StrTok(raw, "|");

            for(b = 0; b < toks.size; b++)
            {
                if(allPerks && player HasPerk(toks[b]))
                    player UnSetPerk(toks[b]);
                else if(!allPerks && !player HasPerk(toks[b]))
                    player SetPerk(toks[b]);
            }
        }
        else
        {
            if(allPerks && player HasPerk(raw))
                player UnSetPerk(raw);
            else if(!allPerks && !player HasPerk(raw))
                player SetPerk(raw);
        }
    }
}

GivePlayerPerk(perk, player)
{
    if(IsSubStr(perk, "|"))
        toks = StrTok(perk, "|");

    if(player HasPerk1(perk))
    {
        if(IsDefined(toks) && toks.size)
        {
            for(a = 0; a < toks.size; a++)
            {
                if(player HasPerk(toks[a]))
                    player UnSetPerk(toks[a]);
            }
        }
        else
            player UnSetPerk(perk);
    }
    else
    {
        if(IsDefined(toks) && toks.size)
        {
            for(a = 0; a < toks.size; a++)
            {
                if(!player HasPerk(toks[a]))
                    player SetPerk(toks[a]);
            }
        }
        else
            player SetPerk(perk);
    }
}

HasAllPerks()
{
    for(a = 148; a < 177; a++)
    {
        if(StatsTableType(a) != "specialty")
            continue;
        
        raw = StatsTableRaw(a);

        if(raw == "specialty_earnmoremomentum") //Fucks up giving/earning killstreaks
            continue;

        if(!self HasPerk1(raw))
            return false;
    }

    return true;
}

HasPerk1(perk)
{
    if(IsSubStr(perk, "|"))
    {
        toks = StrTok(perk, "|");

        for(a = 0; a < toks.size; a++)
        {
            if(!self HasPerk(toks[a]))
                return false;
        }
    }
    else
    {
        if(!self HasPerk(perk))
            return false;
    }

    return true;
}

ThirdPerson(player)
{
    player.ThirdPerson = BoolVar(player.ThirdPerson);
    player SetClientThirdPerson(Is_True(player.ThirdPerson));
}

SetMovementSpeed(scale, player)
{
    player notify("EndMoveSpeed");
    player endon("EndMoveSpeed");
    player endon("disconnect");
    
    player.MovementSpeed = (scale == 1) ? undefined : scale;
    player SetMoveSpeedScale(scale);
    
    while(IsDefined(player.MovementSpeed) && player.MovementSpeed != 1)
    {
        player SetMoveSpeedScale(scale);
        wait 0.5;
    }
}

PlayerClone(type, player)
{
    switch(type)
    {
        case "Clone":
            player ClonePlayer(999999, player GetCurrentWeapon(), player);
            break;
        
        case "Dead":
            clone = player ClonePlayer(999999, player GetCurrentWeapon(), player);
            clone StartRagdoll(1);
            break;
        
        default:
            break;
    }
}

Invisibility(player)
{
    player.Invisibility = BoolVar(player.Invisibility);

    if(Is_True(player.Invisibility))
        player Hide();
    else
        player Show();
}

ChangeClassesPlayer(player)
{
    ccmenu = Is_True(level.teamBased) ? game["menu_changeclass_" + player.team] : game["menu_changeclass"];
    player OpenMenu(ccmenu);

    player waittill("menuresponse", menu, response);

    if(response == "cancel")
        return;
    
    player.selectedclass = 1;
    
    player CloseInGameMenu();
    playerclass = player loadout::getclasschoice(response);

    if(IsDefined(player.pers["class"]) && player.pers["class"] == playerclass)
        return;

    self.pers["changed_class"] = 1;
    self notify("changed_class");

    if(IsDefined(self.curclass) && self.curclass == playerclass)
        self.pers["changed_class"] = 0;

    self.pers["class"] = playerclass;
    self.curclass = playerclass;
    self.pers["weapon"] = undefined;

    if(self.sessionstate == "playing")
    {
        self loadout::setclass(self.pers["class"]);
        self.tag_stowed_back = undefined;
        self.tag_stowed_hip = undefined;
        self loadout::giveloadout(self.pers["team"], self.pers["class"]);
        self killstreaks::give_owned();
    }
}

ChangeTeamsPlayer(team, player)
{
    team = ToLower(team);
    player CloseInGameMenu();

    if(player.pers["team"] == team)
        return;

    if(team != "spectator")
    {
        if(player.sessionstate == "playing")
        {
            player.switching_teams = 1;
            player.switchedteamsresetgadgets = 1;
            player.joining_team = team;
            player.leaving_team = player.pers["team"];
        }

        player LUINotifyEvent(&"clear_notification_queue");
        player.pers["team"] = team;
        player.team = team;
        player UpdateObjectiveText();

        player.sessionteam = team;
        player SetClientScriptMainMenu(game["menu_start_menu"]);
        player notify("joined_team");
        level notify("joined_team");
        callback::callback(#"hash_95a6c4c0");
        player notify("end_respawn");
    }
    else //Spectator isn't an option in Apparition, but I added support for it anyways
    {
        if(IsAlive(player))
        {
            player.switching_teams = 1;
            player.switchedteamsresetgadgets = 1;
            player.joining_team = "spectator";
            player.leaving_team = player.pers["team"];

            player Suicide();
        }

        player.pers["team"] = "spectator";
        player.team = "spectator";
        
        player UpdateObjectiveText();
        player.sessionteam = "spectator";

        if(IsDefined(level.spawnspectator))
            [[ level.spawnspectator ]]();

        player thread globallogic_player::spectate_player_watcher();
        player SetClientScriptMainMenu(game["menu_start_menu"]);

        player notify("joined_spectators");
        callback::callback(#"hash_4c5ae192");
    }
}

UpdateObjectiveText()
{
    if(self.pers["team"] == "spectator")
    {
        self SetClientCGObjectiveText("");
        return;
    }

    if(level.scorelimit > 0 || level.roundscorelimit > 0)
        self SetClientCGObjectiveText(util::getobjectivescoretext(self.pers["team"]));
    else
        self SetClientCGObjectiveText(util::getobjectivetext(self.pers["team"]));
}

ReducedSpread(player)
{
    player.ReducedSpread = BoolVar(player.ReducedSpread);

    if(Is_True(player.ReducedSpread))
        player SetSpreadOverride(1);
    else
        player ResetSpreadOverride();
}

MultiJump(player)
{    
    player endon("disconnect");

    player.MultiJump = BoolVar(player.MultiJump);

    if(Is_True(player.MultiJump)) CheckActiveThreads();
    else SetThreadInactive();

    while(Is_True(player.MultiJump))
    {
        if(player IsOnGround())
            firstJump = true;
        
        if(player JumpButtonPressed() && !player IsOnGround() && Is_True(firstJump))
        {
            while(player JumpButtonPressed())
                wait 0.01;
            
            firstJump = false;
        }
        
        if(Is_Alive(player) && !player IsOnGround() && !Is_True(firstJump))
        {
            if(player JumpButtonPressed())
            {
                while(player JumpButtonPressed())
                    wait 0.01;
                
                player SetVelocity(player GetVelocity() + (0, 0, 250));
                wait 0.05;
            }
        }
        
        wait 0.05;
    }
}

GetVisualType(effect)
{
    types = Array("visionset", "overlay");
    type = undefined;

    for(a = 0; a < types.size; a++)
    {
        foreach(key in GetArrayKeys(level.vsmgr[types[a]].info))
        {
            if(IsDefined(key) && key == effect)
                type = IsDefined(type) ? "Both" : types[a];
        }
    }

    return type;
}

GetVisualEffectState(effect)
{
    type = GetVisualType(effect);

    if(type == "Both")
    {
        types = Array("visionset", "overlay");

        for(a = 0; a < types.size; a++)
        {
            state = level.vsmgr[types[a]].info[effect].state;

            if(IsDefined(state.players[self GetEntityNumber()].active) && state.players[self GetEntityNumber()].active == 1)
                return true;
        }

        return false;
    }

    state = level.vsmgr[type].info[effect].state;
    
    if(!IsDefined(state.players[self GetEntityNumber()]))
        return false;
    
    return IsDefined(state.players[self GetEntityNumber()].active) && state.players[self GetEntityNumber()].active == 1;
}

SetClientVisualEffects(effect, player)
{
    player endon("disconnect");

    type = GetVisualType(effect);

    if(!IsDefined(type))
        return;

    if(IsDefined(player.ClientVisualEffect))
    {
        if(effect == player.ClientVisualEffect)
            effect = "None";
        else if(effect != player.ClientVisualEffect && player GetVisualEffectState(effect))
            dEffect = effect;
    }

    if(IsDefined(player.ClientVisualEffect) && player.ClientVisualEffect != "None" || IsDefined(dEffect))
    {
        if(IsDefined(dEffect))
        {
            disable = dEffect;
        }
        else
        {
            if(IsDefined(player.ClientVisualEffect))
                disable = player.ClientVisualEffect;
        }
        
        if(IsDefined(disable))
        {
            removeType = GetVisualType(disable);

            if(removeType == "visionset" || removeType == "Both")
                visionset_mgr::deactivate("visionset", disable, player);
            
            if(removeType == "overlay" || removeType == "Both")
                visionset_mgr::deactivate("overlay", disable, player);
        }
    }

    if(!IsDefined(dEffect))
    {
        player.ClientVisualEffect = effect;

        if(IsDefined(effect) && effect != "None")
        {
            if(type == "visionset" || type == "Both")
                visionset_mgr::activate("visionset", effect, player);
            
            if(type == "overlay" || type == "Both")
                visionset_mgr::activate("overlay", effect, player);
        }
    }
}

DisablePlayerHUD(player)
{
    player.DisablePlayerHUD = BoolVar(player.DisablePlayerHUD);
    player SetClientUIVisibilityFlag("hud_visible", !Is_True(player.DisablePlayerHUD));
}

ShootWhileSprinting(player)
{
    if(!player HasPerk("specialty_sprintfire"))
        player SetPerk("specialty_sprintfire");
    else
        player UnSetPerk("specialty_sprintfire");
}

UnlimitedSprint(player)
{
    if(!player HasPerk("specialty_unlimitedsprint"))
        player SetPerk("specialty_unlimitedsprint");
    else
        player UnSetPerk("specialty_unlimitedsprint");
}

ConstantAdvancedUAV(player)
{
    player endon("disconnect");
    level endon("Kill_All_Active_Threads");

    player.ConstantUAV = BoolVar(player.ConstantUAV);
    if(Is_True(player.ConstantUAV)) CheckActiveThreads();
    
    while(Is_True(player.ConstantUAV))
    {
        player SetClientUIVisibilityFlag("radar_client", 1);
        player.hassatellite = 1;

        wait 0.1;
    }
    
    if(!Is_True(player.ConstantUAV))
    {
        activeuavs = level.activeuavs[player.entnum];
        activeuavsandsatellites = (activeuavs + (IsDefined(level.activesatellites) ? level.activesatellites[player.entnum] : 0));

        player SetClientUIVisibilityFlag("radar_client", (activeuavsandsatellites > 0));
        player.hassatellite = 0;
        SetThreadInactive();
    }
}

PlayerDeath(player)
{
    if(Is_True(player.godmode))
        player Godmode(player);

    player DisableInvulnerability(); //Just to ensure that the player is able to be damaged.

    if(!Is_Alive(player))
        return self iPrintlnBold("^1ERROR: ^7Player Isn't Alive");
    
    player Suicide();
}

ToggleNerfedDamage(player = self) {
    player.nerfed_damage = isDefined(player.nerfed_damage) ? undefined : true;
    player.NerfDamageOffSet = int(0);
}

SetNerfDamageOffSet(value) {
    self.NerfDamageOffSet = value;
    self S("Offset set to " + value);
}

InfiniteJumpBoost(player = self) {
    player endon("disconnect");
    level endon("game_ended");
    level endon("Kill_All_Active_Threads");

    player.InfiniteJumpBoost = isDefined(player.InfiniteJumpBoost) ? undefined : true;

    if(Is_True(player.InfiniteJumpBoost)) CheckActiveThreads();
    else SetThreadInactive();

    while(isDefined(player.InfiniteJumpBoost)) {
        wait 0.5;
        player setdoublejumpenergy(200);
    }
}

UnlimitedSpecialist(player = self)
{
    player endon("disconnect");
    level endon("Kill_All_Active_Threads");

    if(!Is_True(player.UnlimitedSpecialist))
    {
        player.UnlimitedSpecialist = true;
        CheckActiveThreads();

        while(Is_True(player.UnlimitedSpecialist))
        {
            if(player GadgetIsActive(0))
                player GadgetPowerSet(0, 99);
            else if(player GadgetPowerGet(0) < 100)
                player GadgetPowerSet(0, 100);

            wait 0.01;
        }
    }
    else {
        player.UnlimitedSpecialist = false; 
        SetThreadInactive();
    }
}

BSDamageImmune(player = self) {
    player.BSDamageImmune = BoolVar(player.BSDamageImmune);
}