# Using arduinoscope #

The included processing patches (in examples/) will show you a few differnt ways to use the Oscilloscope class. The application zip files featured on front page of this project, are builds of the example SimpleSerialArduinoscope, included in the Processing lib.

To get started with changing it, or doing something different, extract [the processing lib](http://arduinoscope.googlecode.com/files/processing-arduinoscope.zip) into your sketch library dir, in a folder called "arduinoscope", or whatever you want.

You can use the included SimpleSerialArduinoscope example (in processing - Sketchbook/libraries/arduinoscope/examples) it requires you to load [the arduino patch](http://code.google.com/p/arduinoscope/source/browse/trunk/arduino_oscilliscope.pde) onto your arduino.

Here is what it looks like reading 6 analog inputs:
<img src='http://arduinoscope.googlecode.com/files/Screenshot-Oscilliscope.png' />

To set the number of scopes, in the example patch, find the line that reads
```
Oscilloscope[] scopes = new Oscilloscope[6];
```
and change 6 to how many ever you want.  [The arduino patch](http://code.google.com/p/arduinoscope/source/browse/trunk/arduino_oscilliscope.pde) sends the 6 analog ports on the first 6 places, and 12 digital pins, after that (2-13, all but 0 & 1 - serial)

If you wanted an all digital scope, for example, you could do this:
```
Oscilloscope[] scopes = new Oscilloscope[12];
```

in setup() set the ranges, in the loop over scopes:
```
// find this:
scopes[i] = new Oscilloscope(this, posv, dimv);
scopes[i].setLine_color(color((int)random(255), (int)random(127)+127, 255));

// set range to something more useful:
scopes[i].setMultiplier(1.0f);
scopes[i].setResolution(1.0f);

```

and in draw() function, change:
```
scopes[i].addData(vals[i]);
```
to
```
scopes[i].addData(vals[i+6]);
```

## Higher samplerates ##
The arduino isn't really designed to be accurate at very high sample-rates (200khz recommended ADC clock rate in specs.) Also, processing probably doesn't run fast enough on your computer to really keep up with it.

That being said, check out [this project](http://gabuku.com/scope/). gabebear has some good ideas about a more efficient serial data format, that has a sort of error-correction, which might be a nice thing to add to your own processing+arduino patch.

See [this](http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1208715493/11) for ideas on getting the arduino to read analog faster. Once you start getting up into super-high numbers, you probably should be using a DSP, or something, though.