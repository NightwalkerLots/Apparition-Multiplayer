PopulateFunScripts(menu, player)
{
    switch(menu)
    {
        case "Fun Scripts":
            self addMenu("Fun Scripts");
                self addOpt("Effect Man Options", ::newMenu, "Effect Man Options");
                self addOpt("Force Field Options", ::newMenu, "Force Field Options");
                self addOpt("Fireworks Options", ::newMenu, "Fireworks Options");
                self addOptSlider("Human Fountain", ::HumanFountain, Array("Disable", "Gore", "Water", "Smoke"), player);
                self addOpt("Mortar Strike", ::MortarStrike, player);
                self addOpt("Adventure Time", ::AdventureTime, player);
                self addOpt("Earthquake", ::SendEarthquake, player);
                self addOptBool(player.drivable_car_enabled, "Drivablce Car", ::toggle_drivable_car, player);
                self addOptBool(player.Jetpack, "Jetpack", ::Jetpack, player);
                self addOptBool(player.grab_players, "Grab Players", ::GrabPlayers, player);
                self addOptBool(player.LightProtector, "Light Protector", ::LightProtector, player);
                self addOptBool(player.DeadOpsView, "Dead Ops View", ::DeadOpsView, player);
                self addOptBool(player.DropCamera, "Drop Camera", ::PlayerDropCamera, player);
                self addOptBool(player.IceSkating, "Ice Skating", ::IceSkating, player);
                self addOptBool(player.ForgeMode, "Forge Mode", ::ForgeMode, player);
                self addOptBool(player.ClusterGrenades, "Cluster Grenades", ::ClusterGrenades, player);
                self addOptBool(player.RocketRiding, "Rocket Riding", ::RocketRiding, player);
                self addOptBool(player.GrapplingGun, "Grappling Gun", ::GrapplingGun, player);
                self addOptBool(player.GravityGun, "Gravity Gun", ::GravityGun, player);
                self addOptBool(player.DeleteGun, "Delete Gun", ::DeleteGun, player);
                self addOptBool(player.FrogJump, "Frog Jump", ::FrogJump, player);
                self addOptBool(player.SpecNade, "Spec-Nade", ::SpecNade, player);
                self addOptBool(player.AutoDropShot, "Auto-Drop Shot", ::AutoDropShot, player);
                self addOptBool(player.HumanCentipede, "Human Centipede", ::HumanCentipede, player);
            break;
        
        case "Effect Man Options":
            if(!IsDefined(player.FXManTag))
                player.FXManTag = "j_head";
            
            self addMenu("Effect Man Options");
                self addOpt("Disable", ::DisableFXMan, player);
                self addOptSlider("Tag", ::SetFXManTag, Array("j_head", "j_neck", "j_spineupper", "j_spinelower", "j_mainroot", "j_shoulder_le", "j_shoulder_ri", "j_elbow_le", "j_elbow_ri", "j_wrist_le", "j_wrist_ri", "j_hip_le", "j_mainroot", "j_hip_ri", "j_knee_le", "j_knee_ri", "j_ankle_le", "j_ankle_ri", "j_ball_le", "j_ball_ri"), player);
                self addOpt("");
                
                for(a = 0; a < level.menuFX.size; a++)
                    self addOpt(CleanString(level.menuFX[a]), ::FXMan, level.menuFX[a], player);
            break;
        
        case "Force Field Options":
            if(!IsDefined(player.ForceFieldSize))
                player.ForceFieldSize = 250;
            
            if(!IsDefined(player.ForceFieldAction))
                player.ForceFieldAction = "Kill";
            
            self addMenu("Force Field Options");
                self addOptBool(player.ForceField, "Force Field", ::ForceField, player);
                self addOptIncSlider("Force Field Size", ::ForceFieldSize, 250, player.ForceFieldSize, 500, 25, player);
                self addOptSlider("Force Field Action", ::ForceFieldAction, Array("Kill", "Push"), player);
            break;

        case "Fireworks Options":
            if(!IsDefined(player.FireworksHeight))
                player.FireworksHeight = 850;
            
            if(!IsDefined(player.FireworksDensity))
                player.FireworksDensity = 6;
            
            if(!IsDefined(player.FireworksSpeed))
                player.FireworksSpeed = "Medium";
            
            self addMenu("Fireworks Options");
                self addOptBool(player.FireworksShow, "Fireworks Show", ::ToggleFireworksShow, player);
                self addOpt("Grand Finale", ::LaunchFireworksFinale, player);
                self addOptBool(player.FireworksGun, "Fireworks Gun", ::ToggleFireworksGun, player);
                self addOpt("Crosshair Fireworks", ::LaunchCrosshairFireworks, player);
                self addOpt("Select Location Fireworks", ::LaunchLocationFireworks, player);
                self addOptIncSlider("Burst Height", ::SetFireworksHeight, 400, player.FireworksHeight, 1500, 100, player);
                self addOptIncSlider("Burst Density", ::SetFireworksDensity, 3, player.FireworksDensity, 10, 1, player);
                self addOptSlider("Show Speed", ::SetFireworksSpeed, Array("Slow", "Medium", "Fast"), player);
            break;
    }
}

FXMan(fx, player)
{
    player notify("EndFXMan");
    player endon("disconnect");
    player endon("EndFXMan");
    
    player.FXMan = true;
    
    if(IsDefined(player.fxent))
        player.fxent delete();
    
    wait 0.05;
    player.SavedFX = fx;
    player.SavedFXTag = player.FXManTag;
    
    while(Is_True(player.FXMan))
    {
        if(IsAlive(player))
        {
            player.fxent = SpawnFX(level._effect[player.SavedFX], player GetTagOrigin(player.SavedFXTag));
            TriggerFX(player.fxent);
            wait 0.1;
        }
        
        if(IsDefined(player.fxent))
            player.fxent delete();
        
        wait 0.1;
    }
}

SetFXManTag(tag, player)
{
    player.FXManTag = tag;
    player.FXMan = false;
    
    if(IsDefined(player.SavedFX))
        player thread FXMan(player.SavedFX, player);
}

DisableFXMan(player)
{
    player notify("EndFXMan");
    player.FXMan = false;
    
    if(IsDefined(player.fxent))
        player.fxent delete();
    
    wait 0.05;
    player.SavedFX = undefined;
}

ForceField(player)
{
    player endon("disconnect");

    player.ForceField = BoolVar(player.ForceField);

    while(Is_True(player.ForceField))
    {
        if(IsAlive(player))
        {
            foreach(client in GetPlayerArray())
            {
                if(client isHost() || client isDeveloper() || !IsAlive(client) || Distance(player.origin, client.origin) > player.ForceFieldSize || client == player || level.teamBased && client.pers["team"] == player.pers["team"])
                    continue;
                
                switch(player.ForceFieldAction)
                {
                    case "Kill":
                        client thread [[ level.callbackPlayerDamage ]](player, player, (client.health + 999), 0, "MOD_RIFLE_BULLET", player GetCurrentWeapon(), (0, 0, 0), (0, 0, 0), "head", 0, 0);
                        break;
                    
                    case "Push":
                        client SetVelocity(client GetVelocity() + VectorScale(AnglesToForward(player GetPlayerAngles()), 300));
                        break;
                    
                    default:
                        break;
                }
            }
        }
        
        wait 0.05;
    }
}

ForceFieldAction(type, player)
{
    player.ForceFieldAction = type;
}

ForceFieldSize(num, player)
{
    player.ForceFieldSize = num;
}

MortarStrike(player)
{
    newOrigin = self RunCustomLocationSelection();
                
    if(!IsDefined(newOrigin))
        return;
    
    StrikePosition = newOrigin + (0, 0, 2500);
    
    for(a = -1; a < 2; a += 2)
    {
        for(b = 0; b < 5; b++)
        {
            MagicBullet(GetWeapon("hunter_rocket_turret_player"), StrikePosition, StrikePosition - (0, (b * (a * 50)), 2500), player);
            wait 0.25;
        }
    }
    
    for(a = -1; a < 2; a += 2)
    {
        for(b = 0; b < 5; b++)
        {
            MagicBullet(GetWeapon("hunter_rocket_turret_player"), StrikePosition, StrikePosition - ((b * (a * 50)), 0, 2500), player);
            wait 0.25;
        }
    }
}

AdventureTime(player)
{
    if(Is_True(player.AdventureTime))
        return;
    
    if(player isPlayerLinked())
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    player endon("disconnect");
    
    player.AdventureTime = true;
    
    origin = player.origin;
    model = SpawnScriptModel(player.origin, "wpn_t7_care_package_world", (0, player.angles[1], 0));
    player PlayerLinkTo(model);
    
    for(a = 0; a < 10; a++)
    {
        if(!IsAlive(player))
            break;
        
        newOrigin = origin + (RandomInt(7500), RandomInt(7500), RandomIntRange(1000, 7500));
        model MoveTo(newOrigin, 1.5);
        wait 3;
    }
    
    if(IsAlive(player))
    {
        model MoveTo(origin, 3);
        wait 3.5;
        
        player Unlink();
    }
    
    model delete();
    player.AdventureTime = false;
}

SendEarthquake(player)
{
    Earthquake(1, 15, player.origin, 750);
}

HumanFountain(type, player)
{
    if(type != "Disable")
    {
        player notify("EndHumanFountain");
        player endon("disconnect");
        player endon("EndHumanFountain");
        
        switch(type)
        {
            case "Gore":
                fx = "impacts/fx_flesh_hit";
                break;
            
            case "Water":
                fx = "impacts/fx_xtreme_water_hit_mp";
                break;
            
            case "Smoke":
                fx = "weapon/trophy_system/fx_trophy_deploy_impact";
                break;
            
            default:
                fx = "impacts/fx_flesh_hit";
                break;
        }
        
        tags = Array("j_head", "j_neck", "j_spine4", "j_spinelower", "j_mainroot", "pelvis", "j_ankle_le", "j_ankle_ri");
        
        while(1)
        {
            if(IsAlive(player))
                PlayFXOnTag(level._effect[fx], player, tags[RandomInt(tags.size - 1)]);
            
            wait 0.075;
        }
    }
    else
        player notify("EndHumanFountain");
}

Jetpack(player)
{
    player endon("disconnect");

    if(player isPlayerLinked() && !Is_True(player.Jetpack))
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    if(Is_True(player.NoclipBind1) && !Is_True(player.Jetpack))
        return self iPrintlnBold("^1ERROR: ^7Player Has Noclip Bind Enabled");
    
    player.Jetpack = BoolVar(player.Jetpack);

    if(Is_True(player.Jetpack))
    {
        player iPrintlnBold("Press & Hold [{+frag}] To Use Jetpack");

        while(Is_True(player.Jetpack))
        {
            if(player FragButtonPressed() && !player isPlayerLinked())
            {
                if(player IsOnGround())
                    player SetOrigin((player.origin + (0, 0, 5)));
                
                Earthquake(0.55, 0.05, player GetTagOrigin("back_low"), 25);
                player SetVelocity((player GetVelocity() + (0, 0, 50)));
                PlayFX(level._effect["character_fire_death_torso"], player GetTagOrigin("back_low"));
            }

            wait 0.05;
        }
    }
}

LightProtector(player)
{
    player endon("disconnect");
    player endon("EndLightProtector");

    player.LightProtector = BoolVar(player.LightProtector);

    if(Is_True(player.LightProtector))
    {
        player.LightProtect = SpawnScriptModel(player GetTagOrigin("j_head") + (0, 0, 45), "tag_origin");

        if(IsDefined(player.LightProtect))
            PlayFXOnTag(level._effect["prox_grenade_friendly_warning"], player.LightProtect, "tag_origin");

        while(Is_True(player.LightProtector) && IsDefined(player.LightProtect))
        {
            player.LightProtect MoveTo(player GetTagOrigin("j_head") + (0, 0, 45), 0.1);
            target = player GetLightProtectorTarget(500);
            
            if(IsDefined(target))
                player LightProtectorMoveToTarget(target);
            
            wait 0.1;
        }

        //In the case that the entity crash protection deletes the light protector, but the light protector variable is still true
        if(Is_True(player.LightProtector) && !IsDefined(player.LightProtect))
            LightProtector(player);
    }
    else
    {
        if(IsDefined(player.LightProtect))
            player.LightProtect Delete();
        
        player notify("EndLightProtector");
    }
}

LightProtectorMoveToTarget(target)
{
    if(!IsDefined(target) || !IsAlive(target) || !IsDefined(self.LightProtect))
        return;
    
    self endon("disconnect");
    self endon("EndLightProtector");
    
    if(self IsDamageable(target, target.origin) && Distance(self.origin, target.origin) <= 500)
    {
        origin = target GetTagOrigin("j_head");
        time = CalcDistance(1100, self.LightProtect.origin, origin);
        self.LightProtect MoveTo(origin, time);
        wait time;

        RadiusDamage(target GetTagOrigin("j_head"), 1, (target.health + 999), (target.health + 999), self);
        wait 0.1;

        newTarget = self GetLightProtectorTarget(500);

        if(IsDefined(newTarget))
        {
            self thread LightProtectorMoveToTarget(target);
            return;
        }

        if(!IsDefined(self.LightProtect))
            return;
        
        time = CalcDistance(1100, self.LightProtect.origin, self GetTagOrigin("j_head") + (0, 0, 45));
        self.LightProtect MoveTo(self GetTagOrigin("j_head") + (0, 0, 45), time);
        wait time;
    }
}

GetLightProtectorTarget(distance)
{
    foreach(player in GetPlayerArray())
    {
        if(player == self || Distance(self.origin, player.origin) > distance || player isHost() || !IsAlive(player) || level.teamBased && self.pers["team"] == player.pers["team"] || !self IsDamageable(player, player GetTagOrigin("j_head")))
            continue;
        
        if(self IsDamageable(player, player.origin) && Distance(self.origin, player.origin) <= distance)
        {
            if(!IsDefined(enemy))
                enemy = player;
            
            if(IsDefined(enemy) && enemy != player && Closer(self.origin, player.origin, enemy.origin) && self IsDamageable(player, player.origin))
                enemy = player;
        }
    }

    return enemy;
}

DeadOpsView(player)
{
    if(!Is_Alive(player) && !Is_True(player.DeadOpsView))
        return iPrintlnBold("^1ERROR: ^7Player Needs To Be Alive To Enable Dead Ops View");
    
    if(Is_True(player.SpecNade) && !Is_True(player.DeadOpsView))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Spec-Nade Is Enabled");
    
    if(Is_True(player.DropCamera) && !Is_True(player.DeadOpsView))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Drop Camera Is Enabled");
    
    player.DeadOpsView = BoolVar(player.DeadOpsView);
    
    if(Is_True(player.DeadOpsView))
    {
        player endon("disconnect");
        
        tracePosition = BulletTrace(player.origin, player.origin + (0, 0, 350), 0, player)["position"];
        player.camlinker = SpawnScriptModel(tracePosition, "tag_origin", (90, 90, 0));
        
        player CameraSetPosition(player.camlinker);
        player CameraSetLookat(player.camlinker);
        player CameraActivate(true);
        
        while(Is_True(player.DeadOpsView))
        {
            if(IsAlive(player))
            {
                tracePosition = BulletTrace(player.origin, player.origin + (0, 0, 350), 0, player)["position"];
                
                if(IsDefined(player.camlinker) && player.camlinker.origin != tracePosition)
                    player.camlinker.origin = tracePosition;
            }
            
            wait 0.01;
        }
    }
    else
    {
        player CameraActivate(false);
        
        if(IsDefined(player.camlinker))
            player.camlinker Delete();
    }
}

PlayerDropCamera(player)
{
    player endon("disconnect");
    
    if(Is_True(player.SpecNade) && !Is_True(player.DropCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Spec-Nade Is Enabled");
    
    if(Is_True(player.PlayerMountCamera) && !Is_True(player.DropCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Mount Camera Is Enabled");
    
    if(Is_True(player.DeadOpsView) && !Is_True(player.DropCamera))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Dead Ops View Is Enabled");
    
    player.DropCamera = BoolVar(player.DropCamera);
    
    if(Is_True(player.DropCamera))
    {
        player.camlinker = SpawnScriptModel(player GetTagOrigin("j_head"), "tag_origin");

        player CameraSetLookAt(player);
        player CameraSetPosition(player.camlinker);
        player CameraActivate(true);

        player.camlinker Launch(VectorScale(AnglesToForward(self GetPlayerAngles()), 10));
    }
    else
    {
        player CameraActivate(false);

        if(IsDefined(player.camlinker))
            player.camlinker Delete();
    }
}

IceSkating(player)
{
    player.IceSkating = BoolVar(player.IceSkating);
    player ForceSlick(Is_True(player.IceSkating));
}

ForgeMode(player)
{
    player endon("disconnect");

    if(Is_True(player.DeleteGun))
        player DeleteGun(player);
    
    if(Is_True(player.GravityGun))
        player GravityGun(player);
    
    player.ForgeMode = BoolVar(player.ForgeMode);

    if(Is_True(player.ForgeMode))
    {
        player iPrintln("Aim At Entities/Zombies/Players To Pick Them Up");
        player iPrintln("[{+attack}] To Release");
        
        grabEnt = undefined;

        while(Is_True(player.ForgeMode))
        {
            if(IsDefined(grabEnt) && (IsPlayer(grabEnt) && !Is_Alive(grabEnt) || Is_True(grabEnt.is_zombie) && !IsAlive(grabEnt)))
                grabEnt = undefined;
            
            if(IsDefined(grabEnt))
            {
                if(IsPlayer(grabEnt))
                    grabEnt SetOrigin((player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250)));
                else
                    grabEnt.origin = (player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250));

                if(player AttackButtonPressed())
                    grabEnt = undefined;
            }

            if(player AdsButtonPressed() && !IsDefined(grabEnt))
            {
                trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 1, player);

                if(IsDefined(trace["entity"]) && trace["entity"].model != "tag_origin")
                    grabEnt = trace["entity"];
            }

            wait 0.01;
        }
    }
}

ClusterGrenades(player)
{
    player endon("disconnect");
    player endon("EndClusterGrenades");

    player.ClusterGrenades = BoolVar(player.ClusterGrenades);
    
    if(Is_True(player.ClusterGrenades))
    {
        while(Is_True(player.ClusterGrenades))
        {
            player waittill("grenade_fire", grenade, weapon);
            if(!IsDefined(grenade) || !IsDefined(weapon) || IsInvalidEquipmentEffects(weapon, "Explosion"))
                continue;
            
            while(IsDefined(grenade))
            {
                origin = grenade.origin;
                wait 0.1;
            }

            for(a = 0; a < 10; a++)
                player MagicGrenadeType(weapon, origin, GetRandomThrowSpeed(), ((30 + a) / 10));
        }
    }
    else
        player notify("EndClusterGrenades");
}

GetRandomThrowSpeed()
{
    yaw = RandomFloat(360);
    pitch = RandomFloatRange(65, 85);
    
    return (((Cos(yaw) * Cos(pitch)), (Sin(yaw) * Cos(pitch)), Sin(pitch)) * RandomFloatRange(400, 600));
}

RocketRiding(player)
{
    player endon("disconnect");
    player endon("EndRocketRiding");

    player.RocketRiding = BoolVar(player.RocketRiding);
    
    if(Is_True(player.RocketRiding))
    {
        while(Is_True(player.RocketRiding))
        {
            player waittill("missile_fire", missile, weaponName);

            if(util::getweaponclass(weaponName) != "weapon_launcher")
                continue;
            
            trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 200), 1, player);
            rider = undefined;

            foreach(client in level.players)
            {
                if(!IsAlive(client) || client == player)
                    continue;
                
                if(Distance(client.origin, trace["position"]) <= 225)
                {
                    if(!IsDefined(rider))
                    {
                        rider = client;
                    }
                    else
                    {
                        if(Distance(client, trace["position"]) < Distance(rider, trace["position"]))
                            rider = client;
                    }
                }
            }
            
            if(!IsDefined(rider))
                rider = player;
            
            if(Is_True(rider.RidingRocket))
            {
                rider notify("StopRidingRocket");
                rider Unlink();
                rider.RocketRidingLinker Delete();
                rider.RidingRocket = BoolVar(rider.RidingRocket);
            }
            
            wait 0.2;
            rider.RidingRocket = true;
            rider.RocketRidingLinker = SpawnScriptModel(missile.origin, "tag_origin");

            if(IsDefined(rider.RocketRidingLinker))
                rider.RocketRidingLinker LinkTo(missile);
            
            rider SetOrigin(rider.RocketRidingLinker.origin);
            rider PlayerLinkTo(rider.RocketRidingLinker);

            wait 0.1;
            rider thread WatchRocket(missile);
        }
    }
    else
        player notify("EndRocketRiding");
}

WatchRocket(rocket)
{
    self endon("death");
    self endon("disconnect");
    self endon("StopRidingRocket");
    
    while(IsDefined(rocket) && Is_Alive(self))
    {
        if(self MeleeButtonPressed())
            break;

        wait 0.05;
    }
    
    self Unlink();

    if(IsDefined(self.RocketRidingLinker))
        self.RocketRidingLinker Delete();
    
    if(Is_True(self.RidingRocket))
        self.RidingRocket = BoolVar(self.RidingRocket);
}

GrapplingGun(player)
{
    player endon("disconnect");
    player endon("EndGrapplingGun");
    
    player.GrapplingGun = BoolVar(player.GrapplingGun);

    if(Is_True(player.GrapplingGun))
    {
        while(Is_True(player.GrapplingGun))
        {
            player waittill("weapon_fired");
            
            trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 0, player);
            origin = trace["position"];
            surface = trace["surfacetype"];

            if(surface == "none" || surface == "default" || IsDefined(player.grapplingent))
                continue;
            
            player.grapplingent = SpawnScriptModel(player.origin, "tag_origin");

            if(!IsDefined(player.grapplingent))
                continue;

            player PlayerLinkTo(player.grapplingent);
            player.grapplingent MoveTo(origin, 1);
            player.grapplingent waittill("movedone");

            if(!IsDefined(player.grapplingent))
                continue;
            
            player Unlink();
            player.grapplingent Delete();
        }
    }
    else
    {
        if(IsDefined(player.grapplingent))
            player.grapplingent Delete();
        
        player notify("EndGrapplingGun");
    }
}

GravityGun(player)
{
    player endon("disconnect");

    if(Is_True(player.DeleteGun))
        player DeleteGun(player);
    
    if(Is_True(player.ForgeMode))
        player ForgeMode(player);
    
    player.GravityGun = BoolVar(player.GravityGun);

    if(Is_True(player.GravityGun))
    {
        player iPrintln("Aim At Entities/Players To Pick Them Up");
        player iPrintln("[{+attack}] To Launch");

        grabEnt = undefined;
        
        while(Is_True(player.GravityGun))
        {
            if(IsDefined(grabEnt) && IsPlayer(grabEnt) && !IsAlive(grabEnt))
                grabEnt = undefined;
            
            if(IsDefined(grabEnt))
            {
                if(IsPlayer(grabEnt))
                    grabEnt SetOrigin((player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250)));
                else
                    grabEnt.origin = (player GetEye() + VectorScale(AnglesToForward(player GetPlayerAngles()), 250));
                
                if(player AttackButtonPressed() && IsDefined(grabEnt))
                {
                    shootEnt = SpawnScriptModel(grabEnt.origin, "tag_origin");

                    if(IsPlayer(grabEnt))
                        grabEnt PlayerLinkTo(shootEnt);
                    else
                        grabEnt LinkTo(shootEnt);
                    
                    grabEnt.GravityGunLaunched = true;
                    shootEnt.GravityGunLaunched = true;

                    shootEnt thread deleteAfter(5);
                    grabEnt thread GravityGunUnlinkAfter(5);
                    shootEnt Launch(VectorScale(AnglesToForward(player GetPlayerAngles()), 2500));
                    wait 0.1;

                    grabEnt = undefined;
                }
            }

            if(player AdsButtonPressed() && !IsDefined(grabEnt))
            {
                trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 1, player);

                if(IsDefined(trace["entity"]) && !Is_True(trace["entity"].GravityGunLaunched) && trace["entity"].model != "tag_origin")
                    grabEnt = trace["entity"];
            }

            wait 0.01;
        }
    }
}

GravityGunUnlinkAfter(time)
{
    self endon("death");
    self endon("disconnect");
    
    wait time;

    if(IsDefined(self))
        self Unlink();

    if(IsDefined(self) && Is_True(self.GravityGunLaunched))
        self.GravityGunLaunched = BoolVar(self.GravityGunLaunched);
}

DeleteGun(player)
{
    player endon("disconnect");

    if(Is_True(player.GravityGun))
        player GravityGun(player);
    
    if(Is_True(player.ForgeMode))
        player ForgeMode(player);
    
    player.DeleteGun = BoolVar(player.DeleteGun);

    if(Is_True(player.DeleteGun))
    {
        player iPrintlnBold("Aim At Entities To Delete Them");
        
        while(Is_True(player.DeleteGun))
        {
            if(player AdsButtonPressed())
            {
                trace = BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(player GetPlayerAngles()), 1000000), 1, player);

                if(IsDefined(trace["entity"]) && !IsPlayer(trace["entity"]))
                    trace["entity"] Delete();
            }

            wait 0.01;
        }
    }
}

RapidFire(player)
{
    player endon("disconnect");
    player endon("EndRapidFire");

    player.RapidFire = BoolVar(player.RapidFire);
    
    if(Is_True(player.RapidFire))
    {
        while(Is_True(player.RapidFire))
        {
            player waittill("weapon_fired");

            weapon = player GetCurrentWeapon();

            if(!IsDefined(weapon) || weapon == level.weaponnone)
                continue;

            for(a = 0; a < 3; a++)
            {
                MagicBullet(weapon, player GetWeaponMuzzlePoint(), BulletTrace(player GetWeaponMuzzlePoint(), player GetWeaponMuzzlePoint() + player GetWeaponForwardDir() * 100, 0, undefined)["position"] + (RandomFloatRange(-5, 5), RandomFloatRange(-5, 5), RandomFloatRange(-5, 5)), player);
                wait 0.05;
            }
        }
    }
    else
        player notify("EndRapidFire");
}

AutoDropShot(player)
{
    player.AutoDropShot = BoolVar(player.AutoDropShot);

    if(Is_True(player.AutoDropShot))
    {
        player endon("disconnect");
        player endon("EndAutoDropShot");
        
        while(Is_True(player.AutoDropShot))
        {
            player waittill("weapon_fired");
            player SetStance("prone");
        }
    }
    else
        player notify("EndAutoDropShot");
}

FrogJump(player)
{
    player.FrogJump = BoolVar(player.FrogJump);

    if(Is_True(player.FrogJump))
    {
        player endon("disconnect");
        
        while(Is_True(player.FrogJump))
        {
            if(player JumpButtonPressed() && !player IsOnGround() && player GetStance() == "stand" && IsAlive(player))
            {
                AngF = AnglesToForward(player GetPlayerAngles());
                player SetVelocity((AngF[0] * 550, AngF[1] * 550, 400));
                
                while(!player IsOnGround())
                    wait 0.05;
            }
            
            wait 0.01;
        }
    }
}

HumanCentipede(player)
{
    player.HumanCentipede = BoolVar(player.HumanCentipede);

    if(Is_True(player.HumanCentipede))
    {
        player.HumanCentipedeArray = [];
        player.HumanCentipedeClone = 0;
        
        while(Is_True(player.HumanCentipede))
        {
            if(IsAlive(player))
            {
                player.HumanCentipedeArray[player.HumanCentipedeClone] = player ClonePlayer(999999, player GetCurrentWeapon(), player);
                player.HumanCentipedeArray[player.HumanCentipedeClone] StartRagDoll(1);
                
                player.HumanCentipedeClone++;
                
                if(player.HumanCentipedeArray.size >= 8)
                {
                    if(player.HumanCentipedeClone >= 8)
                        player.HumanCentipedeClone = 0;
                    
                    if(IsDefined(player.HumanCentipedeArray[player.HumanCentipedeClone]))
                        player.HumanCentipedeArray[player.HumanCentipedeClone] Delete();
                }
            }
            else
            {
                if(player.HumanCentipedeArray.size)
                {
                    foreach(clone in player.HumanCentipedeArray)
                    {
                        if(IsDefined(clone))
                            clone Delete();
                    }
                }
            }
            
            wait 0.01;
        }
    }
    else
    {
        foreach(clone in player.HumanCentipedeArray)
        {
            if(IsDefined(clone))
                clone Delete();
        }
    }
}

SpecNade(player)
{
    player endon("disconnect");
    player endon("EndSpecNade");
    
    if(player isPlayerLinked() && !Is_True(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7Player Is Linked To An Entity");
    
    if(Is_True(player.NoclipBind1) && !Is_True(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Noclip Bind Is Enabled");
    
    if(Is_True(player.DropCamera) && !Is_True(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Drop Camera Is Enabled");
    
    if(Is_True(player.DeadOpsView) && !Is_True(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Dead Ops View Is Enabled");
    
    if(Is_True(player.PlayerMountCamera) && !Is_True(player.SpecNade))
        return self iPrintlnBold("^1ERROR: ^7You Can't Use This Option While Mount Camera Is Enabled");
    
    player.SpecNade = BoolVar(player.SpecNade);

    if(Is_True(player.SpecNade))
    {
        while(Is_True(player.SpecNade))
        {
            player waittill("grenade_fire", grenade, name);
            
            if(!IsDefined(grenade) || IsInvalidEquipmentEffects(name) || player isPlayerLinked())
                continue;

            linker = SpawnScriptModel(grenade.origin, "tag_origin");
            linker LinkTo(grenade);
            player PlayerLinkTo(linker);
            
            while(IsDefined(grenade))
                wait 0.1;
            
            linker delete();
        }
    }
    else
    {
        player notify("EndSpecNade");
    }
}

/*
    ================================================
    Fireworks System
    ================================================
*/

ToggleFireworksShow(player)
{
    player endon("disconnect");
    player.FireworksShow = BoolVar(player.FireworksShow);

    if(Is_True(player.FireworksShow))
    {
        player notify("EndFireworksShow");
        player endon("EndFireworksShow");

        player iPrintlnBold("^2Fireworks Show: ^7Started");

        while(Is_True(player.FireworksShow))
        {
            if(IsAlive(player))
            {
                offsetX = RandomFloatRange(-800, 800);
                offsetY = RandomFloatRange(-800, 800);
                groundGuess = player.origin + (offsetX, offsetY, 100);
                trace = BulletTrace(groundGuess, groundGuess - (0, 0, 1000), 0, undefined);
                launchPos = trace["position"];

                height = player.FireworksHeight + RandomIntRange(-120, 180);
                density = player.FireworksDensity;

                level thread LaunchSingleFirework(launchPos, height, density, player);

                delay = 1.0;
                if(IsDefined(player.FireworksSpeed))
                {
                    switch(player.FireworksSpeed)
                    {
                        case "Slow":
                            delay = RandomFloatRange(1.4, 2.2);
                            break;
                        case "Medium":
                            delay = RandomFloatRange(0.7, 1.3);
                            break;
                        case "Fast":
                            delay = RandomFloatRange(0.35, 0.6);
                            break;
                    }
                }
                wait delay;
            }
            else
                wait 1;
        }
    }
    else
    {
        player notify("EndFireworksShow");
        player iPrintlnBold("^1Fireworks Show: ^7Stopped");
    }
}

LaunchFireworksFinale(player)
{
    player endon("disconnect");

    if(Is_True(player.FireworksFinaleActive))
        return player iPrintlnBold("^1ERROR: ^7Finale already running!");

    player.FireworksFinaleActive = true;
    player iPrintlnBold("^3GRAND FIREWORKS FINALE!");

    baseOrigin = player.origin;
    totalRockets = 26;

    for(i = 0; i < totalRockets; i++)
    {
        if(!IsAlive(player))
            break;

        offsetX = RandomFloatRange(-900, 900);
        offsetY = RandomFloatRange(-900, 900);
        groundGuess = baseOrigin + (offsetX, offsetY, 100);
        trace = BulletTrace(groundGuess, groundGuess - (0, 0, 1000), 0, undefined);
        launchPos = trace["position"];

        height = player.FireworksHeight + RandomIntRange(-150, 200);
        density = (i > 18) ? (player.FireworksDensity + 2) : player.FireworksDensity;

        level thread LaunchSingleFirework(launchPos, height, density, player);

        speedRatio = 1.0 - (i / totalRockets);
        wait (0.12 + (speedRatio * 0.35));
    }

    for(k = 0; k < 4; k++)
    {
        angle = k * 90;
        dir = AnglesToForward((0, angle, 0));
        launchPos = baseOrigin + (dir * 350);
        trace = BulletTrace(launchPos + (0, 0, 100), launchPos - (0, 0, 1000), 0, undefined);
        level thread LaunchSingleFirework(trace["position"], player.FireworksHeight + 150, player.FireworksDensity + 3, player);
    }

    wait 2.5;
    player.FireworksFinaleActive = false;
    player iPrintlnBold("^2Grand Finale Complete!");
}

ToggleFireworksGun(player)
{
    player endon("disconnect");
    player.FireworksGun = BoolVar(player.FireworksGun);

    if(Is_True(player.FireworksGun))
    {
        player notify("EndFireworksGun");
        player endon("EndFireworksGun");

        player iPrintlnBold("^2Fireworks Gun: ^7Enabled");

        while(Is_True(player.FireworksGun))
        {
            player waittill("weapon_fired");

            if(!IsAlive(player))
                continue;

            start = player GetWeaponMuzzlePoint();
            if(!IsDefined(start) || !IsVec(start))
                start = player GetEye();

            forward = AnglesToForward(player GetPlayerAngles());
            trace = BulletTrace(start, start + VectorScale(forward, 6000), 0, player);
            hitPos = trace["position"];

            level thread LaunchFireworkFromGun(start, hitPos, player.FireworksDensity, player);
            wait 0.05;
        }
    }
    else
    {
        player notify("EndFireworksGun");
        player iPrintlnBold("^1Fireworks Gun: ^7Disabled");
    }
}

LaunchFireworkFromGun(startPos, targetPos, density, player)
{
    weapon = GetWeapon("hunter_rocket_turret_player");
    if(!IsDefined(weapon) || weapon.name == "none")
        weapon = GetWeapon("launcher_standard");

    MagicBullet(weapon, startPos, targetPos, player);

    dist = Distance(startPos, targetPos);
    flightTime = dist / 2200;
    if(flightTime < 0.1) flightTime = 0.1;
    if(flightTime > 1.8) flightTime = 1.8;

    wait flightTime;

    Earthquake(0.35, 0.5, targetPos, 1200);
    PlayFX(level._effect["rcbombexplosion"], targetPos);

    if(IsDefined(level.menuFX) && level.menuFX.size > 0)
    {
        randomFx = level.menuFX[RandomInt(level.menuFX.size)];
        if(IsDefined(level._effect[randomFx]))
            PlayFX(level._effect[randomFx], targetPos);
    }

    flak = GetWeapon("flak_drone_rocket");
    if(!IsDefined(flak) || flak.name == "none")
        flak = weapon;

    for(i = 0; i < density; i++)
    {
        yaw = (i * (360 / density)) + RandomFloatRange(-15, 15);
        pitch = RandomFloatRange(10, 60);
        dir = (Cos(yaw) * Cos(pitch), Sin(yaw) * Cos(pitch), Sin(pitch));
        starTarget = targetPos + (dir * RandomFloatRange(250, 450));
        MagicBullet(flak, targetPos, starTarget, player);
    }
}

LaunchCrosshairFireworks(player)
{
    hitPos = player TraceBullet();
    if(!IsDefined(hitPos))
        return;

    player iPrintln("^2Launching Crosshair Fireworks!");

    for(i = 0; i < 3; i++)
    {
        offset = (RandomFloatRange(-100, 100), RandomFloatRange(-100, 100), 0);
        level thread LaunchSingleFirework(hitPos + offset, player.FireworksHeight, player.FireworksDensity, player);
        wait 0.25;
    }
}

LaunchLocationFireworks(player)
{
    newOrigin = self RunCustomLocationSelection();
    if(!IsDefined(newOrigin))
        return;

    player iPrintlnBold("^2Firing Fireworks at Selected Location!");

    for(i = 0; i < 5; i++)
    {
        offset = (RandomFloatRange(-150, 150), RandomFloatRange(-150, 150), 0);
        level thread LaunchSingleFirework(newOrigin + offset, player.FireworksHeight, player.FireworksDensity, player);
        wait 0.3;
    }
}

LaunchSingleFirework(launchOrigin, targetHeight, density, player)
{
    apexTarget = launchOrigin + (RandomFloatRange(-80, 80), RandomFloatRange(-80, 80), targetHeight);
    trace = BulletTrace(launchOrigin + (0, 0, 30), apexTarget, 0, undefined);
    if(trace["fraction"] < 1.0)
    {
        apexZ = launchOrigin[2] + ((targetHeight * trace["fraction"]) - 40);
        if(apexZ < launchOrigin[2] + 250)
            apexZ = launchOrigin[2] + 250;
        apex = (launchOrigin[0], launchOrigin[1], apexZ);
    }
    else
        apex = apexTarget;

    weapon = GetWeapon("hunter_rocket_turret_player");
    if(!IsDefined(weapon) || weapon.name == "none")
        weapon = GetWeapon("launcher_standard");

    launchPos = launchOrigin + (0, 0, 10);
    MagicBullet(weapon, launchPos, apex, player);

    dist = Distance(launchPos, apex);
    flightTime = dist / 1100;
    if(flightTime < 0.25) flightTime = 0.25;
    if(flightTime > 1.6) flightTime = 1.6;

    wait flightTime;

    Earthquake(0.35, 0.6, apex, 1500);
    PlayFX(level._effect["rcbombexplosion"], apex);

    if(IsDefined(level.menuFX) && level.menuFX.size > 0)
    {
        randomFx = level.menuFX[RandomInt(level.menuFX.size)];
        if(IsDefined(level._effect[randomFx]))
            PlayFX(level._effect[randomFx], apex);
    }

    flak = GetWeapon("flak_drone_rocket");
    if(!IsDefined(flak) || flak.name == "none")
        flak = weapon;

    for(i = 0; i < density; i++)
    {
        yaw = (i * (360 / density)) + RandomFloatRange(-15, 15);
        pitch = RandomFloatRange(10, 60);
        dir = (Cos(yaw) * Cos(pitch), Sin(yaw) * Cos(pitch), Sin(pitch));
        starTarget = apex + (dir * RandomFloatRange(250, 450));
        MagicBullet(flak, apex, starTarget, player);
    }
}

SetFireworksHeight(num, player)
{
    player.FireworksHeight = num;
}

SetFireworksDensity(num, player)
{
    player.FireworksDensity = num;
}

SetFireworksSpeed(val, player)
{
    player.FireworksSpeed = val;
}

/*
    Drivable Car 
*/

toggle_drivable_car( player = self, enabled )
{
    player endon( "disconnect" );
    
    player.drivable_car_enabled = !isDefined( player.drivable_car_enabled ) || !player.drivable_car_enabled;
    
    if( player.drivable_car_enabled )
    {
        if( isDefined( player.spawned_car ) )
            return;
            
        player thread spawn_and_manage_car();
    }
    else
    {
        player notify( "drivable_car_deactivated" );
        player cleanup_drivable_car();
    }
}

spawn_and_manage_car()
{
    self endon( "disconnect" );
    self endon( "drivable_car_deactivated" );
    
    forward = AnglesToForward( self.angles );
    spawn_origin = self.origin + ( forward * 120 );
    spawn_angles = ( 0, self.angles[1], 0 );
    
    car = Spawn( "script_model", spawn_origin );
    car SetModel( "defaultvehicle" ); 
    car.angles = spawn_angles;
    self.spawned_car = car;
    
    self.is_driving_car = true;
    self EnableInvulnerability();
    self.god_mode_car = true;
    
    self PlayerLinkToDelta( car, "tag_driver", 1.0, 180, 180, 180, 180, 1 );
    
    // Store HUD array on the player entity so it can be accessed globally
    self.hud_controls = self create_car_hud();
    
    move_speed = 0;
    max_speed = 25;
    acceleration = 1.2;
    deceleration = 0.8;
    turn_speed = 3.5;
    
    // Driving loop
    while( isDefined( car ) && self.drivable_car_enabled )
    {    
        movement = self GetNormalizedMovement();
        forward_input = movement[0];  // Forward/Back input
        strafe_input = movement[1];   // Left/Right input
        
        if( forward_input > 0.2 ) // Forward
        {
            move_speed = Min( move_speed + acceleration, max_speed );
        }
        else if( forward_input < -0.2 ) // Reverse
        {
            move_speed = Max( move_speed - acceleration, -12 );
        }
        else // Friction / Coasting
        {
            if( move_speed > 0 )
                move_speed = Max( 0, move_speed - deceleration );
            else if( move_speed < 0 )
                move_speed = Min( 0, move_speed + deceleration );
        }
        
        // Steering - only turn if car is moving
        if( Abs( move_speed ) > 0.5 )
        {
            steering_dir = ( move_speed < 0 ) ? -1 : 1; // Reverse steering correction
            
            if( strafe_input > 0.2 ) // Turn Right
            {
                car.angles = ( car.angles[0], car.angles[1] - ( turn_speed * steering_dir ), car.angles[2] );
            }
            else if( strafe_input < -0.2 ) // Turn Left
            {
                car.angles = ( car.angles[0], car.angles[1] + ( turn_speed * steering_dir ), car.angles[2] );
            }
        }
        
        // Apply velocity
        if( move_speed != 0 )
        {
            car_forward = AnglesToForward( car.angles );
            new_origin = car.origin + ( car_forward * move_speed );
            car MoveTo( new_origin, 0.05 );
        }
        
        // Re-enable godmode 
        self EnableInvulnerability();
        
        wait 0.05;
    }
}

create_car_hud()
{
    hud_elems = [];
    
    hud_title = NewClientHudElem( self );
    hud_title.x = 20;
    hud_title.y = 180;
    hud_title.alignX = "left";
    hud_title.alignY = "top";
    hud_title.fontScale = 1.4;
    hud_title.color = ( 0.2, 0.8, 1.0 );
    hud_title SetText( "^5=== CAR CONTROLS ===" );
    hud_elems[hud_elems.size] = hud_title;
    
    hud_move = NewClientHudElem( self );
    hud_move.x = 20;
    hud_move.y = 200;
    hud_move.alignX = "left";
    hud_move.alignY = "top";
    hud_move.fontScale = 1.1;
    hud_move SetText( "^7Drive / Reverse: ^3[{+forward}] / [{+back}]^7" );
    hud_elems[hud_elems.size] = hud_move;
    
    hud_steer = NewClientHudElem( self );
    hud_steer.x = 20;
    hud_steer.y = 215;
    hud_steer.alignX = "left";
    hud_steer.alignY = "top";
    hud_steer.fontScale = 1.1;
    hud_steer SetText( "^7Steer Left / Right: ^3[{+moveleft}] / [{+moveright}]^7" );
    hud_elems[hud_elems.size] = hud_steer;

    return hud_elems;
}

destroy_car_hud( hud_elems )
{
    if( isDefined( hud_elems ) )
    {
        foreach( elem in hud_elems )
        {
            if( isDefined( elem ) )
                elem Destroy();
        }
    }
}

cleanup_drivable_car()
{
    if( isDefined( self.hud_controls ) )
    {
        self destroy_car_hud( self.hud_controls );
        self.hud_controls = undefined;
    }

    if( isDefined( self.is_driving_car ) && self.is_driving_car )
    {
        self Unlink();
        
        if( isDefined( self.god_mode_car ) && self.god_mode_car )
        {
            self DisableInvulnerability();
            self.god_mode_car = undefined;
        }
        
        if( isDefined( self.spawned_car ) )
        {
            right_offset = AnglesToRight( self.spawned_car.angles ) * 80;
            self SetOrigin( self.spawned_car.origin + right_offset );
        }
        
        self.is_driving_car = undefined;
    }
    
    if( isDefined( self.spawned_car ) )
    {
        self.spawned_car Delete();
        self.spawned_car = undefined;
    }
    
    self.drivable_car_enabled = false;
}

SetPlayerActiveCamo(player = self)
{
    player endon("disconnect");
    player.ActiveCamoEnabled = isDefined(player.ActiveCamoEnabled) ? undefined : true;

    if(Is_True(player.ActiveCamoEnabled))
    {
        player clientfield::set("camo_shader", 1);
        player iPrintlnBold("^2Unlimited Active Camo: ^7Enabled");
    }
    else
    {
        player clientfield::set("camo_shader", 0);
        player iPrintlnBold("^1Unlimited Active Camo: ^7Disabled");
    }
}