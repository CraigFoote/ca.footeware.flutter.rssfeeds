import 'package:dart_rss/dart_rss.dart';
import 'package:intl/intl.dart';

class FeedItem {
  final RssFeed rssFeed;
  final RssItem rssItem;
  late final DateTime dateTime;

  FeedItem(this.rssFeed, this.rssItem) {
    String pubDate = rssItem.pubDate!;
    final format = DateFormat('E, d LLL y H:m:s z');
    DateTime parsed = format.parse(pubDate);
    dateTime = parsed;
  }
}
