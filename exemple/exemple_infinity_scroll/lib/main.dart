import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinity_scroll/widget/infinite_scroll_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<MyEntity> list = [];
  bool isLoading = true;
  bool reachMax = false;

  Future<void> _fetchList() async {
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      list.addAll(List.generate(
          10, (index) => MyEntity('Title$index', 'Description$index')));
      isLoading = false;
      reachMax = Random().nextBool();
    });
  }

  Future<void> _loadMore() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      list.addAll(List.generate(
          10, (index) => MyEntity('Title$index', 'Description$index')));
      isLoading = false;
      reachMax = Random().nextBool();
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      list.clear();
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      list.addAll(List.generate(
          10, (index) => MyEntity('Title$index', 'Description$index')));
      isLoading = false;
      reachMax = Random().nextBool();
    });
  }

  @override
  void initState() {
    _fetchList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: InfiniteScrollWidget<MyEntity>(
        list: list,
        delegate: (context, item, index) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title),
              const SizedBox(height: 6.0),
              Text(item.description),
            ],
          ),
        ),
        onLoadMore: () async {
          await _loadMore();
        },
        onRefresh: () async {
          await _onRefresh();
        },
        reachMax: reachMax,
        isLoading: isLoading,
      ),
    );
  }
}

class MyEntity {
  String title;
  String description;

  MyEntity(
    this.title,
    this.description,
  );
}
