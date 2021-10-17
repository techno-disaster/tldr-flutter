import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tldr/command/bloc/command_bloc.dart';
import 'package:tldr/command/models/command.dart';
import 'package:tldr/utils/commands_tile.dart';
import 'package:tldr/utils/constants.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';

class AllCommandsScreen extends StatefulWidget {
  final List<Command> commands;

  const AllCommandsScreen({Key? key, required this.commands}) : super(key: key);

  @override
  State<AllCommandsScreen> createState() => _AllCommandsScreenState();
}

class _AllCommandsScreenState extends State<AllCommandsScreen>
    with SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(text: "Android"),
    Tab(text: "Common"),
    Tab(text: "Linux"),
    Tab(text: "OSX"),
    Tab(text: "Sunos"),
    Tab(text: "Windows")
  ];

  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  IconData icon(String tab) {
    switch (tab) {
      case 'android':
        return Icons.android;
      case 'linux':
        return MyIcons.linux_1;
      case 'osx':
        return MyIcons.app_store_ios;
      case 'windows':
        return MyIcons.windows;
      default:
        return Icons.all_inbox_sharp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff17181c),
      appBar: AppBar(
        elevation: 0,
        title: Text("All Commands"),
        backgroundColor: Color(0xff17181c),
        bottom: TabBar(
          isScrollable: true,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          indicatorColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BubbleTabIndicator(
            indicatorHeight: 25.0,
            indicatorColor: Colors.blueAccent,
            tabBarIndicatorSize: TabBarIndicatorSize.tab,
            // Other flags
            // indicatorRadius: 1,
            // insets: EdgeInsets.all(1),
            // padding: EdgeInsets.all(10)
          ),
          tabs: tabs,
          controller: _tabController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.shuffle),
          backgroundColor: Color(0xff2e2f37),
          onPressed: () {
            Command command = (widget.commands.toList()..shuffle()).first;
            Navigator.push(
              context,
              createCommandDetailsRoute(command),
            );
            Command c = Command(
              name: command.name,
              platform: command.platform,
              dateTime: DateTime.now(),
            );
            BlocProvider.of<CommandBloc>(context).add(
              AddToHistory(c),
            );
            BlocProvider.of<CommandBloc>(context).add(
              GetFromHistory(),
            );
          }),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((Tab tab) {
          return widget.commands.isNotEmpty
              ? ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: widget.commands.length,
                  itemBuilder: (context, index) {
                    return AllCommandsTile(
                      index: index,
                      command: widget.commands[index],
                      icon: icon(tab.text!.toLowerCase()),
                      hidden: widget.commands[index].platform !=
                          tab.text!.toLowerCase(),
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Unable to fetch commands.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
        }).toList(),
      ),
    );
  }
}
