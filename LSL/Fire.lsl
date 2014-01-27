// LSL script generated: RealFire-Rene10957.LSL.Fire.lslp Mon Jan 27 06:05:39 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
// Realfire by Rene - Fire
//
// Author: Rene10957 Resident
// Date: 31-05-2013
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
// - Access control: owner, group, world
// - Touch to start or stop fire
// - Long touch to show menu

//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: initial structure for multiple sound files, implement linked_message system, background sound, LSLForge Modules
//27. Jan. 2014
//v2.2-0.81

//Files:
//Fire.lsl
//
//Smoke.lsl
//Sound.lsl
//config
//User Manual
//
//
//Prequisites: Smoke.lsl in another prim than Fire.lsl
//	Soundfiles need to be in same prim as Sound.lsl
//
//Notecard format: see config NC
//basic help: User Manual

//Changelog
//	Formatting
//	variable naming sheme
//	structure for multiple sound files
//	structure for multiple scripts
//	B-Sound

//bug: on notcard change, connection to smoke and sound gets lost

//todo: make sound configurable via notecard - maybe own config file?
//todo: keep sound running for a short time after turning fire off
//todo: sound preload on touch
//todo: sound seems to get called twice
//todo: integrate B-Sound  - use key in lllinkedmessage/link_message to differentiate; add backround sound off
//todo: scale for effect 0<=x<=100, -1 backround, 110 Sound start -- don't confuse with volume
//todo: prim fire / flexi prim (need to move/rotate it) / sculpted prims ----- temp rezzer 
//todo: sparkles
//todo: fire via particles, using textures?!
//todo: check //PSYS_PART_RIBBON_MASK effect
//todo: maybe en-/disable //PSYS_PART_WIND_MASK, if fire is out-/inside (test effect!)
//todo: test cone instead of explode (radius) + angle (placement)
//todo: longer break between automatic fire off and going on again, also make fire slowly bigger... and let fire burn down slower (look into function)
//todo: make 5% lowest setting (glowing)? and adjust fire (100%)  - is way too big for the fireplace
//todo: better smoke (color, intensity, change when fire changes) - rework smoke in updateSize (currently only changed when size<=25)
//todo: smoke with textures
//todo: check change smoke while smoke is off
//todo: let sound script do calculation of sound percentage, as smoke does it
//todo: add ping/pong with other scripts in case only fire.lsl gets resetted
//todo: if script in another prim is removed, Fire.lsl cannot handle the situation
//todo: move object animation to own script too?
//todo: ability to change burndown/restart
//todo: fire size = 0 - but sound on + volume --> at least background sound (glowing embers)
//todo: HUD?
//todo: play with llListen()
//todo: always check for llGetFreeMemory()
//todo: check if other particle scripts are in same prim
//todo: rethink system of verbose messages - use settings notecard!
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode = FALSE;


//user changeable variables
//-----------------------------------------------
string NOTECARD = "config";
string SOUNDSCRIPT = "Sound.lsl";
string BACKSOUNDSCRIPT = "B-Sound.lsl";

// Particle parameters
float g_fAge = 1.0;
float g_fRate = 0.1;
integer g_iCount = 10;
vector g_vStartScale = <0.4,2,0>;
vector g_vEndScale = <0.4,2,0>;
float g_fMinSpeed = 0.0;
float g_fMaxSpeed = 4.0e-2;
float g_fBurstRadius = 0.4;
vector g_vPartAccel = <0,0,10>;
vector g_vStartColor = <1,1,0>;
vector g_vEndColor = <1,0,0>;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire";
string g_sVersion = "2.2-0.81";
string g_sScriptName;
string g_sAuthors = "Rene10957, Zopf";


// Constants
integer ACCESS_OWNER = 4;
integer ACCESS_GROUP = 2;
integer ACCESS_WORLD = 1;
float MAX_COLOR = 1.0;
float MAX_INTENSITY = 1.0;
float MAX_RADIUS = 20.0;
float MAX_FALLOFF = 2.0;
float MAX_VOLUME = 1.0;

//RealFire MESSAGE MAP
integer COMMAND_CHANNEL = -10950;
integer SMOKE_CHANNEL = -10957;
integer SOUND_CHANNEL = -10956;


// Notecard variables
integer g_iVerbose = TRUE;
integer g_iSwitchAccess;
integer g_iMenuAccess;
integer g_iMsgNumber;
string g_sMsgSwitch;
string g_sMsgOn;
string g_sMsgOff;
string g_sMsgMenu;
integer g_iBurnDown = FALSE;
float g_fBurnTime;
float g_fDieTime;
integer g_iLoop = FALSE;
integer g_iChangeLight = TRUE;
integer g_iChangeSmoke = TRUE;
integer g_iChangeVolume = TRUE;
integer g_iDefSize;
vector g_vDefStartColor;
vector g_vDefEndColor;
integer g_iDefVolume;
integer g_iDefSmoke = TRUE;
integer g_iDefSound = FALSE;
string g_sCurrentSound = "55";
integer g_iDefIntensity;
integer g_iDefRadius;
integer g_iDefFalloff;

// Variables
key g_kOwner;
key g_kUser;
key g_kQuery = NULL_KEY;

integer g_iSmokeAvail = FALSE;
integer g_iSoundAvail = FALSE;
integer g_iBackSoundAvail = FALSE;

integer g_iLine;
integer menuChannel;
integer g_iStartColorChannel;
integer g_iEndColorChannel;
integer g_iMenuHandle;
integer g_iStartColorHandle;
integer g_iEndColorHandle;
integer g_iPerRedStart;
integer g_iPerGreenStart;
integer g_iPerBlueStart;
integer g_iPerRedEnd;
integer g_iPerGreenEnd;
integer g_iPerBlueEnd;
integer g_iPerSize;
integer g_iPerVolume;
integer g_iOn = FALSE;
integer g_iBurning = FALSE;
integer g_iSmokeOn = FALSE;
integer g_iSoundOn = FALSE;
integer g_iMenuOpen = FALSE;
float g_fTime;
float g_fPercent;
float g_fPercentSmoke;
float g_fDecPercent;
vector g_vLightColor;
float g_fLightIntensity;
float g_fLightRadius;
float g_fLightFalloff;
float g_fSoundVolume = 0.0;
float g_fSoundVolumeTmp;
float g_fStartIntensity;
float g_fStartRadius;
float g_fStartVolume;

//###
//Debug.lslm
//0.1 - 14Jan2014
//###


//===============================================================================
//= parameters   :    string    sMsg    message string received
//=
//= return        :    none
//=
//= description  :    output debug messages
//=
//===============================================================================
Debug(string sMsg){
    if ((!g_iDebugMode)) return;
    llOwnerSay(((("DEBUG: " + g_sScriptName) + "; ") + sMsg));
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
    Debug(("toggle function " + sFunction));
    if (("fire" == sFunction)) {
        if (g_iOn) stopSystem();
        else  startSystem();
    }
    else  if (("smoke" == sFunction)) {
        if (g_iSmokeOn) {
            sendMessage(SMOKE_CHANNEL,"0","");
            (g_iSmokeOn = FALSE);
        }
        else  {
            sendMessage(SMOKE_CHANNEL,((string)llRound(g_fPercentSmoke)),"");
            (g_iSmokeOn = TRUE);
        }
    }
    else  if (("sound" == sFunction)) {
        if (g_iSoundOn) {
            (g_fSoundVolumeTmp = g_fSoundVolume);
            (g_fSoundVolume = 0.0);
            sendMessage(SOUND_CHANNEL,((string)g_fSoundVolume),"");
            (g_iSoundOn = FALSE);
        }
        else  {
            if (((g_fSoundVolumeTmp > 0) && (g_fSoundVolumeTmp <= 1))) (g_fSoundVolume = g_fSoundVolumeTmp);
            if ((g_iSoundAvail || g_iBackSoundAvail)) sendMessage(SOUND_CHANNEL,((string)g_fSoundVolume),g_sCurrentSound);
            (g_iSoundOn = TRUE);
        }
    }
}


//most important function
//-----------------------------------------------
updateSize(float size){
    vector start;
    vector end;
    float min;
    float max;
    float radius;
    vector push;
    (end = ((g_vEndScale / 100.0) * size));
    (min = ((g_fMinSpeed / 100.0) * size));
    (max = ((g_fMaxSpeed / 100.0) * size));
    (push = ((g_vPartAccel / 100.0) * size));
    if ((g_iSoundAvail || g_iBackSoundAvail)) {
        (g_fSoundVolume = g_fStartVolume);
        if (((0 <= size) && (100 >= size))) (g_sCurrentSound = ((string)size));
        sendMessage(SOUND_CHANNEL,((string)g_fSoundVolume),g_sCurrentSound);
    }
    if ((size > 25.0)) {
        (start = ((g_vStartScale / 100.0) * size));
        (radius = ((g_fBurstRadius / 100.0) * size));
        if ((size >= 80.0)) llSetLinkTextureAnim(LINK_SET,(ANIM_ON | LOOP),ALL_SIDES,4,4,0,0,9);
        else  if ((size > 50.0)) llSetLinkTextureAnim(LINK_SET,(ANIM_ON | LOOP),ALL_SIDES,4,4,0,0,6);
        else  llSetLinkTextureAnim(LINK_SET,(ANIM_ON | LOOP),ALL_SIDES,4,4,0,0,4);
    }
    else  {
        if ((size >= 15.0)) llSetLinkTextureAnim(LINK_SET,(ANIM_ON | LOOP),ALL_SIDES,4,4,0,0,3);
        else  llSetLinkTextureAnim(LINK_SET,(ANIM_ON | LOOP),ALL_SIDES,4,4,0,0,1);
        (start = (g_vStartScale / 4.0));
        (radius = (g_fBurstRadius / 4.0));
        if ((size < 5.0)) {
            (start.y = (((g_vStartScale.y / 100.0) * size) * 5.0));
            if ((start.y < 0.25)) (start.y = 0.25);
        }
        if (g_iChangeLight) {
            (g_fLightIntensity = percentage((size * 4.0),g_fStartIntensity));
            (g_fLightRadius = percentage((size * 4.0),g_fStartRadius));
        }
        else  {
            (g_fLightIntensity = g_fStartIntensity);
            (g_fLightRadius = g_fStartRadius);
        }
        if ((g_iChangeSmoke && g_iSmokeAvail)) (g_fPercentSmoke = (size * 4.0));
        else  (g_fPercentSmoke = 100.0);
        Debug(((((("Smoke size: change= " + ((string)g_iChangeSmoke)) + ", size= ") + ((string)size)) + ", percentage= ") + ((string)g_fPercentSmoke)));
        if ((g_iSoundAvail || g_iBackSoundAvail)) {
            if (g_iChangeVolume) {
                if (g_iSoundOn) (g_fSoundVolume = percentage((size * 4.0),g_fStartVolume));
                else  (g_fSoundVolumeTmp = percentage((size * 4.0),g_fStartVolume));
            }
            else  if (g_iSoundOn) (g_fSoundVolume = g_fStartVolume);
            else  (g_fSoundVolumeTmp = g_fStartVolume);
        }
    }
    updateColor();
    updateParticles(start,end,min,max,radius,push);
    llSetPrimitiveParams([PRIM_POINT_LIGHT,TRUE,g_vLightColor,g_fLightIntensity,g_fLightRadius,g_fLightFalloff]);
    if ((g_iSmokeAvail && g_iSmokeOn)) sendMessage(SMOKE_CHANNEL,((string)llRound(g_fPercentSmoke)),"");
    if (((g_iSoundAvail || g_iBackSoundAvail) && g_iSoundOn)) sendMessage(SOUND_CHANNEL,((string)g_fSoundVolume),"");
    Debug(((((((string)llRound(size)) + "% ") + ((string)start)) + " ") + ((string)end)));
}

updateColor(){
    (g_vStartColor.x = percentage(((float)g_iPerRedStart),MAX_COLOR));
    (g_vStartColor.y = percentage(((float)g_iPerGreenStart),MAX_COLOR));
    (g_vStartColor.z = percentage(((float)g_iPerBlueStart),MAX_COLOR));
    (g_vEndColor.x = percentage(((float)g_iPerRedEnd),MAX_COLOR));
    (g_vEndColor.y = percentage(((float)g_iPerGreenEnd),MAX_COLOR));
    (g_vEndColor.z = percentage(((float)g_iPerBlueEnd),MAX_COLOR));
    (g_vLightColor = ((g_vStartColor + g_vEndColor) / 2.0));
}

integer accessGranted(key kUser,integer iAccess){
    integer iBitmask = ACCESS_WORLD;
    if ((kUser == g_kOwner)) (iBitmask += ACCESS_OWNER);
    if (llSameGroup(kUser)) (iBitmask += ACCESS_GROUP);
    return (iBitmask & iAccess);
}

string showAccess(integer access){
    string strAccess;
    if (access) {
        if ((access & ACCESS_OWNER)) (strAccess += " Owner");
        if ((access & ACCESS_GROUP)) (strAccess += " Group");
        if ((access & ACCESS_WORLD)) (strAccess += " World");
    }
    else  {
        (strAccess = " None");
    }
    return strAccess;
}

integer checkInt(string par,integer val,integer min,integer max){
    if (((val < min) || (val > max))) {
        if ((val < min)) (val = min);
        else  if ((val > max)) (val = max);
        llWhisper(0,((("[Notecard] " + par) + " out of range, corrected to ") + ((string)val)));
    }
    return val;
}

vector checkVector(string par,vector val){
    if ((val == ZERO_VECTOR)) {
        (val = <100,100,100>);
        llWhisper(0,((("[Notecard] " + par) + " out of range, corrected to ") + ((string)val)));
    }
    return val;
}

integer checkYesNo(string par,string val){
    if ((llToLower(val) == "yes")) return TRUE;
    if ((llToLower(val) == "no")) return FALSE;
    llWhisper(0,(("[Notecard] " + par) + " out of range, corrected to NO"));
    return FALSE;
}

loadNotecard(){
    (g_iLine = 0);
    if ((llGetInventoryType(NOTECARD) == INVENTORY_NOTECARD)) {
        Debug("loadNotecard, NC avail");
        (g_kQuery = llGetNotecardLine(NOTECARD,g_iLine));
    }
    else  {
        llWhisper(0,(("Notecard \"" + NOTECARD) + "\" not found or empty, using defaults"));
        (g_iVerbose = TRUE);
        (g_iSwitchAccess = ACCESS_WORLD);
        (g_iMenuAccess = ACCESS_WORLD);
        (g_iMsgNumber = 10957);
        (g_sMsgSwitch = "switch");
        (g_sMsgOn = "on");
        (g_sMsgOff = "off");
        (g_sMsgMenu = "menu");
        (g_iBurnDown = FALSE);
        (g_fBurnTime = 300.0);
        (g_fDieTime = 300.0);
        (g_iLoop = FALSE);
        (g_iChangeLight = TRUE);
        (g_iChangeSmoke = TRUE);
        (g_iChangeVolume = TRUE);
        (g_iDefSize = 25);
        (g_vDefStartColor = <100,100,0>);
        (g_vDefEndColor = <100,0,0>);
        (g_iDefVolume = 100);
        (g_iDefSmoke = TRUE);
        (g_iDefSound = FALSE);
        (g_iDefIntensity = 100);
        (g_iDefRadius = 50);
        (g_iDefFalloff = 40);
        if ((!g_iBurnDown)) (g_fBurnTime = 315360000);
        (g_fTime = (g_fDieTime / 100.0));
        if ((g_fTime < 1.0)) (g_fTime = 1.0);
        (g_fDecPercent = (100.0 / (g_fDieTime / g_fTime)));
        (g_fStartIntensity = percentage(g_iDefIntensity,MAX_INTENSITY));
        (g_fStartRadius = percentage(g_iDefRadius,MAX_RADIUS));
        (g_fLightFalloff = percentage(g_iDefFalloff,MAX_FALLOFF));
        (g_fStartVolume = percentage(g_iDefVolume,MAX_VOLUME));
        reset();
        if (g_iOn) startSystem();
        if (g_iVerbose) InfoLines();
        if (g_iDebugMode) {
            llOwnerSay(("verbose = " + ((string)g_iVerbose)));
            llOwnerSay(("switchAccess = " + ((string)g_iSwitchAccess)));
            llOwnerSay(("menuAccess = " + ((string)g_iMenuAccess)));
            llOwnerSay(("msgNumber = " + ((string)g_iMsgNumber)));
            llOwnerSay(("msgSwitch = " + g_sMsgSwitch));
            llOwnerSay(("msgOn = " + g_sMsgOn));
            llOwnerSay(("msgOff = " + g_sMsgOff));
            llOwnerSay(("msgMenu = " + g_sMsgMenu));
            llOwnerSay(("burnDown = " + ((string)g_iBurnDown)));
            llOwnerSay(("burnTime = " + ((string)g_fBurnTime)));
            llOwnerSay(("dieTime = " + ((string)g_fDieTime)));
            llOwnerSay(("loop = " + ((string)g_iLoop)));
            llOwnerSay(("changeLight = " + ((string)g_iChangeLight)));
            llOwnerSay(("changeSmoke = " + ((string)g_iChangeSmoke)));
            llOwnerSay(("changeVolume = " + ((string)g_iChangeVolume)));
            llOwnerSay(("defSize = " + ((string)g_iDefSize)));
            llOwnerSay(("defStartColor = " + ((string)g_vDefStartColor)));
            llOwnerSay(("defEndColor = " + ((string)g_vDefEndColor)));
            llOwnerSay(("defVolume = " + ((string)g_iDefVolume)));
            llOwnerSay(("defSmoke = " + ((string)g_iDefSmoke)));
            llOwnerSay(("defSound = " + ((string)g_iDefSound)));
            llOwnerSay(("defIntensity = " + ((string)g_iDefIntensity)));
            llOwnerSay(("defRadius = " + ((string)g_iDefRadius)));
            llOwnerSay(("defFalloff = " + ((string)g_iDefFalloff)));
            llOwnerSay(("time = " + ((string)g_fTime)));
            llOwnerSay(("decPercent = " + ((string)g_fDecPercent)));
        }
    }
}

readNotecard(string ncLine){
    string ncData = llStringTrim(ncLine,STRING_TRIM);
    if (((llStringLength(ncData) > 0) && (llGetSubString(ncData,0,0) != "#"))) {
        list ncList = llParseString2List(ncData,["=","#"],[]);
        string par = llList2String(ncList,0);
        string val = llList2String(ncList,1);
        (par = llStringTrim(par,STRING_TRIM));
        (val = llStringTrim(val,STRING_TRIM));
        string lcpar = llToLower(par);
        if ((lcpar == "verbose")) (g_iVerbose = checkYesNo("verbose",val));
        else  if ((lcpar == "switchaccess")) (g_iSwitchAccess = checkInt("switchAccess",((integer)val),0,7));
        else  if ((lcpar == "menuaccess")) (g_iMenuAccess = checkInt("menuAccess",((integer)val),0,7));
        else  if ((lcpar == "msgnumber")) (g_iMsgNumber = ((integer)val));
        else  if ((lcpar == "msgswitch")) (g_sMsgSwitch = val);
        else  if ((lcpar == "msgon")) (g_sMsgOn = val);
        else  if ((lcpar == "msgoff")) (g_sMsgOff = val);
        else  if ((lcpar == "msgmenu")) (g_sMsgMenu = val);
        else  if ((lcpar == "burndown")) (g_iBurnDown = checkYesNo("burndown",val));
        else  if ((lcpar == "burntime")) (g_fBurnTime = ((float)checkInt("burnTime",((integer)val),1,315360000)));
        else  if ((lcpar == "dietime")) (g_fDieTime = ((float)checkInt("dieTime",((integer)val),1,315360000)));
        else  if ((lcpar == "loop")) (g_iLoop = checkYesNo("loop",val));
        else  if ((lcpar == "changelight")) (g_iChangeLight = checkYesNo("changeLight",val));
        else  if ((lcpar == "changesmoke")) (g_iChangeSmoke = checkYesNo("changeSmoke",val));
        else  if ((lcpar == "changevolume")) (g_iChangeVolume = checkYesNo("changeVolume",val));
        else  if ((lcpar == "size")) (g_iDefSize = checkInt("size",((integer)val),0,100));
        else  if ((lcpar == "topcolor")) (g_vDefEndColor = checkVector("topColor",((vector)val)));
        else  if ((lcpar == "bottomcolor")) (g_vDefStartColor = checkVector("bottomColor",((vector)val)));
        else  if ((lcpar == "volume")) (g_iDefVolume = checkInt("volume",((integer)val),0,100));
        else  if ((lcpar == "smoke")) (g_iDefSmoke = checkYesNo("smoke",val));
        else  if ((lcpar == "sound")) (g_iDefSound = checkYesNo("sound",val));
        else  if ((lcpar == "intensity")) (g_iDefIntensity = checkInt("intensity",((integer)val),0,100));
        else  if ((lcpar == "radius")) (g_iDefRadius = checkInt("radius",((integer)val),0,100));
        else  if ((lcpar == "falloff")) (g_iDefFalloff = checkInt("falloff",((integer)val),0,100));
        else  llWhisper(0,((("Unknown parameter in notecard line " + ((string)(g_iLine + 1))) + ": ") + par));
    }
    (g_iLine++);
    (g_kQuery = llGetNotecardLine(NOTECARD,g_iLine));
}

menuDialog(key id){
    (g_iMenuOpen = TRUE);
    string strSmoke = "N/A";
    if (g_iSmokeAvail) {
        if (g_iSmokeOn) (strSmoke = "ON");
        else  (strSmoke = "OFF");
    }
    string strSound = "N/A";
    if ((g_iSoundAvail || g_iBackSoundAvail)) {
        if (g_iSoundOn) (strSound = "ON");
        else  (strSound = "OFF");
    }
    (menuChannel = ((integer)(llFrand((-1.0e9)) - 1.0e9)));
    llListenRemove(g_iMenuHandle);
    (g_iMenuHandle = llListen(menuChannel,"","",""));
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id,(((((((((((g_sTitle + " ") + g_sVersion) + "\n\nSize: ") + ((string)g_iPerSize)) + "%\t\tVolume: ") + ((string)g_iPerVolume)) + "%") + "\nSmoke: ") + strSmoke) + "\t\tSound: ") + strSound),["Smoke","Sound","Close","-Volume","+Volume","Reset","-Fire","+Fire","Color","Small","Medium","Large"],menuChannel);
}

startColorDialog(key id){
    (g_iMenuOpen = TRUE);
    (g_iStartColorChannel = ((integer)(llFrand((-1.0e9)) - 1.0e9)));
    llListenRemove(g_iStartColorHandle);
    (g_iStartColorHandle = llListen(g_iStartColorChannel,"","",""));
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id,((((((((("Bottom color" + "\n\nRed: ") + ((string)g_iPerRedStart)) + "%") + "\nGreen: ") + ((string)g_iPerGreenStart)) + "%") + "\nBlue: ") + ((string)g_iPerBlueStart)) + "%"),["Top color","One color","Main menu","-Blue","+Blue","B min/max","-Green","+Green","G min/max","-Red","+Red","R min/max"],g_iStartColorChannel);
}

endColorDialog(key id){
    (g_iMenuOpen = TRUE);
    (g_iEndColorChannel = ((integer)(llFrand((-1.0e9)) - 1.0e9)));
    llListenRemove(g_iEndColorHandle);
    (g_iEndColorHandle = llListen(g_iEndColorChannel,"","",""));
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id,((((((((("Top color" + "\n\nRed: ") + ((string)g_iPerRedEnd)) + "%") + "\nGreen: ") + ((string)g_iPerGreenEnd)) + "%") + "\nBlue: ") + ((string)g_iPerBlueEnd)) + "%"),["Bottom color","One color","Main menu","-Blue","+Blue","B min/max","-Green","+Green","G min/max","-Red","+Red","R min/max"],g_iEndColorChannel);
}

float percentage(float per,float num){
    return ((num / 100.0) * per);
}

integer min(integer x,integer y){
    if ((x < y)) return x;
    else  return y;
}

integer max(integer x,integer y){
    if ((x > y)) return x;
    else  return y;
}

reset(){
    if ((!g_iSmokeAvail)) (g_iSmokeOn = FALSE);
    else  (g_iSmokeOn = g_iDefSmoke);
    if (((!g_iSoundAvail) && (!g_iBackSoundAvail))) (g_iSoundOn = FALSE);
    else  (g_iSoundOn = g_iDefSound);
    (g_iPerSize = g_iDefSize);
    (g_iPerVolume = g_iDefVolume);
    (g_iPerRedStart = ((integer)g_vDefStartColor.x));
    (g_iPerGreenStart = ((integer)g_vDefStartColor.y));
    (g_iPerBlueStart = ((integer)g_vDefStartColor.z));
    (g_iPerRedEnd = ((integer)g_vDefEndColor.x));
    (g_iPerGreenEnd = ((integer)g_vDefEndColor.y));
    (g_iPerBlueEnd = ((integer)g_vDefEndColor.z));
    sendMessage(SMOKE_CHANNEL,"0","");
    sendMessage(SOUND_CHANNEL,"0","");
    llStopSound();
    if (g_iVerbose) llWhisper(0,"The fire get's taken care off");
}

startSystem(){
    Debug("startSystem");
    (g_fPercent = 100.0);
    (g_fPercentSmoke = 100.0);
    if ((g_iSmokeAvail && g_iSmokeOn)) {
        sendMessage(SMOKE_CHANNEL,((string)llRound(g_fPercentSmoke)),"");
    }
    (g_fLightIntensity = g_fStartIntensity);
    (g_fLightRadius = g_fStartRadius);
    if ((g_iSoundAvail || g_iBackSoundAvail)) {
        (g_fStartVolume = percentage(((float)g_iPerVolume),MAX_VOLUME));
        if (g_iSoundOn) sendMessage(SOUND_CHANNEL,((string)g_fStartVolume),"110");
    }
    if ((g_iVerbose && (!g_iOn))) llWhisper(0,"The fire gets lit");
    updateSize(((float)g_iPerSize));
    llSetTimerEvent(0);
    llSetTimerEvent(g_fBurnTime);
    if (g_iMenuOpen) {
        llListenRemove(g_iMenuHandle);
        llListenRemove(g_iStartColorHandle);
        llListenRemove(g_iEndColorHandle);
        (g_iMenuOpen = FALSE);
    }
    (g_iOn = TRUE);
    (g_iBurning = TRUE);
}

stopSystem(){
    if ((g_iVerbose && g_iOn)) llWhisper(0,"The fire is dying down");
    (g_iOn = FALSE);
    (g_iBurning = FALSE);
    (g_fPercent = 0.0);
    (g_fPercentSmoke = 0.0);
    llSetTimerEvent(0);
    llParticleSystem([]);
    llSetPrimitiveParams([PRIM_POINT_LIGHT,FALSE,ZERO_VECTOR,0,0,0]);
    if ((g_iSoundAvail || g_iBackSoundAvail)) sendMessage(SOUND_CHANNEL,"0","0");
    if (g_iSmokeAvail) sendMessage(SMOKE_CHANNEL,"0","");
    if (g_iMenuOpen) {
        llListenRemove(g_iMenuHandle);
        llListenRemove(g_iStartColorHandle);
        llListenRemove(g_iEndColorHandle);
        (g_iMenuOpen = FALSE);
    }
    llSleep(3);
    llSetLinkTextureAnim(LINK_SET,FALSE,ALL_SIDES,4,4,0,0,1);
}

updateParticles(vector start,vector end,float min,float max,float radius,vector push){
    llParticleSystem([PSYS_PART_FLAGS,(((0 | PSYS_PART_EMISSIVE_MASK) | PSYS_PART_INTERP_COLOR_MASK) | PSYS_PART_INTERP_SCALE_MASK),PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_EXPLODE,PSYS_SRC_BURST_RADIUS,radius,PSYS_PART_START_COLOR,g_vStartColor,PSYS_PART_END_COLOR,g_vEndColor,PSYS_PART_START_ALPHA,1.0,PSYS_PART_END_ALPHA,0.0,PSYS_PART_START_SCALE,start,PSYS_PART_END_SCALE,end,PSYS_PART_MAX_AGE,g_fAge,PSYS_SRC_BURST_RATE,g_fRate,PSYS_SRC_BURST_PART_COUNT,g_iCount,PSYS_SRC_ACCEL,push,PSYS_SRC_BURST_SPEED_MIN,min,PSYS_SRC_BURST_SPEED_MAX,max]);
}


//===============================================================================
//= parameters   :    integer	iChan		determines the script (function) to talk to
//=					string	sVal			Value to set, also on/off (0 - 100)
//=					string	sMsg			for sound: description of fire size
//=
//= return        :    none
//=
//= description  :    forwards settings to functions/other scripts
//=
//===============================================================================
sendMessage(integer iChan,string sVal,string sMsg){
    if ((iChan == SMOKE_CHANNEL)) {
        llMessageLinked(LINK_ALL_OTHERS,SMOKE_CHANNEL,sVal,((key)g_sScriptName));
    }
    else  if ((iChan == SOUND_CHANNEL)) {
        string sSoundSet = ((sVal + ",") + sMsg);
        llMessageLinked(LINK_SET,SOUND_CHANNEL,sSoundSet,((key)g_sScriptName));
    }
}

InfoLines(){
    llWhisper(0,("Switch access:" + showAccess(g_iSwitchAccess)));
    llWhisper(0,("Menu access:" + showAccess(g_iMenuAccess)));
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

    state_entry() {
        (g_kOwner = llGetOwner());
        (g_sScriptName = llGetScriptName());
        stopSystem();
        Debug(("Particle count: " + ((string)llRound(((((float)g_iCount) * g_fAge) / g_fRate)))));
        Debug((((string)llGetFreeMemory()) + " bytes free"));
        llWhisper(0,((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors));
        llWhisper(0,"Touch to start/stop fire\n *Long touch to show menu*");
        llMessageLinked(LINK_SET,COMMAND_CHANNEL,"register",((key)g_sScriptName));
        if (g_iVerbose) llWhisper(0,"Loading notecard...");
        loadNotecard();
    }


    on_rez(integer start_param) {
        llResetScript();
    }

	
    changed(integer change) {
        if ((change & CHANGED_INVENTORY)) {
            (g_iSmokeAvail = (g_iSmokeOn = FALSE));
            (g_iSoundAvail = (g_iBackSoundAvail = (g_iDefSound = (g_iSoundOn = FALSE))));
            llWhisper(0,"Inventory changed, reloading notecard...");
            loadNotecard();
        }
    }

	
    touch_start(integer total_number) {
        llResetTime();
    }


    touch_end(integer total_number) {
        (g_kUser = llDetectedKey(0));
        if ((llGetTime() > 2.0)) {
            if (accessGranted(g_kUser,g_iMenuAccess)) {
                if ((!g_iOn)) toggleFunktion("fire");
                menuDialog(g_kUser);
            }
            else  llInstantMessage(g_kUser,"[Menu] Access denied");
        }
        else  {
            if (accessGranted(g_kUser,g_iSwitchAccess)) toggleFunktion("fire");
            else  llInstantMessage(g_kUser,"[Switch] Access denied");
        }
    }


    listen(integer channel,string name,key id,string msg) {
        Debug(((("LISTEN event: " + ((string)channel)) + "; ") + msg));
        if ((channel == menuChannel)) {
            llListenRemove(g_iMenuHandle);
            if ((msg == "Small")) (g_iPerSize = 20);
            else  if ((msg == "Medium")) (g_iPerSize = 55);
            else  if ((msg == "Large")) (g_iPerSize = 80);
            else  if ((msg == "-Fire")) (g_iPerSize = max((g_iPerSize - 5),5));
            else  if ((msg == "+Fire")) (g_iPerSize = min((g_iPerSize + 5),100));
            else  if ((msg == "-Volume")) {
                (g_iPerVolume = max((g_iPerVolume - 5),5));
                (g_fStartVolume = percentage(g_iPerVolume,MAX_VOLUME));
                if (g_iSoundOn) (g_fSoundVolume = g_fStartVolume);
                else  (g_fSoundVolumeTmp = g_fStartVolume);
            }
            else  if ((msg == "+Volume")) {
                (g_iPerVolume = min((g_iPerVolume + 5),100));
                (g_fStartVolume = percentage(g_iPerVolume,MAX_VOLUME));
                if (g_iSoundOn) (g_fSoundVolume = g_fStartVolume);
                else  (g_fSoundVolumeTmp = g_fStartVolume);
            }
            else  if (((msg == "Smoke") && g_iSmokeAvail)) toggleFunktion("smoke");
            else  if (((msg == "Sound") && (g_iSoundAvail || g_iBackSoundAvail))) toggleFunktion("sound");
            else  if ((msg == "Color")) endColorDialog(g_kUser);
            else  if ((msg == "Reset")) {
                reset();
                startSystem();
            }
            else  if ((msg == "Close")) {
                llSetTimerEvent(0);
                llSetTimerEvent(g_fBurnTime);
                (g_iMenuOpen = FALSE);
            }
            if (((msg != "Color") && (msg != "Close"))) {
                if ((((msg != "Smoke") && (msg != "Sound")) && (msg != "Reset"))) updateSize(((float)g_iPerSize));
                menuDialog(g_kUser);
            }
        }
        else  if ((channel == g_iStartColorChannel)) {
            llListenRemove(g_iStartColorHandle);
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
            else  if ((msg == "Top color")) endColorDialog(g_kUser);
            else  if ((msg == "Main menu")) menuDialog(g_kUser);
            else  if ((msg == "One color")) {
                (g_iPerRedEnd = g_iPerRedStart);
                (g_iPerGreenEnd = g_iPerGreenStart);
                (g_iPerBlueEnd = g_iPerBlueStart);
            }
            if (((msg != "Top color") && (msg != "Main menu"))) {
                updateSize(((float)g_iPerSize));
                startColorDialog(g_kUser);
            }
        }
        else  if ((channel == g_iEndColorChannel)) {
            llListenRemove(g_iEndColorHandle);
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
            else  if ((msg == "Bottom color")) startColorDialog(g_kUser);
            else  if ((msg == "Main menu")) menuDialog(g_kUser);
            else  if ((msg == "One color")) {
                (g_iPerRedStart = g_iPerRedEnd);
                (g_iPerGreenStart = g_iPerGreenEnd);
                (g_iPerBlueStart = g_iPerBlueEnd);
            }
            if (((msg != "Bottom color") && (msg != "Main menu"))) {
                updateSize(((float)g_iPerSize));
                endColorDialog(g_kUser);
            }
        }
    }

	
//listen for linked messages from other RealFire scripts and devices
//-----------------------------------------------
    link_message(integer iSender_number,integer iChan,string sMsg,key kId) {
        Debug(((((("link_message= channel" + ((string)iChan)) + "; Message ") + sMsg) + "; ") + ((string)kId)));
        if ((iChan == COMMAND_CHANNEL)) return;
        if ((iChan == SMOKE_CHANNEL)) {
            if (("1" == sMsg)) {
                (g_iSmokeAvail = TRUE);
                llWhisper(0,"Smoke effects available");
                if ((g_iDefSmoke && g_iOn)) {
                    (g_iSmokeOn = FALSE);
                    toggleFunktion("smoke");
                }
            }
            else  {
                (g_iSmokeAvail = FALSE);
                if (("0" == sMsg)) llWhisper(0,"Unable to provide smoke effects");
            }
        }
        else  if (((iChan == SOUND_CHANNEL) && (llToLower(((string)kId)) != llToLower(g_sScriptName)))) {
            if ((((string)kId) == SOUNDSCRIPT)) {
                if (("1" == sMsg)) {
                    (g_iSoundAvail = TRUE);
                    llWhisper(0,"Sound effects available");
                }
                else  (g_iSoundAvail = FALSE);
            }
            if ((((string)kId) == BACKSOUNDSCRIPT)) {
                if (("1" == sMsg)) {
                    (g_iBackSoundAvail = TRUE);
                    llWhisper(0,"Ambience sound available");
                }
                else  (g_iBackSoundAvail = FALSE);
            }
            if (("1" != sMsg)) llWhisper(0,(("Unable to provide sound effects (" + ((string)kId)) + ")"));
        }
        else  if ((iChan == g_iMsgNumber)) {
            if ((kId != "")) (g_kUser = kId);
            else  {
                llWhisper(0,"A valid avatar key must be provided in the link message.");
                return;
            }
            if ((sMsg == g_sMsgSwitch)) {
                if (accessGranted(g_kUser,g_iSwitchAccess)) toggleFunktion("fire");
                else  llInstantMessage(g_kUser,"[Switch] Access denied");
            }
            else  if ((sMsg == g_sMsgOn)) {
                if (accessGranted(g_kUser,g_iSwitchAccess)) startSystem();
                else  llInstantMessage(g_kUser,"[Switch] Access denied");
            }
            else  if ((sMsg == g_sMsgOff)) {
                if (accessGranted(g_kUser,g_iSwitchAccess)) stopSystem();
                else  llInstantMessage(g_kUser,"[Switch] Access denied");
            }
            else  if ((sMsg == g_sMsgMenu)) {
                if (accessGranted(g_kUser,g_iMenuAccess)) {
                    startSystem();
                    menuDialog(g_kUser);
                }
                else  llInstantMessage(g_kUser,"[Menu] Access denied");
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
            Debug("Dataserver, last line done");
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
            (g_fStartIntensity = percentage(g_iDefIntensity,MAX_INTENSITY));
            (g_fStartRadius = percentage(g_iDefRadius,MAX_RADIUS));
            (g_fLightFalloff = percentage(g_iDefFalloff,MAX_FALLOFF));
            (g_fStartVolume = percentage(((float)g_iDefVolume),MAX_VOLUME));
            reset();
            if (g_iOn) startSystem();
            if (g_iVerbose) InfoLines();
            if (g_iDebugMode) {
                llOwnerSay((((string)g_iLine) + " lines in notecard"));
                llOwnerSay(("verbose = " + ((string)g_iVerbose)));
                llOwnerSay(("switchAccess = " + ((string)g_iSwitchAccess)));
                llOwnerSay(("menuAccess = " + ((string)g_iMenuAccess)));
                llOwnerSay(("msgNumber = " + ((string)g_iMsgNumber)));
                llOwnerSay(("msgSwitch = " + g_sMsgSwitch));
                llOwnerSay(("msgOn = " + g_sMsgOn));
                llOwnerSay(("msgOff = " + g_sMsgOff));
                llOwnerSay(("msgMenu = " + g_sMsgMenu));
                llOwnerSay(("burnDown = " + ((string)g_iBurnDown)));
                llOwnerSay(("burnTime = " + ((string)g_fBurnTime)));
                llOwnerSay(("dieTime = " + ((string)g_fDieTime)));
                llOwnerSay(("loop = " + ((string)g_iLoop)));
                llOwnerSay(("changeLight = " + ((string)g_iChangeLight)));
                llOwnerSay(("changeSmoke = " + ((string)g_iChangeSmoke)));
                llOwnerSay(("changeVolume = " + ((string)g_iChangeVolume)));
                llOwnerSay(("defSize = " + ((string)g_iDefSize)));
                llOwnerSay(("defStartColor = " + ((string)g_vDefStartColor)));
                llOwnerSay(("defEndColor = " + ((string)g_vDefEndColor)));
                llOwnerSay(("defVolume = " + ((string)g_iDefVolume)));
                llOwnerSay(("defSmoke = " + ((string)g_iDefSmoke)));
                llOwnerSay(("defSound = " + ((string)g_iDefSound)));
                llOwnerSay(("defIntensity = " + ((string)g_iDefIntensity)));
                llOwnerSay(("defRadius = " + ((string)g_iDefRadius)));
                llOwnerSay(("defFalloff = " + ((string)g_iDefFalloff)));
                llOwnerSay(("time = " + ((string)g_fTime)));
                llOwnerSay(("decPercent = " + ((string)g_fDecPercent)));
            }
        }
    }


    timer() {
        if (g_iMenuOpen) {
            if (g_iVerbose) llWhisper(0,"MENU TIMEOUT");
            llListenRemove(g_iMenuHandle);
            llListenRemove(g_iStartColorHandle);
            llListenRemove(g_iEndColorHandle);
            llSetTimerEvent(0);
            llSetTimerEvent(g_fBurnTime);
            (g_iMenuOpen = FALSE);
            return;
        }
        if (g_iBurning) {
            llSetTimerEvent(0);
            llSetTimerEvent(g_fTime);
            (g_iBurning = FALSE);
        }
        if ((g_fPercent >= g_fDecPercent)) {
            (g_fPercent -= g_fDecPercent);
            updateSize((g_fPercent / (100.0 / ((float)g_iPerSize))));
        }
        else  {
            if (g_iLoop) startSystem();
            else  stopSystem();
        }
    }
}
