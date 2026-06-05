PopulateBotMenu(menu)
{
    switch(menu)
    {
        case "Bot Menu":
            if(!IsDefined(level.BotTeamSelection))
                level.BotTeamSelection = "autoassign";
            
            self addMenu("Bot Menu");
                self addOpt("Bot Options", ::newMenu, "Bot Options");
                
                if(Is_True(level.teamBased))
                    self addOptSlider("Bot Team", ::BotTeamSelection, Array("Auto", "Friendly", "Enemy"));
                
                self addOptIncSlider("Spawn", ::SpawnBot, 1, 1, 17, 1);
            break;
        
        case "Bot Options":
            self addMenu("Bot Options");
                self addOpt("Kill", ::KillAllBots);
                self addOpt("Kick", ::KickAllBots);
                self addOptSlider("Teleport Bots To", ::TeleportBots, Array("Self", "Saved Location", "Crosshairs"));
                self addOptBool(level.TeleportBotsToCrosshairsLoop, "Teleport To Crosshairs", ::TeleportBotsToCrosshairsLoop);
                self addOptBool(IsDefined(level.BotSpawnLocation), "Set Spawn Location", ::SetBotSpawnLocation);
                self addOpt("Take All Weapons", ::BotsTakeAllWeapons);
                
                if(Is_True(level.teamBased))
                    self addOptSlider("Change Teams", ::BotsChangeTeams, Array("Axis", "Allies"));
            break;
    }
}

SpawnBot(amount)
{
    failed = 0;

    for(a = 0; a < amount; a++)
    {
        bot = bot::add_bot(level.BotTeamSelection);

        if(!IsDefined(bot))
            failed++;
    }

    if(failed)
    {
        if(failed > 1)
            self iPrintln("^1ERROR: ^7Failed To Spawn " + failed + " Bots");
        else
            self iPrintln("^1ERROR: ^7Failed To Spawn Bot");
    }
}

KillAllBots()
{
    foreach(player in GetPlayerArray())
    {
        if(player util::is_bot())
            player Suicide();
    }
}

KickAllBots()
{
    foreach(player in GetPlayerArray())
    {
        if(player util::is_bot())
            Kick(player GetEntityNumber(), "EXE_PLAYERKICKED_NOTSPAWNED");
    }
}

TeleportBots(Location)
{
    switch(location)
    {
        case "Self":
            foreach(player in GetPlayerArray())
            {
                if(player util::is_bot())
                    player SetOrigin(self.origin);
            }
            break;
        
        case "Saved Location":
            player = self;
            
            if(!IsDefined(player.SavedOrigin))
                return player iPrintlnBold("^1ERROR: ^7You Need To Save A Location Before Using This Option");
            
            foreach(client in GetPlayerArray())
            {
                if(player util::is_bot())
                    client SetOrigin(player.SavedOrigin);
            }
            break;
        
        case "Crosshairs":
            foreach(player in GetPlayerArray())
            {
                if(player util::is_bot())
                    player SetOrigin(self TraceBullet());
            }
            break;
        
        default:
            break;
    }
}

TeleportBotsToCrosshairsLoop()
{
    level.TeleportBotsToCrosshairsLoop = BoolVar(level.TeleportBotsToCrosshairsLoop);

    if(Is_True(level.TeleportBotsToCrosshairsLoop))
    {
        origin = self TraceBullet();
        
        while(Is_True(level.TeleportBotsToCrosshairsLoop))
        {
            foreach(player in GetPlayerArray())
            {
                if(player util::is_bot() && IsAlive(player))
                    player SetOrigin(origin);
            }
            
            wait 0.5;
        }
    }
}

SetBotSpawnLocation()
{
    level.BotSpawnLocation = IsDefined(level.BotSpawnLocation) ? undefined : self TraceBullet();
    
    if(IsDefined(level.BotSpawnLocation))
    {
        foreach(player in GetPlayerArray())
        {
            if(player util::is_bot())
                player SetOrigin(level.BotSpawnLocation);
        }
    }
}

BotsTakeAllWeapons()
{
    foreach(player in GetPlayerArray())
    {
        if(player util::is_bot() && IsAlive(player))
            player TakePlayerWeapons(player);
    }
}

BotsChangeTeams(team)
{
    foreach(player in GetPlayerArray())
    {
        if(player util::is_bot() && (player.pers["team"] != team || !IsDefined(player.pers["team"])))
            player ChangeTeamsPlayer(team, player);
    }
}
    
BotTeamSelection(team)
{
    switch(team)
    {
        case "Auto":
            level.BotTeamSelection = "autoassign";
            break;
        
        case "Friendly":
            level.BotTeamSelection = self.pers["team"];
            break;
        
        case "Enemy":
            level.BotTeamSelection = self GetEnemyTeam();
            break;
        
        default:
            break;
    }
}