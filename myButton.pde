class myButton extends myInterface {

  String text = "";

  myButton(String t, int x, int y) {
    super(
      x,
      y,
      int(textWidth(t) + VarDefault.margin*2 + VarDefault.buttonPaddingX*2),
      int(VarDefault.fontSize + VarDefault.margin*2 + VarDefault.buttonPaddingY*2)
    );

    text = t;
    focusable = false;     // i bottoni non ricevono focus tastiera
  }

  @Override
  void visualizza() {

    // --- GRAFICA BASE (bordo, hover, pressed) ---
    super.visualizza();

    // --- COLORE SPECIFICO DEL BOTTONE ---
    int fondo;

    if (pressed && !interruttore) {
      fondo = VarDefault.c_buttonPressed;

    } else if (interruttore && on) {
      fondo = mouseOver ? VarDefault.c_buttonOnInEvent : VarDefault.c_buttonOn;

    } else {
      fondo = mouseOver ? VarDefault.c_buttonInEvent : VarDefault.c_button;
    }

    fill(fondo);
    noStroke();
    rect(left, top, larg, alt);

    // --- TESTO ---
    fill(VarDefault.c_text);
    textAlign(CENTER, CENTER);
    textSize(VarDefault.fontSize);
    text(text, left + larg/2, top + alt/2);
  }

  @Override
  void onClick() {
    println("Hai cliccato il bottone: " + text);
  }
}
