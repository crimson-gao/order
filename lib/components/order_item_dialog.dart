import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:order/model/order.dart';
import 'package:order/utils/string.dart';
import 'package:smartlogger/smartlogger.dart';

class MyInput extends StatelessWidget {
  final String title, unit;
  final double hint;
  final bool autoFocus;
  final void Function(String) onChange;
  const MyInput(this.title, this.unit, this.onChange,
      {this.autoFocus = false, this.hint = 1, super.key});

  @override
  Widget build(BuildContext context) {
    var hintText = shortString(hint);

    return Center(
      child: IntrinsicHeight(
          child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
                letterSpacing: 1, fontWeight: FontWeight.bold, fontSize: 25),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
          Row(children: [
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 120),
                child: IntrinsicWidth(
                    child: TextFormField(
                  autofocus: autoFocus,
                  initialValue: hintText,
                  onFieldSubmitted: (v) {
                    Log.i('fieldSubmit $v');
                  },
                  onEditingComplete: () {
                    Log.i('editComplete');
                  },
                  onChanged: (v) {
                    onChange(v);
                    Log.i('change $v');
                  },
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                  ],
                  style: const TextStyle(fontSize: 24),
                  decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12)),
                ))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
            Text(unit)
          ])
        ],
      )),
    );
  }
}

class OrderItemDialog extends HookWidget {
  final OrderItem order;

  const OrderItemDialog(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    // 理想状态下进货与预想的一致
    var modifiedOrderItem = useState(order.copyWith(
        realQuantity: order.wantQuantity, realPrice: order.goods.lastPrice));
    Log.i('saved state ${modifiedOrderItem.value.toString()}');
    onChangeRealQuantity(String v) {
      double? d = double.tryParse(v);
      if (d != null) {
        modifiedOrderItem.value =
            modifiedOrderItem.value.copyWith(realQuantity: d);
      }
    }

    onChangeRealPrice(String v) {
      double? d = double.tryParse(v);
      if (d != null) {
        modifiedOrderItem.value =
            modifiedOrderItem.value.copyWith(realPrice: d);
      }
    }

    onChangeWantQuantity(String v) {
      double? d = double.tryParse(v);
      if (d != null) {
        modifiedOrderItem.value =
            modifiedOrderItem.value.copyWith(wantQuantity: d);
      }
    }

    return SizedBox(
      height: 300,
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text(
                  '数量',
                  style: TextStyle(
                      letterSpacing: 5,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 30, maxWidth: 83),
                        child: IntrinsicWidth(
                            child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                          ],
                          decoration: InputDecoration(
                              hintText: shortString(order.wantQuantity),
                              isDense: true,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12)),
                        ))),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                    const Text('斤')
                  ],
                )
              ],
            ),
            Column(
              children: [
                const Text('最近价格',
                    style: TextStyle(
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Text(shortString(order.goods.lastPrice ?? 0)),
                      Text('元')
                    ],
                  ),
                )
              ],
            )
          ],
        ),
        Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              MyInput('进货数量', '斤', onChangeRealQuantity,
                  hint: order.wantQuantity, autoFocus: true),
              MyInput('进货价格', '元', onChangeRealPrice,
                  hint: order.goods.lastPrice ?? 0),
            ])),
        Container(
          padding: const EdgeInsets.all(10),
          child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: IconButton(
                  iconSize: 45,
                  color: Colors.white,
                  onPressed: () {},
                  icon: const Icon(Icons.done))),
        )
      ]),
    );
  }
}
