PopulateAimbotMenu(menu, player)
{
    switch(menu)
    {
        case "Aimbot Menu":
            if(!IsDefined(player.AimbotType))
                player.AimbotType = "Snap";
            
            if(!IsDefined(player.AimBoneTag))
                player.AimBoneTag = "j_head";
            
            if(!IsDefined(player.AimbotKey))
                player.AimbotKey = "None";
            
            if(!IsDefined(player.AimbotVisibilityRequirement))
                player.AimbotVisibilityRequirement = "None";
            
            if(!IsDefined(player.AimbotDistance))
                player.AimbotDistance = 100;
            
            if(!IsDefined(player.SmoothSnaps))
                player.SmoothSnaps = 5;
            
            if(!IsDefined(player.AimbotIgnore))
                player.AimbotIgnore = [];
            
            self addMenu("Aimbot Menu");
                self addOptBool(player.Aimbot, "Aimbot", ::Aimbot, player);
                self addOpt("Ignore", ::newMenu, "Aimbot Ignore Players");
                self addOptSlider("Type", ::AimbotType, Array("Snap", "Smooth Snap", "Silent"), player);
                self addOptSlider("Tag", ::AimBoneTag, Array("j_head", "j_neck", "j_spineupper", "j_spinelower", "j_mainroot", "j_shoulder_le", "j_shoulder_ri", "j_elbow_le", "j_elbow_ri", "j_wrist_le", "j_wrist_ri", "j_hip_le", "j_mainroot", "j_hip_ri", "j_knee_le", "j_knee_ri", "j_ankle_le", "j_ankle_ri", "j_ball_le", "j_ball_ri"), player);
                self addOptSlider("Key", ::AimbotKey, Array("None", "Aiming", "Firing"), player);
                self addOptSlider("Requirement", ::AimbotVisibilityRequirement, Array("None", "Visible", "Damageable"), player);
                self addOptIncSlider("Smooth Snaps", ::SetSmoothSnaps, 5, 5, 15, 1, player);
                self addOptBool(player.AimbotSnipersOnly, "Snipers Only", ::AimbotOptions, 1, player);
                self addOptBool(player.AimbotMidAirOnly, "Mid-Air Only", ::AimbotOptions, 2, player);
                self addOptBool(player.AutoFire, "Auto-Fire", ::AimbotOptions, 3, player);
                self addOptBool(player.AimbotDistanceCheck, "Distance Check", ::AimbotOptions, 4, player);

                if(Is_True(player.AimbotDistanceCheck))
                    self addOptIncSlider("Distance", ::AimbotDistance, 100, 100, 5000, 100, player);
            break;
        
        case "Aimbot Ignore Players":
            clients = 0;
            
            self addMenu("Ignore");
                
                foreach(client in GetPlayerArray())
                {
                    if(client != player && (level.teamBased && client.team != player.team || !level.teamBased) && !client IsHost() && !client isDeveloper())
                    {
                        self addOptBool(isInArray(player.AimbotIgnore, client), CleanName(client getName()), ::AimbotIgnore, player, client);
                        clients++;
                    }
                }
                
                if(!clients)
                    self addOpt("No Enemy Players Found");
            break;
    }
}

Aimbot(player)
{
    player.Aimbot = BoolVar(player.Aimbot);

    if(Is_True(player.Aimbot))
    {
        player endon("disconnect");
        
        while(Is_True(player.Aimbot))
        {
            enemy = player GetClosestTarget();
            
            if(Is_True(player.Noclip) || Is_True(player.UFOMode) || Is_True(player.AC130))
                enemy = undefined;
            
            if(IsDefined(enemy) && (!IsAlive(enemy) || Is_True(player.AimbotSnipersOnly) && util::getweaponclass(player GetCurrentWeapon()) != "weapon_sniper" || IsDefined(player.AimbotMidAirOnly) && player IsOnGround() || Is_True(player.AimbotDistanceCheck) && Distance(player.origin, enemy.origin) > player.AimbotDistance))
                enemy = undefined;
            
            if(IsDefined(enemy) && (player.AimbotKey == "Aiming" && !player PlayerADS() || player.AimbotKey == "Firing" && !player isFiring1()))
                enemy = undefined;
            
            if(IsDefined(enemy))
            {
                origin = enemy GetTagOrigin(player.AimBoneTag);
                
                if(IsDefined(origin))
                {
                    if(player.AimbotType == "Snap")
                    {
                        player SetPlayerAngles(VectorToAngles(origin - player GetEye()));
                    
                        if(Is_True(player.AutoFire))
                            player FireGun();
                    }
                    else if(player.AimbotType == "Smooth Snap")
                    {
                        if(!IsDefined(player.smoothTarget) || player.smoothTarget != enemy)
                        {
                            player.smoothTarget = enemy;
                            player.snapsRemaining = player.SmoothSnaps;
                            player.snapAngles = VectorToAngles(origin - player GetEye());
                        }

                        if(player.snapsRemaining)
                        {
                            viewAngles = player GetPlayerAngles();
                            
                            smoothangles = (AngleNormalize180(player.snapAngles[0] - viewAngles[0]), AngleNormalize180(player.snapAngles[1] - viewAngles[1]), 0);
                            smoothangles /= player.snapsRemaining;
                            
                            player SetPlayerAngles((AngleNormalize180(viewAngles[0] + smoothangles[0]), AngleNormalize180(viewAngles[1] + smoothangles[1]), 0));
                            player.snapsRemaining--;
                        }
                        else
                            player SetPlayerAngles(VectorToAngles(origin - player GetEye())); //After it has finished the smooth snap to the target, it will stay locked on
                        
                        if(Is_True(player.AutoFire) && player.snapsRemaining <= 1)
                            player FireGun();
                    }
                    
                    if(player.AimbotType == "Silent" || player.AimbotVisibilityRequirement == "None")
                    {
                        if(Is_True(player.AutoFire) || player isFiring1())
                            player FireGun(origin + (5, 0, 0), origin, false);
                    }
                }
                else
                {
                    if(IsDefined(player.smoothTarget))
                    {
                        player.smoothTarget = undefined;
                        player.snapsRemaining = undefined;
                        player.snapAngles = undefined;
                    }
                }
            }
            else
            {
                if(IsDefined(player.smoothTarget))
                {
                    player.smoothTarget = undefined;
                    player.snapsRemaining = undefined;
                    player.snapAngles = undefined;
                }
            }
            
            wait 0.01;
        }
    }
    else
    {
        if(IsDefined(player.smoothTarget))
        {
            player.smoothTarget = undefined;
            player.snapsRemaining = undefined;
            player.snapAngles = undefined;
        }
    }
}

GetClosestTarget()
{
    player = self;
    
    foreach(client in GetPlayerArray())
    {
        if(!IsDefined(client) || !IsAlive(client) || client == player || level.teamBased && client.pers["team"] == player.pers["team"] || client IsHost() || client isDeveloper() || IsGodMode(client) || IsDefined(player.AimbotIgnore) && isInArray(player.AimbotIgnore, client) || player.AimbotVisibilityRequirement == "Damageable" && !player IsDamageable(client, client GetTagOrigin(player.AimBoneTag)) || player.AimbotVisibilityRequirement == "Visible" && !player IsVisible(client GetTagOrigin(player.AimBoneTag), client))
            continue;
        
        if(!IsDefined(enemy))
            enemy = client;
        
        if(IsDefined(enemy) && enemy != client)
        {
            if(!Closer(player.origin, client.origin, enemy.origin))
                continue;
            
            enemy = client;
        }
    }
    
    return enemy;
}

AimbotType(type, player)
{
    player.AimbotType = type;
}

AimBoneTag(tag, player)
{
    player.AimBoneTag = tag;
}

AimbotKey(key, player)
{
    player.AimbotKey = key;
}

AimbotVisibilityRequirement(requirement, player)
{
    player.AimbotVisibilityRequirement = requirement;
}

SetSmoothSnaps(snaps, player)
{
    player.SmoothSnaps = snaps;
}

AimbotDistance(distance, player)
{
    player.AimbotDistance = distance;
}

AimbotIgnore(player, client)
{
    if(IsDefined(player.AimbotIgnore) && isInArray(player.AimbotIgnore, client))
        player.AimbotIgnore = ArrayRemove(player.AimbotIgnore, client);
    else
        player.AimbotIgnore[player.AimbotIgnore.size] = client;
}

AimbotOptions(a, player)
{
    switch(a)
    {
        case 1:
            player.AimbotSnipersOnly = BoolVar(player.AimbotSnipersOnly);
            break;
        
        case 2:
            player.AimbotMidAirOnly = BoolVar(player.AimbotMidAirOnly);
            break;
        
        case 3:
            player.AutoFire = BoolVar(player.AutoFire);
            break;
        
        case 4:
            player.AimbotDistanceCheck = BoolVar(player.AimbotDistanceCheck);
            break;
        
        default:
            break;
    }
}

FireGun(startPosition, targetPosition, takeAmmo = false)
{
    self endon("disconnect");

    weapon = self GetCurrentWeapon();

    if(!IsDefined(weapon) || weapon.name == "none")
        return;
    
    if(!self GetWeaponAmmoClip(weapon) || self IsReloading() || self isOnLadder() || self IsMantling() || self IsSwitchingWeapons() || self IsMeleeing() || self IsSprinting())
        return;
    
    MagicBullet(weapon, IsDefined(startPosition) ? startPosition : self GetWeaponMuzzlePoint(), IsDefined(targetPosition) ? targetPosition : self TraceBullet(), self);
    
    if(takeAmmo)
        self SetWeaponAmmoClip(weapon, (self GetWeaponAmmoClip(weapon) - 1));
    
    self WeaponPlayEjectBrass();
    time = weapon.fireTime;

    if(!IsDefined(time) || time <= 0)
        time = 0.1;

    wait (time / 2);
}