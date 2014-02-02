// LSL script generated: RealFire-Rene10957.LSL.P-Anim_Object.lslp Sun Feb  2 17:10:11 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//PrimFire rezzed object script
// by Zopf Resident - Ray Zopf (Raz)
//
//01. Feb. 2014
//v0.2
//

//Files:
// P-Anim_Object.lsl
//
// Fire.lsl
// P-Anim.lsl
// config
// User Manual
//
//
//Prequisites: Fireobjects need to be in same prim as P-Anim.lsl
//Notecard format: see config NC
//basic help: User Manual
//
//Changelog
//

//bug: ---

//todo: additional script to animate/change fire prim textures
//todo: fire objects need to be phantom... maybe make them flexiprim too
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode = FALSE;


//user changeable variables
//-----------------------------------------------
//integer g_iVerbose = TRUE;

//string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;


//internal variables
//-----------------------------------------------
//string g_sTitle = "RealPrimFire-Object";     // title
//string g_sVersion = "0.2";       // version
string g_sScriptName;
integer g_iType = LINK_SET;

integer g_iLowprim = FALSE;
key g_kOwner;
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


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

/*SelectPrimFire(float fMsg)
{
	Debug("SelectPrimFire: "+(string)fMsg);
	if (fMsg <= 25) {
			g_sCurrentPrimFireFile = g_sPrimFireFileSmall;
	} else if (fMsg > 25 && fMsg <= 50) {
		g_sCurrentPrimFireFile = g_sPrimFireFileMedium1;
	} else if (fMsg > 50 && fMsg < 80) {
			g_sCurrentPrimFireFile = g_sPrimFireFileMedium1;
	} else if (fMsg >= 80 && fMsg <= 100) {
			g_sCurrentPrimFireFile = g_sPrimFireFileFull;
	} else {
		//Debug("start if g_fSoundVolumeNew > 0: -"+(string)g_fSoundVolumeNew+"-");
		//if (g_fSoundVolumeNew > 0 && TRUE == g_iSoundFileStartAvail) {
		//	integer n;
		//	for (n = 0; n < 3; ++n) { //let sound appear louder
		//		llTriggerSound(g_sSoundFileStart, g_fSoundVolumeNew); //preloaded on touch
		//	}
		// to let the sound play additionally to looping ones and without getting stoped
		//}
		g_sSize = "0";
		return;
	}
	g_sSize = (string)fMsg;
}*/


//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        (g_kOwner = llGetOwner());
        Debug("state_entry");
        llSetPrimitiveParams([PRIM_TEMP_ON_REZ,FALSE,PRIM_PHANTOM,TRUE]);
        llListen(PRIMCOMMAND_CHANNEL,"",NULL_KEY,"");
        llOwnerSay("Wait, if you want to make object temp - else react within next 10 seconds");
        llSleep(10.0);
        llSetPrimitiveParams([PRIM_TEMP_ON_REZ,TRUE]);
        (g_iLowprim = TRUE);
        llOwnerSay("Now, object is temp and will vanish shortly");
    }


	/*changed(integer change)
	{
		if (change & CHANGED_OWNER) {
			llResetScript();
	}
	}*/

	on_rez(integer start_param) {
        Debug(("on_rez: " + ((string)start_param)));
        if ((0 == start_param)) {
            llSetLinkPrimitiveParamsFast(g_iType,[PRIM_TEMP_ON_REZ,FALSE]);
            integer g_iLowprim = TRUE;
        }
        (g_kOwner = llGetOwner());
    }


//listen for messages from PrimFire script
//-----------------------------------------------
	listen(integer iChan,string name,key kId,string sSet) {
        Debug(("listen: " + sSet));
        if ((llGetOwnerKey(kId) != g_kOwner)) return;
        if (("toggle" == sSet)) {
            (g_iLowprim = (!g_iLowprim));
            Debug(("listen - toggle:" + ((string)g_iLowprim)));
            if (g_iLowprim) llSetLinkPrimitiveParamsFast(g_iType,[PRIM_TEMP_ON_REZ,TRUE]);
            else  llSetLinkPrimitiveParamsFast(g_iType,[PRIM_TEMP_ON_REZ,FALSE]);
        }
        else  if (("die" == sSet)) llDie();
    }
}
