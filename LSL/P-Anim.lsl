// LSL script generated: RealFire-Rene10957.LSL.P-Anim.lslp Fri Jan 31 00:48:04 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//PrimFire Enhancement to Realfire by Zopf Resident - Ray Zopf (Raz)
//
//30. Jan. 2014
//v0.1
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)

//Files:
//P-Anim.lsl
//
//Fire.lsl
//config
//User Manual
//
//
//Prequisites: Fireobjects need to be in same prim as P-Anim.lsl
//Notecard format: see config NC
//basic help: User Manual

//Changelog
//

//bug: ---

//todo: make file check (lists) the other way round: check if every inventory file is member of RealFire file list?
//todo: create a module sizeSelect, put size class borders into variables and settings notecard
//todo: selectPrimFire needs more work - less stages than selectSound in Sound.lsl
///////////////////////////////////////////////////////////////////////////////////////////////////



//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode = FALSE;


//user changeable variables
//-----------------------------------------------
integer g_iPrimFire = TRUE;
integer g_iVerbose = TRUE;

//string g_sPrimFireFileStart 	= "75145__willc2-45220__struck-match-8b-22k-1-65s";   	// starting fire (somehow special sound!)
string g_sPrimFireFileSmall = "Fire_small";
string g_sPrimFireFileMedium1 = "Fire_medium";
//string g_sPrimFireFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1";    	// second sound for medium fire
string g_sPrimFireFileFull = "Fire_full";

integer g_iPrimFireNFiles = 3;
//starting sound has to be first in list
list g_lPrimFireFileList = [g_sPrimFireFileSmall,g_sPrimFireFileMedium1,g_sPrimFireFileFull];
string g_sCurrentPrimFireFile = g_sPrimFireFileMedium1;

float g_fAltitude = 1.0;

string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealPrimFire";
string g_sVersion = "0.1";
string g_sScriptName;
integer g_iType = LINK_SET;

integer g_iPrimFireAvail = FALSE;
integer g_iInvType = INVENTORY_OBJECT;
//integer g_iPrimFireFileStartAvail = TRUE;
integer g_iLowprim = FALSE;
string g_sSize = "0";
integer COMMAND_CHANNEL = -15700;
integer ANIM_CHANNEL = -15770;
integer PRIMCOMMAND_CHANNEL = -15771;


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
//0.11 - 28Jan2014

InfoLines(){
    if (g_iVerbose) {
        if (g_iPrimFireAvail) llWhisper(0,(g_sTitle + " - File(s) found in inventory: Yes"));
        else  llWhisper(0,(((g_sTitle + " / ") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
        if ((!g_iPrimFire)) llWhisper(0,(((g_sTitle + " / ") + g_sScriptName) + " script disabled"));
        if ((g_iPrimFire && g_iPrimFireAvail)) llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " ready"));
        else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
    }
}


//###
//getGroup.lslm
//0.21 - 29Jan2014

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
//RegisterExtension.lslm
//0.22 - 29Jan2014

RegisterExtension(integer link){
    string sId = ((getGroup(LINKSETID) + ";") + g_sScriptName);
    if ((g_iPrimFire && g_iPrimFireAvail)) llMessageLinked(link,ANIM_CHANNEL,"1",((key)sId));
    else  llMessageLinked(link,ANIM_CHANNEL,"0",((key)sId));
}


//###
//MasterCommand.lslm
//0.2 - 30Jan2014

MasterCommand(integer iChan,string sVal){
    if ((iChan == COMMAND_CHANNEL)) {
        if (("register" == sVal)) RegisterExtension(g_iType);
        else  if (("verbose" == sVal)) (g_iVerbose = TRUE);
        else  if (("nonverbose" == sVal)) (g_iVerbose = FALSE);
        else  llSetTimerEvent(0.1);
    }
}


//###
//GroupCheck.lslm
//0.4 - 30Jan2014

string GroupCheck(key kId){
    string str = getGroup(LINKSETID);
    list lKeys = llParseString2List(((string)kId),[";"],[]);
    string sGroup = llList2String(lKeys,0);
    string sScriptName = llList2String(lKeys,1);
    if ((((str == sGroup) || (LINKSETID == sGroup)) || (LINKSETID == str))) return sScriptName;
    return "exit";
}


//###
//checkforFiles.lslm
//0.1 - 30Jan2014

checkforFiles(integer iNFiles,list lgivenFileList,string sCurrentFile){
    integer iFileNumber = llGetInventoryNumber(g_iInvType);
    Debug(("File number = " + ((string)iFileNumber)));
    if ((iFileNumber > 0)) {
        list lFileAvail = [];
        list lFileList = [];
        integer i;
        for ((i = 0); (i < iFileNumber); (++i)) {
            (lFileList += llGetInventoryName(g_iInvType,i));
        }
        for ((i = 0); (i < iNFiles); (++i)) {
            list lFileCompare = llList2List(lgivenFileList,i,i);
            if ((ERR_GENERIC == llListFindList(lFileList,lFileCompare))) {
                (lFileAvail += FALSE);
                if ((((0 < i) && (((string)lFileCompare) == sCurrentFile)) && (2 < iNFiles))) {
                    integer iFileNAvail = llGetListLength(lFileAvail);
                    if ((iNFiles > iFileNAvail)) (sCurrentFile = ((string)llList2List(lgivenFileList,(i + 1),(i + 1))));
                    else  {
                        list lFileAvailTmp = llList2List(lFileAvail,1,(iNFiles - 1));
                        integer j = llListFindList(lFileAvailTmp,[TRUE]);
                        if ((0 <= j)) (sCurrentFile = ((string)llList2List(lFileAvailTmp,j,j)));
                    }
                }
                llWhisper(0,((g_sTitle + " - File not found in inventory: ") + ((string)lFileCompare)));
            }
            else  (lFileAvail += TRUE);
        }
        if ((0 == llListFindList(lFileAvail,[TRUE]))) (g_iPrimFireAvail = TRUE);
        else  (g_iPrimFireAvail = FALSE);
        if ((ERR_GENERIC != llListFindList(llList2List(lFileAvail,1,(iNFiles - 1)),[TRUE]))) (g_iPrimFireAvail = TRUE);
        else  (g_iPrimFireAvail = FALSE);
    }
    else  (g_iPrimFireAvail = FALSE);
}


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

SelectPrimFire(float fMsg){
    Debug(("SelectPrimFire: " + ((string)fMsg)));
    if ((fMsg <= 25)) {
        (g_sCurrentPrimFireFile = g_sPrimFireFileSmall);
    }
    else  if (((fMsg > 25) && (fMsg <= 50))) {
        (g_sCurrentPrimFireFile = g_sPrimFireFileMedium1);
    }
    else  if (((fMsg > 50) && (fMsg < 80))) {
        (g_sCurrentPrimFireFile = g_sPrimFireFileMedium1);
    }
    else  if (((fMsg >= 80) && (fMsg <= 100))) {
        (g_sCurrentPrimFireFile = g_sPrimFireFileFull);
    }
    else  {
        (g_sSize = "0");
        return;
    }
    (g_sSize = ((string)fMsg));
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

    state_entry() {
        (g_sScriptName = llGetScriptName());
        Debug("state_entry");
        checkforFiles(g_iPrimFireNFiles,g_lPrimFireFileList,g_sCurrentPrimFireFile);
        llSleep(1);
        RegisterExtension(g_iType);
        InfoLines();
    }


    on_rez(integer start_param) {
        llResetScript();
    }

	
	changed(integer change) {
        if ((change & CHANGED_INVENTORY)) {
            llWhisper(0,"Inventory changed, checking objects...");
            checkforFiles(g_iPrimFireNFiles,g_lPrimFireFileList,g_sCurrentPrimFireFile);
            llSleep(1);
            RegisterExtension(g_iType);
            InfoLines();
        }
    }


	
//listen for linked messages from Fire (main) script
//-----------------------------------------------
    link_message(integer iSender,integer iChan,string sSet,key kId) {
        Debug(((((("link_message = channel " + ((string)iChan)) + "; sSet ") + sSet) + "; kId ") + ((string)kId)));
        MasterCommand(iChan,sSet);
        string sScriptName = GroupCheck(kId);
        if (("exit" == sScriptName)) return;
        if (((((iChan != ANIM_CHANNEL) || (!g_iPrimFire)) || (!g_iPrimFireAvail)) || (llToLower(sScriptName) == llToLower(g_sScriptName)))) return;
        list lParams = llParseString2List(sSet,[","],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        Debug("work on link_message");
        if ((sVal == g_sSize)) {
            if ((((integer)sMsg) == g_iLowprim)) return;
            else  {
                llSetTimerEvent(0.0);
                llSay(PRIMCOMMAND_CHANNEL,"toggle");
                if (g_iLowprim) state temprez;
                return;
            }
        }
        if ((((integer)sMsg) != g_iLowprim)) {
            llSetTimerEvent(0.0);
            if (g_iLowprim) {
                llSay(PRIMCOMMAND_CHANNEL,"permanent");
            }
            else  state temprez;
            (g_iLowprim = (!g_iLowprim));
        }
        if (((((integer)sVal) > 0) && (100 >= ((integer)sVal)))) {
            llSetTimerEvent(0.0);
            string sCurrentPrimFireFileTemp = g_sCurrentPrimFireFile;
            SelectPrimFire(((float)sVal));
            if (("0" == g_sSize)) llRezObject(g_sCurrentPrimFireFile,(llGetPos() + <0.0,0.0,g_fAltitude>),ZERO_VECTOR,ZERO_ROTATION,0);
            else  {
                if ((g_sCurrentPrimFireFile != sCurrentPrimFireFileTemp)) {
                    llSay(PRIMCOMMAND_CHANNEL,"die");
                    llRezObject(g_sCurrentPrimFireFile,(llGetPos() + <0.0,0.0,g_fAltitude>),ZERO_VECTOR,ZERO_ROTATION,0);
                }
            }
            (g_sSize = sVal);
            if (g_iLowprim) state temprez;
        }
        else  llSetTimerEvent(1.0);
    }



	timer() {
        llSay(PRIMCOMMAND_CHANNEL,"die");
        if (g_iVerbose) llWhisper(0,"(v) Prim fire effects ended");
        (g_sSize = "0");
        llSetTimerEvent(0.0);
    }
}



state temprez {

	state_entry() {
        state default;
    }

	
	timer() {
        
    }
}
