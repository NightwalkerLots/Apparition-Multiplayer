onPlayerDisconnect()
{
    if(self IsHost())
        return;
    
    foreach(player in level.players)
    {
        if(!IsDefined(player) || !IsPlayer(player) || player == self || !player hasMenu())
            continue;
        
        //If a player is navigating another players options, and that player disconnects, it will kick them back to the player menu
        if(IsDefined(player.menu_parent) && isInArray(player.menu_parent, "Players") && player.SelectedPlayer == self)
        {
            openMenu = player isInMenu(false);

            if(openMenu)
                player thread closeMenu1();
            
            player.menu_parent = [];
            player.currentMenu = "Players";
            player.menu_parent[player.menu_parent.size] = "Main";

            if(openMenu)
            {
                player thread openMenu1();
                player iPrintlnBold("^1ERROR: ^7Player Has Disconnected");
            }
        }
        else if(player isInMenu() && player getCurrent() == "Players") //If a player is viewing the player menu when a player disconnects, it will refresh the player list
        {
            player RefreshMenu();
        }
    }
}