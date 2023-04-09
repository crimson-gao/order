import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:smartlogger/smartlogger.dart';

class GoodsPage extends HookWidget {
  const GoodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Log.i('goods build');
    return const Text('Goods Page');
  }
}
