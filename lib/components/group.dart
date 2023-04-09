import 'package:flutter/material.dart';

class GroupTitle extends StatelessWidget {
  final String title;
  const GroupTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}

List<Widget> toGroupWidget<T>(List<T> items, BuildContext context,
    Widget Function(BuildContext, T) builder) {
  List<Widget> itemList = [];
  for (T item in items) {
    itemList.add(builder(context, item));
    itemList.add(const Divider(
      height: 1,
    ));
  }
  if (itemList.isNotEmpty) {
    itemList.removeLast();
  }
  return itemList;
}
