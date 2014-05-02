// EasyLight
//
// Author: Rene10957 Resident
// Date: 12-04-2014
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.

string title = "EasyLight";       // title
string version = "1.0";           // version

// Constants //////////////////////////////////////////////////////////////////////////////////////

integer defIntensity = 100;       // default intensity (%)
vector RGBcolor = <255,255,255>;  // light color in RGB format (white)
float alpha = 1.0;                // alpha (0-1) where 0 = fully transparent
float maxIntensity = 1.0;         // max. light intensity (0-1)
float maxRadius = 10.0;           // max. light radius (0-20)
float falloff = 0.75;             // light falloff (0-2)
float glow = 0.0;                 // glowing when lit (0-1) where 1 = fully glowing
integer fullBright = TRUE;        // fullbright when lit (TRUE or FALSE)
integer changePrimColor = TRUE;   // change prim color with light color (TRUE or FALSE)
integer msgNumber = 180512;       // number part of incoming link message
string lightName = "EasyLight";   // all prims with this name will be lit

///////////////////////////////////////////////////////////////////////////////////////////////////

// Variables

integer on = FALSE;               // on-off switch
vector color;                     // light color in LSL format
integer perIntensity;             // percent light intensity
integer perRadius;                // percent light radius
integer menuChannel;              // main menu channel
integer menuHandle;               // handle for main menu listener

// Functions

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

setLight()
{
    float intensity;
    float radius;
    integer fullbr = FALSE;
    vector primColor;
    integer i;
    integer number = llGetNumberOfPrims();
    integer light = FALSE;

    if (on) {
        perRadius = perIntensity + 50 - perIntensity / 2;       // light radius ranges from 50 to 100%
        intensity = maxIntensity / 100.0 * (float)perIntensity;
        radius = maxRadius / 100.0 * (float)perRadius;
        fullbr = fullBright;
        if (changePrimColor) primColor = color;
        else primColor = <1,1,1>;
    }
    else {
        fullbr = FALSE;
        primColor = <1,1,1>;
    }

    for (i = number; i >= 0; --i) {
        if (number == 1 || lower(llGetLinkName(i)) == lower(lightName)) {
            light = TRUE;
            llSetLinkPrimitiveParamsFast(i, [
                PRIM_POINT_LIGHT, on, color, intensity, radius, falloff,
                PRIM_COLOR, ALL_SIDES, primColor, alpha,
                PRIM_GLOW, ALL_SIDES, glow,
                PRIM_FULLBRIGHT, ALL_SIDES, fullbr]);
        }
    }

    if (!light) llWhisper(0, "WARNING. No prims named \"" + lightName + "\"!");
}

menuDialog (key id)
{
    string strOn = "OFF"; if (on) strOn = "ON";
    menuChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    llListenRemove(menuHandle);
    menuHandle = llListen(menuChannel, "", "", "");
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id, title + " " + version + "\n\n" + strOn + "\t\t" + (string)perIntensity + "%",
        [ "Off", "-Light", "Close", "On", "+Light", "Reset" ], menuChannel);
}

default
{
    state_entry()
    {
        color = RGBcolor / 255.0;
        perIntensity = defIntensity;
        setLight();
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

        if (msg == "On") on = TRUE;
        else if (msg == "Off") on = FALSE;
        else if (msg == "Reset") perIntensity = defIntensity;
        else if (msg == "+Light") perIntensity = min(perIntensity + 10, 100);   // raise by 10%, stop at 100%
        else if (msg == "-Light") perIntensity = max(perIntensity - 10, 10);    // lower by 10%, stop at 10%

        if (msg != "Close") {
            setLight();
            menuDialog(id);
        }
    }

    link_message(integer sender_number, integer number, string msg, key id)
    {
        if (number != msgNumber) return;

        if (msg == "switch") {
            on = !on;
            setLight();
        }
        else if (msg == "on") {
            on = TRUE;
            setLight();
        }
        else if (msg == "off") {
            on = FALSE;
            setLight();
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
