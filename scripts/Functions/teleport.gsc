PopulateTeleportMenu(menu, player)
{
    switch(menu)
    {
        case "Teleport Menu":
            self addMenu("Teleport Menu");

                if(IsDefined(level.spawnpoints) && level.spawnpoints.size)
                    self addOptIncSlider("Official Spawn Points", ::OfficialSpawnPoint, 0, 0, (level.spawnpoints.size - 1), 1, player);
                
                self addOptSlider("Teleport", ::TeleportPlayer, Array("Custom", "Crosshairs", "Sky"), player);
                self addOptBool(player.TeleportGun, "Teleport Gun", ::TeleportGun, player);
                self addOptBool(player.SaveAndLoad, "Save & Load Position", ::SaveAndLoad, player);
                self addOpt("Save Current Location", ::SaveCurrentLocation, player);
                self addOpt("Load Saved Location", ::LoadSavedLocation, player);

                if(player != self)
                {
                    self addOpt("Teleport To Self", ::TeleportPlayer, self, player);
                    self addOpt("Teleport To Player", ::TeleportPlayer, player, self);
                }
            break;
    }
}

TeleportPlayer(origin, player, angles)
{
    if(!IsDefined(origin))
        return;

    if(IsPlayer(origin))
        newOrigin = origin.origin;
    
    if(IsString(origin))
    {
        switch(origin)
        {
            case "Custom":
                newOrigin = self RunCustomLocationSelection();
                
                if(!IsDefined(newOrigin))
                    return;
                break;
            
            case "Crosshairs":
                newOrigin = self TraceBullet();
                break;
            
            case "Sky":
                newOrigin = player.origin + (0, 0, 35000);
                break;
            
            default:
                newOrigin = self TraceBullet();
                break;
        }
    }
    
    if(!IsDefined(newOrigin))
        newOrigin = origin;
    
    player SetOrigin(newOrigin);

    if(IsDefined(angles))
        player SetPlayerAngles(angles);
}

OfficialSpawnPoint(point, player)
{
    player SetOrigin(level.spawnpoints[point].origin);
    player SetPlayerAngles(level.spawnpoints[point].angles);
}

TeleportGun(player)
{
    player endon("disconnect");
    player endon("EndTeleportGun");
    
    player.TeleportGun = BoolVar(player.TeleportGun);

    if(Is_True(player.TeleportGun))
    {
        while(Is_True(player.TeleportGun))
        {
            player waittill("weapon_fired");
            player SetOrigin(player TraceBullet());
        }
    }
    else
    {
        player notify("EndTeleportGun");
    }
}

SaveAndLoad(player)
{
    player endon("disconnect");

    player.SaveAndLoad = BoolVar(player.SaveAndLoad);

    if(Is_True(player.SaveAndLoad))
    {
        player iPrintln("Press [{+actionslot 3}] To ^2Save Current Location");
        player iPrintln("Press [{+actionslot 2}] To ^2Load Saved Location");

        while(Is_True(player.SaveAndLoad))
        {
            if(!player isInMenu(true))
            {
                if(player ActionslotThreeButtonPressed())
                {
                    player SaveCurrentLocation(player);
                    wait 0.05;
                }

                if(player ActionslotTwoButtonPressed() && IsDefined(player.SavedOrigin))
                {
                    player LoadSavedLocation(player);
                    wait 0.05;
                }
            }

            wait 0.05;
        }
    }
}

SaveCurrentLocation(player)
{
    player.SavedOrigin = player.origin;
    player.SavedAngles = player.angles;
}

LoadSavedLocation(player)
{
    if(!IsDefined(player.SavedOrigin))
    {
        if(player != self)
            self iPrintlnBold("^1ERROR: ^7Player Doesn't Have A Location Saved");
        else
            self iPrintlnBold("^1ERROR: ^7You Have To Save A Location Before Using This Option");
        
        return;
    }
    
    player SetOrigin(player.SavedOrigin);
    player SetPlayerAngles(player.SavedAngles);
}