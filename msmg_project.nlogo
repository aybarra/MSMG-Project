breed [allies ally]
breed [axis an-axis]
breed [mountains a-mountain]
breed [armor-allies ar-ally]
breed [armor-axis ar-axis]

globals
[
  mouse-was-down?
  screen-size
  axis-grouping-radius
  allies-grouping-radius

  bat-name
  allies-engaged
  engagementXCor
  engagementYCor
  terrainUpdated

  engagement-count
  dt
  remaining-health

  unit-health-list-gold-ally-inf
  unit-health-list-gold-axis-inf
  unit-health-list-gold-ally-ar
  unit-health-list-gold-axis-ar
  turtle-size

  remaining-health-list

  ally-batallion-names
  axis-batallion-names


  total-health-ally-inf
  total-health-ally-ar
  total-health-axis-inf
  total-health-axis-ar

  total-allies-retreated
  total-axis-retreated
]

patches-own
[
  terrain-val
  ally-retreat-val
  axis-retreat-val
  ally-assist-val
]

turtles-own
[
  health
  name
  unit-target
  objective-locations
  unit-health-list

  half-health
  original-health

  same-pos-count
  old-posx
  old-posy
  retreated

  bonus
]

allies-own
[
  engaged
]

armor-allies-own
[
  engaged
]
mountains-own
[
  elevation
]

to setup
  clear-all

  set screen-size (max-pxcor - min-pxcor) * (max-pycor - min-pycor)

  import-drawing "map-terrain.png"
  import-pcolors-rgb "map-terrain-routes.png"

  set axis-grouping-radius 10
  set allies-grouping-radius 10
  place-mountains

  setup-ally-retreat
  setup-axis-retreat

  set engagement-count 0
  set allies-engaged false

  set terrainUpdated false

  set turtle-size 2
  setup-unit-health

  place-axis

  place-allies

  set-default-shape allies "square"
  set-default-shape axis "square"
  set-default-shape armor-axis "tank"
  set-default-shape armor-allies "tank"
  set-default-shape mountains "triangle 2"

  set ally-batallion-names (list ("3-168 IN") ("3/1 AR") ("2-168 IN") ("CCC") ("1/6 AR"))
  set axis-batallion-names (list ("KG Gerhardt") ("KG Stenkoff") ("KG Schutte") ("KG Reimann"))

  set dt 1

  set total-health-ally-inf 0
  ask allies [ set total-health-ally-inf total-health-ally-inf + sum unit-health-list ]

  set total-health-ally-ar 0
  ask armor-allies [ set total-health-ally-ar total-health-ally-ar + sum unit-health-list ]

  set total-health-axis-inf 0
  ask axis [ set total-health-axis-inf total-health-axis-inf + sum unit-health-list ]

  set total-health-axis-ar 0
  ask armor-axis [ set total-health-axis-ar total-health-axis-ar + sum unit-health-list ]

  set total-axis-retreated 0
  set total-allies-retreated 0

  reset-ticks

end

to place-mountains
  file-open "mtn-locs-cleaned.txt"

  while [not file-at-end?][
    ;read one line
    let loc list file-read file-read
    create-mountains 1
    [
      set color [0 0 0]
      setxy (item 0 loc) (item 1 loc)
      set heading 0
      set size 1.5
      set health 10
    ]
  ]
  file-close

  ;; Check if the color is yellow if so, se the terrainval to 2
  ask patches [
    ifelse pcolor = [237 237 49] [

      set terrain-val (8 * (distance patch (.55 * max-pxcor) (.60 * min-pycor)))
    ]
    [
      ifelse pcolor = [121 255 1] [
        set terrain-val (2 * (distance patch (.55 * max-pxcor) (.60 * min-pycor)))
      ][
      ;; Otherwise to 20
       set terrain-val (20 * (distance patch (.55 * max-pxcor) (.60 * min-pycor)))
      ]
    ]
  ]

  ;; Make those mountains a bitch to pass
  ask mountains [
    ask patch-here [
      set terrain-val (100 * (distance patch (.55 * max-pxcor) (.60 * min-pycor)))
    ]
  ]

end

to setup-axis-retreat

  import-pcolors-rgb "map-terrain-routes-axis-retreat.png"

  ;; Check if the color is yellow if so, se the terrainval to 20
  ask patches [
    ifelse pcolor = [237 237 49] [
      set axis-retreat-val (8 * (distance patch (.90 * max-pxcor) (.48 * min-pycor)))
    ]
    [
      ;; Color red for ideal area
      ifelse pcolor = [215 50 41] [
        set axis-retreat-val (2 * (distance patch (.90 * max-pxcor) (.48 * min-pycor)))
      ][
      ;; Otherwise to 20 for the sandy areas
       set axis-retreat-val (20 * (distance patch (.90 * max-pxcor) (.48 * min-pycor)))
      ]
    ]
  ]

  ;; Make the mountains a bitch to pass
  ask mountains [
    ask patch-here [
      set axis-retreat-val (100 * (distance patch (.90 * max-pxcor) (.48 * min-pycor)))
    ]
  ]
end

to setup-ally-retreat
  import-pcolors-rgb "map-terrain-routes-ally-retreat.png"

  ;; Check if the color is yellow if so, se the terrainval to 2
  ask patches [
    ifelse pcolor = [237 237 49] [

      set ally-retreat-val (8 * (distance patch (.25 * max-pxcor) (.30 * min-pycor)))
    ]
    [
      ;; Color blue for ally retreat
      ifelse pcolor = [52 94 171] [
        set ally-retreat-val (2 * (distance patch (.25 * max-pxcor) (.30 * min-pycor)))
      ][
      ;; Otherwise to 20
       set ally-retreat-val (8 * (distance patch (.25 * max-pxcor) (.30 * min-pycor)))
      ]
    ]
  ]

  ;; Make those mountains a bitch to pass
  ask mountains [
    ask patch-here [
      set ally-retreat-val (100 * (distance patch (.55 * max-pxcor) (.60 * min-pycor)))
    ]
  ]
end

to setup-ally-assist [ xCord yCord ]
  ask patches [
    ifelse pcolor = [237 237 49] [
      set ally-assist-val (8 * (distance patch xCord yCord))
    ][
      ifelse pxcor = xCord and pycor = yCord[
          set ally-assist-val 2
      ][
          ;; Otherwise to 20
          set ally-assist-val (12 * (distance patch (xCord) (yCord)))
      ]
    ]
  ]

  ;; Make those mountains a bitch to pass
  ask mountains [
    ask patch-here [
      set ally-assist-val (100 * (distance patch (xCord) (yCord)))
    ]
  ]
end

to setup-unit-health

    ;; Ally inf
    let itr 0
    set unit-health-list-gold-ally-inf (list starting-health)
    while [itr < ally-inf-batallion-size - 1] [
      set unit-health-list-gold-ally-inf lput starting-health unit-health-list-gold-ally-inf
      set itr itr + 1
    ]

    ;; Ally ar
    set itr 0
    set unit-health-list-gold-ally-ar (list starting-health)
    while [itr < ally-ar-batallion-size - 1] [
      set unit-health-list-gold-ally-ar lput starting-health unit-health-list-gold-ally-ar
      set itr itr + 1
    ]

    ;; Axis inf
    set itr 0
    set unit-health-list-gold-axis-inf (list starting-health)
    while [itr < axis-inf-batallion-size - 1] [
      set unit-health-list-gold-axis-inf lput starting-health unit-health-list-gold-axis-inf
      set itr itr + 1
    ]

    ;; Axis ar
    set itr 0
    set unit-health-list-gold-axis-ar (list starting-health)
    while [itr < axis-ar-batallion-size - 1] [
      set unit-health-list-gold-axis-ar lput starting-health unit-health-list-gold-axis-ar
      set itr itr + 1
    ]

end

to place-axis

  ;; KG Stenkoff (1 infantry, 2 armor)
  create-axis 1
  [
    set color (list 255 0 0 (opacity))
    set size turtle-size
    setxy (.20 * max-pxcor) min-pycor
    set name "KG Stenkoff"
    set label name
    set unit-target (list ("3/1 AR"))
    set retreated false

    set unit-health-list unit-health-list-gold-axis-inf
    set original-health (sum unit-health-list)
    hide-turtle
  ]

  create-armor-axis 1
  [
    set color (list 255 0 0 (opacity))
    set size turtle-size
    setxy ((.20 * max-pxcor) + 2) min-pycor
    set name "KG Stenkoff"
    set unit-target (list ("3/1 AR"))
    set heading 0
    set retreated false

    set unit-health-list unit-health-list-gold-axis-ar
    set original-health (sum unit-health-list)
    hide-turtle
  ]

  create-armor-axis 1
  [
    set color (list 255 0 0 (opacity))
    set size turtle-size
    setxy ((.20 * max-pxcor) + 4) min-pycor
    set name "KG Stenkoff"
    set unit-target (list ("3/1 AR"))
    set heading 0
    set retreated false

    set unit-health-list unit-health-list-gold-axis-ar
    set original-health (sum unit-health-list)
    hide-turtle
  ]

  ;; KG Schutte (1 infantry, 1 armor)
  create-axis 1
  [
    set color (list 255 0 0 (opacity))
    set size turtle-size
    setxy ((.65 * max-pxcor)) min-pycor
    ;set label who
    set name "KG Schutte"
    set unit-target (list ("3-168 IN"))
    set heading 0
    set retreated false

    set unit-health-list unit-health-list-gold-axis-inf
    set original-health (sum unit-health-list)

    ;; Hide these guys until 2-168 gets attacked
    hide-turtle
  ]

  create-armor-axis 1
  [
    set color (list 255 0 0 (opacity))
    set size turtle-size
    set name "KG Schutte"
    setxy ((.68 * max-pxcor)) min-pycor
    set label name
    set unit-target (list ("3-168 IN"))
    set heading 0
    set retreated false

    set unit-health-list unit-health-list-gold-axis-ar
    set original-health (sum unit-health-list)

    ;; Hide these guys until 2-168 gets attacked
    hide-turtle
  ]

  ;; KG Reiman (1 infantry)
  create-axis 1
  [
    set color (list 255 0 0 (opacity))
    set size turtle-size
    set name "KG Reimann"
    setxy ((.78 * max-pxcor)) ((.62 * min-pycor))
    set label name
    set unit-target (list ("3/1 AR"))
    set retreated false

    set unit-health-list unit-health-list-gold-axis-inf
    set original-health (sum unit-health-list)

    set bonus true
  ]

  ;; KG Gerhardt (1 armor, 1 infantry)
  create-armor-axis 1
  [
    set color (list 255 0 0 (opacity))
    set size turtle-size
    setxy (.79 * max-pxcor) (.57 * min-pycor)
    ;set label who
    set name "KG Gerhardt"
    set unit-target (list ("2-168 IN"))
    set heading 270
    set retreated false

    set unit-health-list unit-health-list-gold-axis-ar
    set original-health (sum unit-health-list)

    set bonus true
  ]

  create-axis 1
  [
    set color (list 255 0 0 (opacity))
    set size turtle-size
    setxy (.82 * max-pxcor) (.58 * min-pycor)
    set name "KG Gerhardt"
    set label name
    set unit-target (list ("2-168 IN"))
    set heading 270
    set retreated false

    set unit-health-list unit-health-list-gold-axis-inf
    set original-health (sum unit-health-list)

    set bonus true
  ]

end

to place-allies

  ;; 3-168 IN
  create-allies 1
  [
    set color (list 0 0 255 (opacity))
    set size turtle-size
    setxy (.71 * max-pxcor) (.83 * min-pycor)
    set name "3-168 IN"
    set label name
    set retreated false

    set unit-health-list unit-health-list-gold-ally-inf
    set original-health (sum unit-health-list)
  ]

  ;; 3/1 AR
  create-armor-allies 1
  [
    set color (list 0 0 255 (opacity))
    set size turtle-size
    setxy (.5 * max-pxcor) (.78 * min-pycor)
    set name "3/1 AR"
    set label name
    set objective-locations (list (.55 * max-pxcor) (.62 * min-pycor))
    set heading 90
    set retreated false

    set unit-health-list unit-health-list-gold-ally-ar
    set original-health (sum unit-health-list)
  ]

  ;; 2-168 IN
  create-allies 1
  [
    set color (list 0 0 255 (opacity))
    set size turtle-size
    setxy (.56 * max-pxcor) (.45 * min-pycor)
    set name "2-168 IN"
    set label name
    set retreated false

    set unit-health-list unit-health-list-gold-ally-inf
    set original-health (sum unit-health-list)
  ]

  ;; Combat command C (1 infantry, 1 armor)
  create-allies 1
  [
    set color (list 0 0 255 (opacity))
    set size turtle-size
    setxy (.39 * max-pxcor) (.25 * min-pycor)
    set name "CCC"
    set label name
    set heading 190
    set retreated false

    set unit-health-list unit-health-list-gold-ally-inf
    set original-health (sum unit-health-list)

    set bonus true
  ]

  create-armor-allies 1
  [
    set color (list 0 0 255 (opacity))
    set size turtle-size
    setxy (.36 * max-pxcor) (.25 * min-pycor)
    set heading 190
    set name "CCC"
    set retreated false

    set unit-health-list unit-health-list-gold-ally-ar
    set original-health (sum unit-health-list)

    set bonus true
  ]

  ;; 1/6 AR (1 armor)
  create-armor-allies 1
  [
    set color (list 0 0 255 (opacity))
    set size turtle-size
    setxy (.23 * max-pxcor) (.29 * min-pycor)
    set name "1/6 AR"
    set label name
    set heading 135
    set retreated false

    set unit-health-list unit-health-list-gold-ally-ar
    set original-health (sum unit-health-list)
  ]
end

to go

  ;; Axis move first
  foreach axis-batallion-names [
    set bat-name ?
    perform-axis-movement bat-name
  ]

  ;; Setup the ally assist if necessary
  if allies-engaged = true and terrainUpdated = false [
    setup-ally-assist engagementXCor engagementYCor
    set terrainUpdated true
  ]

  ;; Allies move next
  foreach ally-batallion-names [
    set bat-name ?
    perform-allies-movement bat-name
  ]

  ;; Check to see if distances are farther away and if so break link
  ask links [
    if link-length > engagement-range [die]
  ]

  ;; Kill off any troop that health has reached 0
  check-death

  ;; deduct from reaction-delay
  if allies-engaged [
    if reaction-delay > 0 [
      set reaction-delay reaction-delay - 1
    ]
  ]

  ;; Check to see if turtles got stuck
  ask turtles [
    if breed != mountains [
      ifelse xcor = old-posx and ycor = old-posy [
        set same-pos-count same-pos-count + 1
      ][
        set old-posx xcor
        set old-posy ycor
        set same-pos-count 0
      ]

      if same-pos-count > 0 and same-pos-count mod 20 = 0 [
        set heading random 360
        fd 1
        set same-pos-count 0
      ]
    ]
  ]


  ;; Update the health reporter for the plot and for the experiment run
  set total-health-ally-inf 0
  ask allies [ set total-health-ally-inf total-health-ally-inf + sum unit-health-list ]

  set total-health-ally-ar 0
  ask armor-allies [ set total-health-ally-ar total-health-ally-ar + sum unit-health-list ]

  set total-health-axis-inf 0
  ask axis [ set total-health-axis-inf total-health-axis-inf + sum unit-health-list ]

  set total-health-axis-ar 0
  ask armor-axis [ set total-health-axis-ar total-health-axis-ar + sum unit-health-list ]

  update-retreated-count

  tick
end


to update-retreated-count
  set total-allies-retreated 0
  set total-axis-retreated 0

  set total-allies-retreated (total-allies-retreated + (3 - count allies))
  set total-allies-retreated (total-allies-retreated + (3 - count armor-allies))

  set total-axis-retreated (total-axis-retreated + (4 - count axis))
  set total-axis-retreated (total-axis-retreated + (4 - count armor-axis))

  ask allies [
    if retreated [
        set total-allies-retreated total-allies-retreated + 1
    ]
  ]
  ask armor-allies [
    if retreated [
      set total-allies-retreated total-allies-retreated + 1
    ]
  ]

  ask axis [
    if retreated [
      set total-axis-retreated total-axis-retreated + 1
    ]
  ]
  ask armor-axis [
    if retreated [
      set total-axis-retreated total-axis-retreated + 1
    ]
  ]
end

to perform-allies-movement [ name-of-batallion ]
  let units (turtles with [name = name-of-batallion])

  ask units [
      ;; Only run this if not hidden
      if not hidden? [
          let retreating false
          let move-unit self

          ;; Check health and if you're less than 50% then retreat
          ask move-unit [
            if (sum unit-health-list) < (original-health * attrition) [
              set retreating true
              set retreated true
            ]
          ]

          ifelse retreating = true [
            ;; Makes the infantry move slower
            if (breed = axis and (ticks mod infantry-delay = 0)) or breed = armor-allies [
              downhill ally-retreat-val
            ]
          ][
              ;; Otherwise move to assist
              if reaction-delay = 0 and allies-engaged = true [
                downhill ally-assist-val
              ]
          ]
      ]
  ]
end

to perform-axis-movement [ name-of-batallion ]
  let units (turtles with [name = name-of-batallion])

  ask units [
      if not hidden? [

          let retreating false
          let move-unit self

          ;; Check health and if you're less than 50% then retreat
          ask move-unit [
            if (sum unit-health-list) < (original-health * attrition) [
               set retreating true
               set retreated true
            ]
          ]

          ;; If retreating fall back through the pass
          ifelse retreating [
            ;; Makes the infantry move slower
            if (breed = axis and (ticks mod infantry-delay = 0)) or breed = armor-axis [
              downhill axis-retreat-val
            ]
          ][

              ;; Check if there's a link with another turtle already
              ifelse any? out-link-neighbors [
                ;;output-print word ([name] of self) (word "OUTLINK NEIGHBORS IS NON-EMPTY: " (out-link-neighbors))
                ;; Attack the same guy...
                attack self (one-of out-link-neighbors)
              ][

                  ;;output-print word ([name] of self) ": NO TARGET ACQUIRED, SEARCHING"
                  let attacking false
                  let target nobody
                  ;; Check to see if an armor enemy is in range
                  ;; If so then attack
                  ask armor-allies in-cone detection-range 360 [
                     set target self
                     set attacking true
                  ]
                  ;; Next check if an infantry enemy is in range
                  if attacking = false [
                      ask allies in-cone detection-range 360 [
                          set target self
                          set attacking true
                     ]
                  ]
                  ;; Move towards objective city
                  ifelse attacking = false [
                      if (breed = axis and (ticks mod infantry-delay) = 0) or breed = armor-axis [
                        ;;output-print word ([name] of self) ": GOING DOWNHILL"
                        downhill terrain-val
                      ]
                   ;; Otherwise attack the target
                   ][
                   ifelse distance target <= engagement-range [
                      attack self target

                      if (([name] of self) = "KG Reimann" or ([name] of self) = "KG Gerhardt") and ([name] of target) = "2-168 IN" [
                          unhide-batallion-turtles "KG Schutte"
                      ]
                      if ([name] of self) = "KG Schutte" [
                          unhide-batallion-turtles "KG Stenkoff"
                      ]
                      if allies-engaged = false [

                         set allies-engaged true
                         ask target [
                           set engagementXCor xcor
                           set engagementYCor ycor
                         ]
                      ]

                      ask self [ create-link-to target]
                      ask target [ set engaged true ]
                     ][
                         face target
                         fd 1
                      ]
                  ]
              ]
          ]
      ]
     ]
end

;; Finish outputting to a file
to finish-adding-mtns
  file-close
end

to check-death
  ask turtles [
    if breed != mountains and sum unit-health-list <= 0 [ die ]
  ]
end

to attack [attacker target]
  let attacker-bonus ([bonus] of attacker)
  let target-bonus ([bonus] of target)

  let attack-breed ([breed] of attacker)
  let target-breed ([breed] of target)

  let attack-health (sum [unit-health-list] of attacker)
  let target-health (sum [unit-health-list] of target)

  ;; =============
  ;; Ally attacks
  ;; =============
  if (attack-breed) = allies and target-breed = armor-axis [
  ]
  if (attack-breed) = allies and target-breed = axis [
  ]
  if (attack-breed) = armor-allies and target-breed = armor-axis [
  ]
  if (attack-breed) = armor-allies and target-breed = axis [
  ]

  ;; ============
  ;; Axis attacks
  ;; ============
  ;; Axis infantry attacking armor allies
  if (attack-breed) = axis and target-breed = armor-allies [
    ;;output-print "AXIS INF ATTACKING ARMOR ALLIES"

    ;; Call function for axis infantry health
    lanchester-axis-inf-ar attack-health target-health
    ;;output-print word "Remaining health for axis inf is: " remaining-health
    update-health ([unit-health-list] of attacker) remaining-health

    ;; Check to see if the target had a bonus and if so tack on 10% decrease
    if target-bonus = true [
        update-health remaining-health-list (floor ((sum remaining-health-list) * (1 - bonus-value)))
        ask target [ set bonus false ]
    ]
    ask attacker [ set unit-health-list remaining-health-list ]

    ;; Call function for ally armor health
    ;; Axis infantry attacking allied armor
    lanchester-ally-ar-inf target-health attack-health
    update-health ([unit-health-list] of target) remaining-health
    if attacker-bonus = true [
        update-health remaining-health-list (floor ((sum remaining-health-list) * (1 - bonus-value)))
        ask attacker [ set bonus false ]
    ]
    ask target [ set unit-health-list remaining-health-list ]
  ]
  ;; Axis infantry attacking ally infantry
  if (attack-breed) = axis and target-breed = allies [
    ;;output-print "AXIS INF ATTACKING ALLY INFANTRY"

    ;; Update axis health
    lanchester-axis-inf-inf attack-health target-health
    ;;output-print word "Remaining health for axis inf is: " remaining-health
    update-health ([unit-health-list] of attacker) remaining-health
    ;; Check to see if the target had a bonus and if so tack on 10% decrease
    if target-bonus = true [
        update-health remaining-health-list (floor ((sum remaining-health-list) * (1 - bonus-value)))
        ask target [ set bonus false ]
    ]
    ask attacker [ set unit-health-list remaining-health-list ]

    ;; Update ally health
    lanchester-ally-inf-inf target-health attack-health
    ;;output-print word "Remaining health for ally inf is: " remaining-health
    update-health ([unit-health-list] of target) remaining-health
    if attacker-bonus = true [
        update-health remaining-health-list (floor ((sum remaining-health-list) * (1 - bonus-value)))
        ask attacker [ set bonus false ]
    ]
    ask target [ set unit-health-list remaining-health-list ]

  ]
  ;; Armor axis attacking armor allies
  if (attack-breed) = armor-axis and target-breed = armor-allies [
    ;;output-print "ARMOR AXIS ATTACKING ARMOR ALLIES"

    ;; Update health of axis
    axis-ar-ar attack-health target-health
    ;;output-print word "Remaining health for Axis AR is: " remaining-health
    update-health ([unit-health-list] of attacker) remaining-health
    ;; Check to see if the target had a bonus and if so tack on 10% decrease
    if target-bonus = true [
        update-health remaining-health-list (floor ((sum remaining-health-list) * (1 - bonus-value)))
        ask target [ set bonus false ]
    ]
    ask attacker [ set unit-health-list remaining-health-list ]

    ;; Update health of allies
    ally-ar-ar target-health attack-health
    ;;output-print word "Remaining health for Ally AR is: " remaining-health
    update-health ([unit-health-list] of target) remaining-health
    if attacker-bonus = true [
        update-health remaining-health-list (floor ((sum remaining-health-list) * (1 - bonus-value)))
        ask attacker [ set bonus false ]
    ]
    ask target [ set unit-health-list remaining-health-list ]
  ]
  ;; Armor axis attacking ally infantry
  if (attack-breed) = armor-axis and target-breed = allies [
    ;;output-print "ARMOR AXIS ATTACKING ALLIES"

    ;; Update health of axis
    lanchester-axis-ar-inf attack-health target-health
    ;;output-print word "Remaining health for Axis AR is: " remaining-health
    update-health ([unit-health-list] of attacker) remaining-health
    ;; Check to see if the target had a bonus and if so tack on 10% decrease
    if target-bonus = true [
        update-health remaining-health-list (floor ((sum remaining-health-list) * (1 - bonus-value)))
        ask target [ set bonus false ]
    ]
    ask attacker [ set unit-health-list remaining-health-list ]

    ;; Update the health of allies
    lanchester-ally-inf-ar target-health attack-health
    ;;output-print word "Remaining health for Ally infantry is: " remaining-health
    update-health ([unit-health-list] of target) remaining-health
    if attacker-bonus = true [
        update-health remaining-health-list (floor ((sum remaining-health-list) * (1 - bonus-value)))
        ask attacker [ set bonus false ]
    ]
    ask target [ set unit-health-list remaining-health-list ]
  ]
end

;; ====================
;; ALLY ATTACK METHODS
;; ====================
;; --------- Ally infantry attacking Axis infantry --------
to lanchester-ally-inf-inf [ ally-inf-health axis-inf-health ]
  let remaining-ally (((.5 * ((ally-inf-health - (sqrt (axis-inf-eff / ally-inf-eff)) * axis-inf-health) * (exp sqrt (ally-inf-eff * axis-inf-eff))))) + ((.5 * ((ally-inf-health + (sqrt (axis-inf-eff / ally-inf-eff)) * axis-inf-health) * (exp (-1 * (sqrt (ally-inf-eff * axis-inf-eff))))))))
  ;output-print word ("The remaining ally inf") remaining-ally
  set remaining-health remaining-ally
end

;; ---------- Ally infantry attacking Axis armor ---------
to lanchester-ally-inf-ar [ ally-inf-health axis-ar-health ]
  let remaining-ally ((ally-inf-health) * exp (-1 * axis-ar-eff))
  set remaining-health remaining-ally
end

;; --------- Ally armor attacking Axis infantry --------
to lanchester-ally-ar-inf [ ally-ar-health axis-inf-health ]
  let amount (100 + 100 * (-1 * ally-tank-killing-eff))
  let prob random amount
  ifelse prob < 50 [
    set remaining-health (.95 * ally-ar-health)
  ][
    set remaining-health ally-ar-health
  ]
end

;; ------ Ally armor attacking Axis armor ------------
to ally-ar-ar [ ally-ar-health axis-ar-health ]
  let prob random 100
  ifelse prob < 10 [
    set remaining-health (.5  * ally-ar-health)
  ][
    set remaining-health (ally-ar-health)
  ]
end

;; ===================
;; AXIS ATTACK METHODS
;; ===================
;; -------- Axis infantry attacking Ally infantry -------
to lanchester-axis-inf-inf [ axis-inf-health ally-inf-health ]
  let remaining-axis (((.5 * ((axis-inf-health - (sqrt (axis-inf-eff / ally-inf-eff)) * ally-inf-health) * (exp sqrt (ally-inf-eff * axis-inf-eff))))) + ((.5 * ((axis-inf-health + (sqrt (axis-inf-eff / ally-inf-eff)) * ally-inf-health) * (exp (-1 * (sqrt (ally-inf-eff * axis-inf-eff))))))))
  ;output-print word ("The remaining axis inf") remaining-axis
  set remaining-health remaining-axis
end

;; -------- Axis Armor attacking Ally infantry ----------
;; Rationale behind this method is that the health will either go down by half if random dice roll falls in range or will stay the same
to lanchester-axis-ar-inf [ axis-ar-health ally-inf-health ]
  let amount (100 + 100 * (-1 * ally-tank-killing-eff))
  let prob random amount
  ifelse prob < 50 [
    set remaining-health (.95 * axis-ar-health)
  ][
    set remaining-health axis-ar-health
  ]
end

;; -------- Axis infantry attacking Ally armor ---------
to lanchester-axis-inf-ar [ axis-inf-health ally-ar-health ]
  let remaining-axis ((axis-inf-health) * exp (-1 * ally-ar-eff))
  set remaining-health remaining-axis
end

;; --------- Axis armor attacking Ally armor ------------
to axis-ar-ar [ axis-unit-health ally-unit-health ]
  let prob random 100
  ifelse prob < 10 [
    set remaining-health (.5  * axis-unit-health)
  ][
    set remaining-health axis-unit-health
  ]
end

to update-health [ health-list health-remaining]
  if health-remaining < 1 [
      set health-remaining 0
  ]
  set remaining-health-list sublist health-list 0 (health-remaining / 100)
end


to unhide-batallion-turtles [ batallion-name ]
  ask axis [
    if name = batallion-name [
      show-turtle
    ]
  ]
  ask armor-axis [
    if name = batallion-name [
      show-turtle
    ]
  ]

end

to wiggle        ;; turtle procedure
  rt random 50 - random 50
end


; Copyright 1998 Uri Wilensky.
;; Is there an assumption that allies are the one's attacking? so we'd have a switch to set allies to attack first
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
209
10
1337
704
-1
-1
13.0
1
10
1
1
1
0
0
0
1
0
85
-50
0
1
1
1
ticks
30.0

BUTTON
26
675
89
708
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
94
675
160
708
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
13
10
185
43
opacity
opacity
0
250
210
10
1
NIL
HORIZONTAL

SLIDER
12
45
184
78
starting-health
starting-health
0
100
100
10
1
NIL
HORIZONTAL

SLIDER
16
551
188
584
engagement-range
engagement-range
0
3
3
1
1
NIL
HORIZONTAL

SLIDER
11
116
183
149
axis-ar-eff
axis-ar-eff
0
.2
0.01
.001
1
NIL
HORIZONTAL

SLIDER
11
148
183
181
axis-inf-eff
axis-inf-eff
0
.2
0.01
.001
1
NIL
HORIZONTAL

SLIDER
11
182
183
215
ally-ar-eff
ally-ar-eff
0
.2
0.01
.001
1
NIL
HORIZONTAL

SLIDER
11
223
183
256
ally-inf-eff
ally-inf-eff
0
.2
0.01
.001
1
NIL
HORIZONTAL

SLIDER
8
259
189
292
axis-ar-batallion-size
axis-ar-batallion-size
75
75
75
0
1
NIL
HORIZONTAL

SLIDER
10
425
184
458
axis-tank-killing-eff
axis-tank-killing-eff
0
1
0.5
.1
1
NIL
HORIZONTAL

SLIDER
12
460
184
493
ally-tank-killing-eff
ally-tank-killing-eff
0
1
0.5
.1
1
NIL
HORIZONTAL

PLOT
1110
79
1371
310
Infantry Health
ticks
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Allies" 1.0 0 -13345367 true "" "plot total-health-ally-inf"
"Axis" 1.0 0 -2674135 true "" "plot total-health-axis-inf"

SLIDER
1106
31
1278
64
infantry-delay
infantry-delay
0
5
2
1
1
NIL
HORIZONTAL

MONITOR
1269
315
1372
360
NIL
reaction-delay
17
1
11

SLIDER
17
505
189
538
attrition
attrition
0
1
0.1
.1
1
NIL
HORIZONTAL

SLIDER
15
591
187
624
detection-range
detection-range
0
10
10
1
1
NIL
HORIZONTAL

INPUTBOX
1205
364
1360
424
reaction-delay
0
1
0
Number

SLIDER
4
294
201
327
axis-inf-batallion-size
axis-inf-batallion-size
750
750
750
0
1
NIL
HORIZONTAL

SLIDER
4
328
190
361
ally-ar-batallion-size
ally-ar-batallion-size
100
100
100
0
1
NIL
HORIZONTAL

SLIDER
6
364
203
397
ally-inf-batallion-size
ally-inf-batallion-size
1000
1000
1000
0
1
NIL
HORIZONTAL

PLOT
1110
429
1370
579
Armor Health
Ticks
Total Health
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Allies" 1.0 0 -13345367 true "" "plot total-health-ally-ar"
"Axis" 1.0 0 -2674135 true "" "plot total-health-axis-ar"

SLIDER
15
630
187
663
bonus-value
bonus-value
0
1
0.1
.1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Netlogo simulation illustrating the Battle of Sidi Bouzid

## HOW IT WORKS

-The model illustrates the battle using batallion positions, both forces use the downhill function to move based on a map-terrain.png that make the roads available. For retreat there are separate .png's that determine where the retreat location is for each side (northwest for the allies, back through the pass for the axis forces)
- Because the downhill function doesn't always work the way we want it to (there are instances where a turtle reaches a local minimum), if the turtle remains parked for 20 ticks, I allow them to move one step in the direction they are facing.
- We have setup inf-inf using lanchester attrition, ar-inf using linear lanchester attrition, and inf-ar and ar-ar as direct fire model

## HOW TO USE IT

Currently the only input that we'd recommend changing is reaction-delay

## THINGS TO NOTICE

KG Schutte arrives (becomes unhidden) after 3-168 IN is attacked by KG Reimann or KG Gerhardt, KG Stenkoff arrives after Schutte engages an ally force. (This is done to make the model run longer and more closely parallel the movement and placement of forces with that of history). Ally forces move in to the location where the first engagement is registered. If ally forces are attacked before then, they will attack using the appropriate attack equations depending on the engagement type.

For each experimental run we capture the number of forces that register a retreat status (loss of 50%), as well as the remaining health for each sides forces both infantry and armor

## THINGS TO TRY
Currently only supports running from Setup and Go, modifying the reaction-delay text input to see how battle changes

## EXTENDING THE MODEL
It's worth investigating alternatives to the downhill function, its convenient as a netlogo paradigm but it'd be interesting to see if it could be substitued with A* or Djikstra's algorithm output for determining a path to travel.

## NETLOGO FEATURES

import-drawing for the background mapview
import-pcolors-rgb for the patch variables
downhill --> for more natural movement over using waypoints

## RELATED MODELS

Sheep and Shepherds example

## CREDITS AND REFERENCES

Credit to author: Uri Wilensky for base sheep and shepherd implementation
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

german
false
15
Rectangle -1 true true 127 79 172 94
Polygon -7500403 true false 105 90 60 195 90 210 135 105
Polygon -7500403 true false 195 90 240 195 210 210 165 105
Circle -1 true true 110 5 80
Polygon -7500403 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -7500403 true false 122 4 107 16 102 39 105 53 135 30 195 45 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person_soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

tank
true
0
Rectangle -7500403 true true 144 0 159 105
Rectangle -6459832 true false 195 45 255 255
Rectangle -16777216 false false 195 45 255 255
Rectangle -6459832 true false 45 45 105 255
Rectangle -16777216 false false 45 45 105 255
Line -16777216 false 45 75 255 75
Line -16777216 false 45 105 255 105
Line -16777216 false 45 60 255 60
Line -16777216 false 45 240 255 240
Line -16777216 false 45 225 255 225
Line -16777216 false 45 195 255 195
Line -16777216 false 45 150 255 150
Polygon -7500403 true true 90 60 60 90 60 240 120 255 180 255 240 240 240 90 210 60
Rectangle -16777216 false false 135 105 165 120
Polygon -16777216 false false 135 120 105 135 101 181 120 225 149 234 180 225 199 182 195 135 165 120
Polygon -16777216 false false 240 90 210 60 211 246 240 240
Polygon -16777216 false false 60 90 90 60 89 246 60 240
Polygon -16777216 false false 89 247 116 254 183 255 211 246 211 237 89 236
Rectangle -16777216 false false 90 60 210 90
Rectangle -16777216 false false 143 0 158 105

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment2" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-0" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-1" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-2" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-3" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-4" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-5" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-6" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-7" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-8" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-9" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-10" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-20" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-24" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-40" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-80" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-160" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="160"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reaction-delay-320" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-health-ally-inf</metric>
    <metric>total-health-ally-ar</metric>
    <metric>total-health-axis-inf</metric>
    <metric>total-health-axis-ar</metric>
    <metric>total-axis-retreated</metric>
    <metric>total-allies-retreated</metric>
    <enumeratedValueSet variable="ally-inf-batallion-size">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-range">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-batallion-size">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-batallion-size">
      <value value="750"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attrition">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-batallion-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-tank-killing-eff">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infantry-delay">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="opacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="axis-ar-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reaction-delay">
      <value value="320"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-health">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ally-inf-eff">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus-value">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

line2
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
