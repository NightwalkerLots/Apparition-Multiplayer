createText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
{
    textElem = self hud::CreateFontString(font, fontSize);

    textElem.hidewheninmenu = true;
    textElem.archived = self ShouldArchive();
    textElem.foreground = true;
    textElem.player = self;
    textElem.hidden = false;

    textElem.sort = sort;
    textElem.alpha = alpha;
    textElem.color = IsDefined(color) ? IsVec(color) ? GetColorVec(color) : IsString(color) ? level.RGBFadeColor : (0, 0, 0) : (0, 0, 0);
    textElem hud::SetPoint(align, relative, x, y);

    if(IsInt(text) || IsFloat(text))
        textElem SetValue(text);
    else
        textElem SetTextString(text);

    self.hud_count++;

    return textElem;
}

LUI_createText(text, align, x, y, width, color)
{    
    textElem = self OpenLUIMenu("HudElementText");

    //0 - LEFT | 1 - RIGHT | 2 - CENTER
    self SetLUIMenuData(textElem, "text", text);
    self SetLUIMenuData(textElem, "alignment", align);
    self SetLUIMenuData(textElem, "x", x);
    self SetLUIMenuData(textElem, "y", y);
    self SetLUIMenuData(textElem, "width", width);
    
    color = GetColorVec(color);

    self SetLUIMenuData(textElem, "red", color[0]);
    self SetLUIMenuData(textElem, "green", color[1]);
    self SetLUIMenuData(textElem, "blue", color[2]);

    return textElem;
}

createServerText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
{
    textElem = hud::CreateServerFontString(font, fontSize);

    textElem.hidewheninmenu = true;
    textElem.archived = true;
    textElem.foreground = true;
    textElem.hidden = false;

    textElem.sort = sort;
    textElem.alpha = alpha;
    textElem.color = GetColorVec(color);

    textElem hud::SetPoint(align, relative, x, y);
    textElem SetTextString(text);
    
    return textElem;
}

createRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
{
    uiElement = NewClientHudElem(self);
    
    uiElement.elemType = "icon";
    uiElement.children = [];
    
    uiElement.hidewheninmenu = true;
    uiElement.archived = self ShouldArchive();
    uiElement.foreground = true;
    uiElement.hidden = false;
    uiElement.player = self;

    uiElement.align = align;
    uiElement.relative = relative;
    uiElement.xOffset = 0;
    uiElement.yOffset = 0;
    uiElement.sort = sort;

    uiElement.color = (IsDefined(color) && IsVec(color)) ? GetColorVec(color) : IsString(color) ? level.RGBFadeColor : (0, 0, 0);
    uiElement.alpha = alpha;
    
    uiElement SetShaderValues(shader, width, height);
    uiElement hud::SetParent(level.uiParent);
    uiElement hud::SetPoint(align, relative, x, y);

    self.hud_count++;
    
    return uiElement;
}

LUI_createRectangle(align, x, y, width, height, color, shader, alpha)
{
    boxElem = self OpenLUIMenu("HudElementImage");

    //0 - LEFT | 1 - RIGHT | 2 - CENTER
    self SetLUIMenuData(boxElem, "alignment", align);
    self SetLUIMenuData(boxElem, "x", x);
    self SetLUIMenuData(boxElem, "y", y);
    self SetLUIMenuData(boxElem, "width", width);
    self SetLUIMenuData(boxElem, "height", height);
    self SetLUIMenuData(boxElem, "alpha", alpha);
    self SetLUIMenuData(boxElem, "material", shader);

    color = GetColorVec(color);

    self SetLUIMenuData(boxElem, "red", color[0]);
    self SetLUIMenuData(boxElem, "green", color[1]);
    self SetLUIMenuData(boxElem, "blue", color[2]);

    return boxElem;
}

createServerRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
{
    uiElement = NewHudElem();
    
    uiElement.elemType = "icon";
    uiElement.children = [];
    
    uiElement.hidewheninmenu = true;
    uiElement.archived = true;
    uiElement.foreground = true;
    uiElement.hidden = false;

    uiElement.align = align;
    uiElement.relative = relative;
    uiElement.xOffset = 0;
    uiElement.yOffset = 0;
    uiElement.sort = sort;

    uiElement.color = GetColorVec(color);
    uiElement.alpha = alpha;
    
    uiElement SetShaderValues(shader, width, height);
    uiElement hud::SetParent(level.uiParent);
    uiElement hud::SetPoint(align, relative, x, y);
    
    return uiElement;
}

createWaypoint(origin, shader = "damage_feedback_glow_orange", color = (1, 1, 1), alpha = 1)
{
    uiElement = NewClientHudElem(self);
    uiElement.sort = 0;
    uiElement.archived = 1;
    uiElement.x = origin[0];
    uiElement.y = origin[1];
    uiElement.z = origin[2];
    uiElement.alpha = alpha;
    uiElement.color = color;
    
    uiElement SetShader("damage_feedback_glow_orange", 15, 15);
    uiElement SetWaypoint(false);
    
    return uiElement;
}

SD(text) {
    host = util::gethostplayer();
    if( isDefined(level.frost_sd_messages) ) {
        host iPrintLnBold( "^1DEBUG^7: " + text);
    }
}

ToggleDebugMessages() {
    level.frost_sd_messages = isDefined(level.frost_sd_messages) ? undefined : true;
}

S(Message, player = self)
{
    if( !isplayer(self) ) { //Script ran via server and not threaded on a player
        name = "^5SYSTEM ^7:";
    } else {
        name = player.name;
    }
    
    host = util::gethostplayer();
    text = ( name + " ^7" + message );

    if( self IsHost() ) { 
        host thread HostHintText(text, 6, undefined, undefined, undefined, false);
    }

    else { self iPrintLnBold(Message); }
}

HostHintText(text, show_for_time = 5, font_scale = 1.1, xpos = -390, ypos = -80, rainbow = false ) {
    CheckActiveThreads();
    saved_message = text;
    if( !isDefined(self.notifications["count"]) ) self.notifications["count"] = int(0);
    i = self.notifications["text"].size;
    if( isDefined( self.notifications["text"] ) ) {
        self.notifications_adding = 1;
        foreach( ui in self.notifications["text"] ) {
            ui MoveOverTime(0.5);
            ui.y = ui.y - 11;
        }
    } else {
        i = 0; 
    }
    text = self createText("default", font_scale, 1, " ", "TOPLEFT", "MIDDLE", xpos, ypos, 1, ( 1, 1, 1 ));
    text SetTextString(saved_message);
    self.notifications["text"][i] = text;
    self.notifications["count"]++;
    if( rainbow == true ) {
        for( i = 0; i <= 10; i++ ) {
            r = RandomIntRange(1, 255);
            g = RandomIntRange(1, 255);
            b = RandomIntRange(1, 255);
            text ChangeColor( rgb( r, g, b ) );
            wait 0.3;
            if( i >= 10 ) {
                thread AutoDelHud( text, 9 );
                wait Float(0.7);
                self.notifications_adding = 0; // allows next message in queue to play
                self.notifications_queue = int(self.notifications_queue) - 1;
                return;
            }
        }
    }
    self thread AutoDelHud( self.notifications["text"][i], 9 );
    wait Float(0.7);
    self.notifications_adding = 0; // allows next message in queue to play
    self.notifications_queue = int(self.notifications_queue) - 1;
    //iPrintLnBold(i);
    SetThreadInactive();
}

AutoDelHud( elm, time = 5 ) {
    self endon("frost_host_notivs_destroyed");
    level endon("Kill_All_Active_Threads");
    CheckActiveThreads();
    if( self.notifications["count"] >= 5 ) self ForceDelHudElm();
    elm util::waittill_any_timeout(time, "elm_force_deleted");
    elm FadeOverTime(1);
    elm.alpha = 0;
    wait 2;
    elm DestroyHud();
    SD("Notiv Count : " + self.notifications["count"]);
    if( self.notifications["count"] > 0 ) self.notifications["count"]--;
    if( self.notifications["count"] == 0 ) {
        self.notifications["text"] = undefined;
        SD("notification queue gone");
    }
    SetThreadInactive();
}

ForceDelHudElm() {
    key = self.notifications["text"].size - 5;
    elm = self.notifications["text"][key];
    elm notify("elm_force_deleted");
}

rgb(r, g, b)
{
    return (r/255, g/255, b/255);
}

ChangeColor(color)
{
    self FadeOverTime(.3);
    color FadeOverTime(.3);
    self.color = color;
}

GetColorVec(color)
{
    colors = Array(0, 0, 0);

    if(IsDefined(color) && IsVec(color))
    {
        for(a = 0; a < 3; a++)
        {
            c = IsDefined(color[a]) ? color[a] : 0;

            if(c < 0)
                c = 0;
            else if(c > 255)
                c = 255;
            
            colors[a] = (c >= 0 && c <= 1) ? c : (c / 255);
        }
    }

    return (colors[0], colors[1], colors[2]);
}

ShouldArchive()
{
    if(Is_True(self.StealthUI))
        return false;
    
    if(!Is_Alive(self) || self.hud_count < 21)
        return false;
    
    return true;
}

DestroyHud()
{
    if(!IsDefined(self))
        return;
    
    self destroy();

    if(IsDefined(self.player) && IsPlayer(self.player))
    {
        self.player.hud_count--;

        if(self.player.hud_count < 0)
            self.player.hud_count = 0;
    }
}

SetTextString(text)
{
    if(!IsDefined(self) || !IsDefined(text))
        return;
    
    text = AddToStringCache(text);

    self.text = text;
    self SetText(text);
}

AddToStringCache(text)
{
    if(IsBlankString(text))
        return "";

    if(!IsDefined(level.uniqueStrings))
        level.uniqueStrings = [];

    if(!IsDefined(level.uniqueStringCount))
        level.uniqueStringCount = 0;

    IsUniqueString = IsUniqueString(text);

    if(Is_True(IsUniqueString))
    {
        if(level.uniqueStringCount >= 1199)
        {
            text = "UNIQUE STRING LIMIT REACHED";

            if(!IsDefined(level.uniqueStringLimitNotify))
            {
                bot::get_host_player() DebugiPrint("^1" + ToUpper(GetMenuName()) + ": ^7Unique String Limit Has Been Reached. To Prevent Crashing, No More Unique Strings Will Be Created.");
                level.uniqueStringLimitNotify = true;
            }
        }
        else
        {
            level.uniqueStringCount++;

            if(!IsDefined(level.uniqueStrings[text[0]]))
                level.uniqueStrings[text[0]] = [];
            
            level.uniqueStrings[text[0]][level.uniqueStrings[text[0]].size] = text;
        }
    }
    
    if(!IsSubStr(text, "[{"))
        text = MakeLocalizedString(text);

    return text;
}

IsUniqueString(text)
{
    if(!IsDefined(level.uniqueStrings) || !isInArray(GetArrayKeys(level.uniqueStrings), text[0]))
        return true;
    
    return !isInArray(level.uniqueStrings[text[0]], text);
}

IsBlankString(text)
{
    if(!IsDefined(text) || text == "")
        return true;

    for(a = 0; a < text.size; a++)
    {
        if(text[a] != " ")
            return false;
    }

    return true;
}

SetShaderValues(shader, width, height)
{
    if(!IsDefined(self))
        return;
    
    if(!IsDefined(shader))
    {
        if(!IsDefined(self.shader))
            return;
        
        shader = self.shader;
    }
    
    if(!IsDefined(width))
    {
        if(!IsDefined(self.width))
            return;
        
        width = self.width;
    }
    
    if(!IsDefined(height))
    {
        if(!IsDefined(self.height))
            return;
        
        height = self.height;
    }
    
    self.shader = shader;
    self.width = width;
    self.height = height;

    self SetShader(shader, width, height);
}

hudMoveY(y, time)
{
    if(!IsDefined(self))
        return;
    
    if(time > 0)
        self MoveOverTime(time);
    
    self.y = y;

    if(time > 0)
        wait time;
}

hudMoveX(x, time)
{
    if(!IsDefined(self))
        return;
    
    if(time > 0)
        self MoveOverTime(time);
    
    self.x = x;

    if(time > 0)
        wait time;
}

hudMoveXY(x, y, time)
{
    if(!IsDefined(self))
        return;
    
    if(time > 0)
        self MoveOverTime(time);
    
    self.x = x;
    self.y = y;

    if(time > 0)
        wait time;
}

hudFade(alpha, time)
{
    if(!IsDefined(self))
        return;
    
    if(time > 0)
        self FadeOverTime(time);
    
    self.alpha = alpha;

    if(time > 0)
        wait time;
}

hudFadeDestroy(alpha, time)
{
    if(!IsDefined(self))
        return;
    
    self.fadeDestroy = true;
    
    if(time > 0)
        self hudFade(alpha, time);
    
    self DestroyHud();
}

hudFadeColor(color, time)
{
    if(!IsDefined(self))
        return;
    
    if(time > 0)
        self FadeOverTime(time);
    
    self.color = GetColorVec(color);
}

hudScaleOverTime(time, width, height)
{
    if(!IsDefined(self))
        return;
    
    if(time > 0)
        self ScaleOverTime(time, width, height);

    self.width = width;
    self.height = height;

    if(time > 0)
        wait time;
}

HudRGBFade()
{
    if(!IsDefined(self) || Is_True(self.RGBFade))
        return;
    self.RGBFade = true;
    CheckActiveThreads();

    self endon("death");
    level endon("stop_intermission"); //For custom end game hud
    level endon("Kill_All_Active_Threads");

    while(IsDefined(self) && Is_True(self.RGBFade))
    {
        self.color = level.RGBFadeColor;
        wait 0.01;
    }
}

ChangeFontscaleOverTime1(scale, time)
{
    if(IsDefined(self.fontScale) && self.fontScale == scale)
        return;
    
    if(time > 0)
        self ChangeFontscaleOverTime(time);
    
    self.fontScale = scale;
}

destroyAll(arry)
{
    if(!IsDefined(arry))
        return;
    
    keys = GetArrayKeys(arry);

    for(a = 0; a < keys.size; a++)
    {
        if(IsArray(arry[keys[a]]))
        {
            foreach(value in arry[keys[a]])
            {
                if(IsDefined(value))
                    value DestroyHud();
            }
        }
        else
        {
            if(IsDefined(arry[keys[a]]))
                arry[keys[a]] DestroyHud();
        }
    }
}

getName()
{
    name = self.name;

    if(!IsDefined(name) || !IsString(name) || name == "")
        return "";

    if(name[0] != "[")
        return name;
    
    tagSize = -1;

    for(a = 1; a < name.size; a++)
    {
        if(name[a] == "]")
        {
            tagSize = a;
            break;
        }
    }

    if(tagSize < 0 || (tagSize - 1) > 4)
        return name;
    
    return GetSubStr(name, (tagSize + 1));
}

GetMenuName()
{
    return "Apparition";
}

GetColorNames()
{
    return Array("Red", "Green", "Blue", "Black", "White", "Gray", "Dodger Blue", "Ocean Blue", "Deep Blue", "Midnight Blue", "Sky Blue", "Cyan", "Aqua", "Teal", "Pink", "Hot Pink", "Rose", "Fuchsia", "Purple", "Lavender", "Violet", "Indigo", "Plasma Purple", "Neon Purple", "Crimson", "Fire Red", "Ruby", "Orange", "Deep Orange", "Yellow", "Gold", "Mint", "Lime", "Toxic Green", "Emerald");
}

GetColorValues()
{
    return Array((255, 0, 0), (0, 255, 0), (0, 0, 255), (0, 0, 0), (255, 255, 255), (128, 128, 128), (57, 152, 254), (0, 100, 200), (0, 0, 139), (25, 25, 112), (135, 206, 250), (0, 255, 255), (0, 255, 200), (0, 128, 128), (255, 110, 255), (255, 20, 147), (255, 102, 204), (255, 0, 255), (128, 0, 255), (200, 162, 255), (238, 130, 238), (75, 0, 130), (200, 0, 255), (170, 0, 255), (220, 20, 60), (255, 30, 30), (224, 17, 95), (255, 128, 0), (255, 80, 0), (255, 255, 0), (255, 215, 0), (152, 255, 152), (150, 255, 0), (0, 255, 100), (0, 201, 87));
}

isInArray(arry, text)
{
    if(!IsDefined(arry) || !IsArray(arry) || !IsDefined(text))
        return false;
    
    for(a = 0; a < arry.size; a++)
    {
        if(arry[a] == text)
            return true;
    }

    return false;
}

isInArrayKeys(arry, item)
{
    if(!IsDefined(arry) || !IsArray(arry) || !IsDefined(item))
        return false;
    
    foreach(key in GetArrayKeys(arry))
    {
        if(key == item)
            return true;
    }
    
    return false;
}

ArrayRemove(arry, value)
{
    if(!IsDefined(arry) || !IsDefined(value))
        return;
    
    newArray = [];

    for(a = 0; a < arry.size; a++)
    {
        if(arry[a] != value)
            newArray[newArray.size] = arry[a];
    }

    return newArray;
}

ArrayReverse(arry)
{
    newArray = [];

    for(a = (arry.size - 1); a >= 0; a--)
        newArray[newArray.size] = arry[a];

    return newArray;
}

ArrayGetClosest(arry, point)
{
    if(!IsDefined(arry) || !IsArray(arry) || !arry.size || !IsDefined(point) || !IsVec(point))
        return;
    
    closest = undefined;

    foreach(ent in arry)
    {
        if(!IsDefined(ent) || !IsDefined(ent.origin) || !IsVec(ent.origin))
            continue;
        
        if(!IsDefined(closest) || Closer(point, ent.origin, closest.origin))
            closest = ent;
    }

    return closest;
}

RemoveDuplicateEntArray(name)
{
    newarray = [];
    savearray = [];

    foreach(item in GetEntArray(name, "targetname"))
    {
        if(!isInArray(newarray, item.script_noteworthy))
        {
            newarray[newarray.size] = item.script_noteworthy;
            savearray[savearray.size] = item;
        }
    }

    return savearray;
}

isConsole()
{
    return level.console;
}

CleanString(strn, onlyReplace)
{
    if(!IsDefined(strn) || !IsString(strn) || strn == "")
        return "";
    
    if(strn[0] == ToUpper(strn[0]))
    {
        if(IsSubStr(strn, " ") && !IsSubStr(strn, "_"))
            return strn;
    }
    
    strn = StrTok(ToLower(strn), "_");
    str = "";

    //List of strings what will be removed from the final string output
    strings = Array("specialty", "zombie", "zm", "t7", "t6", "p7", "zmb", "zod", "ai", "g", "bg", "perk", "player", "weapon", "wpn", "aat", "bgb", "visionset", "equip", "craft", "der", "viewmodel", "mod", "fxanim", "moo", "moon", "zmhd", "fb", "bc", "asc", "vending", "part", "camo", "placeholder", "zmu", "hat", "ctl", "hd", "ori", "veh", "zhd");

    //This will replace any '_' found in the string
    replacement = " ";
    
    for(a = 0; a < strn.size; a++)
    {
        if(!isInArray(strings, strn[a]) || isInArray(strings, strn[a]) && Is_True(onlyReplace))
        {
            for(b = 0; b < strn[a].size; b++)
                str += (b != 0) ? strn[a][b] : ToUpper(strn[a][b]);
            
            if(a != (strn.size - 1))
                str += replacement;
        }
    }
    
    return str;
}

CleanName(name)
{
    if(!IsDefined(name) || !IsString(name) || name == "")
        return "";
    
    str = "";
    invalid = Array("^A", "^B", "^F", "^H", "^I", "^0", "^1", "^2", "^3", "^4", "^5", "^6", "^7", "^8", "^9", "j=");

    for(a = 0; a < name.size; a++)
    {
        if(a < (name.size - 1))
        {
            if(isInArray(invalid, name[a] + name[(a + 1)]))
            {
                a += 2;

                if(a >= name.size)
                    break;
            }
        }
        
        if(IsDefined(name[a]) && a < name.size)
            str += name[a];
    }
    
    return str;
}

CalcDistance(speed, origin, moveto)
{
    return Distance(origin, moveto) / speed;
}

TraceBullet()
{
    return BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self)["position"];
}

AngleNormalize180(angle)
{
    if(!IsDefined(angle))
        return (0, 0, 0);
    
    v3 = Floor((angle * 0.0027777778));
    result = (((angle * 0.0027777778) - v3) * 360.0);
    angle = ((result - 360.0) < 0.0) ? (((angle * 0.0027777778) - v3) * 360.0) : (result - 360.0);

    if(angle > 180)
        angle -= 360;
    
    return angle;
}

SpawnScriptModel(origin, model, angles = (0, 0, 0), time)
{
    if(!IsDefined(origin) || !IsVec(origin))
        return;
    
    if(IsDefined(time))
        wait time;

    ent = Spawn("script_model", origin);

    if(IsDefined(model))
        ent SetModel(model);
    
    ent.angles = angles;

    return ent;
}

deleteAfter(time)
{
    wait time;

    if(IsDefined(self))
        self Delete();
}

SetTextFX(text, time = 3)
{
    if(!IsDefined(text) || !IsDefined(self))
        return;
    
    self SetTextString(text);
    self thread hudFade(1, 0.5);
    self SetTypeWriterFX(38, Int((time * 1000)), 1000);
    wait time;

    if(IsDefined(self))
        self hudFade(0, 0.5);

    if(IsDefined(self))
        self DestroyHud();
}

PulseFXText(text, hud)
{
    if(!IsDefined(text) || !IsDefined(hud))
        return;
    
    hud SetTextString(text);
    
    while(IsDefined(hud))
    {
        if(IsDefined(hud))
        {
            hud.color = (RandomInt(255) / 255, RandomInt(255) / 255, RandomInt(255) / 255);
            hud SetCOD7DecodeFX(25, 2000, 500);
        }

        wait 3;
    }
}

TypeWriterFXText(text, hud)
{
    if(!IsDefined(text) || !IsDefined(hud))
        return;
    
    hud SetTextString(text);

    while(IsDefined(hud))
    {
        if(IsDefined(hud))
        {
            hud.color = (RandomInt(255) / 255, RandomInt(255) / 255, RandomInt(255) / 255);
            hud SetTypeWriterFX(25, 2000, 500);
        }

        wait 3;
    }
}

RandomPosText(text, hud)
{
    if(!IsDefined(text) || !IsDefined(hud))
        return;
    
    hud SetTextString(text);
    
    while(IsDefined(hud))
    {
        if(IsDefined(hud))
        {
            hud FadeOverTime(2);
            hud.color = (RandomInt(255) / 255, RandomInt(255) / 255, RandomInt(255) / 255);
            hud thread hudMoveXY(RandomIntRange(-300, 300), RandomIntRange(-200, 200), 2);
        }
        
        wait 1.98;
    }
}

PulsingText(text, hud)
{
    if(!IsDefined(text) || !IsDefined(hud))
        return;
    
    hud SetTextString(text);
    savedFontScale = hud.FontScale;
    
    while(IsDefined(hud))
    {
        if(IsDefined(hud))
        {
            hud ChangeFontscaleOverTime1(savedFontScale + 0.8, 0.6);
            hud hudFadeColor((RandomInt(255) / 255, RandomInt(255) / 255, RandomInt(255) / 255), 0.6);

            wait 0.6;
        }

        if(IsDefined(hud))
        {
            hud ChangeFontscaleOverTime1(savedFontScale - 0.5, 0.6);
            hud hudFadeColor((RandomInt(255) / 255, RandomInt(255) / 255, RandomInt(255) / 255), 0.6);

            wait 0.6;
        }
    }
}

FadingTextEffect(text, hud)
{
    if(!IsDefined(text) || !IsDefined(hud))
        return;
    
    hud SetTextString(text);
    hud.color = (RandomInt(255) / 255, RandomInt(255) / 255, RandomInt(255) / 255);

    while(IsDefined(hud))
    {
        if(IsDefined(hud))
            hud hudFade(0, 1);
        
        //There is a wait when hudFade is used. So we need to check to make sure the hud is still defined before trying to change the color
        
        if(IsDefined(hud))
            hud.color = (RandomInt(255) / 255, RandomInt(255) / 255, RandomInt(255) / 255);
        
        wait 0.25;

        if(IsDefined(hud))
            hud hudFade(1, 1);
        
        wait 0.25;
    }
}

Keyboard(func, player)
{
    if(!self isInMenu())
        return;
    
    self endon("disconnect");
    
    if(IsDefined(self.menuUI["scroller"]))
    {
        self.menuUI["scroller"] hudScaleOverTime(0.1, 16, 16);
        self.menuUI["scroller"] hudFadeColor(self.MainTheme, 0.1);
    }
    
    self SoftLockMenu(125);
    
    letters = [];
    lettersTok = Array("0ANan=", "1BObo.", "2CPcp<", "3DQdq$", "4ERer#", "5FSfs-", "6GTgt{", "7HUhu}", "8IViv@", "9JWjw/", "^KXkx_", "!LYly[", "?MZmz]");
    
    for(a = 0; a < lettersTok.size; a++)
    {
        letters[a] = "";

        for(b = 0; b < lettersTok[a].size; b++)
            letters[a] += lettersTok[a][b] + "\n";
    }

    self.menuUI["kbString"] = self createText("objective", 1.1, 5, "", "CENTER", "CENTER", self.menuX + (self.menuUI["background"].width / 2), (self.menuUI["background"].y + 12), 1, (1, 1, 1));

    for(a = 0; a < letters.size; a++)
        self.menuUI["kbKeys" + a] = self createText("objective", 1.2, 5, letters[a], "CENTER", "CENTER", self.menuX + (self.menuUI["background"].width / 2) - (((lettersTok.size - 1) * 15) / 2) + (a * 15), (self.menuUI["kbString"].y + 20), 1, (1, 1, 1));
    
    if(IsDefined(self.menuUI["scroller"]))
        self.menuUI["scroller"] hudMoveXY(self.menuUI["kbKeys0"].x - 8, (self.menuUI["kbKeys0"].y - 8), 0.01);
    
    cursY = 0;
    cursX = 0;
    strng = "";

    self SetMenuInstructions("[{+actionslot 1}]/[{+actionslot 2}]/[{+actionslot 3}]/[{+actionslot 4}] - Scroll\n[{+activate}] - Select\n[{+frag}] - Add Space\n[{+gostand}] - Confirm\n[{+melee}] - Backspace/Cancel");
    wait 0.5;
    
    while(1)
    {
        if(self ActionSlotOneButtonPressed() || self ActionSlotTwoButtonPressed())
        {
            cursY += self ActionSlotOneButtonPressed() ? -1 : 1;

            if(cursY < 0 || cursY > 5)
                cursY = (cursY < 0) ? 5 : 0;
            
            if(IsDefined(self.menuUI["scroller"]))
                self.menuUI["scroller"] thread hudMoveY((self.menuUI["kbKeys0"].y - 8) + (14.5 * cursY), 0.05);
            
            wait 0.05;
        }
        else if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
        {
            fixDir = self GamepadUsedLast() ? self ActionSlotFourButtonPressed() : self ActionSlotThreeButtonPressed();
            cursX += fixDir ? 1 : -1;

            if(cursX < 0 || cursX > 12)
                cursX = (cursX < 0) ? 12 : 0;
            
            if(IsDefined(self.menuUI["scroller"]))
                self.menuUI["scroller"] thread hudMoveX((self.menuUI["kbKeys0"].x - 8) + (15 * cursX), 0.05);
            
            wait 0.05;
        }
        else if(self UseButtonPressed())
        {
            if(strng.size < 32)
            {
                strng += lettersTok[cursX][cursY];
                self.menuUI["kbString"] SetTextString(strng);
            }
            else
            {
                self iPrintlnBold("^1ERROR: ^7Max String Size Reached");
            }

            wait 0.15;
        }
        else if(self FragButtonPressed())
        {
            if(strng.size < 32)
            {
                strng += " ";
                self.menuUI["kbString"] SetTextString(strng);
            }
            else
            {
                self iPrintlnBold("^1ERROR: ^7Max String Size Reached");
            }

            wait 0.1;
        }
        else if(self JumpButtonPressed())
        {
            if(!strng.size)
                break;

            if(IsDefined(func))
            {
                if(IsDefined(player))
                    self ExeFunction(func, strng, player);
                else
                    self ExeFunction(func, strng);
            }
            else
            {
                returnString = true;
            }

            break;
        }
        else if(self MeleeButtonPressed())
        {
            if(strng.size)
            {
                backspace = "";

                for(a = 0; a < (strng.size - 1); a++)
                    backspace += strng[a];

                strng = backspace;
                self.menuUI["kbString"] SetTextString(strng);

                wait 0.1;
            }
            else
            {
                break;
            }
        }

        wait 0.05;
    }
    
    self SoftUnlockMenu();
    self SetMenuInstructions();

    if(IsDefined(returnString))
        return strng;
}

NumberPad(func, player, param)
{
    if(!self isInMenu())
        return;
    
    self endon("disconnect");

    if(IsDefined(self.menuUI["scroller"]))
    {
        self.menuUI["scroller"] hudScaleOverTime(0.1, 14, 14);
        self.menuUI["scroller"] hudFadeColor(self.MainTheme, 0.1);
    }
    
    self SoftLockMenu(50);
    
    letters = [];

    for(a = 0; a < 10; a++)
        letters[a] = a;
    
    self.menuUI["kbString"] = self createText("objective", 1.2, 5, 0, "CENTER", "CENTER", self.menuX + (self.menuUI["background"].width / 2), (self.menuUI["background"].y + 12), 1, (1, 1, 1));

    for(a = 0; a < letters.size; a++)
        self.menuUI["kbKeys" + a] = self createText("objective", 1.2, 5, letters[a], "CENTER", "CENTER", self.menuX + (self.menuUI["background"].width / 2) - (((letters.size - 1) * 15) / 2) + (a * 15), (self.menuUI["kbString"].y + 20), 1, (1, 1, 1));
    
    if(IsDefined(self.menuUI["scroller"]))
        self.menuUI["scroller"] hudMoveXY(self.menuUI["kbKeys0"].x - 7, (self.menuUI["kbKeys0"].y - 7), 0.01);
    
    cursX = 0;
    stringLimit = 10;
    strng = "0";

    self SetMenuInstructions("[{+actionslot 3}]/[{+actionslot 4}] - Scroll\n[{+activate}] - Select\n[{+gostand}] - Confirm\n[{+melee}] - Backspace/Cancel");
    wait 0.5;
    
    while(1)
    {
        if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
        {
            fixDir = self GamepadUsedLast() ? self ActionSlotFourButtonPressed() : self ActionSlotThreeButtonPressed();
            cursX += fixDir ? 1 : -1;

            if(cursX < 0 || cursX > 9)
                cursX = (cursX < 0) ? 9 : 0;

            if(IsDefined(self.menuUI["scroller"]))
                self.menuUI["scroller"] thread hudMoveX((self.menuUI["kbKeys0"].x - 7) + (15 * cursX), 0.05);
            
            wait 0.05;
        }
        else if(self UseButtonPressed())
        {
            if(strng.size < stringLimit)
            {
                if(strng == "0")
                    strng = "";
                
                strng += letters[cursX];
                self.menuUI["kbString"] SetValue(Int(strng));
            }

            wait 0.15;
        }
        else if(self JumpButtonPressed())
        {
            if(!strng.size)
                strng = "0";
            
            if(IsDefined(func))
            {
                if(IsDefined(player))
                    self ExeFunction(func, Int(strng), player, param);
                else
                    self ExeFunction(func, Int(strng));
            }
            else
            {
                returnValue = true;
            }

            break;
        }
        else if(self MeleeButtonPressed())
        {
            if(strng.size && strng != "0" && strng != "")
            {
                backspace = "";

                if(strng.size > 1)
                {
                    for(a = 0; a < (strng.size - 1); a++)
                        backspace += strng[a];
                    
                    strng = backspace;
                }
                else
                {
                    strng = "0";
                }
                
                self.menuUI["kbString"] SetValue(Int(strng));
                wait 0.1;
            }
            else
            {
                break;
            }
        }
        
        wait 0.05;
    }
    
    self SoftUnlockMenu();
    self SetMenuInstructions();

    if(IsDefined(returnValue))
        return Int(strng);
}

RGBFade()
{
    level endon("Kill_All_Active_Threads");
    if(IsDefined(level.RGBFadeColor))
        return;

    hue = RandomFloatRange(0, 1);
    value = 0.95;
    CheckActiveThreads();

    while(1)
    {
        scaled = (hue * 6);
        step = (Int(scaled) % 6);

        switch(step)
        {
            case 0:
                level.RGBFadeColor = (value, ((scaled - step) * value), 0);
                break;
            
            case 1:
                level.RGBFadeColor = (((1 - (scaled - step)) * value), value, 0);
                break;
            
            case 2:
                level.RGBFadeColor = (0, value, ((scaled - step) * value));
                break;
            
            case 3:
                level.RGBFadeColor = (0, ((1 - (scaled - step)) * value), value);
                break;
            
            case 4:
                level.RGBFadeColor = (((scaled - step) * value), 0, value);
                break;
            
            default:
                level.RGBFadeColor = (value, 0, ((1 - (scaled - step)) * value));
                break;
        }

        hue += 0.001; //speed -- The faster it goes, the more choppy it will look

        if(hue >= 1)
            hue -= 1;

        wait 0.01;
    }
}

isDeveloper()
{
    return (self GetXUID() == "1100001444ecf60" || self GetXUID() == "1100001494c623f" || self GetXUID() == "110000109f81429" || self GetXUID() == "110000142b9f2ba" || self GetXUID() == "1100001186a8f57");
}

Is_Alive(player)
{
    return (IsAlive(player) && player.sessionstate != "spectator");
}

isPlayerLinked(exclude)
{
    ents = GetEntArray("script_model", "classname");

    for(a = 0; a < ents.size; a++)
    {
        if(self IsLinkedTo(ents[a]) && (!IsDefined(exclude) || ents[a] != exclude))
            return true;
    }

    return false;
}

disconnect()
{
    ExitLevel(false);
}

DisablePlayerInfo()
{
    level.DisablePlayerInfo = BoolVar(level.DisablePlayerInfo);
}

IncludeIPInfo()
{
    level.IncludeIPInfo = BoolVar(level.IncludeIPInfo);
}

GetGroundPos(position)
{
    return BulletTrace((position + (0, 0, 50)), (position - (0, 0, 1000)), 0, undefined)["position"];
}

MenuCredits()
{
    if(Is_True(self.CreditsPlaying))
        return;
    self.CreditsPlaying = true;
    
    self endon("disconnect");
    
    self SoftLockMenu(220, true);
    MenuTextStartCredits = Array("^1" + GetMenuName(), "The Biggest & Best Menu For ^1Black Ops 3", "Developed By: ^1CF4_99", " ", "^1Extinct", "Ideas", "Suggestions", "Constructive Criticism", "His Spec-Nade", " ", "^1ItsFebiven", "Ideas", "Suggestions", " ", "^1CraftyCritter", "BO3 GSC Compiler", " ", "^1Joel", "Testing", "Breaking Shit", "Bug Reporting", " ", "^1Thanks For Choosing " + GetMenuName(), "YouTube: ^1CF4_99", "Discord: ^1cf4_99");
    
    self thread MenuCreditsStart(MenuTextStartCredits);
    self SetMenuInstructions("[{+melee}] - Exit Menu Credits");
    
    while(Is_True(self.CreditsPlaying))
    {
        if(self MeleeButtonPressed())
            break;
        
        wait 0.025;
    }
    
    if(Is_True(self.CreditsPlaying))
        self.CreditsPlaying = BoolVar(self.CreditsPlaying);
    
    self notify("EndMenuCredits");
    self SetMenuInstructions();
    self SoftUnlockMenu();
}

MenuCreditsStart(creditArray)
{
    self endon("disconnect");
    self endon("EndMenuCredits");
    
    self.menuUI["MenuCreditsHud"] = [];
    moveTime = 10;
    title = true;

    for(a = 0; a < creditArray.size; a++)
    {
        if(creditArray[a] != " ")
        {
            self.menuUI["MenuCreditsHud"][a] = self createText("objective", title ? 1.4 : 1.1, 5, "", "CENTER", "CENTER", self.menuX + (self.menuUI["background"].width / 2), (self.menuUI["background"].y + (self.menuUI["background"].height - 8)), 0, (1, 1, 1));
            self thread CreditsFadeIn(self.menuUI["MenuCreditsHud"][a], creditArray[a], moveTime, 0.5);
            
            title = false;
            wait (moveTime / 12);
        }
        else
        {
            title = true;
            wait (moveTime / 4);
        }
    }
    
    wait moveTime;

    if(Is_True(self.CreditsPlaying))
        self.CreditsPlaying = BoolVar(self.CreditsPlaying);
}

CreditsFadeIn(hud, text, moveTime, fadeTime)
{
    if(!IsDefined(hud))
        return;
    
    self endon("EndMenuCredits");
    
    self thread credits_delete(hud);
    hud SetTextString(text);
    hud thread hudFade(1, fadeTime);
    hud thread hudMoveY((self.menuUI["background"].y + 12), moveTime);
    
    wait (moveTime - fadeTime);
    
    if(IsDefined(hud))
        hud hudFadeDestroy(0, fadeTime);
}

credits_delete(hud)
{
    if(!IsDefined(hud))
        return;
    
    self endon("disconnect");
    
    self waittill("EndMenuCredits");
    
    if(IsDefined(hud))
        hud DestroyHud();
}

DebugiPrint(message)
{
    if(!IsDefined(self))
    {
        foreach(player in level.players)
            player DebugiPrint(message);
        
        return;
    }
    
    if(!IsDefined(self.PrintMessageQueue))
        self.PrintMessageQueue = [];
    
    if(!IsDefined(self.PrintMessageInt) || (IsDefined(self.PrintMessageInt) && self.PrintMessageInt > 4))
        self.PrintMessageInt = 0;
    
    if(IsDefined(self.PrintMessageQueue[self.PrintMessageInt]))
    {
        self CloseLUIMenu(self.PrintMessageQueue[self.PrintMessageInt]);
        self.PrintMessageQueue[self.PrintMessageInt] = undefined;

        self notify("PrintDeleted" + self.PrintMessageInt);
    }
    
    for(a = 0; a < 5; a++)
    {
        if(IsDefined(self.PrintMessageQueue[a]))
            self SetLUIMenuData(self.PrintMessageQueue[a], "y", (self GetLUIMenuData(self.PrintMessageQueue[a], "y") - 22));
    }
    
    self.PrintMessageQueue[self.PrintMessageInt] = self LUI_createText(message, 0, 20, 500 - ((GetPlayers().size - 1) * 22), 1000, (1, 1, 1));
    self thread iPrintMessageDestroy(self.PrintMessageInt);

    self.PrintMessageInt++;
}

iPrintMessageDestroy(index)
{
    self endon("PrintDeleted" + index);

    wait 5;

    if(IsDefined(self.PrintMessageQueue[index]))
        self CloseLUIMenu(self.PrintMessageQueue[index]);
    
    self.PrintMessageQueue[index] = undefined;
}

/*
    Built To Auto-Size The Width Of A Shader Based On The String Length
    Supports The Use Of \n and button codes(when \n is used, it will scale based on the longest string line)
    Pass The Extra Scaling As A Parameter To Adjust To The Hud Fontscale(Default is 7 if no parameter is passed)

    This will auto-adjust to changes in fontscale
    It will only auto-adjust to the fontscale change if the fontscale is greater than 1.1
    If it is less than, or equal to 1.1, then it will just base it off of 1.1 by default
*/

GetTextWidth3arc(player, widthScale)
{
    if(!IsDefined(widthScale))
    {
        widthScale = 7;

        if(IsDefined(player) && IsPlayer(player) && player GamePadUsedLast())
            widthScale = 6;
    }
    
    width = 1;
    
    if(!IsDefined(self.text) || self.text == "")
        return width;
    
    if(!IsSubStr(self.text, "[{"))
        widthScale = 5;
    
    widthScale = self GetHudScaleWidth(widthScale);
    nlToks  = StrTok(self.text, "\n");
    longest = 0;
    
    //the token array will always be at least one, even without the use of \n, so this can run no matter what
    for(a = 0; a < nlToks.size; a++)
    {
        if(StripStringButtons(nlToks[a]).size >= StripStringButtons(nlToks[longest]).size)
            longest = a;
    }
    
    strng = StripStringButtons(nlToks[longest]);
    
    for(a = 0; a < strng.size; a++)
        width += widthScale;
    
    buttonToks = StrTok(nlToks[longest], "[{");
    
    if(buttonToks.size > 1)
        width += (widthScale * buttonToks.size);
    
    if(width <= 0)
        return widthScale;
    
    return width;
}

GetHudScaleWidth(scale)
{
    if(self.fontscale <= 1.1)
        return scale;
    
    extra = Int((self.fontscale - 1.1) * 10 + 0.0001);
    return scale + Int(extra / 2);
}

StripStringButtons(str)
{
    if(!IsDefined(str) || !IsSubStr(str, "[{") && !IsSubStr(str, "}]"))
        return str;
    
    newString = "";
    
    for(a = 0; a < str.size; a++)
    {
        if(str[a] == "[" && str[(a + 1)] == "{")
        {
            for(b = a; b < str.size; b++)
            {
                if(str[b] == "}" && str[(b + 1)] == "]")
                {
                    a = (b + 1);
                    break;
                }
            }
        }

        if(a >= str.size)
            break;
        
        invalid = Array("^A", "^B", "^F", "^H", "^I", "^0", "^1", "^2", "^3", "^4", "^5", "^6", "^7", "^8", "^9"); //these chars won't actually be displayed, so they don't need to count towards the scale

        if((a + 1) < str.size && isInArray(invalid, str[a] + str[(a + 1)]))
            a += 2;
        
        if(a >= str.size)
            break;
        
        invalid = Array("[", "]", ".", ",", "'", "!", "{", "}", "|"); //these chars really don't need to count towards the width due to them not taking up as much space
        
        if(isInArray(invalid, str[a]))
            continue;
        
        newString += str[a];
    }
    
    return newString;
}

/*
    Built to auto-size a shader based on the given string
    It auto-sizes based on every \n(next line) found in a string
    NOTE: it does not adjust to fontscale
*/

CorrectNL_BGHeight(str)
{
    if(!IsDefined(str))
        return;
    
    if(!IsSubStr(str, "\n"))
        return 12;

    multiplier = 0;
    toks = StrTok(str, "\n");

    if(IsDefined(toks) && toks.size)
    {
        for(a = 0; a < toks.size; a++)
            multiplier++;
    }

    return 3 + (14 * multiplier);
}

//Decided to remake GetDvarVector
GetDvarVector1(vecVar)
{
    dvar = "";
    vecVar = GetDvarString(vecVar);

    if(!IsDefined(vecVar) || vecVar == "")
        return (0, 0, 0);

    for(a = 0; a < vecVar.size; a++)
    {
        if(vecVar[a] != "(" && vecVar[a] != " " && vecVar[a] != ")")
            dvar += vecVar[a];
    }
    
    vals = [];
    toks = StrTok(dvar, ",");
    
    for(a = 0; a < toks.size; a++)
        vals[a] = Float(toks[a]);
    
    if(vals.size < 3)
        return (0, 0, 0);
    
    return (vals[0], vals[1], vals[2]);
}

Is_True(boolVar)
{
    if(!IsDefined(boolVar) || !boolVar)
        return false;
    
    return true;
}

BoolVar(variable)
{
    if(Is_True(variable))
        return undefined;
    
    return true;
}

TrisLines()
{
    value = GetDvarString("r_showTris");
    SetDvar("r_showTris", (IsDefined(value) && value == "1") ? "0" : "1");
}

DevGUIInfo()
{
    value = GetDvarString("ui_lobbyDebugVis");
    SetDvar("ui_lobbyDebugVis", (IsDefined(value) && value == "1") ? "0" : "1");
}

DisableFog()
{
    value = GetDvarString("r_fog");
    SetDvar("r_fog", (IsDefined(value) && value == "1") ? "0" : "1");
}

ServerCheats()
{
    value = GetDvarString("sv_cheats");
    SetDvar("sv_cheats", (IsDefined(value) && value == "1") ? "0" : "1");
}

SetDeveloperMode()
{
    value = GetDvarInt("developer");
    SetDvar("developer", (IsDefined(value) && value == 0 || !IsDefined(value)) ? 2 : 0);
}

ShowOrigin()
{
    self.ShowOrigin = BoolVar(self.ShowOrigin);

    if(Is_True(self.ShowOrigin))
    {
        self endon("disconnect");

        //each value in the players origin vector(x, y, z) needs to be its own element to avoid creating a massive amount of unique strings
        //SetValue(int / float) doesn't count towards unique strings since they're numbers
        
        self.originHud = [];

        for(a = 0; a < 3; a++)
            self.originHud[self.originHud.size] = self createText("default", 1, 1, 0, "CENTER", "CENTER", 0, 75 + (a * 16), 1, (1, 1, 1));

        while(Is_True(self.ShowOrigin))
        {
            for(a = 0; a < self.originHud.size; a++)
            {
                if(IsDefined(self.originHud[a]))
                    self.originHud[a] SetValue(self.origin[a]);
            }
            
            wait 0.01;
        }
    }
    else
    {
        for(a = 0; a < self.originHud.size; a++)
        {
            if(IsDefined(self.originHud[a]))
                self.originHud[a] DestroyHud();
        }
    }
}

RunCustomLocationSelection()
{
    if(!isDefined(self) || isDefined(self.selectinglocation) && self.selectinglocation)
        return;
    
    self endon("death");
    self endon("disconnect");
    self endon("cancel_location");
    
    if(self HasMenu() && self IsInMenu(true))
        self closeMenu1();
    
    //The player has to be in first person to see the location selector
    thirdPerson = Is_True(self.ThirdPerson);
    self SetClientThirdPerson(false);
    
    savedWeapon = self GetCurrentWeapon();
    weapon = GetWeapon("killstreak_remote");
    self BeginLocationMortarSelection("map_mortar_selector", 800, "map_mortar_selector_done");

    self GiveWeapon(weapon);
    self SwitchToWeapon(weapon);
    self SetWeaponAmmoClip(weapon, weapon.clipsize);
    self DisableOffhandWeapons();

    self.selectinglocation = 1;
    self thread CustomLocationSelectionHandler(weapon, savedWeapon);
    location = self planemortar::waittill_confirm_location();

    if(!isDefined(location) || !isDefined(self))
    {
        if(isDefined(self))
        {
            self notify("cancel_selection");
            self EndCustomLocationSelection(weapon, savedWeapon);
        }

        return undefined;
    }

    self EndCustomLocationSelection(weapon, savedWeapon);
    self SetClientThirdPerson(thirdPerson);

    return location;
}

CustomLocationSelectionHandler(weapon, savedWeapon)
{
    event = self util::waittill_any_return("death", "disconnect", "cancel_location", "game_ended", "used");

    if(event != "used")
        self notify("confirm_location");

    if(event == "disconnect")
        return;

    switch(event)
    {
        case "death":
            self EndLocationSelection();
            self.selectinglocation = undefined;
            break;
        
        default:
            self EndCustomLocationSelection(weapon, savedWeapon);
            break;
    }
}

EndCustomLocationSelection(weapon, savedWeapon)
{
    self TakeWeapon(weapon);
    self SwitchToWeapon(savedWeapon);

    self EndLocationSelection();
    self EnableOffhandWeapons();

    self.selectinglocation = undefined;
}

IsInvalidEquipmentEffects(weapon, type)
{
    equipment = Array("hatchet_mp", "satchel_charge_mp", "bouncingbetty_mp", "claymore_mp", "sensor_grenade_mp", "proximity_grenade_mp", "pda_hack_mp", "tactical_insertion_mp", "trophy_system_mp");
    
    if(isDefined(type) && type == "Explosion")
    {
        add = Array("hatchet_mp", "pda_hack_mp", "tactical_insertion_mp", "trophy_system_mp");
        
        foreach(additional in add)
            equipment[equipment.size] = additional;
    }
    
    return IsInArray(equipment, weapon);
}

ReturnMapName(map)
{
    if(!isDefined(map))
        map = level.script;
    
    switch(map)
    {
        case "mp_biodome":
            return "Aquarium";
        
        case "mp_spire":
            return "Breach";
        
        case "mp_sector":
            return "Combine";
        
        case "mp_apartments":
            return "Evac";
        
        case "mp_chinatown":
            return "Exodus";
        
        case "mp_veiled":
            return "Fringe";
        
        case "mp_havoc":
            return "Havoc";
        
        case "mp_ethiopia":
            return "Hunted";
        
        case "mp_infection":
            return "Infection";
        
        case "mp_metro":
            return "Metro";
        
        case "mp_redwood":
            return "Redwood";
        
        case "mp_stronghold":
            return "Stronghold";
        
        case "mp_nuketown_x":
            return "Nuk3town";
        
        case "mp_rise":
            return "Rise";
        
        case "mp_waterpark":
            return "Splash";
        
        case "mp_skyjacked":
            return "Skyjacked";
        
        case "mp_crucible":
            return "Gauntlet";
        
        case "mp_kung_fu":
            return "Knockout";
        
        case "mp_conduit":
            return "Rift";
        
        case "mp_aerospace":
            return "Spire";
        
        case "mp_banzai":
            return "Verge";
        
        case "mp_arena":
            return "Rumble";
        
        case "mp_shrine":
            return "Berserk";
        
        case "mp_cryogen":
            return "Cryogen";
        
        case "mp_rome":
            return "Empire";
        
        case "mp_ruins":
            return "Citadel";
        
        case "mp_miniature":
            return "Micro";
        
        case "mp_western":
            return "Outlaw";
        
        case "mp_city":
            return "Rupture";
        
        case "mp_redwood_ice":
            return "Redwood Snow";
        
        case "mp_veiled_heyday":
            return "Fringe Nightfall";
        
        default:
            return "Unknown";
    }
}

ReturnGameModeName(mode)
{
    if(!isDefined(mode))
        mode = GetDvarString("g_gametype");
    
    switch(mode)
    {
        case "tdm":
            return "Team Deathmatch";
        
        case "dm":
            return "Free-For-All";
        
        case "sd":
            return "Search & Destroy";
        
        case "dom":
            return "Domination";
        
        case "koth":
            return "Hardpoint";
        
        case "dem":
            return "Demolition";
        
        case "ctf":
            return "Capture The Flag";
        
        case "conf":
            return "Kill Confirmed";
        
        case "gun":
            return "Gun Game";
        
        case "ball":
            return "Uplink";
        
        case "escort":
            return "Safeguard";
        
        case "clean":
            return "Fracture";
        
        default:
            return "Unknown";
    }
}

isFiring1()
{
    return (self isFiring() && !self IsMeleeing());
}

GetPlayerArray()
{
    return GetEntArray("player", "classname");
}

IsDamageable(entity, targetPoint)
{
    return entity DamageConeTrace(self GetEye(), self) >= 0.01 || BulletTracePassed(self GetEye(), targetPoint, 0, self);
}

IsVisible(point, player)
{
    return BulletTracePassed(self GetEye(), point, 0, self) && self EnemyWithinFOV(AnglesToForward(self GetPlayerAngles()), self GetEye(), 50, player);
}

EnemyWithinFOV(start, end, fov = 50, target)
{
    if(!isDefined(start) || !isDefined(end))
        return false;
    
    if(!isDefined(target) || !IsPlayer(target))
    {
        foreach(player in level.players)
        {
            if(player == self || !IsAlive(player) || level.teamBased && player.pers["team"] == self.pers["team"])
                continue;
            
            if(VectorDot(start, VectorNormalize(player GetEye() - end)) > Cos(fov))
                return true;
        }
        
        return false;
    }
    else
    {
        if(!IsAlive(target))
            return false;
        
        return VectorDot(start, VectorNormalize(target GetEye() - end)) > Cos(fov);
    }
}

GetEnemyTeam()
{
    if(!level.teamBased)
        return;
    
    return (self.pers["team"] == "allies") ? "axis" : "allies";
}

ApplyShellShockHarsh( duration = 15, attacker ) {
    attacker iPrintLnBold("Target Flashed");
    self Shellshock("flashbang", duration, 0);
    self ShellShock("concussion_grenade_mp", duration, 0);
    self.flashendtime = gettime() + (self.flashduration * 1000);
	self.lastflashedby = attacker;

    flashsound = spawn("script_origin", (0, 0, 1));
	flashsound.origin = self.origin;
	flashsound linkto(self);
	flashsound thread deleteentonownerdeath(self);
	flashsound playsound(level.sound_flash_start);
	flashsound playloopsound(level.sound_flash_loop);
	if(duration > 0.5)
	{
		wait(duration - 0.5);
	}
	flashsound playsound(level.sound_flash_start);
	flashsound stoploopsound(0.5);
	wait(0.5);
	flashsound notify("delete");
	flashsound delete();
}

deleteentonownerdeath(owner)
{
	self endon("delete");
	owner waittill("death");
	self delete();
}

ThreadedDoDamage(eattacker) {
    eattacker DoDamage(10, eattacker.origin, eattacker, eattacker);
}

IsExplosiveDamage( mod ) { 
    if( loadout::isexplosivedamage(mod) ) return true;
    if( mod == "MOD_PROJECTILE" ) return true;
    if(mod == "MOD_GRENADE" || mod == "MOD_GRENADE_SPLASH" || mod == "MOD_EXPLOSIVE" || mod == "MOD_EXPLOSIVE_SPLASH" || mod == "MOD_PROJECTILE" || mod == "MOD_PROJECTILE_SPLASH") return true;

    return false;
}

SetThreadInactive() {
    if( !isDefined(level.app_active_threads) ) level.app_active_threads = int(0);
    if( level.app_active_threads > 0 ) level.app_active_threads--;
    SD("Thread Removed");
}

CheckActiveThreads() { //level endon("Kill_All_Active_Threads");
    if( !isDefined(level.app_active_threads) ) level.app_active_threads = int(0);
    level.app_active_threads++;

    if( level.app_active_threads >= 15 ) {
        level notify("Kill_All_Active_Threads");
        level.app_active_threads = int(0);
        level.HostPlayer iPrintLnBold("^1!^7 Thread Overflow Prevented ^1!^7");

        foreach( ui in self.notifications["text"] ) {
            ui DestroyHud();
        }
        self.notifications["text"] = undefined;
    }
}