///////////////////////////////////////////////////////////////////////////////////////////////////
//Realfire by Rene - Fire
//
// Author: Rene10957 Resident
// Date: 12-01-2014
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
//
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: initial structure for multiple sound files, implement linked_message system, background sound, LSLForge Modules
//04. Feb. 2014
//v2.2.1-0.96
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

//debug variables
//-----------------------------------------------
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
string NOTECARD = "config";                  // notecard name
string SOUNDSCRIPT = "Sound.lsl";            // normal sounds
string BACKSOUNDSCRIPT = "B-Sound.lsl";      // only one (backround, quieter) sound
string SMOKESCRIPT = "Smoke.lsl";            // script for smoke particles from a second prim
string SPARKSSCRIPT = "Sparks.lsl";          // script for particles from a third prim
string TEXTUREANIMSCRIPT = "Animation.lsl";  // script that handles texture animations (for each single prim)
string PRIMFIREANIMSCRIPT = "P-Anim.lsl";    // script to create temporary flexi prim (Fire)
string PARTICLEFIREANIMSCRIPT = "F-Anim.lsl";

string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;

//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire";            // title
string g_sVersion = "2.2.1-0.96";        // version
string g_sAuthors = "Rene10957, Zopf";

string g_sType = "fire";
integer g_iType = LINK_SET;              // in this case it defines which prim emitts the light and changes texture

// Constants
integer ACCESS_OWNER = 4;            // owner access bit
integer ACCESS_GROUP = 2;            // group access bit
integer ACCESS_WORLD = 1;            // world access bit
float MAX_VOLUME = 1.0;          // max. volume for sound

// RealFire MESSAGE MAP
//integer COMMAND_CHANNEL =
//integer PARTICLE_CHANNEL =       smoke channel
//integer SOUND_CHANNEL =       sound channel
//integer ANIM_CHANNEL =        primfire/textureanim channel
//integer PRIMCOMMAND_CHANNEL = kill fire prims or make temp prims


// Notecard variables
integer g_iVerbose = TRUE;         // show more/less info during startup
integer g_iSwitchAccess;           // access level for switch
integer g_iMenuAccess;             // access level for menu
integer g_iLowprim = FALSE;        // only use temp prim for PrimFire if set to TRUE
integer g_iBurnDown = FALSE;       // burn down or burn continuously
float g_fBurnTime;                 // time to burn in seconds before starting to die
float g_fDieTime;                  // time it takes to die in seconds
integer g_iLoop = FALSE;           // restart after burning down
integer g_iChangeSmoke = TRUE;     // change smoke with fire
integer g_iChangeVolume = TRUE;    // change volume with fire
integer g_iDefSize;                // default fire size (percentage)
integer g_iDefVolume;              // default volume for sound (percentage)
integer g_iDefChangeVolume = TRUE;
integer g_iDefSmoke = TRUE;         // default smoke on/off
integer g_iDefSound = FALSE;        // default sound on/off; keep off if SoundAvail
integer g_iDefParticleFire = TRUE;  // default fire particle effects on
integer g_iDefPrimFire = FALSE;     // default rezzing fire prims off
string g_sCurrentSound = "55";

// Variables
key g_kUser;                       // key of last avatar to touch object
key	g_kQuery = NULL_KEY;

integer g_iSmokeAvail = FALSE;      // true after script sucessfully registered for the task
integer g_iSoundAvail = FALSE;      // true after script sucessfully registered for the task
integer g_iBackSoundAvail = FALSE;
integer g_iParticleFireAvail = FALSE;
integer g_iPrimFireAvail = FALSE;  //

integer g_iLine;                   // notecard line
string g_sConfLine = "";                //config settings to give to extensions
integer menuChannel;               // main menu channel
integer g_iStartColorChannel;      // start color menu channel
integer g_iEndColorChannel;        // end color menu channel
integer g_iOptionsChannel;
integer g_iMenuHandle;             // handle for main menu listener
integer g_iStartColorHandle;       // handle for start color menu listener
integer g_iEndColorHandle;         // handle for end color menu listener
integer g_iOptionsHandle;
float g_fPerSize;                  // percent particle size
integer g_iPerVolume;              // percent volume
integer g_iOn = FALSE;             // fire on/off
integer g_iBurning = FALSE;        // burning constantly
integer g_iSmokeOn = FALSE;        // smoke on/off
integer g_iSoundOn = FALSE;        // sound on/off
integer g_iParticleFireOn = FALSE;
integer g_iPrimFireOn = FALSE;
integer g_iVerboseButton = FALSE;
integer g_iMenuOpen = FALSE;       // a menu is open or canceled (ignore button)
float g_fTime;                     // timer interval in seconds
float g_fPercent;                  // percentage of particle size
float g_fPercentSmoke;             // percentage of smoke
float g_fDecPercent;               // how much to burn down (%) every timer interval
float g_fSoundVolume = 0.0;        // sound volume (changed by burning down)
float g_fSoundVolumeTmp;
float g_fStartVolume;              // start value of volume (before burning down)


//===============================================
//LSLForge MODULES
//===============================================
$import RealFireMessageMap.lslm();
$import Debug.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName);
$import GenericFunctions.lslm();
$import ColorChanger.lslm();
$import GroupHandling.lslm(m_sGroup=LINKSETID);


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
toggleFunktion(string sFunction)
{
	Debug("toggle function " + sFunction);
	if ("fire" == sFunction) {
		if (g_iOn) stopSystem(); else startSystem();
	} else if ("particlefire" == sFunction) {
		if (g_iParticleFireOn) {
			sendMessage(PARTICLE_CHANNEL, "0", "fire");
			g_iParticleFireOn = FALSE;
		} else {
			sendMessage(PARTICLE_CHANNEL, (string)g_fPerSize, "fire");
			g_iParticleFireOn = TRUE;
		}
	} else if ("primfire" == sFunction) {
		if (g_iPrimFireOn) {
			sendMessage(ANIM_CHANNEL, "0", (string)g_iLowprim);
			g_iPrimFireOn = FALSE;
		} else {
			sendMessage(ANIM_CHANNEL, (string)llRound(g_fPerSize), (string)g_iLowprim);
			g_iPrimFireOn = TRUE;
		}
	} else if ("smoke" == sFunction) {
			if (g_iSmokeOn) {
			sendMessage(PARTICLE_CHANNEL, "0", "smoke");
			g_iSmokeOn = FALSE;
		} else {
			sendMessage(PARTICLE_CHANNEL, (string)llRound(g_fPercentSmoke), "smoke");
			g_iSmokeOn = TRUE;
		}
	} else if ("sound" == sFunction) {
		if (g_iSoundOn) {
			sendMessage(SOUND_CHANNEL, "", "0");
			g_iSoundOn = FALSE;
		} else {
			sendMessage(SOUND_CHANNEL, g_sCurrentSound, (string)g_fSoundVolume);
			g_iSoundOn = TRUE;
		}
	}
}


//most important function
//-----------------------------------------------
updateSize(float size)
{
	g_fSoundVolume = g_fStartVolume;

	if (size <= SIZE_SMALL) {
		if (g_iChangeSmoke && g_iSmokeAvail) g_fPercentSmoke = size * 4.0; //works only here within range 0-100!!!
			else g_fPercentSmoke = 100.0;
		Debug("Smoke size: change= "+(string)g_iChangeSmoke+", size= "+(string)size +", percentage= "+(string)g_fPercentSmoke);
		if ((g_iSoundAvail || g_iBackSoundAvail) && g_iChangeVolume) g_fSoundVolume = percentage(size * 4.0, g_fStartVolume);
	}

	if (g_iPrimFireAvail && g_iPrimFireOn) sendMessage(ANIM_CHANNEL, (string)size, (string)g_iLowprim);
	if (g_iSmokeAvail && g_iSmokeOn) sendMessage(PARTICLE_CHANNEL, (string)llRound(g_fPercentSmoke), "smoke");
	if (g_iSoundAvail || g_iBackSoundAvail) { //needs to be improved
		if (0 <= size && 100 >= size) g_sCurrentSound = (string)size;
		if (g_iSoundOn) sendMessage(SOUND_CHANNEL, g_sCurrentSound, (string)g_fSoundVolume); //used when changing fire size via menu
			else sendMessage(SOUND_CHANNEL, g_sCurrentSound, "0");
	}
	if (g_iParticleFireAvail && g_iParticleFireOn) sendMessage(PARTICLE_CHANNEL, (string)size, "fire");
	//Debug((string)llRound(size) + "% " + (string)vStart + " " + (string)vEnd);
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
	} else {
		strAccess = " None";
	}
	return strAccess;
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
	g_sConfLine = "";
	if (llGetInventoryType(NOTECARD) == INVENTORY_NOTECARD) {
		Debug("loadNotecard, NC avail");
		g_kQuery = llGetNotecardLine(NOTECARD, g_iLine);
	} else {
		llWhisper(0, "Notecard \"" + NOTECARD + "\" not found or empty, using defaults");

		g_iVerbose = TRUE;
		g_iSwitchAccess = ACCESS_WORLD;
		g_iMenuAccess = ACCESS_WORLD;
		g_iLowprim = FALSE;
		g_iBurnDown = FALSE;
		g_fBurnTime = 300.0;
		g_fDieTime = 300.0;
		g_iLoop = FALSE;
		g_iChangeSmoke = TRUE;
		g_iDefSize = 25;
		g_vDefStartColor = <100,100,0>;
		g_vDefEndColor = <100,0,0>;
		g_iDefVolume = 100;
		g_iDefChangeVolume = TRUE;
		g_iDefSmoke = TRUE;
		g_iDefSound = FALSE;
		g_iDefParticleFire = TRUE;
		g_iDefPrimFire = FALSE;

		if (!g_iBurnDown) g_fBurnTime = 315360000;   // 10 years
		g_fTime = g_fDieTime / 100.0;                // try to get a one percent timer interval
		if (g_fTime < 1.0) g_fTime = 1.0;            // but never smaller than one second
		g_fDecPercent = 100.0 / (g_fDieTime / g_fTime); // and burn down decPercent% every time

		g_fStartVolume = percentage(g_iDefVolume, MAX_VOLUME);

		reset(); // initial values for menu
		if (g_iOn) startSystem();
		if (g_iVerbose) infoLines();

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
		list ncList = llParseString2List(ncData, ["=","#"], []);  //split into parameter, value, comment
		string par = llList2String(ncList, 0);
		string val = llList2String(ncList, 1);
		par = llStringTrim(par, STRING_TRIM);
		val = llStringTrim(val, STRING_TRIM);
		string lcpar = llToLower(par);
		if ("globaldebug" == lcpar) {
			if ("D E B U G" == val) {
				g_iDebugMode = TRUE;
				sendMessage(COMMAND_CHANNEL, "globaldebug", "");
			}
		} else if ("linksetid" == lcpar && "" != val) LINKSETID = val;
		else if (lcpar == "verbose") g_iVerbose = checkYesNo("verbose", val);
		else if (lcpar == "switchaccess") g_iSwitchAccess = checkInt("switchAccess", (integer)val, 0, 7);
		else if (lcpar == "menuaccess") g_iMenuAccess = checkInt("menuAccess", (integer)val, 0, 7);
		else if (lcpar == "msgnumber") {
			g_iMsgNumber = (integer)val;
			g_sConfLine += lcpar+"="+(string)g_iMsgNumber+SEPARATOR;
		}
		else if (lcpar == "msgswitch") g_sMsgSwitch = val;
		else if (lcpar == "msgon") g_sMsgOn = val;
		else if (lcpar == "msgoff") g_sMsgOff = val;
		else if (lcpar == "msgmenu") g_sMsgMenu = val;
		else if (lcpar == "burndown") g_iBurnDown = checkYesNo("burndown", val);
		else if (lcpar == "burntime") g_fBurnTime = (float)checkInt("burnTime", (integer)val, 1, 315360000); // 10 years
		else if (lcpar == "dietime") g_fDieTime = (float)checkInt("dieTime", (integer)val, 1, 315360000); // 10 years
		else if (lcpar == "loop") g_iLoop = checkYesNo("loop", val);
		else if (lcpar == "changelight") {
			g_iChangeLight = checkYesNo("changeLight", val);
			g_sConfLine += lcpar+"="+(string)g_iChangeLight+SEPARATOR;
		} else if (lcpar == "changesmoke") g_iChangeSmoke = checkYesNo("changeSmoke", val);
		else if (lcpar == "changevolume") g_iDefChangeVolume = checkYesNo("changeVolume", val);
		else if (lcpar == "size") g_iDefSize = checkInt("size", (integer)val, 0, 100);
		// config for particle fire
		else if (lcpar == "topcolor") {
			g_vDefEndColor = checkVector("topColor", (vector)val);
			g_sConfLine += lcpar+"="+(string)g_vDefEndColor+SEPARATOR;
		} else if (lcpar == "bottomcolor") {
			g_vDefStartColor = checkVector("bottomColor", (vector)val);
			g_sConfLine += lcpar+"="+(string)g_vDefStartColor+SEPARATOR;
		} else if (lcpar == "volume") g_iDefVolume = checkInt("volume", (integer)val, 0, 100);
		else if ("particlefire" == lcpar)g_iDefParticleFire = checkYesNo("particlefire", val);
		else if ("lowprim" == lcpar) g_iLowprim = checkYesNo("lowprim", val);
		else if ("primfire" == lcpar) g_iDefPrimFire = checkYesNo("primfire", val);
		else if (lcpar == "smoke") g_iDefSmoke = checkYesNo("smoke", val);
		else if (lcpar == "sound") g_iDefSound = checkYesNo("sound", val);
		// config for light
		else if (lcpar == "intensity") {
			g_iDefIntensity = checkInt("intensity", (integer)val, 0, 100);
			g_sConfLine += lcpar+"="+(string)g_iDefIntensity+SEPARATOR;
		} else if (lcpar == "radius") {
			g_iDefRadius = checkInt("radius", (integer)val, 0, 100);
			g_sConfLine += lcpar+"="+(string)g_iDefRadius+SEPARATOR;
		} else if (lcpar == "falloff") {
			g_iDefFalloff = checkInt("falloff", (integer)val, 0, 100);
			g_sConfLine += lcpar+"="+(string)g_iDefFalloff+SEPARATOR;

		} else llWhisper(0, "Unknown parameter in notecard line " + (string)(g_iLine + 1) + ": " + par);
	}

	g_iLine++;
	g_kQuery = llGetNotecardLine(NOTECARD, g_iLine);
}


menuDialog (key id)
{
	g_iMenuOpen = TRUE;

	string sParticleFire = "N/A";
	if (g_iParticleFireAvail) {
		if (g_iParticleFireOn) sParticleFire = "ON";
			else sParticleFire = "OFF";
	}

	string sPrimFire = "N/A";
	if (g_iPrimFireAvail) {
		if (g_iPrimFireOn) {
			if (g_iLowprim) sPrimFire = "ON (temp)";
				else sPrimFire = "ON";
		} else sPrimFire = "OFF";
	}
	string strSmoke = "N/A";
	if (g_iSmokeAvail) {
		if (g_iSmokeOn) strSmoke = "ON";
			else strSmoke = "OFF";
	}
	string strSound = "N/A";
	if (g_iSoundAvail || g_iBackSoundAvail) {
		if (g_iSoundOn) {
			if (g_iBackSoundAvail && g_iSoundAvail) strSound = "ON";
			else if (g_iBackSoundAvail) strSound = "ON (back)";
			else strSound = "ON (normal)";
		} else strSound = "OFF";
	}
	menuChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
	llListenRemove(g_iMenuHandle);
	g_iMenuHandle = llListen(menuChannel, "", "", "");
	llSetTimerEvent(0.0);
	llSetTimerEvent(120.0);
	llDialog(id, g_sTitle + " " + g_sVersion +
			"\n\nSize: " + (string)((integer)g_fPerSize) + "%\t\tVolume: " + (string)g_iPerVolume + "%" +
			"\nParticleFire: " + sParticleFire + "\tSmoke: " + strSmoke + "\tSound: " + strSound + "\nPrimFire:\t " + sPrimFire, [
			"Options", "FastToggle", "Close",
			"-Volume", "+Volume", "---",
			"-Fire", "+Fire", "---",
			"Small", "Medium", "Large"
			],
	menuChannel);
}


startColorDialog (key id)
{
	g_iMenuOpen = TRUE;
	g_iStartColorChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
	llListenRemove(g_iStartColorHandle);
	g_iStartColorHandle = llListen(g_iStartColorChannel, "", "", "");
	llSetTimerEvent(0.0);
	llSetTimerEvent(120.0);
	llDialog(id, "Bottom color" +
			"\n\nRed: " + (string)g_iPerRedStart + "%" +
			"\nGreen: " + (string)g_iPerGreenStart + "%" +
			"\nBlue: " + (string)g_iPerBlueStart + "%", [
			"Top color", "One color", "^Main menu",
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
	llSetTimerEvent(0.);
	llSetTimerEvent(120.);
	llDialog(id, "Top color" +
			"\n\nRed: " + (string)g_iPerRedEnd + "%" +
			"\nGreen: " + (string)g_iPerGreenEnd + "%" +
			"\nBlue: " + (string)g_iPerBlueEnd + "%", [
			"Bottom color", "One color", "^Options",
			"-Blue",  "+Blue",  "B min/max",
			"-Green", "+Green", "G min/max",
			"-Red",   "+Red",   "R min/max" ],
			g_iEndColorChannel);
}


optionsDialog (key kId)
{
	g_iMenuOpen = TRUE;

	string sParticleFire = "N/A";
	if (g_iParticleFireAvail) {
		if (g_iParticleFireOn) sParticleFire = "ON";
			else sParticleFire = "OFF";
	}

	string sPrimFire = "N/A";
	if (g_iPrimFireAvail) {
		if (g_iPrimFireOn) {
			if (g_iLowprim) sPrimFire = "ON, (temp)";
				else sPrimFire = "ON";
		} else sPrimFire = "OFF";
	}
	string strSmoke = "N/A";
	if (g_iSmokeAvail) {
		if (g_iSmokeOn) strSmoke = "ON";
			else strSmoke = "OFF";
	}
	string strSound = "N/A";
	if (g_iSoundAvail || g_iBackSoundAvail) {
		if (g_iSoundOn) {
			if (g_iBackSoundAvail && g_iSoundAvail) strSound = "ON";
			else if (g_iBackSoundAvail) strSound = "ON (back)";
			else strSound = "ON (normal)";
		} else strSound = "OFF";
	}
	string sVerbose = "???";
	if (g_iVerbose) {
		if (g_iVerboseButton) sVerbose = "ON";
			else sVerbose = "part. ON";
	} else if (g_iVerboseButton) sVerbose = "OFF";

	g_iOptionsChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
	llListenRemove(g_iOptionsHandle);
	g_iOptionsHandle = llListen(g_iOptionsChannel, "", "", "");
	llSetTimerEvent(0.0);
	llSetTimerEvent(120.0);
	llDialog(kId, "\t\tOptions" +
			"\n\nParticleFire: " + sParticleFire + "\tSmoke: " + strSmoke + "\tSound: " + strSound + "\nPrimFire:\t " + sPrimFire +"\t\t\t\tVerbose: " + sVerbose, [
			"^Main menu", "RESET", "Close",
			"Color", "FastToggle", "Verbose",
			"PrimFire", "---", "---",
			"ParticleFire", "Smoke", "Sound" ],
			g_iOptionsChannel);
}


reset()
{
	g_iParticleFireOn = g_iDefParticleFire;
	g_iPrimFireOn = g_iDefPrimFire;
	g_iSmokeOn = g_iDefSmoke;
	g_iSoundOn = g_iDefSound;
	g_iChangeVolume = g_iDefChangeVolume;
	g_fPerSize = (float)g_iDefSize;
	g_iPerVolume = g_iDefVolume;
	g_iPerRedStart = (integer)g_vDefStartColor.x;
	g_iPerGreenStart = (integer)g_vDefStartColor.y;
	g_iPerBlueStart = (integer)g_vDefStartColor.z;
	g_iPerRedEnd = (integer)g_vDefEndColor.x;
	g_iPerGreenEnd = (integer)g_vDefEndColor.y;
	g_iPerBlueEnd = (integer)g_vDefEndColor.z;

	sendMessage(COMMAND_CHANNEL, "config", "reset");

	//just send, don't check
	sendMessage(COMMAND_CHANNEL, "off", "");
	if (g_iVerbose) llWhisper(0, "(v) The fire gets taken care off");
}


startSystem()
{
	Debug("startSystem");
	llSetTimerEvent(0.0);
	if (g_iMenuOpen) {
		llListenRemove(g_iMenuHandle);
		llListenRemove(g_iStartColorHandle);
		llListenRemove(g_iEndColorHandle);
		llListenRemove(g_iOptionsHandle);
		g_iMenuOpen = FALSE;
	}
	g_fPercent = 100.0;
	g_fPercentSmoke = 100.0;
	if (g_iSoundAvail || g_iBackSoundAvail) { //needs some more rework, move all calculation inside
		g_fStartVolume = percentage((float)g_iPerVolume, MAX_VOLUME);
	}
	if (!g_iOn) {
		if (g_iSoundAvail && g_iSoundOn) sendMessage(SOUND_CHANNEL, "110", (string)g_fStartVolume); // special start sound
		if (g_iVerbose) llWhisper(0, "(v) The fire gets lit");
	}
	updateSize(g_fPerSize);
	llSetTimerEvent(g_fBurnTime);
	g_iOn = TRUE;
	g_iBurning = TRUE;
}


stopSystem()
{
	if (g_iVerbose && g_iOn) llWhisper(0, " (v) The fire is dying down");
	g_iOn = FALSE;
	g_iBurning = FALSE;
	g_fPercent = 0.0;
	g_fPercentSmoke = 0.0;
	llSetTimerEvent(0.0);
	if (g_iPrimFireOn) sendMessage(ANIM_CHANNEL, "0", "");
	if (g_iSmokeOn || g_iParticleFireOn) sendMessage(PARTICLE_CHANNEL, "0", "");
	if (g_iSoundAvail || g_iBackSoundAvail) sendMessage(SOUND_CHANNEL, "0", "0"); //volume off and size off
	if (g_iMenuOpen) {
		llListenRemove(g_iMenuHandle);
		llListenRemove(g_iStartColorHandle);
		llListenRemove(g_iEndColorHandle);
		llListenRemove(g_iOptionsHandle);
		g_iMenuOpen = FALSE;
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
sendMessage(integer iChan, string sVal, string sMsg )
{
	string sId = getGroup(LINKSETID) + SEPARATOR + g_sScriptName;
	string sSet = sVal + SEPARATOR + sMsg;
	llMessageLinked(LINK_SET, iChan, sSet, (key)sId);
}

infoLines()
{
	llWhisper(0, g_sTitle +" "+g_sVersion+" by "+g_sAuthors);
	llWhisper(0, "Touch to start/stop fire\n *Long touch to show menu*");
	if (g_iVerbose) {
		llWhisper(0, "(v) Switch access:" + showAccess(g_iSwitchAccess));
		llWhisper(0, "(v) Menu access:" + showAccess(g_iMenuAccess));
		llWhisper(0, "(v) Channel for remote control: "+ (string)g_iMsgNumber);
		llWhisper(0, "\n\t -free memory: "+(string)llGetFreeMemory()+" -\n(v) "+g_sTitle+"/"+ g_sScriptName);
	}
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
		sendMessage(COMMAND_CHANNEL, "register", "");
		if (g_iVerbose) llWhisper(0, "(v) Loading notecard...");
		loadNotecard();
	}

	on_rez(integer start_param)
	{
		llResetScript();
	}

	changed(integer change)
	{
		if (change & CHANGED_INVENTORY) {
			g_iParticleFireAvail = g_iParticleFireOn = FALSE;
			g_iPrimFireAvail = g_iPrimFireOn = FALSE;
			g_iSmokeAvail = g_iSmokeOn = FALSE;
			g_iSoundAvail = g_iBackSoundAvail = g_iDefSound = g_iSoundOn = FALSE;
			sendMessage(COMMAND_CHANNEL, "register", "");
			llWhisper(0, "Inventory changed, reloading notecard...");
			loadNotecard();
		}
	}

	touch_start(integer total_number)
	{
		g_kUser = llDetectedKey(0);
		llRegionSayTo(g_kUser, 0, "*Long touch to show menu*");
		llResetTime();
	}


	touch_end(integer total_number)
	{
		if (llGetTime() > 2.0) {
			if (accessGranted(g_kUser, g_iMenuAccess)) {
				if (!g_iOn) toggleFunktion("fire"); //do not use if fire is already burning
				//startSystem();
				menuDialog(g_kUser);
			} else llInstantMessage(g_kUser, "[Menu] Access denied");
		} else {
			if (accessGranted(g_kUser, g_iSwitchAccess)) toggleFunktion("fire");
				else llInstantMessage(g_kUser, "[Switch] Access denied");
		}
	}

	listen(integer channel, string name, key id, string msg)
	{
		Debug("LISTEN event: " + (string)channel + "; " + msg);

		if (channel == menuChannel) {
			llListenRemove(g_iMenuHandle);
			if (msg == "Small") g_fPerSize = SIZE_SMALL;
			else if (msg == "Medium") g_fPerSize = SIZE_MEDIUM;
			else if (msg == "Large") g_fPerSize = SIZE_LARGE;
			else if (msg == "-Fire") g_fPerSize = max((integer)g_fPerSize - 5, 5);
			else if (msg == "+Fire") g_fPerSize = min((integer)g_fPerSize + 5, 100);
			else if (msg == "-Volume") {
				g_iPerVolume = max(g_iPerVolume - 5, 0);
				g_fStartVolume = percentage(g_iPerVolume, MAX_VOLUME);
			} else if (msg == "+Volume") {
				g_iPerVolume = min(g_iPerVolume + 5, 100);
				g_fStartVolume = percentage(g_iPerVolume, MAX_VOLUME);
			} else if ("FastToggle" == msg) {
				if (g_iSmokeOn || g_iSoundOn || g_iParticleFireOn  || g_iPrimFireOn) {
					sendMessage(COMMAND_CHANNEL, "off", "");
					g_iParticleFireOn = g_iSmokeOn = g_iSoundOn = g_iPrimFireOn = FALSE;
				} else {
					if (!g_iParticleFireOn && g_iParticleFireAvail) toggleFunktion("particlefire");
					if (!g_iPrimFireOn && g_iPrimFireAvail) toggleFunktion("primfire");
					if (!g_iSmokeOn && g_iSmokeAvail) toggleFunktion("smoke");
					if (!g_iSoundOn && (g_iSoundAvail || g_iBackSoundAvail)) toggleFunktion("sound");
				}
			}

			if (msg != "Close" && "Options" != msg) {
				if ("FastToggle" != msg) updateSize(g_fPerSize);
				menuDialog(g_kUser);
			} else if (msg == "Options") optionsDialog(g_kUser);
			else if (msg == "Close") {
				llSetTimerEvent(0.0); // stop dialog timer
				llSetTimerEvent(g_fBurnTime); // restart burn timer
				g_iMenuOpen = FALSE;
			}
		}

		if (channel == g_iOptionsChannel) {
			llListenRemove(g_iOptionsHandle);
			if ("ParticleFire" == msg && g_iParticleFireAvail) toggleFunktion("particlefire");
			else if ("PrimFire" == msg && g_iPrimFireAvail) toggleFunktion("primfire");
			else if (msg == "Smoke" && g_iSmokeAvail) toggleFunktion("smoke");
			else if (msg == "Sound" && (g_iSoundAvail || g_iBackSoundAvail)) toggleFunktion("sound");
			else if (msg == "Color") endColorDialog(g_kUser);
			else if ("Verbose" == msg) {
				if (g_iVerbose && g_iVerboseButton) {
					sendMessage(COMMAND_CHANNEL, "nonverbose", "");
					g_iVerbose= FALSE;
				} else {
					sendMessage(COMMAND_CHANNEL, "verbose", "");
					g_iVerbose= TRUE;
					infoLines();
				}
				g_iVerboseButton = TRUE;
			} else if ("FastToggle" == msg) {
				if (g_iSmokeOn || g_iSoundOn || g_iParticleFireOn  || g_iPrimFireOn) {
					sendMessage(COMMAND_CHANNEL, "off", "");
					g_iParticleFireOn = g_iSmokeOn = g_iSoundOn = g_iPrimFireOn = FALSE;
					} else {
						if (!g_iParticleFireOn && g_iParticleFireAvail) toggleFunktion("particlefire");
						if (!g_iPrimFireOn && g_iPrimFireAvail) toggleFunktion("primfire");
						if (!g_iSmokeOn && g_iSmokeAvail) toggleFunktion("smoke");
						if (!g_iSoundOn && (g_iSoundAvail || g_iBackSoundAvail)) toggleFunktion("sound");
					}
				} else if (msg == "RESET") { reset(); startSystem(); }

			if ("Color" != msg && msg != "^Main menu" && "Close" != msg) {
				optionsDialog(g_kUser);
			} else if (msg == "^Main menu") menuDialog(g_kUser);
				else if (msg == "Close") {
					llSetTimerEvent(0.0); //stop dialog timer
					llSetTimerEvent(g_fBurnTime); //restart burn timer
					g_iMenuOpen = FALSE;
				}

			} else if (channel == g_iStartColorChannel) {
				Debug("startcolor");
				llListenRemove(g_iStartColorHandle);
				setColor(1, msg);
				if (msg != "Top color" && msg != "^Main menu") {
					Debug("do it (start)");
					sendMessage(COMMAND_CHANNEL, "config", "startcolor="+msg);
					//updateSize(g_fPerSize);
					startColorDialog(g_kUser);
				} else if (msg == "Top color") endColorDialog(g_kUser);
				else if (msg == "^Main menu") menuDialog(g_kUser);

			} else if (channel == g_iEndColorChannel) {
				Debug("endcolor");
				llListenRemove(g_iEndColorHandle);
				setColor(0, msg);
				if (msg != "Bottom color" && msg != "^Options") {
					Debug("do it (start)");
					sendMessage(COMMAND_CHANNEL, "config", "endcolor="+msg);
					//updateSize(g_fPerSize);
					endColorDialog(g_kUser);
				} else if (msg == "Bottom color") startColorDialog(g_kUser);
				else if (msg == "^Options") optionsDialog(g_kUser);
			}
		}

//listen for linked messages from other RealFire scripts and devices
//-----------------------------------------------
	link_message(integer iSender_number, integer iChan, string sMsg, key kId)
	{
		Debug("link_message= channel: " + (string)iChan + "; Message: " + sMsg + ";Key: " + (string)kId);

		if (iChan == COMMAND_CHANNEL) return;
		string sScriptName = GroupCheck(kId);
		if ("exit" == sScriptName) return;

		if (iChan == ANIM_CHANNEL && llToLower(sScriptName) != llToLower(g_sScriptName)) {
			if (sScriptName == PRIMFIREANIMSCRIPT) {
				if ("1" == sMsg) {
					g_iPrimFireAvail = TRUE;
					llWhisper(0, "PrimFire available");
					if (g_iDefPrimFire && g_iOn) { //if only smoke scripts gets resetted - is normally in another prim!
						g_iPrimFireOn = !g_iPrimFireOn; //important to get it toggled
						toggleFunktion("primfire");
					}
				} else g_iPrimFireAvail = FALSE;
			}
			if (sScriptName == TEXTUREANIMSCRIPT) {
				if ("1" == sMsg){
					//g_iBackSoundAvail = TRUE;
					llWhisper(0, "Texture animations available");
				} else ;//g_iBackSoundAvail = FALSE;
			}
			if ("1" != sMsg ) llWhisper(0, "Unable to provide animations ("+sScriptName+")");

		} else if (iChan == PARTICLE_CHANNEL && llToLower(sScriptName) != llToLower(g_sScriptName)) {
			if (sScriptName == PARTICLEFIREANIMSCRIPT) {
				if ("1" == sMsg) {
					g_iParticleFireAvail = TRUE;
					if ("" != g_sConfLine) sendMessage(COMMAND_CHANNEL, "config", g_sConfLine);
					llWhisper(0, "ParticleFire available");
					if (g_iDefParticleFire && g_iOn) { //if only smoke scripts gets resetted - is normally in another prim!
						g_iParticleFireOn = !g_iParticleFireOn; //important to get it toggled
						toggleFunktion("particlefire");
					}
				} else g_iParticleFireAvail = FALSE;
			}
			if (sScriptName == SMOKESCRIPT) {
				if ("1" == sMsg) {
					g_iSmokeAvail = TRUE;
					llWhisper(0, "Smoke available");
					if (g_iDefSmoke && g_iOn) { //if only smoke scripts gets resetted - is normally in another prim!
						g_iSmokeOn = !g_iSmokeOn; //important to get it toggled
						toggleFunktion("smoke");
					}
				} else g_iSmokeAvail = FALSE;
			}
			if ("1" != sMsg ) llWhisper(0, "Unable to provide particle effects ("+sScriptName+")");

		} else if (iChan == SOUND_CHANNEL && llToLower(sScriptName) != llToLower(g_sScriptName)) {
			if (sScriptName == SOUNDSCRIPT) {
				if ("1" == sMsg) {
					g_iSoundAvail = TRUE;
					llWhisper(0, "Noise available");
					if (g_iDefSound && g_iOn) { //if only sound scripts gets resetted - one of them should be another prim!
						g_iSoundOn = !g_iSoundOn; //important to get it toggled
						toggleFunktion("sound");
					}
				} else g_iSoundAvail = FALSE;
			} else if (sScriptName == BACKSOUNDSCRIPT) {
				if ("1" == sMsg){
					g_iBackSoundAvail = TRUE;
					llWhisper(0, "Ambience sound available");
					if (g_iDefSound && g_iOn) { //if only sound scripts gets resetted
						g_iSoundOn = !g_iSoundOn; //important to get it toggled
						toggleFunktion("sound");
					}
				} else g_iBackSoundAvail = FALSE;
			}
			if ("1" != sMsg ) llWhisper(0, "Unable to provide sound effects ("+sScriptName+")");

		} else if (iChan == REMOTE_CHANNEL) {
				if ("1" == sMsg) {
					llWhisper(0, "Remote receiver activated");
					if ("" != g_sConfLine) sendMessage(COMMAND_CHANNEL, "config", g_sConfLine);
				}

		} else if (iChan == g_iMsgNumber) {
			if (kId != "") g_kUser = kId;
				else {
					llWhisper(0, "A valid avatar key must be provided in the link message.");
					return;
				}

			if (sMsg == g_sMsgSwitch) {
				if (accessGranted(g_kUser, g_iSwitchAccess)) toggleFunktion("fire");
					else llInstantMessage(g_kUser, "[Switch] Access denied");
			} else if (sMsg == g_sMsgOn) {
				if (accessGranted(g_kUser, g_iSwitchAccess)) startSystem();
					else llInstantMessage(g_kUser, "[Switch] Access denied");
				}
			else if (sMsg == g_sMsgOff) {
				if (accessGranted(g_kUser, g_iSwitchAccess)) stopSystem();
				else llInstantMessage(g_kUser, "[Switch] Access denied");
			} else if (sMsg == g_sMsgMenu) {
				if (accessGranted(g_kUser, g_iMenuAccess)) {
					startSystem();
					menuDialog(g_kUser);
				} else llInstantMessage(g_kUser, "[Menu] Access denied");
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
			if (!g_iBurnDown) g_fBurnTime = 315360000;   //10 years
			g_fTime = g_fDieTime / 100.0;                //try to get a one percent timer interval
			if (g_fTime < 1.0) g_fTime = 1.0;            //but never smaller than one second
			g_fDecPercent = 100.0 / (g_fDieTime / g_fTime); //and burn down decPercent% every time

			g_vDefStartColor.x = checkInt("ColorOn (RED)", (integer)g_vDefStartColor.x, 0, 100);
			g_vDefStartColor.y = checkInt("ColorOn (GREEN)", (integer)g_vDefStartColor.y, 0, 100);
			g_vDefStartColor.z = checkInt("ColorOn (BLUE)", (integer)g_vDefStartColor.z, 0, 100);
			g_vDefEndColor.x = checkInt("ColorOff (RED)", (integer)g_vDefEndColor.x, 0, 100);
			g_vDefEndColor.y = checkInt("ColorOff (GREEN)", (integer)g_vDefEndColor.y, 0, 100);
			g_vDefEndColor.z = checkInt("ColorOff (BLUE)", (integer)g_vDefEndColor.z, 0, 100);

			g_fStartVolume = percentage((float)g_iDefVolume, MAX_VOLUME);

			if ("" != g_sConfLine) sendMessage(COMMAND_CHANNEL, "config", g_sConfLine);

			reset(); //initial values for menu

			if (g_iOn) startSystem();
			if (g_iVerbose) infoLines();

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
			llWhisper(0, "MENU TIMEOUT");
			llListenRemove(g_iMenuHandle);
			llListenRemove(g_iStartColorHandle);
			llListenRemove(g_iEndColorHandle);
			llListenRemove(g_iOptionsHandle);
			llSetTimerEvent(0.0); //stop dialog timer
			llSetTimerEvent(g_fBurnTime); //restart burn timer
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
			updateSize(g_fPercent / (100.0 / g_fPerSize));
		} else {
			if (g_iLoop) startSystem();
				else stopSystem();
		}
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}