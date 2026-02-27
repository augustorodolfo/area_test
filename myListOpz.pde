class Opzione {
    String nomeCampo;
    Class<?> tipo;
    Object valore;
    myInterface editor;   // widget di input
}
class myListOpz extends myInterface {

    ArrayList<Opzione> opzioni = new ArrayList<>();
    vScrollBar sb;

    int rowHeight = 28;
    int colNameWidth = 180;

    Object targetObj;   // es: VarDefault

    myListOpz(int x, int y, int w, int h) {
        super(x, y, w, h);

        draggable = false;
        resizable = false;
        focusable = true;

        sb = new vScrollBar(x + w - 12, y, 12, h);
    }
void loadFromObject(Object obj) {
    targetObj = obj;
    opzioni.clear();

    Field[] campi = obj.getClass().getDeclaredFields();

    for (Field f : campi) {
        f.setAccessible(true);

        Opzione o = new Opzione();
        o.nomeCampo = f.getName();
        o.tipo = f.getType();

        try {
            o.valore = f.get(obj);
        } catch (Exception e) {
            continue;
        }

        o.editor = createEditorForType(o.nomeCampo, o.tipo, o.valore);

        opzioni.add(o);
    }

    updateScrollbar();
}
myInterface createEditorForType(String nome, Class<?> tipo, Object valore) {

    // COLORI (int con prefisso c_)
    if (tipo == int.class && nome.startsWith("c_")) {
        return new myColorBox(0,0,100,rowHeight, (int) valore);
    }

    // NUMERI INTERI
    if (tipo == int.class || tipo == Integer.class) {
        myText t = new myText(0,0,100,rowHeight);
        t.setText(str(valore));
        return t;
    }

    // FLOAT
    if (tipo == float.class || tipo == Float.class) {
        myText t = new myText(0,0,100,rowHeight);
        t.setText(nf((float) valore,1,2));
        return t;
    }

    // BOOLEAN
    if (tipo == boolean.class || tipo == Boolean.class) {
        myButton b = new myButton("",0,0);
        b.interruttore = true;
        b.on = (boolean) valore;
        return b;
    }

    // STRING
    if (tipo == String.class) {
        myText t = new myText(0,0,150,rowHeight);
        t.setText((String) valore);
        return t;
    }

    return new myLabel("Tipo non supportato");
}
@Override
void visualizza() {
    super.visualizza();

    sb.left = left + larg - sb.larg;
    sb.top  = top;
    sb.alt  = alt;

    float yoff = top - sb.val;

    clip(left, top, larg - sb.larg, alt);

    for (int i = 0; i < opzioni.size(); i++) {
        Opzione o = opzioni.get(i);
        float ry = yoff + i * rowHeight;

        // Nome campo
        fill(0);
        text(o.nomeCampo, left + 6, ry + 6);

        // Editor
        o.editor.left = left + colNameWidth;
        o.editor.top  = ry;
        o.editor.larg = larg - colNameWidth - sb.larg - 4;
        o.editor.alt  = rowHeight - 2;

        o.editor.visualizza();
    }

    noClip();

    sb.visualizza();
}
void updateObject() {
    if (targetObj == null) return;

    for (Opzione o : opzioni) {
        try {
            Field f = targetObj.getClass().getDeclaredField(o.nomeCampo);
            f.setAccessible(true);

            Object nuovoValore = extractValueFromEditor(o.editor, o.tipo);
            f.set(targetObj, nuovoValore);

        } catch (Exception e) {
            println("Errore aggiornando " + o.nomeCampo);
        }
    }
}
Object extractValueFromEditor(myInterface ed, Class<?> tipo) {

    if (tipo == int.class && ed instanceof myColorBox) {
        return ((myColorBox) ed).getColor();
    }

    if (tipo == int.class && ed instanceof myText) {
        return parseInt(((myText) ed).getText());
    }

    if (tipo == float.class && ed instanceof myText) {
        return parseFloat(((myText) ed).getText());
    }

    if (tipo == boolean.class && ed instanceof myButton) {
        return ((myButton) ed).on;
    }

    if (tipo == String.class && ed instanceof myText) {
        return ((myText) ed).getText();
    }

    return null;
}
void updateScrollbar() {
    int totalHeight = opzioni.size() * rowHeight;
    int visible = alt;

    int maxScroll = max(0, totalHeight - visible);

    sb.setRange(0, maxScroll);
    sb.setAltPercCurs((float)visible / totalHeight * 100);
}
}



