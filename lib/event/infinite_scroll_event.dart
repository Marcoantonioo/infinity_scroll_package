typedef OnLoadMoreList = Function;
typedef OnRefreshList = Future<void> Function();

abstract class InfiniteScrollEvent {
  const InfiniteScrollEvent._();
}

class LoadMore implements InfiniteScrollEvent {
  final OnLoadMoreList action;
  LoadMore({
    required this.action,
  });
}

class OnRefresh implements InfiniteScrollEvent {
  final OnRefreshList action;
  OnRefresh({
    required this.action,
  });
}
