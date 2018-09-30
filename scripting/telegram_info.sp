#include <sourcemod>
#include <SteamWorks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[Telegram] Info",
	author = "Alexbu444",
	description = "Send info to Telegram",
	version = "1.0.0",
	url = "https://t.me/alexbu444"
};

#define PMP PLATFORM_MAX_PATH
char g_szLogFile[PMP];
char sPath[PMP];
char szQuery[256];
char szToken[256];
char szChatId[256];

public void OnPluginStart() {
	RegConsoleCmd("sm_tg_me", InfoMe);
	BuildPath(Path_SM, g_szLogFile, sizeof(g_szLogFile), "logs/tg_info.log");
}

public void OnConfigsExecuted() {
    BuildPath(Path_SM, sPath, sizeof(sPath), "configs/telegram.cfg");
    KeyValues kv = new KeyValues("Telegram");
    
    if(!kv.ImportFromFile(sPath) || !kv.GotoFirstSubKey()) SetFailState("[Telegram] file is not found (%s)", sPath);
    
    kv.Rewind();
    
    if(kv.JumpToKey("Info"))
    {
        kv.GetString("token", szToken, sizeof(szToken));
        kv.GetString("chatId", szChatId, sizeof(szChatId));
    }
    else
    {
        SetFailState("[Telegram] settings not found (%s)", sPath);
    }
        
    delete kv;
}

public Action InfoMe(int iClient, int iArgs) {
	if (!iClient)
		return Plugin_Handled;

	char szSI2[256], szSI3[256], szSI64[256];

	GetClientAuthId(iClient, AuthId_Steam2, szSI2, sizeof(szSI2));
	GetClientAuthId(iClient, AuthId_Steam3, szSI3, sizeof(szSI3));
	GetClientAuthId(iClient, AuthId_SteamID64, szSI64, sizeof(szSI64));

	FormatEx(szQuery, sizeof(szQuery), "https://api.telegram.org/bot%s/sendMessage?chat_id=%s&parse_mode=markdown&text=%s: ```SteamID v2 / v3 / Community ID: %s / %s / %s```", szToken, szChatId, iClient, szSI2, szSI3, szSI64);
	Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, szQuery);
	SteamWorks_SetHTTPRequestHeaderValue(hRequest, "User-Agent", "telegram");
	SteamWorks_SetHTTPCallbacks(hRequest, OnTransferComplete);
	SteamWorks_SendHTTPRequest(hRequest);

	return Plugin_Handled;
}

public int OnTransferComplete(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode) {
	int sz;
	SteamWorks_GetHTTPResponseBodySize(hRequest, sz);
	char[] sBody = new char[sz];
	SteamWorks_GetHTTPResponseBodyData(hRequest, sBody, sz);
	LogToFileEx(g_szLogFile, "Telegram: %s", sBody);
}