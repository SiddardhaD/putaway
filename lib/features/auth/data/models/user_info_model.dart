import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_info_model.freezed.dart';
part 'user_info_model.g.dart';

@freezed
class UserInfoModel with _$UserInfoModel {
  const factory UserInfoModel({
    required String token,
    String? langPref,
    String? locale,
    String? dateFormat,
    String? dateSeperator,
    String? simpleDateFormat,
    String? timeFormat,
    String? decimalFormat,
    int? addressNumber,
    String? alphaName,
    String? appsRelease,
    String? country,
    String? username,
    String? longUserId,
    String? timeZoneOffset,
    String? dstRuleKey,
  }) = _UserInfoModel;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);
}
