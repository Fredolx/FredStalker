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
  Filters filters = Filters(ViewType.all, 1, StalkerType.vod, null);
  List<Channel> channels = [];
  int? maxItemsPerPage;
  int? maxPages;
  bool initialLoading = true;
  TextEditingController search = TextEditingController();
  bool showSearchBar = false;
  final FocusNode _focusNode = FocusNode();

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
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home"), elevation: 2),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            search_bar.SearchBar(
              focusNode: _focusNode,
              hide: showSearchBar,
              searchController: search,
              load: getResultsQuery,
              toggleSearch: toggleSearch,
            ),
            GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: channels.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 2,
              ),
              itemBuilder: (context, index) {
                final item = channels[index];
                return Tile(channel: item);
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
      floatingActionButton: Visibility(
        visible: !showSearchBar,
        child: FloatingActionButton(
          onPressed: toggleSearch,
          tooltip: 'Search',
          child: const Icon(Icons.search),
        ),
      ),
      bottomNavigationBar: BottomNav(
        updateViewMode: updateViewMode,
        startingView: ViewType.all,
      ),
    );
  }

  toggleSearch() {
    setState(() {
      showSearchBar = !showSearchBar;
    });
    if (showSearchBar) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => FocusScope.of(context).requestFocus(_focusNode),
      );
    } else {
      FocusScope.of(context).unfocus();
      filters.query = null;
      filters.page = 1;
      search.clear();
      //  _scrollController.jumpTo(0);
      getResults();
    }
  }

  prevPage() async {
    if (filters.page == 1) {
      return;
    }
    setState(() {
      filters.page--;
    });
    await getResults();
  }

  nextPage() async {
    setState(() {
      filters.page++;
    });
    await getResults();
  }
}
