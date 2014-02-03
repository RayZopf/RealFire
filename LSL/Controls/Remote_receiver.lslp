// Remote receiver for RealFire
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
// Drop this into the same prim where the FIRE SCRIPT is located
// Note: only useful if you are also using the remote control script

string title = "Remote Receiver";   // title
string version = "1.1";             // version

// Constants

integer remoteChannel = -975102;    // remote channel
integer msgNumber = 10957;          // number part of link message
string separator = ";;";            // separator for region messages

// Functions

string getGroup()
{
    string str = llStringTrim(llGetObjectDesc(), STRING_TRIM);
    if (llToLower(str) == "(no description)" || str == "") str = "Default";
    return str;
}

default
{
    state_entry()
    {
        llListen(remoteChannel, "", "", "");
        llWhisper(0, title + " " + version + " ready");
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    listen(integer channel, string name, key id, string msg)
    {
        if (channel != remoteChannel) return;

        list msgList = llParseString2List(msg, [separator], []);
        string group = llList2String(msgList, 0);
        string command = llList2String(msgList, 1);
        key user = (key)llList2String(msgList, 2);

        if (group == getGroup() || group == "Default" || getGroup() == "Default") {
            llMessageLinked(LINK_THIS, msgNumber, command, user);
        }
    }
}
