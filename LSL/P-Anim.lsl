// LSL script generated: RealFire-Rene10957.LSL.P-Anim.lslp Tue Feb 11 21:32:37 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//PrimFire Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//11. Feb. 2014
//v0.17
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)

//Files:
// P-Anim.lsl
//
// Fire.lsl
// config
// User Manual
//
//
//Prequisites: Fireobjects need to be in same prim as P-Anim.lsl
//Notecard format: see config NC
//basic help: User Manual

//Changelog
//

//FIXME: ---

//TODO: make file check (lists) the other way round: check if every inventory file is member of RealFire file list?
//TODO: create a module sizeSelect, put size class borders into variables and settings notecard
//TODO: selectStuff needs more work - less stages than selectSound in Sound.lsl
//TODO: maybe make them flexiprim too
//TODO: temp prim handling not good
//TODO: listen event + timer to check if fire prim really was created
///////////////////////////////////////////////////////////////////////////////////////////////////



//===============================================
//GLOBAL VARIABLES
//===============================================

//user changeable variables
//-----------------------------------------------
integer g_iPrimFire;

//string g_sPrimFireFileStart = "75145__willc2-45220__struck-match-8b-22k-1-65s";   // starting fire (somehow special sound!)
string g_sPrimFireFileSmall = "Fire_small";
vector g_vOffsetSmall;
string g_sPrimFireFileMedium1 = "Fire_medium";
vector g_vOffsetMedium1;
//string g_sPrimFireFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1";    // second sound for medium fire
string g_sPrimFireFileFull = "Fire_full";
vector g_vOffsetFull;

integer g_iPrimFireNFiles;
//starting sound has to be first in list
list g_lPrimFireFileList = [g_sPrimFireFileSmall,g_sPrimFireFileMedium1,g_sPrimFireFileFull];
string g_sCurrentPrimFireFile = g_sPrimFireFileMedium1;

float g_fAltitude;

string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealPrimFire";
string g_sVersion = "0.17";
string g_sAuthors = "Zopf";

string g_sType = "anim";

integer g_iPrimFireAvail = 0;
//integer g_iPrimFireFileStartAvail = TRUE;
integer g_iPrimFireNFilesAvail;
integer g_iLowprim = 0;
string g_sSize = "0";
vector g_vOffset;
integer g_iVerbose = 1;
string g_sMainScript = "Fire.lsl";
string g_sScriptName;
integer silent = 0;
integer g_iSingleFire = 1;
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


//###
//CheckForFiles.lslm
//0.21 - 11Feb2014

string CheckForFiles(integer iNFiles,list lgivenFileList,integer iPermCheck,string sCurrentFile){
    integer iFileNumber = llGetInventoryNumber(6);
    
    if ((iFileNumber > 0)) {
        (g_iPrimFireNFilesAvail = 0);
        list lFileAvail = [];
        list lFileList = [];
        integer i;
        for ((i = 0); (i < iFileNumber); (++i)) {
            (lFileList += llGetInventoryName(6,i));
        }
        list lFileCompare = [];
        for ((i = 0); (i < iNFiles); (++i)) {
            (lFileCompare = llList2List(lgivenFileList,i,i));
            if ((-1 == llListFindList(lFileList,lFileCompare))) {
                (lFileAvail += 0);
                if ((((0 < i) && (((string)lFileCompare) == sCurrentFile)) && (2 < iNFiles))) {
                    integer iFileNAvail = llGetListLength(lFileAvail);
                    if ((iNFiles > iFileNAvail)) (sCurrentFile = ((string)llList2List(lgivenFileList,(i + 1),(i + 1))));
                    else  {
                        list lFileAvailTmp = llList2List(lFileAvail,1,(iNFiles - 1));
                        integer j = llListFindList(lFileAvailTmp,[1]);
                        if ((0 <= j)) (sCurrentFile = ((string)llList2List(lFileAvailTmp,j,j)));
                    }
                }
                llWhisper(0,((g_sTitle + " - File not found in inventory: ") + ((string)lFileCompare)));
            }
            else  {
                if (iPermCheck) {
                    if ((!(32768 & llGetInventoryPermMask(((string)lFileCompare),1)))) {
                        llWhisper(0,((g_sTitle + " - File has wrong permission: ") + ((string)lFileCompare)));
                        (lFileAvail += 0);
                    }
                    else  {
                        (lFileAvail += 1);
                        (g_iPrimFireNFilesAvail++);
                    }
                }
                else  {
                    (lFileAvail += 1);
                    (g_iPrimFireNFilesAvail++);
                }
            }
        }
        if ((0 == llListFindList(lFileAvail,[1]))) (g_iPrimFireAvail = 1);
        else  (g_iPrimFireAvail = 0);
        if ((-1 != llListFindList(llList2List(lFileAvail,1,(iNFiles - 1)),[1]))) (g_iPrimFireAvail = 1);
        else  (g_iPrimFireAvail = 0);
        return sCurrentFile;
    }
    else  {
        (g_iPrimFireAvail = 0);
        return "0";
    }
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        MESSAGE_MAP();
        (g_iPrimFire = 1);
        (g_vOffsetSmall = <0.0,0.0,-0.525>);
        (g_vOffsetMedium1 = <0.0,0.0,-0.345>);
        (g_vOffsetFull = <0.0,0.0,5.0e-2>);
        (g_iPrimFireNFiles = 3);
        (g_fAltitude = 1.0);
        integer rc = -1;
        (rc = llSetMemoryLimit(30000));
        if ((g_iVerbose && (1 > rc))) llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Setting memory limit failed"));
        (g_sScriptName = llGetScriptName());
        
        llSay(PRIMCOMMAND_CHANNEL,"die");
        (g_sCurrentPrimFireFile = CheckForFiles(g_iPrimFireNFiles,g_lPrimFireFileList,1,g_sCurrentPrimFireFile));
        llSleep(1);
        integer link = -1;
        if (g_iPrimFire) {
            if ((g_iSingleFire && (-1 == llGetInventoryType(g_sMainScript)))) {
                (g_iPrimFireAvail = 0);
                jump __end02;
            }
            string sDefGroup = LINKSETID;
            if (("" == sDefGroup)) (sDefGroup = "Default");
            string str = llStringTrim(llGetObjectDesc(),3);
            if (((llToLower(str) == "(no description)") || (str == ""))) (str = sDefGroup);
            else  {
                list lGroup = llParseString2List(str,[" "],[]);
                (str = llList2String(lGroup,0));
            }
            string sId = ((str + SEPARATOR) + g_sScriptName);
            if (g_iPrimFireAvail) llMessageLinked(link,ANIM_CHANNEL,"1",((key)sId));
            else  if (g_iSingleFire) llMessageLinked(link,ANIM_CHANNEL,"0",((key)sId));
        }
        @__end02;
        if ((g_iVerbose && 1)) {
            if (g_iPrimFireAvail) {
                if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
            }
            else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
        }
        if (g_iPrimFire) {
            if (g_iPrimFireAvail) {
                if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
            }
            else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
        }
        else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
        if (((!silent) && g_iVerbose)) llWhisper(0,((((((((("\n\t- used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	changed(integer change) {
        if ((change & 1)) {
            if ((!silent)) llWhisper(0,"Inventory changed, checking objects...");
            llSay(PRIMCOMMAND_CHANNEL,"die");
            (g_sCurrentPrimFireFile = CheckForFiles(g_iPrimFireNFiles,g_lPrimFireFileList,1,g_sCurrentPrimFireFile));
            llSleep(1);
            integer link = -1;
            if (g_iPrimFire) {
                if ((g_iSingleFire && (-1 == llGetInventoryType(g_sMainScript)))) {
                    (g_iPrimFireAvail = 0);
                    jump __end01;
                }
                string sDefGroup = LINKSETID;
                if (("" == sDefGroup)) (sDefGroup = "Default");
                string str = llStringTrim(llGetObjectDesc(),3);
                if (((llToLower(str) == "(no description)") || (str == ""))) (str = sDefGroup);
                else  {
                    list lGroup = llParseString2List(str,[" "],[]);
                    (str = llList2String(lGroup,0));
                }
                string sId = ((str + SEPARATOR) + g_sScriptName);
                if (g_iPrimFireAvail) llMessageLinked(link,ANIM_CHANNEL,"1",((key)sId));
                else  if (g_iSingleFire) llMessageLinked(link,ANIM_CHANNEL,"0",((key)sId));
            }
            @__end01;
            if ((g_iVerbose && 1)) {
                if (g_iPrimFireAvail) {
                    if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
                }
                else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
            }
            if (g_iPrimFire) {
                if (g_iPrimFireAvail) {
                    if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
                }
                else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
            }
            else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
            if (((!silent) && g_iVerbose)) llWhisper(0,((((((((("\n\t- used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
        }
    }



//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender,integer iChan,string sSet,key kId) {
        
        string _ret0;
        if ((iChan == COMMAND_CHANNEL)) {
            list lValues = llParseString2List(sSet,[SEPARATOR],[]);
            string sCommand = llList2String(lValues,0);
            if (("register" == sCommand)) {
                integer link = -1;
                if (g_iPrimFire) {
                    if ((g_iSingleFire && (-1 == llGetInventoryType(g_sMainScript)))) {
                        (g_iPrimFireAvail = 0);
                        jump _end0;
                    }
                    string sDefGroup = LINKSETID;
                    if (("" == sDefGroup)) (sDefGroup = "Default");
                    string str = llStringTrim(llGetObjectDesc(),3);
                    if (((llToLower(str) == "(no description)") || (str == ""))) (str = sDefGroup);
                    else  {
                        list lGroup = llParseString2List(str,[" "],[]);
                        (str = llList2String(lGroup,0));
                    }
                    string sId = ((str + SEPARATOR) + g_sScriptName);
                    if (g_iPrimFireAvail) llMessageLinked(link,ANIM_CHANNEL,"1",((key)sId));
                    else  if (g_iSingleFire) llMessageLinked(link,ANIM_CHANNEL,"0",((key)sId));
                }
                @_end0;
            }
            else  if (("verbose" == sCommand)) {
                (g_iVerbose = 1);
                if ((g_iVerbose && 0)) {
                    if (g_iPrimFireAvail) {
                        if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
                    }
                    else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
                }
                if (g_iPrimFire) {
                    if (g_iPrimFireAvail) {
                        if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
                    }
                    else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
                }
                else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
                if (((!silent) && g_iVerbose)) llWhisper(0,((((((((("\n\t- used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
            }
            else  if (("nonverbose" == sCommand)) (g_iVerbose = 0);
            else  if ((0 && ("config" == sCommand))) {
                (_ret0 = sSet);
                jump _end1;
            }
            else  if (g_iPrimFire) llSetTimerEvent(0.1);
            (_ret0 = "");
            jump _end1;
        }
        (_ret0 = "");
        @_end1;
        string sConfig = _ret0;
        string _ret2;
        string _sDefGroup4 = LINKSETID;
        if (("" == _sDefGroup4)) (_sDefGroup4 = "Default");
        string _str2 = llStringTrim(llGetObjectDesc(),3);
        if (((llToLower(_str2) == "(no description)") || (_str2 == ""))) (_str2 = _sDefGroup4);
        else  {
            list _lGroup7 = llParseString2List(_str2,[" "],[]);
            (_str2 = llList2String(_lGroup7,0));
        }
        string _str5 = _str2;
        list lKeys = llParseString2List(((string)kId),[SEPARATOR],[]);
        string sGroup = llList2String(lKeys,0);
        string _sScriptName6 = llList2String(lKeys,1);
        if ((((_str5 == sGroup) || (LINKSETID == sGroup)) || (LINKSETID == _str5))) {
            (_ret2 = _sScriptName6);
            jump _end3;
        }
        (_ret2 = "exit");
        @_end3;
        string sScriptName = _ret2;
        if (("exit" == sScriptName)) return;
        if (((((iChan != ANIM_CHANNEL) || (!g_iPrimFire)) || (!g_iPrimFireAvail)) || (llSubStringIndex(llToLower(sScriptName),g_sType) >= 0))) return;
        list lParams = llParseString2List(sSet,[SEPARATOR],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        
        if (((sVal != g_sSize) || (((integer)sMsg) != g_iLowprim))) {
            if (((sVal == g_sSize) && (("0" == sMsg) || ("1" == sMsg)))) {
                llSetTimerEvent(0.0);
                (g_iLowprim = (!g_iLowprim));
                llSay(PRIMCOMMAND_CHANNEL,"toggle");
                if (g_iLowprim) state temprez;
                return;
            }
        }
        else  return;
        if (((((integer)sVal) > 0) && (100 >= ((integer)sVal)))) {
            llSetTimerEvent(0.0);
            if (((((integer)sMsg) != g_iLowprim) && (("0" == sMsg) || ("1" == sMsg)))) (g_iLowprim = (!g_iLowprim));
            string sCurrentPrimFireFileTemp = g_sCurrentPrimFireFile;
            string g_sSizeTemp = g_sSize;
            if ((g_iPrimFireNFilesAvail > 1)) {
                float fVal = ((float)sVal);
                
                if ((fVal <= 25.0)) {
                    (g_sCurrentPrimFireFile = g_sPrimFireFileSmall);
                    (g_vOffset = <g_vOffsetSmall.x,g_vOffsetSmall.y,(g_vOffsetSmall.z + g_fAltitude)>);
                }
                else  if (((fVal > 25.0) && (fVal < 50.0))) {
                    (g_sCurrentPrimFireFile = g_sPrimFireFileMedium1);
                    (g_vOffset = <g_vOffsetMedium1.x,g_vOffsetMedium1.y,(g_vOffsetMedium1.z + g_fAltitude)>);
                }
                else  if (((fVal >= 50.0) && (fVal < 80.0))) {
                    (g_sCurrentPrimFireFile = g_sPrimFireFileMedium1);
                    (g_vOffset = <g_vOffsetMedium1.x,g_vOffsetMedium1.y,(g_vOffsetMedium1.z + g_fAltitude)>);
                }
                else  if (((fVal >= 80.0) && (fVal <= 100))) {
                    (g_sCurrentPrimFireFile = g_sPrimFireFileFull);
                    (g_vOffset = <g_vOffsetFull.x,g_vOffsetFull.y,(g_vOffsetFull.z + g_fAltitude)>);
                }
                else  {
                    (g_sSize = "0");
                    jump _end8;
                }
                (g_sSize = ((string)fVal));
                @_end8;
            }
            if (("0" == g_sSizeTemp)) {
                llSleep(2.0);
                llRezObject(g_sCurrentPrimFireFile,(llGetPos() + g_vOffset),ZERO_VECTOR,ZERO_ROTATION,1);
                if ((!g_iLowprim)) {
                    llSleep(3.0);
                    llSay(PRIMCOMMAND_CHANNEL,"toggle");
                    llSay(PRIMCOMMAND_CHANNEL,sVal);
                }
            }
            else  {
                if ((g_sCurrentPrimFireFile != sCurrentPrimFireFileTemp)) {
                    llSay(PRIMCOMMAND_CHANNEL,"die");
                    llRezObject(g_sCurrentPrimFireFile,(llGetPos() + g_vOffset),ZERO_VECTOR,ZERO_ROTATION,1);
                    if ((!g_iLowprim)) {
                        llSleep(3.0);
                        llSay(PRIMCOMMAND_CHANNEL,"toggle");
                    }
                }
                else  llSay(PRIMCOMMAND_CHANNEL,sVal);
            }
            if (g_iLowprim) state temprez;
        }
        else  llSetTimerEvent(1.0);
    }



	timer() {
        llSay(PRIMCOMMAND_CHANNEL,"die");
        if (((!silent) && g_iVerbose)) llWhisper(0,"(v) Prim fire effects ended");
        (g_sSize = "0");
        llSetTimerEvent(0.0);
    }
}



state temprez {

	state_entry() {
        state default;
        llSetTimerEvent(0.0);
    }


//listen for linked messages from Fire (main) script
//-----------------------------------------------
		//link_message(integer iSender, integer iChan, string sSet, key kId)


	timer() {
        llRezObject(g_sCurrentPrimFireFile,(llGetPos() + g_vOffset),ZERO_VECTOR,ZERO_ROTATION,1);
    }
}
