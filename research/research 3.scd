// Definir el SynthDef con parámetros para la envolvente
(
SynthDef(\metalico, {
    arg freq = 440, dur = 2, amp = 0.7, att = 0.01;

    var env, source;

    // Variar el tiempo de ataque con un valor aleatorio
    att = att + (att * (0.1.rand2));  // Variación del 10% del valor original

    // Configurar envolvente ADSR con parámetros
    env = EnvGen.kr(EnvGen.kr(EnvGen.kr(Env.adsr(att, 0.3, 0.5, 0.2), doneAction: 2), doneAction: 2, timeScale: dur);

    // Generar sonido con envolvente ADSR
    source = SinOsc.ar(freq) * env * amp;

    Out.ar(0, source);
}).add;
)

// Crear patrones de valores para los parámetros
var freqs = Pseq([400, 280, 390], inf);
var durs = Pseq([2, 2, 2], inf);
var amps = Pseq([0.7, 0.7, 0.7], inf);
var atts = Pseq([0.002, 0.01, 0.031], inf);

// Crear patrón de eventos utilizando Pbind
var pattern = Pbind(
    \instrument, \metalico,
    \freq, Pseq(freqs, inf),
    \dur, Pseq(durs, inf),
    \amp, Pseq(amps, inf),
    \att, Pseq(atts, inf)
);

// Reproducir el patrón
pattern.play;

// Definir el SynthDef
(
SynthDef(\tenuto2, {
	var env = EnvGen.kr(Env([0.0, 0.5, 0.0, [1.0, 1.25, 1.5], 0.9, 0.0], [0.05, 0.1, 0.01, 1.0, 1.5], -4));
	Out.ar(0, SinOsc.ar(220, 0, env) * 0.2);
}).add;
)
// Crear una función que ejecuta el SynthDef
{
	var env = EnvGen.kr(Env.perc, doneAction: 2);
	Synth(\tenuto2, [ \freq, 220, \amp, 0.2, \dur, 1, \legato, 1, \sustain, 0.7 ]);
	env.wait;
}.fork;


// Reproducir la función varias veces
(
2.do {
	{
		var env = EnvGen.kr(Env.perc, doneAction: 2);
		Synth(\tenuto,2 [ \freq, 220, \amp, 0.2, \dur, 1, \legato, 1, \sustain, 0.7 ]);
		env.wait;
	}.fork;
}
)

