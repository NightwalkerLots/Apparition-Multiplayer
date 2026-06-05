PopulateFunScripts(menu, player)
{
    switch(menu)
    {
        case "Fun Scripts":
            self addMenu("Fun Scripts");
                self addOpt("Effect Man Options", ::newMenu, "Effect Man Options");
                self addOpt("Force Field Options", ::newMenu, "Force Field Options");
                self addOptSlider("Human Fountain", ::HumanFountain, Array("Disable", "Gore", "Water", "Smoke"), player);
                self addOpt("Mortar Strike", ::MortarStrike, player);
                self addOpt("Adventure Time", ::AdventureTime, player);
                self addOpt("Earthquake", ::SendEarthquake, player);
                self addOptBool(player.Jetpack, "Jetpack", ::Jetpack, player);
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
                self addOptBool(player.RapidFire, "Rapid Fire", ::RapidFire, player);
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