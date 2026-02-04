import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_owner/Api/DataSource/api_data_source.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/referral_history_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/review_create_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/review_history_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/send_tcoin_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/uid_name_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/wallet_history_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/wallet_qr_response.dart';
import 'package:tringo_owner/Presentation/Wallet/Model/withdraw_request_response.dart';

import '../../Login/controller/login_notifier.dart';

class WalletState {
  final bool isLoading;
  final bool isMsgSendingLoading;
  final String? sendError;
  final WalletHistoryResponse? walletHistoryResponse;
   final UidNameResponse? uidNameResponse;
   final SendTcoinData? sendTcoinData;
   final WithdrawRequestResponse? withdrawRequestResponse;
   final ReferralHistoryResponse? referralHistoryResponse;
   final ReviewHistoryResponse? reviewHistoryResponse;
   final ReviewCreateResponse? reviewCreateResponse;
   final WalletQrResponse? walletQrResponse;

  final String? error;

  const WalletState({
    this.isLoading = false,
    this.isMsgSendingLoading = false,
    this.sendError,
    this.error,
    this.walletHistoryResponse,
     this.uidNameResponse,
     this.sendTcoinData,
     this.withdrawRequestResponse,
     this.referralHistoryResponse,
     this.reviewHistoryResponse,
     this.reviewCreateResponse,
     this.walletQrResponse,
  });

  factory WalletState.initial() => const WalletState();

  WalletState copyWith({
    bool? isLoading,
    bool? isMsgSendingLoading,
    String? sendError,
    String? error,
    WalletHistoryResponse? walletHistoryResponse,
    UidNameResponse? uidNameResponse,
    SendTcoinData? sendTcoinData,
    WithdrawRequestResponse? withdrawRequestResponse,
    ReferralHistoryResponse? referralHistoryResponse,
    ReviewHistoryResponse? reviewHistoryResponse,
    ReviewCreateResponse? reviewCreateResponse,
    WalletQrResponse? walletQrResponse,
    bool clearError = false,
    bool clearSendError = false,
    bool clearSendData = false,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      sendError: clearSendError ? null : (sendError ?? this.sendError),
      isMsgSendingLoading: isMsgSendingLoading ?? this.isMsgSendingLoading,
      walletHistoryResponse:
      walletHistoryResponse ?? this.walletHistoryResponse,
      uidNameResponse: uidNameResponse ?? this.uidNameResponse,
      sendTcoinData: sendTcoinData ?? this.sendTcoinData,
      withdrawRequestResponse:
      withdrawRequestResponse ?? this.withdrawRequestResponse,
      referralHistoryResponse:
      referralHistoryResponse ?? this.referralHistoryResponse,
      reviewHistoryResponse:
      reviewHistoryResponse ?? this.reviewHistoryResponse,
      reviewCreateResponse: reviewCreateResponse ?? this.reviewCreateResponse,
      walletQrResponse: walletQrResponse ?? this.walletQrResponse,
    );
  }
}

class WalletNotifier extends Notifier<WalletState> {
  late final ApiDataSource api;

  @override
  WalletState build() {
    api = ref.read(apiDataSourceProvider);
    return WalletState.initial();
  }

  Future<void> walletHistory({String type = "ALL"}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.walletHistory(type: type);

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
          (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          walletHistoryResponse: response,
        );
      },
    );
  }

  Future<void> fetchUidPersonName(String uid, {bool load = true}) async {
    state = state.copyWith(isLoading: load, error: null);

    final result = await api.uIDPersonName(uid: uid);

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
          (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          uidNameResponse: response,
        );
      },
    );
  }

  Future<dynamic /*SendTcoinData?*/> uIDSendApi({
    required String toUid,
    required String tcoin,
  }) async {
    // ✅ only button loader + only send error
    state = state.copyWith(
      isMsgSendingLoading: true,
      clearSendError: true,
      clearSendData: true,
    );

    final result = await api.uIDSendApi(tCoin: tcoin, toUid: toUid);

    return result.fold(
          (failure) {
        state = state.copyWith(
          isMsgSendingLoading: false,
          sendError: failure.message, // ✅ store in sendError only
        );
        return null;
      },
          (resp) {
        // resp.data = {"success":true,"fromBalance":1}
        state = state.copyWith(
          isMsgSendingLoading: false,
          clearSendError: true,
          sendTcoinData: resp.data,
        );
        return resp.data;
      },
    );
  }

  Future<void> uIDWithRawApi({
    required String upiId,
    required String tcoin,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.uIDWithRawApi(tcoin: tcoin, upiId: upiId);

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
          (resp) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          withdrawRequestResponse: resp, // ✅ WithdrawRequestData
        );
      },
    );
  }



  Future<void> walletQrCode() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.walletQrCode();

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
          (resp) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          walletQrResponse: resp,
        );
      },
    );
  }
}

final walletNotifier = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);
