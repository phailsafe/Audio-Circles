import ddf.minim.*;
import ddf.minim.ugens.*;

color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
   red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB, grey=#5F5F5F, brown=#AF6407,
   sand=#FCBA69, pink=#FF8EE7 ;
   
Circle[] circles = new Circle[4];
Circle A; Circle B; Circle C; Circle D;
Circle selected;
float startAngle, endAngle;
float distance = 0;// note arc variables
pt startPt, endPt;
boolean playing = false;
boolean animation = false;
int mode;


void setup() {             
   size(800, 600);         
   frameRate(30);
   smooth();  strokeJoin(ROUND); strokeCap(ROUND); 
   frameRate(30);
  
  mode = 1;
   
   A = new Circle(200, 150, 20, 4, 3);
   B = new Circle(600, 150, 20, 4, 3);   
   C = new Circle(200, 450, 20, 4, 3);
   D = new Circle(600, 450, 20, 4, 3);   
   circles[0] = A;
   circles[1] = B;
   circles[2] = C;
   circles[3] = D;
} 
   
void draw() {
   background(255); noFill();


   A.drawCircle();
   B.drawCircle();
   C.drawCircle();
   D.drawCircle();
   
   if (playing) {
      for (Circle c : circles) {
         c.play(); 
      }
   }
   
   if (animation) { //if animating draw a dude and make him dance
      noFill();
      ellipse(width/2, height/2 - 80, 60, 60); // head
      ellipse(width/2 - 15, height/2 - 90, 10, 10);
      ellipse(width/2 + 15, height/2 - 90, 10, 10);
      line(width/2, height/2 - 50, width/2, height/2+30); //torso
      
      for (int i = 0; i < 80 - 1; i++) {
          line(width/2 - i, height/2 - 30 + A.out.left.get(i)*30, width/2 - i - 1, height/2 - 30 + A.out.left.get(i+1)*30);
          line(width/2 + i, height/2 - 30 + B.out.left.get(i)*30, width/2 + i - 1, height/2 - 30 + B.out.left.get(i+1)*30);
          line(width/2 - i/2 + C.out.left.get(i)*20, height/2 + 30 + i + C.out.left.get(i)*30, width/2 - i/2 - 1 + C.out.left.get(i)*20, height/2 + 30 + i + C.out.left.get(i+1)*30);
          line(width/2 + i/2 - D.out.left.get(i)*20, height/2 + 30 + i + D.out.left.get(i)*30, width/2 + i/2 - 1 - D.out.left.get(i)*20, height/2 + 30 + i + D.out.left.get(i+1)*30);
      }
   }
   
}

void keyPressed() {
    if (key == 't') {
       animation = !animation; 
    }
    if (animation) {
      
    }
    
    if (key == 'w') {
      Circle c = closestCircle(mouseX, mouseY);
      c.addTick();
    }
    if (key == 's') {
        Circle c = closestCircle(mouseX, mouseY);
        c.removeTick();
    }
    if (key == 'd') { // increase octave
        Circle c = closestCircle(mouseX, mouseY);
        c.increaseOctave();
    }
    if (key == 'a') { // lower octave
        Circle c = closestCircle(mouseX, mouseY);
        c.decreaseOctave();
    }
    if (key == 'c') {
        Circle c = closestCircle(mouseX, mouseY);
        c.deletePrevNote();
    }
    
    if (key == ' ') {
        if (playing) { // play and stop 
          for (Circle c : circles) {
             c.stop(); 
          }
        }
        playing = !playing;
    }
    if (key == 'p') {
        playing = !playing; 
    }
    
    if (key == 'k') {
       for (int i = 0; i < 50; i++) {
          A.deletePrevNote();
          B.deletePrevNote();
          C.deletePrevNote();
          D.deletePrevNote();
       } 
    }
    if (key == '1') mode = 1; println(mode);
    if (key == '2') mode = 2; println(mode);
    if (key == '3') mode = 3; println(mode);
    if (key == '4') mode = 4; println(mode);
    if (key == '5') mode = 5; println(mode);

}

void mousePressed() {
     
     startPt = Pmouse();
     selected = closestCircle(mouseX, mouseY);
     distance = d(selected.center, P(mouseX, mouseY));
     //println("Distance: " + distance);
     startAngle = angle(P(selected.x + 10, selected.y), selected.center, P(mouseX, mouseY));
     startAngle = positiveAngle(startAngle);
     //println("Start Angle: " + startAngle);    
   
   
}

Circle closestCircle(int x, int y) {
    float min = 9999.9;
    int closest = 0;
    for (int i = 0; i < 4; i++) {
        float distance = d(circles[i].center, P(x, y));
        if (distance < min) { 
          min = distance;
          closest = i;
        }
    }
    //println("Selected circle: " + closest);
    return circles[closest];
}




void mouseReleased() {

      endPt = Pmouse();
      endAngle = angle(P(selected.x + 10, selected.y), selected.center, P(mouseX, mouseY));
      endAngle = positiveAngle(endAngle);
      //println("End Angle: " + endAngle);
      if (startAngle > endAngle) {
        float temp = startAngle;
        startAngle = endAngle;
        endAngle = temp; 
      }
      selected.addNote(startAngle, startPt, endAngle, endPt, distance, mode);
    
    
}


float positiveAngle(float angle) {
    if (angle >= 0) {
      return angle;
    }
    else {
      float newAngle = 2*PI + angle;
      return newAngle;
    }
}

