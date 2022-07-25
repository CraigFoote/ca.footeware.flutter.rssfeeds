import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'feed_item.dart';

class FeedItemPage extends StatefulWidget {
  const FeedItemPage({required this.client, required this.feedItem, Key? key})
      : super(key: key);

  final FeedItem feedItem;
  final http.Client client;

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
    return FutureBuilder(
      future: _getContent(widget.feedItem.rssItem.link),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff4c566a)),
          );
        }
        String data = snapshot.data as String;
        return Material(
          child: Scaffold(
            appBar: AppBar(title: Text('${widget.feedItem.rssFeed.title}')),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    isThreeLine: true,
                    leading: SizedBox(
                      height: 50,
                      width: 50,
                      child: Hero(
                        tag: widget.feedItem.rssItem.title!,
                        child: CachedNetworkImage(
                          height: 50,
                          imageUrl: url!,
                        ),
                      ),
                    ),
                    title: SelectableText(
                      widget.feedItem.rssItem.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Html(
                        onLinkTap: (url, context, attributes, element) =>
                            _launchInBrowser(url!),
                        style: {
                          'body': Style(
                            fontSize: FontSize.large,
                            backgroundColor: const Color(0xffd8dee9),
                            padding: const EdgeInsets.all(8),
                          ),
                        },
                        data: widget.feedItem.rssFeed.title! +
                            '<br>' +
                            widget.feedItem.rssItem.description! +
                            '<br>' +
                            widget.feedItem.rssItem.pubDate!),
                    tileColor: const Color(0xff81a1c1),
                    dense: false,
                    contentPadding: const EdgeInsets.all(8),
                    textColor: const Color(0xff4c566a),
                    hoverColor: const Color(0xffebcb8b),
                  ),
                  Container(
                    decoration: const BoxDecoration(color: Color(0xff81a1c1)),
                    child: Html(
                      onLinkTap: (url, context, attributes, element) =>
                          _launchInBrowser(url!),
                      style: {
                        'body': Style(
                          fontSize: FontSize.xLarge,
                          backgroundColor: const Color(0xffd8dee9),
                          padding: const EdgeInsets.all(8),
                        ),
                      },
                      data: data,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
    )) {
      throw 'Could not launch $url';
    }
  }

  Future<String> _getContent(String? link) async {
    String body = '';
    await widget.client.get(Uri.parse(link!)).then((response) {
      body = response.body;
    });
    return body;
  }
}
