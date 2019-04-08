clearscreen.
print "Ascent guidance enabled.  Hands off the stick!".
print "Staging is not handled by this program.".

// Heading will stay locked to startAngle until apoapsis reaches this point.
parameter turnStartAltitude is 500.
// How fast the autopilot will pitch the craft down. Higher numbers mean you will go horizontal faster.
parameter turnSpeedMultiplier is 1.2.
// Program will terminate when apoapsis reaches this point.
parameter targetAltitude is 80000.
// Angle of the craft at inial burn.  90 is vertical.  Change if you're using clamps to start at an angle.
parameter startAngle is 90.
// If set to a number, when the craft hits this stage, the program will terminate.
// If set to false, the program will only terminate when apoapsis reaches target altitude.
parameter endOnStage is false.
// Allows you to set the ascent profile to a parabolic curve.  1 is for a linear function.
parameter profileCurve is 0.75.
// Ascent angle cannot be set higher than this number.
parameter maxAngle is 90.
// Ascent angle cannot be set lower than this number.
parameter minAngle is 1.
// The cardinal direction that the craft will be pitching towards.  East by default.
// Note: You should roll your craft out to the launch pad with its belly facing the direction you want to pitch toward.
parameter startRoll is 90.

set oldSAS to SAS.
set SAS to false.

set headingCalc to heading(startRoll,startAngle).
lock steering to headingCalc.

// play around with the parameters here: https://www.desmos.com/calculator/cofygusacw 
lock ascentAngle to startAngle - (startAngle * turnSpeedMultiplier) * (ship:apoapsis - turnStartAltitude)^profileCurve / ((targetAltitude - turnStartAltitude)^profileCurve).

lock throttle to 1.0.

print "Ascent angle is: " + round(startAngle,2).
until ship:apoapsis >= targetAltitude {
    if endOnStage and (stage:number <= endOnStage) {
        print "Target stage met, terminating guidance program...".
        break.
    }

    if ship:apoapsis < turnStartAltitude {
        print "Ascent angle is: " + round(startAngle,2) + "   " at (0,2).
        set headingCalc to heading(startRoll,startAngle).
    } else {
        if ascentAngle >= minAngle and ascentAngle <= maxAngle {
            set headingCalc to heading(startRoll, ascentAngle).
            print "Ascent angle is: " + round(ascentAngle,2) + "   " at (0,2).
        }
    }
}

// cleanup
set ship:control:pilotMainThrottle to 0.
set SAS to oldSAS.
print "Launch guidance terminated.  Control returned to pilot.".