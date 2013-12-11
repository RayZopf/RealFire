// Remote control (secondary switch) for RealFire
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
// Drop this in an external prim you want to use as an extra on/off/menu switch
// Note: only useful if you need an external switch for a single fire
//
// A switch can be bound to a fire by entering the same word in the description of both prims
// Alternatively, you can use the network switch to control up to 9 fires

string title = "Remote Control";   // title
string version = "1.0";            // version

// Constants

integer remoteChannel = -975102;   // remote channel
string separator = ";;";           // separator for region messages

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
        llWhisper(0, title + " " + version + " ready");
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
        key user = llDetectedKey(0);
        string command;

        if (llGetTime() > 1.0) command = "menu";
        else command = "switch";

        list msgList = [getGroup(), command, user];
        string msgData = llDumpList2String(msgList, separator);
        llRegionSay(remoteChannel, msgData);
    }
}
