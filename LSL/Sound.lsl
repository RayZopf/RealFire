// LSL script generated: RealFire-Rene10957.LSL.Sound.lslp Thu Jan 30 17:20:27 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire by Zopf Resident - Ray Zopf (Raz)
//
//30. Jan. 2014
//v0.81
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)

//Files:
//Sound.lsl
//
//Fire.lsl
//config
//User Manual
//
//
//Prequisites: Soundfiles need to be in same prim as Sound.lsl
//Notecard format: see config NC
//basic help: User Manual

//Changelog
// LSLForge Modules
//

//bug: ---

//todo: improve sound file check
//todo: make sound file check (lists) the other way round: check if every inventory file is member of fire sound list?
//todo: decide if touch event should really block touch on child prim and how to preload sound
//todo: think about fire size = 0 what happens to normal sound (B-sound would just go working on)
//todo: use more sounds and change them randomly http://wiki.secondlife.com/wiki/Script:Random_Sounds
//todo: check if other sound scripts are in same prim
//todo: create a module sizeSelect, put size class borders into variables and settings notecard
///////////////////////////////////////////////////////////////////////////////////////////////////



//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode = FALSE;


//user changeable variables
//-----------------------------------------------
integer g_iSound = TRUE;
integer g_iVerbose = TRUE;

string g_sSoundFileStart = "75145__willc2-45220__struck-match-8b-22k-1-65s";
string g_sSoundFileSmall = "17742__krisboruff__fire-crackles-no-room";
string g_sSoundFileMedium1 = "104958__glaneur-de-sons__petit-feu-little-fire-2";
string g_sSoundFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1";
string g_sSoundFileFull = "4211__dobroide__fire-crackling";

integer g_iSoundNFiles = 5;
//starting sound has to be first in list
list g_lSoundFileList = [g_sSoundFileStart,g_sSoundFileSmall,g_sSoundFileMedium1,g_sSoundFileMedium2,g_sSoundFileFull];
string g_sCurrentSoundFile = g_sSoundFileMedium2;

string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSound";
string g_sVersion = "0.81";
string g_sScriptName;
string g_sType = "sound";
integer g_iType = LINK_SET;

integer g_iSoundAvail = FALSE;
integer g_iInvType = INVENTORY_SOUND;
integer g_iSoundFileStartAvail = TRUE;
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeNew;
string g_sSize = "0";

//RealFire MESSAGE MAP
//integer COMMAND_CHANNEL = -15700;
integer SOUND_CHANNEL = -15789;
integer COMMAND_CHANNEL = -15700;


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
        if (g_iSoundAvail) llWhisper(0,(g_sTitle + " - File(s) found in inventory: Yes"));
        else  llWhisper(0,(((g_sTitle + " / ") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
        if ((!g_iSound)) llWhisper(0,(((g_sTitle + " / ") + g_sScriptName) + " script disabled"));
        if ((g_iSound && g_iSoundAvail)) llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " ready"));
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
    if ((g_iSound && g_iSoundAvail)) llMessageLinked(link,SOUND_CHANNEL,"1",((key)sId));
    else  llMessageLinked(link,SOUND_CHANNEL,"0",((key)sId));
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
        if ((0 == llListFindList(lFileAvail,[TRUE]))) (g_iSoundFileStartAvail = TRUE);
        else  (g_iSoundFileStartAvail = FALSE);
        if ((ERR_GENERIC != llListFindList(llList2List(lFileAvail,1,(iNFiles - 1)),[TRUE]))) (g_iSoundAvail = TRUE);
        else  (g_iSoundAvail = FALSE);
    }
    else  (g_iSoundAvail = FALSE);
}


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

SelectSound(float fMsg){
    Debug(("SelectSound: " + ((string)fMsg)));
    if ((fMsg <= 25)) {
        (g_sCurrentSoundFile = g_sSoundFileSmall);
    }
    else  if (((fMsg > 25) && (fMsg <= 50))) {
        (g_sCurrentSoundFile = g_sSoundFileMedium1);
    }
    else  if (((fMsg > 50) && (fMsg < 80))) {
        (g_sCurrentSoundFile = g_sSoundFileMedium2);
    }
    else  if (((fMsg >= 80) && (fMsg <= 100))) {
        (g_sCurrentSoundFile = g_sSoundFileFull);
    }
    else  {
        Debug((("start if g_fSoundVolumeNew > 0: -" + ((string)g_fSoundVolumeNew)) + "-"));
        if (((g_fSoundVolumeNew > 0) && (TRUE == g_iSoundFileStartAvail))) {
            integer n;
            for ((n = 0); (n < 3); (++n)) {
                llTriggerSound(g_sSoundFileStart,g_fSoundVolumeNew);
            }
        }
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
        llStopSound();
        checkforFiles(g_iSoundNFiles,g_lSoundFileList,g_sCurrentSoundFile);
        llSleep(1);
        RegisterExtension(g_iType);
        InfoLines();
    }


    on_rez(integer start_param) {
        llResetScript();
    }

	
	touch(integer total_number) {
    }

	
	changed(integer change) {
        if ((change & CHANGED_INVENTORY)) {
            llWhisper(0,"Inventory changed, checking sound samples...");
            llStopSound();
            checkforFiles(g_iSoundNFiles,g_lSoundFileList,g_sCurrentSoundFile);
            llSleep(1);
            RegisterExtension(g_iType);
            InfoLines();
        }
    }


	
//listen for linked messages from Fire (main) script
//-----------------------------------------------
    link_message(integer iSender,integer iChan,string sSoundSet,key kId) {
        Debug(((((("link_message = channel " + ((string)iChan)) + "; sSoundSet ") + sSoundSet) + "; kId ") + ((string)kId)));
        MasterCommand(iChan,sSoundSet);
        string sScriptName = GroupCheck(kId);
        if (("exit" == sScriptName)) return;
        if (((((iChan != SOUND_CHANNEL) || (!g_iSound)) || (!g_iSoundAvail)) || (llSubStringIndex(llToLower(sScriptName),g_sType) >= 0))) return;
        list lParams = llParseString2List(sSoundSet,[","],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        Debug(((((((("no changes? background? " + sVal) + "-") + sMsg) + "...g_fSoundVolumeCur=") + ((string)g_fSoundVolumeCur)) + "-g_sSize=") + g_sSize));
        if ((((((float)sVal) == g_fSoundVolumeCur) && ((sMsg == g_sSize) || ("" == sMsg))) || ("-1" == sMsg))) return;
        Debug("work on link_message");
        llSetTimerEvent(0.0);
        (g_fSoundVolumeNew = ((float)sVal));
        if (((((0 == g_fSoundVolumeNew) && (sMsg != g_sSize)) && ("" != sMsg)) && ("0" != sMsg))) {
            SelectSound(((float)sMsg));
            Debug("change while off");
            return;
        }
        if (((g_fSoundVolumeNew > 0) && (g_fSoundVolumeNew <= 1))) {
            if ((("" == sMsg) || (sMsg == g_sSize))) {
                if ((g_fSoundVolumeCur > 0)) {
                    llAdjustSoundVolume(g_fSoundVolumeNew);
                    if (g_iVerbose) llWhisper(0,"(v) Sound range for fire has changed");
                }
                else  {
                    llLoopSound(g_sCurrentSoundFile,g_fSoundVolumeNew);
                    if (g_iVerbose) llWhisper(0,"(v) The fire starts to make some noise");
                }
                (g_fSoundVolumeCur = g_fSoundVolumeNew);
                return;
            }
            string sCurrentSoundFileTemp = g_sCurrentSoundFile;
            SelectSound(((float)sMsg));
            if ((g_sCurrentSoundFile == sCurrentSoundFileTemp)) {
                llAdjustSoundVolume(g_fSoundVolumeNew);
                if (g_iVerbose) llWhisper(0,"(v) Sound range for fire has changed");
                return;
            }
            if ((g_iVerbose && ("0" != g_sSize))) llWhisper(0,"(v) The fire changes it's sound");
            Debug(("play sound: " + g_sCurrentSoundFile));
            llPreloadSound(g_sCurrentSoundFile);
            (g_fSoundVolumeCur = g_fSoundVolumeNew);
            llStopSound();
            llLoopSound(g_sCurrentSoundFile,g_fSoundVolumeNew);
        }
        else  llSetTimerEvent(1.0);
    }



	timer() {
        llStopSound();
        if (g_iVerbose) llWhisper(0,"(v) Noise from fire ended");
        (g_fSoundVolumeNew = (g_fSoundVolumeCur = 0.0));
        llSetTimerEvent(0.0);
    }
}
