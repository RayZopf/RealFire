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
//Additions: ---
//12. Dec. 2013
//v2.2-0.1

//Files:
//Fire.lsl
//
//Smoke.lsl
//config
//User Manual
//
//
//Prequisites: Smoke.lsl in another prim than Fire.lsl
//Notecard format: see config NC
//basic help: User Manual

//Changelog
//Formatting

//bug: ---

//todo: ---
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
integer g_iDebugMode=TRUE; // set to TRUE to enable Debug messages
integer debug = FALSE;          // show debug messages


//user changeable variables
//-----------------------------------------------
string NOTECARD = "config";     // notecard name

// Particle parameters
float g_fAge = 1.0;                // particle lifetime
float g_fRate = 0.1;               // particle burst rate
integer g_fCount = 10;             // particle count
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
string g_sVersion = "2.2";         // version

// Constants
integer ACCESS_OWNER = 4;            // owner access bit
integer ACCESS_GROUP = 2;            // group access bit
integer ACCESS_WORLD = 1;            // world access bit
integer SMOKE_CHANNEL = -10957;  // smoke channel
float MAX_COLOR = 1.0;             // max. red, green, blue
float MAX_INTENSITY = 1.0;       // max. light intensity
float MAX_RADIUS = 20.0;         // max. light radius
float MAX_FALLOFF = 2.0;         // max. light falloff
float MAX_VOLUME = 1.0;          // max. volume for sound

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
integer g_iDefSound = TRUE;        // default sound on/off
integer g_iDefIntensity;           // default light intensity (percentage)
integer g_iDefRadius;              // default light radius (percentage)
integer g_iDefFalloff;             // default light falloff (percentage)

// Variables
key g_kOwner;                      // object owner
key g_kUser;                       // key of last avatar to touch object
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
integer g_iSmokeOn = TRUE;         // smoke on/off
integer g_iSoundOn = TRUE;         // sound on/off
integer g_iMenuOpen = FALSE;       // a menu is open or canceled (ignore button)
float g_fTime;                     // timer interval in seconds
float g_fPercent;                  // percentage of particle size
float g_fPercentSmoke;             // percentage of smoke
float g_fDecPercent;               // how much to burn down (%) every timer interval
vector g_vLightColor;              // light color
float g_fLightIntensity;           // light intensity (changed by burning down)
float g_fLightRadius;              // light radius (changed by burning down)
float g_fLightFalloff;             // light falloff
float g_fSoundVolume;              // sound volume (changed by burning down)
string g_iSoundFile;                   // first sound in inventory
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
    llOwnerSay("DEBUG: "+ llGetScriptName() + ": " + sMsg);
}


toggleFire()
{
    if (g_iOn) stopSystem(); else startSystem();
}

toggleSmoke()
{
    if (g_iSmokeOn) {
        sendMessage(0);
        g_iSmokeOn = FALSE;
    }
    else {
        sendMessage(100);
        g_iSmokeOn = TRUE;
    }
}

toggleSound()
{
    if (g_iSoundOn) {
        llStopSound();
        g_iSoundOn = FALSE;
    }
    else {
        if (g_iSoundFile) llLoopSound(g_iSoundFile, g_fSoundVolume);
        g_iSoundOn = TRUE;
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

    if (size > 25.0) {
        start = g_vStartScale / 100.0 * size;     // start scale
        radius = g_fBurstRadius / 100.0 * size;   // burst radius
        if (size >= 80) llSetLinkTextureAnim(LINK_SET, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,9);
            else if (size > 50) llSetLinkTextureAnim(LINK_SET, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,6);
                else llSetLinkTextureAnim(LINK_SET, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,4);
    }
    else {
        if (size >= 15) llSetLinkTextureAnim(LINK_SET, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,3);
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
        if (g_iChangeSmoke) g_fPercentSmoke = size * 4.0;
        else g_fPercentSmoke = 100.0;
        if (g_iChangeVolume) g_fSoundVolume = percentage(size * 4.0, g_fStartVolume);
        else g_fSoundVolume = g_fStartVolume;
    }

    updateColor();
    updateParticles(start, end, min, max, radius, push);
    llSetPrimitiveParams([PRIM_POINT_LIGHT, TRUE, g_vLightColor, g_fLightIntensity, g_fLightRadius, g_fLightFalloff]);
    if (g_iSmokeOn) sendMessage(llRound(g_fPercentSmoke));
    if (g_iSoundFile) if (g_iSoundOn) llAdjustSoundVolume(g_fSoundVolume);
    if (debug && g_iBurnDown) llOwnerSay((string)llRound(size) + "% " + (string)start + " " + (string)end);
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
    g_iDefSound = TRUE;
    g_iDefIntensity = 100;
    g_iDefRadius = 50;
    g_iDefFalloff = 40;
    g_iLine = 0;

    if (!g_iBurnDown) g_fBurnTime = 315360000;   // 10 years
    g_fTime = g_fDieTime / 100.0;                // try to get a one percent timer interval
    if (g_fTime < 1.0) g_fTime = 1.0;            // but never smaller than one second
    g_fDecPercent = 100.0 / (g_fDieTime / g_fTime); // and burn down decPercent% every time

    g_fStartIntensity = percentage(g_iDefIntensity, MAX_INTENSITY);
    g_fStartRadius = percentage(g_iDefRadius, MAX_RADIUS);
    g_fLightFalloff = percentage(g_iDefFalloff, MAX_FALLOFF);
    g_fStartVolume = percentage(g_iDefVolume, MAX_VOLUME);

    if (llGetInventoryType(NOTECARD) == INVENTORY_NOTECARD) {
        llGetNotecardLine(NOTECARD, g_iLine);
    }
    else {
        llWhisper(0, "Notecard \"" + NOTECARD + "\" not found or empty, using defaults");
        reset(); // initial values for menu
        if (g_iOn) startSystem();
        if (g_iVerbose) {
            if (g_iSoundFile) llWhisper(0, "Sound in object inventory: Yes");
            else llWhisper(0, "Sound in object inventory: No");
        }
        llWhisper(0, g_sTitle + " " + g_sVersion + " ready");
        if (debug) {
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
    llGetNotecardLine(NOTECARD, g_iLine);
}

menuDialog (key id)
{
    g_iMenuOpen = TRUE;
    string strSmoke = "OFF"; if (g_iSmokeOn) strSmoke = "ON";
    string strSound = "NONE"; if (g_iSoundFile) if (g_iSoundOn) strSound = "ON"; else strSound = "OFF";
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
    g_iSmokeOn = g_iDefSmoke;
    g_iSoundOn = g_iDefSound;
    g_iPerSize = g_iDefSize;
    g_iPerVolume = g_iDefVolume;
    g_iPerRedStart = (integer)g_vDefStartColor.x;
    g_iPerGreenStart = (integer)g_vDefStartColor.y;
    g_iPerBlueStart = (integer)g_vDefStartColor.z;
    g_iPerRedEnd = (integer)g_vDefEndColor.x;
    g_iPerGreenEnd = (integer)g_vDefEndColor.y;
    g_iPerBlueEnd = (integer)g_vDefEndColor.z;
}

startSystem()
{
    g_iOn = TRUE;
    g_iBurning = TRUE;
    g_fPercent = 100.0;
    g_fPercentSmoke = 100.0;
    g_iSmokeOn = !g_iSmokeOn;
    toggleSmoke();
    g_fStartVolume = percentage(g_iPerVolume, MAX_VOLUME);
    g_fLightIntensity = g_fStartIntensity;
    g_fLightRadius = g_fStartRadius;
    g_fSoundVolume = g_fStartVolume;
    updateSize((float)g_iPerSize);
    llStopSound();
    if (g_iSoundFile) if (g_iSoundOn) llLoopSound(g_iSoundFile, g_fSoundVolume);
    llSetTimerEvent(0);
    llSetTimerEvent(g_fBurnTime);
    if (g_iMenuOpen) {
        llListenRemove(g_iMenuHandle);
        llListenRemove(g_iStartColorHandle);
        llListenRemove(g_iEndColorHandle);
        g_iMenuOpen = FALSE;
    }
}

stopSystem()
{
    g_iOn = FALSE;
    g_iBurning = FALSE;
    g_fPercent = 0.0;
    g_fPercentSmoke = 0.0;
    llSetTimerEvent(0);
    llParticleSystem([]);
    llSetPrimitiveParams([PRIM_POINT_LIGHT, FALSE, ZERO_VECTOR, 0, 0, 0]);
    llStopSound();
    sendMessage(0);
    if (g_iMenuOpen) {
        llListenRemove(g_iMenuHandle);
        llListenRemove(g_iStartColorHandle);
        llListenRemove(g_iEndColorHandle);
        g_iMenuOpen = FALSE;
    }
    llSetLinkTextureAnim(LINK_SET, FALSE, ALL_SIDES,4,4,0,0,1);
}

updateParticles(vector start, vector end, float min, float max, float radius, vector push)
{
    llParticleSystem ([
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
        PSYS_PART_START_COLOR, g_vStartColor,
        PSYS_PART_END_COLOR, g_vEndColor,
        PSYS_PART_START_ALPHA, 1.0,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, start,
        PSYS_PART_END_SCALE, end,
        PSYS_PART_MAX_AGE, g_fAge,
        PSYS_SRC_BURST_RATE, g_fRate,
        PSYS_SRC_BURST_PART_COUNT, g_fCount,
        PSYS_SRC_BURST_SPEED_MIN, min,
        PSYS_SRC_BURST_SPEED_MAX, max,
        PSYS_SRC_BURST_RADIUS, radius,
        PSYS_SRC_ACCEL, push,
        PSYS_PART_FLAGS,
        0 |
        PSYS_PART_EMISSIVE_MASK |
        PSYS_PART_FOLLOW_VELOCITY_MASK |
        PSYS_PART_INTERP_COLOR_MASK |
        PSYS_PART_INTERP_SCALE_MASK ]);
}

sendMessage(integer number)
{
    llMessageLinked(LINK_ALL_OTHERS, smokeChannel, (string)number, "");
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
        g_iSoundFile = llGetInventoryName(INVENTORY_SOUND, 0); // get first sound from inventory
        if (g_iSoundFile) llPreloadSound(g_iSoundFile);
        stopSystem();
        if (debug) {
            llOwnerSay("Particle g_fCount: " + (string)llRound((float)count * g_fAge / g_fRate));
            llOwnerSay((string)llGetFreeMemory() + " bytes free");
        }
        llWhisper(0, "RealFire by Rene10957");
        llWhisper(0, "Loading notecard...");
        loadNotecard();
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }
	
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY) {
            llWhisper(0, "Inventory changed, reloading notecard...");
            g_iSoundFile = llGetInventoryName(INVENTORY_SOUND, 0); // get first sound from inventory
            if (g_iSoundFile) llPreloadSound(g_iSoundFile);
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

        if (llGetTime() > 1.0) {
            if (accessGranted(g_kUser, g_iMenuAccess)) {
                startSystem();
                menuDialog(g_kUser);
            }
            else llInstantMessage(g_kUser, "[Menu] Access denied");
        }
        else {
            if (accessGranted(g_kUser, g_iSwitchAccess)) toggleFire();
            else llInstantMessage(g_kUser, "[Switch] Access denied");
        }
    }

    listen(integer channel, string name, key id, string msg)
    {
        if (debug) llOwnerSay("[Fire] LISTEN event: " + (string)channel + "; " + msg);

        if (channel == menuChannel) {
            llListenRemove(g_iMenuHandle);
            if (msg == "Small") g_iPerSize = 25;
            else if (msg == "Medium") g_iPerSize = 50;
            else if (msg == "Large") g_iPerSize = 75;
            else if (msg == "-Fire") g_iPerSize = max(g_iPerSize - 5, 5);
            else if (msg == "+Fire") g_iPerSize = min(g_iPerSize + 5, 100);
            else if (msg == "-Volume") {
                g_iPerVolume = max(g_iPerVolume - 5, 5);
                g_fStartVolume = percentage(g_iPerVolume, MAX_VOLUME);
            }
            else if (msg == "+Volume") {
                g_iPerVolume = min(g_iPerVolume + 5, 100);
                g_fStartVolume = percentage(g_iPerVolume, MAX_VOLUME);
            }
            else if (msg == "Smoke") toggleSmoke();
            else if (msg == "Sound") toggleSound();
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
	
//listen for linked messages from OC scripts
//-----------------------------------------------
    link_message(integer sender_number, integer number, string msg, key id)
    {
        if (debug) llOwnerSay("[Fire] LINK_MESSAGE event: " + (string)number + "; " + msg + "; " + (string)id);
        if (number != g_iMsgNumber) return;

        if (id) g_kUser = id;
        else {
            llWhisper(0, "A valid avatar key must be provided in the link message.");
            return;
        }

        if (msg == g_sMsgSwitch) {
            if (accessGranted(g_kUser, g_iSwitchAccess)) toggleFire();
            else llInstantMessage(g_kUser, "[Switch] Access denied");
        }
        else if (msg == g_sMsgOn) {
            if (accessGranted(g_kUser, g_iSwitchAccess)) startSystem();
            else llInstantMessage(g_kUser, "[Switch] Access denied");
        }
        else if (msg == g_sMsgOff) {
            if (accessGranted(g_kUser, g_iSwitchAccess)) stopSystem();
            else llInstantMessage(g_kUser, "[Switch] Access denied");
        }
        else if (msg == g_sMsgMenu) {
            if (accessGranted(g_kUser, g_iMenuAccess)) {
                startSystem();
                menuDialog(g_kUser);
            }
            else llInstantMessage(g_kUser, "[Menu] Access denied");
        }
    }
	
//get presets from notecard
//-----------------------------------------------
    dataserver(key req, string data)
    {
        if (data == EOF) {
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
            g_fStartVolume = percentage(g_iDefVolume, MAX_VOLUME);

            reset(); // initial values for menu
            if (g_iOn) startSystem();

            if (g_iVerbose) {
                llWhisper(0, "Touch to start/stop fire");
                llWhisper(0, "Long touch to show menu");
                llWhisper(0, "Switch access:" + showAccess(g_iSwitchAccess));
                llWhisper(0, "Menu access:" + showAccess(g_iMenuAccess));
                if (g_iSoundFile) llWhisper(0, "Sound in object inventory: Yes");
                else llWhisper(0, "Sound in object inventory: No");
            }
            llWhisper(0, g_sTitle + " " + g_sVersion + " ready");

            if (debug) {
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
        else {
            readNotecard(data);
        }
    }

    timer()
    {
        if (g_iMenuOpen) {
            if (debug) llOwnerSay("MENU TIMEOUT");
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
