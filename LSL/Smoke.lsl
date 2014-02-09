// LSL script generated: RealFire-Rene10957.LSL.Smoke.lslp Sun Feb  9 00:58:57 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Realfire by Rene - Smoke
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
// See fire.lsl for feature list
//
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: register with Fire.lsl, LSLForge Modules
//08. Feb. 2014
//v2.1.3-0.581
//

//Files:
//Smoke.lsl
//
//Fire.lsl
//config
//User Manual
//
//
//Prequisites: Smoke.lsl in another prim than Fire.lsl
//Notecard format: see config NC
//basic help: User Manual
//
//Changelog
// Formatting
// moved functions into main code

//FIXME: if smoke is turned off via menu, llSleep still applies

//TODO: more natural smoke according to fire intensity - low fire with more fume, black smoke, smoke after fire is off, smoke fading instead of turning off
//TODO: en-/disable //PSYS_PART_WIND_MASK, if fire is out-/inside
//TODO: better use cone instead of explode (radius) + cone (placement)
//TODO: smoke reflecting fire light
//TODO: check if other sound scripts are in same prim
//TODO: more/different smoke (e.g. full perm prim fire)
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode = FALSE;


//user changeable variables
//-----------------------------------------------
integer g_iSmoke = TRUE;
integer g_iVerbose = TRUE;

string LINKSETID = "RealFire";

// Particle parameters
float g_fAge = 10.0;
float g_fRate = 0.5;
integer g_iCount = 5;
float g_fStartAlpha = 0.4;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSmoke";
string g_sVersion = "2.1.3-0.581";
string g_sAuthors = "Rene10957, Zopf";
integer g_iType = LINK_ALL_OTHERS;

string g_sSize = "0";
string g_sMainScript = "Fire.lsl";
string g_sScriptName;
integer silent = FALSE;
integer g_iSingleSmoke = FALSE;
string SEPARATOR = ";;";
integer COMMAND_CHANNEL = -15700;
integer PARTICLE_CHANNEL = -15790;


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


float percentage(float per,float num){
    return ((num / 100.0) * per);
}


//###
//PrintStatusInfo.lslm
//0.2 - 08Feb2014

InfoLines(integer bool){
    if ((g_iVerbose && bool)) {
        if (g_iSmoke) {
            if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
        }
        else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
    }
    if (g_iSmoke) {
        if (g_iSmoke) {
            if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
        }
        else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
    }
    else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
    if (((!silent) && g_iVerbose)) llWhisper(0,((((("\n\t- free memory: " + ((string)llGetFreeMemory())) + " -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
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


string GroupCheck(key kId){
    string str = getGroup(LINKSETID);
    list lKeys = llParseString2List(((string)kId),[SEPARATOR],[]);
    string sGroup = llList2String(lKeys,0);
    string sScriptName = llList2String(lKeys,1);
    if ((((str == sGroup) || (LINKSETID == sGroup)) || (LINKSETID == str))) return sScriptName;
    return "exit";
}


//###
//ExtensionBasics.lslm
//0.462 - 08Feb2014

RegisterExtension(integer link){
    if (g_iSmoke) {
        if ((g_iSingleSmoke && (INVENTORY_NONE == llGetInventoryType(g_sMainScript)))) {
            (g_iSmoke = FALSE);
            return;
        }
        string sId = ((getGroup(LINKSETID) + SEPARATOR) + g_sScriptName);
        if (g_iSmoke) llMessageLinked(link,PARTICLE_CHANNEL,"1",((key)sId));
        else  if (g_iSingleSmoke) llMessageLinked(link,PARTICLE_CHANNEL,"0",((key)sId));
    }
}


string MasterCommand(integer iChan,string sVal,integer conf){
    if ((iChan == COMMAND_CHANNEL)) {
        list lValues = llParseString2List(sVal,[SEPARATOR],[]);
        string sCommand = llList2String(lValues,0);
        if (("register" == sCommand)) {
            RegisterExtension(g_iType);
        }
        else  if (("verbose" == sCommand)) {
            (g_iVerbose = TRUE);
            InfoLines(FALSE);
        }
        else  if (("nonverbose" == sCommand)) (g_iVerbose = FALSE);
        else  if (("globaldebug" == sCommand)) (g_iVerbose = TRUE);
        else  if ((conf && ("config" == sCommand))) return sVal;
        else  if (g_iSmoke) llSetTimerEvent(0.1);
        return "";
    }
    return "";
}


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

initExtension(){
    if (g_iSmoke) llParticleSystem([]);
    llSleep(1);
    RegisterExtension(g_iType);
    InfoLines(FALSE);
}


updateParticles(float fAlpha){
    Debug(("fAlpha " + ((string)fAlpha)));
    llParticleSystem([PSYS_PART_FLAGS,((0 | PSYS_PART_INTERP_COLOR_MASK) | PSYS_PART_INTERP_SCALE_MASK),PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_EXPLODE,PSYS_SRC_BURST_RADIUS,0.1,PSYS_PART_START_COLOR,<0.5,0.5,0.5>,PSYS_PART_END_COLOR,<0.5,0.5,0.5>,PSYS_PART_START_ALPHA,fAlpha,PSYS_PART_END_ALPHA,0.0,PSYS_PART_START_SCALE,<0.1,0.1,0.0>,PSYS_PART_END_SCALE,<3.0,3.0,0.0>,PSYS_PART_MAX_AGE,g_fAge,PSYS_SRC_BURST_RATE,g_fRate,PSYS_SRC_BURST_PART_COUNT,g_iCount,PSYS_SRC_ACCEL,<0.0,0.0,0.2>,PSYS_SRC_BURST_SPEED_MIN,0.0,PSYS_SRC_BURST_SPEED_MAX,0.1]);
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        (g_sScriptName = llGetScriptName());
        Debug(("state_entry, Particle count = " + ((string)llRound(((((float)g_iCount) * g_fAge) / g_fRate)))));
        initExtension();
    }


	on_rez(integer start_param) {
        llResetScript();
    }

/* not needed, as there currently are no dependencies on files or config
	changed(integer change)
	{
		if (change & CHANGED_INVENTORY) {
		initExtension();
		}
	}
*/

//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender,integer iChan,string sSet,key kId) {
        Debug(((((((("link_message = channel " + ((string)iChan)) + "; sSet ") + sSet) + "; kId ") + ((string)kId)) + " ...g_sSize ") + g_sSize));
        MasterCommand(iChan,sSet,FALSE);
        if (((iChan != PARTICLE_CHANNEL) || (!g_iSmoke))) return;
        string sScriptName = GroupCheck(kId);
        if (("exit" == GroupCheck(kId))) return;
        list lParams = llParseString2List(sSet,[SEPARATOR],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        if (((sVal == g_sSize) && ("0" != sVal))) {
            llSetTimerEvent(0.0);
            return;
        }
        if ((((((integer)sVal) > 0) && (((integer)sVal) <= 100)) && ("smoke" == sMsg))) {
            llSetTimerEvent(0.0);
            updateParticles(percentage(((float)sVal),g_fStartAlpha));
            if ((g_iVerbose && ("0" != g_sSize))) llWhisper(0,"(v) Smoke changes it's appearance");
            (g_sSize = sVal);
        }
        else  if ((("smoke" == sMsg) || ("" == sMsg))) {
            llWhisper(0,"Fumes are fading");
            llSetTimerEvent(11.0);
        }
    }



	timer() {
        llParticleSystem([]);
        if (g_iVerbose) llWhisper(0,"(v) Smoke vanished");
        Debug("smoke particles off");
        (g_sSize = "0");
        llSetTimerEvent(0.0);
    }
}
