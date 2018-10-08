#include <sourcemod>
#include <telegram>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[Telegram] Info",
	author = "Alexbu444",
	description = "Send info to Telegram",
	version = "1.1.0",
	url = "https://t.me/alexbu444"
};

public void OnPluginStart() {
	RegConsoleCmd("sm_tg_me", InfoMe);
	RegConsoleCmd("sm_tg_server", ServerInfo);
}

public Action InfoMe(int iClient, int iArgs) {
	if (!iClient)
		return Plugin_Handled;

	char s2[256], s3[256], s64[256], sBuffer[256];

	GetClientAuthId(iClient, AuthId_Steam2, s2, sizeof(s2));
	GetClientAuthId(iClient, AuthId_Steam3, s3, sizeof(s3));
	GetClientAuthId(iClient, AuthId_SteamID64, s64, sizeof(s64));

	Format(sBuffer, sizeof(sBuffer), "`%N: SteamID v2 / v3: %s / %s Steam Community ID: %s`", iClient, s2, s3, s64);

	TelegramMsg(sBuffer);
	TelegramSend();

	return Plugin_Continue;
}

public Action ServerInfo(int iClient, int iArgs) {
	char sHostname[256], sMap[256], sPlayers[256], sAdmins[256], sBuffer[256];

	GetConVarString(FindConVar("hostname"), sHostname, sizeof(sHostname));
	GetCurrentMap(sMap, sizeof(sMap));
	FormatEx(sPlayers, sizeof(sPlayers), "%d / %d", GetClientCount(true), MaxClients);
	FormatEx(sAdmins, sizeof(sAdmins), "%d", GetAdminCount());

	Format(sBuffer, sizeof(sBuffer), "`Hostname: %s / Current Map: %s / Players: %s / Admins: %s`", sHostname, sMap, sPlayers, sAdmins);

	TelegramMsg(sBuffer);
	TelegramSend();

	return Plugin_Continue;
}

int GetAdminCount() {
	int res;

	for (int i; ++i <= MaxClients;) {
		if (!IsClientInGame(i) || IsFakeClient(i) || GetUserAdmin(i) == INVALID_ADMIN_ID)
			continue;
		res++;
  	}

	return res;
}