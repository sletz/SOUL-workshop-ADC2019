import("stdfaust.lib");

processor_period = 1.0f/ma.SR;

modulationRate = hslider("Rate", 2, 0.1, 1000, 0.1);
modulationDepth = hslider("Depth", 50, 0, 100, 0.1);
modulationShape = nentry("Shape", 0, 0, 1, 1);

isSineWaveform(modulationShape) = modulationShape < 0.5f;

getSineValue(phase) = sin(phase * float(2 * ma.PI));
getTriangleValue(phase) = ba.if((phase < 0.5f), -1.0f + (phase * 4.0f), 1.0f - ((phase - 0.5f) * 4.0f));

// ---------------------------------------------------------------------
StereoPanner(panPosition) = _ <: *(leftLevel), *(rightLevel)
with {
    leftLevel = (1.0f - panPosition) / 2.0f;
    rightLevel = 1.0f - leftLevel;
};

// ---------------------------------------------------------------------
Oscillator = modulationDepth * 0.01f * value
with {
    value = ba.if(isSineWaveform(modulationShape), getSineValue(phase), getTriangleValue(phase));
    phase = modulationRate * processor_period : (+ : fmod1) ~ _;
    fmod1(x) = fmod(x, 1.0f);
    fast_fmod(x, y) = x - (y * float(int(x/y)));
};

// ---------------------------------------------------------------------
Chorus = Oscillator : StereoPanner(1.0f);

//======
// Main
//======

process = Chorus;

