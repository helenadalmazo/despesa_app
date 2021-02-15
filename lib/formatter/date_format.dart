class DateFormat {

  static String now() {
    DateTime now = DateTime.now();

    String day = now.day.toString().padLeft(2, "0");
    String month = now.month.toString().padLeft(2, "0");
    String year = now.year.toString();

    month = _getMonthAbbreviation(month);

    return "$day/$month/$year";
  }

  static String format(String value) {
    List<String> slipValue = value.split("-");

    String year = slipValue[0];
    String month = slipValue[1];
    String day = slipValue[1];

    month = _getMonthAbbreviation(month);

    return "$day/$month/$year";
  }

  static String formatYearMonth(String value) {
    List<String> slipValue = value.split("-");

    String year = slipValue[0];
    String month = slipValue[1];

    year = year.substring(2, 4);
    month = _getMonthAbbreviation(month);

    return "$month/$year";
  }

  static String _getMonthAbbreviation(String value) {
    if (value == "01") return "jan";
    if (value == "02") return "fev";
    if (value == "03") return "mar";
    if (value == "04") return "abr";
    if (value == "05") return "maio";
    if (value == "06") return "jun";
    if (value == "07") return "jul";
    if (value == "08") return "ago";
    if (value == "09") return "set";
    if (value == "10") return "out";
    if (value == "11") return "nov";
    if (value == "12") return "dez";
    throw Exception("Abbreviation not found for month $value");
  }

}