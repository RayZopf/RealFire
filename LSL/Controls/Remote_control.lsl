// LSL script generated: RealFire-Rene10957.LSL.Controls.Remote_control.lslp Fri Feb  7 21:06:26 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Remote control (secondary switch) for RealFire
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
//
// ALSO TO BE USED IN FIRE PRIMS (for primfire objects, so that on/off/menu still works when main script prim is behind those fire prims)
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: initial structure for multiple sound files, implement linked_message system, background sound, LSLForge Modules
//03. Feb. 2014
//v1.0-0.2
//


integer g_iVerbose = FALSE;


//user changeable variables
//-----------------------------------------------
string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire Remote Control";
string g_sVersion = "1.0-0.2";
string g_sAuthors = "Rene10957, Zopf";
string g_sMsgSwitch = "switch";
string g_sMsgMenu = "menu";
string SEPARATOR = ";;";
integer REMOTE_CHANNEL = -975102;


//###
//GroupHandling.lslm
//0.5 - 31Jan2014

string getGroup(string sDefGroup){
    if (("" == sDefGroup)) (sDefGroup = "Default");
    string str = llStringTrim(llGetObjectDesc(),STRING_TRIM);
    if (((llToLower(str) == "(no description)") || (str == ""))) (str = sDefGroup);
    else  {
        list lGroup = llParseString2List(str,[" "],[]);
        (str = llList2String(lGroup,0));
    }
    return str;
}


//===============================================
//PREDEFINED FUNCTIONS
//===============================================



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        if (g_iVerbose) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + " ready"));
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	touch_start(integer total_number) {
        llResetTime();
    }


	touch_end(integer total_number) {
        key kUser = llDetectedKey(0);
        string command;
        if ((llGetTime() > 1.0)) (command = g_sMsgMenu);
        else  (command = g_sMsgSwitch);
        list msgList = [getGroup(LINKSETID),command,kUser];
        string msgData = llDumpList2String(msgList,SEPARATOR);
        llRegionSay(REMOTE_CHANNEL,msgData);
    }
}
