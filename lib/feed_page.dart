import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:rss_feeds/rss_exception.dart';

import 'channel.dart';
import 'feed_item.dart';

class FeedPage extends StatefulWidget {
  const FeedPage(this.channels, this.client, this.stateCallback, {Key? key})
      : super(key: key);

  final List<Channel> channels;
  final http.Client client;
  final Function stateCallback;

  @override
  State<StatefulWidget> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late Future<List<FeedItem>> feedItems;

  @override
  Widget build(_) {
    return FutureBuilder(
      future: _getFeedItems(widget.channels),
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
                return Hero(
                  tag: feedItem.rssItem.title!,
                  child: Material(
                    child: ListTile(
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
                    ),
                  ),
                );
              },
            );
          } else {
            throw RssException('\'feedItem\' was null');
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xff4c566a),
            ),
          );
        }
      },
    );
  }

  Future<List<FeedItem>> _getFeedItems(List<Channel> channels) async {
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
        final SnackBar _snackBar = SnackBar(
          backgroundColor: const Color(0xff434c5e),
          content: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'An error occurred parsing an RSS feed.\n$e',
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      tooltip: 'Copy to clipboard',
                      color: const Color(0xffd8dee9),
                      icon: const Icon(
                        Icons.content_copy_rounded,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '$e'));
                      },
                    ),
                    IconButton(
                      tooltip: 'Dismiss',
                      color: const Color(0xffd8dee9),
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 20),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(_snackBar);
      });
    }
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  _handleSelectedFeedItem(FeedItem feedItem) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => FeedItemPage(feedItem)));
  }
}

class FeedItemPage extends StatefulWidget {
  const FeedItemPage(this.feedItem, {Key? key}) : super(key: key);

  final FeedItem feedItem;

  @override
  State<StatefulWidget> createState() => _FeedItemPageState();
}

class _FeedItemPageState extends State<FeedItemPage> {
  @override
  Widget build(BuildContext context) {
    String? url;
    if (widget.feedItem.rssFeed.image != null &&
        widget.feedItem.rssFeed.image?.url != null) {
      url = widget.feedItem.rssFeed.image?.url;
    } else {
      url =
          'https://upload.wikimedia.org/wikipedia/en/thumb/4/43/Feed-icon.svg/128px-Feed-icon.svg.png';
    }
    return Material(
      child: Scaffold(
        appBar: AppBar(title: const Text('RSS Feed Item')),
        body: Column(
          children: [
            Hero(
              tag: widget.feedItem.rssItem.title!,
              child: Material(
                child: ListTile(
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
                    widget.feedItem.rssItem.title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(widget.feedItem.rssFeed.title! +
                      '\n\n' +
                      widget.feedItem.rssItem.pubDate!),
                  tileColor: const Color(0xff81a1c1),
                  dense: false,
                  contentPadding: const EdgeInsets.all(8),
                  textColor: const Color(0xff4c566a),
                  hoverColor: const Color(0xffebcb8b),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xff81a1c1),
                  ),
                  child: Html(
                    style: {
                      'body': Style(
                        fontSize: FontSize.xLarge,
                        backgroundColor: const Color(0xffd8dee9),
                        padding: const EdgeInsets.all(8),
                      ),
                    },
                    data: widget.feedItem.rssItem.description ??
                        'Description not found.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
