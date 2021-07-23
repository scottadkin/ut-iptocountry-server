/*
    IpToCountry 1.6 Copyright (C) 2006-2010

    Initial to v1.2 by [es]Rush
    v1.6 by Matthew 'MSuLL' Sullivan

    This program is free software; you can redistribute and/or modify
    it under the terms of the Open Unreal Mod License version 1.1.
*/

class LinkActor extends Mutator config(ipToCountry);

var config string QueryServerHost[4];
var config string QueryServerFilePath[4];
var config int QueryServerPort[4];
var config string resolvedAddress[4];
var config int MaxTimeout;
var config int ErrorLimit;
var config bool bNeverPurgeAddress;
var config bool bSpawnAddon;
var config string IPData[256];
var config int IPDataIndex; /* if IPData[] if full, the next data will be saved to IPData[IPDataIndex] */

var HTTPClient httpClientInstance;
var bool httpClientInstanceStarted;
var int numHTTPRestarts;
var int NumberOfServers;
var int currentServer;
var bool bCheckAOL;

event PreBeginPlay()
{
	Tag='IpToCountry';
	Super.PreBeginPlay();
}

function PostBeginPlay()
{
	local Addon addonInstance;
	local int i;
	local string addonText, aolText;

	Super.PostBeginPlay();
	SaveConfig();

	for(i=0;i<ArrayCount(QueryServerHost);i++)
	{
		if(QueryServerHost[i] == "" || QueryServerFilePath[i] == "")
		{
			break;
		}
		else
		{
			NumberOfServers++;
		}
	}

	Log("####################################");
	Log("#          IP To Country           #");
	Log("#           Version 1.6            #");
	Log("# Initial to v1.2 by [es]Rush      #");
	Log("# v1.6 by Matthew 'MSuLL' Sullivan #");
	Log("####################################");

	if(NumberOfServers < 1)
	{
		Log("# You do not seem to have any      #");
		Log("# query servers configured, this   #");
		Log("# must be fixed in ipToCountry.ini #");
		Log("####################################");
		Log("#    IP TO COUNTRY IS UNLOADING    #");
		Log("####################################");

		Destroy();
		return;
	}

	addonText = "False";
	if(bSpawnAddon)
	{
		addonInstance = Level.Spawn(class'Addon');
		Level.Game.BaseMutator.AddMutator(addonInstance);
		addonInstance.IpToCountry = self;
		addonText = "True ";
	}

	aolText = "False";
	if(InStr(Caps(ConsoleCommand("get ini:Engine.Engine.GameEngine ServerPackages")), "IPTOCOUNTRY_AOL") != -1)
	{
		bCheckAOL = True;
		aolText = "True ";
	}

	Log("# Spawn Addon: "$addonText$"               #");
	Log("# Extension for AOL: "$aolText$"         #");
	Log("# Query Servers: "$NumberOfServers$"                 #");
	Log("####################################");

	initHTTPFunctions();
}

function restartHTTPClient(optional bool bSwitchServers)
{
	httpClientInstance.Destroy();
	httpClientInstanceStarted = False;

	if(numHTTPRestarts < 4)
	{
		Log("[IpToCountry] Too many HTTP errors in one session, HTTP client restarting.");

		if(bSwitchServers)
		{
			if((currentServer + 1) == NumberOfServers)
			{
				currentServer = 0;
			}
			else
			{
				currentServer++;
			}
		}

		initHTTPFunctions();
		numHTTPRestarts++;
	}
	else
	{
		Log("[IpToCountry] Too many HTTP client restarts in one session, HTTP functions disabled.");
	}
}

function string GetItemName(string IP)
{
	if(httpClientInstanceStarted)
	{
		return httpClientInstance.SendData(IP);
	}
	else
	{
		return "!Disabled";
	}
}

function initHTTPFunctions()
{
	if(!httpClientInstanceStarted)
	{
		httpClientInstance = Spawn(class'HTTPClient');
		httpClientInstanceStarted = true;
	}
}

/* STRING FUNCTIONS */

// Arguments(Input string, Character separating elements)
static final function int ElementsNum(string Str, optional string Char)
{
	local int count, pos;

	if(Char=="")
		Char=":";

	while(true)
	{
		pos = InStr(Str, Char);
		if(pos == -1)
			break;
		Str=Mid(Str, pos+1);
		count++;
	}
	return count+1;
}

// Arguments(Input string, Element to get, Character separating elements)
static final function string SelElem(string Str, int Elem, optional string Char)
{
	local int pos;
	if(Char=="")
		Char=":";

	while(Elem>1)
	{
		Str=Mid(Str, InStr(Str, Char)+1);
		Elem--;
	}
	pos=InStr(Str, Char);
	if(pos != -1)
    	Str=Left(Str, pos);
    return Str;
}

static final function string SepLeft(string Input, optional string Char)
{
	local int pos;
	if(Char=="")
		Char=":";

	pos = InStr(Input, Char);
	if(pos != -1)
		return Left(Input, pos);
	else
		return Input;
}

static final function string SepRight(string Input, optional string Char)
{
	local int pos;
	if(Char=="")
		Char=":";

	pos = InStr(Input, Char);
	if(pos != -1)
		return Right(Input, len(Input)-pos-1);
	else
		return "";
}

defaultproperties
{
    Tag='IpToCountry'
    QueryServerHost(0)="iptocountry.ut-files.com"
    QueryServerHost(1)="www.ut-slv.com"
    QueryServerHost(2)="utgl.unrealadmin.org"
    QueryServerFilePath(0)="/iptocountry16.php"
    QueryServerFilePath(1)="/iptocountry/iptocountry16.php"
    QueryServerFilePath(2)="/iptocountry16.php"
    QueryServerPort(0)=80
    QueryServerPort(1)=80
    QueryServerPort(2)=80
    QueryServerPort(3)=80
    MaxTimeout=10
    ErrorLimit=5
    bSpawnAddon=True
}
