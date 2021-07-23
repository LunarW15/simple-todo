import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:simple_todo/scopedmodel/todo_list_model.dart';
import 'package:simple_todo/model/todo_model.dart';
import 'package:simple_todo/utils/color_utils.dart';
import 'package:simple_todo/component/todo_badge.dart';
import 'package:simple_todo/model/hero_id_model.dart';
import 'package:simple_todo/utils/text_utils.dart';

class AddTodoScreen extends StatefulWidget {
  final String taskId;
  final HeroId heroIds;

  AddTodoScreen({
    required this.taskId,
    required this.heroIds,
  });

  @override
  State<StatefulWidget> createState() {
    return _AddTodoScreenState();
  }
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  late String newTask;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    newTask = '';
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TodoListModel>(
      builder: (context, child, model) {
        if (model.tasks.isEmpty) {
          // Loading
          return Container(
            color: Colors.white,
          );
        }

        var _task = model.tasks.firstWhere((it) => it.id == widget.taskId);
        var _color = ColorUtils.getColorFrom(id: _task.color);
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              '새로운 할 일',
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
                Text(
                  '오늘은 어떤 계획이 있으신가요?',
                  style: tHowTextStyle,
                ),
                Container(
                  height: 16.0,
                ),
                TextField(
                  onChanged: (text) {
                    setState(() => newTask = text);
                  },
                  cursorColor: _color,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '할 일을 입력해 주세요!',
                    hintStyle: tHintTextStyle,
                  ),
                  style: tInputTextStyle,
                ),
                Container(
                  height: 26.0,
                ),
                Row(
                  children: [
                    TodoBadge(
                      codePoint: _task.codePoint,
                      color: _color,
                      id: widget.heroIds.codePointId,
                      size: 20.0,
                    ),
                    Container(
                      width: 16.0,
                    ),
                    Hero(
                      child: Text(
                        _task.name,
                        style: tTaskTextStyle,
                      ),
                      tag: "not_using_right_now", //widget.heroIds.titleId,
                    ),
                  ],
                )
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton.extended(
                heroTag: 'fab_new_task',
                icon: Icon(Icons.add),
                backgroundColor: _color,
                label: Text(
                  '추가',
                  style: tButtonTextStyle,
                ),
                onPressed: () {
                  if (newTask.isEmpty) {
                    final snackBar = SnackBar(
                      content: Text(
                        '내용을 입력해 주세요!',
                        style: tSnackBarTextStyle,
                      ),
                      backgroundColor: _color,
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                    // _scaffoldKey.currentState.showSnackBar(snackBar);
                  } else {
                    model.addTodo(Todo(
                      newTask,
                      parent: _task.id,
                    ));
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
