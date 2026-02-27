GlobalVar globalVar;
VarDefault VarDefault;
myManager ui;
boolean toggleDrag=false;
vScrollBar sb;

void setup() {
 size(9000, 1000);
  VarDefault = new VarDefault();   // OBBLIGATORIO
  globalVar = new GlobalVar();     // OBBLIGATORIO
  ui = new myManager();
  // --- PANNELLO ---
  myPannel p = new myPannel(50, 50, 400, 200);
  ui.aggiungi(p, "pannello");
  // --- BOTTONI ---
  myButton b1 = new myButton("Muovi", 80, 80);
  myButton b2 = new myButton("Annulla", 200, 80);
  ui.aggiungi(b1, "Muovi");
  ui.aggiungi(b2, "Annulla");
  b1=new myButton("Resize", 300, 80);
  b1.interruttore=true;
  ui.aggiungi(b1, "Resize");
  ui.aggiungi(new myText(200, 150, 300, 40), "T");
  ui.aggiungi(new myText(200, 200, 300, 40), "T1");
  ui.aggiungi(new myText(200, 250, 300, 40), "T2");
  ui.aggiungi(new myTextArea(200, 350, 300, 250), "TA");

}

void draw() { 
  background(240);
  ui.drawAll();
}

void mousePressed() {
  ui.mousePressedAll();
  
  if (ui.getById("Muovi").pressed) {
    toggleDrag = !toggleDrag;   // inverti ON/OFF

    // Applica il nuovo stato a tutti i widget che iniziano con "T"
    for (myInterface o : ui.elementi) {
      o.draggable = toggleDrag;
    }
  }
  if (ui.getById("Annulla").pressed) {
    println("Hai premuto Annulla");
  }
}
void mouseReleased() {
  ui.mouseReleasedAll();
  myInterface r = ui.getById("Resize");
  if (r.released) {
    ui.setResizableAll(r.on);
  }
}


void mouseDragged() {
  ui.mouseDraggedAll();
}

void mouseMoved() {
  ui.mouseMovedAll();
}

void mouseWheel(MouseEvent e) {
  ui.mouseWheelAll(e.getCount());
}

void keyPressed() {
  ui.keyPressedAll(key, keyCode);
}

void keyReleased() {
  ui.keyReleasedAll(key, keyCode);
}
