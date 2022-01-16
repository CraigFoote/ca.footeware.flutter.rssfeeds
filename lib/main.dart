import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:rss_feeds/color_factory.dart';

import 'add_edit_dialog.dart';
import 'channel.dart';
import 'channel_set.dart';
import 'channels_page.dart';
import 'feed_page.dart';

void main() {
  runApp(const RssFeedApp());
}

class RssFeedApp extends StatelessWidget {
  const RssFeedApp({Key? key}) : super(key: key);
  final String title = 'RSS Feeds';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        primarySwatch: ColorFactory.createMaterialColor(
          const Color(0xff4c566a),
        ),
      ),
      home: HomePage(
        title: title,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;
  final httpClient = http.Client();
  final _formKey = GlobalKey<FormState>();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;
  late ChannelSet _channels;
  late final LocalStorage storage;

  @override
  void initState() {
    super.initState();
    storage = LocalStorage('rss_feeds');
  }

  void stateCallback(ChannelSet list) {
    storage.setItem('rss_feeds', _channels.toJSONEncodable());
    setState(() {
      _channels = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd8dee9),
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
        actions: [
          IconButton(
            onPressed: () => _addFeed(widget._formKey),
            icon: const Icon(
              Icons.add_circle_rounded,
            ),
            tooltip: 'Add Feed',
            color: const Color(0xffd08770),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff4c566a),
        selectedItemColor: const Color(0xffebcb8b),
        unselectedItemColor: const Color(0xffeceff4),
        iconSize: 40,
        currentIndex: _selectedPageIndex,
        onTap: (index) => setState(() => _selectedPageIndex = index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_rounded,
            ),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.rss_feed_rounded,
            ),
            label: 'Channels',
          ),
        ],
      ),
      body: FutureBuilder(
        future: _getChannels(),
        builder: (_, snapshot) {
           if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff4c566a),
              ),
            );
          } else {
            _channels = snapshot.data as ChannelSet;
            return Material(
              // wrap in Material to prevent bleed through
              child: IndexedStack(
                index: _selectedPageIndex,
                children: [
                  Material(
                      child: FeedPage(
                    client: widget.httpClient,
                    channels: _channels,
                  )),
                  Material(
                      child: ChannelsPage(
                          formKey: widget._formKey,
                          stateCallback: stateCallback,
                          channels: _channels)),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  _addFeed(GlobalKey<FormState> formKey) {
    showDialog(
      context: context,
      builder: (_) {
        return AddEditDialog(
          stateCallback: stateCallback,
          context: context,
          formKey: formKey,
          channels: _channels,
        );
      },
    );
  }

  Future<ChannelSet> _getChannels() async {
    await storage.ready;
    ChannelSet channelSet = ChannelSet();
    var items = storage.getItem('rss_feeds');
    List<Channel> list = [];
    if (items != null) {
      list = List<Channel>.from(
        (items as List).map(
          (item) => Channel(
            name: item['name'],
            url: item['url'],
          ),
        ),
      );
      channelSet.items.addAll(list);
    }
    return channelSet;
  }

}
