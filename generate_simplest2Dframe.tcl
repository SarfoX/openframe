# Simple 2D Frame
# Just to start checking on my 2D IDA concepts for frames
#
# Created 30/Nov/2011 by D. Vamvatsikos
#
wipe

source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/generate2DFrameNodes.tcl
source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/GetPeriodSetDamping.tcl
source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/units_constants_metric.tcl
source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/RunGravityAnalysis.tcl

source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/BuildRCrectSection.tcl

source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/DisplayModel2D.tcl

source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/DisplayPlane.tcl



model basic -ndm 2 -ndf 3

set nbayx 4

set nstory 3

#set sheight "[list 3.0 3.0 2.725]"

set sheight [list 3.0 3.0 2.725]

#set sheight [list 4.8 3.2 3.2 3.2]

set baylength [list 2.85 3.75 3.75 5.525]

#set baylength [expr 5*$m ]


#------------------------------------------------------------------------
# default analysis!
#set analysistype "eigenvalue"
#set analysistype "pushover"
set analysistype "dynamic"
#---------------------------
# Pushover load pattern is a*x^k, where x is height from ground and a is a normalizing constant
# if k=0 you get a uniform. If k=1 you get a linear pattern etc.
set pushoverLPk 2.0
#------------------------------------------------------------------------
# Frame geometry


# Offset for node and column numbers for every successive story. This allows for almost 100 bays
set csx 100
# Offset for beam numbering. This allows for nearly 100 floors :))
set Beoff 10000


#------------------------------------------------------------------------
# Source the optimization parameters for the bridge (e.g. number of spans)
# The standard file recreates the original Kavala in 2D
if {[file exists "MatIDA_paramfile.tcl"]} {
 puts "Using EXTERNAL parameter file for optimization (Matlab-generated)"
source standard_paramfile.tcl
} else {
  puts "Using STANDARD parameter file"
 source standard_paramfile.tcl
#}

#---------------------------------------------------------------------------
# Source the analysistype information. Better to have it in a distinct file.
if {[file exists "MatIDA_anlsfile.tcl"]} {
  puts "Reading EXTERNAL Analysistype file (Matlab-generated)"
  source MatIDA_anlsfile.tcl
}


#---------------------------
# Source the timehistory information to apply. The default
# file applies "HDA255.AT2.txt" and "HDA165.AT2.txt", upscaled by 7.5
# if another exists, then it is treated as if generated to run an IDA.
if {$analysistype=="dynamic" & [file exists "MatIDA_thfile.tcl"]} {
   set runIDAflag 1
   puts "Using EXTERNAL Timehistory data-file (Matlab-generated)"
   source MATIDA_thfile.tcl
} else {
   set runIDAflag 0
   puts "Using STANDARD Timehistory data-file"
   source standard_thfile.tcl
}
#--------------------------------




# max allowed subdivisions of dt (for variable transient) or standard subdivisions (for Transient)
set dtsub 1.0

# the equalDOFs seriously reduce the eigenmodes that can be calculated.
# Estimate up to 3 eigenvalues. It may fail for only one story. Careful.
if {$nstory<3} {
  set Neigen $nstory  
} else {
  set Neigen 3 	
}

geomTransf LinearInt 6

uniaxialMaterial Concrete01 8 [expr -10*$MPa] -0.002 0 -0.01
uniaxialMaterial Steel02 1003 [expr 250*$MPa] [expr 200000*$MPa] 0.02 20 0.9 0.2 0 0.1 0 0.1
uniaxialMaterial Steel02 1005 [expr 250*$MPa] [expr 200000*$MPa]  0.02 20 0.9 0.2 0 0.1 0 0.1

section FiberInt 5 -NStrip 1 [expr 0.15*$m] 1 [expr 0.15*$m] 1 [expr 0.15*$m] {
fiber [expr -1*0.15*$m] 0 [expr 0.15*0.15*$m2] 8
fiber [expr -1*0.15*$m] 0 [expr 2*$pi*16*$mm*16*$mm/4] 1003
fiber 0 0 [expr 0.15*0.15*$m2] 8
fiber 0 0 0 1003
fiber [expr 0.15*$m] 0 [expr 0.15*0.15*$m2] 8
fiber [expr 0.15*$m] 0 [expr 2*$pi*16*$mm*16*$mm/4] 1003
Hfiber 0 0 [expr 2*$pi*8*$mm*8*$mm/(4*0.15*$m*200*$mm)] 1005
}



#section FiberInt
#-----------------------------------------------------------------------------
# 45cm x 15cm RC columns
set Ac [expr 0.45*0.15*$m2]
set Ec [expr 30*$GPa]
set Izzc [expr pow(0.45,4)/12 *$m4]

#-----------------------------------
# 45cm x 15cm RC beams
set Ab [expr 0.45*0.15*$m2]
set Eb [expr 30*$GPa]
set Izzb [expr 0.15*pow(0.45,3)/12 *$m4]
#______________________
# Beam hinge properties
#______________________
# Note: The My is the same for spring and beam. All forces and moments are the same
# for springs in series. Still, adiv (according to Ibarra's Thesis) adjusts the spring
# stiffness, so it has to adjust the spring yield rotation as well (it is reduced by adiv)
# see Figure B.1 of Ibarra's thesis. Thus all the parameters of the backbone that are
# stiffness or ductility related have to change (ah,ac,mc). Those that are force related
# remain the same (My, rf).
set adiv 10
# Hardening ah
#set ah 0.03
#set ahs [expr ($adiv+1)*$ah/($adiv+1-$adiv*$ah)]
# beam stiffness in double curvature bending
#set Kr [expr 0.02*($adiv+1)*6*$Eb*$Izzb/$baylength]
# Yield moment. Originally 4e3. Where did I find this????
#set My 1e3

set SectionType FiberSection;
source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/LibMaterialsRC.tcl

# define section tags:
set ColSecTag 1;
set BeamSecTag 2;
set BeamSecTagRoof 30;

# Section Properties:
set HCol [expr 450*$mm];		# square-Column width
set BCol [expr 150*$mm]
set HBeam [expr 450*$mm];		# Beam depth -- perpendicular to bending axis
set HBeamRoof [expr 225*$mm];		# Beam depth -- perpendicular to bending axis
set BBeam [expr 150*$mm];		# Beam width -- parallel to bending axis



# FIBER SECTION properties 
# Column section geometry:
set cover [expr 25*$mm];	# rectangular-RC-Column cover
set colBarDia 16;			# diameter of reinforcement in millimeters
set numBarsTopCol 2;		# number of longitudinal-reinforcement bars on top layer
set numBarsBotCol 2;		# number of longitudinal-reinforcement bars on bottom layer
set numBarsIntCol 0;		# TOTAL number of reinforcing bars on the intermediate layers
set barAreaTopCol [expr $pi*pow($colBarDia,2)/4*$mm2];	# longitudinal-reinforcement bar area
set barAreaBotCol [expr $pi*pow($colBarDia,2)/4*$mm2];	# longitudinal-reinforcement bar area
set barAreaIntCol [expr $pi*pow($colBarDia,2)/4*$mm2];	# longitudinal-reinforcement bar area

set beamBarDia 16;			# diameter of reinforcement in milimeters
set numBarsTopBeam 2;		# number of longitudinal-reinforcement bars on top layer
set numBarsBotBeam 2;		# number of longitudinal-reinforcement bars on bottom layer
set numBarsIntBeam 0;		# TOTAL number of reinforcing bars on the intermediate layers
set barAreaTopBeam [expr $pi*pow($beamBarDia,2)/4*$mm2];	# longitudinal-reinforcement bar area
set barAreaBotBeam [expr $pi*pow($beamBarDia,2)/4*$mm2];	# longitudinal-reinforcement bar area
set barAreaIntBeam [expr $pi*pow($beamBarDia,2)/4*$mm2];	# longitudinal-reinforcement bar area

puts "I am defined";

set nfCoreY 20;		# number of fibers in the core patch in the y direction
set nfCoreZ 20;		# number of fibers in the core patch in the z direction
set nfCoverY 20;		# number of fibers in the cover patches with long sides in the y direction
set nfCoverZ 20;		# number of fibers in the cover patches with long sides in the z direction

# rectangular section with one layer of steel evenly distributed around the perimeter and a confined core.
BuildRCrectSection $ColSecTag $HCol $BCol $cover $cover $IDconcCore  $IDconcCover $IDSteel $numBarsTopCol $barAreaTopCol $numBarsBotCol $barAreaBotCol $numBarsIntCol $barAreaIntCol  $nfCoreY $nfCoreZ $nfCoverY $nfCoverZ
BuildRCrectSection $BeamSecTag $HBeam $BBeam $cover $cover $IDconcCore  $IDconcCover $IDSteel $numBarsTopBeam $barAreaTopBeam $numBarsBotBeam $barAreaBotBeam $numBarsIntBeam $barAreaIntBeam  $nfCoreY $nfCoreZ $nfCoverY $nfCoverZ

BuildRCrectSection $BeamSecTagRoof $HBeamRoof $BBeam $cover $cover $IDconcCore  $IDconcCover $IDSteel $numBarsTopBeam $barAreaTopBeam $numBarsBotBeam $barAreaBotBeam $numBarsIntBeam $barAreaIntBeam  $nfCoreY $nfCoreZ $nfCoverY $nfCoverZ

puts "section created";



# NOTE: Do not try with ah==0.0, as OpenSees will fail. It will accept a negative
# ah though. Anything as long as it is not zero!
# the slope of the hardening segment is a*E, where a=(Hiso+Hkin)/(E+Hiso+Hkin)
# in our case, use Hiso=0, E=1, so a=Hkin/(E+Hkin) <=> Hkin=a*E/(1-a)
#uniaxialMaterial Hardening $matTag $E $sigmaY $H_iso $H_kin <$eta>
#puts "kinematic hardening, ah=$ah, ahs=$ahs "
#set Hkin [expr $ahs*$Kr/(1-$ahs)]
#set Hiso 0.0
#uniaxialMaterial Hardening 1 $Kr $My $Hiso $Hkin


#section Uniaxial $secTag $matTag $string
#section Uniaxial 1 1 Mz
# this is great for 3D structures. It will provide UNCOUPLED springs for both bending rotations of
# the beam end.
#section Aggregator 1 1 Mz 1 My 
# for beams
geomTransf Linear 1
# for columns
geomTransf PDelta 2
set np 5


#generate2DFrameNodes $nbayx $nstory "{$baylength}" “{3,3}” $csx

generate2DFrameNodes $nbayx $nstory $baylength $sheight $csx
#generate2DFrameNodes $nbayx $nstory "{$baylength}" "{$sheight}" $csx


# Generate column elements
for {set i 0} {$i<=$nstory-1} {incr i} {
  for {set j 0} {$j<=$nbayx} {incr j} {
    #element elasticBeamColumn $eleTag $iNode $jNode $A $E $Iz $transfTag
#element dispBeamColumn [expr $i*$csx+$j+1]  [expr $i*$csx+$j+1] [expr ($i+1)*$csx+$j+1] $np $ColSecTag 2
element dispBeamColumnInt [expr $i*$csx+$j+1]  [expr $i*$csx+$j+1] [expr ($i+1)*$csx+$j+1] $np 5 6 0.4

  }
}

#puts [expr 12*$Eb*($adiv+1)/$adiv*$Izzb/6]

# Generate beam elements
# and place rigid diaphragms!
for {set i 1} {$i<=$nstory} {incr i} {

  for {set j 0} {$j<=$nbayx-1} {incr j} {
if { $i == $nstory} {
element dispBeamColumn [expr $Beoff+$i*$csx+$j+1]  [expr $i*$csx+$j+1] [expr $i*$csx+$j+2] $np $BeamSecTagRoof 1
} else {
element dispBeamColumn [expr $Beoff+$i*$csx+$j+1]  [expr $i*$csx+$j+1] [expr $i*$csx+$j+2] $np $BeamSecTag 1
}


  }

}


# Fix to ground
for {set j 0} {$j<=$nbayx} {incr j} {
  fix [expr $j+1] 1 1 1
}


set facDL 1.05
set facLL 1.25
set DL [expr 5.1*$kN/$m2]
set DLRoof [expr 1.0*$kN/$m2]
set LL [expr 2.5*$kN/$m2]
set LLRoof [expr 1.0*$kN/$m2]
set Area  [expr 33.651*$m2]
set Load [ expr $Area*($facDL* $DL + $facLL*$LL)]
set LoadRoof [ expr $Area*($facDL* $DL + $facLL*$LLRoof)]
set nmassx [expr $Load/(($nbayx+1)*$g)]
set nmassxRoof [expr $LoadRoof/(($nbayx+1)*$g)]

for {set i 1} {$i<=$nstory} {incr i} {
  for {set j 0} {$j<=$nbayx} {incr j} {

if {$i == $nstory} {
mass [expr $i*$csx+$j+1] $nmassxRoof 0 0
} else {
mass [expr $i*$csx+$j+1] $nmassx 0 0
}

}
} 


set lengthX [expr 15.6*$m]
set nload [expr $Load/$lengthX]
set nloadRoof [expr $LoadRoof/$lengthX]




# assign gravity loads

pattern Plain 1 Linear {
  for {set i 1} {$i<=$nstory} {incr i} {
    for {set j 0} {$j<=$nbayx} {incr j} {

if {$i == $nstory} {
load [expr $i*$csx+$j+1] 0 [expr -$nloadRoof] 0
} else {
load [expr $i*$csx+$j+1] 0 [expr -$nload] 0
}
}
}
}



#_______________________
# ANALYSES
#_______________________

constraints Transformation
RunGravityAnalysis 10

# Compute $Neigen modes and apply 2% damping at 1st and 2nd modes 
GetPeriodSetDamping $Neigen 0.05 1 2 "simple2DframePeriods.out"

for {set i 1} {$i<=$nstory} {incr i} {
  # recorder Drift $fileName <-time> $node1 $node2 $dof $perpDirn
  # Interstory drifts. The dof is along x (1) and the height along y (2)
  # NOTE: The higher node should always be second (node 2). I believe the drift is determined as
  #  (node2x-node1x)/abs(node2y-node1y)
  if {$i<10} {

    # use $i\x.out because $ix.out will search for variable $ix not $i.
    recorder Drift -file "idr_0$i\x.out" -time -iNode [expr ($i-1)*$csx+0+1] -jNode [expr $i*$csx+0+1] -dof 1 -perpDirn 2

  } else {

    recorder Drift -file "idr_$i\x.out" -time -iNode [expr ($i-1)*$csx+0+1] -jNode  [expr $i*$csx+0+1] -dof 1 -perpDirn 2

  }

}

# roof drift. The dof is along x (1) and the height along y (2)
recorder Drift -file "roofdrx.out" -time -iNode 1 -jNode [expr $nstory*$csx+0+1] -dof 1 -perpDirn 2


# Now allow option to perform either SPO or single dynamic analysis
if {$analysistype=="pushover"} {
  source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/RunPushover2Converge.tcl
  pattern Plain 2 Linear {
    set allsum 0.0
    for {set i 1} {$i<=$nstory} {incr i} {
      set allsum [expr $allsum+pow($i,$pushoverLPk)]
    }
    for {set i 1} {$i<=$nstory} {incr i} {
      load [expr $i*$csx+0+1] [expr pow($i,$pushoverLPk)/$allsum] 0 0 0 0 0
    }
  }
  #integrator DisplacementControl $nodeTag $dofTag $dU1 <$Jd $minDu $maxDu>
  # 1st step is 0.1% roof drift
  set IDctrlNode [expr $nstory*$csx+0+1]
  set DriftStep 0.5e-4
  set DispStep [expr $nstory*$sheight*$DriftStep]
  #set Nsteps 894; # for k=1
  set Nsteps 6000
  set DmaxPush [expr $Nsteps*$DispStep]
  puts "Pushing to [expr $Nsteps*$DriftStep*100]% roof drift in $Nsteps steps"
  integrator DisplacementControl $IDctrlNode 1 $DispStep
  #test EnergyIncr 1.0e-5 10 0
  test NormDispIncr 1.0e-8 20 0
  analysis Static
  RunPushover2Converge  $IDctrlNode $DmaxPush $Nsteps
  loadConst -time 0.0
} elseif {$analysistype=="dynamic"} {
  source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/ReadSMDFile3.tcl
  source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/RunTransient2Converge.tcl
  source C:/Users/KNUST/Desktop/JackOpenSees/bundle_runIDA/osees/util/DefineXYZ_UniformExcitation.tcl

  # you are getting back "nptsx" and "dtx"
  DefineXYZ_UniformExcitation $dtsub $g $GMdir $GMfileX $GMfileY $GMfileZ $GMfactorX $GMfactorY $GMfactorZ nptsx dtx

  integrator Newmark 0.5 0.25
  test NormDispIncr 1.0e-8 10 0
  
  
  analysis Transient
  puts "analysis Transient"
  RunTransient2Converge [expr $nptsx*$dtsub] [expr $dtx/$dtsub]
}


if {!$runIDAflag} {
  # Delete old file as "print" simply appends the new results
  file delete simple2DframePrint.out 
  print simple2DframePrint.out
}
