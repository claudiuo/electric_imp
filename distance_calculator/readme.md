This is my first electric imp project; it is based on an <a href="http://ivyco.blogspot.com/2013/09/my-arduino-distance-from-home-project.html" target="details">older NinjaBlocks app</a> which used code originally written by ChrisN (thanks a lot for code and all the help).

The agent code gets geo coordinates from Christian Brosch's <a href="https://play.google.com/store/apps/details?id=broware.easygpstracker&hl=en" target="details">EasyGPSTracker</a> Android app in a string containing latitude and longitude values, plus a few other fields (docs are <a href="http://www.easygpstracker.de/index.php?page=client-server-communication" target="details">here</a>). Big thanks to Christian for writing this app, it saved me a lot of time since I am only a beginner with Android coding. Based on the lat and long values received, the agent calculates the distance to my home location and sends it to the imp.

The imp then calculates PWM values to be sent to an RGB LED connected to 3 of the imp pins (since all the imp pins are PWM capable, any 3 pins could work but for some reason in my case I discovered that pin1 doesn't work, I am not sure why so I am using pins 2, 5 and 7). The LED is on only for a few seconds and then it turns off until a new distance is received.

This is just the first version of this app and it is not very efficient because the imp is up and connected all the time; the imp.setpowersave(true) call should help a lot but still, it will drain the batteries pretty fast. Now that I have a little bit of experience with writing code for the imp, I plan to rewrite it to use imp's awesome sleep features.

<!--Since I get a distance reading every 2 minutes or so, this should work fine.-->
