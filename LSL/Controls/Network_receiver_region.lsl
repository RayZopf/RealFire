// Network receiver for RealFire
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
// Drop this into the same prim where the FIRE SCRIPT is located
// Note: only useful if you are also using the network control script

string title = "Network Receiver";   // title
string version = "2.1";              // version
integer linkSet = FALSE;             // REGION mode
integer debug = FALSE;               // show/hide debug messages
integer silent = FALSE;              // silent startup

// Constants

integer remoteChannel = -975101;     // remote channel
integer replyChannel = -975106;      // reply channel
integer msgNumber = 10959;           // number part of link message
string separator = ";;";             // separator for link or region messages

// Variables

key owner;                           // object owner

default
{
    state_entry()
    {
        owner = llGetOwner();
        if (linkSet) {
            version += "-LINKSET";
        }
        else {
            version += "-REGION";
            llListen(remoteChannel, "", "", "");
        }
        if (!silent) llWhisper(0, title + " " + version + " ready");
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    link_message(integer sender, integer number, string msg, key id)
    {
        if (debug) llOwnerSay("[Receiver] LINK_MESSAGE event: " + (string)number + "; " + msg + "; " + (string)id);
        if (number != remoteChannel) return;
        if (msg == "HELO") {
            llRegionSayTo(id, replyChannel, "DATA");
            return;
        }
        list msgList = llParseString2List(msg, [separator], []);
        key target = (key)llList2String(msgList, 0);
        string command = llList2String(msgList, 1);
        key user = (key)llList2String(msgList, 2);
        if (target == llGetKey()) llMessageLinked(LINK_THIS, msgNumber, command, user);
    }

    listen(integer channel, string name, key id, string msg)
    {
        if (debug) llOwnerSay("[Receiver] LISTEN event: " + (string)channel + "; " + msg);
        if (channel != remoteChannel) return;
        if (llGetOwnerKey(id) != owner) return;
        if (msg == "HELO") {
            llRegionSayTo(id, replyChannel, "DATA");
            return;
        }
        list msgList = llParseString2List(msg, [separator], []);
        string command = llList2String(msgList, 1);
        key user = (key)llList2String(msgList, 2);
        llMessageLinked(LINK_THIS, msgNumber, command, user);
    }
}
