import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:order/dao/page.dart';
import 'package:order/dao/sqlite.dart';
import 'package:order/model/order.dart';
import 'package:sqflite/sqlite_api.dart';

class OrderDAO {
  // 查询订单，支持分页，按时间排序
  Future<List<Order>> queryOrders(Database db,
      {PageQuery pageQuery = const PageQuery()}) async {
    var result = await db.query(Order.tableName,
        orderBy: 'create_time',
        limit: pageQuery.limit,
        offset: pageQuery.offset);
    return Future.value(result.map(Order.fromMap).toList());
  }

  Future<Order?> queryOrderByID(Database db, int id) async {
    var result = await db.query(Order.tableName, where: 'id = $id');
    return result.isNotEmpty ? Order.fromMap(result.first) : null;
  }

  Future<int> insertOrder(Database db, Order order) async {
    return await db.insert(Order.tableName, order.toMap(withID: false));
  }

  Future<bool> deleteOrder(Database db, int id) async {
    return (await db.delete(Order.tableName, where: 'id = $id')) == 1;
  }

  Future<bool> updateOrder(Database db, Order order) async {
    return (await db.update(Order.tableName, order.toMap(withID: true),
            where: 'id = ${order.id}')) ==
        1;
  }
}

final orderProvider = StreamProvider.autoDispose<List<Order>>((ref) async* {
  final db = await ref.watch(dbProvider.future);
  var page = 0, offset = 0;
  const pageLimit = 20;
  final dao = OrderDAO();
  while (true) {
    final orders = await dao.queryOrders(db,
        pageQuery: PageQuery(offset: offset, limit: pageLimit));
    if (orders.isEmpty) {
      break;
    }
    yield orders;
    page++;
    offset += orders.length;
  }
});

class GoodsDAO {
  Future<List<Goods>> queryGoods(Database db,
      {PageQuery pageQuery = const PageQuery(), String? filterTag}) async {
    var result = await db.query(Goods.tableName,
        where: filterTag == null ? null : 'tag = $filterTag',
        orderBy: 'name',
        limit: pageQuery.limit,
        offset: pageQuery.offset);
    return Future.value(result.map(Goods.fromMap).toList());
  }

  Future<Goods?> queryGoodsByID(Database db, int id) async {
    var result = await db.query(Goods.tableName, where: 'id = $id');
    return result.isNotEmpty ? Goods.fromMap(result.first) : null;
  }

  Future<int> insertGoods(Database db, Goods goods) async {
    return await db.insert(Goods.tableName, goods.toMap(withID: false));
  }

  Future<bool> deleteGoods(Database db, int id) async {
    return (await db.delete(Goods.tableName, where: 'id = $id')) == 1;
  }

  Future<bool> updateGoods(Database db, Goods goods) async {
    return (await db.update(Goods.tableName, goods.toMap(withID: true),
            where: 'id = ${goods.id}')) ==
        1;
  }
}

class OrderItemDAO {
  // 已完成 未完成 过滤条件
  String toFilterStateWhere(OrderItemState? filterState) {
    if (filterState == null) return '';
    return 'AND ${OrderItem.tableName}.state = ${filterState.toInt()}';
  }

  // 按商品种类过滤
  String toFilterTagWhere(String? filterTag) {
    if (filterTag == null) return '';
    return 'AND ${Goods.tableName}.tag = $filterTag';
  }

  Future<List<OrderItem>> queryOrderItemByOrderID(Database db, int orderID,
      {String? filterTag, OrderItemState? filterState}) async {
    // 查询关联订单
    var order = await OrderDAO().queryOrderByID(db, orderID);
    if (order == null) return Future.value([]);

    // 关联查询 商品 与 订单项
    var result = await db.rawQuery('''
        SELECT ${OrderItem.tableName}.* , 
              ${Goods.tableName}.name, 
              ${Goods.tableName}.tag,
              ${Goods.tableName}.lastPrice,
              ${Goods.tableName}.unit
         FROM ${OrderItem.tableName} 
         INNER JOIN ${Goods.tableName} ON
            ${Goods.tableName}.id = ${OrderItem.tableName}.goods_id
         WHERE ${OrderItem.tableName}.order_id = $orderID 
            ${toFilterStateWhere(filterState)}
            ${toFilterTagWhere(filterTag)} ''');

    toOrderItem(Map<String, Object?> m) {
      Goods goods = Goods.fromMap(m, id: m['goods_id'] as int);
      return OrderItem.fromMap(m, order, goods);
    }

    return Future.value(result.map(toOrderItem).toList());
  }

  Future<OrderItem?> queryOrderItemByID(Database db, int id) async {
    var result = await db.query(OrderItem.tableName, where: 'id = $id');
    if (result.isEmpty) return Future.value(null);
    var item = result.first;

    // 查询关联订单
    var order = await OrderDAO().queryOrderByID(db, item['order_id'] as int);
    var goods = await GoodsDAO().queryGoodsByID(db, item['goods_id'] as int);
    if (order == null || goods == null) return Future.value(null);
    return Future.value(OrderItem.fromMap(item, order, goods));
  }

  Future<int> insertOrderItem(Database db, OrderItem item) async {
    return await db.insert(OrderItem.tableName, item.toMap(withID: false));
  }

  Future<bool> deleteOrderItem(Database db, int id) async {
    return (await db.delete(OrderItem.tableName, where: 'id = $id')) == 1;
  }

  Future<bool> updateOrderItem(Database db, OrderItem item) async {
    return (await db.update(OrderItem.tableName, item.toMap(withID: true),
            where: 'id = ${item.id}')) ==
        1;
  }
}
