PopulateBulletMenu(menu, player)
{
    switch(menu)
    {
        case "Bullet Menu":
            self addMenu("Bullet Menu");
                self addOpt("Projectiles", ::newMenu, "Weapon Projectiles");
                self addOpt("Effects", ::newMenu, "Bullet Effects");
                self addOpt("Spawnables", ::newMenu, "Bullet Spawnables");
                self addOpt("Explosive Bullets", ::newMenu, "Explosive Bullets");
                self addOpt("Reset", ::ResetBullet, player);
            break;
        
        case "Weapon Projectiles":
            if(!IsDefined(player.ProjectileMultiplier))
                player.ProjectileMultiplier = 1;
            
            if(!IsDefined(player.ProjectileSpreadMultiplier))
                player.ProjectileSpreadMultiplier = 5;
            
            self addMenu("Projectiles");
                self addOpt("Weapon Projectile", ::newMenu, "Weapon Projectile");
                self addOptIncSlider("Projectile Multiplier", ::ProjectileMultiplier, 1, 1, 5, 1, player);
                self addOptIncSlider("Spread Multiplier", ::ProjectileSpreadMultiplier, 1, 5, 50, 1, player);
            break;
        
        case "Weapon Projectile":
            weaponsVar = Array("weapon_assault", "weapon_smg", "weapon_lmg", "weapon_sniper", "weapon_cqb", "weapon_pistol", "weapon_launcher", "weapon_knife", "hero", "weapon_special");
            specials = Array("hunter_rocket_turret_player", "flak_drone_rocket", "helicopter_gunner_turret_rockets", "remote_missile_missile", "remote_missile_bomblet");
            specialsName = Array("Hunter Rocket", "Flak Drone Rocket", "Helicopter Gunner Rockets", "Remote Missile", "Remote Missile Bomblet");

            self addMenu("Weapon Projectile");

                for(a = 0; a < specials.size; a++)
                    self addOpt(specialsName[a], ::BulletProjectile, GetWeapon(specials[a]), "Projectile", player);

                foreach(index, var in weaponsVar)
                {
                    for(a = 0; a < 148; a++)
                    {
                        if(StatsTableType(a) != var || var == "weapon_knife")
                            continue;
                        
                        raw = GetWeapon(StatsTableRaw(a));
                        localized = StatsTableLocalized(a);

                        if(raw.name == "none" || IsSubStr(raw.name, "_dw") || IsSubStr(raw.name, "_null") || var == "hero" && (raw.name == "hero_gravityspikes" || raw.name == "hero_armblade"))
                            continue;
                        
                        self addOpt(localized, ::BulletProjectile, raw, "Projectile", player);
                    }
                }
            break;
        
        case "Bullet Effects":
            self addMenu("Effects");

                for(a = 0; a < level.menuFX.size; a++)
                    self addOpt(CleanString(level.menuFX[a]), ::BulletProjectile, level.menuFX[a], "Effect", player);
            break;
        
        case "Bullet Spawnables":
            self addMenu("Spawnables");

                if(IsDefined(level.menu_models) && level.menu_models.size)
                {
                    for(a = 0; a < level.menu_models.size; a++)
                        self addOpt(CleanString(level.menu_models[a]), ::BulletProjectile, level.menu_models[a], "Spawnable", player);
                }
            break;
        
        case "Explosive Bullets":
            if(!IsDefined(player.ExplosiveBulletsRange))
                player.ExplosiveBulletsRange = 250;
            
            if(!IsDefined(player.ExplosiveBulletsDamage))
                player.ExplosiveBulletsDamage = 100;
            
            self addMenu("Explosive Bullets");
                self addOptBool(player.ExplosiveBullets, "Explosive Bullets", ::ExplosiveBullets, player);
                self addOptBool(player.ExplosiveBulletEffect, "Explosive Bullets Effect", ::ExplosiveBulletEffect, player);
                self addOptIncSlider("Explosive Bullet Range", ::ExplosiveBulletRange, 25, 250, 500, 25, player);
                self addOptIncSlider("Explosive Bullet Damage", ::ExplosiveBulletDamage, 25, 100, 500, 25, player);
            break;
    }
}

BulletProjectile(projectile, type, player)
{
    player notify("endProjectile");
    player endon("endProjectile");
    player endon("disconnect");

    if(!IsDefined(player.ProjectileSpreadMultiplier))
        player.ProjectileSpreadMultiplier = 1;
    
    while(1)
    {
        player waittill("weapon_fired");

        start = player GetWeaponMuzzlePoint();

        if(!IsDefined(start) || !IsVec(start))
            start = player GetEye();
        
        switch(type)
        {
            case "Projectile":
                for(a = 0; a < player.ProjectileMultiplier; a++)
                    MagicBullet(projectile, start, BulletTrace(start, start + vectorScale(AnglesToForward(player GetPlayerAngles()), 100), 0, undefined)["position"] + (RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier), RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier), RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier)), player);
                break;
            
            case "Equipment":
                for(a = 0; a < player.ProjectileMultiplier; a++)
                    player MagicGrenadeType(projectile, start, VectorScale(VectorNormalize(AnglesToForward(player GetPlayerAngles())), 5000) + (RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier), RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier), RandomFloatRange((-1 * player.ProjectileSpreadMultiplier), player.ProjectileSpreadMultiplier)), 1);
                break;
            
            case "Spawnable":
                bspawn = SpawnScriptModel(player TraceBullet(), projectile);

                if(IsDefined(bspawn))
                {
                    bspawn NotSolid();
                    bspawn thread deleteAfter(5);
                }
                break;
            
            case "Effect":
                PlayFX(level._effect[projectile], player TraceBullet());
                break;
            
            default:
                break;
        }
    }
}

ProjectileMultiplier(multiplier, player)
{
    player.ProjectileMultiplier = multiplier;
}

ProjectileSpreadMultiplier(multiplier, player)
{
    player.ProjectileSpreadMultiplier = multiplier;
}

ExplosiveBullets(player)
{
    player.ExplosiveBullets = BoolVar(player.ExplosiveBullets);

    if(Is_True(player.ExplosiveBullets))
    {
        player endon("disconnect");
        player endon("EndExplosiveBullets");

        while(Is_True(player.ExplosiveBullets))
        {
            player waittill("weapon_fired");
            
            RadiusDamage(player TraceBullet(), player.ExplosiveBulletsRange, player.ExplosiveBulletsDamage, player.ExplosiveBulletsDamage, player);

            if(Is_True(player.ExplosiveBulletEffect))
                PlayFX(level._effect["rcbombexplosion"], player TraceBullet());
        }
    }
    else
    {
        player notify("EndExplosiveBullets");
        player.ExplosiveBullets = false;
    }
}

ExplosiveBulletDamage(num, player)
{
    player.ExplosiveBulletsDamage = num;
}

ExplosiveBulletRange(num, player)
{
    player.ExplosiveBulletsRange = num;
}

ExplosiveBulletEffect(player)
{
    player.ExplosiveBulletEffect = !Is_True(player.ExplosiveBulletEffect);
}

ResetBullet(player)
{
    player notify("endProjectile");
    player.ExplosiveBullets = false;
    player notify("EndExplosiveBullets");
}