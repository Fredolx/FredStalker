import 'package:flutter/material.dart';
import 'package:fredstalker/arrow_nav.dart';
import 'package:fredstalker/bottom_nav.dart';
import 'package:fredstalker/models/channel.dart';
import 'package:fredstalker/models/filters.dart';
import 'package:fredstalker/models/memory.dart';
import 'package:fredstalker/models/stalker_type.dart';
import 'package:fredstalker/models/view_type.dart';
import 'package:fredstalker/tile.dart';
import 'package:fredstalker/search_bar.dart' as search_bar;

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Filters filters = Filters(ViewType.all, 1, StalkerType.live, null);
  List<Channel> channels = [];
  int? maxItemsPerPage;
  int? maxPages;
  bool initialLoading = true;
  TextEditingController search = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<bool> isSelected = [true, false, false];
  String? categoryName;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  initAsync() async {
    await getResults();
    initialLoading = false;
  }

  getResults() async {
    var result = await Memory.stalker.getStreams(filters);
    setState(() {
      maxItemsPerPage = result.maxItemsPerPage;
      channels = result.channels;
      maxPages = result.maxPage;
    });
  }

  getResultsQuery(String query) {
    filters.query = query;
    filters.page = 1;
    getResults();
  }

  updateViewMode(ViewType type) {
    filters.view = type;
    filters.categoryId = null;
    filters.page = 1;
    getResults();
  }

  updateMediaType(StalkerType type) {
    filters.type = type;
    setState(() {
      filters.page = 1;
    });
    getResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            search_bar.SearchBar(
              focusNode: _focusNode,
              back: () => handleBack(context),
              enabled: !initialLoading,
              searchController: search,
              load: getResultsQuery,
            ),
            SizedBox(height: 15),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: filters.categoryId != null
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsetsGeometry.fromLTRB(20, 10, 0, 0),
                        child: Text(
                          "Viewing category: $categoryName",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child:
                  filters.view == ViewType.history ||
                      filters.view == ViewType.favorites ||
                      filters.categoryId != null
                  ? SizedBox.shrink()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ToggleButtons(
                          borderRadius: BorderRadius.circular(10),
                          isSelected: isSelected,
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < isSelected.length; i++) {
                                isSelected[i] = i == index;
                              }
                            });
                            updateMediaType(StalkerType.values[index]);
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text("Live"),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text("Vods"),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text("Series"),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 5),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: channels.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisExtent: 120,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final item = channels[index];
                return Tile(channel: item, setCategory: setCategory);
              },
            ),
            Visibility(
              visible: !initialLoading,
              child: ArrowNav(
                value: filters.page,
                maxValue: maxPages,
                onDecrement: prevPage,
                onIncrement: nextPage,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        updateViewMode: updateViewMode,
        startingView: ViewType.all,
      ),
    );
  }

  void prevPage(bool max) async {
    if (filters.page == 1) {
      return;
    }
    setState(() {
      filters.page = max ? 1 : filters.page - 1;
    });
    await getResults();
  }

  void nextPage(bool max) async {
    setState(() {
      filters.page = max ? maxPages! : filters.page + 1;
    });
    await getResults();
  }

  void setCategory(String id, String name) {
    categoryName = name;
    filters.view = ViewType.all;
    filters.categoryId = id;
    getResults();
  }

  void handleBack(BuildContext context) {
    if (filters.categoryId != null) {
      filters.categoryId = null;
      filters.view = ViewType.categories;
      categoryName = null;
      getResults();
      return;
    }
    Navigator.of(context).pop();
  }
}
