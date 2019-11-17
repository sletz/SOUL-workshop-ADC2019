import("stdfaust.lib");

processor_period = 1.0f/ma.SR;
twoPi = 2 * ma.PI;

currentNote = button("gate");
noteFreq = hslider("freq", 440, 200, 1000, 1);

phaseIncrement = float(twoPi * processor_period * noteFreq);

addModulo2Pi(phase, phaseIncrement) = ba.if((new_phase >= twoPi), remainder(new_phase, twoPi), new_phase)
with {
    new_phase = phase + phaseIncrement;
};

//==============================================================================
SineOsc = amplitude * sin(phase)
letrec {
    'amplitude = ba.if((currentNote == 0), (amplitude * 0.999f), min(amplitude + 0.001f, 1.0f));
    'phase = addModulo2Pi(phase, phaseIncrement);
};

//==============================================================================
Waveshaper(x) = ma.tanh(drive*x)
with {
    drive = hslider("Drive", 1.0, 1.0, 50.0, 0.1);
};

process = SineOsc : Waveshaper;
//process = SineOsc;
