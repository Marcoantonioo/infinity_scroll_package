typedef OnLoadMoreList = Function;
typedef OnRefreshList = Future<void> Function();

abstract class InfinityScrollEvent {
  const InfinityScrollEvent._();
}

class LoadMore implements InfinityScrollEvent {
  final OnLoadMoreList action;
  LoadMore({
    required this.action,
  });
}

class OnRefresh implements InfinityScrollEvent {
  final OnRefreshList action;
  OnRefresh({
    required this.action,
  });
}
