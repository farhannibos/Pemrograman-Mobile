// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kajian_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KajianHiveModelAdapter extends TypeAdapter<KajianHiveModel> {
  @override
  final int typeId = 0;

  @override
  KajianHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KajianHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      date: fields[3] as DateTime,
      pemateri: fields[4] as String,
      lokasi: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KajianHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.pemateri)
      ..writeByte(5)
      ..write(obj.lokasi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KajianHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
