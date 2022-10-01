import 'package:flutter/material.dart';
import 'package:infinity_scroll/event/infinite_scroll_event.dart';
import 'package:infinity_scroll/logic/infinite_scroll_logic.dart';

class InfiniteScrollWidget<T> extends StatefulWidget {
  final List<T> list;
  final Widget Function(BuildContext context, T entry, int index) delegate;
  final OnLoadMoreList onLoadMore;
  final OnRefreshList? onRefresh;
  final Widget? customLoader;
  final Widget? customLoaderMore;
  final Widget? customEmptyList;
  final Widget? customReachMax;
  final bool reachMax;
  final bool isLoading;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const InfiniteScrollWidget({
    Key? key,
    required this.list,
    required this.delegate,
    required this.onLoadMore,
    required this.reachMax,
    required this.isLoading,
    this.onRefresh,
    this.customLoader,
    this.customLoaderMore,
    this.customEmptyList,
    this.customReachMax,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  State<InfiniteScrollWidget<T>> createState() =>
      _InfiniteScrollWidgetState<T>();
}

class _InfiniteScrollWidgetState<T> extends State<InfiniteScrollWidget<T>> {
  late ScrollController _scrollController;
  late InfiniteScrollLogic _logic;

  @override
  void initState() {
    _logic = InfiniteScrollLogic<T>();
    _scrollController = ScrollController();
    _logic.list(widget.list);
    _initListener();

    super.initState();
  }

  void _initListener() {
    _scrollController.addListener(_onScrollListener);
  }

  void _onScrollListener() async {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!widget.reachMax) {
        _logic.dispatchEvent(
          LoadMore(action: widget.onLoadMore.call),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.onRefresh != null
        ? RefreshIndicator(
            child: _buildContent(),
            onRefresh: () async {
              _logic.dispatchEvent(
                OnRefresh(action: widget.onRefresh!),
              );
            },
          )
        : _buildContent();
  }

  Widget _buildContent() {
    return _logic.list.isEmpty && widget.isLoading
        ? _buildLoader()
        : _logic.list.isEmpty
            ? _buildEmptyList()
            : _buildList();
  }

  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      padding: const EdgeInsets.all(10.0),
      physics: widget.physics ??
          const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
      controller: _scrollController,
      itemCount: widget.list.length + 1,
      itemBuilder: (context, index) {
        if (widget.list.length != index) {
          return widget.delegate(context, widget.list[index], index);
        }
        return widget.list.isNotEmpty && widget.reachMax == false
            ? _buildLoaderMore()
            : _buildReachMax();
      },
    );
  }

  Widget _buildEmptyList() {
    return widget.customEmptyList ??
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text('Empty List'),
          ),
        );
  }

  Widget _buildReachMax() {
    return widget.customReachMax ??
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text('End of list'),
          ),
        );
  }

  Widget _buildLoaderMore() {
    return widget.customLoaderMore ??
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: CircularProgressIndicator(),
          ),
        );
  }

  Widget _buildLoader() {
    return widget.customLoader ??
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading...'),
            ],
          ),
        );
  }
}
