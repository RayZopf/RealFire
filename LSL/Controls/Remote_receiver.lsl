// LSL script generated: RealFire-Rene10957.LSL.Controls.Remote_receiver.lslp Sat Feb  8 04:57:13 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Remote receiver for RealFire
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
// Note: only useful if you are also using the remote control script
//
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: initial structure for multiple sound files, implement linked_message system, background sound, LSLForge Modules
//08. Feb. 2014
//v1.2-0.4
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
string g_sVersion = "1.2-0.4";
string g_sAuthors = "Rene10957, Zopf";
integer g_iType = LINK_SET;

integer g_iListenHandle = 0;

// Constants
integer BOOL = TRUE;
string g_sScriptName;
integer g_iMsgNumber = 10959;
string SEPARATOR = ";;";
integer COMMAND_CHANNEL = -15700;
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
//0.452 - 06Feb2014

RegisterExtension(integer link){
    string sId = ((getGroup(LINKSETID) + SEPARATOR) + g_sScriptName);
    if ((g_iRemote && BOOL)) llMessageLinked(link,REMOTE_CHANNEL,"1",((key)sId));
    else  llMessageLinked(link,REMOTE_CHANNEL,"0",((key)sId));
}


string MasterCommand(integer iChan,string sVal,integer conf){
    if ((iChan == COMMAND_CHANNEL)) {
        list lValues = llParseString2List(sVal,[SEPARATOR],[]);
        string sCommand = llList2String(lValues,0);
        if (("register" == sCommand)) RegisterExtension(g_iType);
        else  if (("verbose" == sCommand)) {
            (g_iVerbose = TRUE);
            InfoLines(FALSE);
        }
        else  if (("nonverbose" == sCommand)) (g_iVerbose = FALSE);
        else  if (("globaldebug" == sCommand)) (g_iVerbose = TRUE);
        else  if ((conf && ("config" == sCommand))) return sVal;
        else  if (g_iRemote) llSetTimerEvent(0.1);
        return "";
    }
    return "";
}

/*
getConfigSound(string sConfig)
{
	list lConfigs = llParseString2List(sConfig, ["=",SEPARATOR], []);
	integer n = llGetListLength(lConfigs);
	integer count = 0;
	if (n > 1 && 0 == n%2) do {
		string par = llList2String(lConfigs, count);
		string val = llList2String(lConfigs, count+1);
/ *
		// config for particle fire
		if (par == "topcolor") g_vDefEndColor = checkVector("topColor", (vector)val);
		else if (par == "bottomcolor") g_vDefStartColor = checkVector("bottomColor", (vector)val);
		// config for light
		else if (par == "intensity") g_iDefIntensity = checkInt("intensity", (integer)val, 0, 100);
		else if (par == "radius") g_iDefRadius = checkInt("radius", (integer)val, 0, 100);
		else if (par == "falloff") g_iDefFalloff = checkInt("falloff", (integer)val, 0, 100);
		// color config
		else if ("startcolor" == par) setColor(1, val);
		else if ("endcolor" == par) setColor(0, val);
* /
		count = count +2;
	} while (count <= n);
}


integer getConfigBSound(string sConfig)
{
	list lConfigs = llParseString2List(sConfig, ["=",SEPARATOR], []);
	integer n = llGetListLength(lConfigs);
	integer count = 0;
	if (n > 1 && 0 == n%2) do {
		string par = llList2String(lConfigs, count);
		string val = llList2String(lConfigs, count+1);
/ *
		// config for particle fire
		if (par == "topcolor") g_vDefEndColor = checkVector("topColor", (vector)val);
		else if (par == "bottomcolor") g_vDefStartColor = checkVector("bottomColor", (vector)val);
		// config for light
		else if (par == "intensity") g_iDefIntensity = checkInt("intensity", (integer)val, 0, 100);
		else if (par == "radius") g_iDefRadius = checkInt("radius", (integer)val, 0, 100);
		else if (par == "falloff") g_iDefFalloff = checkInt("falloff", (integer)val, 0, 100);
		// color config
		else if ("startcolor" == par) setColor(1, val);
		else if ("endcolor" == par) setColor(0, val);
* /
		count = count +2;
	} while (count <= n);
	else return 0;
	return 1;
}
*/

integer getConfigRemote(string sVal){
    list lConfigs = llParseString2List(sVal,["config","=",SEPARATOR],[]);
    integer n = llGetListLength(lConfigs);
    integer count = 0;
    string par;
    Debug(((("getConfig Particlefire " + ((string)lConfigs)) + " n ") + ((string)n)));
    if (((n > 1) && (0 == (n % 2)))) {
        string val;
        do  {
            (par = llList2String(lConfigs,count));
            (val = llList2String(lConfigs,(count + 1)));
            if ((par == "msgnumber")) {
                (g_iMsgNumber = ((integer)val));
                return 1;
            }
            (count = (count + 2));
        }
        while ((count <= n));
    }
    else  return 0;
}


//===============================================
//PREDEFINED FUNCTIONS
//===============================================


initExtension(){
    llListenRemove(g_iListenHandle);
    (g_iListenHandle = llListen(REMOTE_CHANNEL,"","",""));
    InfoLines(FALSE);
    if (g_iVerbose) llWhisper(0,(((((("(v) " + g_sTitle) + " uses channel: ") + ((string)g_iMsgNumber)) + " and listens on ") + ((string)REMOTE_CHANNEL)) + " for remote controler"));
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        (g_sScriptName = llGetScriptName());
        initExtension();
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	listen(integer channel,string name,key kId,string msg) {
        Debug(("listen: " + msg));
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
        string sConfig = MasterCommand(iChan,sSet,TRUE);
        if (("" != sConfig)) {
            if (getConfigRemote(sConfig)) {
                initExtension();
            }
        }
    }
}
