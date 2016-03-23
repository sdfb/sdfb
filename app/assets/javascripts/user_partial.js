
var LEVELS = [0, 1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
var outerSize = 29;
var canvas = document.getElementById('circle-canvas');

var circle = document.getElementById('circle-bar');
    
var settings = {
    points: circle.getAttribute('data-points'),
    lineWidth: circle.getAttribute('data-width'),
    size: circle.getAttribute('data-size')
};

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

var span = document.createElement('div');
span.className = "progress-text";
span.textContent = 0 + '%';

var userLevel = detectLevel(settings.points);
if (settings.points < LEVELS[LEVELS.length - 1]){
    var nextLevelPoints = LEVELS[userLevel];
    var pointsBetweenLevels = LEVELS[userLevel] - LEVELS[userLevel - 1];
    var progressToNextLevel = pointsBetweenLevels - (nextLevelPoints - settings.points);
    var percentComplete = progressToNextLevel / pointsBetweenLevels;
    span.onmouseenter = function(){
        updateText((nextLevelPoints - settings.points), '<br>Points To <br> Next Level');
    };
    span.onmouseleave = function(){
        revertText();
    };
}
else{
    var percentComplete = 100/100;
}

document.getElementById('userlevel').textContent = userLevel;
document.getElementById('levelcount').textContent = LEVELS.length - 1;
document.getElementById('totalpoints').textContent = settings.points;
document.getElementById('pointsleft').textContent = Math.max(LEVELS[LEVELS.length - 1] - settings.points, 0);

var ctx = canvas.getContext('2d');
canvas.width = canvas.height = settings.size;

circle.appendChild(span);
circle.appendChild(canvas);

ctx.translate(settings.size/2, settings.size/2);
ctx.rotate((-1 / 2) * Math.PI);

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


localPercent = 1;
t = 0;
timer = setInterval(function(){
    if (localPercent < 100){
        ctx.clearRect(0, 0, settings.size, settings.size);
        if (settings.points > 0){
            drawCircle(settings.size, '#FDAE61', settings.lineWidth, (localPercent / 100) * (Math.min(settings.points, 100)/LEVELS[LEVELS.length - 1]));
        }
        drawCircle(settings.size - outerSize, '#fff', settings.lineWidth, 100 / 100);
        if (percentComplete > 0){
            if (settings.points < LEVELS[LEVELS.length - 1]){
                drawCircle(settings.size - outerSize, '#196B94', settings.lineWidth, (localPercent / 100) * percentComplete);
            }
            else{
                drawCircle(settings.size - outerSize + 1, '#FDAE61', settings.lineWidth, (localPercent / 100));
            }
            span.textContent = Math.round((localPercent / 100) * percentComplete * 100) + '%';
        }
        v = -0.01 * t*(t/10) + 1;
        localPercent += v;
        t += 0.01;
    }
    else{
        clearInterval(timer);
        
        size = 1;
        ctx.rotate(2 * Math.PI * 0.015);
        if (settings.points < LEVELS[LEVELS.length - 1]){
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

var drawLines = function(size){
    maxN = LEVELS[LEVELS.length - 1];
    ctx.rotate(2 * Math.PI * (LEVELS[1] - LEVELS[0])/maxN);
    for (var i = 2; i < LEVELS.length; i++){
        ctx.rotate(2 * Math.PI * (LEVELS[i] - LEVELS[i - 1])/maxN);
        drawLine(settings.size/2 - 2, size, '#FDAE61', 2);
    }
};

var drawLine = function(dist, length, color, width){
    ctx.beginPath();
    ctx.moveTo(dist,0);
    ctx.lineTo(dist - length,0);
    ctx.strokeStyle = color;
    ctx.lineCap = 'square';
    ctx.lineWidth = width;
    ctx.stroke();
};

var updateText = function(mainText, underText){
    if (span.textContent == percentComplete * 100 + '%'){
        span.textContent = mainText;
        document.getElementById('under').innerHTML = underText;
    }
};

var revertText = function(){
    if (span.textContent != percentComplete * 100 + '%'){
        span.textContent = percentComplete * 100 + '%';
        document.getElementById('under').innerHTML ='<br>To Next Level';
    }
};

$('#account-help-btn').click(function(){
    $('#account-help').slideToggle();
});