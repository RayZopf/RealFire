///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire by Zopf Resident - Ray Zopf (Raz)
//
//15. Dec. 2013
//v0.2
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)

//Files:
//B-Sound.lsl
//
//Fire.lsl
//config
//User Manual
//
//
//Prequisites: Soundfile need to be in same prim as B-Sound.lsl;
//	for fastest start, keep in prim that get's touched at start
//Notecard format: see config NC
//basic help: User Manual

//Changelog
//

//bug: soundpreload on touch is useless in child prim

//todo: decide if touch event should really block touch on child prim and how to preload sound
//todo: simplify to use only one sound file as backround noise (at half the normal volume)
//todo: sMsg has to be changed in Fire.lsl
//todo: make sounds from different prims asynchronus
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

string g_sBackrSoundFile ="17742__krisboruff__fire-crackles-no-room";                   // backroundsound for small fire


//internal variables
//-----------------------------------------------
string g_sTitle = "RealB-Sound";     // title
string g_sVersion = "0.2";       // version
string g_sScriptName;

integer g_iSoundAvail = FALSE;
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeNew;
string g_sSize;
float g_fFactor;

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
			if (sSoundName == g_sBackrSoundFile) g_iSoundAvail = TRUE;
		}
	} else g_iSoundAvail = FALSE;
}


InfoLines()
{
	if (g_iSound && g_iSoundAvail) llWhisper(0, g_sTitle + " " + g_sVersion + " ready");
			else llWhisper(0, g_sTitle + " " + g_sVersion + " not ready");
	if (g_iVerbose) {
		if (g_iSoundAvail) llWhisper(0, "Sound object in inventory found: Yes");
            else llWhisper(0, "All Sound objects in inventory found: No");
		if (!g_iSound) llWhisper(0, g_sTitle+"Sound script disabled");
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
		llPassTouches(TRUE);
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
	
	touch_start(integer total_number)
    {
		if (g_iSoundAvail && g_iSound) llPreloadSound(g_sBackrSoundFile); //maybe change preloaded soundfile to medium fire sound
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
		
        if (iChan != SOUND_CHANNEL || !g_iSound || !g_iSoundAvail || llSubStringIndex(llToLower((string)kId), "sound") >= 0) return; //sound scripts need to have sound in their name, so that we can discard those messages!
		list lParams = llParseString2List(sSoundSet, [","], []);
        string sVal = llList2String(lParams, 0);
		string sMsg = llList2String(lParams, 1);
		
		Debug("no changes? backround on/off? "+sVal+"-"+sMsg+"...g_fSoundVolumeCur="+(string)g_fSoundVolumeCur+"-g_sSize="+g_sSize);
		if ((float)sVal == g_fSoundVolumeCur && (sMsg == g_sSize || "" == sMsg)) return; //no "backround sound off" currently
		Debug("work on link_message");
		
		g_fSoundVolumeNew = (float)sVal;
		if (g_fSoundVolumeNew > 0 && g_fSoundVolumeNew <= 1 && ) { //background sound on/volume adjust
			g_fFactor = 3/4;  //simple adjustment to different fire sizes (full, at start, when special B_Sound message with sMsg = -1)
			if ("-1" == sMsg) g_fFactor = 1.0;
				else if ("" != sMsg && (float)sMsg < 0.55 ) g_fFactor = 3/5;
					else if (float)g_sSize < 0.55) g_fFactor = 3/5;
			if (g_fSoundVolumeCur > 0) { //sound should already run
				Debug("Vol-adjust");
				llAdjustSoundVolume(g_fSoundVolumeNew*g_fFactor);
			} else {
				Debug("play sound");
			
				//llSleep(2); //better not wait to make sound different in timing, find another way
				llStopSound(); // just in case ...
				llLoopSound(g_sBackrSoundFile, g_fSoundVolumeNew*g_fFactor);
			}
			if ("" != sMsg) g_sSize = sMsg;
			g_fSoundVolumeCur = g_fSoundVolumeNew;
		} else {
			Debug("stop");
			llSleep(4); // wait ... better would be to fade out
			llStopSound();
			llWhisper(0, "Backround noise off");
			g_fSoundVolumeNew =g_fSoundVolumeCur = 0.0;
		}
    }
}