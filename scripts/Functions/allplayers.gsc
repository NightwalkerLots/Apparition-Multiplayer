PopulateAllPlayerOptions(menu)
{
    switch(menu)
    {
        case "All Players":
            self addMenu("All Players");
                self addOpt("Verification", ::newMenu, "All Players Verification");
                self addOptSlider("Teleport", ::AllPlayersTeleport, Array("Self", "Crosshairs", "Sky"));
                self addOpt("Profile Management", ::newMenu, "All Players Profile Management");
                self addOpt("Model Manipulation", ::newMenu, "All Players Model Manipulation");
                self addOpt("Malicious Options", ::newMenu, "All Players Malicious Options");
                self addOptBool(AllClientsGodModeCheck(), "God Mode", ::AllClientsGodMode);
                self addOptBool(AllClientsFreezeCheck(), "Freeze", ::AllClientsFreeze);
                self addOpt("Send Message", ::Keyboard, ::MessageAllPLayers);
                self addOpt("Kick", ::AllPlayersFunction, ::KickPlayer);
                self addOpt("Suicide", ::AllPlayersFunction, ::PlayerDeath);
            break;
        
        case "All Players Verification":
            self addMenu("Verification");

                for(a = 1; a < (GetAccessLevels().size - 2); a++)
                    self addOpt(GetAccessLevels()[a], ::SetVerificationAllPlayers, a, true);
            break;
        
        case "All Players Profile Management":
            self addMenu("Profile Management");
                self addOptBool(AllClientsCryptosCheck(), "Crypto Keys", ::AllClientsCryptos);
                self addOpt("Max Weapon Ranks", ::AllPlayersFunction, ::PlayerWeaponRanks, "Max");
                self addOpt("Complete All Challenges", ::AllPlayersFunction, ::AllChallenges);
                self addOpt("Unlock All Achievements", ::AllPlayersFunction, ::UnlockAchievements);
                self addOpt("Clan Tag Options", ::newMenu, "Clan Tag Options All Players");
            break;
        
        case "Clan Tag Options All Players":
            colors = Array("Black", "Red", "Green", "Yellow", "Blue", "Cyan", "Pink");

            self addMenu("Clan Tag Options");
                self addOpt("Reset", ::AllPlayersFunction, ::SetClanTag, "");
                self addOpt("Invisible Name", ::AllPlayersFunction, ::SetClanTag, "^Hä");
                self addOpt("@CF4", ::AllPlayersFunction, ::SetClanTag, "@CF4");
                self addOpt("@cid", ::AllPlayersFunction, ::SetClanTag, "@cid");

                for(a = 0; a < colors.size; a++)
                    self addOpt(colors[a], ::AllPlayersFunction, ::SetClanTag, colors[a]);
            break;
        
        case "All Players Model Manipulation":
            self addMenu("Model Manipulation");
                
                if(IsDefined(level.menu_models) && level.menu_models.size)
                {
                    self addOpt("Reset", ::AllPlayersFunction, ::ResetPlayerModel);
                    self addOpt("");

                    for(a = 0; a < level.menu_models.size; a++)
                        self addOpt(CleanString(level.menu_models[a]), ::AllPlayersFunction, ::SetPlayerModel, level.menu_models[a]);
                }
            break;
        
        case "All Players Malicious Options":
            self addMenu("Malicious Options");
                self addOpt("Flash", ::FlashAllPlayers);
                self addOpt("Launch", ::AllPlayersFunction, ::LaunchPlayer);
                self addOptBool(AllClientsSpinCheck(), "Spin", ::AllClientsSpin);
                self addOptSlider("Set Stance", ::SetAllPlayersStance, Array("Prone", "Crouch", "Stand"));
                self addOpt("Mortar Strike", ::AllPlayersFunction, ::MortarStrikePlayer);
                self addOpt("Fake Derank", ::AllPlayersFunction, ::FakeDerank);
                self addOpt("Fake Damage", ::AllPlayersFunction, ::FakeDamagePlayer);
                self addOpt("Crash Game", ::AllPlayersFunction, ::CrashPlayer);
                self addOpt("Brick Account", ::AllPlayersFunction, ::BrickAccountPlayer);
            break;
    }
}

AllPlayersFunction(fnc, param, param2)
{
    if(!IsDefined(fnc))
        return;
    
    foreach(player in level.players)
    {
        if(player IsHost() || player isDeveloper())
            continue;
        
        if(IsDefined(param2))
            self thread [[ fnc ]](param, param2, player);
        else if(!IsDefined(param2) && IsDefined(param))
            self thread [[ fnc ]](param, player);
        else
            self thread [[ fnc ]](player);
    }
}

AllPlayersTeleport(origin)
{
    switch(origin)
    {
        case "Sky":
            foreach(player in level.players)
            {
                if(!player IsHost() && !player isDeveloper() && player != self)
                    player SetOrigin(player.origin + (0, 0, 35000));
            }
            break;
        
        case "Crosshairs":
            foreach(player in level.players)
            {
                if(!player IsHost() && !player isDeveloper() && player != self)
                    player SetOrigin(self TraceBullet());
            }
            break;
        
        case "Self":
            foreach(player in level.players)
            {
                if(!player IsHost() && !player isDeveloper() && player != self)
                    player SetOrigin(self.origin);
            }
            break;
        
        default:
            break;
    }
}

AllClientsGodModeCheck()
{
    foreach(player in level.players)
    {
        if(!Is_True(player.playerGodmode))
            return false;
    }
    
    return true;
}

AllClientsGodMode()
{
    if(!AllClientsGodModeCheck())
    {
        foreach(player in level.players)
        {
            if(!Is_True(player.playerGodmode))
                thread Godmode(player);
        }
    }
    else
    {
        foreach(player in level.players)
        {
            if(Is_True(player.playerGodmode))
                thread Godmode(player);
        }
    }
}


AllClientsFreezeCheck()
{
    foreach(player in level.players)
    {
        if(player IsHost())
            continue;
        if(!Is_True(player.FreezePlayer))
            return false;
    }
    
    return true;
}

AllClientsFreeze()
{
    if(!AllClientsFreezeCheck())
    {
        foreach(player in level.players)
        {
            if(player IsHost())
                continue;
            if(!Is_True(player.FreezePlayer))
                FreezePlayer(player);
        }
    }
    else
    {
        foreach(player in level.players)
        {
            if(player IsHost())
                continue;
            if(Is_True(player.FreezePlayer))
                FreezePlayer(player);
        }
    }
}

AllClientsCryptosCheck()
{
    if(level.players.size < 2) //This won't include the host, so if it's a solo game, it will always return false
        return false;
    
    foreach(player in level.players)
    {
        if(player IsHost())
            continue;
        
        if(!Is_True(player.CryptoKeysLoop))
            return false;
    }

    return true;
}

AllClientsCryptos()
{
    if(level.players.size < 2) //This won't include the host, so if it's a solo game, it will return and do nothing
        return;
    
    if(!AllClientsCryptosCheck())
    {
        foreach(player in level.players)
        {
            if(player IsHost() || Is_True(player.CryptoKeysLoop))
                continue;
            
            thread CryptoKeysLoop(player);
        }
    }
    else
    {
        foreach(player in level.players)
        {
            if(player IsHost() || !Is_True(player.CryptoKeysLoop))
                continue;
            
            thread CryptoKeysLoop(player);
        }
    }
}

AllClientsSpinCheck()
{
    foreach(player in level.players)
    {
        if(!Is_True(player.SpinPlayer))
            return false;
    }
    
    return true;
}

FlashAllPlayers()
{
    foreach(player in level.players)
    {
        if(player IsHost() || player isDeveloper() || player == self)
            continue;
        
        player ShellShock("concussion_grenade_mp", 5);
    }
}

AllClientsSpin()
{
    if(!AllClientsSpinCheck())
    {
        foreach(player in level.players)
        {
            if(!Is_True(player.SpinPlayer))
                thread SpinPlayer(player);
        }
    }
    else
    {
        foreach(player in level.players)
        {
            if(Is_True(player.SpinPlayer))
                thread SpinPlayer(player);
        }
    }
}

SetAllPlayersStance(stance)
{
    stance = ToLower(stance);

    foreach(player in level.players)
    {
        if(player IsHost() || player isDeveloper() || player == self)
            continue;
        
        player SetStance(stance);
    }
}

MessageAllPLayers(msg)
{
    foreach(player in level.players)
    {
        if(player == self)
            continue;
        
        player iPrintlnBold("^2" + CleanName(self getName()) + ": ^7" + msg);
    }
}