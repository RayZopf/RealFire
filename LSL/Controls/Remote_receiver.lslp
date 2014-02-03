///////////////////////////////////////////////////////////////////////////////////////////////////
//Remote receiver for RealFire
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
//
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: initial structure for multiple sound files, implement linked_message system, background sound, LSLForge Modules
//03. Feb. 2014
//v1.1-0.1
//

//Files:
// Fire.lsl
//
// Smoke.lsl
// Sound.lsl
// config
// User Manual
//
//
//Prequisites:
// Remote_receiver.lsl in same prim as Fire.lsl
// Remote_control.lsl to make use of this script
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

//debug variables
//-----------------------------------------------
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages
integer g_iVerbose = FALSE;


//user changeable variables
//-----------------------------------------------
string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire Remote Receiver";            // title
string g_sVersion = "1.1-0.1";        // version
string g_sScriptName;
string g_sType = "remote";
integer g_iType = LINK_SET;
string g_sAuthors = "Rene10957, Zopf";

// Constants
string SEPARATOR = ";;";           // separator for region messages
integer msgNumber = 10957;          // number part of link message


//===============================================
//LSLForge MODULES
//===============================================
$import RealFireMessageMap.lslm();
$import Debug.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName);
$import GroupHandling.lslm(m_sGroup=LINKSETID);


//===============================================
//PREDEFINED FUNCTIONS
//===============================================



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default
{
    state_entry()
    {
        llListen(REMOTE_CHANNEL, "", "", "");
        llWhisper(0, g_sTitle + " " + g_sVersion+" by "+g_sAuthors + " ready");
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    listen(integer channel, string name, key id, string msg)
    {
        if (channel != REMOTE_CHANNEL) return;

        list msgList = llParseString2List(msg, [SEPARATOR], []);
        string group = llList2String(msgList, 0);
        string command = llList2String(msgList, 1);
        key user = (key)llList2String(msgList, 2);

		string str = getGroup(LINKSETID);
        if (str == group || LINKSETID == group || LINKSETID == str) {
            llMessageLinked(LINK_THIS, msgNumber, command, user);
        }
    }

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}
