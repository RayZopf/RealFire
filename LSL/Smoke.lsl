// LSL script generated: RealFire-Rene10957.LSL.Smoke.lslp Thu Feb  6 03:49:12 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Realfire by Rene - Smoke
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
// See fire.lsl for feature list
//
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: register with Fire.lsl, LSLForge Modules
//04. Feb. 2014
//v2.2.1-0.57
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
string g_sVersion = "2.2.1-0.57";
string g_sAuthors = "Rene10957, Zopf";
integer g_iType = LINK_ALL_OTHERS;

string g_sSize = "0";
string g_sScriptName;
vector g_vDefStartColor;
vector g_vDefEndColor;
integer g_iDefIntensity;
integer g_iDefRadius;
integer g_iDefFalloff;
integer g_iPerRedStart;
integer g_iPerGreenStart;
integer g_iPerBlueStart;
integer g_iPerRedEnd;
integer g_iPerGreenEnd;
integer g_iPerBlueEnd;
string SEPARATOR = ";;";
integer COMMAND_CHANNEL = -15700;
integer SMOKE_CHANNEL = -15790;


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
        if (g_iSmoke) llWhisper(0,(g_sTitle + " - File(s) found in inventory: Yes"));
        else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
    }
    if (g_iSmoke) {
        if (g_iSmoke) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
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


string GroupCheck(key kId){
    string str = getGroup(LINKSETID);
    list lKeys = llParseString2List(((string)kId),[SEPARATOR],[]);
    string sGroup = llList2String(lKeys,0);
    string sScriptName = llList2String(lKeys,1);
    if ((((str == sGroup) || (LINKSETID == sGroup)) || (LINKSETID == str))) return sScriptName;
    return "exit";
}


//###
//GenericFunctions.lslm
//0.1 - 06Feb2014

integer checkInt(string par,integer val,integer min,integer max){
    if (((val < min) || (val > max))) {
        if ((val < min)) (val = min);
        else  if ((val > max)) (val = max);
        llWhisper(0,((("[Notecard] " + par) + " out of range, corrected to ") + ((string)val)));
    }
    return val;
}


vector checkVector(string par,vector val){
    if ((val == ZERO_VECTOR)) {
        (val = <100,100,100>);
        llWhisper(0,((("[Notecard] " + par) + " out of range, corrected to ") + ((string)val)));
    }
    return val;
}


integer min(integer x,integer y){
    if ((x < y)) return x;
    else  return y;
}


integer max(integer x,integer y){
    if ((x > y)) return x;
    else  return y;
}


//###
//ExtensionBasics.lslm
//0.4 - 04Feb2014

RegisterExtension(integer link){
    string sId = ((getGroup(LINKSETID) + SEPARATOR) + g_sScriptName);
    if ((g_iSmoke && g_iSmoke)) llMessageLinked(link,SMOKE_CHANNEL,"1",((key)sId));
    else  llMessageLinked(link,SMOKE_CHANNEL,"0",((key)sId));
}


MasterCommand(integer iChan,string sVal,integer conf){
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
        else  if ((conf && ("config" == sCommand))) getConfig(sConfig);
        else  llSetTimerEvent(0.1);
    }
}


getConfig(string sConfig){
    list lConfigs = llParseString2List(sConfig,["=",SEPARATOR],[]);
    integer n = llGetListLength(lConfigs);
    integer count = 0;
    if (((n > 1) && (0 == (n % 2)))) do  {
        string par = llList2String(lConfigs,count);
        string val = llList2String(lConfigs,(count + 1));
        if ((par == "topcolor")) (g_vDefEndColor = checkVector("topColor",((vector)val)));
        else  if ((par == "bottomcolor")) (g_vDefStartColor = checkVector("bottomColor",((vector)val)));
        else  if ((par == "intensity")) (g_iDefIntensity = checkInt("intensity",((integer)val),0,100));
        else  if ((par == "radius")) (g_iDefRadius = checkInt("radius",((integer)val),0,100));
        else  if ((par == "falloff")) (g_iDefFalloff = checkInt("falloff",((integer)val),0,100));
        else  if (("startcolor" == par)) setColor(1,val);
        else  if (("endcolor" == par)) setColor(0,val);
        (count = (count + 2));
    }
    while ((count <= n));
}


setColor(integer pos,string msg){
    if ((1 == pos)) {
        if ((msg == "-Red")) (g_iPerRedStart = max((g_iPerRedStart - 10),0));
        else  if ((msg == "-Green")) (g_iPerGreenStart = max((g_iPerGreenStart - 10),0));
        else  if ((msg == "-Blue")) (g_iPerBlueStart = max((g_iPerBlueStart - 10),0));
        else  if ((msg == "+Red")) (g_iPerRedStart = min((g_iPerRedStart + 10),100));
        else  if ((msg == "+Green")) (g_iPerGreenStart = min((g_iPerGreenStart + 10),100));
        else  if ((msg == "+Blue")) (g_iPerBlueStart = min((g_iPerBlueStart + 10),100));
        else  if ((msg == "R min/max")) {
            if (g_iPerRedStart) (g_iPerRedStart = 0);
            else  (g_iPerRedStart = 100);
        }
        else  if ((msg == "G min/max")) {
            if (g_iPerGreenStart) (g_iPerGreenStart = 0);
            else  (g_iPerGreenStart = 100);
        }
        else  if ((msg == "B min/max")) {
            if (g_iPerBlueStart) (g_iPerBlueStart = 0);
            else  (g_iPerBlueStart = 100);
        }
        else  if ((msg == "One color")) {
            (g_iPerRedEnd = g_iPerRedStart);
            (g_iPerGreenEnd = g_iPerGreenStart);
            (g_iPerBlueEnd = g_iPerBlueStart);
        }
    }
    else  {
        if ((msg == "-Red")) (g_iPerRedEnd = max((g_iPerRedEnd - 10),0));
        else  if ((msg == "-Green")) (g_iPerGreenEnd = max((g_iPerGreenEnd - 10),0));
        else  if ((msg == "-Blue")) (g_iPerBlueEnd = max((g_iPerBlueEnd - 10),0));
        else  if ((msg == "+Red")) (g_iPerRedEnd = min((g_iPerRedEnd + 10),100));
        else  if ((msg == "+Green")) (g_iPerGreenEnd = min((g_iPerGreenEnd + 10),100));
        else  if ((msg == "+Blue")) (g_iPerBlueEnd = min((g_iPerBlueEnd + 10),100));
        else  if ((msg == "R min/max")) {
            if (g_iPerRedEnd) (g_iPerRedEnd = 0);
            else  (g_iPerRedEnd = 100);
        }
        else  if ((msg == "G min/max")) {
            if (g_iPerGreenEnd) (g_iPerGreenEnd = 0);
            else  (g_iPerGreenEnd = 100);
        }
        else  if ((msg == "B min/max")) {
            if (g_iPerBlueEnd) (g_iPerBlueEnd = 0);
            else  (g_iPerBlueEnd = 100);
        }
        else  if ((msg == "One color")) {
            (g_iPerRedStart = g_iPerRedEnd);
            (g_iPerGreenStart = g_iPerGreenEnd);
            (g_iPerBlueStart = g_iPerBlueEnd);
        }
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
        Debug(("state_entry, Particle count = " + ((string)llRound(((((float)g_iCount) * g_fAge) / g_fRate)))));
        if (g_iSmoke) llParticleSystem([]);
        llSleep(1);
        RegisterExtension(g_iType);
        InfoLines(FALSE);
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	changed(integer change) {
        if ((change & CHANGED_INVENTORY)) {
            llSleep(1);
            RegisterExtension(g_iType);
            InfoLines(FALSE);
        }
    }


//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender,integer iChan,string sMsg,key kId) {
        Debug(((((((("link_message = channel " + ((string)iChan)) + "; sMsg ") + sMsg) + "; kId ") + ((string)kId)) + " ...g_sSize ") + g_sSize));
        MasterCommand(iChan,sMsg,FALSE);
        if (((iChan != SMOKE_CHANNEL) || (!g_iSmoke))) return;
        string sScriptName = GroupCheck(kId);
        if (("exit" == GroupCheck(kId))) return;
        if (((sMsg == g_sSize) && ("0" != sMsg))) {
            llSetTimerEvent(0.0);
            return;
        }
        if (((((integer)sMsg) > 0) && (((integer)sMsg) <= 100))) {
            llSetTimerEvent(0.0);
            float fAlpha = ((g_fStartAlpha / 100.0) * ((float)sMsg));
            Debug(("fAlpha " + ((string)fAlpha)));
            llParticleSystem([PSYS_PART_FLAGS,((0 | PSYS_PART_INTERP_COLOR_MASK) | PSYS_PART_INTERP_SCALE_MASK),PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_EXPLODE,PSYS_SRC_BURST_RADIUS,0.1,PSYS_PART_START_COLOR,<0.5,0.5,0.5>,PSYS_PART_END_COLOR,<0.5,0.5,0.5>,PSYS_PART_START_ALPHA,fAlpha,PSYS_PART_END_ALPHA,0.0,PSYS_PART_START_SCALE,<0.1,0.1,0.0>,PSYS_PART_END_SCALE,<3.0,3.0,0.0>,PSYS_PART_MAX_AGE,g_fAge,PSYS_SRC_BURST_RATE,g_fRate,PSYS_SRC_BURST_PART_COUNT,g_iCount,PSYS_SRC_ACCEL,<0.0,0.0,0.2>,PSYS_SRC_BURST_SPEED_MIN,0.0,PSYS_SRC_BURST_SPEED_MAX,0.1]);
            if ((g_iVerbose && ("0" != g_sSize))) llWhisper(0,"(v) Smoke changes it's appearance");
            (g_sSize = sMsg);
        }
        else  {
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
