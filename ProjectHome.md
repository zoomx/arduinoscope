I saw the wonderful [arduino/processing scope](http://accrochages.drone.ws/en/node/90), and thought of many improvements, including:
  * logic analyzer mode that shows 1's and 0's clearly.
  * pause frame
  * save frame
  * configurable pin-count
  * use as many pins as will fit on screen (tested with 12 at 800x800, seems ok)
  * use scope class in your own thing, easy to reuse, and setup any kind of GUI
  * shows volts, based on scaling settings

Arduinoscope is very much a DIY sort of tool. It makes it easy to set it up however is useful. It can be used a lot of different ways (see [Usage](http://code.google.com/p/arduinoscope/wiki/Usage) for more info)

If you just want a simple oscilloscope, using arduino, put [the arduino sketch](http://arduinoscope.googlecode.com/files/arduino-arduinoscope.pde) on your arduino, and run the pre-made application zip (in downloads to the right) for your platform.

I have started work on a new version hosted on github:
https://github.com/konsumer/arduinoscope

At some point, once the 2 GUIs are complete, this will replace this version. Feel free to fork/check it out and see the direction I am going with the new version.