// Link control (secondary switch) for RealFire
//
// Author: Rene10957 Resident
// Date: 02-02-2014
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.
// Content creator? Please read the license notecard!
//
// Drop this in any prim (within the same linkset) you want to use as an on/off/menu switch
// Note: only useful if you want to use a different prim as a switch (other than the fire prim)

string title = "Link Control";   // title
string version = "1.1";          // version
integer silent = FALSE;          // silent startup

// Constants

integer msgNumber = 10959;       // number part of link message

default
{
    state_entry()
    {
        if (!silent) llWhisper(0, title + " " + version + " ready");
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    touch_start(integer total_number)
    {
        llResetTime();
    }

    touch_end(integer total_number)
    {
        key user = llDetectedKey(0);

        if (llGetTime() > 1.0) {
            llMessageLinked(LINK_ALL_OTHERS, msgNumber, "menu", user);
        }
        else {
            llMessageLinked(LINK_ALL_OTHERS, msgNumber, "switch", user);
        }
    }
}
