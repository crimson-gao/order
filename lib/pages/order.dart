import 'dart:math';

import 'package:bruno/bruno.dart';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:order/components/delete_order_action.dart';
import 'package:order/components/group.dart';
import 'package:order/components/order_item_dialog.dart';
import 'package:order/model/order.dart';
import 'package:smartlogger/smartlogger.dart';

typedef OrderItemBuilder = Widget Function(BuildContext, OrderItem);

class GroupList extends HookWidget {
  final List<OrderItem> orders;
  final OrderItemBuilder itemBuilder;
  const GroupList(this.orders, this.itemBuilder, {super.key});

  @override
  Widget build(BuildContext context) {
    var orderList = toGroupWidget<OrderItem>(orders, context, itemBuilder);
    return Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: orderList,
        ));
  }
}

class DisplayGroup extends HookWidget {
  final String groupTag;
  final List<OrderItem> orders;
  final OrderItemBuilder itemBuilder;

  const DisplayGroup(this.groupTag, this.orders, this.itemBuilder, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [GroupTitle(groupTag), GroupList(orders, itemBuilder)],
    );
  }
}

class OrderView extends HookWidget {
  final List<OrderItem> orders;
  final bool doneStyle;
  const OrderView(this.orders, this.doneStyle, {super.key});

  Widget finishedBuilder(BuildContext context, OrderItem order) {
    return const Text('done');
  }

  Widget unfinishedBuilder(BuildContext context, OrderItem order) {
    return InkWell(
        onTap: () async {
          await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: Center(
                        child: Text(
                      order.goods.name,
                      style: TextStyle(fontSize: 26),
                    )),
                    content: OrderItemDialog(order));
              }).then((value) => null);
        },
        child: Text(order.goods.name));
  }

  @override
  Widget build(BuildContext context) {
    var groups = groupBy(orders, (OrderItem order) => order.goods.tag);
    var builder = doneStyle ? finishedBuilder : unfinishedBuilder;
    var groupsView = groups
        .map((key, value) => MapEntry(key, DisplayGroup(key, value, builder)))
        .values
        .toList();
    return ListView(
      children: groupsView,
    );
  }
}

final orderItemStateProvider =
    StateNotifierProvider<OrderItemNotifier, OrderItem>((ref) =>
        OrderItemNotifier(
            OrderItem(0, Order(0, 'init'), Goods(0, 'init', '个', 'Other'))));

class OrderPage extends HookWidget {
  final Order order;
  const OrderPage(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    var tabs = <BadgeTab>[BadgeTab(text: '待进货'), BadgeTab(text: '已进货')];
    final tabCtrl = useTabController(initialLength: tabs.length);
    final pageCtrl = usePageController();

    onTapTab(state, index) {
      Log.i('onTap tab to $index');
      pageCtrl.animateToPage(index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.decelerate);
    }

    onPageChanged(int page) {
      if (tabCtrl.index != page) {
        tabCtrl.animateTo(page);
      }
    }

    var rand = Random();
    randGoods() {
      var options = [
        Goods(1, '苹果', '斤', '水果', lastPrice: 3),
        Goods(2, '梨子', '斤', '水果', lastPrice: 2),
        Goods(3, '香蕉', '箱', '水果', lastPrice: 3),
        Goods(4, '藕', '斤', '蔬菜', lastPrice: 2),
        Goods(5, '鱼', '斤', '鱼肉', lastPrice: 9.2),
        Goods(8, '酱油', '瓶', '调味', lastPrice: 3),
        Goods(9, '生抽', '瓶', '调味', lastPrice: 4.2),
      ];
      return options[rand.nextInt(options.length)];
    }

    randOrderItem() {
      var order = Order(1, 'first');
      return OrderItem(
        9,
        order,
        randGoods(),
        state: OrderItemState.fromInt(rand.nextInt(2)),
        wantQuantity: rand.nextDouble() * 10,
        realPrice: rand.nextDouble() * 10,
        realQuantity: rand.nextDouble() * 10,
      );
    }

    // todo: 查询订单选项
    List<OrderItem> orderItems = [
      randOrderItem(),
      randOrderItem(),
      randOrderItem(),
      randOrderItem(),
      randOrderItem(),
      randOrderItem(),
      randOrderItem(),
      randOrderItem(),
      randOrderItem(),
      randOrderItem(),
      randOrderItem(),
    ];

    List<OrderItem> finishedOrderItems = [], unfinishedOrderItems = [];
    for (var order in orderItems) {
      if (order.state == OrderItemState.finished) {
        finishedOrderItems.add(order);
      } else {
        unfinishedOrderItems.add(order);
      }
    }

    return Scaffold(
        appBar: BrnAppBar(
            //默认显示返回按钮
            automaticallyImplyLeading: true,
            title: order.title,
            //自定义的右侧文本
            actions: const DeleteOrderAction()),
        body: Column(
          children: [
            BrnTabBar(onTap: onTapTab, controller: tabCtrl, tabs: tabs),
            Expanded(
                child: PageView(
              controller: pageCtrl,
              onPageChanged: onPageChanged,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                OrderView(unfinishedOrderItems, false),
                OrderView(finishedOrderItems, true)
              ],
            )),
          ],
        ));
  }
}
