class vScrollBar extends myInterface {

  float min = 0;
  float max = 100;
  float val = 0;

  float thumbY = 0;
  float thumbH = 40;

  boolean dragging = false;
  float dragOffset;
  int colTrack;
  int colThumb;
  int colThumbHover;
  int colThumbDrag;

  // stile moderno


  vScrollBar(int x, int y, int w, int h) {
    super(x, y, w, h);
    myTipo = "vScrollBar";
    colTrack = VarDefault.c_Track;
    colThumb = VarDefault.c_Thumb;
    colThumbHover = VarDefault.c_ThumbHover;
    colThumbDrag = VarDefault.c_ThumbDrag;
  }

  // ----------------------------------------------------------
  // SETTAGGI
  // ----------------------------------------------------------
  void setRange(float mn, float mx) {
    min = mn;
    max = mx;
    val = constrain(val, min, max);
    updateThumb();
  }

  void setValue(float v) {
    val = constrain(v, min, max);
    updateThumb();
  }

  void setThumbHeight(int h) {
    thumbH = h;
    updateThumb();
  }
  void setAltPercCurs(float perc) {
    // perc = percentuale (0..100)
    perc = constrain(perc, 0, 100);

    float frac = perc / 100.0;

    // altezza del thumb = percentuale dell'altezza della scrollbar
    thumbH = max(10, alt * frac);

    // aggiorna posizione in base al valore corrente
    updateThumb();
  }
  // ----------------------------------------------------------
  // CALCOLO POSIZIONE THUMB
  // ----------------------------------------------------------
  void updateThumb() {
    float range = max - min;
    if (range <= 0) {
      thumbY = top;
      return;
    }
    float trackH = alt - thumbH;
    thumbY = top + (val - min) / range * trackH;
  }

  // ----------------------------------------------------------
  // DISEGNO
  // ----------------------------------------------------------
  @Override
    void visualizza() {
    super.visualizza();  // aggiorna mouseIn, inEvent(), focus, ecc.

    // track
    noStroke();
    fill(colTrack);
    rect(left, top, larg, alt, 4);

    // hover detection
    boolean hoverThumb = (mouseX >= left && mouseX <= left + larg &&
      mouseY >= thumbY && mouseY <= thumbY + thumbH);

    // colore thumb
    int c = colThumb;
    if (dragging) c = colThumbDrag;
    else if (hoverThumb) c = colThumbHover;

    fill(c);
    rect(left, thumbY, larg, thumbH, 4);
  }
  boolean contains(int mx, int my) {
    return mx >= left && mx <= left + larg &&
      my >= top  && my <= top + alt;
  }

  // ----------------------------------------------------------
  // EVENTI
  // ----------------------------------------------------------
  @Override
    void mousePressed() {
    super.mousePressed();

    boolean hoverThumb = (mouseX >= left && mouseX <= left + larg &&
      mouseY >= thumbY && mouseY <= thumbY + thumbH);

    if (hoverThumb) {
      dragging = true;
      dragOffset = mouseY - thumbY;
    }
  }

  @Override
    void mouseDragged() {
    super.mouseDragged();

    if (dragging) {
      float newY = mouseY - dragOffset;

      // limiti
      newY = constrain(newY, top, top + alt - thumbH);

      thumbY = newY;

      // aggiorna valore
      float trackH = alt - thumbH;
      float t = (thumbY - top) / trackH;
      val = min + t * (max - min);
    }
  }

  @Override
    void mouseReleased() {
    dragging = false;
    super.mouseReleased();
  }

  // ----------------------------------------------------------
  // MOUSE WHEEL (firma corretta per myInterface)
  // ----------------------------------------------------------
  void mouseWheel(float delta) {
    if (!inEvent()) return;
    setValue(val + delta * 20);
  }
  void scrollByWheel(float delta) {
    setValue(val + delta );
  }
}
