<CsoundSynthesizer>
<CsOptions>
</CsOptions>

; Realtime output
-odac
<CsInstruments>

;Some settings
sr = 44100
kr = 441
ksmps = 100
nchnls = 2
0dbfs = 1.0

gaoutL init 0
gaoutR init 0

gidelayTime init 1
gifeedback init .6
giVol init 1
gitapTimeL init 1
gitapTimeR init 1.3

 
opcode range_k, k, kkkkk
	kIn, kLowIn, kHighIn, kLowOut, kHighOut xin
	
	kOut = ((kIn - kLowIn) / (kHighIn - kLowIn)) * (kHighOut - kLowOut) + kLowOut
	xout kOut
endop

opcode range_i, k, kiiii
	kIn, iLowIn, iHighIn, iLowOut, iHighOut xin
	
	kOut = ((kIn - iLowIn) / (iHighIn - iLowIn)) * (iHighOut - iLowOut) + iLowOut
	xout kOut
endop

instr 1 
;p4 min_time, p5 max time, p6 min pitch, p7 max pitch, p8 amp


; outputs "1" twice a second


loop:
idurloop  	random    p4, p5 ;duration of each loop
          	timout    0, idurloop, play
          	reinit    loop
play:
ioct random p6 , p7
ioct = int(ioct)
isemi random 0, 0.012
ipitch = ioct + isemi
iamp random .1, 1
iamp *= p8
print ipitch
event_i     "i", 20, 0, 1, ipitch, iamp

endin

instr 10
;p4 min_time, p5 max time, p6 min pitch, p7 max pitch, p8 amp, 


; outputs "1" twice a second



loop:
idurloop  	random    p4, p5 ;duration of each loop
          	timout    0, idurloop, play
          	reinit    loop
play:
ioct random p6 , p7
ioct = int(ioct)
isemi random 0, 0.012
ipitch = ioct + isemi
iamp random .1, .3
iamp *= p8
print ipitch
event_i     "i", 30, 0, 1, ipitch, iamp 

endin

instr 100
;p4 min_time, p5 max time, p6 amp, p7 plackback speed, p8 random playback speed




loop:
idurloop  	random    p4, p5 ;duration of each loop
          	timout    0, idurloop, play
          	reinit    loop
play:
iSample random 1 , 6
iSample = int(iSample)

iamp random .1, 1
iamp *= p6

event_i     "i", 4, 0, 1, iSample, iamp, p7

endin

instr 101
;p4 min_time, p5 max time, p6 amp, p7 plackback speed



loop:
idurloop  	random    p4, p5 ;duration of each loop
          	timout    0, idurloop, play
          	reinit    loop
play:
iSample1 random 1 , 6
iSample1 = int(iSample1)
iSample2 random 1 , 6
iSample2 = int(iSample2)
irandomSpeed1 random -1, 1
iamp1 random .1, 1
iamp1 *= p6
irandomSpeed2 random -1, 1
iamp2 random .1, 1
iamp2 *= p6

event_i     "i", 41, 0, 1, iSample1, iamp1, irandomSpeed1 * p7
event_i     "i", 42, 0, 1, iSample2, iamp2, irandomSpeed2 * p7


endin

instr 102
;p4 min_time, p5 max time, p6 amp



loop:
idurloop  	random    p4, p5 ;duration of each loop
          	timout    0, idurloop, play
          	reinit    loop
play:
iSample1 random 1 , 6
iSample1 = int(iSample1)
iSample2 random 1 , 6
iSample2 = int(iSample2)
iamp1 random .1, 1
iamp1 *= p6
iamp2 random .1, 1
iamp2 *= p6

event_i     "i", 41, 0, 1, iSample1, iamp1, 1
event_i     "i", 42, 0, 1, iSample2, iamp2, 1


endin

instr 2
;p4 = pitch, p5 = amp
iFreq	= cpspch(p4)
print iFreq

aEnv	transeg p5, p3 * 0.99, 0, p5, p3 - (p3 * 0.99), 0, 0
asig pluck p5, iFreq, 0, 0, 3, 0
adel delay asig, .05
asig *= aEnv
adel *= aEnv
	outs asig, adel
;vincr gaoutL, asig
;vincr gaoutR, adel
gaoutL += asig
gaoutR += adel

endin

instr 20
;p4 = pitch, p5 = amp
iFreq	= cpspch(p4)
print iFreq

aEnv	transeg p5, p3 * 0.99, 0, p5, p3 - (p3 * 0.99), 0, 0
asig pluck p5, iFreq, 0, 0, 3, 0
adel delay asig, .05
asig *= aEnv
adel *= aEnv
	outs asig, adel
;vincr gaoutL, asig
;vincr gaoutR, adel
gaoutL += asig
gaoutR += adel

endin

instr 3
;p4 = freq, p5 = amp, 
;p6 = gliss start time, p7 = gliss destination, 
;p8 = Vib rate, p9 = Vib depth, p10 = Env preset
;p11 - p14: ADSR, p15 = ftable index

;MtoF

iFreq	= cpspch(p4)
print iFreq

;Env Presets
;p10 = 1 -> Envelop follow, else, don't follow
if (p10 == 1) then
kEnv	mxadsr 	p3 * 0.1, p3 * 0.3, 0.3, p3 * 0.4
else 
kEnv	mxadsr 	p11, p12, p13, p14
endif

;Main Oscillator
kVib	oscil  	kEnv, p8
kVib 	= 		kVib * p9
aglis	expseg 	1, p6, 1, p3 - p6, p7
asig 	oscil 	p5 * kEnv, (iFreq + kVib) * aglis, p15

;Random panning every note
iPan random 0, 100
iPan = iPan / 100
print iPan
aOutL, aOutR pan2 asig, iPan

outs 	aOutL, aOutR

;
;gaoutL = 0
;gaoutR = 0
endin



instr 30
;p4 = pitch, p5 = amp
iFreq	= cpspch(p4)
print iFreq

aEnv	transeg p5, p3 * 0.99, 0, p5, p3 - (p3 * 0.99), 0, 0
iDur random .1, 1
iPitchHigh random 0, 12
iPitchHigh /= 10
kPitchEnv line iFreq, .1, iFreq+3
aEnv line 0, iDur, p5
asig oscil aEnv, kPitchEnv, 3

;Random panning every note
iPan random 0, 100
iPan = iPan / 100

asig *= aEnv

aOutL, aOutR pan2 asig, iPan

	outs aOutL, aOutR
;vincr gaoutL, asig
;vincr gaoutR, adel
gaoutL += aOutL
gaoutR += aOutR


endin

instr 4
;p4 = sample name, p5 = amp, p6 = playback speed
if (p4 == 1) then
	asig diskin2 "1.wav", p6, 0, 1
elseif (p4 == 2) then
	asig diskin2 "2.wav", p6, 0, 1
elseif (p4 == 3) then
	asig diskin2 "3.wav", p6, 0, 1
elseif (p4 == 4) then
	asig diskin2 "4.wav", p6, 0, 1
elseif (p4 == 5) then
	asig diskin2 "5.wav", p6, 0, 1
elseif (p4 == 6) then
	asig diskin2 "6.wav", p6, 0, 1
endif


asig *= p5
aDel delay asig, .001
out asig, aDel

gaoutL += asig
gaoutR += aDel

endin

instr 41
;p4 = sample name, p5 = amp, p6 = playback speed
if (p4 == 1) then
	asig diskin2 "1.wav", p6, 0, 1
elseif (p4 == 2) then
	asig diskin2 "2.wav", p6, 0, 1
elseif (p4 == 3) then
	asig diskin2 "3.wav", p6, 0, 1
elseif (p4 == 4) then
	asig diskin2 "4.wav", p6, 0, 1
elseif (p4 == 5) then
	asig diskin2 "5.wav", p6, 0, 1
elseif (p4 == 6) then
	asig diskin2 "6.wav", p6, 0, 1
endif
kEnv adsr .1, 0, 1, 2
asig *= kEnv
asig *= p5

out asig, asig * 0

gaoutL += asig

endin

instr 42
;p4 = sample name, p5 = amp, p6 = playback speed
if (p4 == 1) then
	asig diskin2 "1.wav", p6, 0, 1
elseif (p4 == 2) then
	asig diskin2 "2.wav", p6, 0, 1
elseif (p4 == 3) then
	asig diskin2 "3.wav", p6, 0, 1
elseif (p4 == 4) then
	asig diskin2 "4.wav", p6, 0, 1
elseif (p4 == 5) then
	asig diskin2 "5.wav", p6, 0, 1
elseif (p4 == 6) then
	asig diskin2 "6.wav", p6, 0, 1
endif

kEnv adsr .1, 0, 1, 2
asig *= kEnv
asig *= p5
aDel delay asig, .001
out asig*0, aDel

gaoutR += aDel

endin

instr 98
;p4 feedback, p5 delay vol

kLineFb line gifeedback, p3, p4
kLineVol line giVol, p3, p5
passNewData:
	gifeedback = i(kLineFb)
	giVol = i(kLineVol)
	reinit passNewData


endin
instr 99
; delay
gidelayTime = p4
gifeedback = p5
gitapTimeL = p6
gitapTimeR = p7
giVol = p8

aEnv	transeg giVol, p3 * 0.9, 0, giVol, p3 - (p3 * 0.9), 0, 0
abuf	delayr gidelayTime
adelL	deltap gitapTimeL
	delayw gaoutL + (adelL * gifeedback)

abuf	delayr gidelayTime
adelR	deltap gitapTimeR
	delayw gaoutR + (adelR * gifeedback)
	
	outs	(adelL * giVol) * aEnv, (adelR * giVol) * aEnv
gaoutL = 0
gaoutR = 0

endin
</CsInstruments>
<CsScore>
; ftables
f 1 0 32768 10 1 .5 .1 2.3 2.7
f 2 0 32768	 10 1 1.1 1.2 2.25 2.3 2.4
f 3 0 32768	 10 1 .6 .7 .8 .9 1.1 1.2 1.3 1.4

;	inst  start  dur     pitch    amp  p6  p7    p8    p9    p10	p11	p12	p13	p14	p15
i 	3	 0 	  21	    9.075    .1   10  1.15  30    5     0	8	3	.3	1	1
i 	3	 8 	  14 	    9.07 	  .2   .5  .85   20    7     0	7.5	5.5	.1	.5	1	
i	3	 9 	  13 	    9.072 	  .3   3   .87   30    9     0	8	3	.1	.5	1
i	3	 9.5	  12	    9.069	  .25  6   .65   5     15    0	7.5	3	.3	.5	1
i	3	 10	  12	    5.076	  .5   .4  1.34  260   3     0	12	0	0	.8	2
i	3	 11	  11	    5.073	  .6   2   .8    300   5     0	11	0	0	.8	2
i	3	 14	  3	    4.002   .7	 1	.99	1	 0	 0	1	1	.09	1	1
i	3	 16	  4	    4.003    .5   1	.99	1	 0	 0	1	1	.2	1	2
i 	3	 22	  20	    4.008	  .8   10   3	20	 4	 0    2	4	.1	2	1

i 	3	 40 	  21	    6.075    .3   10  6.15  30    5     0	8	6	.3	3	1
i 	3	 40 	  21 	    7.07 	  .25  .5  4.85  20    7     0	7.5	5.5	.1	3	3	
i	3	 40 	  21 	    8.072 	  .25  3   1.87   30    9     0	8	3	.1	3	1
i	3	 40	  21	    9.069	  .15  6   1.65   5     15    0	7.5	3.5	.3	3	2
i	3	 40	  21	    5.076	  .05  .4  10.34  260   3     0	12	4	.3	3	1
i	3	 46	  15	    5.076	  .05  .4  1.34   10   30    0	10	5	.3	3	1

i	3	 85 	  20	    5.012    .15   15 3	 100   20	 0	15	2	.4	2	3
i	3	 85	  20	    5.0123	  .15   15 .4	 200   20   0	15	2	.4	2	3
i	3	 85	  20	    5.0127	  .15   15 2	 200   20   0	15	2	.4	2	3
i	3	 85	  20	    5.0123	  .15   15 .1	 200   20   0	15	2	.4	2	3
i	3	 85	  20	    5.0129	  .15   15 .9	 400   20   0	15	2	.4	2	3
i	3	 85	  20	    5.0131	  .15   15 2.1 	 200   20   0	15	2	.4	2	3
i	3	 85	  20	    5.0132	  .15   15 2.5 	 200   20   0	15	2	.4	2	3
i	3	 85	  20	    5.0136	  .15   15 .4	 200   20   0	15	2	.4	2	3

i	3	 170    30	    11.003   .5    .8  1.1   40    20   0    30	0	0	.1	1  

i	2	 10.5	  3	    9.076	  .2 
i	2	 10.6	  3	    9.07     .35
i	2	 22	  2	    5.03	  .85
i	2	 22	  2	    6.03	  .43
i	2	 22.1  2	    10.083	  .5
i	2	 22.2  2	    9.02      .7
i	2	 62	  5	    5.02	   .7
i	2	 105    5      5.02	   .7
i     2	 105.1  5	    10.002	   .9

		
i	4	 22	  5	    4		   .5	 -1
i	4	 62	  5	    5		   .5 -.9
i	4	 105	  10	    1         .7 -.3
i	4	 110	  10	    2		   .3 -2
i	4	 115	  10	    6         .8  -.7

i	4	 130	  .1	    1		   .9  1
i	4	 132	  .1	    3		   .7  1
i	4	 132.1  .1	    2		   .95  2
i	4	 136	  .1	    4		   .2  .8
i	4	 136.1  .1	    5		   .7  1.3
i	4	 190	  10      4		   .85 -.89
i	4	 194    1       1         .4   1.2
i     4     197	  .48	     6         .9   1
i     4     200    1.8       4	   .98  .8	

;   Effect start  dur		p4	p5	p6	p7	p8
i 	99 	 0 	  205		1	.6	1.2	1.5	.9 

    

i 1 0  8  .1 1  5 10  .1
i 1 30 32 .1 3  5 6  .3
i 1 31 32 .1 .9 9 10 .4
i 1 35 32 .1 2  4.008 8  .3
i 1 70 2  .01 .1 7 10 .2
i 1 75 2  .01 .8 9 10 .9
i 1 82 4  .01 .08 8 9 .3
i 1 82 4  .1 .3 5  6 .1
i 1 175 24 .01 .1 4 7 .3

i 10 108 40 .1 5 6 10 .4
i 10 108 40 .3 1 5 8 .3
i 10 108 40 .1 .5 6 7 .1
i 10 108 40 .01 .1 6 10 .2
i 10 170 29 .01 .2 7 11 .1 


i 100 115 10 .3  2 .11  1   1
i 102 116 2 .1 .1 .21
i 100 118 2 .3 .1 .31 1.8 1
i 102 123 10 .5 .7 .8 

i 100 142 30 1 4 .1  1 1
i 101 145 30 .5 2 .9 1
i 101 150 40 .2 1 1.3 1
i 102 190 10 1 3 .9 

i 98 0 1 0 0
i 98 20 3 .6 .9
i 98 28 3 .6 .8
i 98 35 3 .3 .1
i 98 42 18 .8 .85
i 98 60 10  .4 .7
i 98 75 3 .6 .2
i 98 78 10  .9 .8
i 98 100 3 .6 .7
i 98 192 10 .1 .1

e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
