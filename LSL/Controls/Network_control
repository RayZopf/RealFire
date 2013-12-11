// Network control for RealFire
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
// Drop this in any external object you want to use as a control panel

string title = "Network Control";   // title
string version = "1.0";             // version
integer debug = FALSE;              // show debug messages

// Constants

float cDialogTime = 120.0;          // dialog timeout = 2 minutes
float cRemoteTime = 1.0;            // remote timeout = 1 second
integer remoteChannel = -975101;    // remote channel (two-way)
string separator = ";;";            // separator for region messages

// Variables

float time;                         // timer interval for multiple timers
float vRemoteTime;                  // variable timeout for node discovery, ranging from 1 to 2 sec.
integer dialogChannel;              // dialog channel
integer dialogHandle;               // handle for dialog listener
integer remoteHandle;               // handle for remote listener
key owner;                          // object owner
key user;                           // key of last avatar to touch object
list networkNodes;                  // strided list of network nodes (object key, object name)
list menuButtons;                   // menu buttons (object names)

// Functions

float setTimer(float sec)
{
    llSetTimerEvent(0.0);
    llSetTimerEvent(sec);
    return sec;
}

discoverNodes()
{
    llWhisper(0, "Discovering network nodes...");
    networkNodes = [];
    llListenRemove(remoteHandle);
    remoteHandle = llListen(remoteChannel, "", "", "");
    float pctlag = 100.0 * (1.0 - llGetRegionTimeDilation());  // try to work around time dilation
    vRemoteTime = cRemoteTime + cRemoteTime / 100.0 * pctlag;  // (more lag = longer timeout)
    time = setTimer(vRemoteTime);
    llRegionSay(remoteChannel, "HELO" + separator + NULL_KEY);
}

menuDialog (key id)
{
    dialogChannel = (integer)(llFrand(-1000000000.0) - 1000000000.0);
    llListenRemove(dialogHandle);
    dialogHandle = llListen(dialogChannel, "", "", "");
    time = setTimer(cDialogTime);
    llDialog(id, title + " " + version, menuButtons, dialogChannel);
}

default
{
    state_entry()
    {
        owner = llGetOwner();
        discoverNodes();
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    touch_start(integer total_number)
    {
        user = llDetectedKey(0);
        if (user == owner || llSameGroup(user)) menuDialog(user);
        else llInstantMessage(user, "Access denied");
    }

    listen(integer channel, string name, key id, string msg)
    {
        integer number = llGetListLength(networkNodes) / 2;

        if (channel == remoteChannel) {
            if (llGetOwnerKey(id) != owner) return;
            if (msg != "DATA") return;
            if (number > 8) return;
            string shortName = llGetSubString(name, 0, 22) + (string)number;
            networkNodes += [id] + [shortName];
        }
        else if (channel == dialogChannel) {
            llSetTimerEvent(0);
            llListenRemove(dialogHandle);
            integer i;
            key target;
            if (msg == "On") {
                for (i = 0; i < number; ++i) {
                    target = llList2Key(networkNodes, i * 2);
                    llRegionSayTo(target, remoteChannel, "on" + separator + (string)user);
                }
                menuDialog(user);
            }
            else if (msg == "Off") {
                for (i = 0; i < number; ++i) {
                    target = llList2Key(networkNodes, i * 2);
                    llRegionSayTo(target, remoteChannel, "off" + separator + (string)user);
                }
                menuDialog(user);
            }
            else if (msg == "Discover") {
                discoverNodes();
            }
            else {
                integer index = llListFindList(networkNodes, [msg]);
                if (index > -1) {
                    key object = llList2Key(networkNodes, index - 1);
                    string msgData = "menu" + separator + (string)user;
                    llRegionSayTo(object, remoteChannel, msgData);
                }
                else {
                    llInstantMessage(user, "Unexpected error during object key lookup");
                    menuDialog(user);
                }
            }
        }
    }

    timer()
    {
        llSetTimerEvent(0);
        if (time == cDialogTime) {  // dialog timeout
            if (debug) llOwnerSay("Dialog timeout");
            llListenRemove(dialogHandle);
        }
        else if (time == vRemoteTime) {  // remote timeout (variable!)
            integer number = llGetListLength(networkNodes) / 2;
            if (number == 1) llWhisper(0, "Node discovery completed (" + (string)number + " node)");
            else llWhisper(0, "Node discovery completed (" + (string)number + " nodes)");
            llListenRemove(remoteHandle);
            llListSort(networkNodes, 2, TRUE);
            menuButtons = llList2ListStrided(llDeleteSubList(networkNodes, 0, 0), 0, -1, 2);
            menuButtons = ["On", "Off", "Discover"] + menuButtons;
            if (user) menuDialog(user);
        }
        else {
            if (debug) llOwnerSay("Timer out of range: " + (string)time);
        }
    }
}
