
// Definir dos SynthDef para el sonido de la lluvia
(
SynthDef(\lluviaMetal, {
    arg freq = 0, dur = 0.1, amp = 0.05;

    // Generar una envolvente percusiva
	var env = EnvGen.kr(Env.perc(0.01,0.01,0.25,-8.8), doneAction: 2);

    // Generar sonido usando un oscilador sinusoidal
    var source = WhiteNoise.ar(env, env) ;

    // Salida del sonido
    Out.ar(0, source);
}).add;



SynthDef(\lluviaMadera, {
    arg freq = 220, dur = 0.01, amp = 0.5;

    // Generar una envolvente percusiva
	var env = EnvGen.kr(Env.perc(0.01,0.01,0.55,-9.8), doneAction: 2);

    // Generar sonido usando un oscilador sinusoidal
    var source = PinkNoise.ar(env, env) ;

    // Salida del sonido
    Out.ar(0, source);
}).add;

SynthDef(\wood, {
    arg freq = 20, amp = 0.5, dur = 0.5;

    var env, source, reverb, filtered;

    // Envolvente percusiva
    env = EnvGen.kr(Env.adsr(0, 0.035, 0, 0.2));

    // Oscilador de pulso para obtener un sonido más complejo
    source = BrownNoise.ar(freq, 0.5) * env * amp;

	filtered = BLowPass.ar(source, 650);

    // Aplicar reverberación
    reverb = FreeVerb.ar(filtered, mix: 0.5, room: 0.01, damp:20);

    // Salida del sonido
    Out.ar(0, reverb);
}).add;


)
