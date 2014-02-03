// LSL script generated: RealFire-Rene10957.LSL.Sound.lslp Mon Feb  3 23:48:35 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//03. Feb. 2014
//v0.85
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)
//

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
//
//Changelog
// LSLForge Modules
//

//FIXME: ---

//TODO: make file check (lists) the other way round: check if every inventory file is member of RealFire file list?
//TODO: decide if touch event should really block touch on child prim and how to preload sound
//TODO: think about fire size = 0 what happens to normal sound (B-sound would just go working on)
//TODO: use more sounds and change them randomly http://wiki.secondlife.com/wiki/Script:Random_Sounds
//TODO: check if other sound scripts are in same prim
//TODO: create a module sizeSelect, put size class borders into variables and settings notecard
//TODO: is "change sound while off" really needed? - check sound on/off, sound more/less louder
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
string g_sVersion = "0.85";
string g_sAuthors = "Zopf";
string g_sScriptName;
string g_sType = "sound";
integer g_iType = LINK_SET;

integer g_iSoundAvail = FALSE;
integer g_iInvType = INVENTORY_SOUND;
integer g_iSoundFileStartAvail = TRUE;
integer g_iPermCheck = FALSE;
integer g_iSoundNFilesAvail;
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeNew;
string g_sSize = "0";
float SIZE_SMALL = 25.0;
float SIZE_MEDIUM = 50.0;
float SIZE_LARGE = 80.0;
integer COMMAND_CHANNEL = -15700;
integer SOUND_CHANNEL = -15780;


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
    if ((g_iVerbose && bool)) {
        if (g_iSoundAvail) llWhisper(0,(g_sTitle + " - File(s) found in inventory: Yes"));
        else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
        if ((!g_iSound)) llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
        if ((g_iSound && g_iSoundAvail)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
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
//0.31 - 03Feb2014

RegisterExtension(integer link){
    string sId = ((getGroup(LINKSETID) + ";") + g_sScriptName);
    if ((g_iSound && g_iSoundAvail)) llMessageLinked(link,SOUND_CHANNEL,"1",((key)sId));
    else  llMessageLinked(link,SOUND_CHANNEL,"0",((key)sId));
}


MasterCommand(integer iChan,string sVal){
    if ((iChan == COMMAND_CHANNEL)) {
        if (("register" == sVal)) RegisterExtension(g_iType);
        else  if (("verbose" == sVal)) {
            (g_iVerbose = TRUE);
            InfoLines(FALSE);
        }
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
        (g_iSoundNFilesAvail = 0);
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
                        (g_iSoundNFilesAvail++);
                    }
                }
                else  {
                    (lFileAvail += TRUE);
                    (g_iSoundNFilesAvail++);
                }
            }
        }
        if ((0 == llListFindList(lFileAvail,[TRUE]))) (g_iSoundFileStartAvail = TRUE);
        else  (g_iSoundFileStartAvail = FALSE);
        if ((ERR_GENERIC != llListFindList(llList2List(lFileAvail,1,(iNFiles - 1)),[TRUE]))) (g_iSoundAvail = TRUE);
        else  (g_iSoundAvail = FALSE);
        return sCurrentFile;
    }
    else  {
        (g_iSoundAvail = FALSE);
        return "0";
    }
}


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

selectStuff(float fMsg){
    Debug(("selectStuff: " + ((string)fMsg)));
    if ((fMsg <= SIZE_SMALL)) {
        (g_sCurrentSoundFile = g_sSoundFileSmall);
    }
    else  if (((fMsg > SIZE_SMALL) && (fMsg < SIZE_MEDIUM))) {
        (g_sCurrentSoundFile = g_sSoundFileMedium1);
    }
    else  if (((fMsg >= SIZE_MEDIUM) && (fMsg < SIZE_LARGE))) {
        (g_sCurrentSoundFile = g_sSoundFileMedium2);
    }
    else  if (((fMsg >= SIZE_LARGE) && (fMsg <= 100))) {
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
        (g_sCurrentSoundFile = CheckForFiles(g_iSoundNFiles,g_lSoundFileList,g_iPermCheck,g_sCurrentSoundFile));
        llSleep(1);
        RegisterExtension(g_iType);
        InfoLines(TRUE);
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
            (g_sCurrentSoundFile = CheckForFiles(g_iSoundNFiles,g_lSoundFileList,g_iPermCheck,g_sCurrentSoundFile));
            llSleep(1);
            RegisterExtension(g_iType);
            InfoLines(TRUE);
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
        if ((((((float)sMsg) == g_fSoundVolumeCur) && ((sVal == g_sSize) || ("" == sVal))) || ("-1" == sVal))) return;
        Debug("work on link_message");
        (g_fSoundVolumeNew = ((float)sMsg));
        if (((((0 == g_fSoundVolumeNew) && (sVal != g_sSize)) && ("" != sVal)) && ("0" != sVal))) {
            if ((g_iSoundNFilesAvail > 1)) selectStuff(((float)sVal));
            llPreloadSound(g_sCurrentSoundFile);
            Debug("change while off");
            return;
        }
        if (((g_fSoundVolumeNew > 0) && (g_fSoundVolumeNew <= 1))) {
            llSetTimerEvent(0.0);
            if ((("" == sVal) || (sVal == g_sSize))) {
                if ((g_fSoundVolumeCur > 0)) {
                    llAdjustSoundVolume(g_fSoundVolumeNew);
                    if (g_iVerbose) llWhisper(0,"(v) Sound range for fire has changed");
                }
                else  {
                    llPreloadSound(g_sCurrentSoundFile);
                    llSleep(2.0);
                    llLoopSound(g_sCurrentSoundFile,g_fSoundVolumeNew);
                    if (g_iVerbose) llWhisper(0,"(v) The fire starts to make some noise");
                }
            }
            else  {
                string sCurrentSoundFileTemp = g_sCurrentSoundFile;
                if ((g_iSoundNFilesAvail > 1)) selectStuff(((float)sVal));
                if ((g_sCurrentSoundFile == sCurrentSoundFileTemp)) {
                    llAdjustSoundVolume(g_fSoundVolumeNew);
                    if (g_iVerbose) llWhisper(0,"(v) Sound range for fire has changed");
                }
                else  {
                    if ((g_iVerbose && ("0" != g_sSize))) llWhisper(0,"(v) The fire changes it's sound");
                    Debug(("play sound: " + g_sCurrentSoundFile));
                    llPreloadSound(g_sCurrentSoundFile);
                    llStopSound();
                    llLoopSound(g_sCurrentSoundFile,g_fSoundVolumeNew);
                }
            }
            (g_fSoundVolumeCur = g_fSoundVolumeNew);
        }
        else  llSetTimerEvent(1.2);
    }



	timer() {
        llStopSound();
        if (g_iVerbose) llWhisper(0,"(v) Noise from fire ended");
        (g_fSoundVolumeNew = (g_fSoundVolumeCur = 0.0));
        llSetTimerEvent(0.0);
    }
}
