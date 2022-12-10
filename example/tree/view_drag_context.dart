import 'view_node.dart';

class ViewDragContext {
  static ViewNode? _node;
  static String? _uuid;

  static void drag(ViewNode node) {
    _node = node;
    _uuid = node.uuid;
  }

  static ViewNode? drop(String uuid) {
    if (uuid != _uuid) {
      return null;
    }
    ViewNode? tmp = _node;

    _node = null;
    _uuid = null;
    return tmp;
  }
}
