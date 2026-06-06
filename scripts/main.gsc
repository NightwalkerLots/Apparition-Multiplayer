/*
    ░█████╗░██████╗░██████╗░░█████╗░██████╗░██╗████████╗██╗░█████╗░███╗░░██╗
    ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║╚══██╔══╝██║██╔══██╗████╗░██║
    ███████║██████╔╝██████╔╝███████║██████╔╝██║░░░██║░░░██║██║░░██║██╔██╗██║
    ██╔══██║██╔═══╝░██╔═══╝░██╔══██║██╔══██╗██║░░░██║░░░██║██║░░██║██║╚████║
    ██║░░██║██║░░░░░██║░░░░░██║░░██║██║░░██║██║░░░██║░░░██║╚█████╔╝██║░╚███║
    ╚═╝░░╚═╝╚═╝░░░░░╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝

    Menu:                 Apparition MP
    Developer:            CF4_99
    Discord:              cf4_99
    YouTube:              https://www.youtube.com/c/CF499

    Apparition Discord Server: https://discord.gg/apparitionbo3
    Please leave credit if you use this base

    Multiplayer Port and features: NightwalkerLots
    Originally Ported by: CF4_99
*/

#include scripts\codescripts\struct;
#include scripts\shared\callbacks_shared;
#include scripts\shared\clientfield_shared;
#include scripts\shared\math_shared;
#include scripts\shared\system_shared;
#include scripts\shared\util_shared;
#include scripts\shared\hud_util_shared;
#include scripts\shared\hud_message_shared;
#include scripts\shared\hud_shared;
#include scripts\shared\array_shared;
#include scripts\shared\rank_shared;
#include scripts\shared\flag_shared;
#include scripts\shared\killstreaks_shared;
#include scripts\shared\load_shared;
#include scripts\shared\weapons_shared;
#include scripts\shared\weapons\_weapons;
#include scripts\shared\persistence_shared;
#include scripts\shared\medals_shared;
#include scripts\shared\scoreevents_shared;
#include scripts\shared\visionset_mgr_shared;
#include scripts\shared\lui_shared;
#include scripts\shared\bots\_bot;

#include scripts\mp\_util;
#include scripts\mp\_arena;
#include scripts\mp\_contracts;
#include scripts\mp\gametypes\_loadout;
#include scripts\mp\gametypes\_globallogic;
#include scripts\mp\gametypes\_globallogic_actor;
#include scripts\mp\gametypes\_globallogic_player;
#include scripts\mp\gametypes\_globallogic_vehicle;
#include scripts\mp\gametypes\_globallogic_audio;
#include scripts\mp\gametypes\_globallogic_score;
#include scripts\mp\gametypes\_globallogic_utils;
#include scripts\mp\gametypes\_globallogic_ui;
#include scripts\mp\killstreaks\_killstreaks;
#include scripts\mp\killstreaks\_killstreakrules;
#include scripts\mp\killstreaks\_airsupport;
#include scripts\mp\killstreaks\_planemortar;

#namespace duplicate_render;

autoexec __init__system__()
{
    system::register("duplicate_render", ::__init__, undefined, undefined);
}

__init__()
{
    callback::on_connect(::onPlayerConnect);
    callback::on_spawned(::onPlayerSpawned);
    callback::on_disconnect(::onPlayerDisconnect);
}

onPlayerConnect()
{
    if(!self IsHost())
        return;
    
    level thread RGBFade();
    self thread AntiEndGame();
    level thread DefineMenuArrays();
    level thread int_overides();
}

onPlayerSpawned()
{
    self endon("disconnect");

    if(Is_True(self.runningSpawned))
        return;
    self.runningSpawned = true;

    //Everything put here will be ran every time players spawn
    if(Is_True(self.Invisibility))
        self Hide();

    if(Is_True(self.ReducedSpread))
        self SetSpreadOverride(1);
    
    if(Is_True(level.AntiCamp) && IsAlive(self) && !Is_True(self.AntiCamp))
        self thread AntiCampMonitor();
    
    self SetClientThirdPerson(Is_True(self.ThirdPerson));
    self SetClientUIVisibilityFlag("hud_visible", !Is_True(self.DisablePlayerHUD));

    self.runningSpawned = BoolVar(self.runningSpawned);

    //Everything below this will only be ran on initial spawn
    if(isDefined(self.playerSpawned))
        return;
    self.playerSpawned = true;

    self thread playerSetup();
}

DefineMenuArrays()
{
    level.BgGravity = GetDvarInt("bg_gravity");
    level.GSpeed = GetDvarString("g_speed");
    
    level.menu_models = Array("defaultactor", "defaultvehicle");
    ents = GetEntArray("script_model", "classname");

    for(a = 0; a < ents.size; a++)
    {
        if(ents[a].model != "tag_origin" && ents[a].model != "" && !IsSubStr(ents[a].model, "collision_"))
            array::add(level.menu_models, ents[a].model, 0);
    }
    
    tempEffects = [];
    level.menuFX = [];
    fxs = GetArrayKeys(level._effect);

    for(a = 0; a < fxs.size; a++)
    {
        if(!IsDefined(fxs[a]))
            continue;
        
        if(IsSubStr(fxs[a], "step_") || IsSubStr(fxs[a], "fall_") || isInArray(level.menuFX, fxs[a]) || isInArray(tempEffects, level._effect[fxs[a]]) || fxs[a] == "qrdrone_prop")
            continue;
        
        level.menuFX[level.menuFX.size] = fxs[a];
        tempEffects[tempEffects.size] = level._effect[fxs[a]];
    }

    //This will remove the out of bounds triggers
    while(!IsDefined(level.oob_triggers) || !level.oob_triggers.size)
        wait 0.5;

    level.oob_triggers = [];
    level.oob_timelimit_ms = 2147483647;
    level.oob_damage_per_interval = 0;

    //This will remove death barriers
    triggers = ArrayCombine(GetEntArray("trigger_hurt", "classname"), GetEntArray("trigger_out_of_bounds", "classname"), 0, 1);

    foreach(trigger in triggers)
    {
        if(!IsDefined(trigger))
            continue;
        
        trigger Delete();
    }
}

playerSetup()
{
    if(self util::is_bot())
    {
        self.accessLevel = GetAccessLevels()[0];
        return;
    }

    self.hud_count = 0;
    self.menuUI = [];
    
    //Menu Design Variables
    self LoadMenuVars();

    accessValue = GetDvarInt("ApparitionV_" + self GetXUID());
    accessLevel = IsDefined(accessValue) ? (accessValue > 0 && accessValue < (GetAccessLevels().size - 1)) ? accessValue : 1 : 1;

    self.accessLevel = self isDeveloper() ? GetAccessLevels()[(GetAccessLevels().size - 1)] : self IsHost() ? GetAccessLevels()[(GetAccessLevels().size - 2)] : GetAccessLevels()[accessLevel];
    
    if(self hasMenu())
    {
        self thread MenuInstructionsDisplay();
        self thread menuMonitor();
    }
}

MenuInstructionsDisplay()
{
    self endon("disconnect");
    
    if(Is_True(self.MenuInstructionsDisplay))
        return;
    self.MenuInstructionsDisplay = true;

    self.menuInstructionsUI = [];
    
    while(self hasMenu() && !Is_True(self.DisableMenuInstructions))
    {
        if(self hasMenu() && (!Is_True(self.DisableMenuInstructions) && (!IsDefined(self.menuInstructionsUI["background"]) || !IsDefined(self.menuInstructionsUI["outline"]) || !IsDefined(self.menuInstructionsUI["string"]))))
        {
            if(!IsDefined(self.menuInstructionsUI["background"]))
                self.menuInstructionsUI["background"] = self createRectangle("TOP_LEFT", "CENTER", self.instructionsX, self.instructionsY, 0, 15, (42, 42, 42), 2, 1, "white");
            
            if(!IsDefined(self.menuInstructionsUI["outline"]))
                self.menuInstructionsUI["outline"] = self createRectangle("TOP_LEFT", "CENTER", (self.instructionsX - 1), (self.instructionsY - 1), 0, 17, self.MainTheme, 1, 1, "white");
            
            if(!IsDefined(self.menuInstructionsUI["string"]))
                self.menuInstructionsUI["string"] = self createText("default", 1.1, 3, "", "LEFT", "CENTER", (self.menuInstructionsUI["background"].x + 1), (self.menuInstructionsUI["background"].y + 7), 1, (255, 255, 255));
        }

        if(IsDefined(self.menuInstructionsUI["string"]) && Is_True(self.DisableMenuInstructions) || !self hasMenu() || !Is_Alive(self) && !Is_True(self.refreshInstructionsUI))
        {
            if(Is_True(self.DisableMenuInstructions) || !self hasMenu() || !Is_Alive(self) && !Is_True(self.refreshInstructionsUI))
                self DestroyInstructions();
            
            self.menuInstructionsUI = [];
            
            if(!Is_Alive(self) && !Is_True(self.refreshInstructionsUI))
                self.refreshInstructionsUI = true; //Instructions Need To Be Refreshed To Make Sure They Are Archived Correctly To Be Shown While Dead
        }

        if(Is_Alive(self) && Is_True(self.refreshInstructionsUI))
            self.refreshInstructionsUI = BoolVar(self.refreshInstructionsUI);
        
        if(IsDefined(self.menuInstructionsUI["string"]))
        {
            if(Is_Alive(self))
            {
                if(!IsDefined(self.instructionsString))
                {
                    if(!self isInMenu(true))
                    {
                        str = "";

                        foreach(index, btn in self.OpenControls)
                            str += (index < (self.OpenControls.size - 1)) ? "[{" + btn + "}] & " : "[{" + btn + "}]";
                        
                        str += ": Open " + GetMenuName();

                        if(!Is_True(self.DisableQM))
                        {
                            str += "\n";
                            
                            foreach(index, btn in self.QuickControls)
                                str += (index < (self.QuickControls.size - 1)) ? "[{" + btn + "}] & " : "[{" + btn + "}]";

                            str += ": Open Quick Menu";
                        }
                    }
                    else
                    {
                        str = "[{+attack}]/[{+speed_throw}]/[{+actionslot 1}]/[{+actionslot 2}]: Scroll\n[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right\n[{+activate}]: Select\n[{+melee}]: Go Back/Exit";
                    }
                }
                else
                {
                    str = self.instructionsString;
                }
            }
            else
            {
                str = self isInMenu(true) ? "[{+attack}]/[{+speed_throw}]: Scroll\n[{+actionslot 3}]/[{+actionslot 4}]: Slider Left/Right\n[{+activate}]: Select\n[{+gostand}]: Exit" : "[{+speed_throw}] & [{+gostand}]: Open Quick Menu";
            }
            
            if(self.menuInstructionsUI["string"].text != str)
                self.menuInstructionsUI["string"] SetTextString(str);
            
            self SetInstructionsPosition(str);
        }

        wait 0.1;
    }

    if(Is_True(self.MenuInstructionsDisplay))
        self.MenuInstructionsDisplay = BoolVar(self.MenuInstructionsDisplay);
    
    self DestroyInstructions();
}

SetInstructionsPosition(str)
{
    if(!IsDefined(self.menuInstructionsUI) || !IsDefined(self.menuInstructionsUI["string"]) || !IsDefined(self.menuInstructionsUI["background"]))
        return;
    
    switch(self.MenuDesign)
    {
        case "Classic":
            yOffset = 5;
            xOffset = 0;
            widthOffset = 0;
            break;
        
        case "AIO":
            yOffset = 30;
            xOffset = -1;
            widthOffset = 2;
            break;
        
        case "Native":
            yOffset = 5;
            xOffset = 1;
            widthOffset = -2;
            break;
        
        default:
            yOffset = 18;
            xOffset = 1;
            widthOffset = -2;
            break;
    }

    width = self.menuInstructionsUI["string"] GetTextWidth3arc(self);
    height = IsSubStr(str, "\n") ? (CorrectNL_BGHeight(str) - 5) : CorrectNL_BGHeight(str);

    if(self isInMenu(true) && Is_True(self.AdaptiveMenuInstructions))
    {
        menuWidth = (IsDefined(self.menuUI) && IsDefined(self.menuUI["background"])) ? (self.menuUI["background"].width + widthOffset) : (self.MenuWidth + widthOffset);

        if(width < menuWidth)
            width = menuWidth;
    }
    
    if(self.menuInstructionsUI["background"].width != width || self.menuInstructionsUI["background"].height != height)
    {
        self.menuInstructionsUI["background"] SetShaderValues(undefined, width, height);
        self.menuInstructionsUI["outline"] SetShaderValues(undefined, (width + 2), (height + 2));
    }

    if(Is_True(self.RepositionMenuInstructions))
        return;

    xPos = (self isInMenu(true) && Is_True(self.AdaptiveMenuInstructions)) ? (IsDefined(self.menuUI) && IsDefined(self.menuUI["background"])) ? (self.menuUI["background"].x + xOffset) : (self.menuX + xOffset) : self.instructionsX;
    yPos = (self isInMenu(true) && Is_True(self.AdaptiveMenuInstructions) && IsDefined(self.menuUI) && IsDefined(self.menuUI["background"])) ? ((self.menuUI["background"].y + self.menuUI["background"].height) + yOffset) : (self.instructionsY - height);

    if(self.menuInstructionsUI["background"].y != yPos)
    {
        self.menuInstructionsUI["background"].y = yPos;
        self.menuInstructionsUI["outline"].y = (yPos - 1);
        self.menuInstructionsUI["string"].y = (yPos + 6);
    }

    if(self.menuInstructionsUI["background"].x != xPos)
    {
        self.menuInstructionsUI["background"].x = xPos;
        self.menuInstructionsUI["outline"].x = (xPos - 1);
        self.menuInstructionsUI["string"].x = (xPos + 1);
    }
}

DestroyInstructions()
{
    if(!IsDefined(self.menuInstructionsUI))
        return;
    
    if(IsDefined(self.menuInstructionsUI["string"]))
        self.menuInstructionsUI["string"] DestroyHud();

    if(IsDefined(self.menuInstructionsUI["background"]))
        self.menuInstructionsUI["background"] DestroyHud();
    
    if(IsDefined(self.menuInstructionsUI["outline"]))
        self.menuInstructionsUI["outline"] DestroyHud();
    
    self.menuInstructionsUI = undefined;
}

SetMenuInstructions(text)
{
    self.instructionsString = (!IsDefined(text) || text == "") ? undefined : text;
}