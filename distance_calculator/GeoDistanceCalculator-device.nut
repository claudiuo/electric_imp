// GeoDistance

// Register with the server
imp.configure("GeoDistance", [], []);

imp.setpowersave(true);

// Set up 200Hz PWM, duty cycle zero (ie will stay low)
hardware.pin1.configure(PWM_OUT, 1.0/200, 0);
hardware.pin2.configure(PWM_OUT, 1.0/200, 0);
hardware.pin5.configure(PWM_OUT, 1.0/200, 0);

agent.on("dist", function(data) {
    // get the distance and the user
    local distance = data.distance;
    local user = data.user;
    
    // log them
    server.log("user: "+user);
    server.log("distance: "+distance);

    // server.log("powersave:"+imp.getpowersave());

    // calculate PWM duty cycle values
    if(distance >= 0) {
        local greenValue = getGreenPwmValue(distance);
        local blueValue = getBluePwmValue(distance);
        local redValue = getRedPwmValue(distance);
        server.log("green: "+greenValue);
        server.log("blue: "+blueValue);
        server.log("red: "+redValue);
        
        hardware.pin1.write(greenValue/100);
        hardware.pin2.write(blueValue/100);
        hardware.pin5.write(redValue/100);
    }
    // wakeup in 10 sec to turn the LEDs off
    imp.wakeup(10, turnLedsOff);
});

function turnLedsOff() {
    hardware.pin1.write(0);
    hardware.pin2.write(0);
    hardware.pin5.write(0);
}

// this section to calculate PWM values based on distance
// all distances in km
// dist > 30: RED LED
// 30 >= dist > 15: RED+BLUE LEDs: less RED, more BLUE as distance decreases
// 15 >= dist >= 0: BLUE+GREEN LEDs: less BLUE, more GREEN as distance decreases
// ranges in km
const MIN_DIST_RANGE = 0;
const MID_DIST_RANGE = 15;
const MAX_DIST_RANGE = 30;
const MAX_PWM_VALUE = 100;

function getGreenPwmValue(dist) {
    if(dist >= MID_DIST_RANGE) {
        return 0;
    } else if(dist < 0) {
        return MAX_PWM_VALUE;
    } else {
        return convertToRange(dist, MIN_DIST_RANGE, MID_DIST_RANGE, MAX_PWM_VALUE, 0);
    }
}

function getBluePwmValue(dist) {
    if(dist >= MAX_DIST_RANGE || dist <0) {
        return 0;
    } else if(dist <= MID_DIST_RANGE) {
        return convertToRange(dist, MIN_DIST_RANGE, MID_DIST_RANGE, 0, MAX_PWM_VALUE);
    } else {
        return convertToRange(dist, MID_DIST_RANGE, MAX_DIST_RANGE, MAX_PWM_VALUE, 0);
    }
}

function getRedPwmValue(dist) {
    if(dist <= MID_DIST_RANGE) {
        return 0;
    } else if(dist >= MAX_DIST_RANGE) {
        return MAX_PWM_VALUE;
    } else {
        return convertToRange(dist, MID_DIST_RANGE, MAX_DIST_RANGE, 0, MAX_PWM_VALUE);
    }
}

function convertToRange(value, srcMin, srcMax, dstMin, dstMax) {
    // value is outside source range return -1
    if (value < srcMin || value > srcMax) {
        return -1;
    }

    local srcDiff = srcMax - srcMin;
    local dstDiff = dstMax - dstMin;
    local adjValue = value - srcMin;
    //      server.log("srcDiff: "+srcDiff);
    //      server.log("dstDiff: "+dstDiff);
    //      server.log("adjValue: "+adjValue);
    return math.floor((adjValue * dstDiff / srcDiff) + dstMin);
}
