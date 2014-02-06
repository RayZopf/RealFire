// LSL script generated: RealFire-Rene10957.LSL.Controls.Remote_receiver.lslp Thu Feb  6 06:05:27 Mitteleuropäische Zeit 2014
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
integer g_iType = LINK_SET;

// Constants
integer BOOL = TRUE;
string g_sScriptName;
integer g_iMsgNumber = 10957;
string SEPARATOR = ";;";
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
        if (BOOL) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
        else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
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
//0.451 - 06Feb2014

RegisterExtension(integer link){
    string sId = ((getGroup(LINKSETID) + SEPARATOR) + g_sScriptName);
    if ((g_iRemote && BOOL)) llMessageLinked(link,FAKE_CHANNEL,"1",((key)sId));
    else  llMessageLinked(link,FAKE_CHANNEL,"0",((key)sId));
}


string MasterCommand(integer iChan,string sVal,integer conf){
    if ((iChan == COMMAND_CHANNEL)) {
        list lValues = llParseString2List(sVal,[SEPARATOR],[]);
        string sCommand = llList2String(lValues,0);
        string sConfig = llList2String(lValues,1);
        if (("register" == sCommand)) RegisterExtension(g_iType);
        else  if (("verbose" == sCommand)) {
            (g_iVerbose = TRUE);
            InfoLines(FALSE);
        }
        else  if (("nonverbose" == sCommand)) (g_iVerbose = FALSE);
        else  if (("globaldebug" == sCommand)) (g_iVerbose = TRUE);
        else  if ((conf && ("config" == sCommand))) return sConfig;
        else  llSetTimerEvent(0.1);
        return "";
    }
    return "";
}


integer getConfigRemote(string sConfig){
    list lConfigs = llParseString2List(sConfig,["=",SEPARATOR],[]);
    integer n = llGetListLength(lConfigs);
    integer count = 0;
    integer set = 0;
    if (((n > 1) && (0 == (n % 2)))) do  {
        string par = llList2String(lConfigs,count);
        string val = llList2String(lConfigs,(count + 1));
        if ((par == "msgnumber")) {
            (g_iMsgNumber = ((integer)val));
            (set++);
        }
        (count = (count + 2));
    }
    while ((count <= n));
    else  return 0;
    if ((0 < set)) return 1;
    else  return 0;
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
        if (g_iVerbose) llWhisper(0,(((((("(v) " + g_sTitle) + " uses channel: ") + ((string)g_iMsgNumber)) + " and listens on ") + ((string)REMOTE_CHANNEL)) + " for remote controler"));
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
	link_message(integer iSender,integer iChan,string sSet,key kId) {
        Debug(((((("link_message = channel " + ((string)iChan)) + "; sSoundSet ") + sSet) + "; kId ") + ((string)kId)));
        string sConfig = MasterCommand(iChan,sSet,FALSE);
        if (("" != sConfig)) {
            if ((getConfigRemote(sConfig) && g_iVerbose)) llWhisper(0,(((((("(v) " + g_sTitle) + " uses channel: ") + ((string)g_iMsgNumber)) + " and listens on ") + ((string)REMOTE_CHANNEL)) + " for remote controler"));
        }
    }
}
