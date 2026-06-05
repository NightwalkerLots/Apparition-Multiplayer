PopulateKillstreaks(menu, player)
{
    switch(menu)
    {
        case "Killstreaks":
            self addMenu("Killstreaks");
                
                for(a = 196; a < 227; a++)
                {
                    if(StatsTableType(a) != "killstreak")
                        continue;
                    
                    raw = GetRawKillstreakName(StatsTableRaw(a));
                    type = StatsTableKillstreakType(a);

                    if(!IsDefined(raw) || IsDefined(raw) && IsSubStr(raw, "_null") || type != 0)
                        continue;

                    self addOpt(StatsTableLocalized(a), ::GivePlayerKillstreak, raw, player);
                }
            break;
    }
}
GivePlayerKillstreak(streak, player)
{
    result = player killstreaks::give_internal(streak);

    if(!result)
        self iPrintln("^1ERROR: ^7Could Not Give Kilstreak");
}

GetRawKillstreakName(killstreak)
{
    streaks = GetArrayKeys(level.killstreaks);

    foreach(streak in streaks)
    {
        if(!IsDefined(level.killstreaks[streak]) || level.killstreaks[streak].menuname || IsSubStr(streak, "_null") || IsSubStr(streak, "inventory_"))
            continue;
        
        if(level.killstreaks[streak].menuname != killstreak)
            continue;
        
        return streak;
    }

    return undefined;
}