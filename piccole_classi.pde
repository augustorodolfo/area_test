class GlobalVar {
  int tipoCursor = ARROW;
  int mouseContol = -1;
  boolean released = false;
  myInterface focus = null;
}
class VarDefault {

  // ---------------------------------------------------------
  // COLORI DI SFONDO GENERALI
  // ---------------------------------------------------------
  color c_bground       = color(230, 230, 255);   // sfondo generale dell'app
  color c_fondo         = color(220, 230, 255);   // sfondo widget base
  color c_fondoInEvent  = color(255, 240, 255);   // hover generico

  // ---------------------------------------------------------
  // COLORI DEI BOTTONI
  // ---------------------------------------------------------
  color c_button          = color(180, 200, 220);   // bottone normale
  color c_buttonInEvent   = color(200, 220, 240);   // bottone hover
  color c_buttonPressed   = color(160, 180, 200);   // bottone premuto
  color c_buttonOn        = color(255, 50, 120);    // bottone toggle ON
  color c_buttonOnInEvent = color(255, 0, 160);     // bottone toggle ON hover

  // ---------------------------------------------------------
  // COLORI DEL TESTO
  // ---------------------------------------------------------
  color c_text      = color(0);      // nero
  color c_fondoText = color(150);    // placeholder grigio

  // ---------------------------------------------------------
  // COLORI SPECIALI (SELEZIONE, FOCUS)
  // ---------------------------------------------------------
  color c_selection    = color(0, 120, 255, 80);   // evidenziazione testo
  color c_focus        = color(0, 120, 255);       // bordo focus

  // ---------------------------------------------------------
  // COLORI SPECIFICI PER myText / myTextArea
  // ---------------------------------------------------------
  color c_bgNormal     = color(255);               // sfondo normale
  color c_bgHover      = color(245, 245, 255);     // sfondo hover
  color c_bgFocus      = color(230, 240, 255);     // sfondo focus

  color c_border       = color(120);               // bordo normale
  color c_borderFocus  = color(0, 120, 255);       // bordo focus

  // ---------------------------------------------------------
  // COLORI DEI PANNELLI
  // ---------------------------------------------------------
  color c_pannel        = color(240, 240, 255);   // sfondo pannelli

  color  c_Track = color(230, 240, 255);
  color  c_Thumb = color(125, 200, 200);;
  color  c_ThumbHover =  color(200, 125, 200);;
  color  c_ThumbDrag = color(200, 200, 125);;

  // ---------------------------------------------------------
  // TIPOGRAFIA E LAYOUT
  // ---------------------------------------------------------
  float fontSize      = 18;     // dimensione testo
  int margin          = 4;      // margine interno generico

  // ---------------------------------------------------------
  // BORDI
  // ---------------------------------------------------------
  float borderWeight        = 1.0;   // bordo normale
  float borderWeightPressed = 1.1;   // bordo premuto

  // ---------------------------------------------------------
  // PADDING BOTTONI
  // ---------------------------------------------------------
  int buttonPaddingX = 10;   // padding orizzontale extra
  int buttonPaddingY = 6;    // padding verticale extra

}
