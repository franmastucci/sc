
(
(
SynthDef("bubble", { arg out=0, n=0, maxFreq = 15000, minFreq = 10000,punch = 0.002;
    Out.ar(out,
        FSinOsc.ar(
            ExpRand(minFreq, maxFreq, n),
            0, Line.kr(punch, 0, 0.01, doneAction: Done.freeSelf))
    )
}).add;
);


(
SynthDef("wood", { arg out=0, n=0, maxFreq = 8000.0, amp = 0.0125, punch = 0.01;
    Out.ar(out,
        FSinOsc.ar(
            ExpRand(20, maxFreq, n),
            0, Line.kr(punch, 0, 0.01, doneAction: Done.freeSelf) * amp)
    )
}).add;
)
)

