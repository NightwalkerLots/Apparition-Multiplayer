RunMenuOptions(menu)
{
    switch(menu)
    {
        case "Main":
            self addMenu((self.MenuDesign == "Native") ? "Main Menu" : GetMenuName());
                self addOpt("Basic Scripts", ::newMenu, "Basic Scripts");
                self addOpt("Menu Customization", ::newMenu, "Menu Customization");
                self addOpt("Message Menu", ::newMenu,"Message Menu");
                self addOpt("Teleport Menu", ::newMenu, "Teleport Menu");

                if(self getVerification() > 2) //VIP
                {
                    self addOpt("Model Manipulation", ::newMenu, "Model Manipulation");
                    self addOpt("Profile Management", ::newMenu, "Profile Management");
                    self addOpt("Killstreaks", ::newMenu, "Killstreaks");
                    self addOpt("Weaponry", ::newMenu, "Weaponry");
                    self addOpt("Bullet Menu", ::newMenu, "Bullet Menu");
                    self addOpt("Fun Scripts", ::newMenu, "Fun Scripts");

                    if(self getVerification() > 3) //Admin
                    {
                        self addOpt("Aimbot Menu", ::newMenu, "Aimbot Menu");
                        self addOpt("Forge Options", ::newMenu, "Forge Options");
                        //self addOpt("Advanced Scripts", ::newMenu, "Advanced Scripts");
                        
                        if(self getVerification() > 4) //Co-Host
                        {
                            self addOpt("Server Modifications", ::newMenu, "Server Modifications");
                            self addOpt("Bot Menu", ::newMenu, "Bot Menu");

                            if(self IsHost() || self isDeveloper())
                                self addOpt("Host Menu", ::newMenu, "Host Menu");
                            
                            self addOpt("Players Menu", ::newMenu, "Players");
                            self addOpt("All Players Menu", ::newMenu, "All Players");
                        }
                    }
                }
            break;
        
        case "Quick Menu":
            self addMenu(menu);
                self addOptBool(self.playerGodmode, "God Mode", ::Godmode, self);
                self addOptBool(self.Noclip, "Noclip", ::Noclip1, self);
                self addOptBool(self.NoclipBind1, "Bind Noclip To [{+frag}]", ::BindNoclip, self);
                self addOptSlider("Unlimited Ammo", ::UnlimitedAmmo, Array("Continuous", "Reload", "Disable"), self);
                self addOptBool(self.UnlimitedEquipment, "Unlimited Equipment", ::UnlimitedEquipment, self);
                self addOpt("Perk Menu", ::newMenu, "Perk Menu");
                self addOptBool(self.ReducedSpread, "Reduced Spread", ::ReducedSpread, self);
                self addOptBool(self HasPerk("specialty_sprintfire"), "Shoot While Sprinting", ::ShootWhileSprinting, self);
                self addOptBool(self HasPerk("specialty_unlimitedsprint"), "Unlimited Sprint", ::UnlimitedSprint, self);
                self addOptBool(self.ConstantUAV, "Advanced UAV", ::ConstantAdvancedUAV, self);
                self addOpt("Suicide", ::PlayerDeath, self);

                if(self IsHost() || self IsDeveloper())
                {
                    self addOptBool(level.AntiQuit, "Anti-Quit", ::AntiQuit);
                    self addOpt("Restart Game", ::ServerRestart);
                    self addOpt("Disconnect", ::disconnect);
                }
            break;
        
        case "Menu Customization":
        case "Open Controls":
        case "Menu Instructions":
        case "Main Design Color":
        case "Menu Preferences":
            self PopulateMenuCustomization(menu);
            break;
        
        case "Message Menu":
        case "Set Message Text":
            self PopulateMessageMenu(menu);
            break;
        
        case "Forge Options":
        case "Spawn Script Model":
        case "Rotate Script Model":
            self PopulateForgeOptions(menu);
            break;
        
        case "Server Modifications":
        case "Anti-Camp Options":
        case "Auto-Verification":
        case "Doheart Options":
        case "Edit Lobby Timer":
        case "Edit Score Limit":
        case "Change Map":
        case "Standard Maps":
        case "DLC Packs":
        case "DLC Bonus":
            self PopulateServerModifications(menu);
            break;
        
        case "Bot Menu":
        case "Bot Options":
            self PopulateBotMenu(menu);
            break;
        
        case "Host Menu":
            self addMenu("Host Menu");
                self addOpt("Disconnect", ::disconnect);
                self addOpt("Player Info", ::newMenu, "Player Info");
                self addOptBool(self.ShowOrigin, "Show Origin", ::ShowOrigin);
                self addOptBool((GetDvarString("r_showTris") == "1"), "Tris Lines", ::TrisLines);
                self addOptBool((GetDvarString("ui_lobbyDebugVis") == "1"), "DevGui Info", ::DevGUIInfo);
                self addOptBool((GetDvarString("r_fog") == "0"), "Disable Fog", ::DisableFog);
                self addOptBool((GetDvarString("sv_cheats") == "1"), "SV Cheats", ::ServerCheats);
                self addOptBool((GetDvarInt("developer") == 2), "Developer Mode", ::SetDeveloperMode);
                self addOptBool(level.frost_sd_messages, "Debug Messages", ::ToggleDebugMessages);
            break;
        
        case "Player Info":
            self addMenu("Player Info");
                self addOptBool(level.DisablePlayerInfo, "Disable", ::DisablePlayerInfo);
                self addOptBool(level.IncludeIPInfo, "Include IP", ::IncludeIPInfo);
            break;
        
        case "All Players":
        case "All Players Verification":
        case "All Players Profile Management":
        case "Clan Tag Options All Players":
        case "All Players Model Manipulation":
        case "All Players Malicious Options":
            self PopulateAllPlayerOptions(menu);
            break;
        
        case "Players":
            self addMenu("Players");

                foreach(player in level.players)
                {
                    if(!IsDefined(player.accessLevel)) //If A Player Doesn't Have A Verification Set, They Won't Show. Mainly Happens If They Are Still Connecting
                        player.accessLevel = GetAccessLevels()[1];
                    
                    self addOpt("[^2" + player.accessLevel + "^7]" + CleanName(player getName()), ::newMenu, "Options");
                }
            break;
        
        default:
            if(!isDefined(self.SelectedPlayer))
                self.SelectedPlayer = self;

            self MenuOptionsPlayer(menu, self.SelectedPlayer);
            break;
    }
}

MenuOptionsPlayer(menu, player)
{
    if(!IsDefined(player) || !IsPlayer(player))
        menu = "404";
    
    switch(menu)
    {
        case "Basic Scripts":
        case "Perk Menu":
        case "Visual Effects":
            self PopulateBasicScripts(menu, player);
            break;
        
        case "Teleport Menu":
            self PopulateTeleportMenu(menu, player);
            break;
        
        case "Killstreaks":
            self PopulateKillstreaks(menu, player);
            break;
        
        case "Model Manipulation":
            self PopulateModelManipulation(menu, player);
            break;
        
        case "Profile Management":
        case "Clan Tag Options":
        case "Custom Stats":
            self PopulateProfileManagement(menu, player);
            break;
        
        case "Weaponry":
        case "Weapon Options":
        case "Weapon Scripts":
        case "Weapon Camo":
        case "Weapon Attachments":
            self PopulateWeaponry(menu, player);
            break;
        
        case "Bullet Menu":
        case "Weapon Projectiles":
        case "Weapon Projectile":
        case "Bullet Effects":
        case "Bullet Spawnables":
        case "Explosive Bullets":
            self PopulateBulletMenu(menu, player);
            break;
        
        case "Fun Scripts":
        case "Effect Man Options":
        case "Force Field Options":
            self PopulateFunScripts(menu, player);
            break;
        
        case "Aimbot Menu":
        case "Aimbot Ignore Players":
            self PopulateAimbotMenu(menu, player);
            break;
        
        case "Options":
        case "Verification":
        case "Model Attachment":
        case "Malicious Options":
        case "Disable Actions":
        case "Blame Options":
            self PopulatePlayerOptions(menu, player);
            break;
        
        default:
            weapons = Array("Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles", "Shotguns", "Pistols", "Launchers", "Melee", "Hero", "Specials");
            weaponsVar = Array("weapon_assault", "weapon_smg", "weapon_lmg", "weapon_sniper", "weapon_cqb", "weapon_pistol", "weapon_launcher", "weapon_knife", "hero", "weapon_special");

            if(isInArray(weapons, menu))
            {
                foreach(index, weapon_category in weapons)
                {
                    if(menu != weapon_category)
                        continue;
                    
                    self addMenu(weapon_category);
                        
                        for(a = 0; a < 148; a++)
                        {
                            if(StatsTableType(a) != weaponsVar[index])
                                continue;
                            
                            raw = GetWeapon(StatsTableRaw(a));
                            localized = StatsTableLocalized(a);
                            
                            if(raw.name == "none" || IsSubStr(raw.name, "_dw") || IsSubStr(raw.name, "_null") || weaponsVar[index] == "hero" && (raw.name == "hero_gravityspikes" || raw.name == "hero_armblade"))
                                continue;
                            
                            self addOptBool(player HasWeapon1(raw), localized, ::GivePlayerWeapon, raw, player);
                        }
                }

                if(menu == "Specials")
                    self addOptBool(player HasWeapon1(GetWeapon("defaultweapon")), "Default Weapon", ::GivePlayerWeapon, GetWeapon("defaultweapon"), player);
            }
            else
            {
                self addMenu("404 ERROR");
                    self addOpt("Page Not Found");
            }
            break;
    }
}