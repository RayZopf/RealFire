Project to add some improvements to Linden Home fireplace (Meadowbrooks open fire)
=====================================================================
Aims
----
get a nicer fire, smoke, sound, animated logs  
let fire rezz more logs, embers, etc

Todo
----
work on prims (landimpact, lag; make them flexiprims?)
rework some internal functions, like
 - size of fire
 - change of fire/sound
make it work in opensim (SoaS)
 - LSLForge uses extraneous parentheses
	- see [0005422: (i = 1); fails to compile] (http://opensimulator.org/mantis/view.php?id=5422)
	- and [0005006: LSL implementation does not allow parenthesis assignments] (http://opensimulator.org/mantis/view.php?id=5006)



Components
==========
Script-base
-------
[RealFire] (https://marketplace.secondlife.com/de-DE/p/RealFire-by-Rene/3490495)
 - [Shop] (https://marketplace.secondlife.com/de-DE/stores/113876)
 - [rene10957 Resident (f01fbb75-bd46-4b13-902b-c8bca045a843)] (https://my.secondlife.com/rene10957)

Objects
-------
[Logs] (https://marketplace.secondlife.com/p/Burning-Logs-Full-Perms/3933165),
[Embers] (https://marketplace.secondlife.com/p/Glowing-Hot-Embers-Full-Perms/3880939)
 - [Shop] (https://marketplace.secondlife.com/de-DE/stores/102273)
 - [Xemem Kultus (e769fb46-902c-4bef-b769-67d161f1f232)] (https://my.secondlife.com/xemem.kultus)

Sounds
------
http://freesound.org/
 - found in RealFire pack:
	[fire.crackling.mp3] (http://freesound.org/people/dobroide/sounds/4211/)
	by dobroide@freesound.org

 - more:
	- [75145__willc2-45220__struck-match-8b-22k-1-65s.aif by willc2_45220]
	(http://freesound.org/people/willc2_45220/sounds/75145/)
	- [Fire_Crackles(No Room).wav]
	(http://freesound.org/people/Krisboruff/sounds/17742/)
	by Krisboruff
	- [petit feu-little fire (1).wav]
	(http://freesound.org/people/Glaneur%20de%20sons/sounds/104957/)
	and [petit feu-little fire (2).wav]
	(http://freesound.org/people/Glaneur%20de%20sons/sounds/104958/)
	by Glaneur de sons



Licensing
========
 - for original RealFire see file *License* in directory *LSL*
 - for used Sound samples see *Attribution.txt* in *Objects\Sounds*
 - for used Objects see
 	- *License-Logs_Embers-SL.txt* in directory *Objects*
 	- and *Fire Perms INFO* in directory *Objects\Sculpted Fire Full Perm*