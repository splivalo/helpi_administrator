import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpi_admin/features/coupons/data/coupon_model.dart';

class CouponsNotifier extends StateNotifier<List<CouponModel>> {
  CouponsNotifier() : super([]);

  void setAll(List<CouponModel> items) => state = [...items];

  void addItem(CouponModel item) => state = [...state, item];

  void updateItem(CouponModel item) {
    state = [for (final c in state) c.id == item.id ? item : c];
  }

  void removeItem(int id) {
    state = state.where((c) => c.id != id).toList();
  }
}

final couponsProvider =
    StateNotifierProvider<CouponsNotifier, List<CouponModel>>(
      (ref) => CouponsNotifier(),
    );
