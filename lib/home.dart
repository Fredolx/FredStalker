import 'package:flutter/material.dart';
import 'package:fredstalker/arrow_nav.dart';
import 'package:fredstalker/models/channel.dart';
import 'package:fredstalker/models/filters.dart';
import 'package:fredstalker/models/memory.dart';
import 'package:fredstalker/models/stalker_type.dart';
import 'package:fredstalker/models/view_type.dart';
import 'package:fredstalker/tile.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Filters filters = Filters(ViewType.all, 1, StalkerType.live, null);
  List<Channel> channels = [];
  int? maxItemsPerPage;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  initAsync() async {
    getResults();
  }

  getResults() async {
    var result = await Memory.stalker.getStreams(filters);
    setState(() {
      maxItemsPerPage = result.maxItemsPerPage;
      channels = result.channels;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home"), elevation: 2),
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
            ArrowNav(
              value: filters.page,
              onDecrement: prevPage,
              onIncrement: nextPage,
            ),
          ],
        ),
      ),
    );
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
