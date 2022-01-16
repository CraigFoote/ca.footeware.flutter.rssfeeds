import 'package:quiver/core.dart';

class Channel {
  late String name;
  late String url;

  Channel({required this.name, required this.url});

  toJSONEncodable() {
    Map<String, dynamic> m = {};
    m['name'] = name;
    m['url'] = url;
    return m;
  }

  @override
  bool operator ==(other) =>
      other is Channel && other.name == name && other.url == url;

  @override
  int get hashCode => hash2(name.hashCode, url.hashCode);
}
