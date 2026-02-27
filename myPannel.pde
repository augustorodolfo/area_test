class myPannel extends myInterface {

  myPannel(int x, int y, int w, int h) {
    super(x, y, w, h);

    // Il pannello è un contenitore passivo
    enableHover = false;      // niente hover grafico
    enablePressed = false;    // niente bordo pressed
    focusable = false;        // non riceve focus tastiera

    // Ma è interattivo
    draggable = false;
    resizable = true;
  }

  @Override
  void visualizza() {
  super.visualizza();
    // --- SFONDO PANNELLO ---
    fill(VarDefault.c_pannel);   // colore dedicato ai pannelli
    stroke(0);
    strokeWeight(1);
    rect(left, top, larg, alt);

    drawResizeHandle();
  }
}
