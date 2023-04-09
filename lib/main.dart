import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smartlogger/smartlogger.dart';

import 'components/keep_alive.dart';
import 'pages/goods.dart';
import 'pages/orders.dart';

setupLogger() {}

void main() {
  setupLogger();
  // BrnInitializer.register(allThemeConfig:TestConfigUtils.defaultAllConfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrderApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProviderScope(child: MyHomePage(title: 'Crimson Order App')),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    final idx = useState<int>(0);
    final pageCtrl = usePageController();
    Log.i('myHomePage build');
    createNewOrder() {}
    onTap(int index) {
      if (index != idx.value) {
        idx.value = index;
        pageCtrl.animateToPage(index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.decelerate);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
          child: PageView(
              controller: pageCtrl,
              onPageChanged: (value) => idx.value = value,
              scrollDirection: Axis.horizontal,
              children: const [
            KeepAliveWrapper(child: OrdersPage()),
            KeepAliveWrapper(child: GoodsPage())
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewOrder,
        tooltip: 'NewOrder',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: idx.value,
          onTap: onTap,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Goods'),
          ]),
    );
  }
}
