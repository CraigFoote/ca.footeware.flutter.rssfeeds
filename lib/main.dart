import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rss_feeds/color_factory.dart';

import 'add_edit_dialog.dart';
import 'channel.dart';
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
  final List<Channel> _channels = [];

  @override
  void initState() {
    super.initState();
    _channels.addAll([
      Channel(
        'Techcrunch',
        Uri.parse('http://feeds.feedburner.com/Techcrunch'),
      ),
      Channel(
        'Ars Technica',
        Uri.parse('http://feeds.arstechnica.com/arstechnica/index'),
      ),
    ]);
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
      body: Material(
        // wrap in Material to prevent bleed through
        child: IndexedStack(
          index: _selectedPageIndex,
          children: [
            Material(child: FeedPage(_channels, widget.httpClient)),
            Material(child: ChannelsPage(widget._formKey, _channels)),
          ],
        ),
      ),
    );
  }

  _addFeed(GlobalKey<FormState> formKey) {
    showDialog(
      context: context,
      builder: (_) {
        return AddEditDialog(
          context: context,
          formKey: formKey,
          channels: _channels,
        );
      },
    );
  }
}
