import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Order {
  int id;
  String title;
  late int createTime;
  String? subtitle;

  Order(this.id, this.title, {this.subtitle, int? createTime}) {
    if (createTime == null) {
      this.createTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Order copyWith({int? id, String? title, String? subtitle, int? createTime}) {
    return Order(id ?? this.id, title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        createTime: createTime ?? this.createTime);
  }

  Order.fromMap(Map m)
      : this(m['id'], m['title'],
            createTime: m['createTime'], subtitle: m['subtitle']);

  Map<String, Object?> toMap({bool withID = false}) {
    var map = <String, Object?>{
      'title': title,
      'createTime': createTime,
      'subtitle': subtitle
    };
    if (withID) {
      map['id'] = id;
    }
    return map;
  }

  static String get tableName => 'Order';

  static String get createTableSql => '''
        CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,   
        title VARCHAR(40) NOT NULL,
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        subtitle VARCHAR(80))
  ''';
}

class Goods {
  int id;
  String tag, name, unit;
  double? lastPrice;

  Goods(this.id, this.name, this.unit, this.tag, {this.lastPrice});
  Goods copyWith(
      {int? id, String? name, String? unit, String? tag, double? lastPrice}) {
    return Goods(
        id ?? this.id, name ?? this.name, unit ?? this.unit, tag ?? this.tag,
        lastPrice: lastPrice ?? this.lastPrice);
  }

  Goods.fromMap(Map m, {int? id})
      : this(id ?? m['id'], m['name'], m['unit'], m['tag'],
            lastPrice: m['lastPrice']);
  Map<String, Object?> toMap({bool withID = false}) {
    var map = <String, Object?>{
      'name': name,
      'unit': unit,
      'tag': tag,
      'lastPrice': lastPrice
    };
    if (withID) {
      map['id'] = id;
    }
    return map;
  }

  static String get tableName => 'Goods';

  static String get createTableSql => '''
        CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(40) NOT NULL,
        tag VARCHAR(40) NOT NULL,
        unit VARCHAR(5) NOT NULL,
        last_price REAL)
  ''';
}

enum OrderItemState {
  unfinished,
  finished,
  unknown;

  factory OrderItemState.fromInt(int state) {
    switch (state) {
      case 0:
        return OrderItemState.unfinished;
      case 1:
        return OrderItemState.finished;
      default:
        return OrderItemState.unknown;
    }
  }
  int toInt() {
    switch (this) {
      case OrderItemState.unfinished:
        return 0;
      case OrderItemState.finished:
        return 1;
      case OrderItemState.unknown:
        return 2;
    }
  }
}

class OrderItem {
  int id;
  OrderItemState state;
  double wantQuantity, realQuantity, realPrice;
  Order order;
  Goods goods;

  static String get tableName => 'OrderItem';

  static String get createTableSql => '''
        CREATE TABLE $tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          state INTEGER NOT NULL,
          order_id INTEGER NOT NULL,
          goods_id INTEGER NOT NULL,
          want_quantity REAL NOT NULL,
          real_quantity REAL,
          real_price REAL,
          # 外键 order_id
          CONSTRAINT fk_order  
          FOREIGN KEY (order_id)  
          REFERENCES ${Order.tableName}(id), 
          # 外键 goods_id
          CONSTRAINT fk_goods  
          FOREIGN KEY (goods_id)  
          REFERENCES ${Goods.tableName}(id)    
        )
  ''';

  @override
  String toString() {
    return '${goods.name} : $realQuantity / $wantQuantity @ $realPrice';
  }

  OrderItem(this.id, this.order, this.goods,
      {this.state = OrderItemState.unfinished,
      this.realPrice = 0,
      this.realQuantity = 0,
      this.wantQuantity = 0});
  OrderItem copyWith(
      {int? id,
      String? tag,
      OrderItemState? state,
      Goods? goods,
      Order? order,
      double? realPrice,
      double? realQuantity,
      double? wantQuantity}) {
    return OrderItem(id ?? this.id, order ?? this.order, goods ?? this.goods,
        state: state ?? this.state,
        realPrice: realPrice ?? this.realPrice,
        realQuantity: realQuantity ?? this.realQuantity,
        wantQuantity: wantQuantity ?? this.wantQuantity);
  }

// 需要关联查询
  OrderItem.fromMap(Map m, Order order, Goods goods)
      : this(m['id'], order, goods,
            state: OrderItemState.fromInt(m['state']),
            realQuantity: m['realQuantity'],
            realPrice: m['realPrice'],
            wantQuantity: m['wantQuantity']);

  Map<String, Object?> toMap({bool withID = false}) {
    var map = <String, Object?>{
      'order_id': order.id,
      'goods_id': goods.id,
      'state': state.toInt(),
      'realQuantity': realQuantity,
      'realPrice': realPrice,
      'wantQuantity': wantQuantity
    };
    if (withID) {
      map['id'] = id;
    }
    return map;
  }
}

// class OrderItemNotifier extends StateNotifier<Map<int, List<OrderItem>>> {
//   OrderItemNotifier() : super({});
//   void updateOrderItems(int order_id, List<OrderItem> items) {
//     var newObj = {...state};
//     newObj[order_id] = items;
//     state = newObj;
//   }
//   //void updateOrderItem(int order_id, )
// }

// map id ->
class OrdersNotifier extends StateNotifier<Map<int, Order>> {
  OrdersNotifier() : super({});
  void updateOrders(List<Order> orders) {
    var newObj = {...state};
    for (var g in orders) {
      newObj[g.id] = g;
    }
    state = newObj;
  }

  void deleteOrder(int id) {
    var newObj = {...state};
    newObj.remove(id);
    state = newObj;
  }
}

// map goods_id -> goods
class GoodsNotifier extends StateNotifier<Map<int, Goods>> {
  GoodsNotifier() : super({});
  void updateGoods(List<Goods> goods) {
    var newObj = {...state};
    for (var g in goods) {
      newObj[g.id] = g;
    }
    state = newObj;
  }
}

class OrderItemNotifier extends StateNotifier<OrderItem> {
  OrderItemNotifier(super.state);
  void changeRealQuantity(double r) {
    state = state.copyWith(realQuantity: r);
  }

  void changeRealPrice(double r) {
    state = state.copyWith(realPrice: r);
  }

  void changeWantQuantity(double r) {
    state = state.copyWith(wantQuantity: r);
  }
}
