import 'package:fredstalker/backend/exceptions/invalid_value_exception.dart';
import 'package:fredstalker/models/media_type.dart';

enum NodeType { category, series, season }

NodeType fromMediaType(MediaType type) {
  switch (type) {
    case MediaType.category:
      return NodeType.category;
    case MediaType.series:
      return NodeType.series;
    case MediaType.season:
      return NodeType.season;
    case MediaType.live:
      throw InvalidValueException(MediaType.live.toString());
    case MediaType.vod:
      throw InvalidValueException(MediaType.live.toString());
  }
}
