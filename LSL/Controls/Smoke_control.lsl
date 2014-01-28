// Smoke control (smoke without fire) for RealFire
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
// Use together with smoke script and drop in the same prim
// No other scripts are needed

string title = "Smoke Control";   // title
string version = "1.0";           // version

// Constants

integer smokeChannel = -15790;    // smoke channel
integer on = FALSE;               // smoke on/off

// Functions

toggleSmoke()
{
    if (on) sendMessage(0); else sendMessage(100);
    on = !on;
}

sendMessage(integer number)
{
    llMessageLinked(LINK_THIS, smokeChannel, (string)number, "");
}

default
{
    state_entry()
    {
        llWhisper(0, title + " " + version + " ready");
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    touch_start(integer total_number)
    {
        toggleSmoke();
    }
}
