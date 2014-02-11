///////////////////////////////////////////////////////////////////////////////////////////////////
//ParticleFire Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//11. Feb. 2014
//v0.33
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)

//Files:
// F-Anim.lsl
//
// Fire.lsl
// config
// User Manual
//
//
//Prequisites: Fireobjects need to be in same prim as P-Anim.lsl
//Notecard format: see config NC
//basic help: User Manual
// to use "integer g_iSingleFire = FALSE;      // single fire or multiple fires"
// - put F-Anim.lsl scripts in those prims
// then you may want to play with "integer g_iTextureAnim = TRUE;" and "integer g_iLight = TRUE;"
// and modify "integer g_iTypeXXX = LINK_SET;              // in this case it defines which prim(s) emitts the light and changes texture;"
// values: LINK_THIS (only this prim, if you have more than one particle fire source/script), LINK_SET (all); LINK_ALL_OTHERS, LINK_ROOT LINK_ALL_CHILDREN
// if you want to use a single fire script that is not in the same prim as main Fire.lsl, set singleFire to false in config notecard!

//Changelog
//

//FIXME: on/off via menu sometimes "not working"

//TODO: create a module sizeSelect, put size class borders into variables and settings notecard
///////////////////////////////////////////////////////////////////////////////////////////////////



//===============================================
//GLOBAL VARIABLES
//===============================================

//user changeable variables
//-----------------------------------------------
integer g_iParticleFire; // script on/off
integer g_iType;              // in this case it defines which prim(s) emitts the light and changes texture; values: LINK_THIS (only this prim, if you have more than one particle fire source/script), LINK_SET (all); LINK_ALL_OTHERS, LINK_ROOT LINK_ALL_CHILDREN
integer g_iTextureAnim;
integer g_iTypeTexture;
integer g_iLight;
integer g_iTypeLight;

string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;

// Particle parameters
float g_fAge = 1.0;                // particle lifetime
float g_fRate = 0.1;               // particle burst rate
integer g_iCount = 10;             // particle count
vector g_vStartScale = <0.4, 2, 0>;// particle start size (100%)
vector g_vEndScale = <0.4, 2, 0>;  // particle end size (100%)
float g_fMinSpeed = 0.0;           // particle min. burst speed (100%)
float g_fMaxSpeed = 0.04;          // particle max. burst speed (100%)
float g_fBurstRadius = 0.4;        // particle burst radius (100%)
vector g_vPartAccel = <0, 0, 10>;  // particle accelleration (100%)
vector g_vStartColor = <1, 1, 0>;  // particle start color
vector g_vEndColor = <1, 0, 0>;    // particle end color

//internal variables
//-----------------------------------------------
string g_sTitle = "RealParticleFire";     // title
string g_sVersion = "0.33";       // version
string g_sAuthors = "Zopf";

string g_sType = "anim";

integer g_iParticleFireAvail = TRUE;

string g_sSize = "0";

// Constants
float MAX_COLOR = 1.0;             // max. red, green, blue
float MAX_INTENSITY = 1.0;       // max. light intensity
float MAX_RADIUS = 20.0;         // max. light radius
float MAX_FALLOFF = 2.0;         // max. light falloff

// Variables
vector g_vLightColor;              // light color
float g_fLightIntensity;           // light intensity (changed by burning down)
float g_fLightRadius;              // light radius (changed by burning down)
float g_fLightFalloff;             // light falloff
float g_fStartIntensity;           // start value of lightIntensity (before burning down)
float g_fStartRadius;              // start value of lightRadius (before burning down)


//===============================================
//LSLForge MODULES
//===============================================
$import Debug2.lslm(m_sScriptName=g_sScriptName);
$import MemoryManagement.lslm(m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iVerbose=g_iVerbose);
$import RealFireMessageMap.lslm();
$import GenericFunctions.lslm();
$import PrintStatusInfo.lslm(m_iAvail=g_iParticleFireAvail, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iEnabled=g_iParticleFire, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import ExtensionBasics.lslm(m_sGroup=LINKSETID, m_iSingle=g_iSingleFire, m_iEnabled=g_iParticleFire, m_iAvail=g_iParticleFireAvail, m_iChannel=PARTICLE_CHANNEL, m_sScriptName=g_sScriptName, m_iLinkType=g_iType, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import GroupHandling.lslm(m_sGroup=LINKSETID);


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

initExtension(integer bool)
{
	if (g_iParticleFire) {
		llParticleSystem([]);
		if (g_iTextureAnim) llSetLinkTextureAnim(g_iTypeTexture, FALSE, ALL_SIDES,4,4,0,0,1);
		if (g_iLight) llSetLinkPrimitiveParamsFast(g_iTypeLight, [PRIM_POINT_LIGHT, FALSE, ZERO_VECTOR, 0, 0, 0]);
	}
	g_vDefStartColor.x = checkInt("ColorOn (RED)", (integer)g_vDefStartColor.x, 0, 100);
	g_vDefStartColor.y = checkInt("ColorOn (GREEN)", (integer)g_vDefStartColor.y, 0, 100);
	g_vDefStartColor.z = checkInt("ColorOn (BLUE)", (integer)g_vDefStartColor.z, 0, 100);
	g_vDefEndColor.x = checkInt("ColorOff (RED)", (integer)g_vDefEndColor.x, 0, 100);
	g_vDefEndColor.y = checkInt("ColorOff (GREEN)", (integer)g_vDefEndColor.y, 0, 100);
	g_vDefEndColor.z = checkInt("ColorOff (BLUE)", (integer)g_vDefEndColor.z, 0, 100);

	g_fStartIntensity = percentage(g_iDefIntensity, MAX_INTENSITY);
	g_fStartRadius = percentage(g_iDefRadius, MAX_RADIUS);
	g_fLightFalloff = percentage(g_iDefFalloff, MAX_FALLOFF);

	llSleep(1);
	if (bool) RegisterExtension(g_iType);
	InfoLines(FALSE);
}


//most important function
//-----------------------------------------------
updateSize(float size)
{
	vector vStart;
	vector vEnd;
	float fMin;
	float fMax;
	float fRadius; // also used to indicate PrimFire size
	vector vPush;

	vEnd = g_vEndScale / 100.0 * size;             // end scale
	fMin = g_fMinSpeed / 100.0 * size;             // min. burst speed
	fMax = g_fMaxSpeed / 100.0 * size;             // max. burst speed
	vPush = g_vPartAccel / 100.0 * size;           // accelleration

	if (size > SIZE_SMALL) {
		vStart = g_vStartScale / 100.0 * size;     // start scale
		fRadius = g_fBurstRadius / 100.0 * size;   // burst radius
		if (g_iTextureAnim) {
			if (size >= SIZE_LARGE) llSetLinkTextureAnim(g_iTypeTexture, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,9);
				else if (size >= SIZE_MEDIUM) llSetLinkTextureAnim(g_iTypeTexture, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,6);
					else llSetLinkTextureAnim(g_iTypeTexture, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,4);
		}
	} else {
		if (g_iTextureAnim) {
			if (size >= SIZE_EXTRASMALL) llSetLinkTextureAnim(g_iTypeTexture, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,3);
				else llSetLinkTextureAnim(g_iTypeTexture, ANIM_ON | LOOP, ALL_SIDES,4,4,0,0,1);
		}
		vStart = g_vStartScale / 4.0;              // start scale
		fRadius = g_fBurstRadius / 4.0;            // burst radius
		if (size < SIZE_TINY) {
			vStart.y = g_vStartScale.y / 100.0 * size * 5.0;
			if (vStart.y < 0.25) vStart.y = 0.25;
		}
		if (g_iLight) {
			if (g_iChangeLight) {
				g_fLightIntensity = percentage(size * 4.0, g_fStartIntensity);
				g_fLightRadius = percentage(size * 4.0, g_fStartRadius);
			} else {
				g_fLightIntensity = g_fStartIntensity;
				g_fLightRadius = g_fStartRadius;
			}
		}
	}
	updateColor();

	updateParticles(vStart, vEnd, fMin, fMax, fRadius, vPush);
	if (g_iLight) llSetLinkPrimitiveParamsFast(g_iTypeLight, [PRIM_POINT_LIGHT, TRUE, g_vLightColor, g_fLightIntensity, g_fLightRadius, g_fLightFalloff]);
	if (debug) Debug((string)llRound(size) + "% " + (string)vStart + " " + (string)vEnd, TRUE, FALSE);
}

// pragma inline
updateColor()
{
	g_vStartColor.x = percentage((float)g_iPerRedStart, MAX_COLOR);
	g_vStartColor.y = percentage((float)g_iPerGreenStart, MAX_COLOR);
	g_vStartColor.z = percentage((float)g_iPerBlueStart, MAX_COLOR);

	g_vEndColor.x = percentage((float)g_iPerRedEnd, MAX_COLOR);
	g_vEndColor.y = percentage((float)g_iPerGreenEnd, MAX_COLOR);
	g_vEndColor.z = percentage((float)g_iPerBlueEnd, MAX_COLOR);

	g_vLightColor = (g_vStartColor + g_vEndColor) / 2.0; //light color = average of start & end color
}


// pragma inline
updateParticles(vector vStart, vector vEnd, float fMin, float fMax, float fRadius, vector vPush)
{
	llSleep(0.8); // give other effects some time to start - also delays updating colour
	llParticleSystem ([
	//System Behavior
		PSYS_PART_FLAGS,
			0 |
			//PSYS_PART_BOUNCE_MASK |
			PSYS_PART_EMISSIVE_MASK |
			//PSYS_PART_FOLLOW_SRC_MASK |
			//PSYS_PART_FOLLOW_VELOCITY_MASK |
			PSYS_PART_INTERP_COLOR_MASK |
			PSYS_PART_INTERP_SCALE_MASK, // |
			//PSYS_PART_RIBBON_MASK |
			//PSYS_PART_TARGET_LINEAR_MASK |
			//PSYS_PART_TARGET_POS_MASK |
			////PSYS_PART_WIND_MASK,
	//System Presentation
		PSYS_SRC_PATTERN,
			PSYS_SRC_PATTERN_EXPLODE, //|
			//PSYS_SRC_PATTERN_ANGLE_CONE |
			//PSYS_SRC_PATTERN_ANGLE |
			////PSYS_SRC_PATTERN_DROP,
		PSYS_SRC_BURST_RADIUS, fRadius,
		//PSYS_SRC_ANGLE_BEGIN, float,
		//PSYS_SRC_ANGLE_END, float,
		//PSYS_SRC_TARGET_KEY, key,
	//Particle Appearance
		PSYS_PART_START_COLOR, g_vStartColor,
		PSYS_PART_END_COLOR, g_vEndColor,
		PSYS_PART_START_ALPHA, 1.0,
		PSYS_PART_END_ALPHA, 0.0,
		PSYS_PART_START_SCALE, vStart,
		PSYS_PART_END_SCALE, vEnd,
		//PSYS_SRC_TEXTURE, string,
		//PSYS_PART_START_GLOW, float,
		//PSYS_PART_END_GLOW, float,
	//Particle Blending
	//Particle Flow
		//PSYS_SRC_MAX_AGE, float,
		PSYS_PART_MAX_AGE, g_fAge,
		PSYS_SRC_BURST_RATE, g_fRate,
		PSYS_SRC_BURST_PART_COUNT, g_iCount,
	//Particle Motion
		PSYS_SRC_ACCEL, vPush,
		//PSYS_SRC_OMEGA, vector,
		PSYS_SRC_BURST_SPEED_MIN, fMin,
		PSYS_SRC_BURST_SPEED_MAX, fMax
	]);
}


specialFire()
{
	if (debug) Debug("specialFire", FALSE, FALSE);
	//particles to start fire with
	llParticleSystem ([
	//System Behavior
		PSYS_PART_FLAGS,
			0 |
			//PSYS_PART_BOUNCE_MASK |
			PSYS_PART_EMISSIVE_MASK |
			//PSYS_PART_FOLLOW_SRC_MASK |
			//PSYS_PART_FOLLOW_VELOCITY_MASK |
			PSYS_PART_INTERP_COLOR_MASK |
			PSYS_PART_INTERP_SCALE_MASK, // |
			//PSYS_PART_RIBBON_MASK |
			//PSYS_PART_TARGET_LINEAR_MASK |
			//PSYS_PART_TARGET_POS_MASK |
			////PSYS_PART_WIND_MASK,
	//System Presentation
		PSYS_SRC_PATTERN,
			PSYS_SRC_PATTERN_EXPLODE, //|
			//PSYS_SRC_PATTERN_ANGLE_CONE |
			//PSYS_SRC_PATTERN_ANGLE |
			////PSYS_SRC_PATTERN_DROP,
		PSYS_SRC_BURST_RADIUS, 0.148438,
		//PSYS_SRC_ANGLE_BEGIN, float,
		//PSYS_SRC_ANGLE_END, float,
		//PSYS_SRC_TARGET_KEY, key,
	//Particle Appearance
		PSYS_PART_START_COLOR, <0.74902,0.6,0.14902>,
		PSYS_PART_END_COLOR, <1,0.2,0>,
		PSYS_PART_START_ALPHA, 0.101961,
		PSYS_PART_END_ALPHA, 0.0705882,
		PSYS_PART_START_SCALE, <0.59375,0.59375,0>,
		PSYS_PART_END_SCALE, <0.09375,0.09375,0>,
		PSYS_SRC_TEXTURE, (key)"23d133ad-c669-18a8-02a3-a75baa9b214a",
		//PSYS_PART_START_GLOW, float,
		//PSYS_PART_END_GLOW, float,
	//Particle Blending
	//Particle Flow
//		PSYS_SRC_MAX_AGE, 2.8, // do not use - is buggy and does not work well when fire is switched off
		PSYS_PART_MAX_AGE, 3.0,
		PSYS_SRC_BURST_RATE, 0.01,
		PSYS_SRC_BURST_PART_COUNT, 1,
	//Particle Motion
		PSYS_SRC_ACCEL, <0,0,0.203125>,
		//PSYS_SRC_OMEGA, vector,
		PSYS_SRC_BURST_SPEED_MIN, 0.0195313,
		PSYS_SRC_BURST_SPEED_MAX, 0.0273438
	]);
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
		//debug=TRUE; // set to TRUE to enable Debug messages
		MESSAGE_MAP();
		g_iParticleFire = TRUE;
		g_iType = LINK_SET;
		g_iTextureAnim = TRUE;
		g_iTypeTexture = LINK_SET;
		g_iLight = TRUE;
		g_iTypeLight = LINK_SET;

		MemRestrict(40000);
		g_sScriptName = llGetScriptName();
		if (debug) Debug("state_entry", TRUE, TRUE);
		if (debug) Debug("Particle count: " + (string)llRound((float)g_iCount * g_fAge / g_fRate), TRUE, FALSE);
		initExtension(TRUE);
	}

	on_rez(integer start_param)
	{
		llResetScript();
	}

	changed(integer change)
	{
		if (change & CHANGED_INVENTORY) {
			if (!silent) llWhisper(PUBLIC_CHANNEL, "Inventory changed, checking objects...");
			initExtension(TRUE);
		}
	}


//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender, integer iChan, string sSet, key kId)
	{
		if (debug) Debug("link_message = channel " + (string)iChan + "; sSet " + sSet + "; kId " + (string)kId, FALSE, FALSE);
		string sConfig = MasterCommand(iChan, sSet, TRUE);
		if ("" != sConfig) {
			integer rc = getConfigParticleFire(sConfig);
			if (1 == rc) initExtension(FALSE); // no recursion - registerExtension+get config lines
				else if (1 <= rc) updateSize((float)g_sSize);
		}

		string sScriptName = GroupCheck(kId);
		if ("exit" == sScriptName) return;
		if (iChan != PARTICLE_CHANNEL || !g_iParticleFire || !g_iParticleFireAvail || (llSubStringIndex(llToLower(sScriptName), g_sType) >= 0)) return; // scripts need to have that identifier in their name, so that we can discard those messages

		list lParams = llParseString2List(sSet, [SEPARATOR], []);
		string sVal = llList2String(lParams, 0);
		string sMsg = llList2String(lParams, 1);
		//if (debug) Debug("no changes? background? "+sVal+"-"+sMsg+"...g_fSoundVolumeCur="+(string)g_fSoundVolumeCur+"-g_sSize="+g_sSize, FALSE, FALSE);
		if (debug) Debug("work on link_message", FALSE ,FALSE);

		if  ("0" == sVal && g_iInTimer) return;

		llSetTimerEvent(0.0);
		g_iInTimer = FALSE;
		if (sVal == g_sSize) {
			return;
		} else if ((integer)sVal > 0 && 100 >= (integer)sVal && "fire" == sMsg) {
			string g_sSizeTemp = g_sSize;

			if ("0" == g_sSizeTemp) { // similar to startSystem() in Fire.lsl
				llSleep(0.7); // let fire slowly begin (not counting on lag when rezzing)
				specialFire();
				g_fLightIntensity = g_fStartIntensity;
				g_fLightRadius = g_fStartRadius;
				llSleep(2.4);
				updateSize((float)sVal);
			} else {
				updateSize((float)sVal);
			}
			g_sSize = sVal;
		} else if ("fire" == sMsg || "" == sMsg) {
			g_iInTimer = TRUE;
			llSetTimerEvent(1.0);
			llSleep(1.3);
			specialFire();
			llSleep(2.9);
		}
	}


	timer()
	{
		if (debug) Debug("timer", FALSE, FALSE);
		if (g_iLight) llSetLinkPrimitiveParamsFast(g_iTypeLight, [PRIM_POINT_LIGHT, FALSE, ZERO_VECTOR, 0, 0, 0]);
		llSleep(1.3);
		llParticleSystem([]);
		if (debug) Debug("light + particle off", TRUE, FALSE);
		llSleep(3.9);
		if (g_iTextureAnim) llSetLinkTextureAnim(g_iTypeTexture, FALSE, ALL_SIDES,4,4,0,0,1);
		if (!silent &&g_iVerbose) llWhisper(PUBLIC_CHANNEL, "(v) Particle fire effects ended");
		g_sSize = "0";
		g_iInTimer = FALSE;
		llSetTimerEvent(0.0);
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}