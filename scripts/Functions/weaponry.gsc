PopulateWeaponry(menu, player)
{
    switch(menu)
    {
        case "Weaponry":
            weapons = Array("Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles", "Shotguns", "Pistols", "Launchers", "Melee", "Hero", "Specials");

            self addMenu("Weaponry");
                self addOpt("Weapon Options", ::newMenu, "Weapon Options");
                self addOpt("Attachments", ::newMenu, "Weapon Attachments");
                self addOpt("Camo", ::newMenu, "Weapon Camo");
                self addOpt("");

                for(a = 0; a < weapons.size; a++)
                    self addOpt(weapons[a], ::newMenu, weapons[a]);
            break;
        
        case "Weapon Options":
            self addMenu("Weapon Options");
                self addOpt("Take Current Weapon", ::TakeCurrentWeapon, player);
                self addOpt("Take All Weapons", ::TakePlayerWeapons, player);
                self addOptSlider("Drop Current Weapon", ::DropCurrentWeapon, Array("Take", "Don't Take"), player);
            break;
        
        case "Weapon Camo":
            self addMenu("Camo");
                self addOptBool(player.FlashingCamo, "Flashing Camo", ::FlashingCamo, player);
                self addOpt("");

                skip = Array(37, 72, 127, 128, 129, 130); //These are camos that aren't in the game anymore, so they will be skipped

                for(a = 0; a < 139; a++)
                {
                    if(isInArray(skip, a))
                        continue;
                    
                    self addOpt((ReturnCamoName((a + 45)) == "" || IsSubStr(ReturnCamoName((a + 45)), "PLACEHOLDER") || ReturnCamoName((a + 45)) == "MPUI_CAMO_LOOT_CONTRACT") ? CleanString(ReturnRawCamoName((a + 45))) : ReturnCamoName((a + 45)), ::SetPlayerCamo, a, player);
                }
            break;
        
        case "Weapon Attachments":
            weapon = player GetCurrentWeapon();
            attachments = [];

            if(IsDefined(weapon) && weapon != level.weaponnone)
            {
                for(a = 0; a < 44; a++)
                {
                    if(!isInArray(weapon.supportedAttachments, ReturnAttachment(a)) || ReturnAttachment(a) == "none")
                        continue;
                    
                    attachments[attachments.size] = ReturnAttachment(a);
                }
            }

            self addMenu("Attachments");

                if(attachments.size)
                {
                    weaponToks = StrTok(weapon.name, "_");

                    if(IsDefined(weaponToks[2]) && weaponToks[2] == "dw")
                    {
                        self addOptBool(weaponToks[2] == "dw", "Dual Wield", ::GivePlayerAttachment, "dw", player);
                        attachmentFound = 1;
                    }

                    foreach(attachment in attachments)
                        self addOptBool(isInArray(weapon.attachments, attachment), ReturnAttachmentName(attachment), ::GivePlayerAttachment, attachment, player);
                }
                else
                {
                    self addOpt("No Supported Attachments Found");
                }
            break;
    }
}

TakeCurrentWeapon(player)
{
    weapon = player GetCurrentWeapon();

    if(!IsDefined(weapon) || weapon == level.weaponnone || IsDefined(level.weaponbasemelee) && weapon == level.weaponbasemelee || IsSubStr(weapon.name, "_knife"))
        return;
    
    player TakeWeapon(weapon);
}

TakePlayerWeapons(player)
{
    foreach(weapon in player GetWeaponsList(1))
    {
        if(!IsDefined(weapon) || weapon == level.weaponnone || IsDefined(level.weaponbasemelee) && weapon == level.weaponbasemelee || IsSubStr(weapon.name, "_knife"))
            continue;
        
        player TakeWeapon(weapon);
    }
}

DropCurrentWeapon(type, player)
{
    weapon = player GetCurrentWeapon();
    clip = player GetWeaponAmmoClip(player GetCurrentWeapon());
    stock = player GetWeaponAmmoStock(player GetCurrentWeapon());

    player DropItem(weapon);

    if(type == "Don't Take")
    {
        player GiveWeapon(weapon);
        
        if(IsDefined(weapon.savedCamo))
            SetPlayerCamo(weapon.savedCamo, player);
        
        player SetWeaponAmmoClip(player GetCurrentWeapon(), clip);
        player SetWeaponAmmoStock(player GetCurrentWeapon(), stock);

        if(!IsSubStr(weapon.name, "_knife"))
            player SwitchToWeaponImmediate(weapon);
    }
}

GivePlayerAttachment(attachment, player)
{
    weapon = player GetCurrentWeapon();
    attachments = weapon.attachments;
    
    if(attachment == "dw")
    {
        tokens = StrTok(weapon.name, "_");
        baseWeapon = (tokens[2] == "dw") ? tokens[0] + "_" + tokens[1] : tokens[0] + "_" + tokens[1] + "_dw";
        newWeapon = GetWeapon(baseWeapon);
    }
    else
    {
        if(isInArray(attachments, attachment)) //If the weapon has the attachment, it will be removed
        {
            attachments = ArrayRemove(attachments, attachment);
        }
        else //If the weapon doesn't have the attachment, it will be added
        {
            if(!IsValidCombination(attachments, attachment))
            {
                invalid = GetInvalidAttachments(attachments, attachment);

                if(IsDefined(invalid) && invalid.size)
                {
                    for(a = 0; a < invalid.size; a++)
                        attachments = ArrayRemove(attachments, invalid[a]);
                }
            }
            
            array::add(attachments, attachment, 0);

            if(attachments.size > 8)
                return self iPrintlnBold("^1ERROR: ^7Attachment Limit Reached");
        }
        
        newWeapon = GetWeapon(weapon.rootweapon.name, attachments);
    }
    
    camo = 0;

    if(IsDefined(weapon.savedCamo))
        camo = weapon.savedCamo;
    
    weapon_options = player CalcWeaponOptions(camo, 0, 0);
    newWeapon.savedCamo = camo;
    
    player TakeWeapon(weapon);
    player GiveWeapon(newWeapon, weapon_options);
    player SetSpawnWeapon(newWeapon, true);
}

IsValidCombination(attachments, attachment)
{
    valid = ReturnAttachmentCombinations(attachment);
    tokens = StrTok(valid, " ");

    for(a = 0; a < attachments.size; a++)
    {
        if(!isInArray(tokens, attachments[a]))
            return false;
    }
    
    return true;
}

GetInvalidAttachments(attachments, attachment)
{
    valid = ReturnAttachmentCombinations(attachment);
    tokens = StrTok(valid, " ");

    invalid = [];

    for(a = 0; a < attachments.size; a++)
    {
        if(!isInArray(tokens, attachments[a]))
            array::add(invalid, attachments[a], 0);
    }
    
    return invalid;
}

CorrectInvalidCombo(player)
{
    player.CorrectInvalidCombo = BoolVar(player.CorrectInvalidCombo);
}

SetPlayerCamo(camo, player)
{
    weap = player GetCurrentWeapon();
    weapon = player CalcWeaponOptions(camo, 0, 0);
    NewWeapon = player GetBuildKitAttachmentCosmeticVariantIndexes(weap, false);
    
    player TakeWeapon(weap);
    player GiveWeapon(weap, weapon, NewWeapon);
    player SetSpawnWeapon(weap, true);

    weap.savedCamo = camo;
}

FlashingCamo(player)
{
    player endon("disconnect");

    player.FlashingCamo = BoolVar(player.FlashingCamo);

    while(Is_True(player.FlashingCamo))
    {
        if(!player IsMeleeing() && !player IsSwitchingWeapons() && !player IsReloading() && !player IsSprinting() && !player IsUsingOffhand() && player GetCurrentWeapon() != level.weaponnone)
            SetPlayerCamo(RandomInt(139), player);
        
        wait 0.25;
    }
}

GivePlayerWeapon(weapon, player)
{
    if(player HasWeapon1(weapon))
        return player TakeWeapon(weapon);

    if(player GetWeaponsListPrimaries().size > 2)
        player TakeWeapon(player GetCurrentWeapon());
    
    player GiveWeapon(weapon);
    player GiveStartAmmo(weapon);

    if(!IsSubStr(weapon.name, "_knife"))
        player SwitchToWeaponImmediate(weapon);
}

HasWeapon1(weapon)
{
    if(!IsDefined(weapon))
        return false;
    
    weapons = self GetWeaponsList(true);

    if(!IsDefined(weapons) || !weapons.size)
        return false;

    for(a = 0; a < weapons.size; a++)
    {
        if(weapons[a].rootweapon.name == weapon.rootweapon.name)
            return true;
    }

    return false;
}