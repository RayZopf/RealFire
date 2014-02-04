// LSL script generated: RealFire-Rene10957.LSL.Controls.Remote_receiver.lslp Tue Feb  4 05:38:49 Mitteleuropäische Zeit 2014
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
//04. Feb. 2014
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
integer g_iType = LINK_SET;

// Constants
string SEPARATOR = ";;";
integer BOOL = TRUE;
integer g_iMsgNumber = 10957;
integer COMMAND_CHANNEL = -15700;
integer REMOTE_CHANNEL = -975102;
integer FAKE_CHANNEL = -1001001;


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
//0.13 - 04Feb2014

InfoLines(integer bool){
    if ((g_iVerbose && bool)) {
        if (BOOL) llWhisper(0,(g_sTitle + " - File(s) found in inventory: Yes"));
        else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
    }
    if (g_iRemote) {
        if (BOOL) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
        else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
    }
    else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
    if (g_iVerbose) llWhisper(0,((((("\n\t- free memory: " + ((string)llGetFreeMemory())) + " -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
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


//###
//ExtensionBasics.lslm
//0.32 - 04Feb2014

RegisterExtension(integer link){
    string sId = ((getGroup(LINKSETID) + ";") + g_sScriptName);
    if ((g_iRemote && BOOL)) llMessageLinked(link,FAKE_CHANNEL,"1",((key)sId));
    else  llMessageLinked(link,FAKE_CHANNEL,"0",((key)sId));
}


MasterCommand(integer iChan,string sVal){
    if ((iChan == COMMAND_CHANNEL)) {
        if (("register" == sVal)) RegisterExtension(g_iType);
        else  if (("verbose" == sVal)) {
            (g_iVerbose = TRUE);
            InfoLines(FALSE);
        }
        else  if (("nonverbose" == sVal)) (g_iVerbose = FALSE);
        else  if (("globaldebug" == sVal)) (g_iVerbose = TRUE);
        else  llSetTimerEvent(0.1);
    }
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
        (g_sScriptName = llGetScriptName());
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


//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender,integer iChan,string sSoundSet,key kId) {
        Debug(((((("link_message = channel " + ((string)iChan)) + "; sSoundSet ") + sSoundSet) + "; kId ") + ((string)kId)));
        MasterCommand(iChan,sSoundSet);
    }
}
