///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire by Zopf Resident - Ray Zopf (Raz)
//
//28. Jan. 2014
//v0.72
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
///////////////////////////////////////////////////////////////////////////////////////////////////



//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
integer g_iSound = TRUE;			// Sound on/off in this prim
integer g_iVerbose = TRUE;

string g_sSoundFileStart 	= "75145__willc2-45220__struck-match-8b-22k-1-65s";   	// starting fire (somehow special sound!)
string g_sSoundFileSmall 	= "17742__krisboruff__fire-crackles-no-room";            	// sound for small fire
string g_sSoundFileMedium1 = "104958__glaneur-de-sons__petit-feu-little-fire-2";    	// first sound for medium fire (yes, file fire-2)
string g_sSoundFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1";    	// second sound for medium fire
string g_sSoundFileFull 	= "4211__dobroide__fire-crackling";                   	// standard sound, sound for big fire

integer g_iSoundNFiles = 5;
//starting sound has to be first in list
list g_lSoundFileList = [g_sSoundFileStart, g_sSoundFileSmall, g_sSoundFileMedium1, g_sSoundFileMedium2, g_sSoundFileFull];
string g_sCurrentSoundFile = g_sSoundFileMedium2;							// standard sound - must not be sound for starting fire!


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSound";     // title
string g_sVersion = "0.72";       // version
string g_sScriptName;

integer g_iSoundAvail = FALSE;
list g_lSoundFileAvail = [];
integer g_iSoundFileStartAvail = TRUE;
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeNew;
string g_sSize = "0";

//RealFire MESSAGE MAP
integer COMMAND_CHANNEL = -15700;
integer SOUND_CHANNEL = -15789;  // smoke channel


//===============================================
//LSLForge MODULES
//===============================================
$import Debug.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName);
$import PrintStatusInfo.lslm(m_iVerbose=g_iVerbose, m_iAvail=g_iSoundAvail, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iOn=g_iSound, m_sVersion=g_sVersion);
$import getGroup.lslm();
$import RegisterExtension.lslm(m_iOn=g_iSound, m_iComplete=g_iSoundAvail, channel=SOUND_CHANNEL, m_sScriptName=g_sScriptName);


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

CheckSoundFiles()
{
	integer iSoundNumber = llGetInventoryNumber(INVENTORY_SOUND);
	Debug("Sound number = " +(string)iSoundNumber);
	if ( iSoundNumber > 0) {
		g_lSoundFileAvail = [];
		list lSoundList = [];
		integer i;
		for (i = 0; i < iSoundNumber; ++i) { //assuming there are no other sound sources (scripts) with sound files in this prim!
			lSoundList += llGetInventoryName(INVENTORY_SOUND, i);
		}
		for (i = 0; i < g_iSoundNFiles; ++i) {
			list lSoundCompare = llList2List(g_lSoundFileList, i, i);
			if (ERR_GENERIC == llListFindList(lSoundList, lSoundCompare)) {
				g_lSoundFileAvail += FALSE;
				if (0 < i && (string)lSoundCompare == g_sCurrentSoundFile && 2 < g_iSoundNFiles) {
					integer g_iSoundFileNAvail = llGetListLength(g_lSoundFileAvail);
					if (g_iSoundNFiles > g_iSoundFileNAvail) g_sCurrentSoundFile = (string)llList2List(g_lSoundFileList, i+1, i+1);
						else {
							list lSoundFileAvailTmp = llList2List(g_lSoundFileAvail, 1, g_iSoundNFiles-1);
							integer j = llListFindList(lSoundFileAvailTmp, [TRUE]);
							if (0 <= j) g_sCurrentSoundFile = (string)llList2List(lSoundFileAvailTmp, j, j);
						}
				}
				llWhisper(0, g_sTitle+" - Sound not found in inventory: " + (string)lSoundCompare);
			} else g_lSoundFileAvail += TRUE;
		}
		if (0 == llListFindList(g_lSoundFileAvail, [TRUE])) g_iSoundFileStartAvail = TRUE;
			else g_iSoundFileStartAvail = FALSE;
		if (ERR_GENERIC != llListFindList(llList2List(g_lSoundFileAvail, 1, g_iSoundNFiles-1), [TRUE])) g_iSoundAvail = TRUE;
			else g_iSoundAvail = FALSE;
	} else g_iSoundAvail = FALSE;
}


SelectSound(float fMsg)
{
	Debug("SelectSound: "+(string)fMsg);
	if (fMsg <= 25) {
			g_sCurrentSoundFile = g_sSoundFileSmall;
	} else if (fMsg > 25 && fMsg <= 50) {
		g_sCurrentSoundFile = g_sSoundFileMedium1;
	} else if (fMsg > 50 && fMsg < 80) {
			g_sCurrentSoundFile = g_sSoundFileMedium2;
	} else if (fMsg >= 80 && fMsg <= 100) {
			g_sCurrentSoundFile = g_sSoundFileFull;
	} else {
		Debug("start if g_fSoundVolumeNew > 0: -"+(string)g_fSoundVolumeNew+"-");
		if (g_fSoundVolumeNew > 0 && TRUE == g_iSoundFileStartAvail) {
			integer n;
			for (n = 0; n < 3; ++n) { //let sound appear louder
				llTriggerSound(g_sSoundFileStart, g_fSoundVolumeNew); //preloaded on touch
			}
		// to let the sound play additionally to looping ones and without getting stoped
		}
		g_sSize = "0";
		return;
	}
	g_sSize = (string)fMsg;
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default
{
    state_entry()
    {
		g_sScriptName = llGetScriptName();
		Debug("state_entry");
        llStopSound();
		CheckSoundFiles();
		llSleep(1);
		RegisterExtension(LINK_SET);
		InfoLines();
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }
	
	touch(integer total_number)
    {
		// if (g_iSoundAvail && g_iSound) llPreloadSound(g_sSoundFileMedium1); //maybe change preloaded soundfile to medium fire sound
		//this also blocks touch events on this child to be passed to root prim! only works if child prim is touched
    }
	
	changed(integer change)
    {
		if (change & CHANGED_INVENTORY) {
			llWhisper(0, "Inventory changed, checking sound samples...");
			llStopSound();
			CheckSoundFiles();
			llSleep(1);
			RegisterExtension(LINK_SET);
			InfoLines();
		}
    }

	
//listen for linked messages from Fire (main) script
//-----------------------------------------------
    link_message(integer iSender, integer iChan, string sSoundSet, key kId)
    {
		Debug("link_message = channel " + (string)iChan + "; sSoundSet " + sSoundSet + "; kId " + (string)kId);		
		if (iChan == COMMAND_CHANNEL) RegisterExtension(LINK_SET);

		list lKeys = llParseString2List((string)kId, [","], []);
        string sGroup = llList2String(lKeys, 0);
		string sScriptName = llList2String(lKeys, 1);
		if (getGroup() != sGroup || "Default" != sGroup || "Default" != getGroup()) return;
        if (iChan != SOUND_CHANNEL || !g_iSound || !g_iSoundAvail || llSubStringIndex(llToLower((string)sScriptName), "sound")  >= 0) return; //sound scripts need to have sound in their name, so that we can discard those messages!
		list lParams = llParseString2List(sSoundSet, [","], []);
        string sVal = llList2String(lParams, 0);
        string sMsg = llList2String(lParams, 1);
		
		Debug("no changes? background? "+sVal+"-"+sMsg+"...g_fSoundVolumeCur="+(string)g_fSoundVolumeCur+"-g_sSize="+g_sSize);
		if (((float)sVal == g_fSoundVolumeCur && (sMsg == g_sSize || "" == sMsg)) || "-1" == sMsg) return; //-1 for background sound script
		Debug("work on link_message");
		
		g_fSoundVolumeNew = (float)sVal;
		//change sound while sound is off
		if (0 == g_fSoundVolumeNew && sMsg != g_sSize && "" != sMsg && "0" != sMsg) {
			SelectSound((float)sMsg);
			Debug("change while off");
			return;
		}
		if (g_fSoundVolumeNew > 0 && g_fSoundVolumeNew <= 1) {
			if ("" == sMsg || sMsg == g_sSize) {
				if (g_fSoundVolumeCur > 0) {
					llAdjustSoundVolume(g_fSoundVolumeNew);
					if (g_iVerbose) llWhisper(0, "Fire changes it's volume level");
				} else {
					llLoopSound(g_sCurrentSoundFile, g_fSoundVolumeNew);
					if (g_iVerbose) llWhisper(0, "The fire starts to make some noise");
				}
				g_fSoundVolumeCur = g_fSoundVolumeNew;
				return;
			}

			string sCurrentSoundFileTemp = g_sCurrentSoundFile;
			SelectSound((float)sMsg);
			if ("110" == sMsg || g_sCurrentSoundFile == sCurrentSoundFileTemp) return;
			if (g_iVerbose && "0" != g_sSize) llWhisper(0, "The fire changes it's sound");
			Debug("play sound: "+g_sCurrentSoundFile);
			
			llPreloadSound(g_sCurrentSoundFile);
			g_fSoundVolumeCur = g_fSoundVolumeNew;
			llStopSound();
			llLoopSound(g_sCurrentSoundFile, g_fSoundVolumeNew);
		} else {
				llSleep(1);
				llStopSound();
				if (g_iVerbose) llWhisper(0, "Noise from fire ended");
				g_fSoundVolumeNew =g_fSoundVolumeCur = 0.0;
				g_sSize = "0";
			}
    }
    
//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}