import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:simple_todo/scopedmodel/todo_list_model.dart';
import 'package:simple_todo/model/task_model.dart';
import 'package:simple_todo/component/iconpicker/icon_picker_builder.dart';
import 'package:simple_todo/component/colorpicker/color_picker_builder.dart';
import 'package:simple_todo/utils/color_utils.dart';
import 'package:simple_todo/utils/text_utils.dart';

class AddTaskScreen extends StatefulWidget {
  AddTaskScreen();

  @override
  State<StatefulWidget> createState() {
    return _AddTaskScreenState();
  }
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late String newTask;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late Color taskColor;
  late IconData taskIcon;

  @override
  void initState() {
    super.initState();
    newTask = '';
    taskColor = ColorUtils.defaultColors[0];
    taskIcon = Icons.work;
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
              '새 카테고리',
              style: tAppBarStyle,
            ),
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black26),
            brightness: Brightness.light,
            backgroundColor: Colors.white,
          ),
          body: Container(
            constraints: BoxConstraints.expand(),
            padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16.0,
                ),
                TextField(
                  onChanged: (text) {
                    setState(() => newTask = text);
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
                        onColorChanged: (newColor) =>
                            setState(() => taskColor = newColor)),
                    Container(
                      width: 22.0,
                    ),
                    IconPickerBuilder(
                        iconData: taskIcon,
                        highlightColor: taskColor,
                        action: (newIcon) =>
                            setState(() => taskIcon = newIcon)),
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
                  '카테고리 생성',
                  style: tButtonTextStyle,
                ),
                onPressed: () {
                  if (newTask.isEmpty) {
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
                    model.addTask(Task(newTask,
                        codePoint: taskIcon.codePoint, color: taskColor.value));
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
