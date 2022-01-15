import 'package:flutter/material.dart';

import 'add_edit_dialog.dart';
import 'channel.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage(this.formKey, this.channels, this.stateCallback, {Key? key}) : super(key: key);

  final GlobalKey<FormState> formKey;
  final List<Channel> channels;
  final Function stateCallback;

  @override
  State<StatefulWidget> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
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
          stateCallback: widget.stateCallback,
          context: context,
          formKey: _formKey,
          channels: widget.channels,
          channel: _currentChannel,
        );
      },
    );
  }
}
