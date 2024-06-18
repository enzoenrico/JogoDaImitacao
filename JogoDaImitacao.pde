//define qual tela do jogo ta sendo mostrada
int screen = 0;

//angulação dos membros
float[] modelAngles = new float[4];
float[] playerAngles = new float[4];
float[][] armAnchors = new float[2][7];
float[][] legAnchors = new float[2][7];

//tempo ingame
float initialTime, maxTime = 15, minTime = 10, timeReduction = 1;

boolean lost = false;
float tolerance = 0.25;
int victories = 0;

int[] modelColors = new int[3];
int[] playerColors = new int[3];
boolean[] keysPressed = new boolean[4];

//inicializa tudo
void setup() {
    size(1980, 768);
    initializeAnchors();
    initializeCharacters();
}

void initializeAnchors() {
    float spacing = TWO_PI / 7;
    for (int i = 0; i < 7; i++) {
        armAnchors[0][i] = -PI + i * spacing;
        armAnchors[1][i] = -PI + i * spacing;
        legAnchors[0][i] = -PI + i * spacing;
        legAnchors[1][i] = -PI + i * spacing;
    }
}

void initializeCharacters() {
    for (int i = 0; i < 4; i++) {
        if (i < 2) {
            modelAngles[i] = armAnchors[i][int(random(7))];
            playerAngles[i] = armAnchors[i][int(random(7))];
        } else {
            modelAngles[i] = legAnchors[i - 2][int(random(7))];
            playerAngles[i] = legAnchors[i - 2][int(random(7))];
        }
    }
    
    modelColors = new int[]{int(random(256)), int(random(256)), int(random(256))};
    playerColors = new int[]{int(random(256)), int(random(256)), int(random(256))};
    
    initialTime = millis();
}

void drawCharacter(float[] angles, float x, float y, int[] bodyColors) {
    pushMatrix();
    translate(x, y);
    fill(bodyColors[0], bodyColors[1], bodyColors[2]);
    rect( -40, -120, 80, 240);
    
    ellipse(0, -160, 80, 80);
    
    pushMatrix();
    translate(50, -100);
    rotate(angles[0]);
    rect( -10, -15, 200, 30);
    textSize(16);
    textAlign(CENTER, CENTER);
    fill(255);
    text("Right Arm", 100, 15);
    popMatrix();
    
    fill(bodyColors[0], bodyColors[1], bodyColors[2]);
    pushMatrix();
    translate( -70, -100);
    rotate(angles[1]);
    rect( -140, -15, 200, 30);
    textSize(16);
    textAlign(CENTER, CENTER);
    fill(255);
    text("Left Arm", -100, -15);
    popMatrix();
    
    fill(bodyColors[0], bodyColors[1], bodyColors[2]);
    pushMatrix();
    translate(20, 120);
    rotate(angles[2]);
    rect( -10, -10, 40, 250);
    textSize(16);
    textAlign(CENTER, CENTER);
    fill(255);
    text("Right Leg", 20, 125);
    popMatrix();
    
    fill(bodyColors[0], bodyColors[1], bodyColors[2]);
    pushMatrix();
    translate( -30, 120);
    rotate(angles[3]);
    rect( -10, -10, 40, 250);
    textSize(16);
    textAlign(CENTER, CENTER);
    fill(255);
    text("Left Leg", 20, 125);
    popMatrix();
    
    popMatrix();
}

float calculateNearestAngle(float currentAngle, float[] anchors) {
    float nearestAngle = anchors[0];
    float smallestDistance = dist(cos(currentAngle), sin(currentAngle), cos(anchors[0]), sin(anchors[0]));
    
    for (int i = 1; i < anchors.length; i++) {
        float distance = dist(cos(currentAngle), sin(currentAngle), cos(anchors[i]), sin(anchors[i]));
        if (distance < smallestDistance) {
            nearestAngle = anchors[i];
            smallestDistance = distance;
        }
    }
    return nearestAngle;
}

void draw() {
    background(40);
    switch(screen) {
        case 0:
            initialScreen();
            break;
        case 1:
            gameScreen();
            break;
        case 2:
            finalScreen();
            break;
    }
}

void initialScreen() {
    textAlign(CENTER, CENTER);
    textSize(42);
    fill(255);
    text("Imitation Game", width / 2, height / 2 - 200);
    textSize(26);
    text("Betina Broch", width / 2, height / 2 + 40);
    text("Press Enter to start!", width / 2, height / 2 + 200);
    
    if (keyPressed && key == ENTER) {
        screen = 1;
        initializeCharacters();
        maxTime = 10;
        victories = 0;
        initialTime = millis();
    }
}

void gameScreen() {
    float remainingTime = maxTime - (millis() - initialTime) / 1000.0;
    
    if (remainingTime <= 0) {
        screen = 2;
        lost = true;
    }
    
    drawCharacter(modelAngles, width / 4, height / 2, modelColors);
    drawCharacter(playerAngles, 3 * width / 4, height / 2, playerColors);
    
    if (keyPressed) {
        if (key == '1') playerAngles[0] += 0.05;
        if (key == '2') playerAngles[1] -= 0.05;
        if (key == '3') playerAngles[2] += 0.05;
        if (key == '4') playerAngles[3] -= 0.05;
    }
    
    if (checkVictory()) {
        victories++;
        maxTime = max(minTime, maxTime - timeReduction);
        initializeCharacters();
        initialTime = millis();
    }
    
    textAlign(CENTER, CENTER);
    textSize(32);
    fill(0);
    text("Remaining Time: " + nf(remainingTime, 0, 2), width / 2, 50);
    
    textAlign(CENTER, CENTER);
    textSize(24);
    fill(255);
    text("Move limbs with 1, 2, 3 and 4", width / 2, height - 50);
}

boolean checkVictory() {
    for (int i = 0; i < 4; i++) {
        if (abs(playerAngles[i] - modelAngles[i]) > tolerance) return false;
    }
    return true;
}

void finalScreen() {
    textAlign(CENTER, CENTER);
    textSize(40);
    fill(255);
    text("Victories: " + victories, width / 2, height / 2);
    text("Press ENTER to restart", width / 2, height / 2 + 200);
    
    if (keyPressed && key == ENTER) {
        screen = 0;
        initializeCharacters();
        lost = false;
    }
}

void keyPressed() {
    if (key == '1') keysPressed[0] = true;
    if (key == '2') keysPressed[1] = true;
    if (key == '3') keysPressed[2] = true;
    if (key == '4') keysPressed[3] = true;
}

void keyReleased() {
    if (key == '1') {
        keysPressed[0] = false;
        playerAngles[0] = calculateNearestAngle(playerAngles[0], armAnchors[1]);
    }
    if (key == '2') {
        keysPressed[1] = false;
        playerAngles[1] = calculateNearestAngle(playerAngles[1], armAnchors[0]);
    }
    if (key == '3') {
        keysPressed[2] = false;
        playerAngles[2] = calculateNearestAngle(playerAngles[2], legAnchors[1]);
    }
    if (key == '4') {
        keysPressed[3] = false;
        playerAngles[3] = calculateNearestAngle(playerAngles[3], legAnchors[0]);
    }
}
