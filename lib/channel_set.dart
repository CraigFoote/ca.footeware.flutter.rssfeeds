import 'package:rss_feeds/channel.dart';

class ChannelSet {
  Set<Channel> items = {};

  toJSONEncodable() {
    return items.map((channel) {
      return channel.toJSONEncodable();
    }).toList();
  }
}
