// home_notifier.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_owner/Core/Const/app_logger.dart';
import 'package:tringo_owner/Presentation/Home/Model/reply_response.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Login/controller/login_notifier.dart';
import '../Model/enquiry_response.dart';
import '../Model/mark_enquiry.dart';
import '../Model/shops_response.dart';
import '../Model/enquiry_analytics_response.dart';

enum AnalyticsType { enquiries, calls, locations }

String _keyFromType(AnalyticsType t) {
  switch (t) {
    case AnalyticsType.enquiries:
      return "enquiries";
    case AnalyticsType.calls:
      return "calls";
    case AnalyticsType.locations:
      return "locations";
  }
}

String _tabFromType(AnalyticsType t) {
  switch (t) {
    case AnalyticsType.enquiries:
      return "ENQUIRY";
    case AnalyticsType.calls:
      return "CALL";
    case AnalyticsType.locations:
      return "MAP";
  }
}

/// ✅ UI status (no conflict with model EnquiryStatus)
enum AnalyticsStatus { open, closed, unknown }

String analyticsStatusToString(AnalyticsStatus v) {
  switch (v) {
    case AnalyticsStatus.open:
      return "OPEN";
    case AnalyticsStatus.closed:
      return "CLOSED";
    case AnalyticsStatus.unknown:
      return "UNKNOWN";
  }
}

int _itemsCount(List<CommonSection> sections) {
  int c = 0;
  for (final s in sections) {
    c += s.items.length;
  }
  return c;
}

/// Merge sections by dayKey (append items)
List<CommonSection> mergeSectionsByDay(
  List<CommonSection> oldS,
  List<CommonSection> newS,
) {
  final map = <String, CommonSection>{};

  for (final s in oldS) {
    map[s.dayKey] = CommonSection(
      dayKey: s.dayKey,
      dayLabel: s.dayLabel,
      items: [...s.items],
    );
  }

  for (final s in newS) {
    final existing = map[s.dayKey];
    if (existing == null) {
      map[s.dayKey] = CommonSection(
        dayKey: s.dayKey,
        dayLabel: s.dayLabel,
        items: [...s.items],
      );
    } else {
      map[s.dayKey] = CommonSection(
        dayKey: existing.dayKey,
        dayLabel: existing.dayLabel,
        items: [...existing.items, ...s.items],
      );
    }
  }

  // newest first
  final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
  return [for (final k in keys) map[k]!];
}

class AnalyticsPageState {
  final List<CommonSection> sections;
  final int take;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;

  const AnalyticsPageState({
    this.sections = const [],
    this.take = 10,
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
  });

  int get loadedItems => _itemsCount(sections);
  bool get hasMore => loadedItems < total;

  AnalyticsPageState copyWith({
    List<CommonSection>? sections,
    int? take,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
  }) {
    return AnalyticsPageState(
      sections: sections ?? this.sections,
      take: take ?? this.take,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HomeState {
  final bool isLoading;
  final String? error;

  final EnquiryResponse? enquiryResponse;
  final ReplyResponse? replyResponse;
  final ShopsResponse? shopsResponse;
  final MarkEnquiry? markEnquiry;

  final EnquiryAnalyticsResponse? enquiryAnalyticsResponse;

  final String? selectedShopId;

  final AnalyticsType selectedAnalyticsType;
  final AnalyticsStatus selectedAnalyticsStatus;

  final Map<String, AnalyticsPageState> analyticsPages;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.enquiryResponse,
    this.replyResponse,
    this.shopsResponse,
    this.markEnquiry,
    this.enquiryAnalyticsResponse,
    this.selectedShopId,
    this.selectedAnalyticsType = AnalyticsType.enquiries,
    this.selectedAnalyticsStatus = AnalyticsStatus.open,
    this.analyticsPages = const {},
  });

  factory HomeState.initial() => const HomeState();

  HomeState copyWith({
    bool? isLoading,
    String? error,
    EnquiryResponse? enquiryResponse,
    ReplyResponse? replyResponse,
    ShopsResponse? shopsResponse,
    MarkEnquiry? markEnquiry,
    EnquiryAnalyticsResponse? enquiryAnalyticsResponse,
    String? selectedShopId,
    AnalyticsType? selectedAnalyticsType,
    AnalyticsStatus? selectedAnalyticsStatus,
    Map<String, AnalyticsPageState>? analyticsPages,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error, // ✅ FIX
      enquiryResponse: enquiryResponse ?? this.enquiryResponse,
      replyResponse: replyResponse ?? this.replyResponse,
      shopsResponse: shopsResponse ?? this.shopsResponse,
      markEnquiry: markEnquiry ?? this.markEnquiry,
      enquiryAnalyticsResponse:
          enquiryAnalyticsResponse ?? this.enquiryAnalyticsResponse,
      selectedShopId: selectedShopId ?? this.selectedShopId,
      selectedAnalyticsType:
          selectedAnalyticsType ?? this.selectedAnalyticsType,
      selectedAnalyticsStatus:
          selectedAnalyticsStatus ?? this.selectedAnalyticsStatus,
      analyticsPages: analyticsPages ?? this.analyticsPages,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  late final ApiDataSource api;

  @override
  HomeState build() {
    api = ref.read(apiDataSourceProvider);
    return HomeState.initial();
  }

  // ------------------- Existing Methods -------------------

  Future<void> selectShop(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentShopId', shopId);
    state = state.copyWith(selectedShopId: shopId);
  }

  Future<void> fetchAllEnquiry({required String shopId}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getAllEnquiry(shopId: shopId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
        enquiryResponse: null,
      ),
      (response) => state = state.copyWith(
        isLoading: false,
        error: null,
        enquiryResponse: response,
      ),
    );
  }
  Future<void> replyEnquiry({
    required String shopId,
    required String requestId,      // ✅ must pass real requestId
    required String productTitle,   // ✅ must pass real title
    required String message,        // ✅ must pass real message
    required int price,             // ✅ must pass real price
    File? ownerImageFile,
  }) async {
    state = state.copyWith(isLoading: false, error: null);

    String uploadedUrl = '';

    final hasValidImage =
        ownerImageFile != null &&
            ownerImageFile.path.isNotEmpty &&
            await ownerImageFile.exists();

    if (hasValidImage) {
      final uploadResult = await api.userProfileUpload(imageFile: ownerImageFile);

      uploadedUrl = uploadResult.fold(
            (failure) => '',
            (success) => (success.message ?? '').toString(), // ✅ your API returns URL in message
      );
    }

    // ✅ images list (send empty list if no upload)
    final imagesList = uploadedUrl.isNotEmpty ? [uploadedUrl] : <String>[];

    final result = await api.replyEnquiry(
      shopId: shopId,
      requestId: requestId,           // ✅ FIX: pass real values
      productTitle: productTitle,
      message: message,
      images: imagesList,             // ✅ FIX: List<String>
      price: price,
    );

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          replyResponse: null,
        );
      },
          (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          replyResponse: response,
        );
      },
    );
  }

  Future<ShopsResponse?> fetchShops({
    required String shopId,
    required String filter,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getAllShops(shopId: shopId, filter: filter);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          shopsResponse: null,
        );
        return null; // ❌ failed
      },
      (response) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
          'isFreemium',
          response.data.subscription?.isFreemium ?? false,
        );

        state = state.copyWith(
          isLoading: false,
          error: null,
          shopsResponse: response,
        );

        return response; // ✅ return full data
      },
    );
  }

  // Future<void> fetchShops({required String shopId}) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   final result = await api.getAllShops(shopId: shopId);
  //
  //   result.fold(
  //     (failure) => state = state.copyWith(
  //       isLoading: false,
  //       error: failure.message,
  //       shopsResponse: null,
  //     ),
  //     (response) async {
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setBool(
  //         'isFreemium',
  //         response.data.subscription?.isFreemium ?? false,
  //       );
  //
  //       state = state.copyWith(
  //         isLoading: false,
  //         error: null,
  //         shopsResponse: response,
  //       );
  //     },
  //   );
  // }

  Future<void> markEnquiry({required String enquiryId}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.markEnquiry(enquiryId: enquiryId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
        markEnquiry: null,
      ),
      (response) => state = state.copyWith(
        isLoading: false,
        error: null,
        markEnquiry: response,
      ),
    );
  }

  Future<void> markCallOrLocation({
    required String id,
    required String shopId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.markCallOrMapClose(
      interactionsId: id,
      shopId: shopId,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
        markEnquiry: null,
      ),
      (response) => state = state.copyWith(
        isLoading: false,
        error: null,
        markEnquiry: response,
      ),
    );
  }
  // ------------------- Analytics Methods -------------------

  void setAnalyticsType(AnalyticsType type) {
    state = state.copyWith(selectedAnalyticsType: type, error: null);
  }

  void setAnalyticsStatus(AnalyticsStatus status) {
    state = state.copyWith(selectedAnalyticsStatus: status, error: null);
  }

  AnalyticsPageState _pageOf(String key) =>
      state.analyticsPages[key] ?? const AnalyticsPageState();

  /// ✅ helper: pick open/closed list based on selectedAnalyticsStatus
  CommonList _pickListForStatus(StatusLists? statusLists) {
    if (statusLists == null) {
      return CommonList(
        paging: Paging(take: 0, skip: 0, total: 0),
        sections: const [],
      );
    }
    return (state.selectedAnalyticsStatus == AnalyticsStatus.open)
        ? statusLists.open
        : statusLists.closed;
  }

  /// Refresh current analytics tab (load first page)
  Future<void> refreshAnalytics({
    required String shopId,
    required String start,
    required String end,
    int take = 10,
  }) async {
    final key = _keyFromType(state.selectedAnalyticsType);

    final pages = Map<String, AnalyticsPageState>.from(state.analyticsPages);
    pages[key] = const AnalyticsPageState().copyWith(
      isLoading: true,
      isLoadingMore: false,
      sections: const [],
      take: take,
      total: 0,
    );
    state = state.copyWith(analyticsPages: pages, error: null);

    final statusStr = analyticsStatusToString(state.selectedAnalyticsStatus);

    final result = await api.fetchEnquiryAnalyticsPaged(
      shopId: shopId,
      tab: _tabFromType(state.selectedAnalyticsType),
      enquiryStatus: statusStr,
      callStatus: statusStr,
      mapStatus: statusStr,
      take: take,
      skip: 0,
      start: start,
      end: end,
    );

    result.fold(
      (failure) {
        final pages2 = Map<String, AnalyticsPageState>.from(
          state.analyticsPages,
        );
        pages2[key] = _pageOf(key).copyWith(isLoading: false);
        state = state.copyWith(analyticsPages: pages2, error: failure.message);
      },
      (resp) {
        final statusLists = resp.data.lists.items[key]; // ✅ StatusLists
        final list = _pickListForStatus(
          statusLists,
        ); // ✅ CommonList(open/closed)

        final pages2 = Map<String, AnalyticsPageState>.from(
          state.analyticsPages,
        );
        pages2[key] = AnalyticsPageState(
          sections: list.sections,
          take: take,
          total: list.paging.total,
          isLoading: false,
          isLoadingMore: false,
        );

        state = state.copyWith(
          enquiryAnalyticsResponse: resp,
          analyticsPages: pages2,
          error: null,
        );
      },
    );
  }

  /// Load next page for current analytics tab
  Future<void> loadMoreAnalytics({
    required String shopId,
    required String start,
    required String end,
  }) async {
    final key = _keyFromType(state.selectedAnalyticsType);
    final current = _pageOf(key);

    if (current.isLoading || current.isLoadingMore) return;
    if (current.total != 0 && !current.hasMore) return;

    final nextSkip = current.loadedItems;

    final pages1 = Map<String, AnalyticsPageState>.from(state.analyticsPages);
    pages1[key] = current.copyWith(isLoadingMore: true);
    state = state.copyWith(analyticsPages: pages1, error: null);

    final statusStr = analyticsStatusToString(state.selectedAnalyticsStatus);

    final result = await api.fetchEnquiryAnalyticsPaged(
      shopId: shopId,
      tab: _tabFromType(state.selectedAnalyticsType),
      enquiryStatus: statusStr,
      callStatus: statusStr,
      mapStatus: statusStr,
      take: current.take,
      skip: nextSkip,
      start: start,
      end: end,
    );

    result.fold(
      (failure) {
        final pages2 = Map<String, AnalyticsPageState>.from(
          state.analyticsPages,
        );
        pages2[key] = _pageOf(key).copyWith(isLoadingMore: false);
        state = state.copyWith(analyticsPages: pages2, error: failure.message);
      },
      (resp) {
        final statusLists = resp.data.lists.items[key];
        final list = _pickListForStatus(statusLists);

        final incoming = list.sections;
        final merged = mergeSectionsByDay(current.sections, incoming);

        final pages2 = Map<String, AnalyticsPageState>.from(
          state.analyticsPages,
        );
        pages2[key] = current.copyWith(
          sections: merged,
          total: list.paging.total,
          isLoadingMore: false,
        );

        state = state.copyWith(
          enquiryAnalyticsResponse: resp,
          analyticsPages: pages2,
          error: null,
        );
      },
    );
  }

  // in home_notifier.dart
  Future<void> markAnalyticsItem({
    required AnalyticsType type,
    required String id,
    required String shopId,
  }) async {
    switch (type) {
      case AnalyticsType.enquiries:
        await markEnquiry(enquiryId: id); // API-1
        break;

      case AnalyticsType.calls:
      case AnalyticsType.locations:
        await markCallOrLocation(
          id: id,
          shopId: shopId,
        ); // API-2 (your second API)
        break;
    }
  }
}

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tringo_owner/Core/Const/app_logger.dart';
// import 'package:tringo_owner/Presentation/AboutMe/Model/shop_root_response.dart';
// import 'package:tringo_owner/Presentation/Home/Model/enquiry_response.dart';
// import 'package:tringo_owner/Presentation/Home/Model/mark_enquiry.dart';
// import 'package:tringo_owner/Presentation/Home/Model/shops_response.dart';
//
// import '../../../Api/DataSource/api_data_source.dart';
// import '../../Login/controller/login_notifier.dart';
// import '../Model/enquiry_analytics_response.dart';
//
// class HomeState {
//   final bool isLoading;
//   final String? error;
//   final EnquiryResponse? enquiryResponse;
//   final ShopsResponse? shopsResponse;
//   final MarkEnquiry? markEnquiry;
//   final EnquiryAnalyticsResponse? enquiryAnalyticsResponse;
//   final String? selectedShopId; // ✅ ADD THIS
//
//   const HomeState({
//     this.isLoading = false,
//     this.error,
//     this.enquiryResponse,
//     this.shopsResponse,
//     this.selectedShopId,
//     this.markEnquiry,
//     this.enquiryAnalyticsResponse,
//   });
//
//   factory HomeState.initial() => const HomeState();
//
//   HomeState copyWith({
//     bool? isLoading,
//     String? error,
//     EnquiryResponse? enquiryResponse,
//     ShopsResponse? shopsResponse,
//     String? selectedShopId,
//     MarkEnquiry? markEnquiry,
//     EnquiryAnalyticsResponse? enquiryAnalyticsResponse,
//   }) {
//     return HomeState(
//       isLoading: isLoading ?? this.isLoading,
//       // if you pass `error: null` it will clear error, else keep old
//       error: error,
//       enquiryResponse: enquiryResponse ?? this.enquiryResponse,
//       shopsResponse: shopsResponse ?? this.shopsResponse,
//       selectedShopId: selectedShopId ?? this.selectedShopId,
//       markEnquiry: markEnquiry ?? this.markEnquiry,
//       enquiryAnalyticsResponse:
//           enquiryAnalyticsResponse ?? this.enquiryAnalyticsResponse,
//     );
//   }
// }
//
// class HomeNotifier extends Notifier<HomeState> {
//   late final ApiDataSource api;
//
//   @override
//   HomeState build() {
//     api = ref.read(apiDataSourceProvider);
//     return HomeState.initial();
//   }
//
//   Future<void> selectShop(String shopId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('currentShopId', shopId);
//     AppLogger.log.i(shopId);
//     state = state.copyWith(selectedShopId: shopId);
//   }
//
//   Future<void> fetchAllEnquiry({required String shopId}) async {
//     // only set loading flag, keep shopsResponse as it is
//     state = state.copyWith(isLoading: true, error: null);
//
//     final result = await api.getAllEnquiry(shopId: shopId);
//
//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isLoading: false,
//           error: failure.message,
//           enquiryResponse: null,
//         );
//       },
//       (response) {
//         state = state.copyWith(
//           isLoading: false,
//           error: null,
//           enquiryResponse: response,
//         );
//       },
//     );
//   }
//
//   Future<void> fetchShops({required String shopId}) async {
//     state = state.copyWith(isLoading: true, error: null);
//
//     final result = await api.getAllShops(shopId: shopId);
//
//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isLoading: false,
//           error: failure.message,
//           shopsResponse: null,
//         );
//       },
//       (response) async {
//         final isFreemium = response.data.subscription?.isFreemium ?? false;
//         final prefs = await SharedPreferences.getInstance();
//
//         await prefs.setBool('isFreemium', isFreemium);
//         AppLogger.log.i('isNewUser Data ==== ${isFreemium}');
//         state = state.copyWith(
//           isLoading: false,
//           error: null,
//           shopsResponse: response,
//         );
//       },
//     );
//   }
//
//   Future<void> markEnquiry({required String enquiryId}) async {
//     state = state.copyWith(isLoading: true, error: null);
//
//     final result = await api.markEnquiry(enquiryId: enquiryId);
//
//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isLoading: false,
//           error: failure.message,
//           markEnquiry: null,
//         );
//       },
//       (response) {
//         state = state.copyWith(
//           isLoading: false,
//           error: null,
//           markEnquiry: response,
//         );
//       },
//     );
//   }
//
//   Future<void> enquiryAnalytics({required String enquiryId}) async {
//     state = state.copyWith(isLoading: true, error: null);
//
//     final result = await api.markEnquiry(enquiryId: enquiryId);
//
//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isLoading: false,
//           error: failure.message,
//           markEnquiry: null,
//         );
//       },
//       (response) {
//         state = state.copyWith(
//           isLoading: false,
//           error: null,
//           markEnquiry: response,
//         );
//       },
//     );
//   }
//
//   Future<void> fetchEnquiryAnalytics({  String shopId}) async {
//     state = state.copyWith(isLoading: true, error: null);
//
//     final result = await api.fetchEnquiryAnalytics(shopId: shopId);
//
//     result.fold(
//           (failure) {
//         state = state.copyWith(
//           isLoading: false,
//           error: failure.message,
//           enquiryAnalyticsResponse: null,
//         );
//       },
//           (response) async {
//
//         state = state.copyWith(
//           isLoading: false,
//           error: null,
//            enquiryAnalyticsResponse : response,
//         );
//       },
//     );
//   }
// }
//
// final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(
//   HomeNotifier.new,
// );
//
