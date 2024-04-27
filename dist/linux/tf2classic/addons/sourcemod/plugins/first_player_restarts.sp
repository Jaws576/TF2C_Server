#include <sourcemod>

#define MAX_MAPNANE_LENGTH 128
#define MAX_INT_STRING 6
#define PLUGIN_VERSION "1.2"

public Plugin:myinfo =
{
	name = "First Player Restarts Map",
	author = "Jaws",
	description = "Restarts map if server was empty and a player joins",
	version = PLUGIN_VERSION,
	url = "none"
};

new Handle:g_Cvar_Enable = INVALID_HANDLE; //Enable/Disable the plugin
new Handle:g_PlayerIDs; // Map with key/value pairs of all currently connected userids

new g_Players = 0;		// Total players connected. Doesn't include fake clients.

public OnPluginStart()
{
	SetConVarString(CreateConVar("empty_restarter_version", PLUGIN_VERSION, "version of Empty Server Map Restarter for TF2", FCVAR_SPONLY | FCVAR_NOTIFY | FCVAR_PLUGIN), PLUGIN_VERSION);
	g_Cvar_Enable = CreateConVar("sm_restart_empty_map", "1.0", "1 to enable plugin. Restarts map if server is empty", FCVAR_PLUGIN);
	//hooks the event player_disconnect which only happens when a player really disconnect, not when map changes
	HookEvent("player_disconnect", EventPlayerDisconnect, EventHookMode_Pre);
	g_PlayerIDs = CreateTrie();
}

public OnMapStart()
{
	/* Handle late load */
	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientConnected(i))
		{
			OnClientConnected(i);	
		}
	}
	
}

public OnMapEnd()
{
	
}

//Runs both when a player really connects and when a player reconnects after a mapchange
public OnClientConnected(client)
{
	decl String:index[MAX_INT_STRING];
	
	//filters out fake clients
	if(!client || IsFakeClient(client))
		return;
	
	IntToString(GetClientUserId(client),index,MAX_INT_STRING);

	if ((g_Players == 0))
	{
		LogToGame("Restarting the round, after server became non-empty");
		ServerCommand("mp_restartgame 1");
	}
	
	//Uses a trie to store key value pairs of the user IDs, if it already exist, then it will return false
	if( SetTrieValue(g_PlayerIDs, index, 1,false) )
	{
		g_Players++;
	}
	return;
}

public Action:EventPlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:index[MAX_INT_STRING];
	new userid = GetEventInt(event, "userid");
	//filters out fake clients
	if(!userid)
		return;
		
	IntToString(userid,index,MAX_INT_STRING);
	
	if (RemoveFromTrie(g_PlayerIDs, index))
	{
		g_Players--;
	}
}
