import 'package:fredstalker/models/stalker_type.dart';
import 'package:fredstalker/models/view_type.dart';

class Filters {
  ViewType view;
  int page;
  StalkerType type;
  String? query;
  Filters(this.view, this.page, this.type, this.query);
}
