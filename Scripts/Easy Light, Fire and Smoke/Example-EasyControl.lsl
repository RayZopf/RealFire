// EasyControl
//
// Author: Rene10957 Resident
// Date: 12-04-2014
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.

string title = "EasyControl";      // title
string version = "1.0";            // version

// Constants //////////////////////////////////////////////////////////////////////////////////////

string lightSwitch = "Light";      // text for light switch button (empty string if unused)
string fireSwitch = "Fire";        // text for fire switch button (empty string if unused)
string smokeSwitch = "Smoke";      // text for smoke switch button (empty string if unused)

string lightOn = "Light ON";       // text for light on button (empty string if unused)
string fireOn = "Fire ON";         // text for fire on button (empty string if unused)
string smokeOn = "Smoke ON";       // text for smoke on button (empty string if unused)

string lightOff = "Light OFF";     // text for light off button (empty string if unused)
string fireOff = "Fire OFF";       // text for fire off button (empty string if unused)
string smokeOff = "Smoke OFF";     // text for smoke off button (empty string if unused)

string lightMenu = "Light menu";   // text for light menu button (empty string if unused)
string fireMenu = "Fire menu";     // text for fire menu button (empty string if unused)
string smokeMenu = "Smoke menu";   // text for smoke menu button (empty string if unused)

integer lightNumber = 180512;      // number part of outgoing light message
integer fireNumber = 180506;       // number part of outgoing fire message
integer smokeNumber = 180519;      // number part of outgoing smoke message

///////////////////////////////////////////////////////////////////////////////////////////////////

// Variables

integer menuChannel;               // main menu channel
integer menuHandle;                // handle for main menu listener

// Functions

menuDialog (key id)
{
    list buttonList;
    if (lightMenu) buttonList += [lightMenu];
    if (fireMenu) buttonList += [fireMenu];
    if (smokeMenu) buttonList += [smokeMenu];
    if (lightOff) buttonList += [lightOff];
    if (fireOff) buttonList += [fireOff];
    if (smokeOff) buttonList += [smokeOff];
    if (lightOn) buttonList += [lightOn];
    if (fireOn) buttonList += [fireOn];
    if (smokeOn) buttonList += [smokeOn];
    if (lightSwitch) buttonList += [lightSwitch];
    if (fireSwitch) buttonList += [fireSwitch];
    if (smokeSwitch) buttonList += [smokeSwitch];
    menuChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    llListenRemove(menuHandle);
    menuHandle = llListen(menuChannel, "", "", "");
    llSetTimerEvent(0);
    llSetTimerEvent(120);
    llDialog(id, title + " " + version + "\n\n", buttonList, menuChannel);
}

default
{
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

        if (msg == lightSwitch) llMessageLinked(LINK_SET, lightNumber, "switch", "");
        else if (msg == fireSwitch) llMessageLinked(LINK_SET, fireNumber, "switch", "");
        else if (msg == smokeSwitch) llMessageLinked(LINK_SET, smokeNumber, "switch", "");
        else if (msg == lightOn) llMessageLinked(LINK_SET, lightNumber, "on", id);
        else if (msg == fireOn) llMessageLinked(LINK_SET, fireNumber, "on", id);
        else if (msg == smokeOn) llMessageLinked(LINK_SET, smokeNumber, "on", id);
        else if (msg == lightOff) llMessageLinked(LINK_SET, lightNumber, "off", id);
        else if (msg == fireOff) llMessageLinked(LINK_SET, fireNumber, "off", id);
        else if (msg == smokeOff) llMessageLinked(LINK_SET, smokeNumber, "off", id);
        else if (msg == lightMenu) llMessageLinked(LINK_SET, lightNumber, "menu", id);
        else if (msg == fireMenu) llMessageLinked(LINK_SET, fireNumber, "menu", id);
        else if (msg == smokeMenu) llMessageLinked(LINK_SET, smokeNumber, "menu", id);

        if (msg != lightMenu && msg != fireMenu && msg != smokeMenu) menuDialog(id);
    }

    timer()
    {
        llSetTimerEvent(0);
        llListenRemove(menuHandle);
    }
}
