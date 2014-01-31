///////////////////////////////////////////////////////////////////////////////////////////////////
//PrimFire rezzed object script
//
//31. Jan. 2014
//v0.1
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)

//Files:
//P-Anim_Object.lsl
//
//Fire.lsl
//P-Anim.lsl
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

//todo: additional script to animate/change fire prim textures
//todo: fire objects need to be phantom... maybe make them flexiprim too
///////////////////////////////////////////////////////////////////////////////////////////////////



//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
integer g_iVerbose = TRUE;

string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealPrimFire-Object";     // title
string g_sVersion = "0.1";       // version
string g_sScriptName;

integer g_iLowprim = TRUE;
key g_kOwner;                      // object owner

//RealFire MESSAGE MAP
//integer COMMAND_CHANNEL =
//integer ANIM_CHANNEL = primfire/textureanim channel
//integer PRIMCOMMAND_CHANNEL = kill fire prims or make temp prims


//===============================================
//LSLForge MODULES
//===============================================
$import RealFireMessageMap.lslm();
$import Debug.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName);


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


default
{
    state_entry()
    {
    	g_kOwner = llGetOwner();
		g_sScriptName = llGetScriptName();
		Debug("state_entry");
		// Makes the object temporary so the whole 0 prim part works 
        llSetPrimitiveParams([PRIM_TEMP_ON_REZ, TRUE]);
    }

    on_rez(integer start_param)
    {
        if (start_param) llSetPrimitiveParams([PRIM_TEMP_ON_REZ, FALSE]); // If not rezzed by the rezzer this stops temporary so we can edit it 
	        else llListen(PRIMCOMMAND_CHANNEL, "", NULL_KEY, ""); 
    }
	
//listen for messages from PrimFire script
//-----------------------------------------------
    listen(integer iChan, string name, key kId, string sSet) 
    { 
        // Security - check the object belongs to our owner
        if (llGetOwnerKey(kId) != g_kOwner) return;
        if ("toggle" == sSet) {
        	g_iLowprim = !g_iLowprim;
        	if (!g_iLowprim) {
            	state temp;
        	} else llSetPrimitiveParams([PRIM_TEMP_ON_REZ, FALSE]);
        } else if ("die" == sSet) llDie();
//        else if ((integer)sVal > 0 && 100 >= (integer)sVal) {
//        	SelectPrimFire((float)sVal);
//        }
    }

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}



state temp
{
	state_entry()
	{
		llSetPrimitiveParams([PRIM_TEMP_ON_REZ, TRUE]);
		state default; // so that scripts runs, even if temp rez is not done
	}
	
	listen(integer iChan, string name, key kId, string sSet) 
    { 
        // Security - check the object belongs to our owner 
        if (llGetOwnerKey(kId) != g_kOwner) return; 
        if ("toggle" == sSet) {
        	g_iLowprim = g_iLowprim; 
        	if (!g_iLowprim) {
            	llSetPrimitiveParams([PRIM_TEMP_ON_REZ, FALSE]); 
        	} else state temp;
        if ("die" == sSet) llDie();
        }
    }
    
	timer()
	{
		;
	}

//-----------------------------------------------
//END STATE: temp
//-----------------------------------------------
}