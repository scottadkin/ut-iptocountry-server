/**
 * IPToCountry for Unreal Tournament(Classic) converted to javascript by Scott Adkin 23rd July 2021
 * Original PHP version created by AnthraX, Rush, sphx, MSuLL ~ 2007?
 */

import dns from 'dns';
import geoip from 'geoip-country';
import countries from 'i18n-iso-countries';
import express from 'express';

const app = express();

const port = 1999;
//set this to a two digit country code if you want to set lan player flags, or just unknown ones in general
const defaultCountryCode = "";


class Player{

    constructor(ip, hostnames, countryCode){

        this.ip = ip;
        this.hostname = hostnames;

        if(countryCode === null){
            countryCode = "";
        }else{
            countryCode = countryCode.toLowerCase();
        }

        this.countryCode = countryCode;

        this.countryName = (countryCode === "") ? "Unknown" : countries.getName(countryCode, "en");
        this.countryCode3 = countries.getAlpha3Code(this.countryName, "en");

        if(this.countryCode3 === undefined){
            this.countryCode3 = "";
        }

    }


    print(){

        const now = new Date(Date.now());

        let minutes = now.getMinutes();
        let hours = now.getHours();

        if(minutes < 10) minutes = `0${minutes}`;
        if(hours < 10) hours = `0${hours}`;

        return `${hours}:${minutes} ${this.ip}:${this.hostname}:${this.countryName}:${this.countryCode3}:${this.countryCode}`;
    }
}


function getHostName(ip){

    return new Promise((resolve, reject) =>{

        dns.reverse(ip, (err, hostnames) =>{

            if(err){
                console.trace(err);
                resolve(ip);
                
            }else{

                resolve(hostnames[0]);
            }
        });
    });
}



app.get('/iptocountry', async (req, res) =>{

    try{

        if(req.query.ip !== undefined){

            const ips = req.query.ip.split(",");

            const players = [];

            let currentCountry = 0;

            for(let i = 0; i < ips.length; i++){
 
                currentCountry = geoip.lookup(ips[i]);

                if(currentCountry === null){
                    currentCountry = {"country": defaultCountryCode};
                }

                players.push(new Player(ips[i], await getHostName(ips[i]), currentCountry.country));
            }

            let string = "";

            for(let i = 0; i < players.length; i++){

                string += players[i].print();

                if(i < players.length - 1){
                    string += ",";
                }
            }

            res.send(string);
            return;
        }


        res.send("");

    }catch(err){
        console.trace(err);
        res.send("");
    }
});


app.listen(port);