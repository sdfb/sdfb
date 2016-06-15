
// The levels can be redefined by the user at any points, and there can be any number of levels
// Everything else on the page will be generated based on this list
var LEVELS = [0, 1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

// This defines the size of the outer circle
var outerSize = 29;

// Objects referenced on the page
var canvas = document.getElementById('circle-canvas');
var circle = document.getElementById('circle-bar');
    
// These settings are grabbed from the page
var settings = {
    points: circle.getAttribute('data-points'),
    lineWidth: circle.getAttribute('data-width'),
    size: circle.getAttribute('data-size')
};

// This gets the current user level based on the list of level requirements
var detectLevel = function(points){
    level = 0;
    for (var i = 1; i < LEVELS.length; i++){
        if (points < LEVELS[i]) return level + 1;
        else level++;
    }
    if (points >= LEVELS[LEVELS.length - 1]){
        return LEVELS.length - 1;
    }
    return level;
};

// Generates the text in the center of the progress circle
var span = document.createElement('div');
span.className = "progress-text";
span.textContent = 0 + '%';

// Gets the users level and does calculations to populate the page with data
var userLevel = detectLevel(settings.points);
if (settings.points < LEVELS[LEVELS.length - 1]){
    var nextLevelPoints = LEVELS[userLevel];
    var pointsBetweenLevels = LEVELS[userLevel] - LEVELS[userLevel - 1];
    var progressToNextLevel = pointsBetweenLevels - (nextLevelPoints - settings.points);
    var percentComplete = progressToNextLevel / pointsBetweenLevels;
    // Changes the text when the mouse enters and leaves the center
    span.onmouseenter = function(){
        if (settings.points < LEVELS[LEVELS.length - 1]){
            updateText((nextLevelPoints - settings.points), '<br>Points To <br> Next Level');
        }
    };
    span.onmouseleave = function(){
        revertText();
    };
}
else{
    var percentComplete = 100/100;
}

// Sets the data in elements on the page to the proper values
document.getElementById('userlevel').textContent = userLevel;
document.getElementById('levelcount').textContent = LEVELS.length - 1;
document.getElementById('totalpoints').textContent = settings.points;
document.getElementById('pointsleft').textContent = Math.max(LEVELS[LEVELS.length - 1] - settings.points, 0);

// Defines the canvas to draw the circle
var ctx = canvas.getContext('2d');
canvas.width = canvas.height = settings.size;

// Adds datapoints to circle
circle.appendChild(span);
circle.appendChild(canvas);

// Defines starting position and rotation for circle
ctx.translate(settings.size/2, settings.size/2);
ctx.rotate((-1 / 2) * Math.PI);

// This function just draws a circle given parameters
var drawCircle = function(size, color, lineWidth, percent){
  var radius = (size - lineWidth) / 2;
  percent = Math.min(Math.max(0, percent || 1), 1);
  ctx.beginPath();
  ctx.arc(0, 0, radius, 0, Math.PI * 2 * percent, false);
  ctx.strokeStyle = color;
  ctx.lineCap = 'square';
  ctx.lineWidth = lineWidth;
  ctx.imageSmoothingEnabled = true;
  ctx.stroke();
};

// This function fills the circle slowly over time
localPercent = 1;
t = 0;
timer = setInterval(function(){
    // localPercent tracks fill progress
    if (localPercent < 100){
        // first, clears the canvas
        ctx.clearRect(0, 0, settings.size, settings.size);
        // If there are points, draw the outer circle up to the maximum multiplied by the local percent
        if (settings.points > 0){
            drawCircle(settings.size, '#FDAE61', settings.lineWidth, (localPercent / 100) * (Math.min(settings.points, 100)/LEVELS[LEVELS.length - 1]));
        }
        // Draws the outer circle background filled in completely
        drawCircle(settings.size - outerSize, '#fff', settings.lineWidth, 100 / 100);
        // percentComplete says how much the circle should be filled, defined above
        if (percentComplete > 0){
            // Fills the inner circle based on the localPercent, aka the percent currently complete
            if (settings.points < LEVELS[LEVELS.length - 1]){
                drawCircle(settings.size - outerSize, '#196B94', settings.lineWidth, (localPercent / 100) * percentComplete);
            }
            else{
                drawCircle(settings.size - outerSize + 1, '#FDAE61', settings.lineWidth, (localPercent / 100));
            }
            // Defines the inner text also based on the localPercent
            span.textContent = Math.round((localPercent / 100) * percentComplete * 100) + '%';
        }
        // v uses a smoothing function to slow down the localPercent from increasing too quickly
        v = -0.01 * t*(t/10) + 1;
        localPercent += v;
        t += 0.01;
    }
    else{
        // This case occurs when the circle is done being filled
        clearInterval(timer);
        // This draws lines from the outside of the circle that will grow inward
        size = 1;
        ctx.rotate(2 * Math.PI * 0.015);
        if (settings.points < LEVELS[LEVELS.length - 1]){
            // a new timer is set to animate these lines being drawn
            newTimer = setInterval(function(){
                if (size < 12){
                    drawLines(size);
                    size += 0.25;
                }
                else{
                    clearInterval(newTimer);
                }
            }, 10);
        }
        span.textContent = percentComplete * 100 + '%';
    }
}, 10);

// This function draws lines all the way around the circle given a current length
var drawLines = function(size){
    maxN = LEVELS[LEVELS.length - 1];
    ctx.rotate(2 * Math.PI * (LEVELS[1] - LEVELS[0])/maxN);
    for (var i = 2; i < LEVELS.length; i++){
        ctx.rotate(2 * Math.PI * (LEVELS[i] - LEVELS[i - 1])/maxN);
        drawLine(settings.size/2 - 2, size, '#FDAE61', 2);
    }
};

// This function draws an individual line at a point around the circle
var drawLine = function(dist, length, color, width){
    ctx.beginPath();
    ctx.moveTo(dist,0);
    ctx.lineTo(dist - length,0);
    ctx.strokeStyle = color;
    ctx.lineCap = 'square';
    ctx.lineWidth = width;
    ctx.stroke();
};

// Updates the center text on hover
var updateText = function(mainText, underText){
    if (span.textContent == percentComplete * 100 + '%'){
        span.textContent = mainText;
        document.getElementById('under').innerHTML = underText;
    }
};

// Reverts the center text when hover is gone
var revertText = function(){
    if (span.textContent != percentComplete * 100 + '%'){
        span.textContent = percentComplete * 100 + '%';
        document.getElementById('under').innerHTML ='<br>To Next Level';
    }
};

// When the help button is pressed, the help instructions are shown (using jQuery)
$('#account-help-btn').click(function(){
    $('#account-help').slideToggle();
});