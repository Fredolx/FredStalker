import 'package:fredstalker/models/stalker_type.dart';
import 'package:fredstalker/models/view_type.dart';

class Filters {
  ViewType view;
  int page;
  StalkerType type;
  String? query;
  String? categoryId;
  String? seriesId;
  bool? season;
  Filters(this.view, this.page, this.type, this.query, this.seriesId);
}
