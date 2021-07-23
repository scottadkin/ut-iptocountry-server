/*
    IpToCountry 1.3 Copyright (C) 2006-2010

    Initial to v1.2 by [es]Rush
    v1.3 Overhaul by Matthew 'MSuLL' Sullivan

    This program is free software; you can redistribute and/or modify
    it under the terms of the Open Unreal Mod License version 1.1.
*/

class Addon extends Mutator;

var LinkActor IpToCountry;
var int CurrentID;
var TimeReplication TR[32];

function Tick(float DeltaTime)
{
	local Pawn P;
	local TimeReplication TR;

	if(IpToCountry == None)
		return;
	if(Level.Game.CurrentID > CurrentID)
	{
		for( P=Level.PawnList; P!=None; P=P.NextPawn )
			if(P.PlayerReplicationInfo.PlayerID == CurrentID)
				break;
		CurrentID++;
		if(P.IsA('PlayerPawn'))
			if(NetConnection(PlayerPawn(P).Player) != None)
				IpToCountry.GetItemName(IpToCountry.SepLeft(PlayerPawn(P).GetPlayerNetworkAddress()));
	}
}

function Mutate(string MutateString, PlayerPawn Sender)
{
	local Pawn P;
	local string Data, Country, Host;

	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);

	if(IpToCountry == None)
		return;

 	if(Left(MutateString, 11) ~= "iptocountry")
	{
		for( P=Level.PawnList; P!=None; P=P.NextPawn )
		{
			if(P.IsA('PlayerPawn'))
			{
				if(NetConnection(PlayerPawn(P).Player) != None)
				{
					Data = IpToCountry.GetItemName(IpToCountry.SepLeft(PlayerPawn(P).GetPlayerNetworkAddress()));
					Country = IpToCountry.SelElem(Data,3);
					if(Left(Data, 1) == "!" || Country == "")
						Sender.ClientMessage(P.PlayerReplicationInfo.PlayerName$", Country: Unknown");
					else
						Sender.ClientMessage(P.PlayerReplicationInfo.PlayerName$", Country: "$Capitalize(IpToCountry.SelElem(Data, 3)));
				}
			}
		}

		if(Sender.bAdmin)
		{
			Sender.ClientMessage("[IpToCountry] You are currently authenicated as an admin.");
			Sender.ClientMessage("[IpToCountry] 'mutate iptohost' to see all hostnames for players.");
		}
	}
	if(Sender.bAdmin)
	{
		if(Left(MutateString, 8) ~= "iptohost")
		{
			for( P=Level.PawnList; P!=None; P=P.NextPawn )
				if(P.IsA('PlayerPawn'))
					if(NetConnection(PlayerPawn(P).Player) != None)
					{
						Data = IpToCountry.GetItemName(IpToCountry.SepLeft(PlayerPawn(P).GetPlayerNetworkAddress()));
						Host = IpToCountry.SelElem(Data, 2);
						if(Left(Data, 1) == "!" || Host == "")
							Sender.ClientMessage(P.PlayerReplicationInfo.PlayerName$", Host: Unknown");
						else
							Sender.ClientMessage(P.PlayerReplicationInfo.PlayerName$", Host: "$IpToCountry.SelElem(Data, 2));
				}
		}
	}
}

static final function string Capitalize(coerce string Text)
{
	local int IndexChar;
	local int i;
	local string atc[8];
	local string TempLeft;
	local string TempMid;

	for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
		if (Mid(Text, IndexChar, 1) >= "A" &&
			Mid(Text, IndexChar, 1) <= "Z")
		Text = Left(Text, IndexChar) $ Chr(Asc(Mid(Text, IndexChar, 1)) + 32) $ Mid(Text, IndexChar + 1);

	atc[0]=left(Text,InStr(Text," "));
	for(i=0;InStr(Text," ")!=-1;i++){
		Text=right(Text,Len(Text)-InStr(Text," ")-1);
		atc[i+1]=left(Text,InStr(Text," "));
	}
	atc[i]=Text;

	Text = "";

	for(i=0;i<8;i++)
	{
		if(atc[i] != "")
		{
			TempLeft = CAPS(Left(atc[i],1));
			TempMid = Mid(atc[i],1);

			if(i == 0)
			{
				Text = TempLeft$TempMid;
			}
			else
			{
				Text = Text@TempLeft$TempMid;
			}
		}
	}

	return Text;
}

defaultproperties
{
	bAlwaysTick=True
}
