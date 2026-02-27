import java.awt.*;
import java.awt.datatransfer.*;

class myManager {
  boolean zIndex=false;
  ArrayList<myInterface> elementi = new ArrayList<myInterface>();
  boolean layoutInProgress = false;
String file_layout = "";
File selectedFile;

  // ---------------------------------------------------------
    // AGGIUNGI
  // ---------------------------------------------------------
  void aggiungi(myInterface w, String idName) {
    
    for (myInterface o : elementi) {
      if (o.idName.equals(idName)) {
        println("ERRORE: idName '" + idName + "' già usato");
        return;
      }
    }
    
    w.idName = idName;
    elementi.add(w);
  }
  
  // ---------------------------------------------------------
    // GET BY ID
  // ---------------------------------------------------------
  myInterface getById(String idName) {
    for (myInterface o : elementi) {
      if (o.idName.equals(idName)) return o;
    }
    return null;
  }

// ---------------------------------------------------------
  // REMOVE BY ID
// ---------------------------------------------------------
boolean removeById(String idName) {
  for (int i = 0; i < elementi.size(); i++) {
    if (elementi.get(i).idName.equals(idName)) {
      elementi.remove(i);
      return true;
    }
  }
  return false;
}

// ---------------------------------------------------------
  // BRING TO FRONT
// ---------------------------------------------------------
boolean bringToFront(String idName) {
  for (int i = 0; i < elementi.size(); i++) {
    if (elementi.get(i).idName.equals(idName)) {
      myInterface w = elementi.remove(i);
      elementi.add(w);
      return true;
    }
  }
  return false;
}

// ---------------------------------------------------------
  // SEND TO BACK
// ---------------------------------------------------------
boolean sendToBack(String idName) {
  for (int i = 0; i < elementi.size(); i++) {
    if (elementi.get(i).idName.equals(idName)) {
      myInterface w = elementi.remove(i);
      elementi.add(0, w);
      return true;
    }
  }
  return false;
}

// ---------------------------------------------------------
  // DISEGNO
// ---------------------------------------------------------
void drawAll() {
  for (myInterface o : elementi) {
    o.visualizza();
  }
}
void saveLayout(String fileName) {
  XML root = new XML("Layout");
  
  for (myInterface o : elementi) {
    root.addChild(o.toXML());
  }
  
  saveXML(root, fileName);
  println("Layout salvato in: " + fileName);
}
void scelta_layout() {
    if (!layoutInProgress) {
        layoutInProgress = true;
        selectInput("Seleziona un file layout:", "selezionaLayout");
    }
}
public void selezionaLayout(File selection) {
    try {
        if (selection == null) {
            println("Selezione annullata.");
            return;
        }

        file_layout = selection.getAbsolutePath();
        println("Layout scelto: " + file_layout);

        if (!file_layout.startsWith(pathVersioni)) {
            println("Il file deve essere nella cartella: " + pathVersioni);
            return;
        }

        String nome = file_layout.substring(pathVersioni.length());
        loadLayout(nome);

    } finally {
        layoutInProgress = false;
    }
}

void loadLayout(String fileName) {
    XML root = loadXML(fileName);
    if (root == null) {
        println("Errore: impossibile leggere " + fileName);
        return;
    }

    for (myInterface o : elementi) {
        XML xo = root.getChild(o.idName);
        if (xo != null) {
            o.fromXML(xo);
        }
    }

    println("Layout caricato da: " + fileName);
}

// ---------------------------------------------------------
  // MOUSE EVENTS
// ---------------------------------------------------------

void mousePressedAll() {
  
  globalVar.mouseContol = -1;
  
  for (int i = elementi.size() - 1; i >= 0; i--) {
    myInterface o = elementi.get(i);
    o.mousePressed();
    
    if (o.pressed) {
      // Z-INDEX AUTOMATICO SOLO SE ABILITATO
      if (zIndex) {
        bringToFront(o.idName);
      }
      
      globalVar.focus = o;
      break;
    }
  }
}


void mouseReleasedAll() {
  for (myInterface o : elementi) {
    o.mouseReleased();
  }
}

void mouseDraggedAll() {
  for (myInterface o : elementi) {
    o.mouseDragged();
  }
}

void mouseMovedAll() {
  for (myInterface o : elementi) {
    o.mouseMoved();
  }
}

void mouseWheelAll(float e) {
  for (myInterface o : elementi) {
    o.mouseWheel(e);
  }
}
void setResizableAll(boolean value) {
  for (myInterface o : elementi) {
    o.resizable = value;
  }
}
// ---------------------------------------------------------
  // KEYBOARD EVENTS
// ---------------------------------------------------------

void keyPressedAll(char k, int code) {
if (globalVar.focus != null) {
globalVar.focus.keyPressed(k, code);
}
}

void keyReleasedAll(char k, int code) {
if (globalVar.focus != null) {
globalVar.focus.keyReleased(k, code);
}
}
// utility
void copyToClipboard(String s) {
try {
StringSelection ss = new StringSelection(s);
Clipboard cb = Toolkit.getDefaultToolkit().getSystemClipboard();
cb.setContents(ss, null);
}
catch (Exception e) {
// opzionale: println(e);
}
}

String pasteFromClipboard() {
try {
Clipboard cb = Toolkit.getDefaultToolkit().getSystemClipboard();
if (cb.isDataFlavorAvailable(DataFlavor.stringFlavor)) {
return (String) cb.getData(DataFlavor.stringFlavor);
}
}
catch (Exception e) {
// opzionale: println(e);
}
return null;
}
}
