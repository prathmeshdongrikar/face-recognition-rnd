import 'package:hive_flutter/hive_flutter.dart';
part 'user_dto.g.dart';

@HiveType(typeId: 0)
class UserDto {
 @HiveField(0)  String? name;
  @HiveField(1) List<dynamic>? faceData;

  UserDto({required this.name, required this.faceData});

  UserDto.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    faceData = json['faceData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['faceData'] = faceData;
    return data;
  }
}
