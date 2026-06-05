PopulateProfileManagement(menu, player)
{
    switch(menu)
    {
        case "Profile Management":
            self addMenu("Profile Management");
                self addOptBool(player.CryptoKeysLoop, "Crypto Keys", ::CryptoKeysLoop, player);
                self addOpt("Complete All Challenges", ::AllChallenges, player);
                self addOptSlider("Weapon Ranks", ::PlayerWeaponRanks, Array("Max", "Reset"), player);
                self addOptIncSlider("Rank", ::SetPlayerRank, (player GetDStat("PlayerStatsList", "plevel", "StatValue") == 11) ? 36 : 1, (player GetDStat("PlayerStatsList", "plevel", "StatValue") == level.maxprestige) ? 36 : 1, (player GetDStat("PlayerStatsList", "plevel", "StatValue") == 11) ? 1000 : 35, 1, player);
                self addOptIncSlider("Prestige", ::SetPlayerPrestige, 0, player GetDStat("PlayerStatsList", "plevel", "StatValue"), (player GetDStat("PlayerStatsList", "plevel", "StatValue") == 10) ? 11 : 10, 1, player);
                self addOpt("Unlock All Achievements", ::UnlockAchievements, player);
                self addOpt("Clan Tag Options", ::newMenu, "Clan Tag Options");
                self addOpt("Custom Stats", ::newMenu, "Custom Stats");
            break;
        
        case "Clan Tag Options":
            self addMenu("Clan Tag Options");
                self addOpt("Reset", ::SetClanTag, "", player);
                self addOpt("Invisible Name", ::SetClanTag, "^H?", player);
                self addOpt("@CF4", ::SetClanTag, "@CF4", player);
                self addOpt("@cid", ::SetClanTag, "@cid", player);
                self addOptSlider("Name Color", ::SetClanTag, Array("Black", "Red", "Green", "Yellow", "Blue", "Cyan", "Pink"), player);
                self addOpt("Custom", ::Keyboard, ::SetClanTag, player);
            break;
        
        case "Custom Stats":
            if(!IsDefined(player.CustomStatsValue))
                player.CustomStatsValue = 0;
            
            if(!IsDefined(player.CustomStatsArray))
                player.CustomStatsArray = [];
            
            self addMenu("Custom Stats");
                self addOpt("Clear Selected Stats", ::ClearCustomStats, player);
                self addOpt("Custom Value: " + Int(player.CustomStatsValue), ::NumberPad, ::CustomStatsValue, player);
                self addOpt("Send Selected Stats", ::SetCustomStats, player);
                self addOpt("");

                stats = Array("kills", "headshots", "deaths", "total_shots", "hits", "misses", "total_games_played", "time_played_total");

                for(a = 0; a < stats.size; a++)
                    self addOptBool(isInArray(player.CustomStatsArray, stats[a]), CleanString(stats[a]), ::AddToCustomStats, stats[a], player);
            break;
    }
}

CryptoKeysLoop(player)
{
    player endon("disconnect");

    player.CryptoKeysLoop = BoolVar(player.CryptoKeysLoop);

    if(Is_True(player.CryptoKeysLoop))
    {
        reports = 0;
        
        while(Is_True(player.CryptoKeysLoop))
        {
            player ReportLootReward(1, 255);
            player SetAARStat("lootXpEarned", 255);

            reports += 200;

            if(reports % 2000)
                player iPrintlnBold(reports + " ^BBUTTON_CRYPTO_KEY_ICON^ Reported");

            wait 0.1;
        }
    }
}

GatherChallengeStats()
{
    if(IsDefined(level.challengeStats))
        return;
    
    level.challengeStats = [];
    logChallenges = [];
    
    for(a = 1; a < 7; a++)
    {
        switch(a)
        {
            case 1:
                start = 1;
                end = 239;
                break;
            
            case 2:
                start = 256;
                end = 483;
                break;
            
            case 3:
                start = 512;
                end = 767;
                break;
            
            case 4:
                start = 768;
                end = 929;
                break;
            
            case 5:
                start = 1024;
                end = 1494;
                break;
            
            case 6:
                start = 1500;
                end = 1515;
                break;
            
            default:
                start = 0;
                end = 0;
                break;
        }
        
        for(value = start; value < end; value++)
        {
            stat = SpawnStruct();
            stat.value = Int(TableLookup("gamedata/stats/mp/statsmilestones" + a + ".csv", 0, value, 2));
            stat.type = TableLookup("gamedata/stats/mp/statsmilestones" + a + ".csv", 0, value, 3);
            stat.name = TableLookup("gamedata/stats/mp/statsmilestones" + a + ".csv", 0, value, 4);
            stat.split = TableLookup("gamedata/stats/mp/statsmilestones" + a + ".csv", 0, value, 13);
            
            if(!IsDefined(stat.value) || !stat.value || !IsDefined(stat.name))
                continue;
            
            if(!IsDefined(logChallenges[stat.type + "_" + stat.name]) || IsDefined(logChallenges[stat.type + "_" + stat.name]) && stat.value > logChallenges[stat.type + "_" + stat.name].value)
                logChallenges[stat.type + "_" + stat.name] = stat;
        }
    }
    
    foreach(index, key in GetArrayKeys(logChallenges))
        level.challengeStats[index] = logChallenges[key];
}

AllChallenges(player)
{
    if(Is_True(player.AllChallenges))
        return;
    
    if(!IsDefined(level.challengeStats))
        GatherChallengeStats();

    player.AllChallenges = true;
    modifiedStats = 0;
    
    player endon("disconnect");
 
    if(player != self)
    {
        self iPrintln("^2" + CleanName(player getName()) + ":^7 Complete All Challenges ^2Started");
        self iPrintln("You'll Be Notified When Complete");
    }
    
    player iPrintln("Complete All Challenges ^2Started");
    player iPrintln("You'll Be Notified When Complete");
    
    heroes = ["heroes_mercenary", "heroes_outrider", "heroes_technomancer", "heroes_battery", "heroes_enforcer", "heroes_trapper", "heroes_reaper", "heroes_spectre", "heroes_firebreak"];
    hero_weapons = ["HERO_MINIGUN", "HERO_LIGHTNINGGUN", "HERO_GRAVITYSPIKES", "HERO_ARMBLADE", "HERO_ANNIHILATOR", "HERO_PINEAPPLEGUN", "HERO_BOWLAUNCHER", "HERO_CHEMICALGELGUN", "HERO_FLAMETHROWER"];
    
    for(a = 0; a < level.challengeStats.size; a++)
    {
        switch(level.challengeStats[a].type)
        {
            case "global":
                if(player GetDStat("PlayerStatsList", level.challengeStats[a].name, "StatValue") < level.challengeStats[a].value)
                {
                    player SetDStat("PlayerStatsList", level.challengeStats[a].name, "StatValue", level.challengeStats[a].value);
                    player SetDStat("PlayerStatsList", level.challengeStats[a].name, "ChallengeValue", level.challengeStats[a].value);
                    
                    modifiedStats += 2;
                    wait 0.5;
                }
                break;
            
            case "killstreak":
                foreach(streak in StrTok(level.challengeStats[a].split + " killstreak_autoturret killstreak_helicopter_gunner", " "))
                {
                    self AddWeaponStat(level.killstreaks[GetSubStr(streak, 11)].weapon, level.challengeStats[a].name, level.challengeStats[a].value);
                    modifiedStats++;
                    wait 0.5;
                }
                break;

            case "attachment":
                foreach(token in StrTok(level.challengeStats[a].split, " "))
                {
                    if(player GetDStat("attachments", token, "stats", level.challengeStats[a].name, "StatValue") < level.challengeStats[a].value)
                    {
                        player SetDStat("attachments", token, "stats", level.challengeStats[a].name, "StatValue", level.challengeStats[a].value);
                        player SetDStat("attachments", token, "stats", level.challengeStats[a].name, "ChallengeValue", level.challengeStats[a].value);
                        
                        modifiedStats += 2;
                        wait 0.5;
                    }
                    
                    for(b = 1; b < 8; b++)
                    {
                        if(player GetDStat("attachments", token, "stats", "challenge" + b, "StatValue") < level.challengeStats[a].value)
                            continue;
                        
                        player SetDStat("attachments", token, "stats", "challenge" + b, "StatValue", level.challengeStats[a].value);
                        player SetDStat("attachments", token, "stats", "challenge" + b, "ChallengeValue", level.challengeStats[a].value);
                        
                        modifiedStats += 2;
                        wait 0.5;
                    }
                }
                break;
            
            case "group":
                foreach(token in StrTok(level.challengeStats[a].split, " "))
                {
                    if(player GetDStat("GroupStats", token, "stats", level.challengeStats[a].name, "StatValue") < level.challengeStats[a].value)
                        continue;
                    
                    player SetDStat("GroupStats", token, "stats", level.challengeStats[a].name, "StatValue", level.challengeStats[a].value);
                    player SetDStat("GroupStats", token, "stats", level.challengeStats[a].name, "ChallengeValue", level.challengeStats[a].value);
                    
                    modifiedStats += 2;
                    wait 0.5;
                }
                break;
            
            case "gamemode":
                foreach(token in StrTok(level.challengeStats[a].split, " "))
                {
                    if(player GetDStat("PlayerStatsByGameType", token, level.challengeStats[a].name, "StatValue") < level.challengeStats[a].value)
                        continue;
                    
                    player SetDStat("PlayerStatsByGameType", token, level.challengeStats[a].name, "StatValue", level.challengeStats[a].value);
                    player SetDStat("PlayerStatsByGameType", token, level.challengeStats[a].name, "ChallengeValue", level.challengeStats[a].value);
                    
                    modifiedStats += 2;
                    wait 0.5;
                }
                break;
            
            case "specialist":
                foreach(token in StrTok(level.challengeStats[a].split, " "))
                {
                    if(player GetDStat("specialiststats", GetIndexFromName(token, heroes), "stats", token, level.challengeStats[a].name, "StatValue") < level.challengeStats[a].value)
                        continue;
                    
                    player SetDStat("specialiststats", GetIndexFromName(token, heroes), "stats", level.challengeStats[a].name, "StatValue", level.challengeStats[a].value);
                    player SetDStat("specialiststats", GetIndexFromName(token, heroes), "stats", level.challengeStats[a].name, "ChallengeValue", level.challengeStats[a].value);
                    
                    modifiedStats += 2;
                    wait 0.5;
                }
                
                foreach(hero_weapon in hero_weapons)
                {
                    self AddWeaponStat(GetWeapon(hero_weapon), level.challengeStats[a].name, level.challengeStats[a].value);
                    self AddWeaponStat(GetWeapon(hero_weapon), "used", level.challengeStats[a].value);
                    
                    modifiedStats += 2;
                    wait 0.5;
                }
                break;
            
            case "hero":
                break;
            
            case "bonuscard":
                for(b = 178; b < 188; b++)
                {
                    if(player GetDStat("itemstats", b, "stats", level.challengeStats[a].name, "StatValue") < 300)
                        continue;
                    
                    self SetDStat("itemstats", b, "stats", level.challengeStats[a].name, "StatValue", 300);
                    self SetDStat("itemstats", b, "stats", level.challengeStats[a].name, "ChallengeValue", 300);
                    
                    modifiedStats += 2;
                    wait 0.5;
                }
                break;
            
            default:
                if(IsDefined(level.challengeStats[a].split) && IsSubStr(level.challengeStats[a].type, "weapon_"))
                {
                    foreach(token in StrTok(level.challengeStats[a].split, " "))
                    {
                        player AddWeaponStat(GetWeapon(token), level.challengeStats[a].name, level.challengeStats[a].value);
                        index = GetBaseWeaponItemIndex(GetWeapon(token));

                        for(i = 0; i < 3; i++)
                            player SetDStat("itemstats", index, "isproversionunlocked", i, 1);
                        
                        modifiedStats++;
                        wait 0.5;
                    }
                }
                break;
        }
        
        if(modifiedStats >= 25)
        {
            wait 1;
            UploadStats(player);
            modifiedStats = 0;
        }
        
        player iPrintlnBold((a + 1) + "/" + level.challengeStats.size + " ^7Completed");
    }
    
    wait 1;
    UploadStats(player);
    
    player.AllChallenges = false;
    
    if(self != player)
        self iPrintlnBold("^2" + CleanName(player getName()) + ":^7 All Challenges ^2Completed");
    
    player iPrintlnBold("All Challenges ^2Completed");
}

GetIndexFromName(strng, arry)
{
    foreach(index, name in arry)
    {
        if(name == strng)
            return index;
    }
    
    return;
}

UnlockAchievements(player)
{
    achievements = Array("CP_COMPLETE_PROLOGUE", "CP_COMPLETE_NEWWORLD", "CP_COMPLETE_BLACKSTATION", "CP_COMPLETE_BIODOMES", "CP_COMPLETE_SGEN", "CP_COMPLETE_VENGEANCE", "CP_COMPLETE_RAMSES", "CP_COMPLETE_INFECTION", "CP_COMPLETE_AQUIFER", "CP_COMPLETE_LOTUS", "CP_HARD_COMPLETE", "CP_REALISTIC_COMPLETE", "CP_CAMPAIGN_COMPLETE", "CP_FIREFLIES_KILL", "CP_UNSTOPPABLE_KILL", "CP_FLYING_WASP_KILL", "CP_TIMED_KILL", "CP_ALL_COLLECTIBLES", "CP_DIFFERENT_GUN_KILL", "CP_ALL_DECORATIONS", "CP_ALL_WEAPON_CAMOS", "CP_CONTROL_QUAD", "CP_MISSION_COLLECTIBLES", "CP_DISTANCE_KILL", "CP_OBSTRUCTED_KILL", "CP_MELEE_COMBO_KILL", "CP_COMPLETE_WALL_RUN", "CP_TRAINING_GOLD", "CP_COMBAT_ROBOT_KILL", "CP_KILL_WASPS", "CP_CYBERCORE_UPGRADE", "CP_ALL_WEAPON_ATTACHMENTS", "CP_TIMED_STUNNED_KILL", "CP_UNLOCK_DOA", "ZM_COMPLETE_RITUALS", "ZM_SPOT_SHADOWMAN", "ZM_GOBBLE_GUM", "ZM_STORE_KILL", "ZM_ROCKET_SHIELD_KILL", "ZM_CIVIL_PROTECTOR", "ZM_WINE_GRENADE_KILL", "ZM_MARGWA_KILL", "ZM_PARASITE_KILL", "MP_REACH_SERGEANT", "MP_REACH_ARENA", "MP_SPECIALIST_MEDALS", "MP_MULTI_KILL_MEDALS", "ZM_CASTLE_EE", "ZM_CASTLE_ALL_BOWS", "ZM_CASTLE_MINIGUN_MURDER", "ZM_CASTLE_UPGRADED_BOW", "ZM_CASTLE_MECH_TRAPPER", "ZM_CASTLE_SPIKE_REVIVE", "ZM_CASTLE_WALL_RUNNER", "ZM_CASTLE_ELECTROCUTIONER", "ZM_CASTLE_WUNDER_TOURIST", "ZM_CASTLE_WUNDER_SNIPER", "ZM_ISLAND_COMPLETE_EE", "ZM_ISLAND_DRINK_WINE", "ZM_ISLAND_CLONE_REVIVE", "ZM_ISLAND_OBTAIN_SKULL", "ZM_ISLAND_WONDER_KILL", "ZM_ISLAND_STAY_UNDERWATER", "ZM_ISLAND_THRASHER_RESCUE", "ZM_ISLAND_ELECTRIC_SHIELD", "ZM_ISLAND_DESTROY_WEBS", "ZM_ISLAND_EAT_FRUIT", "ZM_STALINGRAD_NIKOLAI", "ZM_STALINGRAD_WIELD_DRAGON", "ZM_STALINGRAD_TWENTY_ROUNDS", "ZM_STALINGRAD_RIDE_DRAGON", "ZM_STALINGRAD_LOCKDOWN", "ZM_STALINGRAD_SOLO_TRIALS", "ZM_STALINGRAD_BEAM_KILL", "ZM_STALINGRAD_STRIKE_DRAGON", "ZM_STALINGRAD_FAFNIR_KILL", "ZM_STALINGRAD_AIR_ZOMBIES", "ZM_GENESIS_EE", "ZM_GENESIS_SUPER_EE", "ZM_GENESIS_PACKECTOMY", "ZM_GENESIS_KEEPER_ASSIST", "ZM_GENESIS_DEATH_RAY", "ZM_GENESIS_GRAND_TOUR", "ZM_GENESIS_WARDROBE_CHANGE", "ZM_GENESIS_WONDERFUL", "ZM_GENESIS_CONTROLLED_CHAOS", "DLC2_ZOMBIE_ALL_TRAPS", "DLC2_ZOM_LUNARLANDERS", "DLC2_ZOM_FIREMONKEY", "DLC4_ZOM_TEMPLE_SIDEQUEST", "DLC4_ZOM_SMALL_CONSOLATION", "DLC5_ZOM_CRYOGENIC_PARTY", "DLC5_ZOM_GROUND_CONTROL", "ZM_DLC4_TOMB_SIDEQUEST", "ZM_DLC4_OVERACHIEVER", "ZM_PROTOTYPE_I_SAID_WERE_CLOSED", "ZM_ASYLUM_ACTED_ALONE", "ZM_THEATER_IVE_SEEN_SOME_THINGS");
    
    for(a = 0; a < achievements.size; a++)
        player GiveAchievement(achievements[a]);
}

SetClanTag(tag, player)
{
    switch(tag)
    {
        case "Black":
            tag = "^0";
            break;
        
        case "Red":
            tag = "^1";
            break;
        
        case "Green":
            tag = "^2";
            break;
        
        case "Yellow":
            tag = "^3";
            break;
        
        case "Blue":
            tag = "^4";
            break;
        
        case "Cyan":
            tag = "^5";
            break;
        
        case "Pink":
            tag = "^6";
            break;
        
        default:
            break;
    }
    
    player SetDStat("clanTagStats", "clanName", tag);
}

ClearCustomStats(player)
{
    player.CustomStatsArray = [];
}

CustomStatsValue(value, player)
{
    player.CustomStatsValue = value;
}

AddToCustomStats(stat, player)
{
    if(!IsDefined(player.CustomStatsArray))
        player.CustomStatsArray = [];
    
    if(isInArray(player.CustomStatsArray, stat))
        player.CustomStatsArray = ArrayRemove(player.CustomStatsArray, stat);
    else
        player.CustomStatsArray[player.CustomStatsArray.size] = stat;
}

SetCustomStats(player)
{
    if(!IsDefined(player.CustomStatsArray) || !player.CustomStatsArray.size)
        return self iPrintlnBold("^1ERROR: ^7No Stats Have Been Selected");
    
    player endon("disconnect");
    
    for(a = 0; a < player.CustomStatsArray.size; a++)
        player SetDStat("PlayerStatsList", player.CustomStatsArray[a], "StatValue", player.CustomStatsValue);
    
    wait 0.1;
    UploadStats(player);
}

SetPlayerPrestige(prestige, player)
{
    player endon("disconnect");

    menu = self getCurrent();
    curs = self getCursor();

    player SetDStat("PlayerStatsList", "plevel", "StatValue", prestige);
    player SetRank(player rank::getRankForXp(player rank::getRankXP()), player GetDStat("PlayerStatsList", "plevel", "StatValue"));

    wait 0.1;
    RefreshMenu(menu, curs);
    UploadStats(player);
}

SetPlayerRank(rank, player)
{
    player endon("disconnect");

    stat = (rank > 35) ? "paragon_rankxp" : "rankxp";
    rtnColumn = (rank == 35 || rank == 1000) ? 7 : 2;
    value = (rank > 35) ? Int(TableLookup("gamedata/tables/mp/mp_paragonranktable.csv", 13, rank, rtnColumn)) : Int(TableLookup("gamedata/tables/mp/mp_ranktable.csv", 0, (rank - 1), rtnColumn));
    
    player AddRankXPValue("win", (value - player GetDStat("PlayerStatsList", stat, "StatValue")));
    
    wait 0.1;
    UploadStats(player);
}

PlayerWeaponRanks(type, player)
{
    if(Is_True(player.PlayerWeaponRanks))
        return;
    player.PlayerWeaponRanks = true;

    player endon("disconnect");

    for(a = 0; a < 148; a++)
    {
        class = TableLookup("gamedata/stats/mp/mp_statstable.csv", 0, a, 2);
        
        if(!IsSubStr(class, "weapon_"))
            continue;
        
        weapon = TableLookup("gamedata/stats/mp/mp_statstable.csv", 0, a, 4);
        
        player SetDStat("ItemStats", GetBaseWeaponItemIndex(GetWeapon(weapon)), "xp", (type == "Max") ? 665535 : 0);
        player SetDStat("ItemStats", GetBaseWeaponItemIndex(GetWeapon(weapon)), "plevel", (type == "Max") ? 2 : 0);
    }

    wait 0.1;
    UploadStats(player);
    player.PlayerWeaponRanks = false;
    player iPrintln("Weapon Ranks ^2" + type);
}