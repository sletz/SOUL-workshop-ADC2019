import("stdfaust.lib");

processor_period = 1.0f/ma.SR;

modulationRate = hslider("Rate", 2, 0.1, 20, 0.1);
modulationDepth = hslider("Depth", 25, 0, 100, 0.1) : si.smoo;
modulationShape = nentry("Shape [style:menu{'sin':0;'triangle':1}]", 0, 0, 1, 1);
delayLength = hslider("delayLength", 10, 1, 50, 1) : si.smoo;

isSineWaveform(modulationShape) = modulationShape < 0.5f;

getSineValue(phase) = sin(phase * float (2*ma.PI));
getTriangleValue(phase) = ba.if((phase < 0.5f), -1.0f + (phase * 4.0f), 1.0f - ((phase - 0.5f) * 4.0f));

// ---------------------------------------------------------------------
ChorusVoice(initialPhase, panPosition) = (Oscillator(initialPhase), _) : Delay : StereoPanner(panPosition);

// ---------------------------------------------------------------------
DryWetMixer = vgroup("Dry_wet", (_,_,_) : route(3, 4, (1,1), (1,3), (2,2), (3,4)) : (mixer, mixer))
with {
    mixer(dry, wet) = (dryLevel * 0.01f * dry) + (wetLevel * 0.01f * wet);
    dryLevel = hslider("Dry Level", 100, 0, 100, 0.1) : si.smoo;
    wetLevel = hslider("Wet Level", 50, 0, 100, 0.1) : si.smoo;
};

// ---------------------------------------------------------------------
Delay(modulationIn) = de.fdelay(16384, delaySamples)
with {
    samplesPerMs = float(ma.SR / 1000.0f);
    delaySamples = delayLength * samplesPerMs * (1.0f + modulationIn) + 1.0f;
};

// ---------------------------------------------------------------------
StereoPanner(panPosition) = _ <: *(leftLevel), *(rightLevel)
with {
    leftLevel = (1.0f - panPosition) / 2.0f;
    rightLevel = 1.0f - leftLevel;
};

// ---------------------------------------------------------------------
Oscillator(initialPhase) = modulationDepth * 0.01f * value
with {
    value = ba.if(isSineWaveform(modulationShape), getSineValue(phase), getTriangleValue(phase));
    phase = (initialPhase + (modulationRate * processor_period)) : (+ : fmod1) ~ _;
    fmod1(x) = fmod(x, 1.0f);
    fast_fmod(x, y) = x - (y * float(int(x/y)));
};

//======
// Main
//======

voice1 = ChorusVoice(0.0f, -1.0f);
voice2 = ChorusVoice(0.5f, 1.0f);

process = _ <: (_, voice1, voice2) : route(5, 3, (1,1), (2,2), (3,3), (4,2), (5,3)) : DryWetMixer;
