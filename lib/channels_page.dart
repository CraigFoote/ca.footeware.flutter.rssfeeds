import 'package:flutter/material.dart';

import 'add_edit_dialog.dart';
import 'channel.dart';
import 'channel_set.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage(
      {required this.formKey,
      required this.channels,
      required this.stateCallback,
      Key? key})
      : super(key: key);

  final GlobalKey<FormState> formKey;
  final ChannelSet channels;
  final Function stateCallback;

  @override
  State<StatefulWidget> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: widget.channels.items.length,
      padding: const EdgeInsets.all(8),
      separatorBuilder: (_, __) => const Divider(
        color: Color(0xff5e81ac),
        thickness: 1,
        height: 8,
      ),
      itemBuilder: (_, index) {
        Channel currentChannel = widget.channels.items.elementAt(index);
        return ListTile(
          leading: const Icon(Icons.rss_feed_rounded),
          title: Row(
            children: [
              Text(
                currentChannel.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: 'View Feed Items',
                      child: Switch(
                        value: currentChannel.active,
                        onChanged: (value) {
                          setState(() {
                            currentChannel.active = value;
                            widget.stateCallback(widget.channels);
                          });
                        },
                      ),
                    ),
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
            child: SelectableText(currentChannel.url.toString()),
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
              Text('Are you sure you want to delete ${currentChannel.name}?'),
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
                      widget.channels.items.remove(
                          currentChannel); // not sure why this doesn't work
                      Navigator.of(context).pop();
                      widget.stateCallback(widget.channels);
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
