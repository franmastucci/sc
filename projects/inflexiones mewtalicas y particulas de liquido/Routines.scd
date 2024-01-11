(
// Rutina para generar eventos de lluvia
( a =
{
    var numEvents = 1000; // Puedes ajustar la cantidad de eventos
    var minFreqMetal = 1;
    var maxFreqMetal = 200;
    var minDurMetal = 0.001;
    var maxDurMetal = 1.2;
    var minAmpMetal = 0.001;
    var maxAmpMetal = 0.01;

    var minFreqMadera = 200;
    var maxFreqMadera = 15000;
    var minDurMadera = 0.001;
    var maxDurMadera = 0.6;
    var minAmpMadera = 0.001;
    var maxAmpMadera = 1;

    numEvents.do {

        var freqMetal = rrand(minFreqMetal, maxFreqMetal);
        var durMetal = rrand(minDurMetal, maxDurMetal);
        var ampMetal = rrand(minAmpMetal, maxAmpMetal);
		var freqMadera = rrand(minFreqMadera, maxFreqMadera);
        var durMadera = rrand(minDurMadera, maxDurMadera);
        var ampMadera = rrand(minAmpMadera, maxAmpMadera);

        // Lanzar un evento de lluvia
        Synth(\lluviaMetal, [ \freq, freqMetal, \dur, durMetal, \amp, ampMetal ]);

		        // Generar valores aleatorios para frecuencia, duración y amplitud
		durMadera.wait;

        // Lanzar un evento de lluvia
        Synth(\lluviaMadera, [ \freq, freqMadera, \dur, durMadera, \amp, ampMadera ]);

        // Esperar un breve periodo antes de lanzar el próximo evento
        durMetal.wait;
    };
}.fork;
);

(b =
{


	var repetitions = 3;  // Definir la cantidad de repeticiones

	var freqs, durs, amps, patterns;
	var pulseDuration = 0.7;

	// Definir parámetros de la secuencia
	freqs = [ 34, 55, 89, 144, 233, 377];
	durs = [ 1, 0.1, 0.3, 3, 0.4,1,0.1,0.1,1];  // Duraciones más prolongadas
	amps = [0.01, 0.02, 0.03, 0.3, 0.2, 0.2, 0.3, 0.08, 0.01];
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
);

(
c = {
		var repetitions = 3;  // Definir la cantidad de repeticiones

		// Crear instancia del Synth para el sonido tenido
	//var tenidoSynth = Synth(\tenido, [\freq, 250, \dur, 18, \amp, 0.8]);


	// Incrementar gradualmente el volumen durante 5 segundos
	//tenidoSynth.set(\amp, 0.4, \dur, 15);
	//0.18.wait;

	//tenidoSynth.set(\amp, 0.5, \dur, 5, \freq,80);



		repetitions.do {
		~encapsulatedBehavior.play;
		0.18.wait;
		~encapsulatedBehavior.value(freq: 80,amp: 0.7, dur:5);


		// Pausa antes de la siguiente secuencia
	};
	//1.wait;

	3.wait;

}.fork;
);


)