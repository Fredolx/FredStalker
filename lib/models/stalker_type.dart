import 'package:fredstalker/backend/exceptions/invalid_value_exception.dart';
import 'package:fredstalker/models/media_type.dart';

enum StalkerType {
  live("itv"),
  vod("vod"),
  series("series"),
  stb("stb");

  final String value;
  const StalkerType(this.value);
}

StalkerType fromMediaType(MediaType type) {
  switch (type) {
    case MediaType.live:
      return StalkerType.live;
    case MediaType.vod:
      return StalkerType.vod;
    case MediaType.series:
      return StalkerType.series;
    case MediaType.category:
      throw InvalidValueException(MediaType.category.toString());
    case MediaType.season:
      throw InvalidValueException(MediaType.season.toString());
  }
}
