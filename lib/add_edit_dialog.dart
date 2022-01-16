import 'package:flutter/material.dart';

import 'channel.dart';
import 'channel_set.dart';

class AddEditDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final BuildContext context;
  final ChannelSet channels;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final Function stateCallback;
  final Channel? channel;

  AddEditDialog(
      {Key? key,
      required this.context,
      required this.formKey,
      required this.channels,
      required this.stateCallback,
      this.channel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddEditDialogState();
}

class _AddEditDialogState extends State<AddEditDialog> {
  @override
  Widget build(_) {
    widget.nameController.text =
        (widget.channel == null ? '' : widget.channel?.name)!;
    widget.urlController.text =
        (widget.channel == null ? '' : widget.channel?.url.toString())!;
    return AlertDialog(
      backgroundColor: const Color(0xffd8dee9),
      title: widget.channel != null
          ? Text('Edit ${widget.channel?.name}')
          : const Text('Add a Feed'),
      content: Form(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: widget.nameController,
              decoration: const InputDecoration(helperText: 'Name'),
              autofocus: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name.';
                } else {
                  if (widget.channel == null) {
                    // creating new
                    for (Channel c in widget.channels.items) {
                      if (c.name == value) {
                        return 'There\'s already a feed by that name.';
                      }
                    }
                  } else {
                    // editing
                    for (Channel c in widget.channels.items) {
                      if (c != widget.channel && c.name == value) {
                        return 'There\'s already a feed by that name.';
                      }
                    }
                  }
                }
                return null;
              },
            ),
            TextFormField(
              controller: widget.urlController,
              decoration: const InputDecoration(helperText: 'Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address.';
                } else if (Uri.tryParse(value) == null) {
                  return 'Please enter a valid URL.';
                } else {
                  Uri url = Uri.parse(value);
                  if (!url.isAbsolute) {
                    return 'Not a valid URL.';
                  }
                }
                return null;
              },
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    if (widget.formKey.currentState!.validate()) {
                      final name = widget.nameController.text;
                      final url = widget.urlController.text;
                      if (widget.channel == null) {
                        // creating new
                        Channel newChannel = Channel(
                          name: name,
                          url: url,
                          active: true,
                        );
                        widget.channels.items.add(newChannel);
                      } else {
                        widget.channel?.name = name;
                        widget.channel?.url = url;
                      }
                      Navigator.of(context).pop();
                      widget.stateCallback(widget.channels);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
