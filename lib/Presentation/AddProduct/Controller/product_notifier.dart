import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor/Presentation/AddProduct/Model/product_response.dart';
import '../../../Api/DataSource/api_data_source.dart';
import '../../../Api/Repository/failure.dart';
import '../../Login/controller/login_notifier.dart';

class ProductState {
  final bool isLoading;
  final String? error;
  final ProductResponse? productResponse;

  const ProductState({
    this.isLoading = false,
    this.error,
    this.productResponse,
  });

  factory ProductState.initial() => const ProductState();
}

class ProductNotifier extends Notifier<ProductState> {
  late final ApiDataSource api;

  @override
  ProductState build() {
    api = ref.read(apiDataSourceProvider);
    return ProductState.initial();
  }

  Future<bool> addProduct({
    required String category,
    required String subCategory,
    required String englishName,
    required int price,
    required String offerLabel,
    required String offerValue,

    required String description,

  }) async {
    state = const ProductState(isLoading: true);

    final result = await api.addProduct(

      subCategory: subCategory,
      englishName: englishName,
      category: category,

      description: description,
      offerLabel: offerLabel,
      offerValue: offerValue,
      price: price,
    );

    final isSuccess = result.fold(
      (failure) {
        state = ProductState(isLoading: false, error: failure.message);
        return false;
      },
      (response) {
        state = ProductState(isLoading: false, productResponse: response);
        return true;
      },
    );

    return isSuccess;
  }

  void resetState() {
    state = ProductState.initial();
  }
}

final productNotifierProvider =
    NotifierProvider.autoDispose<ProductNotifier, ProductState>(
      ProductNotifier.new,
    );
