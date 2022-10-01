import 'package:get/get.dart';
import 'package:infinity_scroll/event/infinite_scroll_event.dart';

class InfiniteScrollLogic<T> extends GetxController {
  late Rx<InfiniteScrollEvent?> dispatchEvent;
  late RxList<T> list;

  InfiniteScrollLogic() {
    _initValues();

    /// listen to the events
    dispatchEvent.listen(_handleEvents);
  }

  void _handleEvents(InfiniteScrollEvent? event) {
    switch (event.runtimeType) {
      case LoadMore:
        _loadMore((event as LoadMore).action);
        break;
      case OnRefresh:
        _onRefresh((event as OnRefresh).action);
        break;
    }
  }

  Future<void> _loadMore(OnLoadMoreList action) async {
    await action.call();
  }

  Future<void> _onRefresh(OnRefreshList action) async {
    _clearList();
    await action.call();
  }

  void _initValues() {
    dispatchEvent = (null as InfiniteScrollEvent?).obs;
    list = RxList.empty();
  }

  void _clearList() {
    list.clear();
  }
}
