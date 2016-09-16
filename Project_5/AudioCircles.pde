class Circle {
  int x; int y; int radius; int period;
  pt center, play, playStatic;
  int octave;
  float[] baseFreq = new float[] {27.5, 55, 110, 220, 440, 880, 1760, 3520};
  Note[] notes;
  int n, t, tick;
  float angle;
  pt[] ticks;
  float volume = 0.1;
  Minim minim;
  AudioOutput out;
  //AudioRecorder recorder;
  Oscil wave;
  
  public Circle(int x, int y, int r, int p, int o) {
      this.x = x; this.y = y; radius = r; period = p; octave = o;
      n = 0;
      t = 0;
      center = new pt(x, y);
      play = new pt(x+150, y);
      playStatic = play;
      notes = new Note[50];
      minim = new Minim(this); // Declares minim which we use for sounds
      out = minim.getLineOut();
      angle = 0;
      tick = period;
      ticks = new pt[10];
      for (int i = 0; i < tick; i++) {
         ticks[i] = P(center, R(V(center, playStatic), 2*PI/tick*i));
      }
  }
  
  public void drawCircle() {
      noFill();
      ellipse(x, y, 300, 300);
      fill(0, 100, 255);
      drawNotes();
      stroke(0);
      drawTicks();
      stroke(255,0,0);
      edge(center, play);
      stroke(0);
      fill(255, 255, 0);
      ellipse(x, y, 2*radius, 2*radius);
      fill(0);
      label(center, V(-10, -10), "P: " + str(period) + "\nO: " + str(octave+1));
      
  }
  
  void drawTicks() {
      for (pt p : ticks) {
          if (p != null) {
             edge(center, p);
             for (int i = 1; i < 12; i++) {
                pt tone = P(p, i/14.0, V(p, center));
                fill(0);
                tone.show(2);
             }
          }  
      }
  }
  
  public void addTick() {
      if (tick != 10) { 
          tick++;
          for (int i = 0; i < tick; i++) {
             ticks[i] = P(center, R(V(center, playStatic), 2*PI/tick*i));
          }
          period++;
      }
  }
  
  public void removeTick() {
      if (tick > 1) { 
          tick--;
          ticks[tick] = null;
          for (int i = 0; i < tick; i++) {
             ticks[i] = P(center, R(V(center, playStatic), 2*PI/tick*i));
          }
          period--;
      }
  }
  
  public void play() {
     play = P(center, R(V(center, playStatic), angle));
     for (Note n : notes) {
         if (n != null) {
           float playAngle = positiveAngle(angle(playStatic, center, play));
           /*if (playAngle >= n.startAngle && playAngle < n.endAngle) {
               n.wave.setAmplitude(volume);
               
           }
           else {
               n.wave.setAmplitude(0);
           }*/
           if (playAngle >= n.startAngle && playAngle < n.endAngle) {
               //n.wave.setAmplitude(volume);
               n.wave.setAmplitude(0);
               if (!n.played) {
                 out.playNote(0.0, n.duration * period / 2, n.freq);
                 n.played = true;
               }
           }
           else if (playAngle > n.endAngle || playAngle < n.startAngle) {
               n.wave.setAmplitude(0);
               n.played = false;
           }           
         }
     }
     angle+= 2.0*(2.0*PI/30.0)/(period * 1.0);
     if(angle >= 2*PI) angle -= 2*PI;
  }
  
  public void stop() {
      play = playStatic;
      t = 0;
      angle = 0;
      for (Note n : notes) {
         if (n != null) {
            n.wave.setAmplitude(0);
         } 
      }
  }
  
  public void deletePrevNote() {
      if (n > 0) {
         n--;
         notes[n].wave.setAmplitude(0);
         notes[n] = null; 
      }
  }
  
  public void increaseOctave() {
     if (octave != 7) octave++;
     for (Note n : notes) {
        if (n != null) {
           n.setFreq(baseFreq[octave], mode);
       }
     }
     
  }
  public void decreaseOctave() {
     if (octave != 0) octave--;
     for (Note n : notes) {
       if (n != null) {
           n.setFreq(baseFreq[octave], mode);
       }
     }     
  }
  
  void drawNotes() {
      for (Note n : notes) {
         if (n != null) {
           //noFill();
           /*
           pt A = n.startPt;
           pt B;
           float rotate = angle(n.startPt, center, n.endPt);
           //println(rotate);
           //pt B = R(A, rotate, center);
           //edge(A, B);
           for (float t = 0.01; t <= 1; t+= 0.01) {
               //println(t);
               B = R(A, rotate*t, center);
               edge(A, B);
               A = B;
           }*/
           //fill((n.endAngle - n.startAngle) * 100, n.distance, (n.endAngle - n.startAngle) * 100);
           arc(x, y, 2*n.distance, 2*n.distance, n.startAngle, n.endAngle);
           line( x, y, x + n.distance * cos(n.startAngle), y + n.distance * sin(n.startAngle) ); 
           line( x, y, x + n.distance * cos(n.endAngle), y + n.distance * sin(n.endAngle) ); 
           //stroke(0);
           //edge(n.startPt, center);
           //edge(R(n.startPt, n.endAngle - n.startAngle, center), center);           
         }

      }
  }
  
  public void addNote(float s, pt start, float e, pt end, float d, int mode) {
      Note newNote = new Note(s, start, e, end, d);
      newNote.setFreq(baseFreq[octave], mode);
      notes[n] = newNote;
      n++;
  }
 
  
}

class Note {
   float startAngle, endAngle, distance, freq, duration;
   pt startPt, endPt;
   Oscil wave;
   Line ampEnv;
   boolean played;
   
   Note(float s, pt start, float e, pt end, float d) {
     startAngle = s;
     startPt = start;
     endAngle = e;
     endPt = end;
     distance = d;
     freq = 0;
     duration = ((endAngle - startAngle)/(2*PI));
     played = false;
   }
   
   public void setFreq(float baseFreq, int mode) {
      freq = baseFreq*pow(2., ((distance - 30)/10)/12);
      //println("Frequency: " + freq);
      wave = new Oscil(freq, 0, Waves.SINE);
      wave.setFrequency(freq);
      switch (mode) {
        case '1': 
          wave.setWaveform( Waves.SINE );
          break;
         
        case '2':
          wave.setWaveform( Waves.TRIANGLE );
          break;
         
        case '3':
          wave.setWaveform( Waves.SAW );
          break;
        
        case '4':
          wave.setWaveform( Waves.SQUARE );
          break;
          
        case '5':
          wave.setWaveform( Waves.QUARTERPULSE );
          break;
         
        default: break; 
        
      }
      
      //wave.patch(out);
   }
     
}

