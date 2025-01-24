#include <sourcemod>

public Plugin myinfo =
{
	name = "RandomMap",
	author = "Jaws",
	description = "Simple command to change to a random map",
	version = "1.0",
	url = ""
};

ArrayList g_MapList;
ConVar g_Cvar_RandomStart;
bool firstmap;

public void OnPluginStart()
{
    int arraySize = ByteCountToCells(PLATFORM_MAX_PATH);
    g_MapList = new ArrayList(arraySize);
    firstmap = true;
    RegAdminCmd("sm_randommap", Command_RandomMap, ADMFLAG_CHANGEMAP, "sm_randommap - changes to a random map");
    int g_mapFileSerial = -1;
    ReadMapList(g_MapList, g_mapFileSerial, "default", MAPLIST_FLAG_CLEARARRAY|MAPLIST_FLAG_MAPSFOLDER);
    g_Cvar_RandomStart = CreateConVar("sm_randommap_start", "0", "Should we load a random map when the server starts?", _, true, 0.0, true, 1.0);

    AutoExecConfig(true, "randommap");
}

public void OnConfigsExecuted()
{
    if(g_Cvar_RandomStart.BoolValue && firstmap)
    {
        Command_RandomMap(0, 0);
    }
    firstmap=false
}

public Action Command_RandomMap(int client, int args)
{
    char map[PLATFORM_MAX_PATH];
    int count = g_MapList.Length;
    int item = GetRandomInt(0, count - 1);
    g_MapList.GetString(item, map, sizeof(map));
    ForceChangeLevel(map, "Random Map");
    return Plugin_Handled;
}
