// Configuración básica
s.boot;

// SynthDef para el sonido metálico con envolvente ADSR
(
SynthDef(\metalico, {
    arg freq = 400, dur = 2, amp = 0.5, att=  0.1;

    var env, source;

	att = att + (att * (0.1.rand2));  // Variación del 10% del valor original


    // Configurar envolvente ADSR
	env = EnvGen.kr(Env.adsr(att, 0.35, 0, 0.7));

    // Generar sonido metálico con envolvente ADSR
    source = SinOsc.ar(freq) * env * amp;

    Out.ar(0, source);
}).add;
)

{
    var freqs = [400, 280, 390];
    var durs = [2, 2, 2];
    var amps = [0.7, 0.7, 0.9];
    var atts = [0.002, 0.01, 0.031];

    // Crear instancias del Synth con variaciones dinámicas
    3.do { |i|
        Synth(\metalico, [
;            \freq, freqs[i],
            \dur, durs[i],
            \amp, amps[i],
            \att, atts[i]
        ]);
    };
}.fork

// Definir parámetros del arpegio


// Función para convertir grados a frecuencias en el contexto actual
{

};

// Arpegiador
{
	arg degree;
	var baseFreq = 400;
	var arpeggioIntervals = [0, 4, 7];  // Intervalos para crear un acorde mayo
	var durs = [0.5, 0.5, 0.5];  // Duración de cada nota
    var amps = [0.7, 0.7, 0.9];  // Amplitud de cada nota
    var atts = [0.002, 0.01, 0.031];  // Ataque de cada nota
	var env = EnvGen.kr(EnvGen.kr([0, 1, 1, 0], [0.1, 0.8, 0.1], -4, 2), doneAction: 2);


	baseFreq * (2 ** (degree / 12));

	//amps = amps*env;

    // Crear instancias del Synth con variaciones dinámicas
    inf.do { |i|
        arpeggioIntervals.do { |degree|
            Synth(\metalico, [
				\freq, (baseFreq * (2 ** (degree / 12))),
                \dur, durs.choose,
				\amp, amps.choose,
                \att, atts.choose
            ]);
        };

        // Esperar hasta que termine el arpegio antes de comenzar otro
        0.5.wait;
    };
}.fork;

// Arpegiador
{
	arg degree;
	var baseFreq = 400;
	var arpeggioIntervals = [0, 4, 7];  // Intervalos para crear un acorde mayor
	var durs = [0.5, 0.5, 0.5];  // Duración de cada nota
    var amps = [0.7, 0.7, 0.9];  // Amplitud de cada nota
    var atts = [0.002, 0.01, 0.031];  // Ataque de cada nota
	var env = EnvGen.kr(EnvGen.kr([0, 1, 1, 0], [0.1, 0.8, 0.1], -4, 2), doneAction: 2);

	// Variables para comunicación entre hilos
	var result;
	var condition = Condition.new;

	// Función que realiza el arpegio
	var doArpeggio = {
		baseFreq * (2 ** (degree / 12));

		amps = amps * env;

		// Crear instancias del Synth con variaciones dinámicas
		inf.do { |i|
			arpeggioIntervals.do { |degree|
				Synth(\metalico, [
					\freq, (baseFreq * (2 ** (degree / 12))),
					\dur, durs.choose,
					\amp, amps.choose,
					\att, atts.choose
				]);
			};

			// Esperar hasta que termine el arpegio antes de comenzar otro
			0.5.wait;
		};

		// Establecer el resultado y notificar al hilo principal
		result = "¡Arpegio terminado!";
		condition.signal;
	};

	// Ejecutar la función en un hilo separado
	doArpeggio.fork;

	// Esperar hasta que se complete el arpegio y obtener el resultado
	condition.wait;

	// Utilizar el resultado en el hilo principal
	result.postln;

}
.fork;


// Crear instancia del Synth para el sonido metálico
Synth(\metalico2, [\freq, 400, \dur, 2, \amp, 0.7, \att, 0.002]);
Synth(\metalico, [\freq, 280, \dur, 2, \amp, 0.7, \att, 0.01]);
Synth(\metalico, [\freq, 390, \dur, 2, \amp, 0.7, \att, 0.031]);

// Detener la ejecución después de un tiempo (puedes ajustar esto)
5.wait;
s.quit;

