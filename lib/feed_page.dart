import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rss_feeds/rss_exception.dart';

import 'channel.dart';
import 'feed_item.dart';

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
    print('_handleSelectedFeedItem');
  }
}
