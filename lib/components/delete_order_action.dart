import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';

class DeleteOrderAction extends StatelessWidget {
  const DeleteOrderAction({super.key});

  @override
  Widget build(BuildContext context) {
    return BrnTextAction(
      '删除',
      iconPressed: () {
        BrnDialogManager.showConfirmDialog(context,
            title: "删除进货单",
            cancel: '取消',
            confirm: '确认',
            message: "确定要删除此进货单吗", onConfirm: () {
          // todo: 删除 dao
          BrnToast.show("确定", context);
          Navigator.pop(context);
        }, onCancel: () {
          Navigator.pop(context);
        });
      },
    );
  }
}
