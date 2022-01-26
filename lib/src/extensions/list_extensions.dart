import 'dart:collection';

extension ExListS<E> on List<E> {
  List<E> distinctBy(Function(E element) a) {
    HashSet idServers = new HashSet();
    for (int i = 0; i < this.length; i++) {
      final value = a(this[i]);
      if (!idServers.add(value)) {
        /// Do the -- no i because removing an item from the list and not doing that it will skip the next one
        this.removeAt(i--);
      }
    }
    return this;
  }
}
