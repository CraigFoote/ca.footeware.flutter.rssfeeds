import 'package:dart_rss/dart_rss.dart';

class FeedItem {
  final RssFeed rssFeed;
  final RssItem rssItem;
  late final DateTime dateTime;

  FeedItem(this.rssFeed, this.rssItem) {
    String pubDate = rssItem.pubDate!;
    DateTime? dateTime = DateTime.tryParse(pubDate);
    if (dateTime != null) {
      this.dateTime = dateTime;
    } else {
      this.dateTime = DateTime.now();
    }
  }
}
