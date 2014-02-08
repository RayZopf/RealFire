// Network control for RealFire
//
// Author: Rene10957 Resident
// Date: 02-02-2014
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.
// Content creator? Please read the license notecard!
//
// Drop this in any prim you want to use as a control panel

string title = "Network Control";   // title
string version = "2.1";             // version
integer linkSet = FALSE;            // REGION mode
integer debug = FALSE;              // show/hide debug messages
integer silent = FALSE;             // silent startup

// Constants

float cDialogTime = 120.0;          // dialog timeout = 2 minutes
float cReplyTime = 1.0;             // reply timeout = 1 second
integer remoteChannel = -975101;    // remote channel (send)
integer replyChannel = -975106;     // reply channel (receive)
string separator = ";;";            // separator for link or region messages

// Variables

float time;                         // timer interval for multiple timers
float vReplyTime;                   // variable timeout for node discovery, ranging from 1 to 2 sec.
integer dialogChannel;              // dialog channel
integer dialogHandle;               // handle for dialog listener
integer replyHandle;                // handle for reply listener
key owner;                          // object owner
key user;                           // key of last avatar to touch object
list networkNodes;                  // strided list of network nodes (object key, object name)
list menuButtons;                   // menu buttons (object names)

// Functions

list orderButtons(list buttons)
{
    return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) + llList2List(buttons, -9, -7);
}

float setTimer(float sec)
{
    llSetTimerEvent(0.0);
    llSetTimerEvent(sec);
    return sec;
}

discoverNodes(key id)
{
    llWhisper(0, "Discovering network nodes...");
    networkNodes = [];
    llListenRemove(replyHandle);
    replyHandle = llListen(replyChannel, "", "", "");
    float pctlag = 100.0 * (1.0 - llGetRegionTimeDilation());  // try to work around time dilation
    vReplyTime = cReplyTime + cReplyTime / 100.0 * pctlag;  // (more lag = longer timeout)
    time = setTimer(vReplyTime);
    if (linkSet) llMessageLinked(LINK_ALL_OTHERS, remoteChannel, "HELO", llGetKey());
    else llRegionSay(remoteChannel, "HELO");
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
        if (linkSet) version += "-LINKSET";
        else version += "-REGION";
        if (!silent) llWhisper(0, title + " " + version + " ready");
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    touch_start(integer total_number)
    {
        user = llDetectedKey(0);
        if (llGetListLength(networkNodes) == 0) discoverNodes(user);
        else menuDialog(user);
    }

    listen(integer channel, string name, key id, string msg)
    {
        integer length = llGetListLength(networkNodes) / 2;
        if (debug) llOwnerSay("[Network control] LISTEN event: " + (string)channel + "; " + msg);

        if (channel == replyChannel) {
            if (llGetOwnerKey(id) != owner) return;
            if (msg != "DATA") return;
            if (length > 8) return;
            string shortName = llGetSubString(name, 0, 23);
            networkNodes += [id] + [shortName];
        }
        else if (channel == dialogChannel) {
            llSetTimerEvent(0);
            llListenRemove(dialogHandle);
            integer i;
            integer index;
            key target;
            list msgList;
            string msgData;
            if (msg == "On") {
                for (i = 0; i < length; ++i) {
                    target = llList2Key(networkNodes, i * 2);
                    msgList = [target, "on", id];  // id = user who opened the dialog
                    msgData = llDumpList2String(msgList, separator);
                    if (linkSet) llMessageLinked(LINK_ALL_OTHERS, remoteChannel, msgData, "");
                    else llRegionSayTo(target, remoteChannel, msgData);
                }
                menuDialog(id);
            }
            else if (msg == "Off") {
                for (i = 0; i < length; ++i) {
                    target = llList2Key(networkNodes, i * 2);
                    msgList = [target, "off", id];  // id = user who opened the dialog
                    msgData = llDumpList2String(msgList, separator);
                    if (linkSet) llMessageLinked(LINK_ALL_OTHERS, remoteChannel, msgData, "");
                    else llRegionSayTo(target, remoteChannel, msgData);
                }
                menuDialog(id);
            }
            else if (msg == "Discover") {
                discoverNodes(id);
            }
            else {
                index = llListFindList(networkNodes, [msg]);
                if (index > -1) {
                    target = llList2Key(networkNodes, index - 1);
                    msgList = [target, "menu", id];  // id = user who opened the dialog
                    msgData = llDumpList2String(msgList, separator);
                    if (linkSet) llMessageLinked(LINK_ALL_OTHERS, remoteChannel, msgData, "");
                    else llRegionSayTo(target, remoteChannel, msgData);
                }
                else {
                    llInstantMessage(id, "Unexpected error during object key lookup");
                    menuDialog(id);
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
        else if (time == vReplyTime) {  // remote timeout (variable!)
            integer length = llGetListLength(networkNodes) / 2;
            if (length == 1) llWhisper(0, "Node discovery completed (" + (string)length + " node)");
            else llWhisper(0, "Node discovery completed (" + (string)length + " nodes)");
            llListenRemove(replyHandle);
            if (length > 0) {
                menuButtons = llList2ListStrided(llDeleteSubList(networkNodes, 0, 0), 0, -1, 2);
                menuButtons = llListSort(menuButtons, 1, TRUE);  // sort ascending
                menuButtons = orderButtons(menuButtons);         // reverse row order
                menuButtons = ["On", "Off", "Discover"] + menuButtons;
                if (user) menuDialog(user);
            }
        }
        else {
            if (debug) llOwnerSay("Timer out of range: " + (string)time);
        }
    }
}
