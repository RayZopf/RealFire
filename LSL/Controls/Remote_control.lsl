// LSL script generated: RealFire-Rene10957.LSL.Controls.Remote_control.lslp Mon Feb 10 14:26:29 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Remote control (secondary switch) for RealFire
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
//09. Feb. 2014
//v1.1-0.21
//

//Files:
// Fire.lsl
// Remote_receiver.lsl
//
// Smoke.lsl
// Sound.lsl
// config
// User Manual
//
//
//Prequisites:
// Remote_receiver.lsl in same prim as Fire.lsl
//
//Notecard format: see config NC
//basic help: User Manual and in header
//
//Changelog
// Formatting
// LSLFore modules

//FIXME: ----

//TODO: ----
//
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//user changeable variables
//-----------------------------------------------
string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire Remote Control";
string g_sVersion = "1.1-0.21";
string g_sAuthors = "Rene10957, Zopf";
integer g_iVerbose = 1;
string g_sMsgSwitch = "switch";
string g_sMsgMenu = "menu";
string SEPARATOR = ";;";
integer COMMAND_CHANNEL;
integer PARTICLE_CHANNEL;
integer SOUND_CHANNEL;
integer ANIM_CHANNEL;
integer PRIMCOMMAND_CHANNEL;
integer REMOTE_CHANNEL;


MESSAGE_MAP(){
    (COMMAND_CHANNEL = 15700);
    (PARTICLE_CHANNEL = -15790);
    (SOUND_CHANNEL = -15780);
    (ANIM_CHANNEL = -15770);
    (PRIMCOMMAND_CHANNEL = -15771);
    (REMOTE_CHANNEL = -975102);
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
        MESSAGE_MAP();
        (g_iVerbose = 0);
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
        string sDefGroup = LINKSETID;
        if (("" == sDefGroup)) (sDefGroup = "Default");
        string str = llStringTrim(llGetObjectDesc(),3);
        if (((llToLower(str) == "(no description)") || (str == ""))) (str = sDefGroup);
        else  {
            list lGroup = llParseString2List(str,[" "],[]);
            (str = llList2String(lGroup,0));
        }
        list msgList = [str,command,kUser];
        string msgData = llDumpList2String(msgList,SEPARATOR);
        llRegionSay(REMOTE_CHANNEL,msgData);
    }
}
