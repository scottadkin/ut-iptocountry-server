/*
    IpToCountry_AOL
    Copyright (C) 2006 [es]Rush

    This program is free software; you can redistribute and/or modify
    it under the terms of the Open Unreal Mod License version 1.1.

	*this module is supposed to be linked with main IpToCountry package
*/

class TimeReplication extends Info;

var Actor IpToCountry; /* set after being spawned in class'LinkActor' */

replication {
reliable if (Role < ROLE_Authority)
	ServerSet;
}

function ServerSet(string Input)
{
	local string IP;

	IP=PlayerPawn(Owner).GetPlayerNetworkAddress();
	IP=Left(IP, InStr(IP, ":"));
	if(IpToCountry != None)
		IpToCountry.GetItemName("AOLSUX"@IP$":"$Input);
	Destroy();
}

function DelayedDestroy() //well, that's only just in case
{
	SetTimer(10, false);
}

function Timer()
{
	Destroy();
}

simulated event PostNetBeginPlay()
{
	local string IP;
	if(ROLE==ROLE_Authority)
		return;
	DelayedDestroy();
	ServerSet(Level.Hour$":"$Level.Minute);
}

defaultproperties {
	NetPriority=10.0
}