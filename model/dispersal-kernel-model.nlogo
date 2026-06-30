globals []

breed [ seeds seed ]
breed [ pollens pollen ] ;; male gametes (i.e., pollen grains)
breed [ gametes gamete ] ;; female gametes (i.e., ovules)
breed [ plants plant ]

seeds-own [ ms-a ms-b ms-c ms-d ms-e ms-f ms-g ms-h ms-i ;; 9 diallelic microsatellites (as seeds are diploid)
  mass ;; seed mass, randomly set at initilization, and during the runs is a function of seed-mass slider and inbreeding levels
  home-patch ;; the patch where the seed was created (the patch of its' mother plant)
  inbreeding-load ;; inbreeding level, set to maximum (=4) at initialization, and during the runs it is calculated as a function of homozygosity
  distance-travelled ;; a variable to store the dispersal distance
  pop  ;; to which population the seed belongs. Only used during initialization to cluster together plants belonging to the same population
  inbreeding ] ;; a temp variable used for calculations of inbreeding load
pollens-own [ allele-a allele-b allele-c allele-d allele-e allele-f allele-g allele-h allele-i allele-j  ;; 9 alleles (as propagules are haploid)
  pollinated? ;; a logical helping in the pollination phase to avoid having the same pollen grain pollinate multiple ovules
  parent] ;; a variable used to prevent self-pollination
gametes-own [ allele-a allele-b allele-c allele-d allele-e allele-f allele-g allele-h allele-i allele-j parent] ;; same as pollen grains
plants-own [ ms-a ms-b ms-c ms-d ms-e ms-f ms-g ms-h ms-i ;; 9 diallelic microsatellites (as seeds are diploid)
  home-patch ;; inherited from seeds. Used to plot the realized dispersal kernel
  inbreeding-load ;; inbreeding levels, for plotting
  distances-list ;; to measure spatial genetic structure
  distance-travelled ;; to measure spatial genetic structure
  geographic-distances ;; to measure spatial genetic structure
  genetic-distances ;; to measure spatial genetic structure
  pop ;; to which population the seed belongs. Only used during initialization to cluster together plants belonging to the same population
  inbreeding] ;; to plot inbreeding levels of plants

to setup
  ca
  ;; create a green background
  ask patches [ set pcolor 67 + random 8 - random 8 ]
  repeat 20 [ diffuse pcolor 0.25 ]
  populations-setup
  establish
  reset-ticks ;; moved to the END of setup: on reset-ticks NetLogo (Web/desktop GUI) runs every plot's update commands, so it must run only after the world is populated, otherwise plot pens that take mean/etc. of an empty agentset throw a runtime error and abort setup
  end

to go
  establish
  produce-gametes
  produce-pollen
  produce-seeds
  disperse-seeds
  tick
  sgs
  kill-parents
  end


to populations-setup ;; begin population setup
  ifelse (initial-pops = 2) ;; if start with only 2 popualtions:
  [create-seeds N / 2 [ ;; create pop 1
    set shape "dot"
    ifelse (initial-mix = "Yes") ;; mix populations?
    [setxy random-pxcor random-pycor] ;; if yes - give random coordinates to all seeds
    [move-to one-of patches with [ pycor > initial-gap ]] ; if no, concentrate all indiivudals of this population to one half of the screen
    set home-patch patch-here ;; ask each seed to record its' home patch, used later to calculate dispersal distances and spatial genetic structure
    set mass random seed-mass ;; give a random mass to each seed
    set color violet
    set inbreeding-load 4 ;; initially all individuals are homozygote and thus get the maximum value of inbreeding load
    set ms-a 2 set ms-b 2 set ms-c 2 set ms-d 2 set ms-e 2 set ms-f 2 set ms-g 2 set ms-h 2 set ms-i 2 ;; give the seeds a homozygote genome
  ]
    create-seeds N / 2 ;; create pop 2
  [
    set shape "dot"
    ifelse (initial-mix = "Yes") ;; mix populations?
    [setxy random-pxcor random-pycor] ;; yes
    [move-to one-of patches with [ pycor < ( 0 - initial-gap ) ]] ;; no
    set home-patch patch-here
    set mass random seed-mass
    set color pink
    set inbreeding-load 4
  ]] ;; end of first ifelse
   ;; if more than 2 initial populations:
    [create-seeds N / initial-pops [ ;; create first population
    let random-x one-of patches with [count seeds in-radius 3 = 0] ;; look for a random patch that has no seeds in a radius of 3 patches from it, and set it as X
    set pop 1 ;; set population number to 1
    set shape "dot"
    ifelse (initial-mix = "Yes") ;; mix?
    [setxy random-pxcor random-pycor] ;; yes
    [setxy random-normal [pxcor] of random-x 2 random-normal [pycor] of random-x 2] ;; if no - place seed in a 2-patch radius from X
    set home-patch patch-here
    set mass random seed-mass
    set color violet
    set inbreeding-load 4
    set ms-a 2 set ms-b 2 set ms-c 2 set ms-d 2 set ms-e 2 set ms-f 2 set ms-g 2 set ms-h 2 set ms-i 2
  ]
     ; create second population
    create-seeds N / initial-pops [
    let random-x one-of patches with [count seeds in-radius 3 = 0]
    set pop 2
    set shape "dot"
    ifelse (initial-mix = "Yes") ;; Mix?
    [setxy random-pxcor random-pycor] ;; yes
    [setxy random-normal [pxcor] of random-x 2 random-normal [pycor] of random-x 2] ;; no
    set home-patch patch-here
    set mass random seed-mass
    set color pink
    set inbreeding-load 4

  ]
    let m 1 ;; to create populations 3 +, start by making a temp variable named m and set it to 1
  while [m <= (initial-pops - 2 )] [ ;; while m is smaller or equal to the number of populations minus the first two populations:
  let a one-of [0 2] let b one-of [0 2] let c one-of [0 2] let d one-of [0 2] let e1 one-of [0 2] let f one-of [0 2] let g one-of [0 2] let h one-of [0 2] let i one-of [0 2] ;; create a random but homozygote genome
  create-seeds N / initial-pops [
    let random-x one-of patches with [count seeds in-radius 1 = 0]
    set pop m + 2
    set shape "dot"
    ifelse (initial-mix = "Yes") ;; Mix?
    [setxy random-pxcor random-pycor] ;; yes
    [setxy random-normal [pxcor] of random-x 0.5 random-normal [pycor] of random-x 0.5] ;; no
    set home-patch patch-here
    set mass random seed-mass
    set color ( 15 * m )
    set inbreeding-load 4
    set ms-a a set ms-b b set ms-c c set ms-d d set ms-e e1 set ms-f f set ms-g g set ms-h g set ms-i i
    ]
    set m m + 1
  ]]
end ;; end population setup

to establish ;; beginning of to-establish
  ask patches with [any? seeds-here] [ ; Ask patches with any seeds on them:
      ifelse (random-float 1.0 < q) ; in probability q
    [ask max-one-of seeds-here [mass] [ ; heaviest seed in each patch establishes (or 1 random seed out of all the heaviest seeds)
      hatch-plants 1 [ ; the chosen seed hatches a plant
        set shape "flower" ; give the plant a flower shape
      set size 1 ;  set its size
        ]
      ask other seeds-here [die] ; and the rest of the seeds in the patch die
      die ; the established seed dies
      ]]
      [ask n-of 1 seeds-here [hatch-plants 1 [ ; if the above condition is not fulfilled, one random seed establishes and turns to a plant
        set shape "flower" ; give the plant a flower shape
      set size 1 ; set its size
        ]
      ask other seeds-here [die] ; and the others die
      die ; the established seed dies

      ]]]
  ask plants [
    if (random-float 1.0 > 1 - random-extinction) [die] ; randomly kill random-extinction % of all plants
  ]
  ask patches with [count plants-here < 1] [set pcolor brown] ; color patches with no plants in brown
  ask patches with [count plants-here = 1] [set pcolor green + 2] ; color patches with plants in green
  display ; update the display
end ;; end of to establish

to produce-gametes ;; beginning of to-produce-gametes
    ask plants [ ;; ask all plants
  hatch-gametes random-poisson gametes-number [ ;; to produce X gametes. X is a number drawn from a poisson distribution (chose it because it's appropriate for discrete data) with mean and sd determined by a slider
    set shape "x" ;; set shape to X
    ;; to inherit genome:
      ifelse ([ms-a] of myself = 2) [set allele-a 1] ;; if the plant producing the gamete is homozygote 11 in microsattelite a give the gamete allele 1 in this microsattelite
      [if ([ms-a] of myself = 1) [set allele-a (one-of [1 0])]] ;; if it is heterozygote, give either 1 or 0 randomly
                                                                ;; if both above conditions are not satisfied, 0 will be given automatically
    ;; the same as above, for the rest of the microsattelites:
      ifelse ([ms-b] of myself = 2) [set allele-b 1]
      [if ([ms-b] of myself = 1) [set allele-b (one-of [1 0])]]
      ifelse ([ms-c] of myself = 2) [set allele-c 1]
      [if ([ms-c] of myself = 1) [set allele-c (one-of [1 0])]]
      ifelse ([ms-d] of myself = 2) [set allele-d 1]
      [if ([ms-d] of myself = 1) [set allele-d (one-of [1 0])]]
      ifelse ([ms-e] of myself = 2) [set allele-e 1]
      [if ([ms-e] of myself = 1) [set allele-e (one-of [1 0])]]
      ifelse ([ms-f] of myself = 2) [set allele-f 1]
      [if ([ms-f] of myself = 1) [set allele-f (one-of [1 0])]]
      ifelse ([ms-g] of myself = 2) [set allele-g 1]
      [if ([ms-g] of myself = 1) [set allele-g (one-of [1 0])]]
      ifelse ([ms-h] of myself = 2) [set allele-h 1]
      [if ([ms-h] of myself = 1) [set allele-h (one-of [1 0])]]
      ifelse ([ms-i] of myself = 2) [set allele-i 1]
      [if ([ms-i] of myself = 1) [set allele-i (one-of [1 0])]]

    set parent myself ;; keep track of who the parent plant is. Will be used later to prevent self-pollination.
  ]]
end ;; end of to produce-gametes

to produce-pollen ;; beginning of to produce-pollen
    ask plants [ ;; ask all plants
    hatch-pollens random-poisson gametes-number * 2 [ ;; to produce X pollen grains. X is a number drawn from a poisson distribution (chose it because it's appropriate for discrete data) with mean and sd determined by a slider
    set shape "dot" ;; set shape to O
    set pollinated? false ;; create a logical variable that tells whether this grain was alredy used for pollination. Set it initially to false. This is later used to make sure each grain is only used once.
    ;; to inherit genome:
      ifelse ([ms-a] of myself = 2) [set allele-a 1] ;; if the plant producing the gamete is homozygote 11 in microsattelite a give the gamete allele 1 in this microsattelite
      [if ([ms-a] of myself = 1) [set allele-a (one-of [1 0])]] ;; if it is heterozygote, give either 1 or 0 randomly
                                                                ;; if both above conditions are not satisfied, 0 will be given automatically
    ;; the same as above, for the rest of the microsattelites:
      ifelse ([ms-b] of myself = 2) [set allele-b 1]
      [if ([ms-b] of myself = 1) [set allele-b (one-of [1 0])]]
      ifelse ([ms-c] of myself = 2) [set allele-c 1]
      [if ([ms-c] of myself = 1) [set allele-c (one-of [1 0])]]
      ifelse ([ms-d] of myself = 2) [set allele-d 1]
      [if ([ms-d] of myself = 1) [set allele-d (one-of [1 0])]]
      ifelse ([ms-e] of myself = 2) [set allele-e 1]
      [if ([ms-e] of myself = 1) [set allele-e (one-of [1 0])]]
      ifelse ([ms-f] of myself = 2) [set allele-f 1]
      [if ([ms-f] of myself = 1) [set allele-f (one-of [1 0])]]
      ifelse ([ms-g] of myself = 2) [set allele-g 1]
      [if ([ms-g] of myself = 1) [set allele-g (one-of [1 0])]]
      ifelse ([ms-h] of myself = 2) [set allele-h 1]
      [if ([ms-h] of myself = 1) [set allele-h (one-of [1 0])]]
      ifelse ([ms-i] of myself = 2) [set allele-i 1]
      [if ([ms-i] of myself = 1) [set allele-i (one-of [1 0])]]

    set parent myself ;; keep track of who the parent plant is. Will be used later to prevent self-pollination.
   ]]
end ;; end of to produce-pollen

to produce-seeds ;; beginning of to produce seeds
  ask plants [ ;; ask each plant
let the-patches patch-set ( list ;; to make the following list of patches:
      (up-to-n-of number-of-donors neighbors with [any? plants]) ;; n neighboring plants, where n is the number of donors as set in the main screen
      (up-to-n-of (number-of-donors / 2) patches with [(distance myself) >= 2  and (distance myself) < neighborhood-size / 2  and any? plants]) ;; n/2 plants in distance class 2, which is a function of the neighborhood size as set in the main screen
      (up-to-n-of (number-of-donors / 4) patches with [(distance myself) >= 3  and (distance myself) < neighborhood-size  and any? plants]) ) ;; n/4 plants in distance class 3, which is a function of the neighborhood size as set in the main screen
let the-pollens [pollens-here] of the-patches ;; take all pollen grains found on the patches in the above-mentioned patches-list
let the-pollens-set turtle-set the-pollens ;; and put them in an agentset

    ask gametes with [parent = myself] [ ;; each plant asks each of its gametes
let pollinator one-of the-pollens-set with [pollinated? = false and parent != [ parent ] of myself] ;; to find one pollen grain from the pollens agentset, who has not been used for pollination before, and who was not produced by this plant
  hatch-seeds 1 [ ;; and to produce one seed
    if (pollinator = nobody) [die] ;; if there is no pollen donor, the seed dies
      set shape "dot" ;; set seed's shape
        ;; set genotype: sum the alleles in each locus of the gamete and of the pollen grain
        set ms-a [allele-a] of myself + [allele-a] of pollinator
        set ms-b [allele-b] of myself + [allele-b] of pollinator
        set ms-c [allele-c] of myself + [allele-c] of pollinator
        set ms-d [allele-d] of myself + [allele-d] of pollinator
        set ms-e [allele-e] of myself + [allele-e] of pollinator
        set ms-f [allele-f] of myself + [allele-f] of pollinator
        set ms-g [allele-g] of myself + [allele-g] of pollinator
        set ms-h [allele-h] of myself + [allele-h] of pollinator
        set ms-i [allele-i] of myself + [allele-i] of pollinator

        ask pollinator [set pollinated?  True] ;; set the pollen-grain's as pollinated, so it will not be used for pollination again

    let homozygosity 0 ;; setup a homozygosity variable, set its level to 0.
    ;; look at each locus. If the sum of both alleles is either 0 or 2, it means it is homozygous in this locus. In such case, add 1 to homozygosity level
    if (ms-a = 0 or ms-a = 2) [set homozygosity homozygosity + 1 ]
    if (ms-b = 0 or ms-b = 2) [set homozygosity homozygosity + 1 ]
    if (ms-c = 0 or ms-c = 2)  [set homozygosity homozygosity + 1 ]
    if (ms-d = 0 or ms-d = 2)  [set homozygosity homozygosity + 1 ]
    if (ms-e = 0 or ms-e = 2)  [set homozygosity homozygosity + 1 ]
    if (ms-f = 0 or ms-f = 2)  [set homozygosity homozygosity + 1 ]
    if (ms-g = 0 or ms-g = 2)  [set homozygosity homozygosity + 1 ]
    if (ms-h = 0 or ms-h = 2)  [set homozygosity homozygosity + 1 ]
    if (ms-i = 0 or ms-i = 2)  [set homozygosity homozygosity + 1 ]


    set inbreeding 1 - e ^ ( - homozygosity * mass-reduction ) ;; when mass-reduction = 0 -> inbreeding = 0 | when mass-reduction = 1 -> inbreeding increases logarithmically
    set mass ( random-normal (seed-mass * (1 - inbreeding)) (seed-mass * (1 - inbreeding) / 4) ) ;; set seed mass as a random number with mean determined by a slider and as a function of the seed's inbreeding level
    ;; color seeds according to their homozygosity levels, so they can be tracked in the different plots:
      if (homozygosity >= 0 and homozygosity <= 1 ) [set color scale-color blue inbreeding (- 9 ) (9 ) set inbreeding-load 0]
      if (homozygosity > 1 and homozygosity <= 3 ) [set color scale-color green inbreeding (-9) (9 ) set inbreeding-load 1]
      if (homozygosity > 3 and homozygosity <= 5 ) [set color scale-color red inbreeding (-9) (9) set inbreeding-load 2]
      if (homozygosity > 5 and homozygosity <= 7 ) [set color scale-color orange inbreeding (-9) (9) set inbreeding-load 3]
      if (homozygosity > 7 and homozygosity <= 9 ) [set color scale-color yellow inbreeding (-9) (9) set inbreeding-load 4]

        set inbreeding inbreeding * 10 ;; since 0 < inbreeding < 1, and I want to plot histograms, I multiply it by 10.
      ]


      die ;; the gamete that produced the seed dies.
  ]
  ]
end ;; end of to produce-seeds

to disperse-seeds ;; beginning of to disperse
  ask pollens [die] ;; kill all pollen grains
    ask seeds [ ;; ask each seed
   set home-patch patch-here ;; to record their home-patch (to calculate dispersal distance later on)
    if (mass > 0) [ ;; if the seed has a mass of 0 or less, it does not disperse
    rt random 360 ;; choose a random dispersal direction
  forward ( random-normal dispersal-distance dispersal-distance) / mass ;; move (X / mass) units. X is a number drawn from a normal distribution who's mean and var are controlable by a slider
      set distance-travelled distancexy ([pxcor] of home-patch) ([pycor] of home-patch) ;; after dispersal, calculate dispersal distance by measuring the distance between the current patch and the home patch
  ]]
end ;; end of to disperse

to kill-parents ;; beginning of to kill-parents
  ask plants [die] ;; ask all seeds to die
end ;; end of kill-parents

to sgs ;; beginning of to sgs - to calculate spatial genetic structure
ask plants [ ;; ask each plant
  let other-plants (other plants) ;; make a temporary list of all other plants
  set genetic-distances [] ;; set an empty list of genetic distances
  set geographic-distances [] ;; set an empty list of geographic distances
  set distances-list [] ;; set an empty list of distances

  foreach sort other-plants [ [candidate] -> ;; go through all the plants in the other-plants list, one by one
    let genetic-distance 0 ;; make a temp variable named genetic-distance, set it to 0

    ifelse (abs([ms-a] of candidate - ms-a) = 2) [set genetic-distance genetic-distance + (1 / 9)] ;; if both plants are homozygote, but each one has different alleles (so one is 00 and one is 22), add 1 to the value of genetic distance
    [if (abs([ms-a] of candidate - ms-a) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]] ;; if both plants have only one allele in common, add 0.5 to the value of genetic distance. If both conditions are not fulfilled, genetic distance will remain in its' previous value
                                                                                                   ;; repeat for all microsattelites:
    ifelse (abs([ms-b] of candidate - ms-b) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-b] of candidate - ms-b) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-c] of candidate - ms-c) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-c] of candidate - ms-c) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-d] of candidate - ms-d) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-d] of candidate - ms-d) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-e] of candidate - ms-e) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-e] of candidate - ms-e) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-f] of candidate - ms-f) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-f] of candidate - ms-f) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-g] of candidate - ms-g) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-g] of candidate - ms-g) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-h] of candidate - ms-h) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-h] of candidate - ms-h) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-i] of candidate - ms-i) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-i] of candidate - ms-i) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    set genetic-distances lput precision (genetic-distance) 3 genetic-distances ;; add the calculated genetic distance to a list of all genetic distances
    set geographic-distances lput precision ([distance myself] of candidate) 3 geographic-distances ;; calculate the geographic distance between the two plants, and add this value to a list of all geographic distances
    set distances-list (list genetic-distances geographic-distances) ;; make a list of the previous two lists

  ]

  set-current-plot "spatial genetic structure" ;; to plot the spatial genetic structure of an individual:

  let m 0 ;; make a temp variable, for plotting purposes
  while [m < length distances-list ] ;; m is the same size as the above-mentioned lists

  [plotxy item m geographic-distances item m genetic-distances ;; go over each row in the list, and plot its' position on a scatter-plot, where x is the geographic distance and y is the genetic distance.
    set m m + 1] ;; move to the next row

]

end ;; end of to-sgs

to-report ind-sgs [plant-a candidate] ;; make a reporter so I can monitor the calculation of the sgs.


  let genetic-distance 0
  let geographic-distance 0

ask plant-a [


    ifelse (abs([ms-a] of candidate - ms-a) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-a] of candidate - ms-a) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-b] of candidate - ms-b) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-b] of candidate - ms-b) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-c] of candidate - ms-c) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-c] of candidate - ms-c) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-d] of candidate - ms-d) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-d] of candidate - ms-d) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-e] of candidate - ms-e) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-e] of candidate - ms-e) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-f] of candidate - ms-f) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-f] of candidate - ms-f) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-g] of candidate - ms-g) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-g] of candidate - ms-g) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-h] of candidate - ms-h) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-h] of candidate - ms-h) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

    ifelse (abs([ms-i] of candidate - ms-i) = 2) [set genetic-distance genetic-distance + (1 / 9)]
    [if (abs([ms-i] of candidate - ms-i) = 1) [set genetic-distance genetic-distance + (0.5 / 9)]]

set geographic-distance distance candidate
 ]
let output (word "geographic: " precision geographic-distance 3 " genetic: " precision genetic-distance 3)

  report output

end
@#$#@#$#@
GRAPHICS-WINDOW
0
10
432
443
-1
-1
20.2
1
10
1
1
1
0
1
1
1
-10
10
-10
10
1
1
1
ticks
10.0

BUTTON
837
421
900
454
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

BUTTON
1012
416
1075
449
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

SLIDER
786
468
958
501
N
N
2
500
82.0
2
1
NIL
HORIZONTAL

BUTTON
1088
416
1163
449
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
816
11
1237
221
establishment rates
ticks
establishment rate
0.0
10.0
0.0
0.5
true
true
"" "if (gametes-number > 0) [ set-plot-y-range 0 precision ( 1 /  gametes-number ) 3 ]"
PENS
"inbreeding = 4" 1.0 0 -4079321 true "" "if (ticks > 2) [plot count plants with [inbreeding-load = 4 ] / count seeds with [inbreeding-load = 4 ] ]"
"inbreeding = 3" 1.0 0 -955883 true "" "if (ticks > 2) [plot count plants with [ inbreeding-load = 3 ] / count seeds with [inbreeding-load = 3 ] ]"
"inbreeding = 2" 1.0 0 -2674135 true "" "if (ticks > 2) [plot count plants with [ inbreeding-load = 2 ] / count seeds with [inbreeding-load = 2 ] ]"
"inbreeding = 1" 1.0 0 -10899396 true "" "if (ticks > 2) [plot count plants with [ inbreeding-load = 1 ] / count seeds with [inbreeding-load = 1 ] ]"
"inbreeding = 0" 1.0 0 -13345367 true "" "if (ticks > 2) [plot count plants with [ inbreeding-load = 0 ] / count seeds with [inbreeding-load = 0 ] ]"
"total" 1.0 0 -16777216 true "" "if (ticks > 2) [plot count plants / count seeds ]"

SLIDER
1005
505
1177
538
seed-mass
seed-mass
1
20
8.0
1
1
NIL
HORIZONTAL

SLIDER
1006
587
1178
620
neighborhood-size
neighborhood-size
1
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
1005
463
1177
496
gametes-number
gametes-number
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
1004
633
1176
666
dispersal-distance
dispersal-distance
0
30
4.0
1
1
NIL
HORIZONTAL

PLOT
1244
10
1466
131
Total
distance travelled
# seeds
0.0
10.0
0.0
10.0
true
false
"" "if (count seeds > 0) [set-plot-y-range 0 count seeds]"
PENS
"default" 1.0 1 -16777216 true "" "histogram [distance home-patch] of seeds"

PLOT
1244
377
1465
497
Inbreeding = 2
distance travelled
# seeds
0.0
10.0
0.0
10.0
true
false
"" "if (count seeds with [inbreeding-load = 2] > 0) [set-plot-y-range 0 count seeds with [inbreeding-load = 2]]"
PENS
"inbreeding = 2" 1.0 1 -2674135 true "" "histogram [distance home-patch] of seeds with [ inbreeding-load = 2] "

PLOT
1245
498
1466
618
Inbreeding = 1
distance travelled
# seeds
0.0
10.0
0.0
10.0
true
false
"" "if (count seeds with [inbreeding-load = 1] > 0) [set-plot-y-range 0 count seeds with [inbreeding-load = 1]]"
PENS
"default" 1.0 1 -13840069 true "" "histogram [distance home-patch] of seeds with [ inbreeding-load = 1 ]"

PLOT
1245
620
1467
740
Inbreeding = 0
distance travelled
# seeds
0.0
10.0
0.0
10.0
true
false
"" "if (count seeds with [inbreeding-load = 0] > 0) [set-plot-y-range 0 count seeds with [inbreeding-load = 0]]"
PENS
"default" 1.0 1 -13345367 true "" "histogram [distance home-patch] of seeds with [ inbreeding-load = 0]"

SLIDER
790
572
962
605
initial-gap
initial-gap
0
10
0.0
1
1
NIL
HORIZONTAL

CHOOSER
806
512
944
557
Initial-mix
Initial-mix
"Yes" "No"
0

PLOT
1469
377
1678
497
realized kernel inbreeding = 2
distance travelled
# plants
0.0
10.0
0.0
10.0
true
false
"" "if (count plants with [inbreeding-load = 2] > 0) [set-plot-y-range 0 count plants with [inbreeding-load = 2] ]"
PENS
"default" 1.0 1 -2674135 true "" "histogram [distance home-patch] of plants with [ inbreeding-load = 2] "

PLOT
1470
498
1677
618
realized kernel inbreeding = 1
distance travelled
# plants
0.0
10.0
0.0
10.0
true
false
"" "if (count plants with [inbreeding-load = 1] > 0) [set-plot-y-range 0 count plants with [inbreeding-load = 1] ]"
PENS
"default" 1.0 1 -14439633 true "" "histogram [distance home-patch] of plants with [ inbreeding-load = 1 ]"

PLOT
1471
619
1678
739
realized kernel inbreeding = 0
distance travelled
# plants
0.0
10.0
0.0
10.0
true
false
"" "if (count plants with [inbreeding-load = 0] > 0) [set-plot-y-range 0 count plants with [inbreeding-load = 0] ]"
PENS
"default" 1.0 1 -14070903 true "" "histogram [distance home-patch] of plants with [ inbreeding-load = 0 ]"

PLOT
1467
10
1676
130
realized kernel
distance travelled
# plants
0.0
10.0
0.0
10.0
true
false
"" "if (count plants > 2) [set-plot-y-range 0 count plants]"
PENS
"default" 1.0 1 -16777216 true "" "histogram [distance home-patch] of plants"

BUTTON
315
516
395
550
untrace
clear-drawing\nask turtles [pen-erase]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
196
516
309
550
trace dispersal
ask up-to-n-of 100 seeds with [inbreeding-load = 0] [pd]\nask up-to-n-of 100 seeds with [inbreeding-load = 1] [pd]\nask up-to-n-of 100 seeds with [inbreeding-load = 2] [pd]\nask up-to-n-of 100 seeds with [inbreeding-load = 3] [pd]\nask up-to-n-of 100 seeds with [inbreeding-load = 4] [pd]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
1244
256
1465
376
inbreeding = 3
distance travelled
# seeds
0.0
10.0
0.0
10.0
true
false
"" "if (count seeds with [inbreeding-load = 3] > 0) [set-plot-y-range 0 count seeds with [inbreeding-load = 3]]"
PENS
"default" 1.0 1 -955883 true "" "histogram [distance home-patch] of seeds with [ inbreeding-load = 3]"

PLOT
1468
256
1676
376
realized kernel inbreeding = 3
distance travelled
# plants
0.0
10.0
0.0
10.0
true
false
"" "if (count plants with [inbreeding-load = 3]  > 0) [set-plot-y-range 0 count plants with [inbreeding-load = 3] ]"
PENS
"default" 1.0 1 -955883 true "" "histogram [distance home-patch] of plants with [ inbreeding-load = 3 ]"

BUTTON
0
472
80
506
NIL
establish
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
81
472
269
506
produce gametes and pollen
produce-gametes\nproduce-pollen
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
270
472
384
506
NIL
produce-seeds
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
387
472
502
506
NIL
disperse-seeds
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
503
472
596
506
NIL
kill-parents
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
1004
681
1177
714
q
q
0
1
0.0
0.05
1
NIL
HORIZONTAL

PLOT
513
10
815
221
plant quantities
ticks
number of plants
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -4079321 true "" "plot count plants with [inbreeding-load = 4 ]"
"pen-1" 1.0 0 -955883 true "" "plot count plants with [inbreeding-load = 3 ]"
"pen-2" 1.0 0 -2674135 true "" "plot count plants with [inbreeding-load = 2 ]"
"pen-3" 1.0 0 -10899396 true "" "plot count plants with [inbreeding-load = 1 ]"
"pen-4" 1.0 0 -13345367 true "" "plot count plants with [inbreeding-load = 0 ]"

SLIDER
1003
722
1176
755
random-extinction
random-extinction
0
1
0.35
0.05
1
NIL
HORIZONTAL

PLOT
1244
133
1464
253
inbreeding = 4
distance travelled
# seeds
0.0
10.0
0.0
10.0
true
false
"" "if (count seeds with [inbreeding-load = 4] > 0) [set-plot-y-range 0 count seeds with [inbreeding-load = 4]]"
PENS
"default" 1.0 1 -4079321 true "" "histogram [distance home-patch] of seeds with [ inbreeding-load = 4]"

PLOT
1469
133
1675
253
realized kernel inbreeding = 4
distance travelled
# plants
0.0
10.0
0.0
10.0
true
false
"" "if (count plants with [inbreeding-load = 4] > 0) [set-plot-y-range 0 count plants with [inbreeding-load = 4] ]"
PENS
"default" 1.0 1 -4079321 true "" "histogram [distance home-patch] of plants with [ inbreeding-load = 4 ]"

SLIDER
1003
768
1176
801
mass-reduction
mass-reduction
0
1
0.15
0.05
1
NIL
HORIZONTAL

PLOT
513
223
933
406
mean dispersal distance
ticks
dispersal distance
0.0
4.0
0.0
1.0
true
false
"" "if (ticks > 2) [set-plot-y-range precision (mean [distance-travelled] of seeds * 0.8) 2 precision (mean [distance-travelled] of seeds * 1.2) 2]"
PENS
"inbreeding = 4" 1.0 0 -7171555 true "" "if (any? seeds with [inbreeding-load = 4]) [ plotxy ticks mean [distance-travelled] of seeds with [inbreeding-load = 4] ]"
"pen-1" 1.0 0 -955883 true "" "if (any? seeds with [inbreeding-load = 3]) [ plotxy ticks mean [distance-travelled] of seeds with [inbreeding-load = 3] ]"
"pen-2" 1.0 0 -2674135 true "" "if (any? seeds with [inbreeding-load = 2]) [ plotxy ticks mean [distance-travelled] of seeds with [inbreeding-load = 2] ]"
"pen-3" 1.0 0 -10899396 true "" "if (any? seeds with [inbreeding-load = 1]) [ plotxy ticks mean [distance-travelled] of seeds with [inbreeding-load = 1] ]"
"pen-4" 1.0 0 -13345367 true "" "if (any? seeds with [inbreeding-load = 0]) [ plotxy ticks mean [distance-travelled] of seeds with [inbreeding-load = 0] ]"

MONITOR
1684
18
1759
63
plants total
count plants
17
1
11

MONITOR
1685
68
1759
113
seeds total
count seeds
17
1
11

MONITOR
1683
139
1814
184
plants inbreeding = 4
count plants with [inbreeding-load = 4]
17
1
11

MONITOR
1685
190
1814
235
seeds inbreeding = 4
count seeds with [inbreeding-load = 4]
17
1
11

MONITOR
1688
269
1819
314
plants inbreeding = 3
count plants with [inbreeding-load = 3]
17
1
11

MONITOR
1689
316
1818
361
seeds inbreeding = 3
count seeds with [inbreeding-load = 3]
17
1
11

MONITOR
1689
388
1820
433
plants inbreeding = 2
count plants with [inbreeding-load = 2]
17
1
11

MONITOR
1690
436
1819
481
seeds inbreeding = 2
count seeds with [inbreeding-load = 2]
17
1
11

MONITOR
1691
512
1822
557
plants inbreeding = 1
count plants with [inbreeding-load = 1]
17
1
11

MONITOR
1691
559
1820
604
seeds inbreeding = 1
count seeds with [inbreeding-load = 1]
17
1
11

MONITOR
1689
628
1820
673
plants inbreeding = 0
count plants with [inbreeding-load = 0]
17
1
11

MONITOR
1690
677
1819
722
seeds inbreeding = 0
count seeds with [inbreeding-load = 0]
17
1
11

PLOT
937
223
1235
406
spatial genetic structure
geographic distance
genetic distance
0.0
10.0
0.0
1.0
true
false
"" "clear-plot"
PENS
"default" 1.0 2 -16777216 true "" ""

SLIDER
1006
547
1178
580
number-of-donors
number-of-donors
0
20
6.0
1
1
NIL
HORIZONTAL

BUTTON
110
514
173
547
NIL
sgs
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
791
618
963
651
initial-pops
initial-pops
2
10
2.0
1
1
NIL
HORIZONTAL

PLOT
0
620
160
740
Mass inbreeding = 4
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" "if (count seeds with [inbreeding-load = 4] > 0) [set-plot-y-range 0 count seeds with [inbreeding-load = 4] ]"
PENS
"default" 1.0 1 -7171555 true "" "histogram [mass] of seeds with [ inbreeding-load = 4 ]"

PLOT
165
621
325
741
Mass inbreeding = 0
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" "if (count seeds with [inbreeding-load = 0] > 0) [set-plot-y-range 0 count seeds with [inbreeding-load = 0] ]"
PENS
"default" 1.0 1 -13345367 true "" "histogram [mass] of seeds with [ inbreeding-load = 0 ]"

PLOT
351
622
533
742
plants inbreeding
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [inbreeding] of plants"

PLOT
534
622
721
742
seeds inbreeding
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [inbreeding] of seeds"

@#$#@#$#@
# ▶ How to run this model

**This model must be initialized before it will do anything.**

1. Click **`setup`** — you should see flower-shaped plants appear on green patches across the landscape.
2. Then click **`go`** — the simulation runs generation by generation (establishment → pollination → seed production → dispersal → mortality), and the plots fill in.

> If you click **`go`** *before* **`setup`**, the world is empty: `go` has no plants or seeds to act on, so it simply colors every patch brown ("no plant here") and advances the tick counter — it looks like nothing is happening. Always run **`setup`** first.

---

# My Model Description


## 1. Purpose and patterns
_The aim_ of the model is to study the long-term effects and dynamics of the effects of relatedness on dispersal-strategies, and the potential feedback loop with the population's spatial genetic structure.

**Background:** Seed dispersal is a crucial life-history stage in the life cycle of plants, which can have significant impacts on fitness, and is thus potentially subjected to natural selection. The evoltuoin of dispersal kernels is likely shaped by multiple selection pressures, simultaneously selecting for and against dispersal, and the balance between the different costs and benefits associated with it. For example, there may be selection for increased dispersal distances due to kin competition, but selection for decreased dispersal distances due to local adaptations.
Theoretically, another potential source of complexity may rise from the fact that in plants dispersal is maternally-controlled (the dispersal unit is maternally constructed), and as siring by multiple pollen donors is ubiquitous in many plant species, levels of relatedness between the mother-plant to the seeds, as well as among the seeds, may vary. Under such circumctances, it may be advantagous to allocate different seeds to different dispersal distances, based on levels of relatedness. For example, if local adapataions are a strong selective force in the system, it may be more advantagous to have the seeds that are more similar to the mother plant
Here I (wish to) model the long-term dynamics 
The model is ment to elaborate on results of a common-garden experiment, in which we have conducted manual cross-pollinations using pollen donors of increasing geographic distances (self, kin, near neighbors, distant neighbors, etc.), working under the assumption that geographic distance is a proxy of genetic distance (isolation by distance). In this work we found that with distance there is an increase in the mass of the produced seeds, and thus a decrease in their dispersal potential. Theoretically, this may be caused by an inbreeding load that causes seed mass reduction.


#### Research questions: 
  * Does a relatedness-dependent dispersal strategy contribute to the maintenence of low inbreeding levels?
  * Is there an advantage in a dispersal strategy that is relatedness-dependent?
  * What is the spatial-genetic struture of a population that has a relatedness-dependent dispersal strategy?

#### Predictions:

  * If relatedness between parent-plants affects dispersal distances, and since pollination is distance dependent, overall inbreeding levels and levels of kin competition will be reduced, and the spatial genetic structure will be weak.
    * _To test this prediction:_ Run simulations with and without effect of relatedness on dispersal distance
    * Compare spatial genetic structures after X generations
    * compare fitness of relatedness-dependent and relatedness-independent dispersal strategies (proportion of established offspring)

  * A relatedness-dependent dispersal strategy will be superior to a relatedness-independent dispersal strategy, due to the negative effects of inbreeding depression
    * _To test this prediction:_ Run simulations where individuals that have a relatedness-dependent dispersal strategy “compete” with individuals who have a relatedness-independent dispersal strategy 
    * see which strategy takes over 
    * Maybe not one will take over, but both will co-exist. In such case, see what long-term dynamics emerge between the two strategies. Do we reach a stable state?

## 2. Entities, State Variables, and Scales
 

There are 5 entities in the model: patches, plants, pollen-grains, female gametes and seeds.
Plants are annual, wind-dispersed and wind-pollinated, outcrossed-only.

#### State variables:
•	Patches – location
•	_Seeds_ have the following variables: home patch (the patch of the mother plant), current patch (the patch to which the seed was dispersed), mass, diploid genome (9 diallelic genes)
•	Plants – have the same variables as seeds
•	Pollen grains - parent plant, haploid ggenome and an indicator for whether or not it was already used for pollination
•	Female gametes - parent plant and a haploid genome.


#### Scales 
One time-step equals to one life-time unit. I am not sure about the extent at this point. 
One grid cell represents a habitat suitable for 1 individual. Again, unsure about the extent.




## 3. Process Overview and Scheduling

In each time step: 

  1. Establishment: In each cell, if it has at least one seed in it, the seed with the highest mass turns to a plant in probability q, or one seed is randomly chosen in a probability of 1-q. If more than one seed has the highest mass, one of them is randomly chosen. After establishment all seeds die, and a certain percentage of established plants are randomly chosen and die as well (this proportion can be manipulated using a slider).

  2. Production of reproduction units: Plants produce female gametes and pollen grains. The number of gametes and grains produced by each individual is drawn from a Poisson-distribution with mean that can be manipulated using a slider. Each gamete and grain inherit half of their parent’s genotype, so they are haploid. 

  3. Pollination: Each plant collects pollen from other plants in a distance-dependent manner. The number of potential donors and the neighborhood-size (max distance of allowable donors) can be manipulated using sliders). Then, each gamete of the plant randomly chooses one of the not previously used collected grains, to produce a seed. The seed inherits one set of alleles from the gamete and one from the grain, thus it has a diploid genome. Then, levels of inbreeding are calculated as a function of homozygosity levels (non-linear relationship between homozygosity and inbreeding. The exact shape of the function can be manipulated with a slider) . Then, seed mass is given by drawing a random number from a normal distribution with mean and variance that are manipulatable using a slider and as a factor of inbreeding levels. Finally, for plotting purposes, the plants are given colors as a function of inbreeding levels.

  4. Dispersal: Each seed disperses in a random direction and to a distance that is a function of its’ mass and a value drawn from a normal distribution with mean and var that are controllable using a slider.

  5. After seed dispersal, all mature plants in the landscape die

  6. Spatial genetic structure estimation: each plant calculates its’ genetic distance from all other plants by comparing their genomes and seeing in how many microsatellites they are identical. Then geographic distance is measured, and a plot is made (but for only one individual at this point).


## 4. Design Concepts
 

## 5. Initialization
 
X Seeds of X populations are created. Populations differ in their genotype, so that all individuals within each population have the same initial genotype. 
One population is completely homozygote, one is completely heterozygote, and the others (if any) are randomly assigned with intermediate levels
The seeds are either randomly dispersed in the landscape, or are aggregated by population.
Seeds turn to plants (or die) in cells (one per cell maximum), according to their mass relative to the mass of all other seeds within the cell (heaviest seed establishes).

## 6. Input Data
 
## 7. Submodels

#### To population setup(If initial-populations = 2 )
```
Create N/2 seeds ;; to create the first population
 If Initial-mix = yes -> Move each seed to a random patch
 If Initial-mix = no -> Move each seed to a random patch with a y-coordinate larger than initial-gap
 Set each seed’s home-patch as the current patch it’s on
 Set mass a random number up to seed-mass
 Set inbreeding-load 4
 Set all alleles in the genotype to 2 (the sum of both alleles, where each allele is either 0 or 1)

Create N/2 seeds ;; to create the second population
 If Initial-mix = yes -> Move each seed to a random patch
 If Initial-mix = no -> Move each seed to a random patch with a y-coordinate smaller than initial-gap
 Set each seed’s home-patch as the current patch it’s on
 Set mass a random number up to seed-mass
 Set inbreeding-load 4
 Set all alleles in the genotype to 0 (the sum of both alleles, where each allele is either 0 or 1)
```

#### To population setup (If initial-populations > 2)
```
Create N/initial-populations seeds ;; create pop 1
 Let random-x be one of the patches with no seeds around it in a radius of 3 cells
 Set pop to 1
 If initial-mix = yes -> place each seed in a random cell 
 otherwise, set x and y coordinates as number drawn from a normal distribution with a mean of random-x and variance of 2
 Set each seed’s home-patch as the current patch it’s on
 Set mass a random number up to seed-mass
 Set inbreeding-load 4
 Set all alleles in the genotype to 2 (the sum of both alleles, where each allele is either 0 or 1)

Create N/initial-populations seeds ;; create pop 2
 Let random-x be one of the patches with no seeds around it in a radius of 3 cells
 Set pop to 1
 If initial-mix = yes -> place each seed in a random cell 
 otherwise, set x and y coordinates as number drawn from a normal distribution with a mean of random-x and variance of 2
 Set each seed’s home-patch as the current patch it’s on
 Set mass a random number up to seed-mass
 Set inbreeding-load 4
 Set all alleles in the genotype to 0 (the sum of both alleles, where each allele is either 0 or 1)

Let m = 1 ;; create populations 3 +
 While m <= (initials-populations – 2)
 Let a-f be either 0 or 2, randomly *used to give the whole population the same genotype*
 Create N/initial-populations seeds *create pop 3+*
 Let random-x be one of the patches with no seeds around it in a radius of 3 cells
 Set pop to m + 2
 If initial-mix = yes -> place each seed in a random cell 
 otherwise, set x and y coordinates as number drawn from a normal distribution with a mean of random-x and variance of 2
 Set each seed’s home-patch as the current patch it’s on
 Set mass a random number up to seed-mass
 Set inbreeding-load 4
 Set all alleles in the genotype according to a-f
```

#### To establish
```
Each patch that has seeds on it either asks the heaviest seed to turn into a plant, in probability q, or randomly chooses one of the seeds on it to establish, in a probability of 1-q. 
The chosen seed hatches one plant, and dies.
The rest of the seeds on the patch die.
A proportion of random-extinction plants in the landscape are randomly chosen and killed. 
Patches with a plant on them are colored green. Patches without a plant on them are colored brown.
```

#### To produce gametes
```
Each plant produces X gametes. X is a number randomly drawn from a Poisson distribution with a mean of gametes-number.
Each gamete inherits half of its parents alleles in the following manner:
 If ms-a of the mother-plant = 2, set allele-a of gamete to 1 
 If ms-a of the mother-plant = 1,  set allele-a of gamete to either 1 or 0 randomly 
 Otherwise, set allele-a of gamete to 0
 Repeat for allele-b to allele-i
Set parent as the mother-plant
```

#### To produce pollen
```
Each plant produces X pollen grains. X is a number randomly drawn from a Poisson distribution with a mean of gametes-number * 2.
Each pollen inherits half of its parents alleles in the following manner:
 If ms-a of the mother-plant = 2, set allele-a of gamete to 1 
 If ms-a of the mother-plant = 1,  set allele-a of gamete to either 1 or 0 randomly 
 Otherwise, set allele-a of gamete to 0
 Repeat for allele-b to allele-i
Set parent as the mother-plant
Set pollinated? False ;; used to account for whether the grain was already used for pollination or not
```

#### To produce seeds
```
Each plant makes a list of potential pollens found in patches according to the following conditions:
 Number-of-donors of immediate neighbors
 Number-of-donors / 2 of individuals found in a radius larger than 2 and smaller than neighborhood-size / 2
 Number-of-donors / 4 of individuals found in a radius larger than neighborhood-size / 2 and smaller than neighborhood-size
Each plant asks each of its gametes to take a random pollen-grain from the list, with pollinated? = false & parent-of-pollen != parent-of-gamete, and use it to create a seed.
 If there is no pollen grain that fulfills these conditions, the gamete dies
To create the seed’s genotype, I sum the value of alleles of the pollen and the gamete in each locus: ms-a of seed = allele-a of gamete + allele-a of pollen
Set the pollen’s pollinated? to True
To calculate homozygosity:
 If ms-a = 0 or 2, set homozygosity + 1
 Repeat for ms-b to ms-I
To calculate inbreeding:
 Inbreeding = 1 – e ^ ( - homozygosity * mass-reduction )
Set seed mass a number drawn from a normal distribution with a mean of seed-mass * ( 1 – inbreeding), and variance of seed-mass * (1 – inbreeding) / 4
To set inbreeding-load:
 If 0 <= homozygosity <= 1 set inbreeding-load 0
 If 1 < homozygosity <= 3 set inbreeding-load 1
 If 3 < homozygosity <= 5 set inbreeding-load 2
 If 5 < homozygosity <= 7 set inbreeding-load 3
 If 7 < homozygosity <= 9 set inbreeding-load 4
```

#### To disperse seeds
```
Ask pollens to die
Ask seeds to set home-patch to the current patch they’re on
If mass > 0 
 turn to a random direction
 Move forward X / mass cells. X is a number drawn from a poisson distribution with a mean of dispersal-distance
Set distance-travelled as the distance from current patch to home-patch
```

#### To kill parents
```
ask plants to die
```

#### To calculate spatial genetic structure
```
Ask each plant to make a list of all other plants
For each plant on the list, calculate genetic distance:
 If |ms-a-of-other-plant – ms-a-of-myself| = 2, set genetic-distance + 1/9
 If |ms-a-of-other-plant – ms-a-of-myself| = 1, set genetic-distance + 0.5/9
 Repeat for ms-b to ms-i
Calculate geographic-distance as the eucalidean distance between the two plants
Put both values in a list
Repeat for all plants
```

## 8. Things I need help with

  * Is there a more proper way to estimate relatedness? Like creating a pedigree of some sort?
    * Currently I am modelling relatedness by looking at homozygosity levels, but this is not really accurate, at least not with such few alleles. I could theoretically make 1,000 alleles instead of "just" 9, but I guess that would be computationally heavy.
    * Also, since I am using homozigosity levels for two purposes (calculating relatedness and assigning inbreeding-load which causes mass reduction), and this mix might have some artifacts I am not currently aware of.
  * Need to improve setup of multiple populations
    * The current way in which I am setting up the populations in the initialization phase is causing errors, especially when the landscape is small
  * How to output spatial genetic structure of all individuals, and not just one plant?
    * Currently I am only able to produce a plot for 1 plant. What I really want is to have a plot of mean sgs for all plants.
  * Improving speed of run?
    * Seems that right now I can only work on very small scales. Maybe I can increase the models' efficiency so I can work on larger landscapes?
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
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
@#$#@#$#@
0
@#$#@#$#@
