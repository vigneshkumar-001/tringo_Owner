enum ChartFilter { day, week, month, year }

/// Convert enum -> API string
String chartFilterToApi(ChartFilter f) {
  switch (f) {
    case ChartFilter.day:
      return "DAY";
    case ChartFilter.week:
      return "WEEK";
    case ChartFilter.month:
      return "MONTH";
    case ChartFilter.year:
      return "YEAR";
  }
}

/// (Optional) API string -> enum (useful if API sends active.mode)
ChartFilter chartFilterFromApi(String? s) {
  switch ((s ?? "").toUpperCase()) {
    case "WEEK":
      return ChartFilter.week;
    case "MONTH":
      return ChartFilter.month;
    case "YEAR":
      return ChartFilter.year;
    case "DAY":
    default:
      return ChartFilter.day;
  }
}

/// UI label for dropdown
String chartFilterLabel(ChartFilter f) {
  switch (f) {
    case ChartFilter.day:
      return "Last 7 Days";
    case ChartFilter.week:
      return "Last 4 Weeks";
    case ChartFilter.month:
      return "This Month";
    case ChartFilter.year:
      return "This Year";
  }
}
