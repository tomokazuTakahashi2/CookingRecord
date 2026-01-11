// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cooking_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CookingRecord _$CookingRecordFromJson(Map<String, dynamic> json) {
  return _CookingRecord.fromJson(json);
}

/// @nodoc
mixin _$CookingRecord {
  String get id => throw _privateConstructorUsedError;
  String get dishName => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get photoPath => throw _privateConstructorUsedError;

  /// Serializes this CookingRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CookingRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CookingRecordCopyWith<CookingRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CookingRecordCopyWith<$Res> {
  factory $CookingRecordCopyWith(
    CookingRecord value,
    $Res Function(CookingRecord) then,
  ) = _$CookingRecordCopyWithImpl<$Res, CookingRecord>;
  @useResult
  $Res call({
    String id,
    String dishName,
    String? memo,
    DateTime createdAt,
    String? photoPath,
  });
}

/// @nodoc
class _$CookingRecordCopyWithImpl<$Res, $Val extends CookingRecord>
    implements $CookingRecordCopyWith<$Res> {
  _$CookingRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CookingRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dishName = null,
    Object? memo = freezed,
    Object? createdAt = null,
    Object? photoPath = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            dishName: null == dishName
                ? _value.dishName
                : dishName // ignore: cast_nullable_to_non_nullable
                      as String,
            memo: freezed == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            photoPath: freezed == photoPath
                ? _value.photoPath
                : photoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CookingRecordImplCopyWith<$Res>
    implements $CookingRecordCopyWith<$Res> {
  factory _$$CookingRecordImplCopyWith(
    _$CookingRecordImpl value,
    $Res Function(_$CookingRecordImpl) then,
  ) = __$$CookingRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String dishName,
    String? memo,
    DateTime createdAt,
    String? photoPath,
  });
}

/// @nodoc
class __$$CookingRecordImplCopyWithImpl<$Res>
    extends _$CookingRecordCopyWithImpl<$Res, _$CookingRecordImpl>
    implements _$$CookingRecordImplCopyWith<$Res> {
  __$$CookingRecordImplCopyWithImpl(
    _$CookingRecordImpl _value,
    $Res Function(_$CookingRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CookingRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dishName = null,
    Object? memo = freezed,
    Object? createdAt = null,
    Object? photoPath = freezed,
  }) {
    return _then(
      _$CookingRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        dishName: null == dishName
            ? _value.dishName
            : dishName // ignore: cast_nullable_to_non_nullable
                  as String,
        memo: freezed == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        photoPath: freezed == photoPath
            ? _value.photoPath
            : photoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CookingRecordImpl implements _CookingRecord {
  const _$CookingRecordImpl({
    required this.id,
    required this.dishName,
    this.memo,
    required this.createdAt,
    this.photoPath,
  });

  factory _$CookingRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$CookingRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String dishName;
  @override
  final String? memo;
  @override
  final DateTime createdAt;
  @override
  final String? photoPath;

  @override
  String toString() {
    return 'CookingRecord(id: $id, dishName: $dishName, memo: $memo, createdAt: $createdAt, photoPath: $photoPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CookingRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dishName, dishName) ||
                other.dishName == dishName) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, dishName, memo, createdAt, photoPath);

  /// Create a copy of CookingRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CookingRecordImplCopyWith<_$CookingRecordImpl> get copyWith =>
      __$$CookingRecordImplCopyWithImpl<_$CookingRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CookingRecordImplToJson(this);
  }
}

abstract class _CookingRecord implements CookingRecord {
  const factory _CookingRecord({
    required final String id,
    required final String dishName,
    final String? memo,
    required final DateTime createdAt,
    final String? photoPath,
  }) = _$CookingRecordImpl;

  factory _CookingRecord.fromJson(Map<String, dynamic> json) =
      _$CookingRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get dishName;
  @override
  String? get memo;
  @override
  DateTime get createdAt;
  @override
  String? get photoPath;

  /// Create a copy of CookingRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CookingRecordImplCopyWith<_$CookingRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
