// LSL script generated: RealFire-Rene10957.LSL.Fire.lslp Tue Feb 11 16:16:26 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Realfire by Rene - Fire
//
// Author: Rene10957 Resident
// Date: 02-02-2014
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.
// Content creator? Please read the license notecard!
//
// Features:
//
// - Fire with smoke, light and sound
// - Burns down at any desired speed
// - Change fire size/color and sound volume
// - Plugin support
// - Access control: owner, group, world
// - Touch to start or stop fire
// - Long touch to show menu
//
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: initial structure for multiple sound files, implement linked_message system, background sound, LSLForge Modules
//11. Feb. 2014
//v2.3-1.21
//

//Files:
// Fire.lsl
//
// Smoke.lsl
// Sound.lsl
// config
// User Manual
//
//
//Prequisites:
// if primfire is used, the fire prims not only need the P-Anim_object (and texture animation) script, but also Remote_control - and Remote_receiver
// Smoke.lsl in another prim than Fire.lsl
// Soundfiles need to be in same prim as Sound scripts
//
//Notecard format: see config NC
//basic help: User Manual
// to use multipe fires, see F-Anim.lsl header
//
//Changelog
// Formatting
// variable naming sheme
// structure for multiple sound files
// structure for multiple scripts
// B-Sound

//FIXME: to many backround sound off messages after every option togggle (primfire)
//FIXME: off messages when touch-off but extensions are allready off in options
//FIXME: heap stack collision - make own module for particle fire

//TODO: remove long delay on initial run
//TODO: make sound configurable via notecard - maybe own config file?
//TODO: keep sound running for a short time after turning fire off
//TODO: sound preload on touch
//TODO: sound seems to get called twice
//TODO: integrate B-Sound  - use key in lllinkedmessage/link_message to differentiate; add backround sound off
//TODO: scale for effect 0<=x<=100, -1 backround, 110 Sound start -- don't confuse with volume
//TODO: prim fire / flexi prim (need to move/rotate it) / sculpted prims ----- temp rezzer
//TODO: sparkles
//TODO: fire via particles, using textures?!
//TODO: check //PSYS_PART_RIBBON_MASK effect
//TODO: maybe en-/disable //PSYS_PART_WIND_MASK, if fire is out-/inside (test effect!)
//TODO: test cone instead of explode (radius) + angle (placement)
//TODO: longer break between automatic fire off and going on again, also make fire slowly bigger... and let fire burn down slower (look into function)
//TODO: make 5% lowest setting (glowing)? and adjust fire (100%)  - is way too big for the fireplace
//TODO: better smoke (color, intensity, change when fire changes) - rework smoke in updateSize (currently only changed when size<=25)
//TODO: smoke with textures
//TODO: check change smoke while smoke is off
//TODO: let sound script do calculation of sound percentage, as smoke does it
//TODO: add ping/pong with other scripts in case only fire.lsl gets resetted
//TODO: if script in another prim is removed, Fire.lsl cannot handle the situation
//TODO: move object animation to own script too?
//TODO: ability to change burndown/restart
//TODO: fire size = 0 - but sound on + volume --> at least background sound (glowing embers)
//TODO: HUD?
//TODO: play with llListen()
//TODO: check if other particle scripts are in same prim
//TODO: create a module sizeSelect, put size class borders into variables and settings notecard
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//user changeable variables
//-----------------------------------------------
string NOTECARD = "config";
string SOUNDSCRIPT = "Sound.lsl";
string BACKSOUNDSCRIPT = "B-Sound.lsl";
string SMOKESCRIPT = "Smoke.lsl";
string TEXTUREANIMSCRIPT = "Animation.lsl";
string PRIMFIREANIMSCRIPT = "P-Anim.lsl";
string PARTICLEFIREANIMSCRIPT = "F-Anim.lsl";

string LINKSETID = "RealFire";

//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire";
string g_sVersion = "2.3-1.21";
string g_sAuthors = "Rene10957, Zopf";

// Notecard variables
integer g_iSwitchAccess;
integer g_iMenuAccess;
integer g_iLowprim = 0;
integer g_iBurnDown = 0;
float g_fBurnTime;
float g_fDieTime;
integer g_iLoop = 0;
integer g_iChangeSmoke = 1;
integer g_iChangeVolume = 1;
integer g_iDefSize;
integer g_iDefVolume;
integer g_iDefChangeVolume = 1;
integer g_iDefSmoke = 1;
integer g_iDefSound = 0;
integer g_iDefParticleFire = 1;
integer g_iDefPrimFire = 0;
string g_sCurrentSound = "55";

// Variables
key g_kUser;
key g_kQuery = NULL_KEY;

integer g_iSmokeAvail = 0;
integer g_iSoundAvail = 0;
integer g_iBackSoundAvail = 0;
integer g_iParticleFireAvail = 0;
integer g_iPrimFireAvail = 0;

integer g_iLine;
string g_sConfLine = "";
integer menuChannel;
integer g_iStartColorChannel;
integer g_iEndColorChannel;
integer g_iOptionsChannel;
integer g_iMenuHandle;
integer g_iStartColorHandle;
integer g_iEndColorHandle;
integer g_iOptionsHandle;
float g_fPerSize;
integer g_iPerVolume;
integer g_iOn = 0;
integer g_iBurning = 0;
integer g_iSmokeOn = 0;
integer g_iSoundOn = 0;
integer g_iParticleFireOn = 0;
integer g_iPrimFireOn = 0;
integer g_iVerboseButton = 0;
integer g_iMenuOpen = 0;
float g_fTime;
float g_fPercent;
float g_fPercentSmoke;
float g_fDecPercent;
float g_fSoundVolume = 0.0;
float g_fStartVolume;
integer g_iVerbose = 1;
string g_sScriptName;
integer silent = 0;
integer g_iMsgNumber = 10959;
string g_sMsgSwitch = "switch";
string g_sMsgOn = "on";
string g_sMsgOff = "off";
string g_sMsgMenu = "menu";
integer g_iExtNumber = 10960;
integer g_iChangeLight = 1;
integer g_iSingleFire = 1;
vector g_vDefStartColor = <100.0,100.0,0.0>;
vector g_vDefEndColor = <100.0,0.0,0.0>;
integer g_iDefIntensity = 100;
integer g_iDefRadius = 50;
integer g_iDefFalloff = 40;
key g_kOwner;
integer g_iPerRedStart;
integer g_iPerGreenStart;
integer g_iPerBlueStart;
integer g_iPerRedEnd;
integer g_iPerGreenEnd;
integer g_iPerBlueEnd;
string SEPARATOR = ";;";
integer COMMAND_CHANNEL;
integer PARTICLE_CHANNEL;
integer SOUND_CHANNEL;
integer ANIM_CHANNEL;
integer PRIMCOMMAND_CHANNEL;
integer REMOTE_CHANNEL;


MESSAGE_MAP(){
    (COMMAND_CHANNEL = 15700);
    (PARTICLE_CHANNEL = -15790);
    (SOUND_CHANNEL = -15780);
    (ANIM_CHANNEL = -15770);
    (PRIMCOMMAND_CHANNEL = -15771);
    (REMOTE_CHANNEL = -975102);
}


//###
//GenericFunctions.lslm
//0.22 - 09Feb2014

integer checkInt(string par,integer val,integer min,integer max){
    if (((val < min) || (val > max))) {
        if ((val < min)) (val = min);
        else  if ((val > max)) (val = max);
        llWhisper(0,((par + " out of range, corrected to ") + ((string)val)));
    }
    return val;
}


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

//===============================================================================
//= parameters   :    string    sFunction    which function to toggle
//=
//= return        :    none
//=
//= description  :    handle different function toggles (on/off with intensity)
//=
//===============================================================================
toggleFunktion(string sFunction){
    
    if (("fire" == sFunction)) {
        if (g_iOn) stopSystem();
        else  startSystem();
    }
    else  if (("particlefire" == sFunction)) {
        if (g_iParticleFireOn) {
            sendMessage(PARTICLE_CHANNEL,"0","fire");
            (g_iParticleFireOn = 0);
        }
        else  {
            sendMessage(PARTICLE_CHANNEL,((string)g_fPerSize),"fire");
            (g_iParticleFireOn = 1);
        }
    }
    else  if (("primfire" == sFunction)) {
        if (g_iPrimFireOn) {
            sendMessage(ANIM_CHANNEL,"0",((string)g_iLowprim));
            (g_iPrimFireOn = 0);
        }
        else  {
            sendMessage(ANIM_CHANNEL,((string)llRound(g_fPerSize)),((string)g_iLowprim));
            (g_iPrimFireOn = 1);
        }
    }
    else  if (("smoke" == sFunction)) {
        if (g_iSmokeOn) {
            sendMessage(PARTICLE_CHANNEL,"0","smoke");
            (g_iSmokeOn = 0);
        }
        else  {
            sendMessage(PARTICLE_CHANNEL,((string)llRound(g_fPercentSmoke)),"smoke");
            (g_iSmokeOn = 1);
        }
    }
    else  if (("sound" == sFunction)) {
        if (g_iSoundOn) {
            sendMessage(SOUND_CHANNEL,"","0");
            (g_iSoundOn = 0);
        }
        else  {
            sendMessage(SOUND_CHANNEL,g_sCurrentSound,((string)g_fSoundVolume));
            (g_iSoundOn = 1);
        }
    }
}


integer checkYesNo(string par,string val){
    if ((llToLower(val) == "yes")) return 1;
    if ((llToLower(val) == "no")) return 0;
    llWhisper(0,(("[Notecard] " + par) + " out of range, corrected to NO"));
    return 0;
}


loadNotecard(){
    (g_iLine = 0);
    (g_sConfLine = "");
    if ((llGetInventoryType(NOTECARD) == 7)) {
        
        (g_kQuery = llGetNotecardLine(NOTECARD,g_iLine));
    }
    else  {
        llWhisper(0,(("Notecard \"" + NOTECARD) + "\" not found or empty, using defaults"));
        (g_iVerbose = 1);
        (g_iSwitchAccess = 1);
        (g_iMenuAccess = 1);
        (g_iLowprim = 0);
        (g_iBurnDown = 0);
        (g_fBurnTime = 300.0);
        (g_fDieTime = 300.0);
        (g_iLoop = 0);
        (g_iChangeSmoke = 1);
        (g_iDefSize = 25);
        (g_vDefStartColor = <100.0,100.0,0.0>);
        (g_vDefEndColor = <100.0,0.0,0.0>);
        (g_iDefVolume = 100);
        (g_iDefChangeVolume = 1);
        (g_iDefSmoke = 1);
        (g_iDefSound = 0);
        (g_iDefParticleFire = 1);
        (g_iDefPrimFire = 0);
        if ((!g_iBurnDown)) (g_fBurnTime = 315360000);
        (g_fTime = (g_fDieTime / 100.0));
        if ((g_fTime < 1.0)) (g_fTime = 1.0);
        (g_fDecPercent = (100.0 / (g_fDieTime / g_fTime)));
        float per = g_iDefVolume;
        float num = 1.0;
        (g_fStartVolume = ((num / 100.0) * per));
        reset();
        if (g_iOn) startSystem();
        if (g_iVerbose) {
            llWhisper(0,((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors));
            if ((!silent)) llWhisper(0,"Touch to start/stop fire\n *Long touch to show menu*");
            if (((!silent) && g_iVerbose)) {
                integer access = g_iSwitchAccess;
                string strAccess;
                if (access) {
                    if ((access & 4)) (strAccess += " Owner");
                    if ((access & 2)) (strAccess += " Group");
                    if ((access & 1)) (strAccess += " World");
                }
                else  {
                    (strAccess = " None");
                }
                llWhisper(0,("(v) Switch access:" + strAccess));
                integer _access4 = g_iMenuAccess;
                string _strAccess5;
                if (_access4) {
                    if ((_access4 & 4)) (_strAccess5 += " Owner");
                    if ((_access4 & 2)) (_strAccess5 += " Group");
                    if ((_access4 & 1)) (_strAccess5 += " World");
                }
                else  {
                    (_strAccess5 = " None");
                }
                llWhisper(0,("(v) Menu access:" + _strAccess5));
                llWhisper(0,("(v) Channel for remote control: " + ((string)g_iMsgNumber)));
                llWhisper(0,((((("\n\t -free memory: " + ((string)llGetFreeMemory())) + " -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
            }
        }
        
    }
}


readNotecard(string ncLine){
    string ncData = llStringTrim(ncLine,3);
    if (((llStringLength(ncData) > 0) && (llGetSubString(ncData,0,0) != "#"))) {
        list ncList = llParseString2List(ncData,["=","#"],[]);
        string par = llList2String(ncList,0);
        string val = llList2String(ncList,1);
        (par = llStringTrim(par,3));
        (val = llStringTrim(val,3));
        string lcpar = llToLower(par);
        if ((("linksetid" == lcpar) && ("" != val))) (LINKSETID = val);
        else  if ((lcpar == "verbose")) (g_iVerbose = checkYesNo("verbose",val));
        else  if ((lcpar == "switchaccess")) (g_iSwitchAccess = checkInt("switchAccess",((integer)val),0,7));
        else  if ((lcpar == "menuaccess")) (g_iMenuAccess = checkInt("menuAccess",((integer)val),0,7));
        else  if ((lcpar == "msgnumber")) {
            (g_iMsgNumber = ((integer)val));
            (g_sConfLine += (((lcpar + "=") + ((string)g_iMsgNumber)) + SEPARATOR));
        }
        else  if ((lcpar == "msgswitch")) (g_sMsgSwitch = val);
        else  if ((lcpar == "msgon")) (g_sMsgOn = val);
        else  if ((lcpar == "msgoff")) (g_sMsgOff = val);
        else  if ((lcpar == "msgmenu")) (g_sMsgMenu = val);
        else  if ((lcpar == "extnumber")) (g_iExtNumber = ((integer)val));
        else  if ((lcpar == "burndown")) (g_iBurnDown = checkYesNo("burndown",val));
        else  if ((lcpar == "burntime")) (g_fBurnTime = ((float)checkInt("burnTime",((integer)val),1,315360000)));
        else  if ((lcpar == "dietime")) (g_fDieTime = ((float)checkInt("dieTime",((integer)val),1,315360000)));
        else  if ((lcpar == "loop")) (g_iLoop = checkYesNo("loop",val));
        else  if ((lcpar == "changelight")) {
            (g_iChangeLight = checkYesNo("changeLight",val));
            (g_sConfLine += (((lcpar + "=") + ((string)g_iChangeLight)) + SEPARATOR));
        }
        else  if ((lcpar == "changesmoke")) (g_iChangeSmoke = checkYesNo("changeSmoke",val));
        else  if ((lcpar == "changevolume")) (g_iDefChangeVolume = checkYesNo("changeVolume",val));
        else  if ((lcpar == "singlefire")) {
            (g_iSingleFire = checkYesNo("singleFire",val));
            (g_sConfLine += (((lcpar + "=") + ((string)g_iSingleFire)) + SEPARATOR));
        }
        else  if ((lcpar == "size")) (g_iDefSize = checkInt("size",((integer)val),0,100));
        else  if ((lcpar == "topcolor")) {
            vector _val2 = ((vector)val);
            if ((_val2 == ZERO_VECTOR)) {
                (_val2 = <100.0,100.0,100.0>);
                llWhisper(0,("[Notecard] topColor out of range, corrected to " + ((string)_val2)));
            }
            (g_vDefEndColor = _val2);
            (g_sConfLine += (((lcpar + "=") + ((string)g_vDefEndColor)) + SEPARATOR));
        }
        else  if ((lcpar == "bottomcolor")) {
            vector _val5 = ((vector)val);
            if ((_val5 == ZERO_VECTOR)) {
                (_val5 = <100.0,100.0,100.0>);
                llWhisper(0,("[Notecard] bottomColor out of range, corrected to " + ((string)_val5)));
            }
            (g_vDefStartColor = _val5);
            (g_sConfLine += (((lcpar + "=") + ((string)g_vDefStartColor)) + SEPARATOR));
        }
        else  if ((lcpar == "volume")) (g_iDefVolume = checkInt("volume",((integer)val),0,100));
        else  if (("particlefire" == lcpar)) (g_iDefParticleFire = checkYesNo("particlefire",val));
        else  if (("lowprim" == lcpar)) (g_iLowprim = checkYesNo("lowprim",val));
        else  if (("primfire" == lcpar)) (g_iDefPrimFire = checkYesNo("primfire",val));
        else  if ((lcpar == "smoke")) (g_iDefSmoke = checkYesNo("smoke",val));
        else  if ((lcpar == "sound")) (g_iDefSound = checkYesNo("sound",val));
        else  if ((lcpar == "intensity")) {
            (g_iDefIntensity = checkInt("intensity",((integer)val),0,100));
            (g_sConfLine += (((lcpar + "=") + ((string)g_iDefIntensity)) + SEPARATOR));
        }
        else  if ((lcpar == "radius")) {
            (g_iDefRadius = checkInt("radius",((integer)val),0,100));
            (g_sConfLine += (((lcpar + "=") + ((string)g_iDefRadius)) + SEPARATOR));
        }
        else  if ((lcpar == "falloff")) {
            (g_iDefFalloff = checkInt("falloff",((integer)val),0,100));
            (g_sConfLine += (((lcpar + "=") + ((string)g_iDefFalloff)) + SEPARATOR));
        }
        else  llWhisper(0,((("Unknown parameter in notecard line " + ((string)(g_iLine + 1))) + ": ") + par));
    }
    (g_iLine++);
    (g_kQuery = llGetNotecardLine(NOTECARD,g_iLine));
}


menuDialog(key id){
    (g_iMenuOpen = 1);
    string sParticleFire = "N/A";
    if (g_iParticleFireAvail) {
        if (g_iParticleFireOn) (sParticleFire = "ON");
        else  (sParticleFire = "OFF");
    }
    string sPrimFire = "N/A";
    if (g_iPrimFireAvail) {
        if (g_iPrimFireOn) {
            if (g_iLowprim) (sPrimFire = "ON (temp)");
            else  (sPrimFire = "ON");
        }
        else  (sPrimFire = "OFF");
    }
    string strSmoke = "N/A";
    if (g_iSmokeAvail) {
        if (g_iSmokeOn) (strSmoke = "ON");
        else  (strSmoke = "OFF");
    }
    string strSound = "N/A";
    if ((g_iSoundAvail || g_iBackSoundAvail)) {
        if (g_iSoundOn) {
            if ((g_iBackSoundAvail && g_iSoundAvail)) (strSound = "ON");
            else  if (g_iBackSoundAvail) (strSound = "ON (back)");
            else  (strSound = "ON (normal)");
        }
        else  (strSound = "OFF");
    }
    (menuChannel = ((integer)(llFrand(-1.0e9) - 1.0e9)));
    llListenRemove(g_iMenuHandle);
    (g_iMenuHandle = llListen(menuChannel,"","",""));
    llSetTimerEvent(0.0);
    llSetTimerEvent(120.0);
    llDialog(id,(((((((((((((((g_sTitle + " ") + g_sVersion) + "\n\nSize: ") + ((string)((integer)g_fPerSize))) + "%\t\tVolume: ") + ((string)g_iPerVolume)) + "%") + "\nParticleFire: ") + sParticleFire) + "\tSmoke: ") + strSmoke) + "\tSound: ") + strSound) + "\nPrimFire:\t ") + sPrimFire),["Options","FastToggle","Close","-Volume","+Volume","---","-Fire","+Fire","---","Small","Medium","Large"],menuChannel);
}


endColorDialog(key id){
    (g_iMenuOpen = 1);
    (g_iEndColorChannel = ((integer)(llFrand(-1.0e9) - 1.0e9)));
    llListenRemove(g_iEndColorHandle);
    (g_iEndColorHandle = llListen(g_iEndColorChannel,"","",""));
    llSetTimerEvent(0.0);
    llSetTimerEvent(120.0);
    llDialog(id,(((((((("Top color\n\nRed: " + ((string)g_iPerRedEnd)) + "%") + "\nGreen: ") + ((string)g_iPerGreenEnd)) + "%") + "\nBlue: ") + ((string)g_iPerBlueEnd)) + "%"),["Bottom color","One color","^Options","-Blue","+Blue","B min/max","-Green","+Green","G min/max","-Red","+Red","R min/max"],g_iEndColorChannel);
}


optionsDialog(key kId){
    (g_iMenuOpen = 1);
    string sParticleFire = "N/A";
    if (g_iParticleFireAvail) {
        if (g_iParticleFireOn) (sParticleFire = "ON");
        else  (sParticleFire = "OFF");
    }
    string sPrimFire = "N/A";
    if (g_iPrimFireAvail) {
        if (g_iPrimFireOn) {
            if (g_iLowprim) (sPrimFire = "ON, (temp)");
            else  (sPrimFire = "ON");
        }
        else  (sPrimFire = "OFF");
    }
    string strSmoke = "N/A";
    if (g_iSmokeAvail) {
        if (g_iSmokeOn) (strSmoke = "ON");
        else  (strSmoke = "OFF");
    }
    string strSound = "N/A";
    if ((g_iSoundAvail || g_iBackSoundAvail)) {
        if (g_iSoundOn) {
            if ((g_iBackSoundAvail && g_iSoundAvail)) (strSound = "ON");
            else  if (g_iBackSoundAvail) (strSound = "ON (back)");
            else  (strSound = "ON (normal)");
        }
        else  (strSound = "OFF");
    }
    string sVerbose = "???";
    if (g_iVerbose) {
        if (g_iVerboseButton) (sVerbose = "ON");
        else  (sVerbose = "part. ON");
    }
    else  if (g_iVerboseButton) (sVerbose = "OFF");
    (g_iOptionsChannel = ((integer)(llFrand(-1.0e9) - 1.0e9)));
    llListenRemove(g_iOptionsHandle);
    (g_iOptionsHandle = llListen(g_iOptionsChannel,"","",""));
    llSetTimerEvent(0.0);
    llSetTimerEvent(120.0);
    llDialog(kId,((((((((("\t\tOptions\n\nParticleFire: " + sParticleFire) + "\tSmoke: ") + strSmoke) + "\tSound: ") + strSound) + "\nPrimFire:\t ") + sPrimFire) + "\t\t\t\tVerbose: ") + sVerbose),["^Main menu","RESET","Close","Color","FastToggle","Verbose","PrimFire","---","---","ParticleFire","Smoke","Sound"],g_iOptionsChannel);
}


reset(){
    (g_iParticleFireOn = g_iDefParticleFire);
    (g_iPrimFireOn = g_iDefPrimFire);
    (g_iSmokeOn = g_iDefSmoke);
    (g_iSoundOn = g_iDefSound);
    (g_iChangeVolume = g_iDefChangeVolume);
    (g_fPerSize = ((float)g_iDefSize));
    (g_iPerVolume = g_iDefVolume);
    (g_iPerRedStart = ((integer)g_vDefStartColor.x));
    (g_iPerGreenStart = ((integer)g_vDefStartColor.y));
    (g_iPerBlueStart = ((integer)g_vDefStartColor.z));
    (g_iPerRedEnd = ((integer)g_vDefEndColor.x));
    (g_iPerGreenEnd = ((integer)g_vDefEndColor.y));
    (g_iPerBlueEnd = ((integer)g_vDefEndColor.z));
    sendMessage(COMMAND_CHANNEL,"config","reset");
    sendMessage(COMMAND_CHANNEL,"off","");
    if (((!silent) && g_iVerbose)) llWhisper(0,"(v) The fire gets taken care off");
}


startSystem(){
    
    if ((!g_iOn)) sendMessage(g_iExtNumber,"1","");
    llSetTimerEvent(0.0);
    if (g_iMenuOpen) {
        llListenRemove(g_iMenuHandle);
        llListenRemove(g_iStartColorHandle);
        llListenRemove(g_iEndColorHandle);
        llListenRemove(g_iOptionsHandle);
        (g_iMenuOpen = 0);
    }
    (g_fPercent = 100.0);
    (g_fPercentSmoke = 100.0);
    if ((g_iSoundAvail || g_iBackSoundAvail)) {
        float per = ((float)g_iPerVolume);
        float num = 1.0;
        (g_fStartVolume = ((num / 100.0) * per));
    }
    if ((!g_iOn)) {
        if ((g_iSoundAvail && g_iSoundOn)) sendMessage(SOUND_CHANNEL,"110",((string)g_fStartVolume));
        if (((!silent) && g_iVerbose)) llWhisper(0,"(v) The fire gets lit");
    }
    float size = g_fPerSize;
    (g_fSoundVolume = g_fStartVolume);
    if ((size <= 25.0)) {
        if ((g_iChangeSmoke && g_iSmokeAvail)) (g_fPercentSmoke = (size * 4.0));
        else  (g_fPercentSmoke = 100.0);
        
        if (((g_iSoundAvail || g_iBackSoundAvail) && g_iChangeVolume)) {
            float _num3 = g_fStartVolume;
            (g_fSoundVolume = ((_num3 / 100.0) * (size * 4.0)));
        }
    }
    if ((g_iPrimFireAvail && g_iPrimFireOn)) sendMessage(ANIM_CHANNEL,((string)size),((string)g_iLowprim));
    if ((g_iSmokeAvail && g_iSmokeOn)) sendMessage(PARTICLE_CHANNEL,((string)llRound(g_fPercentSmoke)),"smoke");
    if ((g_iSoundAvail || g_iBackSoundAvail)) {
        if (((0 <= size) && (100 >= size))) (g_sCurrentSound = ((string)size));
        if (g_iSoundOn) sendMessage(SOUND_CHANNEL,g_sCurrentSound,((string)g_fSoundVolume));
        else  sendMessage(SOUND_CHANNEL,g_sCurrentSound,"0");
    }
    if ((g_iParticleFireAvail && g_iParticleFireOn)) sendMessage(PARTICLE_CHANNEL,((string)size),"fire");
    llSetTimerEvent(g_fBurnTime);
    (g_iOn = 1);
    (g_iBurning = 1);
}


stopSystem(){
    if ((((!silent) && g_iVerbose) && g_iOn)) llWhisper(0," (v) The fire is dying down");
    if (g_iOn) sendMessage(g_iExtNumber,"0","");
    (g_iOn = 0);
    (g_iBurning = 0);
    (g_fPercent = 0.0);
    (g_fPercentSmoke = 0.0);
    llSetTimerEvent(0.0);
    if (g_iPrimFireOn) sendMessage(ANIM_CHANNEL,"0","");
    if ((g_iSmokeOn || g_iParticleFireOn)) sendMessage(PARTICLE_CHANNEL,"0","");
    if ((g_iSoundAvail || g_iBackSoundAvail)) sendMessage(SOUND_CHANNEL,"0","0");
    if (g_iMenuOpen) {
        llListenRemove(g_iMenuHandle);
        llListenRemove(g_iStartColorHandle);
        llListenRemove(g_iEndColorHandle);
        llListenRemove(g_iOptionsHandle);
        (g_iMenuOpen = 0);
    }
}


//===============================================================================
//= parameters   :    integer  iChan        determines the script (function) to talk to
//=                   string   sVal         Value to set, also on/off (0 - 100)
//=                   string   sMsg         for sound: description of fire size, values > 100 (110) when lightning fire
//=
//= return        :    none
//=
//= description  :    forwards settings to functions/other scripts
//=
//===============================================================================
sendMessage(integer iChan,string sVal,string sMsg){
    string sDefGroup = LINKSETID;
    if (("" == sDefGroup)) (sDefGroup = "Default");
    string str = llStringTrim(llGetObjectDesc(),3);
    if (((llToLower(str) == "(no description)") || (str == ""))) (str = sDefGroup);
    else  {
        list lGroup = llParseString2List(str,[" "],[]);
        (str = llList2String(lGroup,0));
    }
    string sId = ((str + SEPARATOR) + g_sScriptName);
    string sSet = ((sVal + SEPARATOR) + sMsg);
    if ((g_iSingleFire && (("fire" == sMsg) || (ANIM_CHANNEL == iChan)))) jump thisprim;
    else  if ((0 && ("smoke" == sMsg))) jump thisprim;
    else  if ((0 && (SOUND_CHANNEL == iChan))) jump thisprim;
    llMessageLinked(-1,iChan,sSet,((key)sId));
    return;
    @thisprim;
    llMessageLinked(-4,iChan,sSet,((key)sId));
}


// pragma inline
integer max(integer x,integer y){
    if ((x > y)) return x;
    else  return y;
}


// pragma inline
integer min(integer x,integer y){
    if ((x < y)) return x;
    else  return y;
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        MESSAGE_MAP();
        (g_kOwner = llGetOwner());
        (g_sScriptName = llGetScriptName());
        stopSystem();
        sendMessage(COMMAND_CHANNEL,"register","");
        if (((!silent) && g_iVerbose)) llWhisper(0,"(v) Loading notecard...");
        loadNotecard();
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	changed(integer change) {
        if ((change & 1)) {
            (g_iParticleFireAvail = (g_iParticleFireOn = 0));
            (g_iPrimFireAvail = (g_iPrimFireOn = 0));
            (g_iSmokeAvail = (g_iSmokeOn = 0));
            (g_iSoundAvail = (g_iBackSoundAvail = (g_iDefSound = (g_iSoundOn = 0))));
            sendMessage(COMMAND_CHANNEL,"register","");
            if ((!silent)) llWhisper(0,"Inventory changed, reloading notecard...");
            loadNotecard();
        }
    }


	touch_start(integer total_number) {
        (g_kUser = llDetectedKey(0));
        if ((!silent)) llRegionSayTo(g_kUser,0,"*Long touch to show menu*");
        llResetTime();
    }



	touch_end(integer total_number) {
        if ((llGetTime() > 2.0)) {
            key kUser = g_kUser;
            integer iAccess = g_iMenuAccess;
            integer iBitmask = 1;
            if ((kUser == g_kOwner)) (iBitmask += 4);
            if (llSameGroup(kUser)) (iBitmask += 2);
            if ((iBitmask & iAccess)) {
                if ((!g_iOn)) toggleFunktion("fire");
                menuDialog(g_kUser);
            }
            else  llInstantMessage(g_kUser,"[Menu] Access denied");
        }
        else  {
            key _kUser4 = g_kUser;
            integer _iAccess5 = g_iSwitchAccess;
            integer _iBitmask6 = 1;
            if ((_kUser4 == g_kOwner)) (_iBitmask6 += 4);
            if (llSameGroup(_kUser4)) (_iBitmask6 += 2);
            if ((_iBitmask6 & _iAccess5)) toggleFunktion("fire");
            else  llInstantMessage(g_kUser,"[Switch] Access denied");
        }
    }


	listen(integer channel,string name,key kId,string msg) {
        
        if ((channel == menuChannel)) {
            llListenRemove(g_iMenuHandle);
            if ((msg == "Small")) (g_fPerSize = 25.0);
            else  if ((msg == "Medium")) (g_fPerSize = 50.0);
            else  if ((msg == "Large")) (g_fPerSize = 80.0);
            else  if ((msg == "-Fire")) {
                integer _ret0;
                integer x = (((integer)g_fPerSize) - 5);
                if ((x > 5)) {
                    (_ret0 = x);
                }
                else  {
                    (_ret0 = 5);
                }
                (g_fPerSize = _ret0);
            }
            else  if ((msg == "+Fire")) {
                integer _ret2;
                integer _x4 = (((integer)g_fPerSize) + 5);
                if ((_x4 < 100)) {
                    (_ret2 = _x4);
                }
                else  {
                    (_ret2 = 100);
                }
                (g_fPerSize = _ret2);
            }
            else  if ((msg == "-Volume")) {
                integer _ret5;
                integer _x7 = (g_iPerVolume - 5);
                if ((_x7 > 0)) {
                    (_ret5 = _x7);
                }
                else  {
                    (_ret5 = 0);
                }
                (g_iPerVolume = _ret5);
                float per = g_iPerVolume;
                (g_fStartVolume = (1.0e-2 * per));
            }
            else  if ((msg == "+Volume")) {
                integer _ret10;
                integer _x12 = (g_iPerVolume + 5);
                if ((_x12 < 100)) {
                    (_ret10 = _x12);
                }
                else  {
                    (_ret10 = 100);
                }
                (g_iPerVolume = _ret10);
                float _per15 = g_iPerVolume;
                (g_fStartVolume = (1.0e-2 * _per15));
            }
            else  if (("FastToggle" == msg)) {
                if ((((g_iSmokeOn || g_iSoundOn) || g_iParticleFireOn) || g_iPrimFireOn)) {
                    sendMessage(COMMAND_CHANNEL,"off","");
                    (g_iParticleFireOn = (g_iSmokeOn = (g_iSoundOn = (g_iPrimFireOn = 0))));
                }
                else  {
                    if (((!g_iParticleFireOn) && g_iParticleFireAvail)) toggleFunktion("particlefire");
                    if (((!g_iPrimFireOn) && g_iPrimFireAvail)) toggleFunktion("primfire");
                    if (((!g_iSmokeOn) && g_iSmokeAvail)) toggleFunktion("smoke");
                    if (((!g_iSoundOn) && (g_iSoundAvail || g_iBackSoundAvail))) toggleFunktion("sound");
                }
            }
            if (((msg != "Close") && ("Options" != msg))) {
                if (("FastToggle" != msg)) {
                    float size = g_fPerSize;
                    (g_fSoundVolume = g_fStartVolume);
                    if ((size <= 25.0)) {
                        if ((g_iChangeSmoke && g_iSmokeAvail)) (g_fPercentSmoke = (size * 4.0));
                        else  (g_fPercentSmoke = 100.0);
                        
                        if (((g_iSoundAvail || g_iBackSoundAvail) && g_iChangeVolume)) {
                            float num = g_fStartVolume;
                            (g_fSoundVolume = ((num / 100.0) * (size * 4.0)));
                        }
                    }
                    if ((g_iPrimFireAvail && g_iPrimFireOn)) sendMessage(ANIM_CHANNEL,((string)size),((string)g_iLowprim));
                    if ((g_iSmokeAvail && g_iSmokeOn)) sendMessage(PARTICLE_CHANNEL,((string)llRound(g_fPercentSmoke)),"smoke");
                    if ((g_iSoundAvail || g_iBackSoundAvail)) {
                        if (((0 <= size) && (100 >= size))) (g_sCurrentSound = ((string)size));
                        if (g_iSoundOn) sendMessage(SOUND_CHANNEL,g_sCurrentSound,((string)g_fSoundVolume));
                        else  sendMessage(SOUND_CHANNEL,g_sCurrentSound,"0");
                    }
                    if ((g_iParticleFireAvail && g_iParticleFireOn)) sendMessage(PARTICLE_CHANNEL,((string)size),"fire");
                }
                menuDialog(kId);
            }
            else  if ((msg == "Options")) optionsDialog(kId);
            else  if ((msg == "Close")) {
                llSetTimerEvent(0.0);
                llSetTimerEvent(g_fBurnTime);
                (g_iMenuOpen = 0);
            }
        }
        if ((channel == g_iOptionsChannel)) {
            llListenRemove(g_iOptionsHandle);
            if ((("ParticleFire" == msg) && g_iParticleFireAvail)) toggleFunktion("particlefire");
            else  if ((("PrimFire" == msg) && g_iPrimFireAvail)) toggleFunktion("primfire");
            else  if (((msg == "Smoke") && g_iSmokeAvail)) toggleFunktion("smoke");
            else  if (((msg == "Sound") && (g_iSoundAvail || g_iBackSoundAvail))) toggleFunktion("sound");
            else  if ((msg == "Color")) endColorDialog(kId);
            else  if (("Verbose" == msg)) {
                if ((g_iVerbose && g_iVerboseButton)) {
                    sendMessage(COMMAND_CHANNEL,"nonverbose","");
                    (g_iVerbose = 0);
                }
                else  {
                    sendMessage(COMMAND_CHANNEL,"verbose","");
                    (g_iVerbose = 1);
                    llWhisper(0,((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors));
                    if ((!silent)) llWhisper(0,"Touch to start/stop fire\n *Long touch to show menu*");
                    if (((!silent) && g_iVerbose)) {
                        integer access = g_iSwitchAccess;
                        string strAccess;
                        if (access) {
                            if ((access & 4)) (strAccess += " Owner");
                            if ((access & 2)) (strAccess += " Group");
                            if ((access & 1)) (strAccess += " World");
                        }
                        else  {
                            (strAccess = " None");
                        }
                        llWhisper(0,("(v) Switch access:" + strAccess));
                        integer _access4 = g_iMenuAccess;
                        string _strAccess5;
                        if (_access4) {
                            if ((_access4 & 4)) (_strAccess5 += " Owner");
                            if ((_access4 & 2)) (_strAccess5 += " Group");
                            if ((_access4 & 1)) (_strAccess5 += " World");
                        }
                        else  {
                            (_strAccess5 = " None");
                        }
                        llWhisper(0,("(v) Menu access:" + _strAccess5));
                        llWhisper(0,("(v) Channel for remote control: " + ((string)g_iMsgNumber)));
                        llWhisper(0,((((("\n\t -free memory: " + ((string)llGetFreeMemory())) + " -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
                    }
                }
                (g_iVerboseButton = 1);
            }
            else  if (("FastToggle" == msg)) {
                if ((((g_iSmokeOn || g_iSoundOn) || g_iParticleFireOn) || g_iPrimFireOn)) {
                    sendMessage(COMMAND_CHANNEL,"off","");
                    (g_iParticleFireOn = (g_iSmokeOn = (g_iSoundOn = (g_iPrimFireOn = 0))));
                }
                else  {
                    if (((!g_iParticleFireOn) && g_iParticleFireAvail)) toggleFunktion("particlefire");
                    if (((!g_iPrimFireOn) && g_iPrimFireAvail)) toggleFunktion("primfire");
                    if (((!g_iSmokeOn) && g_iSmokeAvail)) toggleFunktion("smoke");
                    if (((!g_iSoundOn) && (g_iSoundAvail || g_iBackSoundAvail))) toggleFunktion("sound");
                }
            }
            else  if ((msg == "RESET")) {
                reset();
                startSystem();
            }
            if (((("Color" != msg) && (msg != "^Main menu")) && ("Close" != msg))) {
                optionsDialog(kId);
            }
            else  if ((msg == "^Main menu")) menuDialog(kId);
            else  if ((msg == "Close")) {
                llSetTimerEvent(0.0);
                llSetTimerEvent(g_fBurnTime);
                (g_iMenuOpen = 0);
            }
        }
        else  if ((channel == g_iStartColorChannel)) {
            
            llListenRemove(g_iStartColorHandle);
            {
                if ((msg == "-Red")) (g_iPerRedStart = max((g_iPerRedStart - 10),0));
                else  if ((msg == "-Green")) (g_iPerGreenStart = max((g_iPerGreenStart - 10),0));
                else  if ((msg == "-Blue")) (g_iPerBlueStart = max((g_iPerBlueStart - 10),0));
                else  if ((msg == "+Red")) (g_iPerRedStart = min((g_iPerRedStart + 10),100));
                else  if ((msg == "+Green")) (g_iPerGreenStart = min((g_iPerGreenStart + 10),100));
                else  if ((msg == "+Blue")) (g_iPerBlueStart = min((g_iPerBlueStart + 10),100));
                else  if ((msg == "R min/max")) {
                    if (g_iPerRedStart) (g_iPerRedStart = 0);
                    else  (g_iPerRedStart = 100);
                }
                else  if ((msg == "G min/max")) {
                    if (g_iPerGreenStart) (g_iPerGreenStart = 0);
                    else  (g_iPerGreenStart = 100);
                }
                else  if ((msg == "B min/max")) {
                    if (g_iPerBlueStart) (g_iPerBlueStart = 0);
                    else  (g_iPerBlueStart = 100);
                }
                else  if ((msg == "One color")) {
                    (g_iPerRedEnd = g_iPerRedStart);
                    (g_iPerGreenEnd = g_iPerGreenStart);
                    (g_iPerBlueEnd = g_iPerBlueStart);
                }
            }
            if (((msg != "Top color") && (msg != "^Main menu"))) {
                
                sendMessage(COMMAND_CHANNEL,"config",("startcolor=" + msg));
                (g_iMenuOpen = 1);
                (g_iStartColorChannel = ((integer)(llFrand(-1.0e9) - 1.0e9)));
                llListenRemove(g_iStartColorHandle);
                (g_iStartColorHandle = llListen(g_iStartColorChannel,"","",""));
                llSetTimerEvent(0.0);
                llSetTimerEvent(120.0);
                llDialog(kId,(((((((("Bottom color\n\nRed: " + ((string)g_iPerRedStart)) + "%") + "\nGreen: ") + ((string)g_iPerGreenStart)) + "%") + "\nBlue: ") + ((string)g_iPerBlueStart)) + "%"),["Top color","One color","^Main menu","-Blue","+Blue","B min/max","-Green","+Green","G min/max","-Red","+Red","R min/max"],g_iStartColorChannel);
            }
            else  if ((msg == "Top color")) endColorDialog(kId);
            else  if ((msg == "^Main menu")) menuDialog(kId);
        }
        else  if ((channel == g_iEndColorChannel)) {
            
            llListenRemove(g_iEndColorHandle);
            {
                if ((msg == "-Red")) (g_iPerRedEnd = max((g_iPerRedEnd - 10),0));
                else  if ((msg == "-Green")) (g_iPerGreenEnd = max((g_iPerGreenEnd - 10),0));
                else  if ((msg == "-Blue")) (g_iPerBlueEnd = max((g_iPerBlueEnd - 10),0));
                else  if ((msg == "+Red")) (g_iPerRedEnd = min((g_iPerRedEnd + 10),100));
                else  if ((msg == "+Green")) (g_iPerGreenEnd = min((g_iPerGreenEnd + 10),100));
                else  if ((msg == "+Blue")) (g_iPerBlueEnd = min((g_iPerBlueEnd + 10),100));
                else  if ((msg == "R min/max")) {
                    if (g_iPerRedEnd) (g_iPerRedEnd = 0);
                    else  (g_iPerRedEnd = 100);
                }
                else  if ((msg == "G min/max")) {
                    if (g_iPerGreenEnd) (g_iPerGreenEnd = 0);
                    else  (g_iPerGreenEnd = 100);
                }
                else  if ((msg == "B min/max")) {
                    if (g_iPerBlueEnd) (g_iPerBlueEnd = 0);
                    else  (g_iPerBlueEnd = 100);
                }
                else  if ((msg == "One color")) {
                    (g_iPerRedStart = g_iPerRedEnd);
                    (g_iPerGreenStart = g_iPerGreenEnd);
                    (g_iPerBlueStart = g_iPerBlueEnd);
                }
            }
            if (((msg != "Bottom color") && (msg != "^Options"))) {
                
                sendMessage(COMMAND_CHANNEL,"config",("endcolor=" + msg));
                endColorDialog(kId);
            }
            else  if ((msg == "Bottom color")) {
                (g_iMenuOpen = 1);
                (g_iStartColorChannel = ((integer)(llFrand(-1.0e9) - 1.0e9)));
                llListenRemove(g_iStartColorHandle);
                (g_iStartColorHandle = llListen(g_iStartColorChannel,"","",""));
                llSetTimerEvent(0.0);
                llSetTimerEvent(120.0);
                llDialog(kId,(((((((("Bottom color\n\nRed: " + ((string)g_iPerRedStart)) + "%") + "\nGreen: ") + ((string)g_iPerGreenStart)) + "%") + "\nBlue: ") + ((string)g_iPerBlueStart)) + "%"),["Top color","One color","^Main menu","-Blue","+Blue","B min/max","-Green","+Green","G min/max","-Red","+Red","R min/max"],g_iStartColorChannel);
            }
            else  if ((msg == "^Options")) optionsDialog(kId);
        }
    }


//listen for linked messages from other RealFire scripts and devices
//-----------------------------------------------
	link_message(integer iSender_number,integer iChan,string sMsg,key kId) {
        
        if ((iChan == COMMAND_CHANNEL)) return;
        string _ret0;
        string sDefGroup = LINKSETID;
        if (("" == sDefGroup)) (sDefGroup = "Default");
        string _str2 = llStringTrim(llGetObjectDesc(),3);
        if (((llToLower(_str2) == "(no description)") || (_str2 == ""))) (_str2 = sDefGroup);
        else  {
            list lGroup = llParseString2List(_str2,[" "],[]);
            (_str2 = llList2String(lGroup,0));
        }
        string str = _str2;
        list lKeys = llParseString2List(((string)kId),[SEPARATOR],[]);
        string sGroup = llList2String(lKeys,0);
        string _sScriptName2 = llList2String(lKeys,1);
        if ((((str == sGroup) || (LINKSETID == sGroup)) || (LINKSETID == str))) {
            (_ret0 = _sScriptName2);
            jump _end1;
        }
        (_ret0 = "exit");
        @_end1;
        string sScriptName = _ret0;
        if (("exit" == sScriptName)) return;
        if (((iChan == ANIM_CHANNEL) && (llToLower(sScriptName) != llToLower(g_sScriptName)))) {
            if ((sScriptName == PRIMFIREANIMSCRIPT)) {
                if (("1" == sMsg)) {
                    (g_iPrimFireAvail = 1);
                    if ((!silent)) llWhisper(0,"PrimFire available");
                    if ((g_iDefPrimFire && g_iOn)) {
                        (g_iPrimFireOn = (!g_iPrimFireOn));
                        toggleFunktion("primfire");
                    }
                }
                else  (g_iPrimFireAvail = 0);
            }
            if ((sScriptName == TEXTUREANIMSCRIPT)) {
                if (("1" == sMsg)) {
                    if ((!silent)) llWhisper(0,"Texture animations available");
                }
            }
            if (("1" != sMsg)) llWhisper(0,(("Unable to provide animations (" + sScriptName) + ")"));
        }
        else  if (((iChan == PARTICLE_CHANNEL) && (llToLower(sScriptName) != llToLower(g_sScriptName)))) {
            if ((sScriptName == PARTICLEFIREANIMSCRIPT)) {
                if (("1" == sMsg)) {
                    (g_iParticleFireAvail = 1);
                    if (("" != g_sConfLine)) sendMessage(COMMAND_CHANNEL,"config",g_sConfLine);
                    if ((!silent)) llWhisper(0,"ParticleFire available");
                    if ((g_iDefParticleFire && g_iOn)) {
                        (g_iParticleFireOn = (!g_iParticleFireOn));
                        toggleFunktion("particlefire");
                    }
                }
                else  (g_iParticleFireAvail = 0);
            }
            if ((sScriptName == SMOKESCRIPT)) {
                if (("1" == sMsg)) {
                    (g_iSmokeAvail = 1);
                    if ((!silent)) llWhisper(0,"Smoke available");
                    if ((g_iDefSmoke && g_iOn)) {
                        (g_iSmokeOn = (!g_iSmokeOn));
                        toggleFunktion("smoke");
                    }
                }
                else  (g_iSmokeAvail = 0);
            }
            if (("1" != sMsg)) llWhisper(0,(("Unable to provide particle effects (" + sScriptName) + ")"));
        }
        else  if (((iChan == SOUND_CHANNEL) && (llToLower(sScriptName) != llToLower(g_sScriptName)))) {
            if ((sScriptName == SOUNDSCRIPT)) {
                if (("1" == sMsg)) {
                    (g_iSoundAvail = 1);
                    if ((!silent)) llWhisper(0,"Noise available");
                    if ((g_iDefSound && g_iOn)) {
                        (g_iSoundOn = (!g_iSoundOn));
                        toggleFunktion("sound");
                    }
                }
                else  (g_iSoundAvail = 0);
            }
            else  if ((sScriptName == BACKSOUNDSCRIPT)) {
                if (("1" == sMsg)) {
                    (g_iBackSoundAvail = 1);
                    if ((!silent)) llWhisper(0,"Ambience sound available");
                    if ((g_iDefSound && g_iOn)) {
                        (g_iSoundOn = (!g_iSoundOn));
                        toggleFunktion("sound");
                    }
                }
                else  (g_iBackSoundAvail = 0);
            }
            if (("1" != sMsg)) llWhisper(0,(("Unable to provide sound effects (" + sScriptName) + ")"));
        }
        else  if ((iChan == REMOTE_CHANNEL)) {
            if (("1" == sMsg)) {
                if ((!silent)) llWhisper(0,"Remote receiver activated");
                if (("" != g_sConfLine)) sendMessage(COMMAND_CHANNEL,"config",g_sConfLine);
            }
        }
        else  if ((iChan == g_iMsgNumber)) {
            if (kId) {
            }
            else  {
                llWhisper(0,"A valid avatar key must be provided in the link message.");
                return;
            }
            if ((sMsg == g_sMsgSwitch)) {
                integer iAccess = g_iSwitchAccess;
                integer iBitmask = 1;
                if ((kId == g_kOwner)) (iBitmask += 4);
                if (llSameGroup(kId)) (iBitmask += 2);
                if ((iBitmask & iAccess)) toggleFunktion("fire");
                else  llInstantMessage(kId,"[Switch] Access denied");
            }
            else  if ((sMsg == g_sMsgOn)) {
                integer _iAccess7 = g_iSwitchAccess;
                integer _iBitmask8 = 1;
                if ((kId == g_kOwner)) (_iBitmask8 += 4);
                if (llSameGroup(kId)) (_iBitmask8 += 2);
                if ((_iBitmask8 & _iAccess7)) startSystem();
                else  llInstantMessage(kId,"[Switch] Access denied");
            }
            else  if ((sMsg == g_sMsgOff)) {
                integer _iAccess11 = g_iSwitchAccess;
                integer _iBitmask12 = 1;
                if ((kId == g_kOwner)) (_iBitmask12 += 4);
                if (llSameGroup(kId)) (_iBitmask12 += 2);
                if ((_iBitmask12 & _iAccess11)) stopSystem();
                else  llInstantMessage(kId,"[Switch] Access denied");
            }
            else  if ((sMsg == g_sMsgMenu)) {
                integer _iAccess15 = g_iMenuAccess;
                integer _iBitmask16 = 1;
                if ((kId == g_kOwner)) (_iBitmask16 += 4);
                if (llSameGroup(kId)) (_iBitmask16 += 2);
                if ((_iBitmask16 & _iAccess15)) {
                    startSystem();
                    menuDialog(kId);
                }
                else  llInstantMessage(kId,"[Menu] Access denied");
            }
        }
    }


//get presets from notecard
//-----------------------------------------------
	dataserver(key kQuery_id,string data) {
        if ((kQuery_id != g_kQuery)) return;
        if ((data != EOF)) {
            readNotecard(data);
        }
        else  {
            
            if ((!g_iBurnDown)) (g_fBurnTime = 315360000);
            (g_fTime = (g_fDieTime / 100.0));
            if ((g_fTime < 1.0)) (g_fTime = 1.0);
            (g_fDecPercent = (100.0 / (g_fDieTime / g_fTime)));
            (g_vDefStartColor.x = checkInt("ColorOn (RED)",((integer)g_vDefStartColor.x),0,100));
            (g_vDefStartColor.y = checkInt("ColorOn (GREEN)",((integer)g_vDefStartColor.y),0,100));
            (g_vDefStartColor.z = checkInt("ColorOn (BLUE)",((integer)g_vDefStartColor.z),0,100));
            (g_vDefEndColor.x = checkInt("ColorOff (RED)",((integer)g_vDefEndColor.x),0,100));
            (g_vDefEndColor.y = checkInt("ColorOff (GREEN)",((integer)g_vDefEndColor.y),0,100));
            (g_vDefEndColor.z = checkInt("ColorOff (BLUE)",((integer)g_vDefEndColor.z),0,100));
            float per = ((float)g_iDefVolume);
            (g_fStartVolume = (1.0e-2 * per));
            if (("" != g_sConfLine)) sendMessage(COMMAND_CHANNEL,"config",g_sConfLine);
            reset();
            if (g_iOn) startSystem();
            if (g_iVerbose) {
                llWhisper(0,((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors));
                if ((!silent)) llWhisper(0,"Touch to start/stop fire\n *Long touch to show menu*");
                if (((!silent) && g_iVerbose)) {
                    integer access = g_iSwitchAccess;
                    string strAccess;
                    if (access) {
                        if ((access & 4)) (strAccess += " Owner");
                        if ((access & 2)) (strAccess += " Group");
                        if ((access & 1)) (strAccess += " World");
                    }
                    else  {
                        (strAccess = " None");
                    }
                    llWhisper(0,("(v) Switch access:" + strAccess));
                    integer _access4 = g_iMenuAccess;
                    string _strAccess5;
                    if (_access4) {
                        if ((_access4 & 4)) (_strAccess5 += " Owner");
                        if ((_access4 & 2)) (_strAccess5 += " Group");
                        if ((_access4 & 1)) (_strAccess5 += " World");
                    }
                    else  {
                        (_strAccess5 = " None");
                    }
                    llWhisper(0,("(v) Menu access:" + _strAccess5));
                    llWhisper(0,("(v) Channel for remote control: " + ((string)g_iMsgNumber)));
                    llWhisper(0,((((("\n\t -free memory: " + ((string)llGetFreeMemory())) + " -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
                }
            }
            
        }
    }


	timer() {
        if (g_iMenuOpen) {
            llWhisper(0,"MENU TIMEOUT");
            llListenRemove(g_iMenuHandle);
            llListenRemove(g_iStartColorHandle);
            llListenRemove(g_iEndColorHandle);
            llListenRemove(g_iOptionsHandle);
            llSetTimerEvent(0.0);
            llSetTimerEvent(g_fBurnTime);
            (g_iMenuOpen = 0);
            return;
        }
        if (g_iBurning) {
            llSetTimerEvent(0);
            llSetTimerEvent(g_fTime);
            (g_iBurning = 0);
        }
        if ((g_fPercent >= g_fDecPercent)) {
            (g_fPercent -= g_fDecPercent);
            float size = (g_fPercent / (100.0 / g_fPerSize));
            (g_fSoundVolume = g_fStartVolume);
            if ((size <= 25.0)) {
                if ((g_iChangeSmoke && g_iSmokeAvail)) (g_fPercentSmoke = (size * 4.0));
                else  (g_fPercentSmoke = 100.0);
                
                if (((g_iSoundAvail || g_iBackSoundAvail) && g_iChangeVolume)) {
                    float num = g_fStartVolume;
                    (g_fSoundVolume = ((num / 100.0) * (size * 4.0)));
                }
            }
            if ((g_iPrimFireAvail && g_iPrimFireOn)) sendMessage(ANIM_CHANNEL,((string)size),((string)g_iLowprim));
            if ((g_iSmokeAvail && g_iSmokeOn)) sendMessage(PARTICLE_CHANNEL,((string)llRound(g_fPercentSmoke)),"smoke");
            if ((g_iSoundAvail || g_iBackSoundAvail)) {
                if (((0 <= size) && (100 >= size))) (g_sCurrentSound = ((string)size));
                if (g_iSoundOn) sendMessage(SOUND_CHANNEL,g_sCurrentSound,((string)g_fSoundVolume));
                else  sendMessage(SOUND_CHANNEL,g_sCurrentSound,"0");
            }
            if ((g_iParticleFireAvail && g_iParticleFireOn)) sendMessage(PARTICLE_CHANNEL,((string)size),"fire");
        }
        else  {
            if (g_iLoop) startSystem();
            else  stopSystem();
        }
    }
}
