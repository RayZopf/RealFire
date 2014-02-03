// LSL script generated: RealFire-Rene10957.LSL.Controls.Remote_receiver.lslp Mon Feb  3 19:31:55 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Remote receiver for RealFire
//
// Author: Rene10957 Resident
// Date: 12-01-2014
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.
// Content creator? Please read the license notecard!
//
// Drop this into the same prim where the FIRE SCRIPT is located
// Note: only useful if you are also using the remote control script
//
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: initial structure for multiple sound files, implement linked_message system, background sound, LSLForge Modules
//03. Feb. 2014
//v1.1-0.1
//




//user changeable variables
//-----------------------------------------------
string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire Remote Receiver";
string g_sVersion = "1.1-0.1";
string g_sAuthors = "Rene10957, Zopf";

// Constants
string SEPARATOR = ";;";
integer msgNumber = 10957;
integer REMOTE_CHANNEL = -975102;


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


//===============================================
//PREDEFINED FUNCTIONS
//===============================================



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

    state_entry() {
        llListen(REMOTE_CHANNEL,"","","");
        llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + " ready"));
    }


    on_rez(integer start_param) {
        llResetScript();
    }


    listen(integer channel,string name,key id,string msg) {
        if ((channel != REMOTE_CHANNEL)) return;
        list msgList = llParseString2List(msg,[SEPARATOR],[]);
        string group = llList2String(msgList,0);
        string command = llList2String(msgList,1);
        key user = ((key)llList2String(msgList,2));
        string str = getGroup(LINKSETID);
        if ((((str == group) || (LINKSETID == group)) || (LINKSETID == str))) {
            llMessageLinked(LINK_THIS,msgNumber,command,user);
        }
    }
}
