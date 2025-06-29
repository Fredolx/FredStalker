import 'package:fredstalker/backend/exceptions/invalid_value_exception.dart';
import 'package:fredstalker/models/stalker_type.dart';

enum MediaType { live, vod, series, category }

MediaType fromStalkerType(StalkerType type) {
  switch (type) {
    case StalkerType.live:
      return MediaType.live;
    case StalkerType.vod:
      return MediaType.vod;
    case StalkerType.series:
      return MediaType.series;
    case StalkerType.stb:
      throw InvalidValueException(StalkerType.stb.toString());
  }
}
