PopulateServerModifications(menu)
{
    switch(menu)
    {
        case "Server Modifications":
            self addMenu("Server Modifications");
                self addOptBool(level.SuperJump, "Super Jump", ::SuperJump);
                self addOptBool((GetDvarInt("bg_gravity") == 200), "Low Gravity", ::LowGravity);
                self addOptBool((GetDvarString("g_speed") == "500"), "Super Speed", ::SuperSpeed);
                self addOptIncSlider("Timescale", ::ServerSetTimeScale, 0.5, GetDvarInt("timescale"), 5, 0.5);
                self addOptBool(level.AntiQuit, "Anti-Quit", ::AntiQuit);
                self addOpt("Anti-Camp Options", ::newMenu, "Anti-Camp Options");
                self addOptBool(level.HearAllPlayers, "Hear All Players", ::HearAllPlayers);
                self addOpt("Auto-Verification", ::newMenu, "Auto-Verification");
                self addOpt("Doheart Options", ::newMenu, "Doheart Options");
                self addOptBool(level.Newsbar, "Newsbar", ::Newsbar);
                self addOptBool(level.ServerPauseWorld, "Pause World", ::ServerPauseWorld);
                self addOptBool(level.CustomAdvertise, "Custom Advertisement", ::CustomAdvertise);
                self addOpt("Edit Lobby Timer", ::newMenu, "Edit Lobby Timer");
                self addOpt("Edit Score Limit", ::newMenu, "Edit Score Limit");
                self addOpt("Change Map", ::newMenu, "Change Map");
                self addOpt("Restart Game", ::ServerRestart);
            break;
        
        case "Anti-Camp Options":
            if(!IsDefined(level.AntiCampAction))
                level.AntiCampAction = "Kill";
            
            if(!IsDefined(level.MaxCampTime))
                level.MaxCampTime = 1000;
            
            self addMenu("Anti-Camp Options");
                self addOptBool(level.AntiCamp, "Anti-Camp", ::AntiCamp);
                self addOptIncSlider("Max Camp Time", ::AntiCampMaxTime, 1, 1, 30, 1);
                self addOptSlider("Anti-Camp Action", ::SetAntiCampAction, Array("Kill", "Warn", "Kick"));
            break;
        
        case "Auto-Verification":
            self addMenu("Auto-Verification");
                
                for(a = 1; a < (GetAccessLevels().size - 2); a++)
                    self addOptBool(level.AutoVerify == a, GetAccessLevels()[a], ::SetAutoVerification, a);
            break;
        
        case "Doheart Options":
            if(!IsDefined(level.DoheartStyle))
                level.DoheartStyle = "Pulsing";
            
            if(!IsDefined(level.DoheartSavedText))
                level.DoheartSavedText = CleanName(bot::get_host_player() getName());

            strings = Array("Apparition <3", "CF4_99 The Goat", "Custom");
            
            self addMenu("Doheart Options");
                self addOptBool(level.Doheart, "Doheart", ::Doheart);
                self addOptSlider("Text", ::DoheartTextPass, strings);
                self addOptSlider("Style", ::SetDoheartStyle, Array("Pulsing", "Pulse Effect", "Type Writer", "Moving", "Fade Effect"));
            break;
        
        case "Edit Lobby Timer":
            self addMenu("Edit Lobby Timer");
                self addOptBool(level.timerstopped, "Pause Timer", ::ServerPauseTimer);
                self addOpt("Custom Lobby Time", ::NumberPad, ::ServerCustomLobbyTimer);
                self addOpt("Add 1 Minute", ::ServerSetLobbyTimer, 1);
                self addOpt("Subtract 1 Minute", ::ServerSetLobbyTimer, -1);
            break;
        
        case "Edit Score Limit":
            self addMenu("Edit Score Limit");
                self addOpt("Custom Score Limit", ::NumberPad, ::ServerSetLobbyScore);
                self addOpt("No Score Limit", ::ServerSetLobbyScore, 0);
                self addOpt("Reset Score Limit", ::ServerSetLobbyScore, level.saveScoreLimit);
            break;
        
        case "Change Map":
            self addMenu("Change Map");
                self addOpt("Standard Maps", ::newMenu, "Standard Maps");
                self addOpt("DLC Packs", ::newMenu, "DLC Packs");
                self addOpt("DLC Bonus", ::newMenu, "DLC Bonus");
            break;
        
        case "Standard Maps":
            maps = Array("mp_biodome", "mp_spire", "mp_sector", "mp_apartments", "mp_chinatown", "mp_veiled", "mp_havoc", "mp_ethiopia", "mp_infection", "mp_metro", "mp_redwood", "mp_stronghold", "mp_nuketown_x");
            
            self addMenu("Standard Maps");
                
                for(a = 0; a < maps.size; a++)
                    self addOptBool((level.script == maps[a]), ReturnMapName(maps[a]), ::ServerChangeMap, maps[a]);
            break;
        
        case "DLC Packs":
            maps = Array("mp_rise", "mp_waterpark", "mp_skyjacked", "mp_crucible", "mp_kung_fu", "mp_conduit", "mp_aerospace", "mp_banzai", "mp_arena", "mp_shrine", "mp_cryogen", "mp_rome", "mp_ruins", "mp_miniature", "mp_western", "mp_city");

            self addMenu("DLC Packs");

                for(a = 0; a < maps.size; a++)
                    self addOptBool((level.script == maps[a]), ReturnMapName(maps[a]), ::ServerChangeMap, maps[a]);
            break;
        
        case "DLC Bonus":
            maps = Array("mp_redwood_ice", "mp_veiled_heyday");

            self addMenu("DLC Bonus");

                for(a = 0; a < maps.size; a++)
                    self addOptBool((level.script == maps[a]), ReturnMapName(maps[a]), ::ServerChangeMap, maps[a]);
            break;
    }
}

SuperJump()
{
    level.SuperJump = BoolVar(level.SuperJump);
    SetJumpHeight(Is_True(level.SuperJump) ? 1023 : 39);
}

LowGravity()
{
    SetDvar("bg_gravity", (GetDvarInt("bg_gravity") == level.BgGravity) ? 200 : level.BgGravity);
}

SuperSpeed()
{
    SetDvar("g_speed", (GetDvarString("g_speed") == level.GSpeed) ? "500" : level.GSpeed);
}

ServerSetTimeScale(timescale)
{
    if(GetDvarInt("timescale") == timescale)
        return;
    
    SetDvar("timescale", timescale);
}

AntiQuit()
{
    level.AntiQuit = BoolVar(level.AntiQuit);
    SetMatchFlag("disableIngameMenu", Is_True(level.AntiQuit));
}

AntiCamp()
{
    level.AntiCamp = BoolVar(level.AntiCamp);

    if(Is_True(level.AntiCamp))
    {
        foreach(player in GetPlayerArray())
        {
            if(IsAlive(player) && !Is_True(player.AntiCamp))
                player thread AntiCampMonitor();
        }
    }
    else
    {
        foreach(player in GetPlayerArray())
        {
            if(Is_True(player.AntiCamp))
                player.AntiCamp = BoolVar(player.AntiCamp);
        }
    }
}

AntiCampMonitor()
{
    if(IsDefined(self.AntiCamp))
        return;
    
    self endon("disconnect");
    level endon("game_ended");
    
    self.AntiCamp = true;
    self.LastTimeChecked = GetTime();
    self.PositionArray = [];
    Radius = 175;
    
    while(Is_True(level.AntiCamp))
    {
        if(!IsAlive(self))
        {
            wait 0.5;

            self.LastTimeChecked = GetTime();
            self.PositionArray = [];
            continue;
        }
        
        self.PositionArray[self.PositionArray.size] = self.origin;
        timeCamping = (GetTime() - self.LastTimeChecked);
        
        if(timeCamping >= level.MaxCampTime)
        {
            if(Distance(self.PositionArray[0], self.origin) < Radius && Distance(self.PositionArray[1], self.PositionArray[0]) < Radius)
            {
                timeCamping = GetTime() - self.LastTimeChecked;
                self AntiCampAction();
            }
            
            self.PositionArray = [];
            self.LastTimeChecked = GetTime();
        }
        
        wait 0.05;
    }
}

AntiCampAction()
{
    switch(level.AntiCampAction)
    {
        case "Kill":
            self Suicide();
            self iPrintlnBold("You Have Been Killed For Camping");
            break;
        
        case "Warn":
            self iPrintlnBold("^1WARNING: ^7Stop Camping");
            break;
        
        case "Kick":
            Kick(self GetEntityNumber());
            break;
        
        default:
            break;
    }
}

AntiCampMaxTime(time)
{
    level.MaxCampTime = (time * 1000);
}

SetAntiCampAction(action)
{
    level.AntiCampAction = action;
}

HearAllPlayers()
{
    level.HearAllPlayers = BoolVar(level.HearAllPlayers);
    SetMatchTalkFlag("EveryoneHearsEveryone", Is_True(level.HearAllPlayers));
}

SetAutoVerification(num)
{
    level.AutoVerify = num;
    self thread SetVerificationAllPlayers(num);
}

Doheart()
{
    level.Doheart = BoolVar(level.Doheart);
    
    if(Is_True(level.Doheart))
    {
        level thread SetDoheartText(level.DoheartSavedText, true);
    }
    else
    {
        if(IsDefined(level.DoheartText))
            level.DoheartText destroy();
    }
}

SetDoheartText(text, refresh)
{
    if(level.DoheartSavedText == text && (!IsDefined(refresh) || !refresh))
        return;
    
    level.DoheartSavedText = text;

    if(!Is_True(level.Doheart) || !IsDefined(text))
        return;
    
    if(IsDefined(level.DoheartText))
        level.DoheartText destroy();

    level.DoheartText = level createServerText("objective", 2, 1, "", "CENTER", "CENTER", 0, -215, 1, (1, 1, 1));
    
    switch(level.DoheartStyle)
    {
        case "Pulsing":
            level thread PulsingText(level.DoheartSavedText, level.DoheartText);
            break;
        
        case "Pulse Effect":
            level thread PulseFXText(level.DoheartSavedText, level.DoheartText);
            break;
        
        case "Type Writer":
            level thread TypeWriterFXText(level.DoheartSavedText, level.DoheartText);
            break;
        
        case "Moving":
            level thread RandomPosText(level.DoheartSavedText, level.DoheartText);
            break;
        
        case "Fade Effect":
            level thread FadingTextEffect(level.DoheartSavedText, level.DoheartText);
            break;
        
        default:
            break;
    }
}

DoheartTextPass(strng)
{
    if(strng != "Custom")
        self thread SetDoheartText(strng);
    else
        self Keyboard(::SetDoheartText);
}

SetDoheartStyle(style)
{
    if(level.DoheartStyle == style)
        return;
    
    level.DoheartStyle = style;

    if(Is_True(level.Doheart) && IsDefined(level.DoheartSavedText))
        level thread SetDoheartText(level.DoheartSavedText, true);
}

Newsbar()
{
    level.Newsbar = BoolVar(level.Newsbar);

    if(Is_True(level.Newsbar))
    {
        level endon("EndNewsBar");

        level.NewsbarBG   = level createServerRectangle("CENTER", "CENTER", 0, -232, 5000, 18, (0, 0, 0), 1, 0.6, "white");
        level.NewsbarText = level createServerText("default", 1, 3, "", "CENTER", "CENTER", 0, -255, 1, (1, 1, 1));
        
        strings = Array("Welcome To ^1" + GetMenuName() + " ^7Developed By ^1CF4_99", "Your Host Today Is ^1" + CleanName(bot::get_host_player() getName()), "[{+speed_throw}] & [{+melee}] To Open ^1" + GetMenuName(), "YouTube.Com/^1CF4_99", "^5Enjoy Your Stay!");
        
        while(Is_True(level.Newsbar))
        {
            for(a = 0; a < strings.size; a++)
            {
                if(IsDefined(level.NewsbarText))
                {
                    level.NewsbarText SetTextString(strings[a]);
                    level.NewsbarText hudMoveY(-232, 0.55);
                    level.NewsbarText ChangeFontscaleOverTime1(1.2, 0.75);
                    wait 5;
                }
                
                if(IsDefined(level.NewsbarText))
                {
                    level.NewsbarText ChangeFontscaleOverTime1(1, 0.3);
                    wait 0.3;
                }
                
                if(IsDefined(level.NewsbarText))
                {
                    level.NewsbarText thread hudMoveY(-255, 0.55);
                    wait 0.55;
                }
            }
        }
    }
    else
    {
        if(IsDefined(level.NewsbarBG))
            level.NewsbarBG destroy();
        
        if(IsDefined(level.NewsbarText))
            level.NewsbarText destroy();
        
        level notify("EndNewsBar");
    }
}

ServerPauseWorld()
{
    level.ServerPauseWorld = BoolVar(level.ServerPauseWorld);
    SetPauseWorld(Is_True(level.ServerPauseWorld));
}

CustomAdvertise()
{
    if(!Is_True(level.CustomAdvertise))
    {
        menu = self getCurrent();
        curs = self getCursor();
        
        advert = self Keyboard();
        
        if(!IsDefined(advert) || advert == "")
            return;
    }

    level.CustomAdvertise = BoolVar(level.CustomAdvertise);
    
    if(Is_True(level.CustomAdvertise))
    {
        self RefreshMenu(menu, curs);
        
        while(Is_True(level.CustomAdvertise))
        {
            iPrintlnBold(advert);
            wait 10;
        }
    }
}

ServerPauseTimer()
{
    if(!Is_True(level.timerstopped))
        level thread globallogic_utils::pausetimer();
    else
        level thread globallogic_utils::resumetimer();
}

ServerSetLobbyTimer(value)
{
    SetGametypeSetting("timelimit", GetGametypeSetting("timelimit") + value);
}

ServerCustomLobbyTimer(value)
{
    SetGametypeSetting("timelimit", value * 60000);
}

ServerSetLobbyScore(input)
{
    level.scorelimit = input;
    SetDvar("ui_scorelimit", input);
    SetGametypeSetting("scorelimit", input);
    level notify("update_scorelimit");
}

ServerChangeMap(map)
{
    if(!MapExists(map))
        return self iPrintlnBold("Map Doesn't Exist");
    
    if(level.script == map)
        return;
    
    Map(map);
}

ServerRestart()
{
    maps = Array("mp_biodome", "mp_spire", "mp_sector", "mp_apartments", "mp_chinatown", "mp_veiled", "mp_havoc", "mp_ethiopia", "mp_infection", "mp_metro", "mp_redwood", "mp_stronghold", "mp_nuketown_x", "mp_rise", "mp_waterpark", "mp_skyjacked", "mp_crucible", "mp_kung_fu", "mp_conduit", "mp_aerospace", "mp_banzai", "mp_arena", "mp_shrine", "mp_cryogen", "mp_rome", "mp_ruins", "mp_miniature", "mp_western", "mp_city", "mp_redwood_ice", "mp_veiled_heyday");

    if(isInArray(maps, level.script))
        Map(level.script);
    else
        MissionFailed();
}