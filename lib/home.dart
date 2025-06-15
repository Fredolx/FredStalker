import 'package:flutter/material.dart';
import 'package:fredstalker/arrow_nav.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(showSearchBar ? 64 : 0),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: showSearchBar
                ? search_bar.SearchBar(
                    searchController: search,
                    hide: showSearchBar,
                    focusNode: _focusNode,
                  )
                : SizedBox.shrink(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
      search.clear();
      //  _scrollController.jumpTo(0);
      //  load(false);
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
