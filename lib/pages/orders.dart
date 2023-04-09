import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:order/components/group.dart';
import 'package:order/dao/order.dart';
import 'package:order/model/order.dart';
import 'package:smartlogger/smartlogger.dart';

import 'order.dart';

// 跳转进入新界面
onTapOrder(BuildContext context, Order order) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => OrderPage(order)),
  );
}

/// List item for an order.
class OrderItem extends StatelessWidget {
  final Order order;
  const OrderItem(
    this.order, {
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    onTapItem() {
      onTapOrder(context, order);
    }

    return InkWell(
        child: ListTile(
      title: Text(order.title),
      subtitle: Text(order.subtitle ?? ''),
      onTap: onTapItem,
    ));
  }
}

/// Multiple order list item.
class GroupList extends StatelessWidget {
  final List<Order> orders;
  const GroupList(this.orders, {super.key});

  Widget orderBuilder(BuildContext context, Order order) {
    return OrderItem(order);
  }

  @override
  Widget build(BuildContext context) {
    var orderList = toGroupWidget<Order>(orders, context, orderBuilder);
    return Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: orderList,
        ));
  }
}

/// Contains an GroupList and a GroupTitle.
class OrderGroup extends StatelessWidget {
  final List<Order> orders;
  final String title;

  const OrderGroup(this.title, this.orders, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [GroupTitle(title), GroupList(orders)],
    );
  }
}

class OrdersPage extends HookConsumerWidget {
  const OrdersPage({super.key});
  Order randMockOrder() {
    return Order(Random().nextInt(999), 'title');
  }

  List<OrderGroup> groupBy(List<Order> orders) {
    Map<String, List<Order>> groups = SplayTreeMap();
    dayFormat(DateTime t) {
      return '${t.year}年${t.month}月${t.day}';
    }

    for (var o in orders) {
      var d = dayFormat(DateTime.fromMillisecondsSinceEpoch(o.createTime));
      if (groups.containsKey(d)) {
        groups[d]!.add(o);
      } else {
        groups[d] = [o];
      }
    }
    List<OrderGroup> result = [];
    var now = DateTime.now();
    final today = dayFormat(now),
        yesterday = dayFormat(now.subtract(const Duration(days: 1)));
    shortTime(String d) {
      if (d == today) {
        return '今天';
      } else if (d == yesterday) {
        return '昨天';
      } else {
        return d;
      }
    }

    groups.forEach((key, value) {
      result.add(OrderGroup(shortTime(key), value));
    });
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Log.i('OrdersPage build');
    final orders = ref.watch(orderProvider);
    return orders.when(
        loading: () => Center(child: Text('loading')),
        error: (e, st) => Center(
              child: Text('$e \n$st'),
            ),
        data: (data) {
          var groups = groupBy(data);
          return Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration:
                  const BoxDecoration(color: Color.fromARGB(85, 158, 158, 158)),
              child: ListView(
                children: groups,
              ));
        });
  }
}
