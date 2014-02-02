// LSL script generated: RealFire-Rene10957.LSL.P-Anim.lslp Sun Feb  2 20:24:11 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//PrimFire Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//02. Feb. 2014
//v0.13
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
//TODO: SelectStuff needs more work - less stages than selectSound in Sound.lsl
//TODO: fire objects need to be phantom... maybe make them flexiprim too
//TODO: temp prim handling not good
//TODO: listen event + timer to check if fire prim really was created
//TODO: check if fire prim is "copy"
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

//string g_sPrimFireFileStart = "75145__willc2-45220__struck-match-8b-22k-1-65s";   // starting fire (somehow special sound!)
string g_sPrimFireFileSmall = "Fire_small";
vector g_vOffsetSmall = <0.0,0.0,0.0>;
string g_sPrimFireFileMedium1 = "Fire_medium";
vector g_vOffsetMedium1 = <0.0,0.0,0.0>;
//string g_sPrimFireFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1";    // second sound for medium fire
string g_sPrimFireFileFull = "Fire_full";
vector g_vOffsetFull = <0.0,0.0,0.0>;

integer g_iPrimFireNFiles = 3;
//starting sound has to be first in list
list g_lPrimFireFileList = [g_sPrimFireFileSmall,g_sPrimFireFileMedium1,g_sPrimFireFileFull];
string g_sCurrentPrimFireFile = g_sPrimFireFileMedium1;

float g_fAltitude = 1.0;

string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealPrimFire";
string g_sVersion = "0.13";
string g_sScriptName;
string g_sType = "anim";
integer g_iType = LINK_SET;

integer g_iPrimFireAvail = FALSE;
integer g_iInvType = INVENTORY_OBJECT;
//integer g_iPrimFireFileStartAvail = TRUE;
integer g_iPrimFireNFilesAvail;
integer g_iLowprim = FALSE;
integer g_iPermCheck = TRUE;
string g_sSize = "0";
vector g_vOffset;
float SIZE_SMALL = 25.0;
float SIZE_MEDIUM = 50.0;
float SIZE_LARGE = 80.0;
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
    list lKeys = llParseString2List(((string)kId),[";"],[]);
    string sGroup = llList2String(lKeys,0);
    string sScriptName = llList2String(lKeys,1);
    if ((((str == sGroup) || (LINKSETID == sGroup)) || (LINKSETID == str))) return sScriptName;
    return "exit";
}


//###
//ExtensionBasics.lslm
//0.3 - 31Jan2014

RegisterExtension(integer link){
    string sId = ((getGroup(LINKSETID) + ";") + g_sScriptName);
    if ((g_iPrimFire && g_iPrimFireAvail)) llMessageLinked(link,ANIM_CHANNEL,"1",((key)sId));
    else  llMessageLinked(link,ANIM_CHANNEL,"0",((key)sId));
}


MasterCommand(integer iChan,string sVal){
    if ((iChan == COMMAND_CHANNEL)) {
        if (("register" == sVal)) RegisterExtension(g_iType);
        else  if (("verbose" == sVal)) (g_iVerbose = TRUE);
        else  if (("nonverbose" == sVal)) (g_iVerbose = FALSE);
        else  llSetTimerEvent(0.1);
    }
}


//###
//CheckForFiles.lslm
//0.2 - 02Feb2014

string CheckForFiles(integer iNFiles,list lgivenFileList,integer iPermCheck,string sCurrentFile){
    integer iFileNumber = llGetInventoryNumber(g_iInvType);
    Debug(("File number = " + ((string)iFileNumber)));
    if ((iFileNumber > 0)) {
        (g_iPrimFireNFilesAvail = 0);
        list lFileAvail = [];
        list lFileList = [];
        integer i;
        for ((i = 0); (i < iFileNumber); (++i)) {
            (lFileList += llGetInventoryName(g_iInvType,i));
        }
        list lFileCompare = [];
        for ((i = 0); (i < iNFiles); (++i)) {
            (lFileCompare = llList2List(lgivenFileList,i,i));
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
            else  {
                if (iPermCheck) {
                    if ((!(PERM_COPY & llGetInventoryPermMask(((string)lFileCompare),MASK_OWNER)))) {
                        llWhisper(0,((g_sTitle + " - File has wrong permission: ") + ((string)lFileCompare)));
                        (lFileAvail += FALSE);
                    }
                    else  {
                        (lFileAvail += TRUE);
                        (g_iPrimFireNFilesAvail++);
                    }
                }
                else  {
                    (lFileAvail += TRUE);
                    (g_iPrimFireNFilesAvail++);
                }
            }
        }
        if ((0 == llListFindList(lFileAvail,[TRUE]))) (g_iPrimFireAvail = TRUE);
        else  (g_iPrimFireAvail = FALSE);
        if ((ERR_GENERIC != llListFindList(llList2List(lFileAvail,1,(iNFiles - 1)),[TRUE]))) (g_iPrimFireAvail = TRUE);
        else  (g_iPrimFireAvail = FALSE);
        return sCurrentFile;
    }
    else  {
        (g_iPrimFireAvail = FALSE);
        return "0";
    }
}


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

SelectStuff(float fMsg){
    Debug(("SelectStuff: " + ((string)fMsg)));
    if ((fMsg <= SIZE_SMALL)) {
        (g_sCurrentPrimFireFile = g_sPrimFireFileSmall);
        (g_vOffset = <g_vOffsetSmall.x,g_vOffsetSmall.y,(g_vOffsetSmall.z + g_fAltitude)>);
    }
    else  if (((fMsg > SIZE_SMALL) && (fMsg < SIZE_MEDIUM))) {
        (g_sCurrentPrimFireFile = g_sPrimFireFileMedium1);
        (g_vOffset = <g_vOffsetMedium1.x,g_vOffsetMedium1.y,(g_vOffsetMedium1.z + g_fAltitude)>);
    }
    else  if (((fMsg >= SIZE_MEDIUM) && (fMsg < SIZE_LARGE))) {
        (g_sCurrentPrimFireFile = g_sPrimFireFileMedium1);
        (g_vOffset = <g_vOffsetMedium1.x,g_vOffsetMedium1.y,(g_vOffsetMedium1.z + g_fAltitude)>);
    }
    else  if (((fMsg >= SIZE_LARGE) && (fMsg <= 100))) {
        (g_sCurrentPrimFireFile = g_sPrimFireFileFull);
        (g_vOffset = <g_vOffsetFull.x,g_vOffsetFull.y,(g_vOffsetFull.z + g_fAltitude)>);
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
        llSay(PRIMCOMMAND_CHANNEL,"die");
        (g_sCurrentPrimFireFile = CheckForFiles(g_iPrimFireNFiles,g_lPrimFireFileList,g_iPermCheck,g_sCurrentPrimFireFile));
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
            (g_sCurrentPrimFireFile = CheckForFiles(g_iPrimFireNFiles,g_lPrimFireFileList,g_iPermCheck,g_sCurrentPrimFireFile));
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
        if (((((iChan != ANIM_CHANNEL) || (!g_iPrimFire)) || (!g_iPrimFireAvail)) || (llSubStringIndex(llToLower(sScriptName),g_sType) >= 0))) return;
        list lParams = llParseString2List(sSet,[","],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        Debug("work on link_message");
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
            if ((g_iPrimFireNFilesAvail > 1)) SelectStuff(((float)sMsg));
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
        if (g_iVerbose) llWhisper(0,"(v) Prim fire effects ended");
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
