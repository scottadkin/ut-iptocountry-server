IpToCountry 1.6 for Unreal Tournament '99

Initial to v1.2 by [es]Rush
v1.6 by Matthew 'MSuLL' Sullivan

Release Date: May 21, 2010
Distributed under the terms of OpenUnrealMod license - see LICENSE.txt for details

Thanks for opening this readme! Please read its contents before asking any questions.
You can learn:
-General information about IpToCountry and how does it work
-How to install and set it on the server
-How to make use of IpToCountry in your own mod

IF UPGRADING (IMPORTANT!)
-------
If you are upgrading from an old version, please see the section 'UPGRADING'
below. There have been a few important changes you need to be aware of!

CHANGELOG
-------
1.6: -Workaround to prevent crashing, improve stability and efficiency.
     -Trying to switch between query servers no longer fails
     -Re-added DNS resolution. IP cached in the config, if it changes the mod will re-resolve.
     -Increased number of query servers to 4.

1.2: -Added a small clientside package to identify AOL's country. Will work for USA/GB/DE players.
     -Added ErrorLimit variable.
     -Removed dependency on the DNS resolving system in UnrealEngine which seemed to be crashing the servers.
      Now all host based query servers have to specify an IP.

1.1: -Fixed the texture package, now it is CountryFlags2, this one should be perfect.
     -Fixed accessed nones in the Addon part while playing on the server with bots.

1.0: -First version

WHAT IS IT FOR?
-------
In short, as the name says, it can resolve a country from an IP address; it also resolves a hostname.
IpToCountry is meant mainly to be just a shared component between many other mods, for example
recent versions of SmartCTF, etc. Don't expect much black magic from IpToCountry itself. But to not
make you sad I've also made a little addon which will show players' country names after doing a
mutate command, for admins there is a similiar command showing hostnames, this addon is enabled by
default, but you can disable it in the config.

HOW DOES IT WORK?
-------
To your knowledge, resolving a country from an IP requires quite a big database and implementing
it in UnrealScript would be very hard, thus IpToCountry connects to a PHP script which is located
on a web server. This PHP script uses a database kindly distributed by www.maxmind.com
If you want to know how the querying stuff exactly works just "Use the source Luke!"

AOL is quite troublesome. AOL has all its IP ranges registered in the USA and thus it doesn't
make identification easy. Fortunately Rush found a way to go around the problem.
Three major countries where AOL is very popular are: USA, Great Britain and Germany. All those three have
different timezones, so Rush just had to get a player's time and compare it to GMT. The idea maybe was Rush's
but Cratos was the first to implement it in LeagueAS, Rush got some code from him so big thanks, mate.

WHO USES IT?
-------
At the time of writing this readme the following mods/mutators make use of IpToCountry (that I know of...):
-SuperWebAdmin 0.97
-LeagueAS140
-SmartCTF_4D (and up)
-BTPlusPlusv097
-Hostname Ban
-Nexgen

ZIP CONTAINS:
-------
README.txt - This file.
LICENSE.txt - OpenUnrealMod License
ipToCountry.u - The most important file, has to be in ServerActors - see INSTALLATION
IpToCountry_AOL.u - it has to be added to ServerPackages in order to activate AOL's country detection
CountryFlags2.utx - Country flags miniatures, has to be in ServerPackages if any mod needs it
Source/ - using this source you can modify and adapt IpToCountry to your needs!
MasterServer v1.6/ - anything related to hosting your own query server

INSTALLATION
-------
Add the following line to the [Engine.GameEngine] section of UnrealTournament.ini:
ServerActors=ipToCountry.LinkActor
ServerPackages=IpToCountry_AOL
ServerPackages=CountryFlags2


restart server and go to IpToCountry.ini for past:

[IpToCountry.LinkActor]
QueryServerHost[0]=www.unrealkillers.com
QueryServerHost[1]=www.wharthog.com
QueryServerHost[2]=utgl.unrealadmin.org
QueryServerHost[3]=
QueryServerFilePath[0]=/iptocountry/iptocountry16.php
QueryServerFilePath[1]=/iptocountry/iptocountry16.php
QueryServerFilePath[2]=/iptocountry16.php
QueryServerFilePath[3]=
QueryServerPort[0]=80
QueryServerPort[1]=80
QueryServerPort[2]=80
QueryServerPort[3]=
resolvedAddress[0]=184.170.132.98
resolvedAddress[1]=141.101.127.154
resolvedAddress[2]=85.236.100.16
resolvedAddress[3]=

UPGRADING
-------
If you are upgrading from any version prior to 1.6,
YOU MUST DELETE YOUR OLD IPTOCOUNTRY.INI AND IPTOCOUNTRY.U FILEs FIRST!

I can't stress this enough so we'll do it again:
YOU MUST DELETE YOUR OLD IPTOCOUNTRY.INI AND IPTOCOUNTRY.U FILEs FIRST!

Alright, now that's taken care of. Otherwise there are no other installation
changes (the ServerActors= line is still the same).

Put the ipToCountry.u file in the /SYSTEM folder and boot the server.
No other configuration needed, unless you absolutely want to, in which case you can look at
the 'CONFIG' section below.

CONFIG
-------
After the first server start, ipToCountry.ini should be created. The mod works just fine out of the
box, but if you wish you can edit the configuration, here are the varibles you can change:

QueryServerHost[0-3]       - This is where you can specify query servers to connect to. The defaults
QueryServerFilePath[0-3]     work just fine and are updated regularly. If you want to add another
QueryServerPort[0-3]         query server, just follow convention (eg. just look and see how its done
                             from the other entries). Query servers are tried sequentially, so the
                             server in the [0] slot will receive all traffic unless it can't connect.

MaxTimeout  - The amount of time before IpToCountry gives up on requesting data from the server
ErrorLimit  - IpToCountry will attempt to restart itself if the number of errors reaches ErrorLimit
bSpawnAddon - whether to use the Addon - should be always enabled unless you want to use IpToCountry
              in some special way - also read 'NOTE FOR ADMINS' below

NOTE FOR ADMINS
-------
Even if you have no mod using IpToCountry yet, you can still make use of it because of the Addon.
Mutate commands and example results:

> mutate iptocountry
[es]Rush, Country: POLAND
LanPlayer, Country: Unknown
OtherPlayer, Country: GERMANY

And this one works only for an admin:

> mutate iptohost
[es]Rush, Host: xxx.xxx.xxx.pl
LanPlayer, Host: 192.168.0.3
OtherPlayer, Host: xxx.xxx.de

The Addon also automatically resolves new IPs from joining players.

INSTRUCTION FOR DEVELOPERS
-------
If you want to use IpToCountry in your mod just learn it from my example class, it is pretty simple
and doesn't require compiling with the dependency and linking:

# SOURCE STARTS HERE
class IpDetails extends Actor;

var Actor IpToCountry;

function PostBeginPlay()
{
	BindIpToCountry();
}

function bool BindIpToCountry()
{
	local Actor A;
	foreach AllActors(class'Actor', A, 'IpToCountry')
		IpToCountry = A;

	// at this point, the variable 'IpToCountry' has
	// been set and can be used
}

function string GetIpInfo(string IP)
{
	if(IpToCountry != None)
		return IpToCountry.GetItemName(IP);
}
# SOURCE ENDS HERE

Now calling on function GetIpInfo() with a string parameter should return either the data or the status
of resolving this data, let me show you below. The function returns status codes under a high stress
(lots of calls). The mod may return any of these values, one after another:

1) "!Added to queue"
2) "!Waiting in queue"
3) "!Resolving now"
4) "!AOL - Trying to clarify"

1) is always returned if IP wasn't in the database
2) is very rarely returned
3) is returned if querying takes some time
4) is returned if the AOL module is currently working

Now when the state 3/4 is done it should report the actual data which is returned in the following form:
<IP>:<HOST>:<COUNTRY>:<PREFIX3>:<PREFIX2>
for example "153.19.48.14:lux.eti.pg.gda.pl:POLAND:POL:pl"

Useful data, isn't it?  Well, the function can also report an error:
1) "!Bad Input"
2) "!Queue full"
3) "!Disabled"

When 3) '!Disabled' is returned don't bother to query IpToCountry again, it means that IpToCountry
is unable to contact any of the query servers or experienced a lot of errors which let to a shutdown
of IpToCountry to prevent UT server stability issues.

When you got the right data you have to do some string parsing in order to get anything in a useful form,
you can use for example my SelElem function which is in the LinkActor.uc file in the source.

Now the fun part, when you've got last part of the return string, the 2 char long prefix, for example "pl",
you can for example display a country flag on a player's hud / scoreboard or however else you want to
use it in your cool new mod. Use the CountryFlags2.utx file and just do DynamicLoadObject on
CountryFlags2.<prefix>

For example, CountryFlags2.pl is a small flag of Poland. The textures are of size 16x16, but the bottom 6 pixels
are masked and shouldn't matter, so the visible size of the textures is 16x10. Remember that CountryFlags2
will have to be added to the ServerPackages, so notify users about it in your instructions.
*You can look at SmartCTF_4D country flags code if you don't have a clue how to make it work :)

A NOTE ON THE HTTPCLIENT CLASS (FOR DEVS ONLY)
-------
UT's implementation of a strong, stable HTTP Client wasn't much of a success. Thankfully Rush and
AnthraX took some time and made great progress on a UScript-based solution for the original
builds of IpToCountry. Problem is: if both query servers went down, or the internet stopped working for
just a little while, the entire UT server process would often die.  In September 2008 I
(MSuLL) began working on a mod that would depend on strong HTTP communications, which became the mod
'Universal Unreal'.  I used Rush's IpToCountry HTTP Client implentation as a base, then went about refining
it and making it more stable and efficient.

One big issue with the old client was that everything was being performed from the HTTP Client class,
and that class was spawned as a ServerActor at startup. When something screws up, the HTTP Client class,
which is based off of UBrowserHTTPClient, can't re-bind a port properly.  The solution is to kill the
HTTP Client class and start another instance upon a critical bind error.

For v1.6(+future editions) of IpToCountry, I've ported (or un-ported?) my HTTP Client implementation
back into the mod where it all began.  I've separated it into three main parts.  The LinkActor class
does error handling and general data management.  The HTTPClient class does the grunt work and can be
killed off (and then restarted) when critical errors are encountered.  The third class is the Addon
class, nothing major has changed in this class though.

I'd encourage developers to make use of this improved HTTP Client implementation in your own
mods.  Even though this game is 11 years old, there's still time for cool new stuff to be built :D
The class is very modular and shouldn't be too hard to understand / modify / etc.  Feel free to
ask for help in the UnrealAdmin.org forum, and I'd be glad to help.

THANKS TO
-------
AnthraX - for overall help, consultations and helping UT'99 community so much, thanks mate!
 Also thanks for updating the query server

teleport*bR - thanks for the great help in putting the texture package to one, thanks also for testing
Cratos - for supporting IpToCountry in LeagueAS and giving me some code to identify AOL's timezone
UnrealAdmin - for keeping UT alive

SPECIAL NOTE
-------
Starting at version 1.6, I (MSuLL) will be trying to support this mod through updates and bugfixes, as Rush
has since moved on from UT and Unreal coding. Rush created the initial versions and did an excellent job.
Most of us (coders) didn't even know such magic was possible until this mod was created and refined.
To both Rush and AnthraX: thank you so very much for your contributions to this mod, and to the UT
community in general. We, the players and admins of UT, deeply appreciate it and thank you for your efforts!

CONTACT & FEEDBACK
---------
UnrealAdmin.org forums:
http://www.unrealadmin.org/forums/showthread.php?t=29924