///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire by Zopf Resident - Ray Zopf (Raz)
//
//14. Dec. 2013
//v0.31
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
//

//bug: soundpreload on touch is useless in child prim

//todo: decide if touch event should really block touch on child prim and how to preload sound
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//FIRESTORM SPECIFIC DEBUG STUFF
//===============================================

//#define FSDEBUG
//#include "fs_debug.lsl"



//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode=TRUE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
integer g_iSound = TRUE;			// Sound on/off in this prim
integer g_iVerbose = TRUE;

string g_sSoundFileSmall ="17742__krisboruff__fire-crackles-no-room";                   // sound for small fire
string g_sSoundFileMedium1 = "104958__glaneur-de-sons__petit-feu-little-fire-2";                   // first sound for medium fire (yes, file fire-2); gets preloaded with every touch and played first on every ignition
string g_sSoundFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1";                   // second sound for medium fire
string g_sSoundFileFull = "4211__dobroide__fire-crackling";                   // standard sound, sound for big fire

string g_sCurrentSoundFile = g_sSoundFileMedium2;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSound";     // title
string g_sVersion = "0.31";       // version
string g_sScriptName;

integer g_iSoundAvail = FALSE;
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeNew;
string g_sSize;

// Constants
integer SOUND_CHANNEL = -10956;  // smoke channel


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

//===============================================================================
//= parameters   :    string    sMsg    message string received
//=
//= return        :    none
//=
//= description  :    output debug messages
//=
//===============================================================================

Debug(string sMsg)
{
    if (!g_iDebugMode) return;
    llOwnerSay("DEBUG: "+ g_sScriptName + ": " + sMsg);
}

CheckSoundFiles()
{
	integer iSoundNumber = llGetInventoryNumber(INVENTORY_SOUND);
	Debug("Sound number = " +(string)iSoundNumber);
	if ( iSoundNumber > 0) {
		integer i;
		for (i = 0; i < iSoundNumber; ++i) {
			string sSoundName = llGetInventoryName(INVENTORY_SOUND, i);
			if (sSoundName == g_sSoundFileFull || sSoundName == g_sSoundFileMedium1 || sSoundName == g_sSoundFileMedium2 || sSoundName == g_sSoundFileSmall)
			g_iSoundAvail = TRUE;
		}
	} else g_iSoundAvail = FALSE;
}


SelectSound(string sMsg)
{
	if ("small" == sMsg) {
			g_sCurrentSoundFile = g_sSoundFileSmall;
	} else if ("medium1" == sMsg) {
		g_sCurrentSoundFile = g_sSoundFileMedium1;
	} else if ("medium2" == sMsg) {
			g_sCurrentSoundFile = g_sSoundFileMedium2;
	} else if ("full" == sMsg) {
			g_sCurrentSoundFile = g_sSoundFileFull;
	} else {
		Debug("start if g_fSoundVolumeNew > 0: -"+(string)g_fSoundVolumeNew+"-");
		if (g_fSoundVolumeNew > 0) llPlaySound(g_sSoundFileMedium1, g_fSoundVolumeNew); //preloaded on touch
		g_sSize = "start";
		return;
	}
	g_sSize = sMsg;
}

InfoLines()
{
	if (g_iSound && g_iSoundAvail) llWhisper(0, g_sTitle + " " + g_sVersion + " ready");
			else llWhisper(0, g_sTitle + " " + g_sVersion + " not ready");
	if (g_iVerbose) {
		if (g_iSoundAvail) llWhisper(0, "Sound object in inventory found: Yes");
            else llWhisper(0, "All Sound objects in inventory found: No");
		if (!g_iSound) llWhisper(0, "Sound script disabled");
    }
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
		if (g_iSound && g_iSoundAvail) llMessageLinked(LINK_SET, SOUND_CHANNEL, "1", (key)g_sScriptName);
			else llMessageLinked(LINK_SET, SOUND_CHANNEL, "0", (key)g_sScriptName);
		InfoLines();
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }
	
	touch(integer total_number)
    {
		if (g_iSoundAvail && g_iSound) llPreloadSound(g_sSoundFileMedium1); //maybe change preloaded soundfile to medium fire sound
		//this also blocks touch events on this child to be passed to root prim!
    }
	
	changed(integer change)
    {
		if (change & CHANGED_INVENTORY) {
			llWhisper(0, "Inventory changed, checking sound samples...");
			llStopSound();
			CheckSoundFiles();
			llSleep(1);
			if (g_iSound && g_iSoundAvail) llMessageLinked(LINK_SET, SOUND_CHANNEL, "1", (key)g_sScriptName);
				else llMessageLinked(LINK_SET, SOUND_CHANNEL, "0", (key)g_sScriptName);
			InfoLines();
		}
    }

	
//listen for linked messages from Fire (main) script
//-----------------------------------------------
    link_message(integer iSender, integer iChan, string sSoundSet, key kId)
    {
		Debug("link_message = channel " + (string)iChan + "; sSoundSet " + sSoundSet + "; kId " + (string)kId);
		
        if (iChan != SOUND_CHANNEL || !g_iSound || !g_iSoundAvail || (string)kId == g_sScriptName) return;
		list lParams = llParseString2List(sSoundSet, [","], []);
        string sVal = llList2String(lParams, 0);
        string sMsg = llList2String(lParams, 1);
		
		Debug("no changes? "+sVal+"-"+sMsg+"...g_fSoundVolumeCur="+(string)g_fSoundVolumeCur+"-g_sSize="+g_sSize);
		if ((float)sVal == g_fSoundVolumeCur && (sMsg == g_sSize || "" == sMsg)) return;
		Debug("work on link_message");
		
		g_fSoundVolumeNew = (float)sVal;
		//change sound while sound is off
		if (0 == g_fSoundVolumeNew && sMsg != g_sSize && "" != sMsg) {
			SelectSound(sMsg);
			Debug("change while off");
			return;
		}
		if (g_fSoundVolumeNew > 0 && g_fSoundVolumeNew <= 1) {
			if ("" == sMsg || sMsg == g_sSize) {
				Debug("Vol-adjust");
				if (g_fSoundVolumeCur > 0) llAdjustSoundVolume(g_fSoundVolumeNew);
					else llLoopSound(g_sCurrentSoundFile, g_fSoundVolumeNew);
				g_fSoundVolumeCur = g_fSoundVolumeNew;
				return;
			}

			SelectSound(sMsg);
			if ("start" == g_sSize) return;
			Debug("play sound: "+g_sCurrentSoundFile);
			
			llPreloadSound(g_sCurrentSoundFile);
			g_fSoundVolumeCur = g_fSoundVolumeNew;
			llStopSound();
			llLoopSound(g_sCurrentSoundFile, g_fSoundVolumeNew);
		} else {
				Debug("stop");
				llStopSound();
				g_fSoundVolumeNew =g_fSoundVolumeCur = 0.0;
			}
    }
}