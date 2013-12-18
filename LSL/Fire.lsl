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
//Additions: initial structure for multiple sound files, implement linked_message system, background sound
//18. Dec. 2013
//v2.2-0.75

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
//todo: better way to handle sound change / not changing on fire size change
//todo: keep sound running for a short time after turning fire off
//todo: sound preload on touch
//todo: integrate B-Sound  - use key in lllinkedmessage/link_message to differentiate; add backround sound off
//todo: scale for effect 0<=x<=100, -1 backround, 110 Sound start -- don't confuse with volume
//todo: prim fire / temp rezzer / flexi prim
//todo: sparkles
//todo: fire via particles, using textures?!
//todo: check //PSYS_PART_RIBBON_MASK effect
//todo: maybe en-/disable //PSYS_PART_WIND_MASK, if fire is out-/inside (test effect!)
//todo: longer break between automatic fire off and going on again, also make fire slowly bigger... and let fire burn down slower (look into function)
//todo: make 5% lowest setting (glowing)? and adjust fire (100%)  - is way too big for the fireplace
//todo: better smoke (color, intensity, change when fire changes) - rework smoke in updateSize (currently only changed when size<=25)
//todo: check change smoke while smoke is off
//todo: let sound script do calculation of sound percentage, as smoke does it
//todo: add ping/pong with other scripts in case only fire.lsl gets resetted
//todo: if script in another prim is removed, Fire.lsl cannot handle the situation
//todo: move object animation to own script too?
//todo: ability to change burndown/restart
//todo: fire size = 0 - but sound on + volume --> at least background sound (glowing embers)
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//FIRESTORM SPECIFIC DEBUG STUFF
//===============================================

//#define FSDEBUG
//#include "fs_debug.lsl"


//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
string NOTECARD = "config";     // notecard name
string SOUNDSCRIPT = "Sound.lsl"; //normal sounds
string BACKSOUNDSCRIPT = "B-Sound.lsl"; //only one (backround, quieter) sound
string SMOKESCRIPT = "Smoke.lsl";	//script for smoke particles from a second prim
string SPARKSSCRIPT = "Sparks.lsl"; //script for particles from a third prim
string TEXTANIMSCRIPT = "Animation.lsl"; //script that handles texture animations (for each single prim)
string PRIMFIREANIMSCRIPT = "P-Anim.lsl"; //script to create temporary flexi prim (Fire)

// Particle parameters
float g_fAge = 1.0;                // particle lifetime
float g_fRate = 0.1;               // particle burst rate
integer g_iCount = 10;             // particle count
vector g_vStartScale = <0.4, 2, 0>;// particle start size (100%)
vector g_vEndScale = <0.4, 2, 0>;  // particle end size (100%)
float g_fMinSpeed = 0.0;           // particle min. burst speed (100%)
float g_fMaxSpeed = 0.04;          // particle max. burst speed (100%)
float g_fBurstRadius = 0.4;        // particle burst radius (100%)
vector g_vPartAccel = <0, 0, 10>;  // particle accelleration (100%)
vector g_vStartColor = <1, 1, 0>;  // particle start color
vector g_vEndColor = <1, 0, 0>;    // particle end color


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire";      // title
string g_sVersion = "2.2-0.75";         // version
string g_sScriptName;

// Constants
integer ACCESS_OWNER = 4;            // owner access bit
integer ACCESS_GROUP = 2;            // group access bit
integer ACCESS_WORLD = 1;            // world access bit
float MAX_COLOR = 1.0;             // max. red, green, blue
float MAX_INTENSITY = 1.0;       // max. light intensity
float MAX_RADIUS = 20.0;         // max. light radius
float MAX_FALLOFF = 2.0;         // max. light falloff
float MAX_VOLUME = 1.0;          // max. volume for sound

//RealFire MESSAGE MAP
integer SMOKE_CHANNEL = -10957;  // smoke channel
integer SOUND_CHANNEL = -10956;  // smoke channel


// Notecard variables
integer g_iVerbose = TRUE;         // show more/less info during startup
integer g_iSwitchAccess;           // access level for switch
integer g_iMenuAccess;             // access level for menu
integer g_iMsgNumber;              // number part of incoming link messages
string g_sMsgSwitch;               // string part of incoming link message: switch (on/off)
string g_sMsgOn;                   // string part of incoming link message: switch on
string g_sMsgOff;                  // string part of incoming link message: switch off
string g_sMsgMenu;                 // string part of incoming link message: show menu
integer g_iBurnDown = FALSE;       // burn down or burn continuously
float g_fBurnTime;                 // time to burn in seconds before starting to die
float g_fDieTime;                  // time it takes to die in seconds
integer g_iLoop = FALSE;           // restart after burning down
integer g_iChangeLight = TRUE;     // change light with fire
integer g_iChangeSmoke = TRUE;     // change smoke with fire
integer g_iChangeVolume = TRUE;    // change volume with fire
integer g_iDefSize;                // default fire size (percentage)
vector g_vDefStartColor;           // default start (bottom) color (percentage R,G,B)
vector g_vDefEndColor;             // default end (top) color (percentage R,G,B)
integer g_iDefVolume;              // default volume for sound (percentage)
integer g_iDefSmoke = TRUE;        // default smoke on/off
integer g_iDefSound = FALSE;  		// default sound on/off; keep off if SoundAvail
string g_sCurrentSound = "55";
integer g_iDefIntensity;           // default light intensity (percentage)
integer g_iDefRadius;              // default light radius (percentage)
integer g_iDefFalloff;             // default light falloff (percentage)

// Variables
key g_kOwner;                      // object owner
key g_kUser;                       // key of last avatar to touch object
key	g_kQuery = NULL_KEY;

integer g_iSmokeAvail = FALSE;		// true after script sucessfully registered for the task
integer g_iSoundAvail = FALSE;		// true after script sucessfully registered for the task
integer g_iBackSoundAvail = FALSE;

integer g_iLine;                   // notecard line
integer menuChannel;            // main menu channel
integer g_iStartColorChannel;      // start color menu channel
integer g_iEndColorChannel;        // end color menu channel
integer g_iMenuHandle;             // handle for main menu listener
integer g_iStartColorHandle;       // handle for start color menu listener
integer g_iEndColorHandle;         // handle for end color menu listener
integer g_iPerRedStart;            // percent red for startColor
integer g_iPerGreenStart;          // percent green for startColor
integer g_iPerBlueStart;           // percent blue for startColor
integer g_iPerRedEnd;              // percent red for endColor
integer g_iPerGreenEnd;            // percent green for endColor
integer g_iPerBlueEnd;             // percent blue for endColor
integer g_iPerSize;                // percent particle size
integer g_iPerVolume;              // percent volume
integer g_iOn = FALSE;             // fire on/off
integer g_iBurning = FALSE;        // burning constantly
integer g_iSmokeOn = FALSE;         // smoke on/off
integer g_iSoundOn = FALSE;         // sound on/off
integer g_iMenuOpen = FALSE;       // a menu is open or canceled (ignore button)
float g_fTime;                     // timer interval in seconds
float g_fPercent;                  // percentage of particle size
float g_fPercentSmoke;             // percentage of smoke
float g_fDecPercent;               // how much to burn down (%) every timer interval
vector g_vLightColor;              // light color
float g_fLightIntensity;           // light intensity (changed by burning down)
float g_fLightRadius;              // light radius (changed by burning down)
float g_fLightFalloff;             // light falloff
float g_fSoundVolume = 0.0;              // sound volume (changed by burning down)
float g_fSoundVolumeTmp;
float g_fStartIntensity;           // start value of lightIntensity (before burning down)
float g_fStartRadius;              // start value of lightRadius (before burning down)
float g_fStartVolume;              // start value of volume (before burning down)


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

//===============================================================================
//= parameters   :    string    sMsg    message string received
//=
//= return        :    none
//=
//= description  :    output debug messages
//=
//===============================================================================
Debug(string sMsg)
{
    if (!g_iDebugMode) return;
    llOwnerSay("DEBUG: "+ g_sScriptName + "; " + sMsg);
}

//===============================================================================
//= parameters   :    string    sFunction    which function to toggle
//=
//= return        :    none
//=
//= description  :    handle different function toggles (on/off with intensity)
//=
//===============================================================================
toggleFunktion(string sFunction)
{
	Debug("toggle function " + sFunction); 
	if ("fire" == sFunction) {
		if (g_iOn) stopSystem(); else startSystem();
	} else if ("smoke" == sFunction) {
	    if (g_iSmokeOn) {
			sendMessage(SMOKE_CHANNEL, "0", "");
			g_iSmokeOn = FALSE;
		} else {
			sendMessage(SMOKE_CHANNEL, (string)llRound(g_fPercentSmoke), "");
			g_iSmokeOn = TRUE;
		}
	} else if ("sound" == sFunction) {
		if (g_iSoundOn) {
			g_fSoundVolumeTmp = g_fSoundVolume;
			g_fSoundVolume = 0.0;
			sendMessage(SOUND_CHANNEL, (string)g_fSoundVolume, "");
			g_iSoundOn = FALSE;
		} else {
			if (g_fSoundVolumeTmp > 0 && g_fSoundVolumeTmp <= 1) g_fSoundVolume = g_fSoundVolumeTmp;
			if (g_iSoundAvail || g_iBackSoundAvail) sendMessage(SOUND_CHANNEL, (string)g_fSoundVolume, g_sCurrentSound);
			g_iSoundOn = TRUE;
		}
	}
}


//most important function
//-----------------------------------------------
updateSize(float size)
{
    vector start;
    vector end;
    float min;
    float max;
    float radius;
    vector push;

    end = g_vEndScale / 100.0 * size;             // end scale
    min = g_fMinSpeed / 100.0 * size;             // min. burst speed
    max = g_fMaxSpeed / 100.0 * size;             // max. burst speed
    push = g_vPartAccel / 100.0 * size;           // accelleration
	
	if (g_iSoundAvail || g_iBackSoundAvail) { //needs to be improved
		g_fSoundVolume = g_fStartVolume; //to start again with default (e.g. menu setting)
		if (0 <= size && 100 >= size) g_sCurrentSound = (string)size;
		sendMessage(SOUND_CHANNEL, (string)g_fSoundVolume, g_sCurrentSound);
	}
	
    if (size > 25.0) {
        start = g_vStartScale / 100.0 * size;     // start scale
        radius = g_fBurstRadius / 100.0 * size;   // burst radius
        if (size >= 80.0) llSetLinkTextureAnim(LINK_SET, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,9);
			else if (size > 50.0) llSetLinkTextureAnim(LINK_SET, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,6);
				else llSetLinkTextureAnim(LINK_SET, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,4);
    }
    else {
        if (size >= 15.0) llSetLinkTextureAnim(LINK_SET, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,3);
            else llSetLinkTextureAnim(LINK_SET, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,1);
        start = g_vStartScale / 4.0;              // start scale
        radius = g_fBurstRadius / 4.0;            // burst radius
        if (size < 5.0) {
            start.y = g_vStartScale.y / 100.0 * size * 5.0;
            if (start.y < 0.25) start.y = 0.25;
        }
        if (g_iChangeLight) {
            g_fLightIntensity = percentage(size * 4.0, g_fStartIntensity);
            g_fLightRadius = percentage(size * 4.0, g_fStartRadius);
        }
        else {
            g_fLightIntensity = g_fStartIntensity;
            g_fLightRadius = g_fStartRadius;
        }
        if (g_iChangeSmoke && g_iSmokeAvail) g_fPercentSmoke = size * 4.0; //works only here within range 0-100!!!
			else g_fPercentSmoke = 100.0;
		Debug("Smoke size: change= "+(string)g_iChangeSmoke+", size= "+(string)size +", percentage= "+(string)g_fPercentSmoke);
		if (g_iSoundAvail || g_iBackSoundAvail) {
			if (g_iChangeVolume) {
				if (g_iSoundOn) g_fSoundVolume = percentage(size * 4.0, g_fStartVolume);
					else g_fSoundVolumeTmp = percentage(size * 4.0, g_fStartVolume);
			} else 
				if (g_iSoundOn) g_fSoundVolume = g_fStartVolume;
					else g_fSoundVolumeTmp = g_fStartVolume;
		}
    }

    updateColor();
    updateParticles(start, end, min, max, radius, push);
    llSetPrimitiveParams([PRIM_POINT_LIGHT, TRUE, g_vLightColor, g_fLightIntensity, g_fLightRadius, g_fLightFalloff]);
    if (g_iSmokeAvail && g_iSmokeOn) sendMessage(SMOKE_CHANNEL, (string)llRound(g_fPercentSmoke), "");
	if ((g_iSoundAvail || g_iBackSoundAvail) && g_iSoundOn) sendMessage(SOUND_CHANNEL, (string)g_fSoundVolume, ""); //adjust Volume - currently only useful when volume-change on automatic fire change
    Debug((string)llRound(size) + "% " + (string)start + " " + (string)end);
}

updateColor()
{
    g_vStartColor.x = percentage((float)g_iPerRedStart, MAX_COLOR);
    g_vStartColor.y = percentage((float)g_iPerGreenStart, MAX_COLOR);
    g_vStartColor.z = percentage((float)g_iPerBlueStart, MAX_COLOR);

    g_vEndColor.x = percentage((float)g_iPerRedEnd, MAX_COLOR);
    g_vEndColor.y = percentage((float)g_iPerGreenEnd, MAX_COLOR);
    g_vEndColor.z = percentage((float)g_iPerBlueEnd, MAX_COLOR);

    g_vLightColor = (g_vStartColor + g_vEndColor) / 2.0; // light color = average of start & end color
}

integer accessGranted(key kUser, integer iAccess)
{
    integer iBitmask = ACCESS_WORLD;
    if (kUser == g_kOwner) iBitmask += ACCESS_OWNER;
    if (llSameGroup(kUser)) iBitmask += ACCESS_GROUP;
    return (iBitmask & iAccess);
}

string showAccess(integer access)
{
    string strAccess;
    if (access) {
        if (access & ACCESS_OWNER) strAccess += " Owner";
        if (access & ACCESS_GROUP) strAccess += " Group";
        if (access & ACCESS_WORLD) strAccess += " World";
    }
    else {
        strAccess = " None";
    }
    return strAccess;
}

integer checkInt(string par, integer val, integer min, integer max)
{
    if (val < min || val > max) {
        if (val < min) val = min;
        else if (val > max) val = max;
        llWhisper(0, "[Notecard] " + par + " out of range, corrected to " + (string)val);
    }
    return val;
}

vector checkVector(string par, vector val)
{
    if (val == ZERO_VECTOR) {
        val = <100,100,100>;
        llWhisper(0, "[Notecard] " + par + " out of range, corrected to " + (string)val);
    }
    return val;
}

integer checkYesNo(string par, string val)
{
    if (llToLower(val) == "yes") return TRUE;
    if (llToLower(val) == "no") return FALSE;
    llWhisper(0, "[Notecard] " + par + " out of range, corrected to NO");
    return FALSE;
}

loadNotecard()
{
	g_iLine = 0;
	if (llGetInventoryType(NOTECARD) == INVENTORY_NOTECARD) {
		Debug("loadNotecard, NC avail");
        g_kQuery = llGetNotecardLine(NOTECARD, g_iLine);
    } else {
		llWhisper(0, "Notecard \"" + NOTECARD + "\" not found or empty, using defaults");

		g_iVerbose = TRUE;
		g_iSwitchAccess = ACCESS_WORLD;
		g_iMenuAccess = ACCESS_WORLD;
		g_iMsgNumber = 10957;
		g_sMsgSwitch = "switch";
		g_sMsgOn = "on";
		g_sMsgOff = "off";
		g_sMsgMenu = "menu";
		g_iBurnDown = FALSE;
		g_fBurnTime = 300.0;
		g_fDieTime = 300.0;
		g_iLoop = FALSE;
		g_iChangeLight = TRUE;
		g_iChangeSmoke = TRUE;
		g_iChangeVolume = TRUE;
		g_iDefSize = 25;
		g_vDefStartColor = <100,100,0>;
		g_vDefEndColor = <100,0,0>;
		g_iDefVolume = 100;
		g_iDefSmoke = TRUE;
		g_iDefSound = FALSE;
		g_iDefIntensity = 100;
		g_iDefRadius = 50;
		g_iDefFalloff = 40;

		if (!g_iBurnDown) g_fBurnTime = 315360000;   // 10 years
		g_fTime = g_fDieTime / 100.0;                // try to get a one percent timer interval
		if (g_fTime < 1.0) g_fTime = 1.0;            // but never smaller than one second
		g_fDecPercent = 100.0 / (g_fDieTime / g_fTime); // and burn down decPercent% every time

		g_fStartIntensity = percentage(g_iDefIntensity, MAX_INTENSITY);
		g_fStartRadius = percentage(g_iDefRadius, MAX_RADIUS);
		g_fLightFalloff = percentage(g_iDefFalloff, MAX_FALLOFF);
		g_fStartVolume = percentage(g_iDefVolume, MAX_VOLUME); //not needed? 
		
		reset(); // initial values for menu
        if (g_iOn) startSystem();
		if (g_iVerbose) InfoLines();
		
        if (g_iDebugMode) {
            llOwnerSay("verbose = " + (string)g_iVerbose);
            llOwnerSay("switchAccess = " + (string)g_iSwitchAccess);
            llOwnerSay("menuAccess = " + (string)g_iMenuAccess);
            llOwnerSay("msgNumber = " + (string)g_iMsgNumber);
            llOwnerSay("msgSwitch = " + g_sMsgSwitch);
            llOwnerSay("msgOn = " + g_sMsgOn);
            llOwnerSay("msgOff = " + g_sMsgOff);
            llOwnerSay("msgMenu = " + g_sMsgMenu);
            llOwnerSay("burnDown = " + (string)g_iBurnDown);
            llOwnerSay("burnTime = " + (string)g_fBurnTime);
            llOwnerSay("dieTime = " + (string)g_fDieTime);
            llOwnerSay("loop = " + (string)g_iLoop);
            llOwnerSay("changeLight = " + (string)g_iChangeLight);
            llOwnerSay("changeSmoke = " + (string)g_iChangeSmoke);
            llOwnerSay("changeVolume = " + (string)g_iChangeVolume);
            llOwnerSay("defSize = " + (string)g_iDefSize);
            llOwnerSay("defStartColor = " + (string)g_vDefStartColor);
            llOwnerSay("defEndColor = " + (string)g_vDefEndColor);
            llOwnerSay("defVolume = " + (string)g_iDefVolume);
            llOwnerSay("defSmoke = " + (string)g_iDefSmoke);
            llOwnerSay("defSound = " + (string)g_iDefSound);
            llOwnerSay("defIntensity = " + (string)g_iDefIntensity);
            llOwnerSay("defRadius = " + (string)g_iDefRadius);
            llOwnerSay("defFalloff = " + (string)g_iDefFalloff);
            llOwnerSay("time = " + (string)g_fTime);
            llOwnerSay("decPercent = " + (string)g_fDecPercent);
        }
    }
}

readNotecard (string ncLine)
{
	//Debug("readNotecard, ncLine: "+ncLine);
    string ncData = llStringTrim(ncLine, STRING_TRIM);

    if (llStringLength(ncData) > 0 && llGetSubString(ncData, 0, 0) != "#") {
        list ncList = llParseString2List(ncData, ["=","#"], []);  // split into parameter, value, comment
        string par = llList2String(ncList, 0);
        string val = llList2String(ncList, 1);
        par = llStringTrim(par, STRING_TRIM);
        val = llStringTrim(val, STRING_TRIM);
        string lcpar = llToLower(par);
        if (lcpar == "verbose") g_iVerbose = checkYesNo("verbose", val);
        else if (lcpar == "switchaccess") g_iSwitchAccess = checkInt("switchAccess", (integer)val, 0, 7);
        else if (lcpar == "menuaccess") g_iMenuAccess = checkInt("menuAccess", (integer)val, 0, 7);
        else if (lcpar == "msgnumber") g_iMsgNumber = (integer)val;
        else if (lcpar == "msgswitch") g_sMsgSwitch = val;
        else if (lcpar == "msgon") g_sMsgOn = val;
        else if (lcpar == "msgoff") g_sMsgOff = val;
        else if (lcpar == "msgmenu") g_sMsgMenu = val;
        else if (lcpar == "burndown") g_iBurnDown = checkYesNo("burndown", val);
        else if (lcpar == "burntime") g_fBurnTime = (float)checkInt("burnTime", (integer)val, 1, 315360000); // 10 years
        else if (lcpar == "dietime") g_fDieTime = (float)checkInt("dieTime", (integer)val, 1, 315360000); // 10 years
        else if (lcpar == "loop") g_iLoop = checkYesNo("loop", val);
        else if (lcpar == "changelight") g_iChangeLight = checkYesNo("changeLight", val);
        else if (lcpar == "changesmoke") g_iChangeSmoke = checkYesNo("changeSmoke", val);
        else if (lcpar == "changevolume") g_iChangeVolume = checkYesNo("changeVolume", val);
        else if (lcpar == "size") g_iDefSize = checkInt("size", (integer)val, 0, 100);
        else if (lcpar == "topcolor") g_vDefEndColor = checkVector("topColor", (vector)val);
        else if (lcpar == "bottomcolor") g_vDefStartColor = checkVector("bottomColor", (vector)val);
        else if (lcpar == "volume") g_iDefVolume = checkInt("volume", (integer)val, 0, 100);
        else if (lcpar == "smoke") g_iDefSmoke = checkYesNo("smoke", val);
        else if (lcpar == "sound") g_iDefSound = checkYesNo("sound", val);
        else if (lcpar == "intensity") g_iDefIntensity = checkInt("intensity", (integer)val, 0, 100);
        else if (lcpar == "radius") g_iDefRadius = checkInt("radius", (integer)val, 0, 100);
        else if (lcpar == "falloff") g_iDefFalloff = checkInt("falloff", (integer)val, 0, 100);
        else llWhisper(0, "Unknown parameter in notecard line " + (string)(g_iLine + 1) + ": " + par);
    }

    g_iLine++;
    g_kQuery = llGetNotecardLine(NOTECARD, g_iLine);
}

menuDialog (key id)
{
    g_iMenuOpen = TRUE;
	
    string strSmoke = "N/A";
	if (g_iSmokeAvail) {
		if (g_iSmokeOn) strSmoke = "ON";
			else strSmoke = "OFF";
	}
    string strSound = "N/A";
	if (g_iSoundAvail || g_iBackSoundAvail) {
		if (g_iSoundOn) strSound = "ON"; 
			else strSound = "OFF";
	}
	
    menuChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    llListenRemove(g_iMenuHandle);
    g_iMenuHandle = llListen(menuChannel, "", "", "");
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id, g_sTitle + " " + g_sVersion +
        "\n\nSize: " + (string)g_iPerSize + "%\t\tVolume: " + (string)g_iPerVolume + "%" +
        "\nSmoke: " + strSmoke + "\t\tSound: " + strSound, [
        "Smoke", "Sound", "Close",
        "-Volume", "+Volume", "Reset",
        "-Fire", "+Fire", "Color",
        "Small", "Medium", "Large" ],
        menuChannel);
}

startColorDialog (key id)
{
    g_iMenuOpen = TRUE;
    g_iStartColorChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    llListenRemove(g_iStartColorHandle);
    g_iStartColorHandle = llListen(g_iStartColorChannel, "", "", "");
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id, "Bottom color" +
        "\n\nRed: " + (string)g_iPerRedStart + "%" +
        "\nGreen: " + (string)g_iPerGreenStart + "%" +
        "\nBlue: " + (string)g_iPerBlueStart + "%", [
        "Top color", "One color", "Main menu",
        "-Blue",  "+Blue",  "B min/max",
        "-Green", "+Green", "G min/max",
        "-Red",   "+Red",   "R min/max" ],
        g_iStartColorChannel);
}

endColorDialog (key id)
{
    g_iMenuOpen = TRUE;
    g_iEndColorChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    llListenRemove(g_iEndColorHandle);
    g_iEndColorHandle = llListen(g_iEndColorChannel, "", "", "");
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id, "Top color" +
        "\n\nRed: " + (string)g_iPerRedEnd + "%" +
        "\nGreen: " + (string)g_iPerGreenEnd + "%" +
        "\nBlue: " + (string)g_iPerBlueEnd + "%", [
        "Bottom color", "One color", "Main menu",
        "-Blue",  "+Blue",  "B min/max",
        "-Green", "+Green", "G min/max",
        "-Red",   "+Red",   "R min/max" ],
        g_iEndColorChannel);
}

float percentage (float per, float num)
{
    return num / 100.0 * per;
}

integer min (integer x, integer y)
{
    if (x < y) return x; else return y;
}

integer max (integer x, integer y)
{
    if (x > y) return x; else return y;
}

reset()
{
	if (!g_iSmokeAvail) g_iSmokeOn = FALSE;
		else g_iSmokeOn = g_iDefSmoke;
	if (!g_iSoundAvail && !g_iBackSoundAvail) g_iSoundOn = FALSE;
		else g_iSoundOn = g_iDefSound;
    g_iPerSize = g_iDefSize;
    g_iPerVolume = g_iDefVolume;
    g_iPerRedStart = (integer)g_vDefStartColor.x;
    g_iPerGreenStart = (integer)g_vDefStartColor.y;
    g_iPerBlueStart = (integer)g_vDefStartColor.z;
    g_iPerRedEnd = (integer)g_vDefEndColor.x;
    g_iPerGreenEnd = (integer)g_vDefEndColor.y;
    g_iPerBlueEnd = (integer)g_vDefEndColor.z;
	
	//just send, don't check
	sendMessage(SMOKE_CHANNEL, "0", "");
	sendMessage(SOUND_CHANNEL, "0", "");
	llStopSound(); //keep, just in case there wents something wrong and this prim has sound too
	if (g_iVerbose) llWhisper(0, "The fire get's taken care off");
}

startSystem()
{
	Debug("startSystem");
    g_fPercent = 100.0;
	g_fPercentSmoke = 100.0;
	if (g_iSmokeAvail && g_iSmokeOn) {
		sendMessage(SMOKE_CHANNEL, (string)llRound(g_fPercentSmoke), "");
	}
    g_fLightIntensity = g_fStartIntensity;
    g_fLightRadius = g_fStartRadius;
    if (g_iSoundAvail || g_iBackSoundAvail) { //needs some more rework, move all calculation inside
		g_fStartVolume = percentage((float)g_iPerVolume, MAX_VOLUME);
		//g_fSoundVolume = g_fStartVolume;
		//if (g_iSoundOn) sendMessage(SOUND_CHANNEL, (string)g_fSoundVolume, "-1"); //background noise - do better not use, gets called to often
		if (g_iSoundOn) sendMessage(SOUND_CHANNEL, (string)g_fStartVolume, "110");
	}
	if (g_iVerbose && !g_iOn) llWhisper(0, "The fire gets lit");
    updateSize((float)g_iPerSize);
    llSetTimerEvent(0);
    llSetTimerEvent(g_fBurnTime);
    if (g_iMenuOpen) {
        llListenRemove(g_iMenuHandle);
        llListenRemove(g_iStartColorHandle);
        llListenRemove(g_iEndColorHandle);
        g_iMenuOpen = FALSE;
    }
    g_iOn = TRUE;
    g_iBurning = TRUE;
}

stopSystem()
{
	if (g_iVerbose && g_iOn) llWhisper(0, "The fire is dying down");
    g_iOn = FALSE;
    g_iBurning = FALSE;
    g_fPercent = 0.0;
    g_fPercentSmoke = 0.0;
    llSetTimerEvent(0);
    llParticleSystem([]);
    llSetPrimitiveParams([PRIM_POINT_LIGHT, FALSE, ZERO_VECTOR, 0, 0, 0]);
	if (g_iSoundAvail || g_iBackSoundAvail) sendMessage(SOUND_CHANNEL, "0", "0"); //volume off and size off
    //llStopSound(); //keep, just in case there wents something wrong and this prim has sound too
    if (g_iSmokeAvail) sendMessage(SMOKE_CHANNEL, "0", "");
    if (g_iMenuOpen) {
        llListenRemove(g_iMenuHandle);
        llListenRemove(g_iStartColorHandle);
        llListenRemove(g_iEndColorHandle);
        g_iMenuOpen = FALSE;
    }
	llSleep(3);
    llSetLinkTextureAnim(LINK_SET, FALSE, ALL_SIDES,4,4,0,0,1);
}

updateParticles(vector start, vector end, float min, float max, float radius, vector push)
{
    llParticleSystem ([
	//System Behavior
        PSYS_PART_FLAGS,
          0 |
			//PSYS_PART_BOUNCE_MASK |
          PSYS_PART_EMISSIVE_MASK |
			//PSYS_PART_FOLLOW_SRC_MASK |
			//PSYS_PART_FOLLOW_VELOCITY_MASK |
          PSYS_PART_INTERP_COLOR_MASK |
          PSYS_PART_INTERP_SCALE_MASK, // |
			//PSYS_PART_RIBBON_MASK |
		  	//PSYS_PART_TARGET_LINEAR_MASK |
			//PSYS_PART_TARGET_POS_MASK |
			////PSYS_PART_WIND_MASK,
	//System Presentation
        PSYS_SRC_PATTERN, 
		  PSYS_SRC_PATTERN_EXPLODE, //|
			//PSYS_SRC_PATTERN_ANGLE_CONE |
			//PSYS_SRC_PATTERN_ANGLE |
			////PSYS_SRC_PATTERN_DROP,
        PSYS_SRC_BURST_RADIUS, radius,
			//PSYS_SRC_ANGLE_BEGIN, float,
			//PSYS_SRC_ANGLE_END, float,
			//PSYS_SRC_TARGET_KEY, key,
	//Particle Appearance
        PSYS_PART_START_COLOR, g_vStartColor,
        PSYS_PART_END_COLOR, g_vEndColor,
        PSYS_PART_START_ALPHA, 1.0,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, start,
        PSYS_PART_END_SCALE, end,
			//PSYS_SRC_TEXTURE, string,
			//PSYS_PART_START_GLOW, float,
			//PSYS_PART_END_GLOW, float,
	//Particle Blending
	//Particle Flow
			//PSYS_SRC_MAX_AGE, float,
        PSYS_PART_MAX_AGE, g_fAge,
        PSYS_SRC_BURST_RATE, g_fRate,
        PSYS_SRC_BURST_PART_COUNT, g_iCount,
	//Particle Motion
        PSYS_SRC_ACCEL, push,
			//PSYS_SRC_OMEGA, vector,
        PSYS_SRC_BURST_SPEED_MIN, min,
        PSYS_SRC_BURST_SPEED_MAX, max
	]);
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
sendMessage(integer iChan, string sVal, string sMsg )
{
	if (iChan == SMOKE_CHANNEL) {
		llMessageLinked(LINK_ALL_OTHERS, SMOKE_CHANNEL, sVal, (key)g_sScriptName); //to all other prims (because of only one emitter per prim)
	} else if (iChan == SOUND_CHANNEL) {
			string sSoundSet = sVal + "," + sMsg;
			llMessageLinked(LINK_SET, SOUND_CHANNEL, sSoundSet, (key)g_sScriptName);
	}
}

InfoLines()
{
        llWhisper(0, "Switch access:" + showAccess(g_iSwitchAccess));
        llWhisper(0, "Menu access:" + showAccess(g_iMenuAccess));
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default
{
    state_entry()
    {
        g_kOwner = llGetOwner();
		g_sScriptName = llGetScriptName();
		
		stopSystem();
        Debug("Particle count: " + (string)llRound((float)g_iCount * g_fAge / g_fRate));
        Debug((string)llGetFreeMemory() + " bytes free");
		llWhisper(0, "RealFire by Rene10957\n + Enhancements by Zopf");
	    llWhisper(0, "Touch to start/stop fire\n *Long touch to show menu*");
		if (g_iVerbose) llWhisper(0, "Loading notecard...");
		loadNotecard();
     }

    on_rez(integer start_param)
    {
        llResetScript();
    }
	
    changed(integer change)
    {
		if (change & CHANGED_INVENTORY) {
			g_iSmokeAvail = g_iSmokeOn = FALSE;
			g_iSoundAvail = g_iBackSoundAvail = g_iDefSound = g_iSoundOn = FALSE;
			llWhisper(0, "Inventory changed, reloading notecard...");
			loadNotecard();
		}
    }
	
    touch_start(integer total_number)
    {
        llResetTime();
    }

    touch_end(integer total_number)
    {
        g_kUser = llDetectedKey(0);

        if (llGetTime() > 2.0) {
            if (accessGranted(g_kUser, g_iMenuAccess)) {
				if (!g_iOn) toggleFunktion("fire"); //do not use if fire is already burning
                //startSystem();
                menuDialog(g_kUser);
            }
            else llInstantMessage(g_kUser, "[Menu] Access denied");
        }
        else {
            if (accessGranted(g_kUser, g_iSwitchAccess)) toggleFunktion("fire");
            else llInstantMessage(g_kUser, "[Switch] Access denied");
        }
    }

    listen(integer channel, string name, key id, string msg)
    {
        Debug("LISTEN event: " + (string)channel + "; " + msg);

        if (channel == menuChannel) {
            llListenRemove(g_iMenuHandle);
            if (msg == "Small") g_iPerSize = 20;
            else if (msg == "Medium") g_iPerSize = 55;
            else if (msg == "Large") g_iPerSize = 80;
            else if (msg == "-Fire") g_iPerSize = max(g_iPerSize - 5, 5);
            else if (msg == "+Fire") g_iPerSize = min(g_iPerSize + 5, 100);
            else if (msg == "-Volume") {
                g_iPerVolume = max(g_iPerVolume - 5, 5);
                g_fStartVolume = percentage(g_iPerVolume, MAX_VOLUME);
				if (g_iSoundOn) g_fSoundVolume = g_fStartVolume;
					else g_fSoundVolumeTmp = g_fStartVolume;  // for changing volume while sound off
            }
            else if (msg == "+Volume") {
                g_iPerVolume = min(g_iPerVolume + 5, 100);
                g_fStartVolume = percentage(g_iPerVolume, MAX_VOLUME);
				if (g_iSoundOn) g_fSoundVolume = g_fStartVolume;
					else g_fSoundVolumeTmp = g_fStartVolume;
            }
            else if (msg == "Smoke" && g_iSmokeAvail) toggleFunktion("smoke");
            else if (msg == "Sound" && (g_iSoundAvail || g_iBackSoundAvail)) toggleFunktion("sound");
            else if (msg == "Color") endColorDialog(g_kUser);
            else if (msg == "Reset") { reset(); startSystem(); }
            else if (msg == "Close") {
                llSetTimerEvent(0); // stop dialog timer
                llSetTimerEvent(g_fBurnTime); // restart burn timer
                g_iMenuOpen = FALSE;
            }
            if (msg != "Color" && msg != "Close") {
					if (msg != "Smoke" && msg != "Sound" && msg != "Reset") updateSize((float)g_iPerSize);
				menuDialog(g_kUser);
            }
        }
        else if (channel == g_iStartColorChannel) {
            llListenRemove(g_iStartColorHandle);
            if (msg == "-Red") g_iPerRedStart = max(g_iPerRedStart - 10, 0);
            else if (msg == "-Green") g_iPerGreenStart = max(g_iPerGreenStart - 10, 0);
            else if (msg == "-Blue") g_iPerBlueStart = max(g_iPerBlueStart - 10, 0);
            else if (msg == "+Red") g_iPerRedStart = min(g_iPerRedStart + 10, 100);
            else if (msg == "+Green") g_iPerGreenStart = min(g_iPerGreenStart + 10, 100);
            else if (msg == "+Blue") g_iPerBlueStart = min(g_iPerBlueStart + 10, 100);
            else if (msg == "R min/max") { if (g_iPerRedStart) g_iPerRedStart = 0; else g_iPerRedStart = 100; }
            else if (msg == "G min/max") { if (g_iPerGreenStart) g_iPerGreenStart = 0; else g_iPerGreenStart = 100; }
            else if (msg == "B min/max") { if (g_iPerBlueStart) g_iPerBlueStart = 0; else g_iPerBlueStart = 100; }
            else if (msg == "Top color") endColorDialog(g_kUser);
            else if (msg == "Main menu") menuDialog(g_kUser);
            else if (msg == "One color") {
                g_iPerRedEnd = g_iPerRedStart;
                g_iPerGreenEnd = g_iPerGreenStart;
                g_iPerBlueEnd = g_iPerBlueStart;
            }
            if (msg != "Top color" && msg != "Main menu") {
                updateSize((float)g_iPerSize);
                startColorDialog(g_kUser);
            }
        }
        else if (channel == g_iEndColorChannel) {
            llListenRemove(g_iEndColorHandle);
            if (msg == "-Red") g_iPerRedEnd = max(g_iPerRedEnd - 10, 0);
            else if (msg == "-Green") g_iPerGreenEnd = max(g_iPerGreenEnd - 10, 0);
            else if (msg == "-Blue") g_iPerBlueEnd = max(g_iPerBlueEnd - 10, 0);
            else if (msg == "+Red") g_iPerRedEnd = min(g_iPerRedEnd + 10, 100);
            else if (msg == "+Green") g_iPerGreenEnd = min(g_iPerGreenEnd + 10, 100);
            else if (msg == "+Blue") g_iPerBlueEnd = min(g_iPerBlueEnd + 10, 100);
            else if (msg == "R min/max") { if (g_iPerRedEnd) g_iPerRedEnd = 0; else g_iPerRedEnd = 100; }
            else if (msg == "G min/max") { if (g_iPerGreenEnd) g_iPerGreenEnd = 0; else g_iPerGreenEnd = 100; }
            else if (msg == "B min/max") { if (g_iPerBlueEnd) g_iPerBlueEnd = 0; else g_iPerBlueEnd = 100; }
            else if (msg == "Bottom color") startColorDialog(g_kUser);
            else if (msg == "Main menu") menuDialog(g_kUser);
            else if (msg == "One color") {
                g_iPerRedStart = g_iPerRedEnd;
                g_iPerGreenStart = g_iPerGreenEnd;
                g_iPerBlueStart = g_iPerBlueEnd;
            }
            if (msg != "Bottom color" && msg != "Main menu") {
                updateSize((float)g_iPerSize);
                endColorDialog(g_kUser);
            }
        }
    }
	
//listen for linked messages from other RealFire scripts and devices
//-----------------------------------------------
    link_message(integer iSender_number, integer iChan, string sMsg, key kId)
    {
        Debug("link_message= channel" + (string)iChan + "; Message " + sMsg + "; " + (string)kId);
		
		if (iChan == SMOKE_CHANNEL) {
			if ("1" == sMsg) {
				g_iSmokeAvail = TRUE;
				if (g_iDefSmoke && g_iOn) { //if only smoke scripts gets resetted
					g_iSmokeOn = FALSE; //important to get it toggled
					toggleFunktion("smoke");
				}
			} else {
				g_iSmokeAvail = FALSE;
				if ("0" == sMsg) llWhisper(0, "Unable to provide smoke effects");
			}
		} else if (iChan == SOUND_CHANNEL && llToLower((string)kId) != llToLower(g_sScriptName)) {
			if ((string)kId == SOUNDSCRIPT) {
				if ("1" == sMsg) g_iSoundAvail = TRUE;
					else g_iSoundAvail = FALSE;
			}
			if ((string)kId == BACKSOUNDSCRIPT) {
				if ("1" == sMsg) g_iBackSoundAvail = TRUE;
					else g_iBackSoundAvail = FALSE;
			}
			if ("1" != sMsg ) llWhisper(0, "Unable to provide sound effects ("+(string)kId+")");	
		} else if (iChan == g_iMsgNumber) {
			if (kId != "") g_kUser = kId;
				else {
					llWhisper(0, "A valid avatar key must be provided in the link message.");
					return;
				}

			if (sMsg == g_sMsgSwitch) {
				if (accessGranted(g_kUser, g_iSwitchAccess)) toggleFunktion("fire");
					else llInstantMessage(g_kUser, "[Switch] Access denied");
			}
				else if (sMsg == g_sMsgOn) {
					if (accessGranted(g_kUser, g_iSwitchAccess)) startSystem();
					else llInstantMessage(g_kUser, "[Switch] Access denied");
				}
				else if (sMsg == g_sMsgOff) {
					if (accessGranted(g_kUser, g_iSwitchAccess)) stopSystem();
					else llInstantMessage(g_kUser, "[Switch] Access denied");
				}
				else if (sMsg == g_sMsgMenu) {
					if (accessGranted(g_kUser, g_iMenuAccess)) {
						startSystem();
						menuDialog(g_kUser);
					}
					else llInstantMessage(g_kUser, "[Menu] Access denied");
				}
		}
    }
	
//get presets from notecard
//-----------------------------------------------
    dataserver(key kQuery_id, string data)
    {
		if(kQuery_id != g_kQuery) return;
        if (data != EOF) {
			//Debug("Dataserver");
			readNotecard(data);
		} else {
			Debug("Dataserver, last line done");
            if (!g_iBurnDown) g_fBurnTime = 315360000;   // 10 years
            g_fTime = g_fDieTime / 100.0;                // try to get a one percent timer interval
            if (g_fTime < 1.0) g_fTime = 1.0;            // but never smaller than one second
            g_fDecPercent = 100.0 / (g_fDieTime / g_fTime); // and burn down decPercent% every time

            g_vDefStartColor.x = checkInt("ColorOn (RED)", (integer)g_vDefStartColor.x, 0, 100);
            g_vDefStartColor.y = checkInt("ColorOn (GREEN)", (integer)g_vDefStartColor.y, 0, 100);
            g_vDefStartColor.z = checkInt("ColorOn (BLUE)", (integer)g_vDefStartColor.z, 0, 100);
            g_vDefEndColor.x = checkInt("ColorOff (RED)", (integer)g_vDefEndColor.x, 0, 100);
            g_vDefEndColor.y = checkInt("ColorOff (GREEN)", (integer)g_vDefEndColor.y, 0, 100);
            g_vDefEndColor.z = checkInt("ColorOff (BLUE)", (integer)g_vDefEndColor.z, 0, 100);

            g_fStartIntensity = percentage(g_iDefIntensity, MAX_INTENSITY);
            g_fStartRadius = percentage(g_iDefRadius, MAX_RADIUS);
            g_fLightFalloff = percentage(g_iDefFalloff, MAX_FALLOFF);
            g_fStartVolume = percentage((float)g_iDefVolume, MAX_VOLUME);

            reset(); // initial values for menu
			
            if (g_iOn) startSystem();
			if (g_iVerbose) InfoLines();

            if (g_iDebugMode) {
                llOwnerSay((string)g_iLine + " lines in notecard");
                llOwnerSay("verbose = " + (string)g_iVerbose);
                llOwnerSay("switchAccess = " + (string)g_iSwitchAccess);
                llOwnerSay("menuAccess = " + (string)g_iMenuAccess);
                llOwnerSay("msgNumber = " + (string)g_iMsgNumber);
                llOwnerSay("msgSwitch = " + g_sMsgSwitch);
                llOwnerSay("msgOn = " + g_sMsgOn);
                llOwnerSay("msgOff = " + g_sMsgOff);
                llOwnerSay("msgMenu = " + g_sMsgMenu);
                llOwnerSay("burnDown = " + (string)g_iBurnDown);
                llOwnerSay("burnTime = " + (string)g_fBurnTime);
                llOwnerSay("dieTime = " + (string)g_fDieTime);
                llOwnerSay("loop = " + (string)g_iLoop);
                llOwnerSay("changeLight = " + (string)g_iChangeLight);
                llOwnerSay("changeSmoke = " + (string)g_iChangeSmoke);
                llOwnerSay("changeVolume = " + (string)g_iChangeVolume);
                llOwnerSay("defSize = " + (string)g_iDefSize);
                llOwnerSay("defStartColor = " + (string)g_vDefStartColor);
                llOwnerSay("defEndColor = " + (string)g_vDefEndColor);
                llOwnerSay("defVolume = " + (string)g_iDefVolume);
                llOwnerSay("defSmoke = " + (string)g_iDefSmoke);
                llOwnerSay("defSound = " + (string)g_iDefSound);
                llOwnerSay("defIntensity = " + (string)g_iDefIntensity);
                llOwnerSay("defRadius = " + (string)g_iDefRadius);
                llOwnerSay("defFalloff = " + (string)g_iDefFalloff);
                llOwnerSay("time = " + (string)g_fTime);
                llOwnerSay("decPercent = " + (string)g_fDecPercent);
            }
        }
    }

    timer()
    {
        if (g_iMenuOpen) {
            if (g_iVerbose) llWhisper(0, "MENU TIMEOUT");
            llListenRemove(g_iMenuHandle);
            llListenRemove(g_iStartColorHandle);
            llListenRemove(g_iEndColorHandle);
            llSetTimerEvent(0); // stop dialog timer
            llSetTimerEvent(g_fBurnTime); // restart burn timer
            g_iMenuOpen = FALSE;
            return;
        }

        if (g_iBurning) {
            llSetTimerEvent(0);
            llSetTimerEvent(g_fTime);
            g_iBurning = FALSE;
        }

        if (g_fPercent >= g_fDecPercent) {
            g_fPercent -= g_fDecPercent;
            updateSize(g_fPercent / (100.0 / (float)g_iPerSize));
        }
        else {
            if (g_iLoop) startSystem();
            else stopSystem();
        }
    }
}