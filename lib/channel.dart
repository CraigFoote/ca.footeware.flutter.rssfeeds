import 'package:quiver/core.dart';

class Channel {
  String name;
  String url;
  bool active;

  Channel({required this.name, required this.url, required this.active});

  toJSONEncodable() {
    Map<String, dynamic> m = {};
    m['name'] = name;
    m['url'] = url;
    m['active'] = active;
    return m;
  }

  @override
  bool operator ==(other) =>
      other is Channel && other.name == name && other.url == url;

  @override
  int get hashCode => hash2(name.hashCode, url.hashCode);
}
