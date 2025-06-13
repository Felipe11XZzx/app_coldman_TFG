class Validations {

  static String? validateRequired(String? value) {
    return (value == null || value.isEmpty) ? "Campo obligatorio" : null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) return "Campo obligatorio";
    int? age = int.tryParse(value);
    if (age == null) return "Edad Debe ser un número";
    if (age <= 0) return "La edad debe ser positiva";
    if (age > 110) return "Edad no válida";
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Campo obligatorio";
    if (value.length < 6) return "Mínimo 6 caracteres";
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return "Campo obligatorio";
    try {
      double price = double.parse(value.replaceAll(',', '.'));
      if (price <= 0) return "Formato no válido";
      return null;
    } catch (e) {
      return "Precio no válido";
    }
  }

  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) return "Campo obligatorio";
    int? stock = int.tryParse(value);
    if (stock == null) return "Formato no válido";
    if (stock < 0) return "No puede haber estock negativo";
    return null;
  }
  
}