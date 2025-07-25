
#define MSGLENGTH 		151
#define SOUNDFILE_PATH_LEN 		256
#define CHECKFLAG 		ADMFLAG_ROOT


/*****************************************************************


			G L O B A L   V A R S


*****************************************************************/
new Handle:hKVCustomJoinMessages = INVALID_HANDLE;

new Handle:g_CvarPlaySound = INVALID_HANDLE;
new Handle:g_CvarPlaySoundFile = INVALID_HANDLE;

new Handle:g_CvarPlayDiscSound = INVALID_HANDLE;
new Handle:g_CvarPlayDiscSoundFile = INVALID_HANDLE;

new Handle:g_CvarMapStartNoSound = INVALID_HANDLE;

new bool:noSoundPeriod = false;

new bool:databaseConnected = false;

new Database:DB;

/*****************************************************************


			L I B R A R Y   I N C L U D E S


*****************************************************************/
#include "cannounce/joinmsg/allow.sp"
#include "cannounce/joinmsg/disallow.sp"
#include "cannounce/joinmsg/set.sp"
#include "cannounce/joinmsg/sound.sp"


/*****************************************************************


			F O R W A R D   P U B L I C S


*****************************************************************/

SetupJoinMsg()
{

	noSoundPeriod = false;

	//cvars
	g_CvarPlaySound = CreateConVar("sm_ca_playsound", "0", "Plays a specified (sm_ca_playsoundfile) sound on player connect");
	g_CvarPlaySoundFile = CreateConVar("sm_ca_playsoundfile", "ambient\\alarms\\klaxon1.wav", "Sound to play on player connect if sm_ca_playsound = 1");


	g_CvarPlayDiscSound = CreateConVar("sm_ca_playdiscsound", "0", "Plays a specified (sm_ca_playdiscsoundfile) sound on player discconnect");
	g_CvarPlayDiscSoundFile = CreateConVar("sm_ca_playdiscsoundfile", "weapons\\cguard\\charging.wav", "Sound to play on player discconnect if sm_ca_playdiscsound = 1");

	g_CvarMapStartNoSound = CreateConVar("sm_ca_mapstartnosound", "30.0", "Time to ignore all player join sounds on a map load");z


	//prepare kv custom messages file
	hKVCustomJoinMessages = CreateKeyValues("CustomJoinMessages");


	if(!FileToKeyValues(hKVCustomJoinMessages, g_fileset))
	{
		KeyValuesToFile(hKVCustomJoinMessages, g_fileset);
	}

	if (!SQL_CheckConfig("cannounce"))
	{
		LogError("Database failure: Could not find Database conf \"cannounce\".");
		databaseConnected = false;
	}

	else
	{
		Database.Connect(GotDatabase, "cannounce");
	}

	SetupJoinMsg_Allow();

	SetupJoinMsg_DisAllow();

	SetupJoinMsg_Set();

	SetupJoinSound_Set();
}



OnAdminMenuReady_JoinMsg()
{
	//Build the "Player Commands" category
	new TopMenuObject:player_commands = FindTopMenuCategory(hTopMenu, ADMINMENU_PLAYERCOMMANDS);

	if (player_commands != INVALID_TOPMENUOBJECT)
	{
		OnAdminMenuReady_JoinMsg_Allow(player_commands);

		OnAdminMenuReady_JoinMsg_DAllow(player_commands);
	}
}


OnMapStart_JoinMsg()
{
	decl Float:waitPeriod;

	noSoundPeriod = false;

	waitPeriod = GetConVarFloat(g_CvarMapStartNoSound);

	if( waitPeriod > 0 )
	{
		noSoundPeriod = true;
		CreateTimer(waitPeriod, Timer_MapStartNoSound);
	}

	if (databaseConnected)
	{
		char query[512];
		Format(query, sizeof(query), "SELECT steamId, playerwasnamed, message FROM CustomJoinMessages");
		DB.Query(GotJoinmsgList, query);
	}
}

OnPostAdminCheck_JoinMsg(client, const String:steamId[])
{
	SendJoinmsg(client, steamId);
}

OnClientDisconnect_JoinMsg()
{
	decl String:soundfile[SOUNDFILE_PATH_LEN];

	if( GetConVarInt(g_CvarPlayDiscSound))
	{
		GetConVarString(g_CvarPlayDiscSoundFile, soundfile, sizeof(soundfile));

		if( strlen(soundfile) > 0)
		{
			EmitSoundToAll( soundfile );
		}
	}
}


OnPluginEnd_JoinMsg()
{
	CloseHandle(hKVCustomJoinMessages);
}


public Action:Timer_MapStartNoSound(Handle:timer)
{
	noSoundPeriod = false;

	return Plugin_Handled;
}


/******************************************************

 * 			CALLBACKS

*************************************************/

public void GotDatabase(Database db, const char[] error, any data)
{
	if (db == INVALID_HANDLE)
	{
		LogError("Database failure: %s.", error);
		return;
	}

	DB = db;
	databaseConnected = true;

	char query[512];

	Format(query, sizeof(query), "SELECT steamId, playerwasnamed, message FROM CustomJoinMessages");
	DB.Query(GotJoinmsgList, query);
}

public void GotJoinmsgList(Database db, DBResultSet results, const char[] error, any data)
{

	if (results == null)
	{
		LogError("Failed to retrieve join message list from the database, %s", error);
		return;
	}

	new String:steamId[24];
	new String:playerwasnamed[MAX_TARGET_LENGTH];
	new String:message[MSGLENGTH + 2];

	while (results.FetchRow())
	{
		results.FetchString(0, steamId, sizeof(steamId));
		results.FetchString(1, playerwasnamed, sizeof(playerwasnamed));
		results.FetchString(2, message, sizeof(message));

		KvJumpToKey(hKVCustomJoinMessages, steamId, true);
		KvSetString(hKVCustomJoinMessages, "playerwasnamed", playerwasnamed );
		KvSetString(hKVCustomJoinMessages, "message", message );
		KvRewind(hKVCustomJoinMessages);
	}
	KeyValuesToFile(hKVCustomJoinMessages, g_fileset);
}

public void UpdateKVFromDB(Database db, DBResultSet results, const char[] error, DataPack dataPack)
{
	new String:steamId[24];
	if (results != null && results.FetchRow())
	{
		new String:playerwasnamed[MAX_TARGET_LENGTH];
		new String:message[MSGLENGTH + 2];

		results.FetchString(0, steamId, sizeof(steamId));
		results.FetchString(1, playerwasnamed, sizeof(playerwasnamed));
		results.FetchString(2, message, sizeof(message));

		KvJumpToKey(hKVCustomJoinMessages, steamId, true);
		KvSetString(hKVCustomJoinMessages, "playerwasnamed", playerwasnamed );
		KvSetString(hKVCustomJoinMessages, "message", message );
		KvRewind(hKVCustomJoinMessages);
	}
	dataPack.Reset();
	int client = dataPack.ReadCell();
	dataPack.ReadString(steamId, 24);
	SendJoinmsg(client, steamId)
}

public void QueryCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (results == null)
	{
		LogError("Failed to query the database, %s", error);
		return;
	}
}
/*****************************************************************


			P L U G I N   F U N C T I O N S


*****************************************************************/
LoadSoundFilesAll()
{
	new String:c_soundFile[SOUNDFILE_PATH_LEN];
	new String:c_soundFileFullPath[SOUNDFILE_PATH_LEN + 6];

	new String:dc_soundFile[SOUNDFILE_PATH_LEN];
	new String:dc_soundFileFullPath[SOUNDFILE_PATH_LEN + 6];

	//download and cache connect sound
	if( GetConVarInt(g_CvarPlaySound))
	{
		GetConVarString(g_CvarPlaySoundFile, c_soundFile, sizeof(c_soundFile));
		Format(c_soundFileFullPath, sizeof(c_soundFileFullPath), "sound/%s", c_soundFile);

		if( FileExists( c_soundFileFullPath ) )
		{
			AddFileToDownloadsTable(c_soundFileFullPath);

			PrecacheSound( c_soundFile );
		}
	}

	//cache disconnect sound
	if( GetConVarInt(g_CvarPlayDiscSound))
	{
		GetConVarString(g_CvarPlayDiscSoundFile, dc_soundFile, sizeof(dc_soundFile));
		Format(dc_soundFileFullPath, sizeof(dc_soundFileFullPath), "sound/%s", dc_soundFile);

		if( FileExists( dc_soundFileFullPath ) )
		{
			AddFileToDownloadsTable(dc_soundFileFullPath);

			PrecacheSound( dc_soundFile );
		}
	}
}

SendJoinmsg(client, const String:steamId[])
{
	decl String:soundfile[SOUNDFILE_PATH_LEN];
	new bool:customSoundPlayed = false;
	new bool:customMessageSent = false;

	//get from kv file
	KvRewind(hKVCustomJoinMessages);
	if(KvJumpToKey(hKVCustomJoinMessages, steamId))
	{
		new String:message[MSGLENGTH + 1];
		new String:output[301];
		new String:soundFilePath[SOUNDFILE_PATH_LEN];
		//Custom join MESSAGE
		KvGetString(hKVCustomJoinMessages, "message", message, sizeof(message), "");

		if( strlen(message) > 0)
		{
			//print output
			Format(output, sizeof(output), "%c%s", 1, message);

			PrintFormattedMessageToAll(output, client);
			customMessageSent = true;
		}

		//Custom join SOUND
		KvGetString(hKVCustomJoinMessages, "soundfile", soundFilePath, sizeof(soundFilePath), "");

		if( strlen(soundFilePath) > 0 && !noSoundPeriod )
		{
			EmitSoundToAll( soundFilePath );
			customSoundPlayed = true;
		}
	}

	KvRewind(hKVCustomJoinMessages);

	//if enabled and custom sound not already played, play all player sound
	if( GetConVarInt(g_CvarPlaySound) && !customSoundPlayed)
	{
		GetConVarString(g_CvarPlaySoundFile, soundfile, sizeof(soundfile));

		if( strlen(soundfile) > 0 && !noSoundPeriod)
		{
			EmitSoundToAll( soundfile );
		}
	}

	if (!customMessageSent)
	{
		ShowDefaultMessage(client);
	}
}
