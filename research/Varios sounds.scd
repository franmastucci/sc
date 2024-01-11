//after goeyvaerts
//(C) Nick Collins 2007


//first send the SynthDefs; make sure the Server is on
(
SynthDef(\goeysynth, {
arg freq=440,amp=0.1, sustain=0.1, pan=0.0;
var source, env;

source= LPF.ar(Mix(LFPar.ar(freq*[0.999,1.001],0,amp)).distort,EnvGen.kr(Env([10000,2000,4000,1000],[0.005,Rand(0.009,0.05),0.005])));

env= EnvGen.kr(Env([0,1,0.4,0.7,0],[Rand(0.001,0.005),0.005,0.005,sustain]), doneAction:2);

Out.ar(0,Pan2.ar(source*env,pan))

}).add;

//preferred version if you have the FreeVerb UGen, commented out by default
//SynthDef(\goeyfx, {
//ReplaceOut.ar(0,FreeVerb.ar(In.ar(0,2),0.33,1.5))
//}).add;

//adapted from JmC reverb
SynthDef(\goeyfx, {
var a,c,z,y,in;
c = 2; // number of comb delays
a = 3; // number of allpass delays

in=In.ar(0,2);
// reverb predelay time :
z = DelayN.ar(in, 0.048,0.048);

//for delaytime if want modulation-	//LFNoise1.kr(0.1.rand, 0.04, 0.05)
y=Mix.arFill(c,{CombL.ar(z,0.1,rrand(0.01, 0.1),5)});

// chain of 4 allpass delays on each of two channels (8 total) :
a.do({ y = AllpassN.ar(y, 0.051, [rrand(0.01, 0.05),rrand(0.01, 0.05)], 1) });

// add original sound to reverb and play it :
Out.ar(0,(0.2*y));

}).add;

)



Synth(\goeysynth,[\freq,440]); //test



//now run the piece
(
var n, octaves, basenote, selections, probs;
var ioirow, ioimult, noterow, amprow, susrow, panrow;
var fxsynth;

n=12; //notes per octave

fxsynth= Synth(\goeyfx);

noterow=(0..(n-1)).scramble; //[4,0,5,14,13,15,21,19,20,11,6,10]%12;
amprow= Pseq((1,3..36).neg.dbamp.scramble,inf).asStream;
susrow= Pseq((((1..37)/37).exp/exp(1)).scramble,inf).asStream;
panrow= Pseq((((0..31)/31)*2-1).scramble,inf).asStream;

ioimult=0.1;

ioirow= n**(((1..n).scramble)/n); //exponential spacing 1 to n
ioirow= Pseq(ioirow,inf).asStream;

basenote=36;
octaves=4;
selections= Array.fill(n,{0});
probs=Array.fill(n,{1.0});

{

inf.do
{
	var notenow;

	if(ioimult.coin,{ioimult=[0.01,0.025,0.05,0.1,0.2].choose;});

	if(0.03.coin,{selections= Array.fill(n,{0});});
	if(0.02.coin,{octaves= rrand(2,5);});
	if(0.01.coin,{basenote=rrand(35,47);});

	//recovery rate
	probs.do{|val,i| if(val<0.9999,{probs[i]=probs[i]+0.1})};

	s.makeBundle(s.latency, {
		[1,2,3,4,5].wchoose([0.5,0.35,0.1,0.025,0.025]).do{
			notenow= noterow.wchoose(probs.normalizeSum);

			probs[notenow]=0.1;

			selections[notenow]=selections[notenow]+1;

			Synth.before(fxsynth, \goeysynth,[\freq, ((((selections[notenow]%octaves)*12)+ basenote) + ((notenow/n)*12)).midicps,\amp,(amprow.next)*0.2, \sustain, susrow.next, \pan, panrow.next]);

		};

	});

	((ioirow.next)*ioimult).wait;
};

}.fork;

)


//future possibilities:
//add different rhythmic sections, and also, use fold or wrap on array data
//up to four notes at once in selection; optional slight spread? really need independent voices too



(
// modal space
// mouse x controls discrete pitch in dorian mode
var scale, buffer;
scale = FloatArray[0, 2, 3.2, 5, 7, 9, 10]; // dorian scale
buffer = Buffer.alloc(s, scale.size,1, {|b| b.setnMsg(0, scale) });
{
	var mix;
	mix =
	// lead tone
	SinOsc.ar(
		(
			DegreeToKey.kr(
				buffer.bufnum,
				MouseX.kr(0,15),		// mouse indexes into scale
				12,					// 12 notes per octave
				1,					// mul = 1
				72					// offset by 72 notes
			)
			+ LFNoise1.kr([3,3], 0.04)	// add some low freq stereo detuning
		).midicps,						// convert midi notes to hertz
		0,
		0.1)

	// drone 5ths
	+ RLPF.ar(LFPulse.ar([48,55].midicps, 0.15),
		SinOsc.kr(0.1, 0, 10, 72).midicps, 0.1, 0.1);

	// add some 70's euro-space-rock echo
	CombN.ar(mix, 0.31, 0.31, 2, 1, mix)
}.play
)



/*
A babbling brook example, by James McCartney 2007. See
http://www.create.ucsb.edu/pipermail/sc-users/2007-April/033231.html
*/

(
{
	({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 1000)
		* 400 + 500, 0.3, 0.003)}!2)
		+ ({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 20)
		* 800 + 500, 0.3, 0.003)}!2)
		* 3
}.play
)

(
{
	({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 1000)
		* 400 + 500, 0.3, 0.003)}!2)
		+ ({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 20)
		* 800 + 500, 0.3, MouseX.kr(0, 0.005))}!2)
	* MouseX.kr(0,3)
}.play
)

// From SC2 distro

// Chaotic Patterns, version 0.1
// Some short examples showing how to create music (?) from
// chaotic iterated maps and (integrated) ODE's. Most of this
// is probably old news, but there are some new maps like Tinkerbell
// and Ikeda that are interesting. Most interesting is the ease of doing
// this in SC2 ! Try them several times
// Staffan Liljegren, 991002, staffan@medialab.ericsson.se


// ======================= Discrete Maps ===================================
// Logistics map with fixed r = 3.9
(
p = Prout({
	var x;
	x=0.5.rand;
	loop({
		// xnew = r * xold * (1.0 - xold)
		x = 3.9 * x * (1.0 - x);
		x.yield;}); });
// p returns points in 0<x<1 and in b we scale it to degrees from 0 - 7. You
// can try freq values instead, by using \freq instead of \degree
b = Pbind(\dur, 0.1,\degree, p*7);

b.play;

)

// Logistics map with r = 3.687 and independent streams scaled to two octave
// frygian scale, amp, legato and pan values)
(

p = Prout({
	var x;
	x=1.0.rand;
	60.do({
		x = 3.687 * x * (1.0 - x); x.yield;}); });
b = Pbind(\scale, [0,1,3,5,7,8,10],\amp,p/4,\legato, p/2, \pan, p*2-1,\dur, 0.125, \degree, p*14);

Paddp(\mtranspose, Pseq([0,-2, 2],1),Ppar([Pbindf(b, \stretch, 2.0, \octave, 3),b++b])).play;

)

// Logistics map with changing r values
// (3.4<r<4.0, with "chaos" entering at 3.57)
(

p = Prout({ var r, x;
		// Initial value
		x=0.5.rand;
		 //     32-cycle, chaos?, ghost of 3-cycle in chaos,  chaos!
		 //r = [3.569,    3.687,  3.8282,                     3.9].choose;
		 r = rrand(3.4,4.0);

		 // Uncomment this if you want to see the current r value
		 //("// "++ r).postln;
		 60.do({x = r * x * (1.0 - x); x.yield;}); });
// scale p to a pentatonic scale
b = Pbind(\scale, [0,3,5,7,9], \legato, p/2,\dur, Pseq([Pshuf([0.1,0.2,0.1],4)],5), \degree, p*12);

Pseq([Ppar([Pset(\octave,3,b),Pset(\octave,4,b)])], inf).play;

)



// Tinkerbell map / attractor scaled to 3 octave lydian
// Good for Glass/Reich/Nyman stuff...or ?
(
// I don't know any good initial conditions, but 0<x0,y0<0.3 seems to work, but
// it escapes to infinity on some occasions. I'll try to fix this

// p plays 40 notes with one randomly chosen c1 value
p = Prout({
		var x0, y0, c1, c2= -0.6013, c3=2.0, c4=0.4, x, y;
		//vary -0.7<c1<0.9. c1=0.3 is a limit cycle, c1=0.485 is a 7-period, c1=0.9 is chaotic
		c1 = rrand(-0.7,0.9);
		x0=0.2.rand; y0=0.2.rand;
		// Uncomment this if you want to see the current c1 value
		//("// "++ c1).postln;
		40.do({
			x = x0.squared - y0.squared + (c1*x0) + (c2*y0);
			y = (2*x0*y0) + (c3*x0) + (c4*y0);
			x0=x; y0=y;
			// I only use the y value, but feel free to experiment with (tiny) x values
			(y*21).yield;}); });
b = Pbind(\scale, [0,2,4,6,7,9,11], \legato, 0.2,\dur,0.1,\degree, p );

Paddp(\mtranspose, Pshuf([0,-3,-1, 3],2),Pseq([Ppar([b,b])], 2)).play;

)

// Ikeda map / attractor scaled to 2 octave aeolian
(

// p plays 40 notes with one randomly chosen c2 value
p = Prout({ var c2;
		var x0, y0, c1=0.4, c3=6.0, rho=1.0, tao, x, y;
		//vary 0.0<c2<1.0. c2=0.726 is a 3-period, c2=0.780 is "crisis" c2=0.9 is chaotic
		c2 = rrand(0.3,0.9);
		x0=0.2.rand; y0=0.2.rand;
		// Uncomment this if you want to see the current c2 value
		//("// "++ c2).postln;
		40.do({
			tao = c1 - (c3/(1 + x0.squared + y0.squared));
			x = (c2 * ( (x0*cos(tao)) - (y0*sin(tao)) )) + rho;
			y = (c2 * ( (x0*sin(tao)) + (y0*cos(tao)) ));
			x0=x; y0=y;
			[x.abs/5+0.1,y*14].yield;}); });
b = Pbind(\scale, [0,2,3,5,7,8,10],\dur,0.1,[\legato,\degree], p );

Pseq([b],inf).play;
)

// Henon map / attractor (returns points in -1.5<x<1.5, -0.4<y<0.4, which are then
// used for pan (x values) and degrees from 2 octave dorian (y values)
(
p = Prout({
	var x0, y0, x, y;
	x0=0; y0=0;
	loop({
		x = y0 + 1 - (1.4*x0*x0);
		y = 0.3*x0;
		x0=x;y0=y;
		[x, y*14].yield;}); });
b = Pbind(\scale, [0,2,3,5,7,9,10], \dur,0.125,[\pan, \degree], p );

Ptpar([0.0,Pbindf(b, \octave, 4,\stretch, 3.0), 4.0,b]).play;

)

//////////////////////////////////////////////////////////////////////////

(
// analog bubbles
{
	f = LFSaw.kr(0.4, 0, 24, LFSaw.kr([8,7.23], 0, 3, 80)).midicps; // glissando function
	CombN.ar(SinOsc.ar(f, 0, 0.04), 0.2, 0.2, 4) // echoing sine wave
}.play)

//////////////////////////////////////////////////////////////////////////

(
// LFO modulation of Pulse waves and resonant filters
play({
	CombL.ar(
		RLPF.ar(LFPulse.ar(FSinOsc.kr(0.05,0,80,160),0,0.4,0.05),
		   FSinOsc.kr([0.6,0.7],0,3600,4000), 0.2),
		0.3, [0.2,0.25], 2)
}))

//////////////////////////////////////////////////////////////////////////

(
// moto rev
{
	RLPF.ar(LFPulse.ar(SinOsc.kr(0.2, 0, 10, 21), 0.1), 100, 0.1).clip2(0.4)
}.play)

//////////////////////////////////////////////////////////////////////////

(
// scratchy
play({  RHPF.ar(BrownNoise.ar([0.5,0.5], -0.49).max(0) * 20, 5000, 1)  })
)

//////////////////////////////////////////////////////////////////////////

(
// sprinkler
play({
	BPZ2.ar(WhiteNoise.ar(LFPulse.kr(LFPulse.kr(0.09, 0, 0.16, 10, 7), 0, 0.25, 0.1)))
}))

(
play({
	BPZ2.ar(WhiteNoise.ar(LFPulse.kr(MouseX.kr(0.2,50), 0, 0.25, 0.1)))
}))

//////////////////////////////////////////////////////////////////////////

(
// harmonic swimming
play({
	var f, p, z, offset;
	f = 50;		// fundamental frequency
	p = 20;		// number of partials per channel
	z = 0.0;		// start of oscil daisy chain
	offset = Line.kr(0, -0.02, 60); // causes sound to separate and fade
	p.do({ arg i;
		z = FSinOsc.ar(
				f * (i+1), 		// freq of partial
				0,
				max(0, 			// clip negative amplitudes to zero
					LFNoise1.kr(
						6 + [4.0.rand2, 4.0.rand2],	// amplitude rate
						0.02, 					// amplitude scale
						offset					// amplitude offset
					)
				),
				z
		)
	});
	z
}))

//////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////

(
{
// Klank - bank of resonators excited by impulses
var n, p, z;
n = 5;	// number of simultaneous instruments
p = 15;	// number of partials per instrument
	z = `[	// filter bank specification :
				Array.fill(p, { 80 + 10000.0.linrand} ),	// frequencies
				Array.fill(p, { 1.0.rand2 }), 			// amplitudes
				0.5		// ring times
			];
		Pan2.ar(
			Klank.ar(z, Dust.ar(0.7, 0.04)),
			1.0.rand2
		)
}.play;
)

//////////////////////////////////////////////////////////////////////////

(
{
// Klank - excited by noise bursts
var n, p;
var exciter, spec;
n = 5;	// number of simultaneous instruments
p = 8;	// number of partials per instrument
		exciter = Decay.ar(Dust.ar(0.6, 0.001), 3.1, WhiteNoise.ar);
		spec = Array.fill(2, {
			`[
				Array.fill(p, { 80 + 10000.0.linrand} ),
				nil,
				Array.fill(p, { 0.2 + 4.0.rand } )
			]
		});
		Klank.ar(spec, exciter)
}.play;
)

//////////////////////////////////////////////////////////////////////////

(
// what was I thinking?
{
	z = RLPF.ar(
		Pulse.ar(
			max( SinOsc.kr(4, 0, 1, 80),
				Decay.ar(LFPulse.ar(0.1, 0, 0.05, Impulse.ar(8, 0, 500)), 2)
			),
			LFNoise1.kr(0.157, 0.4, 0.5),
			0.04),
		LFNoise1.kr(0.2, 2000, 2400),
		0.2);
	y = z * 0.6;
	z +  [
			  CombL.ar(y, 0.06, LFNoise1.kr(0.3.rand, 0.025, 0.035), 1)
			+ CombL.ar(y, 0.06, LFNoise1.kr(0.3.rand, 0.025, 0.035), 1)
		,
			  CombL.ar(y, 0.06, LFNoise1.kr(0.3.rand, 0.025, 0.035), 1)
			+ CombL.ar(y, 0.06, LFNoise1.kr(0.3.rand, 0.025, 0.035), 1)
		]
}.play;
)

//////////////////////////////////////////////////////////////////////////

(
// police state
var n;
n = 4;	// number of sirens
play({
	CombL.ar(
		Mix.arFill(n, {
			Pan2.ar(
				SinOsc.ar(
					SinOsc.kr(0.1.rand + 0.02, 2pi.rand, 600.rand, 1000 + 300.rand2),
					0,
					LFNoise2.ar(100 + 20.0.rand2, 0.1)
				),
				1.0.rand2
			)
		})
		+ LFNoise2.ar(LFNoise2.kr([0.4,0.4], 90, 620), LFNoise2.kr([0.3,0.3], 0.15, 0.18)),
		0.3, 0.3, 3)
}))


//////////////////////////////////////////////////////////////////////////

(
{
// cymbalism
var p;
		var z, f1, f2;
p = 15;	// number of partials per channel per 'cymbal'.
		f1 = 500 + 2000.0.rand;
		f2 = 8000.0.rand;
		z = Array.fill(2, {
			`[	// sine oscil bank specification :
				y = Array.fill(p, { f1 + f2.rand} ), // frequencies
				nil, 							// amplitudes default to 1.0
				Array.fill(p, { 1.0 + 4.0.rand })	// ring times
			]
		});
		Klank.ar(z, Decay.ar(Impulse.ar(3.0.rand + 0.5), 0.004, WhiteNoise.ar(0.03)));
}.play;
)

//////////////////////////////////////////////////////////////////////////

(
// synthetic piano
var n;
n = 6;	// number of keys playing
play({
	Mix.ar(Array.fill(n, {	// mix an array of notes
		var delayTime, pitch, detune, strike, hammerEnv, hammer;

		// calculate delay based on a random note
		pitch = (36 + 54.rand);
		strike = Impulse.ar(0.1+0.4.rand, 2pi.rand, 0.1); // random period for each key
		hammerEnv = Decay2.ar(strike, 0.008, 0.04); // excitation envelope
		Pan2.ar(
			// array of 3 strings per note
			Mix.ar(Array.fill(3, { arg i;
				// detune strings, calculate delay time :
				detune = #[-0.05, 0, 0.04].at(i);
				delayTime = 1 / (pitch + detune).midicps;
				// each string gets own exciter :
				hammer = LFNoise2.ar(3000, hammerEnv); // 3000 Hz was chosen by ear..
				CombL.ar(hammer,		// used as a string resonator
					delayTime, 		// max delay time
					delayTime,			// actual delay time
					6) 				// decay time of string
			})),
			(pitch - 36)/27 - 1 // pan position: lo notes left, hi notes right
		)
	}))
})
)

//////////////////////////////////////////////////////////////////////////
//lluvia
(
var a, c, d, s, z, y;
// reverberated sine percussion
d = 6; // number of percolators
c = 5; // number of comb delays
a = 0; // number of allpass delays

play({
		// sine percolation sound :
	s = Mix.ar(Array.fill(d, { Resonz.ar(Dust.ar(MouseX.kr(0.3, 64)/d, 50), 0.5 + 3000.0.rand, 0.03)}) );

		// reverb predelay time :
	z = DelayN.ar(s, 0.018);

		// 7 length modulated comb delays in parallel :
	y = Mix.ar(CombL.ar(z, 0.1, LFNoise1.kr(Array.fill(c,{1.rand}), 0.004, MouseY.kr(0.001, 0.05)), 15));

		// chain of 4 allpass delays on each of two channels (8 total) :
	a.do({ y = AllpassN.ar(y, 0.050, [0.050.rand,0.0050.rand], 1) });

		// add original sound to reverb and play it :
	s+(0.2*y)
}))

//////////////////////////////////////////////////////////////////////////

(
// reverberated noise bursts
var a, c, d, s, z, y;
play({
		// pink noise percussion sound :
	s = Decay.ar(Dust.ar(0.6, 0.2), 0.15, PinkNoise.ar);

		// reverb predelay time :
	z = DelayN.ar(s, 0.048);

		// 6 modulated comb delays in parallel :
	y = Mix.ar(CombL.ar(z, 0.1, LFNoise1.kr(Array.fill(6,{0.1.rand}), 0.04, 0.05), 15));

		// chain of 4 allpass delays on each of two channels (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand,0.050.rand], 1) });

		// add original sound to reverb and play it :
	s+y
}))

//////////////////////////////////////////////////////////////////////////

(
	// sample and hold liquidities
	// mouse x controls clock rate, mouse y controls center frequency
{
	var clockRate, clockTime, clock, centerFreq, freq, panPos, patch;

	clockRate = MouseX.kr(1, 200, 1);
	clockTime = clockRate.reciprocal;
	clock = Impulse.kr(clockRate, 0.4);

	centerFreq = MouseY.kr(100, 8000, 1);
	freq = Latch.kr(WhiteNoise.kr(centerFreq * 0.5, centerFreq), clock);
	panPos = Latch.kr(WhiteNoise.kr, clock);
	patch = CombN.ar(
			Pan2.ar(
				SinOsc.ar(
					freq,
					0,
					Decay2.kr(clock, 0.1 * clockTime, 0.9 * clockTime)
				),
				panPos
			),
			0.3, 0.3, 2
		);
	patch
}.play;
)

//////////////////////////////////////////////////////////////////////////

(
//a study for recreating key (sound) aspects of data.microhelix by Ryoji Ikeda
//Batuhan Bozkurt 2009 http://www.earslap.com
{
	//rhythm logic: very crude, times are 1/8's mixed with 1/4's (equal probability) plus 1/16.
	//when 1/16 is chosen, we make sure they come in doubles so it sounds rhytmically nicer.
	//we create 2 instances of these trigs so glitching sound will be independent between speakers.
	//we use TDuty with Demand UGens to create this kind of sophisticated triggers (easier and more
	//flexible dealing with pure noise generators).
	var ctrigs =
	{
		TDuty.ar
		(
			Dxrand(((1/8!8) ++ (1/4!8) ++ [Dseq([1/16, 1/16], Drand([1, 2], inf))]) * 1.25, inf), //see above logic
			0,
			Dwhite(0.5, 1, inf) //trigger values are between 0.5, 1
		)
	}!2;

	//the glitch/clicking noises: basically enveloped PinkNoise through bandpass filter with high rq (low q)
	//here I'm modulating the decay time of the noise envelope with a LFNoise1.
	//there are many diferent ways of approaching this, needs experimentation,
	//dynamic center freq, rq etc. can be employed for example. This sounded nice to me, however.

	var clicks =
		BPF.ar
		(
			PinkNoise.ar(Decay.ar(ctrigs, 0.001 * LFNoise1.ar(4).abs)), //decay time is modulated
			15000,
			0.9,
			25 * LFNoise1.ar(8).range(0, 1) //extreme amplification of glitches.
		).fold(-1, 1); //folding them back into [-1, 1] range (foldback distortion). I think it sounds nice.

	//i don't really know what to call this sound, so its names snd1. 2 sine oscillators tuned by ear, with filtered
	//background noise. nothing fancy. we will random-pan and envelope this later on.
	var snd1 =
		LPF.ar
		(
			SinOsc.ar(44.midicps, 0, 0.5) + SinOsc.ar(90.midicps, 0, 0.6),
			32.midicps * 2
		) + HPF.ar(LPF.ar(WhiteNoise.ar(0.008), 12000), 2400);

	//the shaker-like sound in the background. in the original piece, the rhytmical logic for this sound
	//is a lot more different, I'm using the same ctrigs here, for the sake of simplicity (and I'm a bit lazy).
	//its basically an enveloped WhiteNoise through a bandpass filter with a random freq
	var hiNoise =
		BPF.ar
		(
			WhiteNoise.ar(Decay2.ar(ctrigs * LFNoise1.ar(8, 0.5, 0.5), 0.02, 0.1) * 0.05),
			TRand.ar(12000, 15000, ctrigs),
			0.9
		);

	//the bass/kicky sound needs a lot of tuning (sound and envelope, some best be left to post processing maybe)
	//2 sine oscillators, one has a low freq nad the other is an upper harmonic (quieter)
	//the original piece uses a completely different (and very better) rhytmical logic for this sound.
	//I'm using our ctrigs impulse generator here (first channel) for the sake of clarity.
	//but since I don't want every trigger to activate this, I'm multiplying the trigger with
	//a noise generator (rounded, so its -1, 0, or 1). so not all trigs pass through.

	//the sine oscillator uses a trick I've learned from Josh Parmenter. the freq arguments of the
	//sine oscillators are set to zero, and they are driven by the phase argument with a sweep.
	//this makes the oscillator phase resettable which is very useful for having uniform attacks
	//for low frequency kick-like sounds. or else, the envelope sounding the oscillators can kick
	//in at any phase and the attack of the kicks will vary (in a bad way). here I reset the phase
	//of the sine at each trigger. the speed of the phase driver ([52.8, 740]) determines the
	//frequency of the oscillator here. I'm adding a phase of pi/3 to it so the phase resets to
	//pi/3 instead of zero which produces an additional glitch. this is all about glitch after all right?

	var trigMod = LFNoise0.ar(8).round;

	var bass =
		SinOsc.ar(0, (Sweep.ar(ctrigs[0] * trigMod, 2pi * [52.8, 740]) + (pi/3)).wrap(-pi, pi), [2, 0.05]).mean.tanh *
		EnvGen.ar(Env([0, 0.5, 0.4, 0], [0, 0.2, 0.01], -5), (ctrigs[0] * trigMod).abs)!2;

	//panning and enveloping of snd1. I don't want to use every trigger for the envelope of this so
	//i again multiply it with a random generator. not all trigs pass through. and some random panning.
	snd1 =
		Pan2.ar
		(
			snd1 * EnvGen.ar(Env([0, 1, 0.6, 0], [0.0001, 0.4, 0.01]), ctrigs * LFNoise0.ar(8)),
			TRand.ar(-1, 1, ctrigs)
		);

	//i'm using limiter here because i'm lazy. one needs to get the
	//gain scheduling right for a better sound. this especially kills the bass
	//sometimes. I'm also boosting the freqs around 15000Hz.
	//delete some sounds from the input of MidEQ to hear the sounds
	//(glitches, bass etc) in isolation.
	Limiter.ar(MidEQ.ar(clicks + snd1 + hiNoise + bass, 14000, 0.7, 8));
}.play;
);

///////////
(
// sweepy noise - mouse controls LFO
{
	var lfoDepth, lfoRate, freq, filtered;
	lfoDepth = MouseY.kr(100, 1500, 'exponential');
	lfoRate = MouseX.kr(4, 60, 'exponential');
	freq = Blip.kr(lfoRate, 0, lfoDepth, lfoDepth * 1.2);
	filtered = RLPF.ar(BrownNoise.ar([0.03,0.03]), freq, 0.1);
	CombN.ar(filtered, 0.3, 0.3, 2, 1, filtered);
}.play
)

//////////////////////////////////////////////////////////////////////////

(
{
		var a, a0, a1, b, c, pan;
		a0 = 200.0.rand + 40;
		a1 = a0 + 1.0.rand2;
		a = [a0, a1];
		b = 2000.0.rand;
		c = [a0 + 1.0.rand2, a1 + 1.0.rand2];
		SinOsc.ar(SinOsc.ar(a, 0, 1.0.rand * b, b), 0, SinOsc.kr(c, 0, 0.05, 0.05))
}.play;
)

//////////////////////////////////////////////////////////////////////////

(

// aleatoric quartet
// mouse x controls density

play({
	var amp, density, dmul, dadd, signal;
	amp = 0.07;
	density = MouseX.kr(0.01,1); // mouse determines density of excitation

	// calculate multiply and add for excitation probability
	dmul = density.reciprocal * 0.5 * amp;
	dadd = dmul.neg + amp;

	signal = Mix.ar(	// mix an array of 4 instruments
		Array.fill(4, {
			var excitation, freq;

			excitation = PinkNoise.ar(
				// if amplitude is below zero it is clipped
				// density determines the probability of being above zero
				max(0, LFNoise1.kr(8, dmul, dadd))
			);

			freq = Lag.kr(			// lag the pitch so it glissandos between pitches
				LFNoise0.kr(				// use low freq step noise as a pitch control
					[1, 0.5, 0.25].choose, 	// choose a frequency of pitch change
					7, 					// +/- 7 semitones
					66 + 30.rand2			// random center note
				).round(1), 		// round to nearest semitone
				0.2				// gliss time
			).midicps;			// convert to hertz

			Pan2.ar(	// pan each intrument
				CombL.ar(excitation, 0.02, freq.reciprocal, 3), // comb delay simulates string
				1.0.rand2		// random pan position
			);
	}));

	// add some reverb via allpass delays
	5.do({ signal = AllpassN.ar(signal, 0.05, [0.05.rand,0.05.rand], 1) });
	LeakDC.ar( signal, 0.995);		// delays build up a lot of DC, so leak it out here.
})
)

////////////////////////////////////////////////////////////////////////////////////////////////
//bombed
(~bombed =
{
		var mix, out, n=1;
		r = LFNoise0.kr(rrand(0.2,1.0), 1,1).squared * 0.05 ;
		mix = Klank.ar(
			`[
				Array.fill(n, { exprand(1.0,20.0) }),
				nil,
				Array.fill(n, { 0.2.rand })
			],
			Blip.ar(r, [rrand(2,5),rrand(2,5)], 0.1)
		).fold2(0.2).cubed * 12;
		mix = Mix.arFill(3, { CombL.ar(mix, 0.1, 0.03.linrand, 4.0.linrand) });
		out = mix.distort * 0.5;
		6.do({ out = AllpassN.ar(out, 0.05, [0.05.rand, 0.05.rand], 3) });
		out = LeakDC.ar(out);
}
)

~bombed.play;
~bombed.release;

////////////////////////////////////////////////////////////////////////////////////////////////

(
{
	var root, scale;

	// struck string
	var trig, p, exc, x, freq, s;
	root = rrand(3,6);
	scale = #[0,2,4,5,7,9,11];

	freq = (scale.choose + #[24,36,48,60,72,84].choose + root).midicps;
	exc = BrownNoise.ar(
		Decay2.kr(
			Impulse.kr(#[0.125,0.25,0.375,0.5,0.75,1,1.5,2,3,4].choose,0,[0.05,0.05]
		), 0.005, 0.05));
	s = (Klank.ar(`[
			Array.series(16, freq, freq),
			Array.geom(16,1,rrand(0.7,0.999)),
			Array.fill(16, {rrand(0.1,2.5)})
		], exc) * 0.1).softclip;
}.play
)

///////////////////////////////////////////////////////////////////////////////////////////////

(
{
	var root, scale, s;
			// wind chords
	var trig, p, n, exc, x, base, range;
		//root = rrand(3,6);
		root = 5;
		scale = #[0,2,4,5,7,9,11];
		n = 5;
		exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 1.25, -0.25));
		s = (Klank.ar(`[Array.fill(n, {(scale.choose + #[36,48,60,72,84].choose + root).midicps}),nil,Array.fill(n, {rrand(0.1,2.0)})], exc) * 0.1).softclip;
}.play;
)

///////////////////////////////////////////////////////////////////////////////////////////////
//1
(
{

			// wind metals
			var trig, s, p, n, exc, x, base, range;
			n = 6;
			base = exprand(60,1000);
			range = rrand(500.0,8000.0);
			exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.75, 0.25));
			s = (Klank.ar(`[Array.fill(n, {linrand(range)+base}),nil,Array.fill(n, {rrand(0.1,2.0)})], exc) * 0.1).softclip;
}.play;
)

///////////////////////////////////////////////////////////////////////////////////////////////
//2


///////////////////////////////////////////////////////////////////////////////////////////////
//3
(
{
	var root, scale, s;
	// whistle
	var trig, p, exc, x, freq;
		root = 5;
		scale = #[0,2,4,5,7,9,11];
			freq = (scale.choose + #[84,96].choose + root).midicps;
			exc = BrownNoise.ar([0.05,0.05]) * max(0, SinOsc.kr(exprand(0.125,0.5), 2pi.rand));
			s = (Klank.ar(`[
					Array[freq],
					nil,
					Array[0.3]
				], exc) * 0.1).softclip;
}.play
)

////4
(
{

	// metallic
	var trig, p, exc, x, s;
	exc = BrownNoise.ar(Decay2.kr(Impulse.kr(#[0.125,0.25,0.375,0.5,0.75,1,1.5,2].choose,0,[0.04,0.04]), 0.005, 0.05));
	s = (Klank.ar(`[Array.fill(16, {linrand(8000.0)+60}),nil,Array.fill(16, {rrand(0.1,2.0)})], exc) * 0.1).softclip;
}.play
)

(
{
	// metallic
	var trig, p, exc, x, s;
	exc = BrownNoise.ar(Decay2.kr(Impulse.kr(#[0.125,0.25,0.375,0.5,0.75,1,1.5,2].choose, 0, [0.04,0.04]), 0.005, 0.05));
	s = (Klank.ar(`[Array.fill(16, {linrand(8000.0)+60}),nil,Array.fill(16, {rrand(0.1,2.0)})], exc) * 0.1).softclip;
	s = s * EnvGen.kr(Env.perc, doneAction: 2).softclip;
}.play;
)

(
{
	// metallic
	var trig, p, exc, x, s;
		var env = EnvGen.kr(Env([0, 1, 0], [0.001, 1
	]), doneAction: 2);
	exc = BrownNoise.ar(Decay2.kr(Impulse.kr(#[0.125, 0.25, 0.375, 0.5, 0.75, 1, 1.5, 2].choose, 0, [0.04, 0.04]), 0.005, 0.05));
	s = (Klank.ar(`[Array.fill(16, {linrand(8000.0) + 60}), nil, Array.fill(16, {rrand(0.1, 2.0)})], exc) * 0.1).softclip;

	// Envelope con ataque, sustain y liberación


	// Aplicar la envolvente al sonido
	s = FreeVerb.ar(s, 0.8, 0.9, 0.1);
}.play;
)

(
{
	// metallic
	var trig, p, exc, x, s;
		var env = EnvGen.kr(Env([0, 1, 0], [0.01, 008]), doneAction: 2);
	exc = BrownNoise.ar(Decay2.kr(Impulse.kr(#[1].choose, 0, [0.04, 0.04]), 0.005, 0.05));
	s = (Klank.ar(`[Array.fill(32, {linrand(4000.0) + 60}), nil, Array.fill(1, {rrand(0.1, 2.0)})], exc) * 0.1).softclip;

	// Envelope con ataque, sustain y liberación


	// Aplicar la envolvente al sonido
	s = s * env;

	// Agregar reverberación densa con FreeVerb directamente al sonido
	s = FreeVerb.ar(s, 0, 0.7,1,0.5);

}.play;
)
(
(
{
	// metallic
	var trig, p, exc, x, s;
	exc = BrownNoise.ar(Decay2.kr(Impulse.kr(#[0.125, 0.25, 0.375, 0.5, 0.75, 1, 1.5, 2].choose, 0, [0.04, 0.04]), 0.005, 0.05));

	// Configuración del Klank
	var klankSpecs = `[Array.fill(16, {linrand(8000.0) + 60}), nil, Array.fill(16, {rrand(0.1, 2.0)})], exc];
	var klankDur = 5;  // Duración del sonido Klank en segundos

	// Generar el sonido Klank y multiplicarlo por una envolvente
	s = (Klank.ar(klankSpecs) * EnvGen.kr(EnvGen.kr(Env.perc(0.01, klankDur - 0.02), doneAction: 2))).softclip;

	// Agregar reverberación densa con FreeVerb directamente al sonido
	s = FreeVerb.ar(s, 0.8, 0.9, 0.5);

	// Reproducir el sonido
	s = s ! 2; // Replicar el sonido en ambos canales
	Out.ar(0, s);
}.play;
)





///////////////////////////////////////////////////////////////////////////////////////////////


(
{
Pan2.ar(
	SinOsc.ar(rrand(24,108).midicps, 2pi.rand,

		Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0)
		* Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs
	), 1.0.rand2);

}.play;
)



(
{
		Pan2.ar(
	HPZ1.ar(LFTri.ar(rrand(24,128).midicps, 2pi.rand,

		Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.04)).max(0)
		* Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand])).abs
	)), 1.0.rand2);
}.play;
)


(
{

		Pan2.ar(
	Resonz.ar(LFPulse.ar(exprand(50,600), 2pi.rand, 0.5,

		Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0)
		* Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand])).abs
	), exprand(100,2000), 0.2), 1.0.rand2);
}.play
)


{  SinOsc.ar(exprand(100,6000), 0, LFNoise2.ar(exprand(4,24),[0.07,0.07])) }.play;

(
{

		Pan2.ar(
		RLPF.ar(LFPulse.ar(exprand(50,600), 2pi.rand, 0.5,

			Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0)
			* Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand])).abs
		), exprand(100,2000), 0.2), 1.0.rand2);
}.play;
)
(c = {

}
// Definir el número de disparadores (triggers)
var numTriggers = 100;

// Generar una secuencia de disparadores
var ctrigs = Impulse.ar(0);
ctrigs = HPF.ar(ctrigs, 2);

// Generar sonido con modulación
var clicks = BPF.ar(
    PinkNoise.ar(Decay2.kr(ctrigs, 0.001, 0.1)), // Decay2 para un decaimiento más controlado
    15000,
    0.9,
    25 * LFNoise1.ar(8).range(0, 1)
).fold(-1, 1);

// Salida del sonido
Out.ar(0, clicks);

// Agregar los disparadores
numTriggers.do {
    ctrigs = ctrigs + Dust.ar(0.5);
};

// Esperar antes de finalizar
2.wait;
)
///////////////



//////////////////////////////////////////////////////////////
(
//a study for recreating key (sound) aspects of data.microhelix by Ryoji Ikeda
//Batuhan Bozkurt 2009 http://www.earslap.com
{
	//rhythm logic: very crude, times are 1/8's mixed with 1/4's (equal probability) plus 1/16.
	//when 1/16 is chosen, we make sure they come in doubles so it sounds rhytmically nicer.
	//we create 2 instances of these trigs so glitching sound will be independent between speakers.
	//we use TDuty with Demand UGens to create this kind of sophisticated triggers (easier and more
	//flexible dealing with pure noise generators).
	var ctrigs =
	{
		TDuty.ar
		(
			Dxrand(((1/8!8) ++ (1/4!8) ++ [Dseq([1/16, 1/16], Drand([1, 2], inf))]) * 1.25, inf), //see above logic
			0,
			Dwhite(0.5, 1, inf) //trigger values are between 0.5, 1
		)
	}!2;

	//the glitch/clicking noises: basically enveloped PinkNoise through bandpass filter with high rq (low q)
	//here I'm modulating the decay time of the noise envelope with a LFNoise1.
	//there are many diferent ways of approaching this, needs experimentation,
	//dynamic center freq, rq etc. can be employed for example. This sounded nice to me, however.

	var clicks =
		BPF.ar
		(
			PinkNoise.ar(Decay.ar(ctrigs, 0.001 * LFNoise1.ar(4).abs)), //decay time is modulated
			15000,
			0.9,
			25 * LFNoise1.ar(8).range(0, 1) //extreme amplification of glitches.
		).fold(-1, 1); //folding them back into [-1, 1] range (foldback distortion). I think it sounds nice.

	//i don't really know what to call this sound, so its names snd1. 2 sine oscillators tuned by ear, with filtered
	//background noise. nothing fancy. we will random-pan and envelope this later on.
	var snd1 =
		LPF.ar
		(
			SinOsc.ar(44.midicps, 0, 0.5) + SinOsc.ar(90.midicps, 0, 0.6),
			32.midicps * 2
		) + HPF.ar(LPF.ar(WhiteNoise.ar(0.008), 12000), 2400);

	//the shaker-like sound in the background. in the original piece, the rhytmical logic for this sound
	//is a lot more different, I'm using the same ctrigs here, for the sake of simplicity (and I'm a bit lazy).
	//its basically an enveloped WhiteNoise through a bandpass filter with a random freq
	var hiNoise =
		BPF.ar
		(
			WhiteNoise.ar(Decay2.ar(ctrigs * LFNoise1.ar(8, 0.5, 0.5), 0.02, 0.1) * 0.05),
			TRand.ar(12000, 15000, ctrigs),
			0.9
		);

	//the bass/kicky sound needs a lot of tuning (sound and envelope, some best be left to post processing maybe)
	//2 sine oscillators, one has a low freq nad the other is an upper harmonic (quieter)
	//the original piece uses a completely different (and very better) rhytmical logic for this sound.
	//I'm using our ctrigs impulse generator here (first channel) for the sake of clarity.
	//but since I don't want every trigger to activate this, I'm multiplying the trigger with
	//a noise generator (rounded, so its -1, 0, or 1). so not all trigs pass through.

	//the sine oscillator uses a trick I've learned from Josh Parmenter. the freq arguments of the
	//sine oscillators are set to zero, and they are driven by the phase argument with a sweep.
	//this makes the oscillator phase resettable which is very useful for having uniform attacks
	//for low frequency kick-like sounds. or else, the envelope sounding the oscillators can kick
	//in at any phase and the attack of the kicks will vary (in a bad way). here I reset the phase
	//of the sine at each trigger. the speed of the phase driver ([52.8, 740]) determines the
	//frequency of the oscillator here. I'm adding a phase of pi/3 to it so the phase resets to
	//pi/3 instead of zero which produces an additional glitch. this is all about glitch after all right?

	var trigMod = LFNoise0.ar(8).round;

	var bass =
		SinOsc.ar(0, (Sweep.ar(ctrigs[0] * trigMod, 2pi * [52.8, 740]) + (pi/3)).wrap(-pi, pi), [2, 0.05]).mean.tanh *
		EnvGen.ar(Env([0, 0.5, 0.4, 0], [0, 0.2, 0.01], -5), (ctrigs[0] * trigMod).abs)!2;

	//panning and enveloping of snd1. I don't want to use every trigger for the envelope of this so
	//i again multiply it with a random generator. not all trigs pass through. and some random panning.
	snd1 =
		Pan2.ar
		(
			snd1 * EnvGen.ar(Env([0, 1, 0.6, 0], [0.0001, 0.4, 0.01]), ctrigs * LFNoise0.ar(8)),
			TRand.ar(-1, 1, ctrigs)
		);

	//i'm using limiter here because i'm lazy. one needs to get the
	//gain scheduling right for a better sound. this especially kills the bass
	//sometimes. I'm also boosting the freqs around 15000Hz.
	//delete some sounds from the input of MidEQ to hear the sounds
	//(glitches, bass etc) in isolation.
	Limiter.ar(MidEQ.ar(clicks + snd1 + hiNoise + bass, 14000, 0.7, 8));
}.play;
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// adding many things to the top level spawn.
(
{
	var exc, amp;
	amp = LFPulse.kr(0.001,0,0.00006,0.007);
	exc = LPZ1.ar(GrayNoise.ar([amp,amp]));
	Klank.ar(`[FloatArray.fill(4, { rrand(80.0,400.0) }),
			nil,
			FloatArray[/*parametrizar*/1, 1, 1, 1]], exc);
}.play;
);
(
{
	var exc, amp;
	amp = LFPulse.kr(0.001,0,0.00006,0.007);
	exc = LPZ1.ar(GrayNoise.ar([amp,amp]));
	Klank.ar(`[FloatArray.fill(4, { rrand(80.0,100.0) }),
			nil,
			FloatArray[/*parametrizar*/5, 5, 5, 5]], exc);
}.play;
);


//Monotrón//

((
// Definición del SynthDef
SynthDef(\madera, {
    arg freq = 440, amp = 0.5, dur = 1;

    // Generar sonido
    var exc, snd;
    exc = LPZ1.ar(GrayNoise.ar([amp, amp]));
    snd = Klank.ar(
        `[
            FloatArray.fill(4, { rrand(80.0, 400.0) }),
            nil,
            FloatArray[1, 1, 1, 5]
        ],
        exc
    );

    // Aplicar envolvente
    snd = snd * EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);

    // Salida del sonido
    Out.ar(0, snd * amp);
}).add;
);
s.quit;
y=0;

w= Window.new("Play a tone for each key");

w.view.keyDownAction= {
	arg view , chars, modifiers, unicode,keycode;
	y.free;


	if( keycode >71,
		(
			{
				var exc, amp, freqs;
				var escalaIndia = [261.63, 293.66, 327.03, 392.00/2, 436.05/2, 490.55/2, 523.25/2];
				var escalaGitana = [261.63, 294.33, 329.63, 391.99, 440.00/2, 493.88/2, 587.33/2];
				amp = LFPulse.kr(MouseX.kr(0.01, 0.000001),0,0.00006,0.0007);
				freqs = escalaGitana.choose;
				exc = LPZ1.ar(GrayNoise.ar([amp,amp]));
				Klank.ar(`[FloatArray.fill(1, { freqs}),
					nil,
					FloatArray[/*parametrizar*/5, 5, 5, 5]], exc);
			}.play;

		);

	)};

w.front;

//MouseX.kr(0.0001,0.01)
)

(
{
var root, scale;
			// bowed string
		var trig, p, s, exc, x, freq;
		//root = rrand(3,6);
		root = 5;
		scale = #[0,2,4,5];
			freq = (scale.choose + #[24,36,48,30,32,44].choose + root).midicps;
			exc = BrownNoise.ar([0.007,0.007]) * max(0, LFNoise1.kr(exprand(0.125,0.5), 0.6, 0.4));
			s = (Klank.ar(`[
					Array.series(12, freq, freq),
					Array.geom(12,1,rrand(0.7,0.9)),
					Array.fill(12, {rrand(1.0,3.0)})
				], exc) * 0.1).softclip;
}.play;
)


s.record;
s.stopRecording;

s.boot;

Platform.recordingsDir.openOS;


(
// sweepy noise - mouse controls LFO
{
	var lfoDepth, lfoRate, freq, filtered;
	lfoDepth = MouseY.kr(100, 1500, 'exponential');
	lfoRate = MouseX.kr(4, 60, 'exponential');
	freq = Impulse.kr(lfoRate, 0, lfoDepth, lfoDepth * 1.2);
	filtered = RLPF.ar(BrownNoise.ar([0.03,0.03]), freq, 1);
	CombN.ar(filtered, 0.3, 0.3, 2, 1, filtered);
}.play
)

(
// sweepy noise - mouse controls LFO
{
	var lfoDepth, lfoRate, freq, filtered;
	lfoDepth = MouseY.kr(100, 1500, 'exponential');
	lfoRate = MouseX.kr(4, 60, 'exponential');
	freq = Impulse.kr(lfoRate, 0, lfoDepth, lfoDepth * 2.2);
	filtered = RLPF.ar(BrownNoise.ar([0.03,0.03]), freq, 0.9);
	CombN.ar(filtered, 0.3, 0.3, 4, 1, filtered);
}.play
)

(
// sweepy noise - mouse controls LFO
{
	var lfoDepth, lfoRate, freq, filtered;
	lfoDepth = MouseY.kr(100, 1500, 'exponential');
	lfoRate = MouseX.kr(4, 60, 'exponential');
	freq = Impulse.kr(lfoRate, 0, lfoDepth, lfoDepth * 3.2);
	filtered = RLPF.ar(BrownNoise.ar([0.03,0.03]), freq, 0.9);
	CombN.ar(filtered, 0.3, 0.3, 2, 1, filtered);
}.play
)


(
SynthDef(\freeverb, {
    arg in, out, mix=0.5, room=0.7, damp=0.5;
    var dry, wet, input;
    input = In.ar(in, 2);
    dry = Pan2.ar(input, mix);
    wet = FreeVerb.ar(input, 0.5, room, damp);
    Out.ar(out, dry + wet);
}).add;
)
// Cargar el synthdef de FreeVerb si no está cargado
s.meter;
// Cargar el synthdef de FreeVerb si no está cargado
s.meter;

// Función para generar un sonido con reverb
(
{
    var frecuencia = 55;
    var duracion = 0.01;

    // Generar el sonido del kick
    var sonido = SinOsc.ar(frecuencia, 0, 0.9) * EnvGen.kr(Env.perc(0.005, duracion), doneAction: 2);

    // Modificar el espectro para un sonido más "plástico"
    sonido = sonido * LFNoise1.kr(5).range(1.2, 1.2); // Agrega variabilidad al volumen

    // Aplicar un filtro de paso bajo para enfatizar las frecuencias bajas
    sonido = sonido * LPF.ar(sonido, 100);

    // Aplicar reverb
    sonido = Synth(\freeverb, [
        \in, sonido,
        \out, 0,
        \room, 0.7,  // Ajusta estos parámetros según tus preferencias
        \damp, 0.5
    ]);

    // Salida del sonido
    Out.ar(0, sonido);
}.fork;
)
s.boot;


//bd
(
{
	// metallic
	var trig, p, exc, x, s;
		var env = EnvGen.kr(Env([0, 1, 0], [0.01, 007]), doneAction: 2);
	exc = BrownNoise.ar(Decay2.kr(Impulse.kr(#[40].choose, 0, [0.04, 0.04]), 0.005, 0.05));
	s = (Klank.ar(`[Array.fill(12, {linrand(2000.0) + 60}), nil, Array.fill(1, {rrand(0.1, 2.0)})], exc) * 0.1).softclip;

	// Envelope con ataque, sustain y liberación


	// Aplicar la envolvente al sonido
	s = s * env;

	// Agregar reverberación densa con FreeVerb directamente al sonido
	s = FreeVerb.ar(s, 0, 0.7,1,0.5);

}.play;
)

//klank

(
// harmonic tumbling
play({
	var f, p, z, trig;
	f = MouseX.kr(17,40);	// fundamental frequency
	p = 40;	// number of partials per channel
	z = 0.1;	// start of oscil daisy chain
	trig = XLine.kr([1,1], 0.5, 0.1
	);	// trigger probability decreases over time
	p.do({ arg i;
		z = FSinOsc.ar(
				f * (i+1), 		// freq of partial
				0,
				Decay2.kr(
					Dust.kr(
						trig,		// trigger rate
					MouseY.kr(0.02,0.7)		// trigger amplitude
					),
					0.00005, 	// grain attack time
				0.01	// grain decay time
				),
				z
		)
	});
	z
}))






// Detener el sonido después de un tiempo
s.meter;
s.quit;




(
{
	var exc, amp;
	var keyState;

	// Definir una función para manejar la producción sonora
	{
		var freqs = [80, 120, 200, 300];
		var randFreq = freqs.choose;

		amp = LFPulse.kr(0.00001, 0, 0.00006, 0.007);
		exc = LPZ1.ar(GrayNoise.ar([amp, amp]));
	Klank.ar(`[FloatArray.fill(4, { rrand(80.0,400.0) }),
			nil,
			FloatArray[/*parametrizar*/1, 1, 1, 1]], exc);
	}.play;

	// Configurar la tecla "a" para activar la función
	keyState = KeyState.kr('a');

	// Controlar la producción sonora en función de la tecla presionada
	amp = LinLin.kr(keyState, 0, 1, 0.1, 0.5);

	// Esperar antes de liberar el recurso

	keyState.free;

}.fork;
)



(
{
	CombN.ar(LPF.ar(LFNoise0.ar(MouseX.kr([1,2200])*[1,1.1],LFPulse.kr(1,0,0.3,0.1)), 800).abs, 0.2, [0.2,0.17], 5);
}.play;
)



// To Come:
// Roessler attractor. See Rossler.ar for a chaotic noise implementation.
// Duffing Oscillator






 // Prep
Server.default.boot;

// Función para reproducir el archivo de audio con ruido rosa
(
~playWithPinkNoise = { |path, out = 0, pinkAmp = 1|
	if (~buffer.notNil) { ~buffer.free };
	Buffer.read(
		Server.default, path, action: { |buffer|
			~buffer = buffer;
			~synth = {
				var left, right, pink;
				"===================== STARTED ===================== ".postln;

				// Genera ruido rosa
				pink = SinOsc.ar * pinkAmp ;

				// Lee el archivo de audio
				#left, right = PlayBuf.ar(2, ~buffer, BufRateScale.kr(~buffer), doneAction: 2);

				// Mezcla el ruido rosa con la salida del archivo de audio
				Out.ar(out, [(left * pink), (right * pink)]);
			}.play(args: [\out, out]);
	});
};

)

// Ejemplo de uso
~playWithPinkNoise.("/Users/franciscojosemastucci/Downloads/onlymp3.to - Fiesta casi nudista en Rusia genera acciones legales contra asistentes-cXea5OHsrKs-192k-1704574218.wav",1, 0.1);


/////
(
{
	({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 14)
		* 400 + 500, 0.03, 0.003)}!2)
		+ ({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 20)
		* 800 + 1000, 0.03, 0.005)}!2)
		* 4
}.play
)



s.record;
s.stopRecording;

s.boot;

Platform.recordingsDir.openOS;
/////

(
	// sample and hold liquidities
	// mouse x controls clock rate, mouse y controls center frequency
{
	var clockRate, clockTime, clock, centerFreq, freq, panPos, patch;

	clockRate = MouseX.kr(1, 200, 'exponential');
	clockTime = clockRate.reciprocal;
	clock = Impulse.kr(clockRate, 0.4);

	centerFreq = MouseY.kr(80, 1000, 'exponential');
	freq = Latch.kr(WhiteNoise.kr(centerFreq * 0.5, centerFreq), clock);
	panPos = Pulse.kr(WhiteNoise.kr, clock);
	patch = CombN.ar(
			Pan2.ar(
				SinOsc.ar(
					freq,
					0,
					Decay2.kr(clock, 0.1 * clockTime, 0.9 * clockTime)
				),
				panPos
			),
			0.3, 0.3, 2
		);
	patch
}.play
)
(
// sweep verb
{
	var s, z, y;

	s = SoundIn.ar([0,1], 0.01) ;

		// reverb predelay time :
	z = DelayN.ar(Mix.ar(s), 0.048);

		// 6 modulated comb delays in parallel :
	y = Mix.ar(CombL.ar(z, 0.1, LFNoise1.kr(Array.fill(6,{0.1.rand}), 0.04, 0.05), 15));

		// chain of 4 allpass delays on each of two channels (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand,0.050.rand], 1) });

	// eliminate DC
	LeakDC.ar(y)
}.play
)



