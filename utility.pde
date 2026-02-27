

void dashedRect(float x, float y, float w, float h, float dash, float gap) {
  float[] lengths = { w, h, w, h };  // lunghezze dei 4 lati
  float px = x, py = y;
  int side = 0;

  float remaining = lengths[side];

  float dx = 1, dy = 0;  // direzione iniziale (destra)

  while (side < 4) {

    // segmento tratteggiato
    float seg = min(dash, remaining);
    line(px, py, px + dx * seg, py + dy * seg);

    // avanza
    px += dx * (dash + gap);
    py += dy * (dash + gap);

    remaining -= (dash + gap);

    // se abbiamo finito il lato, passiamo al successivo
    if (remaining <= 0) {
      // correggi posizione finale
      px = constrain(px, x, x + w);
      py = constrain(py, y, y + h);

      // passa al lato successivo
      side++;
      if (side == 1) { dx = 0; dy = 1; px = x + w; py = y; }
      else if (side == 2) { dx = -1; dy = 0; px = x + w; py = y + h; }
      else if (side == 3) { dx = 0; dy = -1; px = x; py = y + h; }

      if (side < 4) remaining = lengths[side];
    }
  }
}
