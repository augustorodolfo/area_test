import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.DataFlavor;
class myText extends myTextBase {

  String text = "";
  String placeholder = "scrivi qui...";

  myText(int x, int y, int w, int h) {
    super(x, y, w, h);
    draggable = false;
    resizable = true;
  }

  // ---------------------------------------------------------
  // IMPLEMENTAZIONE METODI ASTRATTI DI myTextBase
  // ---------------------------------------------------------

  @Override
  String getText() {
    return text;
  }

  @Override
  void setText(String s) {
    text = s;
  }

  @Override
  int getTextLength() {
    return text.length();
  }

  @Override
  float getTextWidthUpTo(int pos) {
    pos = constrain(pos, 0, text.length());
    return textWidth(text.substring(0, pos));
  }

  @Override
  int findCursorPosition(float px) {
    float acc = 0;
    for (int i = 0; i < text.length(); i++) {
      float w = textWidth(text.charAt(i));
      if (acc + w * 0.5 > px) return i;
      acc += w;
    }
    return text.length();
  }

  @Override
  void drawText(float baseX, float baseY) {
    if (text.length() == 0 && globalVar.focus != this) {
      fill(VarDefault.c_fondoText);
      text(placeholder, baseX, baseY);
    } else {
      fill(VarDefault.c_text);
      text(text, baseX, baseY);
    }
  }

  @Override
  void drawSelectionRect(float x1, float x2, float y, float h) {
    fill(VarDefault.c_selection);
    noStroke();
    rect(x1, y, x2 - x1, h);
  }

  // ---------------------------------------------------------
  // VISUALIZZA (solo rendering, logica già in myTextBase)
  // ---------------------------------------------------------
  @Override
  void visualizza() {

    super.visualizza();

    textSize(VarDefault.fontSize);
    textAlign(LEFT, TOP);

    float baseX = left + VarDefault.margin;
    float baseY = top + (alt - textAscent() - textDescent())/2;

    // --- SELEZIONE ---
    if (hasSelection()) {
      int a = min(selStart, selEnd);
      int b = max(selStart, selEnd);

      float x1 = baseX + getTextWidthUpTo(a);
      float x2 = baseX + getTextWidthUpTo(b);

      drawSelectionRect(x1, x2, baseY, textAscent() + textDescent());
    }

    // --- TESTO ---
    drawText(baseX, baseY);

    // --- CURSORE ---
    int safePos = constrain(cursorPos, 0, text.length());
    cursorPos = safePos;

    float cursorX = baseX + getTextWidthUpTo(safePos);

    if (globalVar.focus == this && !hasSelection()) {
      if (millis() - lastBlink > 500) {
        cursorVisible = !cursorVisible;
        lastBlink = millis();
      }
      if (cursorVisible) {
        stroke(0);
        line(cursorX, baseY, cursorX, baseY + textAscent() + textDescent());
      }
    }

    drawResizeHandle();
  }
}
