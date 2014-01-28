// Realfire by Rene - Fire
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

string title = "RealFire";      // title
string version = "2.2.1";       // version
string notecard = "config";     // notecard name
integer debug = FALSE;          // show debug messages

// Constants

integer _OWNER_ = 4;            // owner access bit
integer _GROUP_ = 2;            // group access bit
integer _WORLD_ = 1;            // world access bit
integer smokeChannel = -15790;  // smoke channel
float maxRed = 1.0;             // max. red
float maxGreen = 1.0;           // max. green
float maxBlue = 1.0;            // max. blue
float maxIntensity = 1.0;       // max. light intensity
float maxRadius = 20.0;         // max. light radius
float maxFalloff = 2.0;         // max. light falloff
float maxVolume = 1.0;          // max. volume for sound

// Notecard variables

integer verbose = TRUE;         // show more/less info during startup
integer switchAccess;           // access level for switch
integer menuAccess;             // access level for menu
integer msgNumber;              // number part of incoming link messages
string msgSwitch;               // string part of incoming link message: switch (on/off)
string msgOn;                   // string part of incoming link message: switch on
string msgOff;                  // string part of incoming link message: switch off
string msgMenu;                 // string part of incoming link message: show menu
integer burnDown = FALSE;       // burn down or burn continuously
float burnTime;                 // time to burn in seconds before starting to die
float dieTime;                  // time it takes to die in seconds
integer loop = FALSE;           // restart after burning down
integer changeLight = TRUE;     // change light with fire
integer changeSmoke = TRUE;     // change smoke with fire
integer changeVolume = TRUE;    // change volume with fire
integer defSize;                // default fire size (percentage)
vector defStartColor;           // default start (bottom) color (percentage R,G,B)
vector defEndColor;             // default end (top) color (percentage R,G,B)
integer defVolume;              // default volume for sound (percentage)
integer defSmoke = TRUE;        // default smoke on/off
integer defSound = TRUE;        // default sound on/off
integer defIntensity;           // default light intensity (percentage)
integer defRadius;              // default light radius (percentage)
integer defFalloff;             // default light falloff (percentage)

// Particle parameters

float age = 1.0;                // particle lifetime
float rate = 0.1;               // particle burst rate
integer count = 10;             // particle count
vector startScale = <0.4, 2, 0>;// particle start size (100%)
vector endScale = <0.4, 2, 0>;  // particle end size (100%)
float minSpeed = 0.0;           // particle min. burst speed (100%)
float maxSpeed = 0.04;          // particle max. burst speed (100%)
float burstRadius = 0.4;        // particle burst radius (100%)
vector partAccel = <0, 0, 10>;  // particle accelleration (100%)
vector startColor = <1, 1, 0>;  // particle start color
vector endColor = <1, 0, 0>;    // particle end color

// Variables

key owner;                      // object owner
key user;                       // key of last avatar to touch object
integer line;                   // notecard line
integer menuChannel;            // main menu channel
integer startColorChannel;      // start color menu channel
integer endColorChannel;        // end color menu channel
integer menuHandle;             // handle for main menu listener
integer startColorHandle;       // handle for start color menu listener
integer endColorHandle;         // handle for end color menu listener
integer perRedStart;            // percent red for startColor
integer perGreenStart;          // percent green for startColor
integer perBlueStart;           // percent blue for startColor
integer perRedEnd;              // percent red for endColor
integer perGreenEnd;            // percent green for endColor
integer perBlueEnd;             // percent blue for endColor
integer perSize;                // percent particle size
integer perVolume;              // percent volume
integer on = FALSE;             // fire on/off
integer burning = FALSE;        // burning constantly
integer smokeOn = TRUE;         // smoke on/off
integer soundOn = TRUE;         // sound on/off
integer menuOpen = FALSE;       // a menu is open or canceled (ignore button)
float time;                     // timer interval in seconds
float percent;                  // percentage of particle size
float percentSmoke;             // percentage of smoke
float decPercent;               // how much to burn down (%) every timer interval
vector lightColor;              // light color
float lightIntensity;           // light intensity (changed by burning down)
float lightRadius;              // light radius (changed by burning down)
float lightFalloff;             // light falloff
float soundVolume;              // sound volume (changed by burning down)
string sound;                   // first sound in inventory
float startIntensity;           // start value of lightIntensity (before burning down)
float startRadius;              // start value of lightRadius (before burning down)
float startVolume;              // start value of volume (before burning down)

// Functions

string getGroup()
{
    string str = llStringTrim(llGetObjectDesc(), STRING_TRIM);
    if (llToLower(str) == "(no description)" || str == "") str = "Default";
    return str;
}

toggleFire()
{
    if (on) stopSystem(); else startSystem();
}

toggleSmoke()
{
    if (smokeOn) {
        sendMessage(0);
        smokeOn = FALSE;
    }
    else {
        sendMessage(100);
        smokeOn = TRUE;
    }
}

toggleSound()
{
    if (soundOn) {
        llStopSound();
        soundOn = FALSE;
    }
    else {
        if (sound) llLoopSound(sound, soundVolume);
        soundOn = TRUE;
    }
}

updateSize(float size)
{
    vector start;
    vector end;
    float min;
    float max;
    float radius;
    vector push;

    end = endScale / 100.0 * size;             // end scale
    min = minSpeed / 100.0 * size;             // min. burst speed
    max = maxSpeed / 100.0 * size;             // max. burst speed
    push = partAccel / 100.0 * size;           // accelleration

    if (size > 25.0) {
        start = startScale / 100.0 * size;     // start scale
        radius = burstRadius / 100.0 * size;   // burst radius
    }
    else {
        start = startScale / 4.0;              // start scale
        radius = burstRadius / 4.0;            // burst radius
        if (size < 5.0) {
            start.y = startScale.y / 100.0 * size * 5.0;
            if (start.y < 0.25) start.y = 0.25;
        }
        if (changeLight) {
            lightIntensity = percentage(size * 4.0, startIntensity);
            lightRadius = percentage(size * 4.0, startRadius);
        }
        else {
            lightIntensity = startIntensity;
            lightRadius = startRadius;
        }
        if (changeSmoke) percentSmoke = size * 4.0;
        else percentSmoke = 100.0;
        if (changeVolume) soundVolume = percentage(size * 4.0, startVolume);
        else soundVolume = startVolume;
    }

    updateColor();
    updateParticles(start, end, min, max, radius, push);
    llSetPrimitiveParams([PRIM_POINT_LIGHT, TRUE, lightColor, lightIntensity, lightRadius, lightFalloff]);
    if (smokeOn) sendMessage(llRound(percentSmoke));
    if (sound) if (soundOn) llAdjustSoundVolume(soundVolume);
    if (debug && burnDown) llOwnerSay((string)llRound(size) + "% " + (string)start + " " + (string)end);
}

updateColor()
{
    startColor.x = percentage((float)perRedStart, maxRed);
    startColor.y = percentage((float)perGreenStart, maxGreen);
    startColor.z = percentage((float)perBlueStart, maxBlue);

    endColor.x = percentage((float)perRedEnd, maxRed);
    endColor.y = percentage((float)perGreenEnd, maxGreen);
    endColor.z = percentage((float)perBlueEnd, maxBlue);

    lightColor = (startColor + endColor) / 2.0; // light color = average of start & end color
}

integer accessGranted(key user, integer access)
{
    integer bitmask = _WORLD_;
    if (user == owner) bitmask += _OWNER_;
    if (llSameGroup(user)) bitmask += _GROUP_;
    return (bitmask & access);
}

string showAccess(integer access)
{
    string strAccess;
    if (access) {
        if (access & _OWNER_) strAccess += " Owner";
        if (access & _GROUP_) strAccess += " Group";
        if (access & _WORLD_) strAccess += " World";
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
    verbose = TRUE;
    switchAccess = _WORLD_;
    menuAccess = _WORLD_;
    msgNumber = 10957;
    msgSwitch = "switch";
    msgOn = "on";
    msgOff = "off";
    msgMenu = "menu";
    burnDown = FALSE;
    burnTime = 300.0;
    dieTime = 300.0;
    loop = FALSE;
    changeLight = TRUE;
    changeSmoke = TRUE;
    changeVolume = TRUE;
    defSize = 25;
    defStartColor = <100,100,0>;
    defEndColor = <100,0,0>;
    defVolume = 100;
    defSmoke = TRUE;
    defSound = TRUE;
    defIntensity = 100;
    defRadius = 50;
    defFalloff = 40;
    line = 0;

    if (!burnDown) burnTime = 315360000;   // 10 years
    time = dieTime / 100.0;                // try to get a one percent timer interval
    if (time < 1.0) time = 1.0;            // but never smaller than one second
    decPercent = 100.0 / (dieTime / time); // and burn down decPercent% every time

    startIntensity = percentage(defIntensity, maxIntensity);
    startRadius = percentage(defRadius, maxRadius);
    lightFalloff = percentage(defFalloff, maxFalloff);
    startVolume = percentage(defVolume, maxVolume);

    if (llGetInventoryType(notecard) == INVENTORY_NOTECARD) {
        llGetNotecardLine(notecard, line);
    }
    else {
        llWhisper(0, "Notecard \"" + notecard + "\" not found or empty, using defaults");
        reset(); // initial values for menu
        if (on) startSystem();
        if (verbose) {
            if (sound) llWhisper(0, "Sound in object inventory: Yes");
            else llWhisper(0, "Sound in object inventory: No");
        }
        llWhisper(0, title + " " + version + " ready");
        if (debug) {
            llOwnerSay("verbose = " + (string)verbose);
            llOwnerSay("switchAccess = " + (string)switchAccess);
            llOwnerSay("menuAccess = " + (string)menuAccess);
            llOwnerSay("msgNumber = " + (string)msgNumber);
            llOwnerSay("msgSwitch = " + msgSwitch);
            llOwnerSay("msgOn = " + msgOn);
            llOwnerSay("msgOff = " + msgOff);
            llOwnerSay("msgMenu = " + msgMenu);
            llOwnerSay("burnDown = " + (string)burnDown);
            llOwnerSay("burnTime = " + (string)burnTime);
            llOwnerSay("dieTime = " + (string)dieTime);
            llOwnerSay("loop = " + (string)loop);
            llOwnerSay("changeLight = " + (string)changeLight);
            llOwnerSay("changeSmoke = " + (string)changeSmoke);
            llOwnerSay("changeVolume = " + (string)changeVolume);
            llOwnerSay("defSize = " + (string)defSize);
            llOwnerSay("defStartColor = " + (string)defStartColor);
            llOwnerSay("defEndColor = " + (string)defEndColor);
            llOwnerSay("defVolume = " + (string)defVolume);
            llOwnerSay("defSmoke = " + (string)defSmoke);
            llOwnerSay("defSound = " + (string)defSound);
            llOwnerSay("defIntensity = " + (string)defIntensity);
            llOwnerSay("defRadius = " + (string)defRadius);
            llOwnerSay("defFalloff = " + (string)defFalloff);
            llOwnerSay("time = " + (string)time);
            llOwnerSay("decPercent = " + (string)decPercent);
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
        if (lcpar == "verbose") verbose = checkYesNo("verbose", val);
        else if (lcpar == "switchaccess") switchAccess = checkInt("switchAccess", (integer)val, 0, 7);
        else if (lcpar == "menuaccess") menuAccess = checkInt("menuAccess", (integer)val, 0, 7);
        else if (lcpar == "msgnumber") msgNumber = (integer)val;
        else if (lcpar == "msgswitch") msgSwitch = val;
        else if (lcpar == "msgon") msgOn = val;
        else if (lcpar == "msgoff") msgOff = val;
        else if (lcpar == "msgmenu") msgMenu = val;
        else if (lcpar == "burndown") burnDown = checkYesNo("burndown", val);
        else if (lcpar == "burntime") burnTime = (float)checkInt("burnTime", (integer)val, 1, 315360000); // 10 years
        else if (lcpar == "dietime") dieTime = (float)checkInt("dieTime", (integer)val, 1, 315360000); // 10 years
        else if (lcpar == "loop") loop = checkYesNo("loop", val);
        else if (lcpar == "changelight") changeLight = checkYesNo("changeLight", val);
        else if (lcpar == "changesmoke") changeSmoke = checkYesNo("changeSmoke", val);
        else if (lcpar == "changevolume") changeVolume = checkYesNo("changeVolume", val);
        else if (lcpar == "size") defSize = checkInt("size", (integer)val, 0, 100);
        else if (lcpar == "topcolor") defEndColor = checkVector("topColor", (vector)val);
        else if (lcpar == "bottomcolor") defStartColor = checkVector("bottomColor", (vector)val);
        else if (lcpar == "volume") defVolume = checkInt("volume", (integer)val, 0, 100);
        else if (lcpar == "smoke") defSmoke = checkYesNo("smoke", val);
        else if (lcpar == "sound") defSound = checkYesNo("sound", val);
        else if (lcpar == "intensity") defIntensity = checkInt("intensity", (integer)val, 0, 100);
        else if (lcpar == "radius") defRadius = checkInt("radius", (integer)val, 0, 100);
        else if (lcpar == "falloff") defFalloff = checkInt("falloff", (integer)val, 0, 100);
        else llWhisper(0, "Unknown parameter in notecard line " + (string)(line + 1) + ": " + par);
    }

    line++;
    llGetNotecardLine(notecard, line);
}

menuDialog (key id)
{
    menuOpen = TRUE;
    string strSmoke = "OFF"; if (smokeOn) strSmoke = "ON";
    string strSound = "NONE"; if (sound) if (soundOn) strSound = "ON"; else strSound = "OFF";
    menuChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    llListenRemove(menuHandle);
    menuHandle = llListen(menuChannel, "", "", "");
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id, title + " " + version +
        "\n\nSize: " + (string)perSize + "%\t\tVolume: " + (string)perVolume + "%" +
        "\nSmoke: " + strSmoke + "\t\tSound: " + strSound, [
        "Smoke", "Sound", "Close",
        "-Volume", "+Volume", "Reset",
        "-Fire", "+Fire", "Color",
        "Small", "Medium", "Large" ],
        menuChannel);
}

startColorDialog (key id)
{
    menuOpen = TRUE;
    startColorChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    llListenRemove(startColorHandle);
    startColorHandle = llListen(startColorChannel, "", "", "");
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id, "Bottom color" +
        "\n\nRed: " + (string)perRedStart + "%" +
        "\nGreen: " + (string)perGreenStart + "%" +
        "\nBlue: " + (string)perBlueStart + "%", [
        "Top color", "One color", "Main menu",
        "-Blue",  "+Blue",  "B min/max",
        "-Green", "+Green", "G min/max",
        "-Red",   "+Red",   "R min/max" ],
        startColorChannel);
}

endColorDialog (key id)
{
    menuOpen = TRUE;
    endColorChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    llListenRemove(endColorHandle);
    endColorHandle = llListen(endColorChannel, "", "", "");
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id, "Top color" +
        "\n\nRed: " + (string)perRedEnd + "%" +
        "\nGreen: " + (string)perGreenEnd + "%" +
        "\nBlue: " + (string)perBlueEnd + "%", [
        "Bottom color", "One color", "Main menu",
        "-Blue",  "+Blue",  "B min/max",
        "-Green", "+Green", "G min/max",
        "-Red",   "+Red",   "R min/max" ],
        endColorChannel);
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
    smokeOn = defSmoke;
    soundOn = defSound;
    perSize = defSize;
    perVolume = defVolume;
    perRedStart = (integer)defStartColor.x;
    perGreenStart = (integer)defStartColor.y;
    perBlueStart = (integer)defStartColor.z;
    perRedEnd = (integer)defEndColor.x;
    perGreenEnd = (integer)defEndColor.y;
    perBlueEnd = (integer)defEndColor.z;
}

startSystem()
{
    on = TRUE;
    burning = TRUE;
    percent = 100.0;
    percentSmoke = 100.0;
    smokeOn = !smokeOn;
    toggleSmoke();
    startVolume = percentage(perVolume, maxVolume);
    lightIntensity = startIntensity;
    lightRadius = startRadius;
    soundVolume = startVolume;
    updateSize((float)perSize);
    llStopSound();
    if (sound) if (soundOn) llLoopSound(sound, soundVolume);
    llSetTimerEvent(0);
    llSetTimerEvent(burnTime);
    if (menuOpen) {
        llListenRemove(menuHandle);
        llListenRemove(startColorHandle);
        llListenRemove(endColorHandle);
        menuOpen = FALSE;
    }
}

stopSystem()
{
    on = FALSE;
    burning = FALSE;
    percent = 0.0;
    percentSmoke = 0.0;
    llSetTimerEvent(0);
    llParticleSystem([]);
    llSetPrimitiveParams([PRIM_POINT_LIGHT, FALSE, ZERO_VECTOR, 0, 0, 0]);
    llStopSound();
    sendMessage(0);
    if (menuOpen) {
        llListenRemove(menuHandle);
        llListenRemove(startColorHandle);
        llListenRemove(endColorHandle);
        menuOpen = FALSE;
    }
}

updateParticles(vector start, vector end, float min, float max, float radius, vector push)
{
    llParticleSystem ([
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
        PSYS_PART_START_COLOR, startColor,
        PSYS_PART_END_COLOR, endColor,
        PSYS_PART_START_ALPHA, 1.0,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, start,
        PSYS_PART_END_SCALE, end,
        PSYS_PART_MAX_AGE, age,
        PSYS_SRC_BURST_RATE, rate,
        PSYS_SRC_BURST_PART_COUNT, count,
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

sendMessage(integer alpha)
{
    llMessageLinked(LINK_ALL_OTHERS, smokeChannel, (string)alpha, getGroup());
}

default
{
    state_entry()
    {
        owner = llGetOwner();
        sound = llGetInventoryName(INVENTORY_SOUND, 0); // get first sound from inventory
        if (sound) llPreloadSound(sound);
        stopSystem();
        if (debug) {
            llOwnerSay("Particle count: " + (string)llRound((float)count * age / rate));
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

    touch_start(integer total_number)
    {
        llResetTime();
    }

    touch_end(integer total_number)
    {
        user = llDetectedKey(0);

        if (llGetTime() > 1.0) {
            if (accessGranted(user, menuAccess)) {
                startSystem();
                menuDialog(user);
            }
            else llInstantMessage(user, "[Menu] Access denied");
        }
        else {
            if (accessGranted(user, switchAccess)) toggleFire();
            else llInstantMessage(user, "[Switch] Access denied");
        }
    }

    listen(integer channel, string name, key id, string msg)
    {
        if (debug) llOwnerSay("[Fire] LISTEN event: " + (string)channel + "; " + msg);

        if (channel == menuChannel) {
            llListenRemove(menuHandle);
            if (msg == "Small") perSize = 25;
            else if (msg == "Medium") perSize = 50;
            else if (msg == "Large") perSize = 75;
            else if (msg == "-Fire") perSize = max(perSize - 5, 5);
            else if (msg == "+Fire") perSize = min(perSize + 5, 100);
            else if (msg == "-Volume") {
                perVolume = max(perVolume - 5, 5);
                startVolume = percentage(perVolume, maxVolume);
            }
            else if (msg == "+Volume") {
                perVolume = min(perVolume + 5, 100);
                startVolume = percentage(perVolume, maxVolume);
            }
            else if (msg == "Smoke") toggleSmoke();
            else if (msg == "Sound") toggleSound();
            else if (msg == "Color") endColorDialog(user);
            else if (msg == "Reset") { reset(); startSystem(); }
            else if (msg == "Close") {
                llSetTimerEvent(0); // stop dialog timer
                llSetTimerEvent(burnTime); // restart burn timer
                menuOpen = FALSE;
            }
            if (msg != "Color" && msg != "Close") {
                if (msg != "Smoke" && msg != "Sound" && msg != "Reset") updateSize((float)perSize);
                menuDialog(user);
            }
        }
        else if (channel == startColorChannel) {
            llListenRemove(startColorHandle);
            if (msg == "-Red") perRedStart = max(perRedStart - 10, 0);
            else if (msg == "-Green") perGreenStart = max(perGreenStart - 10, 0);
            else if (msg == "-Blue") perBlueStart = max(perBlueStart - 10, 0);
            else if (msg == "+Red") perRedStart = min(perRedStart + 10, 100);
            else if (msg == "+Green") perGreenStart = min(perGreenStart + 10, 100);
            else if (msg == "+Blue") perBlueStart = min(perBlueStart + 10, 100);
            else if (msg == "R min/max") { if (perRedStart) perRedStart = 0; else perRedStart = 100; }
            else if (msg == "G min/max") { if (perGreenStart) perGreenStart = 0; else perGreenStart = 100; }
            else if (msg == "B min/max") { if (perBlueStart) perBlueStart = 0; else perBlueStart = 100; }
            else if (msg == "Top color") endColorDialog(user);
            else if (msg == "Main menu") menuDialog(user);
            else if (msg == "One color") {
                perRedEnd = perRedStart;
                perGreenEnd = perGreenStart;
                perBlueEnd = perBlueStart;
            }
            if (msg != "Top color" && msg != "Main menu") {
                updateSize((float)perSize);
                startColorDialog(user);
            }
        }
        else if (channel == endColorChannel) {
            llListenRemove(endColorHandle);
            if (msg == "-Red") perRedEnd = max(perRedEnd - 10, 0);
            else if (msg == "-Green") perGreenEnd = max(perGreenEnd - 10, 0);
            else if (msg == "-Blue") perBlueEnd = max(perBlueEnd - 10, 0);
            else if (msg == "+Red") perRedEnd = min(perRedEnd + 10, 100);
            else if (msg == "+Green") perGreenEnd = min(perGreenEnd + 10, 100);
            else if (msg == "+Blue") perBlueEnd = min(perBlueEnd + 10, 100);
            else if (msg == "R min/max") { if (perRedEnd) perRedEnd = 0; else perRedEnd = 100; }
            else if (msg == "G min/max") { if (perGreenEnd) perGreenEnd = 0; else perGreenEnd = 100; }
            else if (msg == "B min/max") { if (perBlueEnd) perBlueEnd = 0; else perBlueEnd = 100; }
            else if (msg == "Bottom color") startColorDialog(user);
            else if (msg == "Main menu") menuDialog(user);
            else if (msg == "One color") {
                perRedStart = perRedEnd;
                perGreenStart = perGreenEnd;
                perBlueStart = perBlueEnd;
            }
            if (msg != "Bottom color" && msg != "Main menu") {
                updateSize((float)perSize);
                endColorDialog(user);
            }
        }
    }

    link_message(integer sender_number, integer number, string msg, key id)
    {
        if (debug) llOwnerSay("[Fire] LINK_MESSAGE event: " + (string)number + "; " + msg + "; " + (string)id);
        if (number != msgNumber) return;

        if (id) user = id;
        else {
            llWhisper(0, "A valid avatar key must be provided in the link message.");
            return;
        }

        if (msg == msgSwitch) {
            if (accessGranted(user, switchAccess)) toggleFire();
            else llInstantMessage(user, "[Switch] Access denied");
        }
        else if (msg == msgOn) {
            if (accessGranted(user, switchAccess)) startSystem();
            else llInstantMessage(user, "[Switch] Access denied");
        }
        else if (msg == msgOff) {
            if (accessGranted(user, switchAccess)) stopSystem();
            else llInstantMessage(user, "[Switch] Access denied");
        }
        else if (msg == msgMenu) {
            if (accessGranted(user, menuAccess)) {
                startSystem();
                menuDialog(user);
            }
            else llInstantMessage(user, "[Menu] Access denied");
        }
    }

    dataserver(key req, string data)
    {
        if (data == EOF) {
            if (!burnDown) burnTime = 315360000;   // 10 years
            time = dieTime / 100.0;                // try to get a one percent timer interval
            if (time < 1.0) time = 1.0;            // but never smaller than one second
            decPercent = 100.0 / (dieTime / time); // and burn down decPercent% every time

            defStartColor.x = checkInt("ColorOn (RED)", (integer)defStartColor.x, 0, 100);
            defStartColor.y = checkInt("ColorOn (GREEN)", (integer)defStartColor.y, 0, 100);
            defStartColor.z = checkInt("ColorOn (BLUE)", (integer)defStartColor.z, 0, 100);
            defEndColor.x = checkInt("ColorOff (RED)", (integer)defEndColor.x, 0, 100);
            defEndColor.y = checkInt("ColorOff (GREEN)", (integer)defEndColor.y, 0, 100);
            defEndColor.z = checkInt("ColorOff (BLUE)", (integer)defEndColor.z, 0, 100);

            startIntensity = percentage(defIntensity, maxIntensity);
            startRadius = percentage(defRadius, maxRadius);
            lightFalloff = percentage(defFalloff, maxFalloff);
            startVolume = percentage(defVolume, maxVolume);

            reset(); // initial values for menu
            if (on) startSystem();

            if (verbose) {
                llWhisper(0, "Touch to start/stop fire");
                llWhisper(0, "Long touch to show menu");
                llWhisper(0, "Switch access:" + showAccess(switchAccess));
                llWhisper(0, "Menu access:" + showAccess(menuAccess));
                if (sound) llWhisper(0, "Sound in object inventory: Yes");
                else llWhisper(0, "Sound in object inventory: No");
            }
            llWhisper(0, title + " " + version + " ready");

            if (debug) {
                llOwnerSay((string)line + " lines in notecard");
                llOwnerSay("verbose = " + (string)verbose);
                llOwnerSay("switchAccess = " + (string)switchAccess);
                llOwnerSay("menuAccess = " + (string)menuAccess);
                llOwnerSay("msgNumber = " + (string)msgNumber);
                llOwnerSay("msgSwitch = " + msgSwitch);
                llOwnerSay("msgOn = " + msgOn);
                llOwnerSay("msgOff = " + msgOff);
                llOwnerSay("msgMenu = " + msgMenu);
                llOwnerSay("burnDown = " + (string)burnDown);
                llOwnerSay("burnTime = " + (string)burnTime);
                llOwnerSay("dieTime = " + (string)dieTime);
                llOwnerSay("loop = " + (string)loop);
                llOwnerSay("changeLight = " + (string)changeLight);
                llOwnerSay("changeSmoke = " + (string)changeSmoke);
                llOwnerSay("changeVolume = " + (string)changeVolume);
                llOwnerSay("defSize = " + (string)defSize);
                llOwnerSay("defStartColor = " + (string)defStartColor);
                llOwnerSay("defEndColor = " + (string)defEndColor);
                llOwnerSay("defVolume = " + (string)defVolume);
                llOwnerSay("defSmoke = " + (string)defSmoke);
                llOwnerSay("defSound = " + (string)defSound);
                llOwnerSay("defIntensity = " + (string)defIntensity);
                llOwnerSay("defRadius = " + (string)defRadius);
                llOwnerSay("defFalloff = " + (string)defFalloff);
                llOwnerSay("time = " + (string)time);
                llOwnerSay("decPercent = " + (string)decPercent);
            }
        }
        else {
            readNotecard(data);
        }
    }

    changed(integer change)
    {
        if (change & CHANGED_INVENTORY) {
            llWhisper(0, "Inventory changed, reloading notecard...");
            sound = llGetInventoryName(INVENTORY_SOUND, 0); // get first sound from inventory
            if (sound) llPreloadSound(sound);
            loadNotecard();
        }
    }

    timer()
    {
        if (menuOpen) {
            if (debug) llOwnerSay("MENU TIMEOUT");
            llListenRemove(menuHandle);
            llListenRemove(startColorHandle);
            llListenRemove(endColorHandle);
            llSetTimerEvent(0); // stop dialog timer
            llSetTimerEvent(burnTime); // restart burn timer
            menuOpen = FALSE;
            return;
        }

        if (burning) {
            llSetTimerEvent(0);
            llSetTimerEvent(time);
            burning = FALSE;
        }

        if (percent >= decPercent) {
            percent -= decPercent;
            updateSize(percent / (100.0 / (float)perSize));
        }
        else {
            if (loop) startSystem();
            else stopSystem();
        }
    }
}
