
​
​//{ Crackle.ar(Line.kr(1.0, 2.0, 3), 0.5, 0.5) * 0.1 }.play;

(
(d =
({

    1000.do({ |pattern|
        Synth("bubble",[
			\minFreq, 1000,
		    \maxFreq, 15000,
			\amp, 0.02,
			\punch , 0.005 ]
		);
				0.01.wait;

}); });
);

(e =
{
    // Definir los parámetros de la envolvente
    var env = EnvGen.kr(
        Env([0, 1, 0], [0.01, 20]),
        doneAction: 2  // Libera automáticamente la instancia de Synth cuando la envolvente termina
    );

    // Generar sonido con ruido marrón y aplicar la envolvente
    var sound = BrownNoise.ar(0.1) * 0.03 * env;

    // Salida del sonido
    Out.ar(0, sound);
};
);

(g =
{
    // Definir los parámetros de la envolvente
    var env = EnvGen.kr(
        Env([0, 0.9, 0], [0.01, 5]),
        doneAction: 2  // Libera automáticamente la instancia de Synth cuando la envolvente termina
    );

    var sound = Pulse.ar(0.1) * 0.3 * env;

	var reverb = FreeVerb.ar(sound, mix: 0.5, room: 1, damp: 2);

    // Salida del sonido
    Out.ar(0, reverb);
};
);
(f =
({

    50.do({ |pattern|
        Synth("wood",[
		    \maxFreq, 500,
			\amp, 0.7,
			\punch , 0.05 ]
		);

		Synth("wood",[
			\maxFreq, 15000,
			\amp, 0.5 ,
			\punch , 0.01 ]
		);
		0.1.wait;
	});

	7.do({ |pattern|
        Synth("wood",[
		    \maxFreq, 500,
			\amp, 0.7,
			\punch , 0.05 ]
		);

		0.012.wait;
		Synth("wood",[
			\maxFreq, 15000,
			\amp, 0.5 ,
			\punch , 0.01 ]
		);
		0.14.wait;
	});

})
);
(c =
({

    50.do({ |pattern|
        Synth("wood",[
		    \maxFreq, 500,
			\amp, 0.7,
			\punch , 0.05 ]
		);

		Synth("wood",[
			\maxFreq, 15000,
			\amp, 0.5 ,
			\punch , 0.01 ]
		);
		0.1.wait;
	});

	13.do({ |pattern|
        Synth("wood",[
		    \maxFreq, 500,
			\amp, 0.7,
			\punch , 0.05 ]
		);

		0.012.wait;
		Synth("wood",[
			\maxFreq, 15000,
			\amp, 0.5 ,
			\punch , 0.01 ]
		);
		0.14.wait;
	});

    13.do({ |pattern|
        Synth("wood",[
		    \maxFreq, 500,
			\amp, 0.7,
			\punch , 0.05 ]
		);

		Synth("wood",[
			\maxFreq, 15000,
			\amp, 0.5 ,
			\punch , 0.01 ]
		);
		0.18.wait;
	});

	    7.do({ |pattern|
        Synth("wood",[
		    \maxFreq, 500,
			\amp, 0.7,
			\punch , 0.05 ]
		);

		Synth("wood",[
			\maxFreq, 15000,
			\amp, 0.5 ,
			\punch , 0.01 ]
		);
		0.25.wait;
	});

})
))
















