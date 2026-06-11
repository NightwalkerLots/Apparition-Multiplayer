PopulateMessageMenu(menu)
{
    switch(menu)
    {
        case "Message Menu":
            self addMenu("Message Menu");
                self addOptSlider("Display Type", ::MessageDisplay, Array("TypeWriter", "Print Bold", "Center UI"));
                self addOpt("Display Message", ::DisplayMessage);
                self addOptIncSlider("Center UI Font Size", ::SetMessageFontSize, 1, 1.5, 10, 0.5);
                self addOptBool(level.customprintlnloop, "iPrintLn Loop", ::PrintlnLoop);
                self addOpt("Custom Message", ::Keyboard, ::DisplayMessage);
                self addOpt("Set Message Text", ::newMenu, "Set Message Text");
            break;
        
        case "Set Message Text":
            self addMenu("Set Message Text");
                foreach(message in level.MenuMessageStrings) {
                    self addOpt(message, ::GetCachedCustomMessage, message);
                }
        break;
    }
}

InitMenuMessageStrings() {
    level.MenuMessageStrings = [
        GetMenuName() + " Was Developed By CF4_99",
        "Welcome To " + GetMenuName(),
        "You've Been ^1Deranked",
        "Discord.gg/e6GKUsbFaE",
        "Youtube.com/c/NightwalkerLots",
        "this server is sponsored by Israel!!",
        "cidshook runs skidops and T7 patch",
        "cleanops.dev is c&p",
        "nightWolf & Krashgamer are pedophiles",
        "cids is fat",
        "Who's Modding?",
        "lerggy sniffs pennies",
        "cidshook rails your mom",
        "^BBUTTON_ZM_VIAL_ICON^ ^BBUTTON_ZM_VIAL_ICON^ ^BBUTTON_ZM_VIAL_ICON^",
        "Your Host Today Is " + CleanName(bot::get_host_player() getName()),
        "Want Menu?"
    ];
}

GetCachedCustomMessage(message, setmessage = true) {
    level.CachedCustomMessage = GetDvarString("saved_cached_message", "Discord.gg/e6GKUsbFaE");
    if(setmessage != true) return level.CachedCustomMessage;

    level.CachedCustomMessage = message;
    SetDvar("saved_cached_message", message);
}

SetMessageFontSize(val) {
    level.CachedCustomMessage_FontSize = val;
}

MessageDisplay(type)
{
    self.MessageDisplay = type;
}

DisplayMessage(message = undefined)
{
    if(!isDefined(message)) message = GetCachedCustomMessage(undefined, false);
    if(!IsDefined(self.MessageDisplay))
        self.MessageDisplay = "TypeWriter";
    
    switch(self.MessageDisplay)
    {
        case "TypeWriter":
            thread typeWriter(message);
        break;
        
        case "Print Bold":
            iPrintlnBold(message);
        break;

        case "Center UI":
            ice_display_discord_advert();
        break;
        
        default:
            break;
    }
}

typeWriter(message)
{
    if(!IsDefined(level.LobbyMessageQueue))
        level.LobbyMessageQueue = [];

    level.LobbyMessageQueue[level.LobbyMessageQueue.size] = message;

    if(Is_True(level.LobbyTypeWriterCreating) || IsDefined(level.LobbyTypeWriterMessage))
        return;

    level.LobbyTypeWriterCreating = true;

    while(level.LobbyMessageQueue.size)
    {
        next = level.LobbyMessageQueue[0];
        newQueue = [];

        for(a = 1; a < level.LobbyMessageQueue.size; a++)
            newQueue[newQueue.size] = level.LobbyMessageQueue[a];
        
        level.LobbyMessageQueue = newQueue;

        level.LobbyTypeWriterMessage = createServerText("objective", 1.7, 1, "", "TOP", "TOP", 0, 75, 1, level.RGBFadeColor);
        level.LobbyTypeWriterMessage thread SetTextFX(next, 4);
        level.LobbyTypeWriterMessage thread HudRGBFade();

        while(IsDefined(level.LobbyTypeWriterMessage))
            wait 0.1;
    }

    level.LobbyTypeWriterCreating = undefined;
}

PrintlnLoop( ) {
    level endon("Kill_All_Active_Threads");
    level.customprintlnloop = isDefined(level.customprintlnloop) ? undefined : true;
    message = GetCachedCustomMessage(undefined, false);

    if(Is_True(level.customprintlnloop)) CheckActiveThreads();
    else SetThreadInactive();

    while(is_true(level.customprintlnloop)) {
        if(!isDefined(level.customprintlnloop)) return;
        iPrintLn(message);
        wait 0.5;
    }
}

ice_display_discord_advert(  ) { //createText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
    if( !isDefined( level.ice_discord_advert ) ) {
        level.ice_discord_advert = true;
        if(!isDefined(level.CachedCustomMessage_FontSize)) level.CachedCustomMessage_FontSize = 1.5;
        message = GetCachedCustomMessage(undefined, false);
        foreach( p in level.players ) {
            elm = p createText("objective", level.CachedCustomMessage_FontSize, 5, message, "TOP", "TOP", 0, 0, 0, (1, 1, 1));
            elm FadeOverTime(1);
            elm.alpha = 1;
            //p thread ice_rainbow_discord_advert( elm );
            p.ice_discord_advert_text = elm; 
        }
        S("String Advert ^2Enabled");
    } else {
        level.ice_discord_advert = undefined;
        S("String Advert ^1Disabled");
        foreach(p in level.players) {
            p.ice_discord_advert_text destroy();
        }
    }
}

NewPlayer_DisplayAdvert( ) {
    message = GetCachedCustomMessage(undefined, false);
    elm = self createText("objective", 1.1, 5, message, "TOP", "TOP", 0, 0, 0, (1, 1, 1));
    elm FadeOverTime(1);
    elm.alpha = 1;
    //self thread ice_rainbow_discord_advert( elm );
    self.ice_discord_advert_text = elm;
}