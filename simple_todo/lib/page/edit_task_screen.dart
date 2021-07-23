import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:simple_todo/scopedmodel/todo_list_model.dart';
import 'package:simple_todo/model/task_model.dart';
import 'package:simple_todo/component/iconpicker/icon_picker_builder.dart';
import 'package:simple_todo/component/colorpicker/color_picker_builder.dart';
import 'package:simple_todo/utils/text_utils.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;
  final String taskName;
  final Color color;
  final IconData icon;

  EditTaskScreen({
    required this.taskId,
    required this.taskName,
    required this.color,
    required this.icon,
  });

  @override
  State<StatefulWidget> createState() {
    return _EditCardScreenState();
  }
}

class _EditCardScreenState extends State<EditTaskScreen> {
  late String taskName;
  late Color taskColor;
  late IconData taskIcon;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    taskName = widget.taskName;
    taskColor = widget.color;
    taskIcon = widget.icon;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TodoListModel>(
      builder: (context, child, model) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              '카테고리 수정',
              style: tAppBarStyle,
            ),
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black26,
            ),
            brightness: Brightness.light,
            backgroundColor: Colors.white,
          ),
          body: Container(
            constraints: BoxConstraints.expand(),
            padding: EdgeInsets.symmetric(
              horizontal: 36.0,
              vertical: 36.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16.0,
                ),
                TextFormField(
                  initialValue: taskName,
                  onChanged: (text) {
                    setState(
                      () => taskName = text,
                    );
                  },
                  cursorColor: taskColor,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '카테고리명',
                    hintStyle: tHintTextStyle,
                  ),
                  style: tInputTextStyle,
                ),
                Container(
                  height: 26.0,
                ),
                Row(
                  children: [
                    ColorPickerBuilder(
                      color: taskColor,
                      onColorChanged: (newColor) => setState(
                        () => taskColor = newColor,
                      ),
                    ),
                    Container(
                      width: 22.0,
                    ),
                    IconPickerBuilder(
                      iconData: taskIcon,
                      highlightColor: taskColor,
                      action: (newIcon) => setState(
                        () => taskIcon = newIcon,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton.extended(
                heroTag: 'fab_new_card',
                icon: Icon(Icons.save),
                backgroundColor: taskColor,
                label: Text(
                  "저장",
                  style: tButtonTextStyle,
                ),
                onPressed: () {
                  if (taskName.isEmpty) {
                    final snackBar = SnackBar(
                      content: Text(
                        '내용을 입력해 주세요!',
                        style: tSnackBarTextStyle,
                      ),
                      backgroundColor: taskColor,
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                    // _scaffoldKey.currentState.showSnackBar(snackBar);
                  } else {
                    model.updateTask(
                      Task(
                        taskName,
                        codePoint: taskIcon.codePoint,
                        color: taskColor.value,
                        id: widget.taskId,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
