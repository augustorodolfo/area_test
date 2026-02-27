class myInterface {

  // Posizione e dimensioni
  int left, top, larg, alt;

  // Stati del mouse
  boolean mouseHit = false;     // hit test logico
  boolean mouseOver = false;    // hover grafico
  boolean pressed = false;
  boolean released = false;
  // Focus
  boolean focusable = true;
  boolean hasFocus = false;
  // Drag
  boolean draggable = false;
  boolean dragging = false;
  int dragOffsetX, dragOffsetY;

  // Resize
  boolean resizable = false;
  boolean resizing = false;
  int resizeMargin = 10;

  // Grafica base
  boolean enableHover = true;
  boolean enablePressed = true;

  // Interruttore (toggle)
  boolean interruttore = false;
  boolean on = false;

  // Identificatore
  String myTipo = "myInterface";
  String idName="";
  myInterface(int x, int y, int w, int h) {
    left = x;
    top = y;
    larg = w;
    alt = h;
  }

  // ---------------------------------------------------------
  // HIT TEST
  // ---------------------------------------------------------
  boolean inEvent() {
    return mouseX >= left && mouseX <= left + larg &&
      mouseY >= top  && mouseY <= top + alt;
  }

  boolean isOnResizeArea() {
    return mouseX >= left + larg - resizeMargin &&
      mouseY >= top  + alt  - resizeMargin;
  }
  boolean usaSfondoBase() {
    return false;
  }
  XML toXML() {
    XML x = new XML(idName);
    x.setInt("left", left);
    x.setInt("top", top);
    x.setInt("larg", larg);
    x.setInt("alt", alt);
    return x;
  }

  void fromXML(XML x) {
    left = x.getInt("left");
    top  = x.getInt("top");
    larg = x.getInt("larg");
    alt  = x.getInt("alt");
  }

  // ---------------------------------------------------------
  // VISUALIZZA
  // ---------------------------------------------------------
  void visualizza() {

    // Aggiorna stati mouse
    mouseHit = inEvent();
    mouseOver = enableHover && mouseHit;

    // Colore di sfondo
    int fondo = VarDefault.c_fondo;
    if (mouseOver) fondo = VarDefault.c_fondoInEvent;

    fill(fondo);

    // Bordo
    float sw = (pressed && enablePressed) ?
      VarDefault.borderWeightPressed :
      VarDefault.borderWeight;

    strokeWeight(sw);
    stroke(0);

    // Rettangolo base
    rect(left, top, larg, alt);

    // Focus (se attivo)
    if (globalVar.focus == this) {
      stroke(VarDefault.c_focus);
      strokeWeight(2);
      noFill();
      rect(left - 2, top - 2, larg + 4, alt + 4);
    }
  }
  // ---------------------------------------------------------
  // DISEGNA IL TRIANGOLINO DI RESIZE
  // ---------------------------------------------------------
  void drawResizeHandle() {
    if (!resizable) return;

    // colore dinamico
    if (resizing) {
      fill(0, 150, 255);    // blu durante il resize
    } else if (isOnResizeArea()) {
      fill(80);             // hover
    } else {
      fill(120);            // normale
    }

    noStroke();
    triangle(
      left + larg, top + alt - resizeMargin,
      left + larg - resizeMargin, top + alt,
      left + larg, top + alt
      );
  }

  // ---------------------------------------------------------
  // MOUSE PRESSED
  // ---------------------------------------------------------
  void mousePressed() {

    if (mouseHit) {
      pressed = true;

      // Focus
      if (focusable) {
        if (globalVar.focus != null)
          globalVar.focus.hasFocus = false;

        globalVar.focus = this;
        hasFocus = true;
      }

      // Resize
      if (resizable && isOnResizeArea()) {
        resizing = true;
        return;
      }

      // Drag
      if (draggable) {
        dragging = true;
        dragOffsetX = mouseX - left;
        dragOffsetY = mouseY - top;
      }
    }
  }


  // ---------------------------------------------------------
  // MOUSE DRAGGED
  // ---------------------------------------------------------
  void mouseDragged() {

    if (dragging) {
      left = mouseX - dragOffsetX;
      top  = mouseY - dragOffsetY;
    }

    if (resizing) {

      int newW = max(40, mouseX - left);
      int newH = max(40, mouseY - top);

      onResize(newW, newH);   // <--- chiamata corretta

      return;
    }
  }

  // ---------------------------------------------------------
  // MOUSE RELEASED
  // ---------------------------------------------------------
  void mouseReleased() {

    boolean wasPressed = pressed;
    pressed = false;

    dragging = false;
    resizing = false;

    if (wasPressed) {
      released = true;

      if (mouseHit) {
        if (interruttore) {
          on = !on;   // toggle
        } else {
          onClick();
        }
      }
    }
  }
  // ---------------------------------------------------------
  // CALLBACK CLICK
  // ---------------------------------------------------------
  void onClick() {
    // vuoto — i widget lo sovrascrivono
  }
  // ---------------------------------------------------------
  // RIDIMENSIONAMENTO (da chiamare quando l'utente ridimensiona)
  // ---------------------------------------------------------
  void onResize(int newW, int newH) {
    larg = newW;
    alt = newH;
  }
  // ---------------------------------------------------------
  // TASTIERA (vuoti, sovrascrivibili)
  // ---------------------------------------------------------
  void keyPressed(char k, int code) {
  }
  void keyReleased(char k, int code) {
  }

  void mouseMoved() {
    mouseHit = (mouseX >= left && mouseX <= left + larg &&
      mouseY >= top  && mouseY <= top + alt);

    if (mouseHit && draggable) {
      cursor(MOVE);   // cursore di movimento
    } else {
      cursor(ARROW);  // cursore normale
    }
  }

  void mouseWheel(float e) {
  }
}
