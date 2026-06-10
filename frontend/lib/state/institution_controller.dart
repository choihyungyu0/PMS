import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../models/medical_institution.dart';
import '../services/institution_api.dart';

class InstitutionController extends ChangeNotifier {
  InstitutionController(this._institutionApi);

  final InstitutionApi _institutionApi;

  bool loading = false;
  String? errorMessage;
  String? selectedCategory;
  String? selectedSigungu;
  String keyword = '';
  List<String> categories = const [];
  InstitutionRecommendation? recommendation;
  List<MedicalInstitution> searchItems = const [];

  List<String> get sigunguOptions {
    final values = <String>{};
    for (final item in [...searchItems, ...?recommendation?.items]) {
      final value = item.sigungu;
      if (value != null && value.isNotEmpty) values.add(value);
    }
    return values.toList()..sort();
  }

  Future<void> loadInitial({String? reportCategory}) async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      categories = await _institutionApi.categories();
      selectedCategory = reportCategory ?? selectedCategory;
      recommendation = await _institutionApi.recommend(
        serviceCategory: selectedCategory,
      );
      searchItems = recommendation?.items ?? const [];
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '의료기관 데이터를 불러오지 못했어요. CSV 시드 상태를 확인해주세요.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> selectCategory(String? category) async {
    selectedCategory = category;
    await recommend();
  }

  Future<void> setSigungu(String? sigungu) async {
    selectedSigungu = sigungu;
    await search();
  }

  Future<void> setKeyword(String value) async {
    keyword = value;
    await search();
  }

  Future<void> recommend({String? symptom}) async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      recommendation = await _institutionApi.recommend(
        symptom: symptom,
        serviceCategory: selectedCategory,
        sigungu: selectedSigungu,
      );
      searchItems = recommendation?.items ?? const [];
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '의료기관 추천 정보를 불러오지 못했어요.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> search() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      searchItems = await _institutionApi.search(
        serviceCategory: selectedCategory,
        sigungu: selectedSigungu,
        keyword: keyword,
      );
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '의료기관 검색에 실패했어요.';
    }
    loading = false;
    notifyListeners();
  }
}
