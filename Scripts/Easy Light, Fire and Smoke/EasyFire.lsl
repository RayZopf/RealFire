// EasyFire
//
// Author: Rene10957 Resident
// Date: 12-04-2014
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.

string title = "EasyFire";             // title
string version = "1.0";                // version

// Constants //////////////////////////////////////////////////////////////////////////////////////

key sound = "2d18c0b7-d9ba-1912-dfda-abc317fcc6b9";          // fire crackling (dobroide@freesound.org)
key fireTexture = "";                                        // default particle texture
key smokeTexture = "5de058da-95f0-2736-b0e0-e218184ddece";   // whispy smoke

integer defSize = 100;                 // default size (%)
integer defSmoke = TRUE;               // default smoke (TRUE or FALSE)
integer defSound = TRUE;               // default sound (TRUE or FALSE)
vector RGBcolor = <255,255,0>;         // lower flame color in RGB format (yellow)
vector RGBtopColor = <255,0,0>;        // upper flame color in RGB format (red)
vector RGBsmokeColor = <128,128,128>;  // smoke color in RGB format (grey)
float smokeAlpha = 1.0;                // smoke alpha (0-1) where 0 = fully transparent
float maxIntensity = 1.0;              // max. light intensity (0-1)
float maxRadius = 10.0;                // max. light radius (0-20)
float falloff = 0.75;                  // light falloff (0-2)
integer msgNumber = 180506;            // number part of incoming link message
string fireName = "EasyFire";          // all prims with this name will burn
string smokeName = "EFsmoke";          // all prims with this name will smoke

///////////////////////////////////////////////////////////////////////////////////////////////////

// Particle resizing parameters: fire (size = 100%)

vector startScale = <0.2, 1.0, 0.0>;   // particle start size
vector endScale = <0.2, 1.0, 0.0>;     // particle end size
float minSpeed = 0.0;                  // particle min. burst speed
float maxSpeed = 0.02;                 // particle max. burst speed
float burstRadius = 0.2;               // particle burst radius
vector partAccel = <0.0, 0.0, 5.0>;    // particle accelleration

// Particle resizing parameters: smoke (size = 100%)

vector startScaleS = <0.1, 0.1, 0.0>;  // particle start size
vector endScaleS = <3.0, 3.0, 0.0>;    // particle end size
float minSpeedS = 0.0;                 // particle min. burst speed
float maxSpeedS = 0.06;                // particle max. burst speed
float burstRadiusS = 0.06;             // particle burst radius
vector partAccelS = <0.0, 0.0, 0.12>;  // particle accelleration

// Variables

vector color;                          // lower flame color in LSL format
vector topColor;                       // upper flame color in LSL format
vector smokeColor;                     // smoke color in LSL format
vector lightColor;                     // light color
integer on = FALSE;                    // on/off switch
integer smokeOn = FALSE;               // smoke on/off
integer soundOn = FALSE;               // sound on/off
integer soundPlaying = FALSE;          // sound is playing
float volume;                          // sound volume
integer perSize;                       // percent particle size, light intentisy and sound volume
integer perRadius;                     // percent light radius
integer menuChannel;                   // main menu channel
integer menuHandle;                    // handle for main menu listener

// Functions

reset()
{
    perSize = defSize;
    smokeOn = defSmoke;
    soundOn = defSound;
}

integer min (integer x, integer y)
{
    if (x < y) return x; else return y;
}

integer max (integer x, integer y)
{
    if (x > y) return x; else return y;
}

string lower(string str)
{
    return llStringTrim(llToLower(str), STRING_TRIM);
}

startFire(integer link, vector start, vector end, float min, float max, float radius, vector push)
{
    llLinkParticleSystem(link, [
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
        PSYS_SRC_TEXTURE, fireTexture,
        PSYS_PART_START_COLOR, color,
        PSYS_PART_END_COLOR, topColor,
        PSYS_PART_START_ALPHA, 1.0,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, start,
        PSYS_PART_END_SCALE, end,
        PSYS_PART_MAX_AGE, 1.0,
        PSYS_SRC_BURST_RATE, 0.1,
        PSYS_SRC_BURST_PART_COUNT, 10,
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

startSmoke(integer link, vector start, vector end, float min, float max, float radius, vector push)
{
    llLinkParticleSystem(link, [
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
        PSYS_SRC_TEXTURE, smokeTexture,
        PSYS_PART_START_COLOR, smokeColor,
        PSYS_PART_END_COLOR, smokeColor,
        PSYS_PART_START_ALPHA, smokeAlpha,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, start,
        PSYS_PART_END_SCALE, end,
        PSYS_PART_MAX_AGE, 16.0,
        PSYS_SRC_BURST_RATE, 0.5,
        PSYS_SRC_BURST_PART_COUNT, 3,
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

setFire()
{
    // Fire
    vector start = startScale / 100.0 * (float)perSize;      // start scale
    vector end = endScale / 100.0 * (float)perSize;          // end scale
    float min = minSpeed / 100.0 * (float)perSize;           // min. burst speed
    float max = maxSpeed / 100.0 * (float)perSize;           // max. burst speed
    float radius = burstRadius / 100.0 * (float)perSize;     // resize burst radius
    vector push = partAccel / 100.0 * (float)perSize;        // accelleration
    // Smoke
    vector startS = startScaleS / 100.0 * (float)perSize;    // start scale
    vector endS = endScaleS / 100.0 * (float)perSize;        // end scale
    float minS = minSpeedS / 100.0 * (float)perSize;         // min. burst speed
    float maxS = maxSpeedS / 100.0 * (float)perSize;         // max. burst speed
    float radiusS = burstRadiusS / 100.0 * (float)perSize;   // resize burst radius
    vector pushS = partAccelS / 100.0 * (float)perSize;      // accelleration
    // Sound
    volume = (float)perSize / 100.0;
    // Light
    perRadius = perSize + 50 - perSize / 2;                  // light radius ranges from 50 to 100%
    float intensity = maxIntensity / 100.0 * (float)perSize;
    float lightRadius = maxRadius / 100.0 * (float)perRadius;

    integer fire = FALSE;
    integer smoke = FALSE;
    integer i;
    integer number = llGetNumberOfPrims();

    for (i = number; i >= 0; --i) {
        if (lower(llGetLinkName(i)) == lower(fireName)) {
            fire = TRUE;
            if (on) {
                if ((key)sound) {
                    if (soundPlaying) llAdjustSoundVolume(volume);
                    else if (soundOn) {
                        soundPlaying = TRUE;
                        llLoopSound(sound, volume);
                    }
                }
                startFire(i, start, end, min, max, radius, push);
                llSetLinkPrimitiveParamsFast(i, [PRIM_POINT_LIGHT, on, lightColor, intensity, lightRadius, falloff]);
            }
            else {
                soundPlaying = FALSE;
                llStopSound();
                llLinkParticleSystem(i, []);
                llSetLinkPrimitiveParamsFast(i, [PRIM_POINT_LIGHT, FALSE, ZERO_VECTOR, 0, 0, 0 ]);
            }
        }
        else if (lower(llGetLinkName(i)) == lower(smokeName)) {
            smoke = TRUE;
            if (on && smokeOn) startSmoke(i, startS, endS, minS, maxS, radiusS, pushS);
            else llLinkParticleSystem(i, []);
        }
    }

    if (!fire) {
        llLinkParticleSystem(LINK_SET, []);
        llWhisper(0, "WARNING. No prims named \"" + fireName + "\"!");
    }
    if (!smoke) llWhisper(0, "WARNING. No prims named \"" + smokeName + "\"!");
}

menuDialog (key id)
{
    string strOn = "OFF"; if (on) strOn = "ON";
    string strSmoke = "OFF"; if (smokeOn) strSmoke = "ON";
    string strSound = "OFF"; if (soundOn) strSound = "ON";
    menuChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    llListenRemove(menuHandle);
    menuHandle = llListen(menuChannel, "", "", "");
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id, title + " " + version + "\n\n" +
        strOn + "\t\t" + (string)perSize + "%\t\t" + "Smoke " + strSmoke + "\t\t" + "Sound " + strSound,
        [ "Reset", "-Fire", "Sound", "On/Off", "+Fire", "Smoke" ], menuChannel);
}

default
{
    state_entry()
    {
        color = RGBcolor / 255.0;
        topColor = RGBtopColor / 255.0;
        smokeColor = RGBsmokeColor / 255.0;
        lightColor = (color + topColor) / 2.0;
        if ((key)sound) llPreloadSound(sound);
        reset();
        setFire();
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    touch_start(integer total_number)
    {
        menuDialog(llDetectedKey(0));
    }

    listen(integer channel, string name, key id, string msg)
    {
        if (channel != menuChannel) return;

        llSetTimerEvent(0);
        llListenRemove(menuHandle);

        if (msg == "Sound") {
            if (soundOn) {
                llStopSound();
                soundOn = FALSE;
                soundPlaying = FALSE;
            }
            else if ((key)sound) {
                llLoopSound(sound, volume);
                soundOn = TRUE;
                soundPlaying = TRUE;
            }
        }
        else if (msg == "Smoke") smokeOn = !smokeOn;
        else if (msg == "On/Off") on = !on;
        else if (msg == "Reset") reset();
        else if (msg == "+Fire") perSize = min(perSize + 10, 100);   // raise by 10%, stop at 100%
        else if (msg == "-Fire") perSize = max(perSize - 10, 20);    // lower by 10%, stop at 20%

        setFire();
        menuDialog(id);
    }

    link_message(integer sender_number, integer number, string msg, key id)
    {
        if (number != msgNumber) return;

        if (msg == "switch") {
            on = !on;
            setFire();
        }
        else if (msg == "on") {
            on = TRUE;
            setFire();
        }
        else if (msg == "off") {
            on = FALSE;
            setFire();
        }
        else if (msg == "menu") {
            if (id) menuDialog(id);
            else llWhisper(0, "A valid avatar key must be provided in the link message");
        }
    }

    timer()
    {
        llSetTimerEvent(0);
        llListenRemove(menuHandle);
    }
}
