# MSMG-Project
Netlogo files and other miscellaneous materials

All Netlogo code is contained in the msmg_project.nlogo file

Currently operates as follows:
* 2 factions --> Allies and Axis
* Every entity group that was listed by Chris on his slide deck are named and represent 6 groups on each side (mixed armor and infantry)
* For the historical events presentation 3/2 the way they work is follows:
  1. Each axis unit is assigned its own group name and a an opposing force to attack
  2. All units are provided a list of points that serve as travel waypoints to move across the field
  3. Because historically the US forces were surprised by the German attack, the model is coded to freeze the US troop movement until there have been '2' engagements (assumption is that the first two will come from KG Schutte, and the other from KG Gerhardt) after which the 3/1 AR will move to the eastern side of Sidi Bouzid....and eventually be pinned between KG Stenkoff, KG Gerhardt, and KG Reimann
