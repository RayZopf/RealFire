// EasySmoke
//
// Author: Rene10957 Resident
// Date: 12-04-2014
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.

string title = "EasySmoke";            // title
string version = "1.0";                // version

// Constants //////////////////////////////////////////////////////////////////////////////////////

key texture = "5de058da-95f0-2736-b0e0-e218184ddece";   // whispy smoke

integer defSize = 100;                 // default size (%)
integer defAlpha = 100;                // default alpha (%)
vector RGBcolor = <128,128,128>;       // smoke color in RGB format (grey)
float maxAlpha = 1.0;                  // max. alpha (0-1) where 0 = fully transparent
integer msgNumber = 180519;            // number part of incoming link message
string smokeName = "EasySmoke";        // all prims with this name will smoke

///////////////////////////////////////////////////////////////////////////////////////////////////

// Particle resizing parameters (size = 100%)

vector startScale = <0.1, 0.1, 0.0>;   // particle start size
vector endScale = <4.0, 4.0, 0.0>;     // particle end size
float minSpeed = 0.0;                  // particle min. burst speed
float maxSpeed = 0.1;                  // particle max. burst speed
float burstRadius = 0.1;               // particle burst radius
vector partAccel = <0.0, 0.0, 0.2>;    // particle accelleration

// Variables

integer on = FALSE;                    // on/off switch
vector color;                          // smoke color in LSL format
integer perSize;                       // percent particle size
integer perAlpha;                      // percent particle alpha
integer menuChannel;                   // main menu channel
integer menuHandle;                    // handle for main menu listener

// Functions

reset()
{
    perSize = defSize;
    perAlpha = defAlpha;
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

startSmoke(integer link, float alpha, vector start, vector end, float min, float max, float radius, vector push)
{
    llLinkParticleSystem(link, [
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
        PSYS_SRC_TEXTURE, texture,
        PSYS_PART_START_COLOR, color,
        PSYS_PART_END_COLOR, color,
        PSYS_PART_START_ALPHA, alpha,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, start,
        PSYS_PART_END_SCALE, end,
        PSYS_PART_MAX_AGE, 10.0,
        PSYS_SRC_BURST_RATE, 0.5,
        PSYS_SRC_BURST_PART_COUNT, 5,
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

setSmoke()
{
    vector start = startScale / 100.0 * (float)perSize;      // start scale
    vector end = endScale / 100.0 * (float)perSize;          // end scale
    float min = minSpeed / 100.0 * (float)perSize;           // min. burst speed
    float max = maxSpeed / 100.0 * (float)perSize;           // max. burst speed
    float radius = burstRadius / 100.0 * (float)perSize;     // resize burst radius
    vector push = partAccel / 100.0 * (float)perSize;        // accelleration
    float alpha = maxAlpha / 100.0 * (float)perAlpha;        // alpha

    integer smoke = FALSE;
    integer i;
    integer number = llGetNumberOfPrims();

    for (i = number; i >= 0; --i) {
        if (number == 1 || lower(llGetLinkName(i)) == lower(smokeName)) {
            smoke = TRUE;
            if (on) startSmoke(i, alpha, start, end, min, max, radius, push);
            else llLinkParticleSystem(i, []);
        }
    }

    if (!smoke) llWhisper(0, "WARNING. No prims named \"" + smokeName + "\"!");
}

menuDialog (key id)
{
    string strOn = "OFF"; if (on) strOn = "ON";
    menuChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    llListenRemove(menuHandle);
    menuHandle = llListen(menuChannel, "", "", "");
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id, title + " " + version + "\n\n" +
        strOn + "\t\t" + (string)perSize + "%\t\tAlpha " + (string)perAlpha + "%\t\t",
        [ "Reset", "-Smoke", "-Alpha", "On/Off", "+Smoke", "+Alpha" ], menuChannel);
}

default
{
    state_entry()
    {
        color = RGBcolor / 255.0;
        reset();
        setSmoke();
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

        if (msg == "On/Off") on = !on;
        else if (msg == "Reset") reset();
        else if (msg == "+Smoke") perSize = min(perSize + 10, 100);   // raise by 10%, stop at 100%
        else if (msg == "-Smoke") perSize = max(perSize - 10, 10);    // lower by 10%, stop at 10%
        else if (msg == "+Alpha") perAlpha = min(perAlpha + 10, 100);   // raise by 10%, stop at 100%
        else if (msg == "-Alpha") perAlpha = max(perAlpha - 10, 10);    // lower by 10%, stop at 10%

        setSmoke();
        menuDialog(id);
    }

    link_message(integer sender_number, integer number, string msg, key id)
    {
        if (number != msgNumber) return;

        if (msg == "switch") {
            on = !on;
            setSmoke();
        }
        else if (msg == "on") {
            on = TRUE;
            setSmoke();
        }
        else if (msg == "off") {
            on = FALSE;
            setSmoke();
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
