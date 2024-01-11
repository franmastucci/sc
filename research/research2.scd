º// Configuración básica
s.boot;

// Función para generar un sonido de madera
(
SynthDef(\wood, {
    arg freq = 20, amp = 0.5, dur = 0.5;

    var env, source, reverb, filtered;

    // Envolvente percusiva
    env = EnvGen.kr(Env.adsr(0, 0.35, 0, 0.7));

    // Oscilador de pulso para obtener un sonido más complejo
    source = Pulse.ar(freq, 0.5) * env * amp;

	filtered = BLowPass.ar(source, 650);

    // Aplicar reverberación
    reverb = FreeVerb.ar(filtered, mix: 0.5, room: 1, damp: 0);

    // Salida del sonido
    Out.ar(0, reverb);
}).add;
)



(
SynthDef("tenido", {
	arg freq =200, dur = 2, amp = 0;

    var env, source;

    // Generar envolvente de crescendo
    env = EnvGen.kr(Env.perc, doneAction: 1, timeScale: dur, doneAction: 2);
    source = SinOsc.ar(freq) * env * amp;

    Out.ar(0, source);
}).add;
)



// Secuencia rítmica de sonidos de madera
(a =
{


	var repetitions = 2;  // Definir la cantidad de repeticiones

	var freqs, durs, amps, patterns;
	var pulseDuration = 0.7;

	// Crear instancia del Synth para el sonido tenido
	var tenidoSynth = Synth(\tenido, [\freq, 250, \dur, 18, \amp, 0.8]);

	// Incrementar gradualmente el volumen durante 5 segundos
	tenidoSynth.set(\amp, 0.4, \dur, 15);
	0.18.wait;
	tenidoSynth.set(\amp, 0.5, \dur, 5, \freq,80);

	// Pausa antes de la siguiente secuencia
	3.wait;

	// Definir parámetros de la secuencia
	freqs = [ 34, 55, 89, 144, 233, 377];
	durs = [ 1, 0.1, 0.3, 3, 0.4,1,0.1,0.1,1];  // Duraciones más prolongadas
	amps = [0.1, 0.2, 0.3, 0.3, 0.2, 0.2, 0.3, 0.8, 0.1];
	patterns = [[0, 1, 2, 3,4,5], [ 5, 4,3,2,1]]; // Patrones de variación

	// Reproducir la secuencia con variaciones
	repetitions.do {
		patterns.do { |pattern|
			pattern.do { |index|
				Synth(\wood, [
					\freq, freqs[index],
					\dur, durs[index]*pulseDuration,  // Ajustar la duración según pulseDuration
					\amp, amps[index]
				]);

				// Pausa entre sonidos
				0.1*durs.choose.wait;
			};
			// Pausa entre patrones
			0.3.wait;
		};
	};

	2.wait;


	~encapsulatedBehavior.value(freq: 196,amp: 0.06, dur:3);
	0.1.wait;
	~encapsulatedBehavior.value(freq: 80,amp: 0.01, dur:4);
	0.01.wait;

		// Esperar antes de finalizar
	//10.wait;

	//0.18.wait;
	//tenidoSynth.set(\amp, 0.5, \dur, 5, \freq, 80);
}.fork;
)

a.stop;


~encapsulatedBehavior.value(freq: 1000,amp: 0.01, dur:1);


(
// Definir la función para el comportamiento encapsulado
~encapsulatedBehavior = {
	arg freq, amp, dur;

	// Crear instancia del Synth para el sonido tenido
	var tenidoSynth = Synth(\tenido, [\freq, freq, \dur, 2, \amp, amp]);

	// Incrementar gradualmente el volumen durante 5 segundos
	tenidoSynth.set(\amp, 0.4, \dur, dur);
	0.18.wait;
	tenidoSynth.set(\amp, amp, \dur, 3, \freq,freq);

	// Pausa antes de la siguiente secuencia
};
)



// Llamar a la función con parámetros específicos
~encapsulatedBehavior.value(freq: 80, amp: 0.8, delay: 0.18);

// Detener la ejecución después de un tiempo (puedes ajustar esto)
30.wait;
s.quit;
