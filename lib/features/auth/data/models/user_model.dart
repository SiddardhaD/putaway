import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';
import 'user_info_model.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String username,
    required String environment,
    required String role,
    required String jasserver,
    required UserInfoModel userInfo,
    @JsonKey(name: 'aisSessionCookie') String? sessionCookie,
    bool? userAuthorized,
    bool? adminAuthorized,
    bool? passwordAboutToExpire,
    String? envColor,
    String? machineName,
    bool? currencyEnvironment,
    String? externalJASURL,
    bool? deprecated,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserEntity toEntity() {
    return UserEntity(
      id: userInfo.addressNumber?.toString() ?? username,
      username: username,
      email: userInfo.longUserId ?? username,
      organization: environment,
      token: userInfo.token,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      username: entity.username,
      environment: entity.organization ?? '',
      role: '*ALL',
      jasserver: '',
      userInfo: UserInfoModel(
        token: entity.token ?? '',
        username: entity.username,
        alphaName: entity.username,
      ),
    );
  }
}
