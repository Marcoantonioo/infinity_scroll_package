library infinity_scroll;

import 'package:flutter/material.dart';
import 'package:infinity_scroll/event/infinity_scroll_event.dart';
import 'package:infinity_scroll/logic/infinity_scroll_logic.dart';

class InfinityScrollWidget<T> extends StatefulWidget {
  final List<T> list;
  final Widget Function(BuildContext context, T entry, int index) delegate;
  final OnLoadMoreList onLoadMore;
  final OnRefreshList? onRefresh;
  final bool reachMax;
  final bool isLoading;
  final Widget? customLoader;
  final Widget? customLoaderMore;
  final Widget? customEmptyList;
  final Widget? customReachMax;

  const InfinityScrollWidget({
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
  }) : super(key: key);

  @override
  State<InfinityScrollWidget<T>> createState() =>
      _InfinityScrollWidgetState<T>();
}

class _InfinityScrollWidgetState<T> extends State<InfinityScrollWidget<T>> {
  late ScrollController _scrollController;
  late InfinityScrollLogic _logic;

  @override
  void initState() {
    _logic = InfinityScrollLogic<T>();
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
      padding: const EdgeInsets.all(10.0),
      physics: const BouncingScrollPhysics(
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
