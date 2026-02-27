abstract class myTextBase extends myInterface {

  // --- CURSORE ---
  int cursorPos = 0;
  boolean cursorVisible = true;
  int lastBlink = 0;

  // --- SELEZIONE ---
  int selStart = -1;
  int selEnd   = -1;
  boolean selecting = false;

  // --- CLICK MULTIPLI ---
  int lastClickTime = 0;
  int clickCount = 0;

  myTextBase(int x, int y, int w, int h) {
    super(x, y, w, h);
    focusable = true;
  }

  // ---------------------------------------------------------
  // METODI ASTRATTI (da implementare nelle sottoclassi)
  // ---------------------------------------------------------
  abstract String getText();
  abstract void setText(String s);
  abstract int getTextLength();
  abstract float getTextWidthUpTo(int pos);
  abstract void drawText(float baseX, float baseY);
  abstract void drawSelectionRect(float x1, float x2, float y, float h);
  abstract int findCursorPosition(float px);

  // ---------------------------------------------------------
  // visualizza lo sfondo
  // ---------------------------------------------------------
  @Override
    void visualizza() {
    super.visualizza(); // <--- IMPORTANTE: aggiorna mouseHit, hover, focus
    // --- SFONDO DINAMICO ---
    if (globalVar.focus == this) {
      fill(VarDefault.c_bgFocus);
      stroke(VarDefault.c_borderFocus);
    } else if (inEvent()) {
      fill(VarDefault.c_bgHover);
      stroke(VarDefault.c_border);
    } else {
      fill(VarDefault.c_bgNormal);
      stroke(VarDefault.c_border);
    }
    strokeWeight(VarDefault.borderWeight);
    rect(left, top, larg, alt);
  }
  // ---------------------------------------------------------
  // SELEZIONE
  // ---------------------------------------------------------
  boolean hasSelection() {
    return selStart != -1 && selEnd != -1 && selStart != selEnd;
  }

  void clearSelection() {
    selStart = selEnd = -1;
  }

  void clampSelection() {
    cursorPos = constrain(cursorPos, 0, getTextLength());
    if (selStart != -1) selStart = constrain(selStart, 0, getTextLength());
    if (selEnd   != -1) selEnd   = constrain(selEnd, 0, getTextLength());
  }

  void deleteSelection() {
    if (!hasSelection()) return;
    int a = min(selStart, selEnd);
    int b = max(selStart, selEnd);
    String t = getText();
    setText(t.substring(0, a) + t.substring(b));
    cursorPos = a;
    clearSelection();
    clampSelection();
  }
  @Override
    boolean usaSfondoBase() {
    return false;
  }

  // ---------------------------------------------------------
  // MOUSE
  // ---------------------------------------------------------
  @Override
    void mousePressed() {
    super.mousePressed();
    if (!mouseHit) return;

    globalVar.focus = this;

    int now = millis();
    clickCount = (now - lastClickTime < 300) ? clickCount + 1 : 1;
    lastClickTime = now;

    float px = mouseX - (left + VarDefault.margin);
    cursorPos = findCursorPosition(px);
    clampSelection();

    if (clickCount == 2) {
      selectWordAt(cursorPos);
      return;
    }
    if (clickCount == 3) {
      selStart = 0;
      selEnd = getTextLength();
      return;
    }

    selecting = true;
    selStart = cursorPos;
    selEnd = cursorPos;

    cursorVisible = true;
    lastBlink = millis();
  }

  @Override
    void mouseDragged() {
    super.mouseDragged();
    if (!selecting) return;

    float px = mouseX - (left + VarDefault.margin);
    selEnd = findCursorPosition(px);
    cursorPos = selEnd;
    clampSelection();

    cursorVisible = true;
    lastBlink = millis();
  }

  @Override
    void mouseReleased() {
    super.mouseReleased();
    selecting = false;
    cursorPos = selEnd;
    clampSelection();
  }

  // ---------------------------------------------------------
  // TASTIERA (comune)
  // ---------------------------------------------------------
  @Override
    void keyPressed(char k, int code) {
    if (globalVar.focus != this) return;

    boolean ctrl = keyEvent.isControlDown() || keyEvent.isMetaDown();
    int ascii = (int) k;

    // --- COPY ---
    if (ctrl && (ascii == 3 || code == 67)) {
      if (hasSelection()) {
        int a = min(selStart, selEnd);
        int b = max(selStart, selEnd);
        ui.copyToClipboard(getText().substring(a, b));
      }
      return;
    }

    // --- PASTE ---
    if (ctrl && (ascii == 22 || code == 86)) {
      String clip = ui.pasteFromClipboard();
      if (clip != null) {
        deleteSelection();
        String t = getText();
        setText(t.substring(0, cursorPos) + clip + t.substring(cursorPos));
        cursorPos += clip.length();
        clampSelection();
      }
      return;
    }

    // --- BACKSPACE ---
    if (k == BACKSPACE) {
      if (hasSelection()) deleteSelection();
      else if (cursorPos > 0) {
        String t = getText();
        setText(t.substring(0, cursorPos - 1) + t.substring(cursorPos));
        cursorPos--;
        clampSelection();
      }
      return;
    }

    // --- DELETE ---
    if (k == DELETE) {
      if (hasSelection()) deleteSelection();
      else if (cursorPos < getTextLength()) {
        String t = getText();
        setText(t.substring(0, cursorPos) + t.substring(cursorPos + 1));
      }
      return;
    }

    // --- FRECCE ---
    if (k == CODED) {
      if (code == CONTROL || code == SHIFT || code == ALT) return;

      if (keyEvent.isShiftDown()) {
        if (!hasSelection()) selStart = cursorPos;

        if (code == LEFT && cursorPos > 0) cursorPos--;
        if (code == RIGHT && cursorPos < getTextLength()) cursorPos++;

        selEnd = cursorPos;
        clampSelection();
      } else {
        clearSelection();
        if (code == LEFT && cursorPos > 0) cursorPos--;
        if (code == RIGHT && cursorPos < getTextLength()) cursorPos++;
      }
      return;
    }

    // --- CARATTERI NORMALI ---
    if (k >= 32 && k <= 126) {
      deleteSelection();
      String t = getText();
      setText(t.substring(0, cursorPos) + k + t.substring(cursorPos));
      cursorPos++;
      clampSelection();
    }
  }

  // ---------------------------------------------------------
  // SELEZIONE PAROLA
  // ---------------------------------------------------------
  void selectWordAt(int pos) {
    String t = getText();
    if (t.length() == 0) return;

    int a = pos;
    int b = pos;

    while (a > 0 && t.charAt(a - 1) != ' ') a--;
    while (b < t.length() && t.charAt(b) != ' ') b++;

    selStart = a;
    selEnd = b;
  }
}
