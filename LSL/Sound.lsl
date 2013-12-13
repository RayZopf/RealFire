///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire by Zopf Resident - Ray Zopf (Raz)
//
//13. Dec. 2013
//v0.1
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

//bug: ---

//todo: ---
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
string g_sSoundFileSmall ="17742__krisboruff__fire-crackles-no-room";                   // sound for small fire
string g_sSoundFileMedium1 = "104958__glaneur-de-sons__petit-feu-little-fire-2";                   // first sound for medium fire (yes, file fire-2); gets preloaded with every touch and played first on every ignition
string g_sSoundFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1";                   // second sound for medium fire
string g_sSoundFileFull = "4211__dobroide__fire-crackling";                   // standard sound, sound for big fire

string g_sCurrentSoundFile = g_sSoundFileMedium2;



//internal variables
//-----------------------------------------------
string g_sTitle = "RealSound";     // title
string g_sVersion = "0.1";       // version

g_iSoundAvail
g_iSoundOn

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
    llOwnerSay("DEBUG: "+ llGetScriptName() + ": " + sMsg);
}

InfoLines()
{
	if (g_iVerbose) {
        llWhisper(0, "Switch access:" + showAccess(g_iSwitchAccess));
        llWhisper(0, "Menu access:" + showAccess(g_iMenuAccess));
		if (g_iSoundAvail) llWhisper(0, "Sound object in inventory found: Yes");
            else llWhisper(0, "All Sound objects in inventory found: No");
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
        llStopSound();
		//no llSleep because there is nothing to do
        Debug("state_entry");
		llWhisper(0, g_sTitle + " " + g_sVersion + " ready");
		CheckSoundFiles();
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }
	
	touch(integer total_number)
    {
        llResetTime();
		if (g_iSoundAvail && g_iSoundOn) llPreloadSound(g_sSoundFileMedium1); //maybe change preloaded soundfile to medium fire sound
    }
	
	changed(integer change)
    {
		if (change & CHANGED_INVENTORY) {
			CheckSoundFiles();
			llWhisper(0, "Inventory changed, reloading notecard...");
			loadNotecard();
		}
    }
		changed(integer change)
    {
		if (change & CHANGED_INVENTORY) {
			llMessageLinked(LINK_ALL_OTHERS, SMOKE_CHANNEL, (string)g_iSmoke, "");
			llWhisper(0, g_sTitle + " " + g_sVersion + " ready");
		}
    }
	
//listen for linked messages from Fire (main) script
//-----------------------------------------------
    link_message(integer iSender, integer iChan, string sMsg, key kId)
    {
		Debug("link_message = channel " + (string)iNumber + "; sMsg " + sMsg + "; kId " + (string)kId);
        if (iChan != SOUND_CHANNEL) return;
		
        if ((integer)sMsg > 0 && (integer)sMsg <= 100) {
			
		} 
    }
}