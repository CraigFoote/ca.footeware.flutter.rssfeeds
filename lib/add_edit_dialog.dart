import 'package:flutter/material.dart';

import 'channel.dart';

class AddEditDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final BuildContext context;
  final List<Channel> channels;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final Channel? channel;

  AddEditDialog(
      {Key? key,
      required this.context,
      required this.formKey,
      required this.channels,
      this.channel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddEditDialogState();
}

class _AddEditDialogState extends State<AddEditDialog> {
  @override
  Widget build(_) {
    widget.nameController.text =
        (widget.channel == null ? '' : widget.channel?.title)!;
    widget.urlController.text =
        (widget.channel == null ? '' : widget.channel?.url.toString())!;
    return AlertDialog(
      backgroundColor: const Color(0xffd8dee9),
      title: widget.channel != null
          ? Text('Edit ${widget.channel?.title}')
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name.';
                } else {
                  for (Channel channel in widget.channels) {
                    if (channel.title == widget.nameController.text) {
                      return 'A feed with that name already exists.';
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
                  onPressed: () {
                    if (widget.formKey.currentState!.validate()) {
                      Channel newChannel = Channel(widget.nameController.text,
                          Uri.parse(widget.urlController.text));
                      setState(
                        () {
                          if (widget.channel == null) {
                            widget.channels.add(newChannel);
                          } else {
                            widget.channels.remove(widget.channel);
                            widget.channels.add(newChannel);
                          }
                        },
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
