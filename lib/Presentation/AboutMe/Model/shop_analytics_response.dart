class ShopAnalyticsResponse {
  final bool status;
  final AnalyticsData data;

  ShopAnalyticsResponse({
    required this.status,
    required this.data,
  });

  factory ShopAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return ShopAnalyticsResponse(
      status: json['status'] as bool? ?? false,
      data: AnalyticsData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class AnalyticsData {
  final bool success;
  final String filter; // DAY|WEEK|MONTH|YEAR
  final DateRange range;
  final int total;
  final List<SeriesItem> series;
  final AnalyticsSelectors selectors;
  final AnalyticsActive active;
  final MoreDetails moreDetails;

  AnalyticsData({
    required this.success,
    required this.filter,
    required this.range,
    required this.total,
    required this.series,
    required this.selectors,
    required this.active,
    required this.moreDetails,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      success: json['success'] as bool? ?? false,
      filter: (json['filter'] as String? ?? '').toUpperCase(),
      range: DateRange.fromJson(json['range'] as Map<String, dynamic>? ?? {}),
      total: (json['total'] as num? ?? 0).toInt(),
      series: (json['series'] as List<dynamic>? ?? [])
          .map((e) => SeriesItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectors:
      AnalyticsSelectors.fromJson(json['selectors'] as Map<String, dynamic>? ?? {}),
      active:
      AnalyticsActive.fromJson(json['active'] as Map<String, dynamic>? ?? {}),
      moreDetails:
      MoreDetails.fromJson(json['moreDetails'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class DateRange {
  final String start;
  final String end;

  DateRange({
    required this.start,
    required this.end,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: (json['start'] as String? ?? '').trim(),
      end: (json['end'] as String? ?? '').trim(),
    );
  }
}

class SeriesItem {
  final String key;   // "2026-02-05" or "2026-03" etc
  final String label; // "05" or "Mar" etc
  final int value;

  SeriesItem({
    required this.key,
    required this.label,
    required this.value,
  });

  factory SeriesItem.fromJson(Map<String, dynamic> json) {
    return SeriesItem(
      key: (json['key'] as String? ?? '').trim(),
      label: (json['label'] as String? ?? '').trim(),
      value: (json['value'] as num? ?? 0).toInt(),
    );
  }
}

class MoreDetails {
  final int locations;
  final int whatsappMsg;
  final int directCall;
  final int enquiries;
  final int userClicks;

  MoreDetails({
    required this.locations,
    required this.whatsappMsg,
    required this.directCall,
    required this.enquiries,
    required this.userClicks,
  });

  factory MoreDetails.fromJson(Map<String, dynamic> json) {
    return MoreDetails(
      locations: (json['locations'] as num? ?? 0).toInt(),
      whatsappMsg: (json['whatsappMsg'] as num? ?? 0).toInt(),
      directCall: (json['directCall'] as num? ?? 0).toInt(),
      enquiries: (json['enquiries'] as num? ?? 0).toInt(),
      userClicks: (json['userClicks'] as num? ?? 0).toInt(),
    );
  }
}

class AnalyticsSelectors {
  final List<SelectorItem> years;
  final List<SelectorItem> months;
  final List<WeekSelectorItem> weeks;

  // ✅ NEW (DAY selector)
  final List<SelectorItem> days;

  AnalyticsSelectors({
    required this.years,
    required this.months,
    required this.weeks,
    required this.days,
  });

  factory AnalyticsSelectors.fromJson(Map<String, dynamic> json) {
    return AnalyticsSelectors(
      years: (json['years'] as List<dynamic>? ?? [])
          .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      months: (json['months'] as List<dynamic>? ?? [])
          .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      weeks: (json['weeks'] as List<dynamic>? ?? [])
          .map((e) => WeekSelectorItem.fromJson(e as Map<String, dynamic>))
          .toList(),

      // ✅ safe (if backend doesn't send -> [])
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => SelectorItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SelectorItem {
  final String key;
  final String label;

  SelectorItem({
    required this.key,
    required this.label,
  });

  factory SelectorItem.fromJson(Map<String, dynamic> json) {
    return SelectorItem(
      key: (json['key'] as String? ?? '').trim(),
      label: (json['label'] as String? ?? '').trim(),
    );
  }
}

class WeekSelectorItem extends SelectorItem {
  final String start;
  final String end;

  WeekSelectorItem({
    required super.key,
    required super.label,
    required this.start,
    required this.end,
  });

  factory WeekSelectorItem.fromJson(Map<String, dynamic> json) {
    return WeekSelectorItem(
      key: (json['key'] as String? ?? '').trim(),
      label: (json['label'] as String? ?? '').trim(),
      start: (json['start'] as String? ?? '').trim(),
      end: (json['end'] as String? ?? '').trim(),
    );
  }
}

class AnalyticsActive {
  final String mode; // DAY|WEEK|MONTH|YEAR

  final String? month; // "2026-03"
  final String? year;  // "2026"
  final String? week;  // "2026-01-19_2026-01-25"
  final String? day;   // "2026-02-05"

  // ✅ NEW: counts
  final int? days;  // DAY -> 7
  final int? weeks; // WEEK -> 4

  // ✅ NEW: optional range
  final String? start;
  final String? end;

  AnalyticsActive({
    required this.mode,
    this.month,
    this.year,
    this.week,
    this.day,
    this.days,
    this.weeks,
    this.start,
    this.end,
  });

  factory AnalyticsActive.fromJson(Map<String, dynamic> json) {
    return AnalyticsActive(
      mode: (json['mode'] as String? ?? '').toUpperCase(),
      month: (json['month'] as String?)?.trim(),
      year: (json['year'] as String?)?.trim(),
      week: (json['week'] as String?)?.trim(),
      day: (json['day'] as String?)?.trim(),

      // ✅ safe int parsing
      days: (json['days'] as num?)?.toInt(),
      weeks: (json['weeks'] as num?)?.toInt(),

      start: (json['start'] as String?)?.trim(),
      end: (json['end'] as String?)?.trim(),
    );
  }
}
