import java.lang.reflect.*;

class myConfigManager {

  String pathVersioni;

  myConfigManager(String basePath) {
    pathVersioni = basePath + "versioni" + File.separator;
  }

  boolean legge_var(Object obj) {
    String pathConfig = pathVersioni + "config.xml";
    XML xml = loadXML(pathConfig);
    if (xml == null) {
      println("ATTENZIONE: [" + pathConfig + "] non è stato letto");
      return false;
    }
    XML nodo = xml.getChild("valori");
    if (nodo == null) return false;

    setta_field_from_attributi(obj, nodo);
    return true;
  }

  void setta_field_from_attributi(Object obj, XML nodo) {
    try {
      Field[] campi = obj.getClass().getDeclaredFields();
      for (Field campo : campi) {
        campo.setAccessible(true);
        String nome = campo.getName();
        String valoreStr = nodo.getString(nome);
        if (valoreStr != null) {
          Object valore = parseValue(nome, valoreStr, campo.getType());
          campo.set(obj, valore);
        }
      }
    } catch (Exception e) {
      println("Errore in setta_field_from_attributi: " + e.getMessage());
    }
  }

  Object parseValue(String nome, String valore, Class<?> tipo) {
    valore = valore.trim();
    try {
      if (tipo == int.class && nome.startsWith("c_")) {
        return (int) Long.parseLong(valore.substring(2), 16);
      }
      if (tipo == int.class) return Integer.parseInt(valore);
      if (tipo == float.class) return Float.parseFloat(valore);
      if (tipo == boolean.class) return Boolean.parseBoolean(valore);
      if (tipo == String.class) return valore;
    } catch (Exception e) {
      println("Errore parsing " + nome);
    }
    return null;
  }

  XML crea_xml_da_classe(Object obj) {
    XML root = new XML("config");
    XML valori = root.addChild("valori");

    try {
      Field[] campi = obj.getClass().getDeclaredFields();
      for (Field campo : campi) {
        campo.setAccessible(true);
        String nome = campo.getName();
        Object valore = campo.get(obj);

        if (campo.getType() == int.class && nome.startsWith("c_")) {
          valori.setString(nome, "0x" + hex((int) valore).toUpperCase());
        } else {
          valori.setString(nome, str(valore));
        }
      }
    } catch (Exception e) {
      println("Errore in crea_xml_da_classe");
    }

    return root;
  }
}
