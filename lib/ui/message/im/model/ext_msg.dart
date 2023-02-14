enum ExtType {
  a,
}

abstract class IExtData {
  ExtType get type;

  Map<String, dynamic> toJson() => {'type': type};
}
