class WrappedLine {
  int rigaOriginale; // indice della riga in righe
  int start;         // indice di inizio nel testo della riga
  int end;           // indice di fine nel testo della riga (escluso)

  WrappedLine(int rigaOriginale, int start, int end) {
    this.rigaOriginale = rigaOriginale;
    this.start = start;
    this.end = end;
  }
}
class myTextArea extends myTextBase {
  boolean draggingSelection = false;

  int scrollOffset = 0;
  int maxScroll = 0;
  int padding_sx = 4;
  int padding_dx = 4;

  ArrayList<String> righe = new ArrayList<String>();
  ArrayList<WrappedLine> wrappedLines = new ArrayList<WrappedLine>();

  boolean wrapByWord = true;
  int lineHeight;

  vScrollBar sb;   // <-- SCROLLBAR MODERNA

  myTextArea(int x, int y, int w, int h) {
    super(x, y, w, h);
    draggable = false;
    resizable = true;

    righe.add("");

    textSize(VarDefault.fontSize);
    lineHeight = (int)(textAscent() + textDescent() + 4);

    // ---------------------------------------------------------
    // CREA LA SCROLLBAR
    // ---------------------------------------------------------
    sb = new vScrollBar(x + w - 12, y, 12, h);
    sb.setRange(0, 0);
    sb.setValue(0);
    sb.setAltPercCurs(100);
  }
  void handleTextMousePressed() {

    // Calcola posizione globale del click nel testo
    int pos = mouseToTextIndex(mouseX, mouseY);

    cursorPos = pos;
    selStart = pos;
    selEnd = pos;

    draggingSelection = true;
  }
  void handleTextMouseDragged() {

    if (!draggingSelection) return;

    int pos = mouseToTextIndex(mouseX, mouseY);
    selEnd = pos;
  }
  void handleTextMouseReleased() {
    draggingSelection = false;
  }

  //----------------
  int mouseToTextIndex(int mx, int my) {

    if (mx < left || mx > left + larg ||
      my < top  || my > top + alt) {
      return cursorPos;
    }

    float y = my - (top + padding_sx) + scrollOffset;

    int row = floor(y / lineHeight);
    row = constrain(row, 0, wrappedLines.size() - 1);

    WrappedLine wl = wrappedLines.get(row);

    String r = righe.get(wl.rigaOriginale);
    int start = wl.start;
    int end   = wl.end;

    float x = mx - (left + padding_sx);

    int col = start;
    float best = 999999;

    for (int i = start; i <= end; i++) {
      float tw = textWidth(r.substring(start, i));
      float diff = abs(tw - x);
      if (diff < best) {
        best = diff;
        col = i;
      }
    }

    // FIX FONDAMENTALE
    return rowColToGlobalPos(wl.rigaOriginale, col);
  }



  // ---------------------------------------------------------
  // METODI DI myTextBase
  // ---------------------------------------------------------
  @Override
    void keyPressed(char k, int code) {
    if (globalVar.focus != this) return;

    if (k == ENTER || k == RETURN) {
      deleteSelection();

      int[] rc = globalPosToRowCol(cursorPos);
      int r = rc[0];
      int c = rc[1];

      String line = righe.get(r);

      String left  = line.substring(0, c);
      String right = line.substring(c);

      righe.set(r, left);
      righe.add(r + 1, right);

      cursorPos = rowColToGlobalPos(r + 1, 0);

      rewrap();
      return;
    }

    super.keyPressed(k, code);
  }
  @Override
    void mousePressed() {

    super.mousePressed(); // mantiene focus, ecc.
    if (draggable || resizable) return;
  }
  @Override
    void mouseDragged() {

    super.mouseDragged();

    // Se sto trascinando la scrollbar
    if (sb.dragging) {
      sb.mouseDragged();
      scrollOffset = (int) sb.val;
      return;
    }

    // Altrimenti trascino la selezione del testo
    handleTextMouseDragged();
  }
  @Override
    void mouseReleased() {

    super.mouseReleased();
    if (draggable || resizable) return;

    sb.mouseReleased();  // rilascia eventuale drag

    handleTextMouseReleased();
  }
  @Override
    void mouseWheel(float delta) {

    // Se il mouse è sopra la textarea
    if (mouseX >= left && mouseX <= left + larg &&
      mouseY >= top  && mouseY <= top + alt) {
      float wheelStep = lineHeight ;
      sb.scrollByWheel(wheelStep*delta);  // aggiorna la scrollbar
      scrollOffset = constrain((int) sb.val, 0, maxScroll);
    }
  }

  @Override
    String getText() {
    return String.join("\n", righe);
  }

  @Override
    void setText(String s) {
    righe.clear();
    String[] parts = s.split("\n", -1);
    for (String p : parts) righe.add(p);
    rewrap();
  }

  @Override
    int getTextLength() {
    int len = 0;
    for (int i = 0; i < righe.size(); i++) {
      len += righe.get(i).length();
      if (i < righe.size() - 1) len++;
    }
    return len;
  }

  @Override
    float getTextWidthUpTo(int pos) {
    int[] rc = globalPosToRowCol(pos);
    int r = rc[0];
    int c = rc[1];
    if (r < 0 || r >= righe.size()) return 0;
    c = constrain(c, 0, righe.get(r).length());
    return textWidth(righe.get(r).substring(0, c));
  }

  @Override
    int findCursorPosition(float px) {
    int visualRow = (int)((mouseY - (top + 4) + scrollOffset) / lineHeight);
    if (visualRow < 0) return 0;
    if (visualRow >= wrappedLines.size()) return getTextLength();

    WrappedLine wl = wrappedLines.get(visualRow);
    String r = righe.get(wl.rigaOriginale);

    float acc = 0;
    for (int i = wl.start; i < wl.end; i++) {
      float w = textWidth(r.charAt(i));
      if (acc + w * 0.5 > px)
        return rowColToGlobalPos(wl.rigaOriginale, i);
      acc += w;
    }
    return rowColToGlobalPos(wl.rigaOriginale, wl.end);
  }

  @Override
    void drawText(float baseX, float baseY) {
    fill(VarDefault.c_text);

    float yoff = top + padding_sx - scrollOffset;

    // Larghezza utile per il testo (senza scrollbar)
    float availableWidth = larg - sb.larg - padding_dx - padding_sx;

    for (int i = 0; i < wrappedLines.size(); i++) {
      WrappedLine wl = wrappedLines.get(i);
      String r = righe.get(wl.rigaOriginale);
      String sub = r.substring(wl.start, wl.end);

      float y = yoff + i * lineHeight;

      // Disegna il testo limitato alla larghezza utile
      text(sub, baseX, y, availableWidth, lineHeight);
    }
  }

  @Override
    void drawSelectionRect(float x1, float x2, float y, float h) {
    fill(VarDefault.c_selection);
    noStroke();
    rect(x1, y, x2 - x1, h);
  }

  @Override
    void onResize(int newW, int newH) {
    super.onResize(newW, newH);

    // aggiorna scrollbar
    sb.left = left + newW - sb.larg;
    sb.top  = top;
    sb.alt  = newH;

    rewrap();
  }

  // ---------------------------------------------------------
  // VISUALIZZA
  // ---------------------------------------------------------

  @Override
    void visualizza() {

    super.visualizza();  // aggiorna mouseIn, focus, ecc.

    // --- PRIMA COSA: aggiornare la scrollbar (geometria) ---
    sb.left = left + larg - sb.larg;
    sb.top  = top;
    sb.alt  = alt;

    // --- SINCRONIZZA SCROLL OFFSET CON LA SCROLLBAR ---
    scrollOffset = (int) sb.val;
    scrollOffset = constrain(scrollOffset, 0, maxScroll);

    textSize(VarDefault.fontSize);
    textAlign(LEFT, TOP);

    float baseX = left + padding_sx;
    float yoff  = top  + padding_sx - scrollOffset;

    // --- CLIP: limita il disegno al riquadro della textarea (senza scrollbar) ---
    clip(left, top, larg - sb.larg, alt);

    // --- SELEZIONE ---
    if (hasSelection()) {
      int a = min(selStart, selEnd);
      int b = max(selStart, selEnd);

      int[] rcA = globalPosToRowCol(a);
      int[] rcB = globalPosToRowCol(b);

      for (int i = 0; i < wrappedLines.size(); i++) {
        WrappedLine wl = wrappedLines.get(i);

        if (wl.rigaOriginale < rcA[0] || wl.rigaOriginale > rcB[0]) continue;

        int sx = wl.start;
        int ex = wl.end;

        if (wl.rigaOriginale == rcA[0]) sx = max(sx, rcA[1]);
        if (wl.rigaOriginale == rcB[0]) ex = min(ex, rcB[1]);

        if (ex <= sx) continue;

        String r = righe.get(wl.rigaOriginale);

        float x1 = baseX + textWidth(r.substring(wl.start, sx));
        float x2 = baseX + textWidth(r.substring(wl.start, ex));
        float yy = yoff + i * lineHeight;

        drawSelectionRect(x1, x2, yy, lineHeight);
      }
    }

    // --- TESTO ---
    drawText(baseX, yoff);

    // --- CURSORE ---
    if (globalVar.focus == this && !hasSelection()) {

      int safePos = constrain(cursorPos, 0, getTextLength());
      cursorPos = safePos;

      float cx = baseX;
      float cy = yoff;

      if (!wrappedLines.isEmpty()) {

        int[] rc = globalPosToRowCol(safePos);
        int r = rc[0];
        int c = rc[1];

        int visualRow = findWrappedVisualRow(r, c);
        visualRow = constrain(visualRow, 0, wrappedLines.size() - 1);

        WrappedLine wl = wrappedLines.get(visualRow);

        String full = righe.get(wl.rigaOriginale);
        String sub  = full.substring(wl.start, c);

        cx = baseX + textWidth(sub);
        cy = yoff + visualRow * lineHeight;
      }

      if (millis() - lastBlink > 500) {
        cursorVisible = !cursorVisible;
        lastBlink = millis();
      }

      if (cursorVisible) {
        stroke(0);
        line(cx, cy, cx, cy + lineHeight);
      }
    }

    // fine clip del testo
    noClip();

    // --- SCROLLBAR (fuori dal clip, così non viene tagliata) ---
    sb.visualizza();

    // --- HANDLE DI RESIZE ---
    drawResizeHandle();
  }


  // ---------------------------------------------------------
  // REWRAP + SCROLLBAR UPDATE
  // ---------------------------------------------------------
  void rewrap() {

    wrappedLines.clear();
    float maxWidth = larg - padding_sx - padding_dx - sb.larg;

    if (maxWidth < 4) {
      wrappedLines.add(new WrappedLine(0, 0, 0));
      return;
    }

    if (righe.isEmpty()) righe.add("");

    // --- WRAPPING ---
    for (int r = 0; r < righe.size(); r++) {
      String s = righe.get(r);

      if (s.length() == 0) {
        wrappedLines.add(new WrappedLine(r, 0, 0));
        continue;
      }

      if (wrapByWord) {

        int lineStart = 0;
        int cursor = 0;

        while (cursor < s.length()) {

          // --- 1. Trova il prossimo token (spazio o parola) ---
          int tokenStart = cursor;

          // spazi
          if (s.charAt(cursor) == ' ') {
            while (cursor < s.length() && s.charAt(cursor) == ' ') {
              cursor++;
            }
          }
          // parola
          else {
            while (cursor < s.length() && s.charAt(cursor) != ' ') {
              cursor++;
            }
          }

          int tokenEnd = cursor;
          String token = s.substring(tokenStart, tokenEnd);
          float tokenWidth = textWidth(token);

          // --- 2. Larghezza della riga corrente ---
          float currentWidth = textWidth(s.substring(lineStart, tokenStart));

          // --- 3. Se il token non entra, chiudi la riga ---
          if (currentWidth + tokenWidth > maxWidth && tokenStart > lineStart) {
            wrappedLines.add(new WrappedLine(r, lineStart, tokenStart));
            lineStart = tokenStart;
          }
        }

        // --- 4. Aggiungi l'ultima riga ---
        wrappedLines.add(new WrappedLine(r, lineStart, s.length()));
        continue;
      }

      // CHARACTER WRAP
      int start = 0;
      while (start < s.length()) {
        int end = start;
        float w = 0;

        while (end < s.length()) {
          float cw = textWidth(s.charAt(end));
          if (w + cw > maxWidth) break;
          w += cw;
          end++;
        }

        wrappedLines.add(new WrappedLine(r, start, end));
        start = end;
      }
    }

    // ---------------------------------------------------------
    // AGGIORNA SCROLLBAR (PUNTO CORRETTO)
    // ---------------------------------------------------------
    maxScroll = max(0, wrappedLines.size() * lineHeight - (alt - 8));
    scrollOffset = constrain(scrollOffset, 0, maxScroll);

    float H_vis = alt - 8;
    float H_tot = wrappedLines.size() * lineHeight;
    float perc = (H_tot > 0) ? (H_vis / H_tot * 100.0) : 100;

    sb.setRange(0, maxScroll);
    sb.setAltPercCurs(perc);
    sb.setValue(scrollOffset);
  }

  // ---------------------------------------------------------
  // SUPPORTO MULTILINEA
  // ---------------------------------------------------------
  int[] globalPosToRowCol(int pos) {
    int p = pos;
    for (int r = 0; r < righe.size(); r++) {
      int len = righe.get(r).length();
      if (p <= len) return new int[]{r, p};
      p -= (len + 1);
    }
    return new int[]{righe.size() - 1, righe.get(righe.size() - 1).length()};
  }

  int rowColToGlobalPos(int r, int c) {
    int pos = 0;
    for (int i = 0; i < r; i++) pos += righe.get(i).length() + 1;
    return pos + c;
  }

  int findWrappedVisualRow(int r, int c) {
    for (int i = 0; i < wrappedLines.size(); i++) {
      WrappedLine wl = wrappedLines.get(i);
      if (wl.rigaOriginale == r && c >= wl.start && c <= wl.end)
        return i;
    }
    return 0;
  }
}
