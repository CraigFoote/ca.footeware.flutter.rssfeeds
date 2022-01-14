import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rss_feeds/color_factory.dart';
import 'package:rss_feeds/rss_exception.dart';

import 'add_edit_dialog.dart';

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

class ChannelsPage extends StatefulWidget {
  const ChannelsPage(this.formKey, this.channels, {Key? key}) : super(key: key);

  final GlobalKey<FormState> formKey;
  final List<Channel> channels;

  @override
  State<StatefulWidget> createState() => ChannelsPageState();
}

class ChannelsPageState extends State<ChannelsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: widget.channels.length,
      padding: const EdgeInsets.all(8),
      separatorBuilder: (_, __) => const Divider(
        color: Color(0xff5e81ac),
        thickness: 1,
        height: 8,
      ),
      itemBuilder: (_, index) {
        Channel currentChannel = widget.channels[index];
        return ListTile(
          leading: const Icon(Icons.rss_feed_rounded),
          title: Row(
            children: [
              Text(
                currentChannel.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_rounded),
                      color: const Color(0xff4c566a),
                      onPressed: () =>
                          _editFeed(widget.formKey, currentChannel),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_rounded),
                      color: const Color(0xff4c566a),
                      onPressed: () => _deleteFeed(currentChannel),
                    ),
                  ],
                ),
              )
            ],
          ),
          isThreeLine: true,
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
            ),
            child: SelectableText(currentChannel.description +
                '\n\n' +
                currentChannel.url.toString()),
          ),
          tileColor: const Color(0xff8fbcbb),
          dense: false,
          contentPadding: const EdgeInsets.all(8),
          textColor: const Color(0xff3b4252),
        );
      },
    );
  }

  _deleteFeed(Channel currentChannel) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xffd8dee9),
          title:
              Text('Are you sure you want to delete ${currentChannel.title}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () {
                      setState(() => widget.channels.remove(currentChannel));
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _editFeed(GlobalKey<FormState> _formKey, Channel _currentChannel) {
    showDialog(
      context: context,
      builder: (_) {
        return AddEditDialog(
          context: context,
          formKey: _formKey,
          channels: widget.channels,
          channel: _currentChannel,
        );
      },
    );
  }
}

class FeedPage extends StatefulWidget {
  const FeedPage(this.channels, this.client, {Key? key}) : super(key: key);

  final List<Channel> channels;
  final http.Client client;

  @override
  State<StatefulWidget> createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  late Future<List<FeedItem>> feedItems;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFeedItems(widget.channels),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final List<FeedItem>? items = snapshot.data as List<FeedItem>;
          if (items != null) {
            int itemCount = items.length;
            final ScrollController controller = ScrollController();
            return ListView.separated(
              itemCount: itemCount,
              padding: const EdgeInsets.all(8),
              separatorBuilder: (_, __) => const Divider(
                color: Color(0xff81a1c1),
                thickness: 1,
                height: 8,
              ),
              controller: controller,
              itemBuilder: (_, index) {
                FeedItem? feedItem = items[index];
                String? url;
                if (feedItem.rssFeed.image != null &&
                    feedItem.rssFeed.image?.url != null) {
                  url = feedItem.rssFeed.image?.url;
                } else {
                  url =
                      'https://upload.wikimedia.org/wikipedia/en/thumb/4/43/Feed-icon.svg/128px-Feed-icon.svg.png';
                }
                return ListTile(
                  isThreeLine: true,
                  leading: SizedBox(
                    height: 50,
                    width: 50,
                    child: CachedNetworkImage(
                      height: 50,
                      imageUrl: url!,
                    ),
                  ),
                  title: SelectableText(
                    feedItem.rssItem.title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    child: Text(feedItem.rssFeed.title! +
                        '\n\n' +
                        feedItem.rssItem.pubDate!),
                  ),
                  tileColor: const Color(0xff81a1c1),
                  dense: false,
                  contentPadding: const EdgeInsets.all(8),
                  textColor: const Color(0xff4c566a),
                  hoverColor: const Color(0xffebcb8b),
                  onTap: () => _handleSelectedFeedItem(feedItem),
                );
              },
            );
          } else {
            throw RssException('\'feedItem\' was null');
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<List<FeedItem>> getFeedItems(List<Channel> channels) async {
    List<FeedItem> list = [];
    for (var channel in channels) {
      await widget.client.get(channel.url).then((response) {
        return response.body;
      }).then((bodyString) {
        RssFeed rssFeed = RssFeed.parse(bodyString);
        channel.description = rssFeed.description!;
        for (RssItem rssItem in rssFeed.items) {
          FeedItem item = FeedItem(rssFeed, rssItem);
          list.add(item);
        }
      }).catchError((e) {
        debugPrint('Got error: $e');
        throw e;
      });
    }
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  _handleSelectedFeedItem(FeedItem feedItem) {
    print('test');
  }
}

class FeedItem {
  FeedItem(this.rssFeed, this.rssItem) {
    String pubDate = rssItem.pubDate!;
    DateTime? dateTime = DateTime.tryParse(pubDate);
    if (dateTime != null) {
      this.dateTime = dateTime;
    } else {
      this.dateTime = DateTime.now();
    }
  }

  final RssFeed rssFeed;
  final RssItem rssItem;
  late final DateTime dateTime;
}

class Channel {
  Channel(this.title, this.url);

  late String title;
  late Uri url;
  late String description = '';
}
