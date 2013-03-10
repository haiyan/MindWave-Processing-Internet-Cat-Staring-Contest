/*****
 A simple staring contest using the Neurosky MindWave device. The game uses the MindWave to detect
 how long the user can go without blinking, keeping a score of the number of seconds elapsed.
 
 This app uses Andreas Borg's Thinkgear library, which creates the connection with the Neurosky
 Thinkgear connector and grabs readings. The library .jar file is included, you should check if
 there have been any updated versions on his github repository (https://github.com/borg/ThinkGear-Java-socket).
 
 INSTRUCTIONS
 1. Install Thinkgear connector and make sure your MindWave works with the accompanying demos (http://developer.neurosky.com/docs/doku.php?id=mindwavemobile)
 2. Download this repository and run MindWave_BlinkGame.pde
 3. Game should connect and start. When connection signal is good (<50) the game will start.
 4. Player will be asked to blink 3 times to start the game, this is to verify the blink detection works.
 5. Get your stare on!
 
 @haiyan
 March, 2013
 *****/



import neurosky.*;
import java.net.*;
ThinkGearSocket neuroSocket;

// game variables
PFont font;
PImage img;
int state=0;
int score=0;
int score_timer;
int total_score;

void setup() {
  // fullscreen
  size(displayWidth, displayHeight);
  ThinkGearSocket neuroSocket = new ThinkGearSocket(this);
  try {
    neuroSocket.start();
  } 
  catch (ConnectException e) {
    //println("Is ThinkGear running??");
  }
  img = loadImage("ugly_cat.jpg");
  smooth();
  font = createFont("Arial", 64);
  textFont(font);
}

void draw() {
  image(img, 0, -50);
  // draw different screen depending on game state
  if (state == 0) {
    // initialisation screen - game will start when connection signal < 50
    fill(255);
    noStroke();
    rect(displayWidth/2-400, displayHeight/2-100, 800, 160);
    fill(0);
    textAlign(CENTER);
    text("Initialising your brain...", displayWidth/2, displayHeight/2);
  }
  else if (state == 1) {
    // countdown screen 1 - asks user to blink
    fill(0);
    noStroke();
    rect(displayWidth/2-400, displayHeight/2-100, 800, 160);
    fill(255);
    textAlign(CENTER);
    text("Blink to continue... 2", displayWidth/2, displayHeight/2);
  }
  else if (state == 2) {
    // countdown screen 2 - asks user to blink
    fill(0);
    noStroke();
    rect(displayWidth/2-400, displayHeight/2-100, 800, 160);
    fill(255);
    textAlign(CENTER);
    text("Blink to continue... 1", displayWidth/2, displayHeight/2);
  }
  else if (state == 3) {
    // countdown sreen 3 - asks user to blink one last time
    fill(0);
    noStroke();
    rect(displayWidth/2-400, displayHeight/2-100, 800, 160);
    fill(255);
    textAlign(CENTER);
    text("Blink to start!", displayWidth/2, displayHeight/2);
    score = 0;
  }
  else if (state == 4) {
    // game play screen, a timer is shown on the left with score
    int passed_time = (millis() - score_timer)/1000;
    fill(0);
    textAlign(LEFT);
    String score_txt = nfc(passed_time) + " secs";
    text(score_txt, 100, displayHeight/2);
  } 
  else if (state == 5) {
    // game over - gives final score
    fill(0);
    textAlign(LEFT);
    String score_txt = nfc(total_score) + " secs";
    text(score_txt, 100, displayHeight/2);
    stroke(255, 0, 0);
    strokeWeight(50);
    strokeCap(SQUARE);
    line(50, 50, displayWidth-50, displayHeight-50);
    line(displayWidth-50, 50, 50, displayHeight-50);
  }
}

void keyPressed() {
  // reset the game when key is pressed
  state = 0;
}

void poorSignalEvent(int sig) {  
  // waits for when connection signal to the headset is good
  if (sig < 50 && state == 0) {
    state = 1;
  }
  println("SignalEvent "+sig);
}

void blinkEvent(int blinkStrength) {
  // when blink happens
  if (blinkStrength > 10) {
    // if in countdown state, move countdown on
    if (state == 1) {
      state = 2;
    } 
    else if (state == 2) {
      state = 3;
    } 
    else if (state == 3) {
      // reset the scoreboard, start the game
      score_timer = millis();
      state = 4;
    } 
    else if (state == 4) {
      // if game is in progress the user has lost
      // calculate final score and end the game (state = 5)
      if ((millis()-score_timer) > 3000) {
        total_score = (millis()-score_timer)/1000;
        state = 5;
      }
    }
  }
  println("blinkStrength: " + blinkStrength);
}

public void eegEvent(int delta, int theta, int low_alpha, int high_alpha, int low_beta, int high_beta, int low_gamma, int mid_gamma) {
}

void rawEvent(int[] raw) {
}	

void stop() {
  // for some reason, calling neuroSocket.stop() sometimes crashes Mac OSX 10.8.2
  //neuroSocket.stop();
  super.stop();
}

