# ut-iptocountry-server
 IpToCountry server for Unreal Tournament servers


# Requirements 
- Node.js v14 or greater

# Install
- Extract the contents of the archive.
- Open command prompt.
- Type **npm install** This will install all dependencies.
- You can specify a different port in **app.mjs** defaults to 1999.
- You can also specify a default country code for people that don't have one(lan users, and unknown ip locations) by changing the variable **defaultCountryCode** to a two letter country code such as **us**. Defaults to "" aka Unknown

# Unreal Tournament Server Setup
- Go to the folder called **ipToCOuntryMutator** in the archive.
- Place **ipToCountry.u** and **ipToCountry_AOL.u** in your Unreal Tournament System folder.
- Place **CountryFlags2.utx** in your UnrealTournament Textures folder.
- Add the following lines to the [Engine.GameEngine] block in UnrealTournament.ini
```
ServerActors=ipToCountry.LinkActor
ServerPackages=IpToCountry_AOL
ServerPackages=CountryFlags2
```
- Restart Server
- Open IpToCountry.ini in your Unreal Tournament System folder.
- **QueryServerHost** should be set to your website host not your ut server host unless they are on the same machine. e.g www.example.com
- **QueryServerFilePath** should be set to **/iptocountry**
- **QueryServerPort** Should be set to the port specified in app.mjs(1999 by default)
- Restart Server

# Running the IPToCountry Server
- In the directory you installed the archive open the command prompt.
- Type the command **node app.mjs** to start the service.