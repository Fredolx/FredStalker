import 'package:flutter/material.dart';
import 'package:fredstalker/arrow_nav.dart';
import 'package:fredstalker/bottom_nav.dart';
import 'package:fredstalker/models/channel.dart';
import 'package:fredstalker/models/filters.dart';
import 'package:fredstalker/models/memory.dart';
import 'package:fredstalker/models/node.dart';
import 'package:fredstalker/models/node_type.dart';
import 'package:fredstalker/models/stalker_type.dart';
import 'package:fredstalker/models/view_type.dart';
import 'package:fredstalker/tile.dart';
import 'package:fredstalker/search_bar.dart' as search_bar;
import 'package:fredstalker/models/stack.dart' as fstack;

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Filters filters = Filters(ViewType.all, 1, StalkerType.vod, null, null);
  List<Channel> channels = [];
  int? maxItemsPerPage;
  int? maxPages;
  bool initialLoading = true;
  TextEditingController search = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<bool> isSelected = [false, true, false];
  fstack.Stack nodeStack = fstack.Stack();
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  initAsync() async {
    await getResults();
    initialLoading = false;
  }

  Future<void> getResults() async {
    final currentRequest = ++_requestId;
    final result = await Memory.stalker.getStreams(filters);
    if (currentRequest != _requestId) return;
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
    clearFilters(true);
    filters.view = type;
    getResults();
  }

  updateMediaType(StalkerType type) {
    if (filters.type != type) {
      clearFilters(false);
      filters.type = type;
    }
    setState(() {
      filters.page = 1;
    });
    getResults();
  }

  clearFilters(bool skipSettingView) {
    filters.seriesId = null;
    filters.season = null;
    filters.page = 1;
    filters.categoryId = null;
    final firstNode = nodeStack.clear();
    if (skipSettingView) return;
    if (firstNode != null) {
      filters.view = firstNode.type == NodeType.category
          ? ViewType.categories
          : ViewType.all;
    }
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
              child: nodeStack.hasNodes()
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsetsGeometry.fromLTRB(20, 10, 0, 20),
                        child: Text(
                          nodeStack.get().toString(),
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
                return Tile(channel: item, setNode: setNode);
              },
            ),
            Visibility(
              visible: !initialLoading && (maxPages != null && maxPages! > 0),
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

  void setNode(Node node) {
    node.query = filters.query;
    node.page = filters.page;
    nodeStack.add(node);
    setFiltersNode(node);
    getResults();
  }

  void setFiltersNode(Node node) {
    clearSearch();
    filters.page = 1;
    switch (node.type) {
      case NodeType.category:
        filters.view = ViewType.all;
        filters.categoryId = node.id;
        break;
      case NodeType.series:
        filters.view = ViewType.all;
        filters.seriesId = node.id;
        break;
      case NodeType.season:
        filters.view = ViewType.all;
        filters.season = true;
        break;
    }
  }

  void clearSearch() {
    filters.query = null;
    search.clear();
  }

  void undoFiltersNode(Node currentNode) {
    switch (currentNode.type) {
      case NodeType.category:
        filters.categoryId = null;
        break;
      case NodeType.series:
        filters.seriesId = null;
      case NodeType.season:
        filters.season = null;
    }
    reapplyFilters(currentNode);
    filters.view = currentNode.type == NodeType.category
        ? ViewType.categories
        : ViewType.all;
  }

  reapplyFilters(Node node) {
    if (node.query != null && node.query!.isNotEmpty) {
      filters.query = node.query;
      search.text = filters.query!;
    }
    if (node.page != null && node.page! > 1) filters.page = node.page!;
  }

  void handleBack(BuildContext context) {
    if (nodeStack.hasNodes()) {
      undoFiltersNode(nodeStack.pop());
      getResults();
      return;
    }
    Navigator.of(context).pop();
  }
}
