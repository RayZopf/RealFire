// LSL script generated: RealFire-Rene10957.LSL.Controls.Remote_receiver.lslp Tue Feb  4 00:05:29 Mitteleuropäische Zeit 2014
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
//v1.1-0.21
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
integer g_iDebugMode = FALSE;


//user changeable variables
//-----------------------------------------------
integer g_iVerbose = TRUE;
integer g_iRemote = TRUE;
string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire Remote Receiver";
string g_sVersion = "1.1-0.21";
string g_sAuthors = "Rene10957, Zopf";
string g_sScriptName;

// Constants
string SEPARATOR = ";;";
integer BOOL = TRUE;
integer g_iMsgNumber = 10957;
integer REMOTE_CHANNEL = -975102;


//###
//Debug.lslm
//0.1 - 28Jan2014

//===============================================================================
//= parameters   :    string    sMsg    message string received
//=
//= return        :    none
//=
//= description  :    output debug messages
//=
//===============================================================================
Debug(string sMsg){
    if ((!g_iDebugMode)) return;
    llOwnerSay(((("DEBUG: " + g_sScriptName) + "; ") + sMsg));
}


//###
//PrintStatusInfo.lslm
//0.12 - 03Feb2014

InfoLines(integer bool){
    if (g_iVerbose) {
        if (bool) {
            if (BOOL) llWhisper(0,(g_sTitle + " - File(s) found in inventory: Yes"));
            else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
        }
        if ((!g_iRemote)) llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
        if ((g_iRemote && BOOL)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
        else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
        llWhisper(0,((((("\n\t- free memory: " + ((string)llGetFreeMemory())) + " -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
    }
}


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
        llListen(REMOTE_CHANNEL,"","","");
        InfoLines(FALSE);
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	listen(integer channel,string name,key kId,string msg) {
        Debug(("listen: " + msg));
        if ((channel != REMOTE_CHANNEL)) return;
        list msgList = llParseString2List(msg,[SEPARATOR],[]);
        string group = llList2String(msgList,0);
        string str = getGroup(LINKSETID);
        if ((((str != group) && (LINKSETID != group)) && (LINKSETID != str))) return;
        string command = llList2String(msgList,1);
        key user = ((key)llList2String(msgList,2));
        llMessageLinked(LINK_THIS,g_iMsgNumber,command,user);
    }
}
