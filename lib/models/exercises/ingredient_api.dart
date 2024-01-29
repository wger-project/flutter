import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient_api.freezed.dart';
part 'ingredient_api.g.dart';

/// Model for the search results returned from the /api/v2/ingredient/search endpoint
@freezed
class IngredientApiSearchDetails with _$IngredientApiSearchDetails {
  factory IngredientApiSearchDetails({
    required int id,
    required String name,
    required String? image,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'image_thumbnail') required String? imageThumbnail,
  }) = _IngredientApiSearchDetails;

  factory IngredientApiSearchDetails.fromJson(Map<String, dynamic> json) =>
      _$IngredientApiSearchDetailsFromJson(json);
}

@freezed
class IngredientApiSearchEntry with _$IngredientApiSearchEntry {
  factory IngredientApiSearchEntry({
    required String value,
    required IngredientApiSearchDetails data,
  }) = _IngredientApiSearchEntry;

  factory IngredientApiSearchEntry.fromJson(Map<String, dynamic> json) =>
      _$IngredientApiSearchEntryFromJson(json);
}

@freezed
class IngredientApiSearch with _$IngredientApiSearch {
  factory IngredientApiSearch({
    required List<IngredientApiSearchEntry> suggestions,
  }) = _IngredientApiSearch;

  factory IngredientApiSearch.fromJson(Map<String, dynamic> json) =>
      _$IngredientApiSearchFromJson(json);
}
