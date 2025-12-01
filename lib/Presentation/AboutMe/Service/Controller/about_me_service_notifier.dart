// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tringo_vendor/Core/Const/app_logger.dart';
//
// import '../../../../Api/DataSource/api_data_source.dart';
// import '../../../Login/controller/login_notifier.dart';
// import '../Model/service_delete_response.dart';
//
// class AboutMeServiceState {
//   final bool isLoading;
//   final String? error;
//   final ServiceDeleteResponse? serviceDeleteResponse;
//
//   const AboutMeServiceState({
//     this.isLoading = false,
//     this.error,
//     this.serviceDeleteResponse,
//   });
//
//   factory AboutMeServiceState.initial() => const AboutMeServiceState();
// }
//
// class AboutMeServiceNotifier extends Notifier<AboutMeServiceState> {
//   late final ApiDataSource api;
//   @override
//   AboutMeServiceState build() {
//     api = ref.read(apiDataSourceProvider);
//     return AboutMeServiceState.initial();
//   }
//
//   Future<bool> deleteServiceAction({String? serviceId}) async {
//     if (!ref.mounted) return false;
//
//     state = const AboutMeServiceState(isLoading: true, error: null);
//
//     final result = await api.deleteService(serviceId: serviceId);
//
//     if (!ref.mounted) return false;
//
//     return result.fold(
//       (failure) {
//         if (!ref.mounted) return false;
//         AppLogger.log.e('❌ deleteProduct failure: ${failure.message}');
//         state = AboutMeServiceState(isLoading: false, error: failure.message);
//         return false;
//       },
//       (response) {
//         if (!ref.mounted) return false;
//         AppLogger.log.i('✅ deleteProduct status: ${response.status}');
//         state = AboutMeServiceState(
//           isLoading: false,
//           serviceDeleteResponse: response,
//         );
//         return response.status == true;
//       },
//     );
//   }
// }
//
// final productNotifierProvider =
//     NotifierProvider<AboutMeServiceNotifier, AboutMeServiceState>(
//       AboutMeServiceNotifier.new,
//     );
