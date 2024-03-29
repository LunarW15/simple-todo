import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:simple_todo/scopedmodel/todo_list_model.dart';
import 'package:simple_todo/task_progress_indicator.dart';
import 'package:simple_todo/component/todo_badge.dart';
import 'package:simple_todo/model/hero_id_model.dart';
import 'package:simple_todo/model/task_model.dart';
import 'package:simple_todo/utils/color_utils.dart';
import 'package:simple_todo/page/add_todo_screen.dart';
import 'package:simple_todo/page/edit_task_screen.dart';
import 'package:simple_todo/utils/text_utils.dart';

class DetailScreen extends StatefulWidget {
  final String taskId;
  final HeroId heroIds;

  DetailScreen({
    required this.taskId,
    required this.heroIds,
  });

  @override
  State<StatefulWidget> createState() {
    return _DetailScreenState();
  }
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(begin: Offset(0, 1.0), end: Offset(0.0, 0.0))
        .animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return ScopedModelDescendant<TodoListModel>(
      builder: (context, child, model) {
        Task _task;

        try {
          _task = model.tasks.firstWhere((it) => it.id == widget.taskId);
        } catch (e) {
          return Container(
            color: Colors.white,
          );
        }

        var _todos =
            model.todos.where((it) => it.parent == widget.taskId).toList();
        var _hero = widget.heroIds;
        var _color = ColorUtils.getMaterialColorFrom(id: _task.color);
        var _icon = IconData(_task.codePoint, fontFamily: 'MaterialIcons');

        return Theme(
          data: ThemeData(primarySwatch: _color),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black26),
              brightness: Brightness.light,
              backgroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  color: _color,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTaskScreen(
                          taskId: _task.id,
                          taskName: _task.name,
                          icon: _icon,
                          color: _color,
                        ),
                      ),
                    );
                  },
                ),
                SimpleAlertDialog(
                  color: _color,
                  onActionPressed: () => model.removeTask(_task),
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
              child: Column(children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 36.0, vertical: 0.0),
                  height: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TodoBadge(
                        color: _color,
                        codePoint: _task.codePoint,
                        id: _hero.codePointId,
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 4.0),
                        child: Hero(
                          tag: _hero.remainingTaskId,
                          child: Text(
                            model.getTotalTodosFrom(_task) == 0
                                ? "할 일 없음"
                                : "${model.getTotalTodosFrom(_task)}개의 할 일",
                            style: tTaskTextStyle,
                          ),
                        ),
                      ),
                      Container(
                        child: Hero(
                          tag: 'title_hero_unused',
                          child: Text(_task.name, style: tTitleTextStyle),
                        ),
                      ),
                      Spacer(),
                      Hero(
                        tag: _hero.progressId,
                        child: TaskProgressIndicator(
                          color: _color,
                          progress: model.getTaskCompletionPercent(_task),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        if (index == _todos.length) {
                          return SizedBox(
                            height: 56, // size of FAB
                          );
                        }
                        var todo = _todos[index];
                        return Container(
                          padding: EdgeInsets.only(left: 22.0, right: 22.0),
                          child: ListTile(
                            onTap: () => model.updateTodo(todo.copy(
                                isCompleted: todo.isCompleted == 1 ? 0 : 1)),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 8.0),
                            leading: Checkbox(
                                activeColor: _color,
                                onChanged: (value) => model.updateTodo(todo
                                    .copy(isCompleted: value == true ? 1 : 0)),
                                value: todo.isCompleted == 1 ? true : false),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline),
                              onPressed: () => model.removeTodo(todo),
                            ),
                            title: Text(
                              todo.name,
                              style: TextStyle(
                                fontFamily: 'Nanum Gothic Bold',
                                fontSize: 18.0,
                                color: todo.isCompleted == 1
                                    ? _color
                                    : Colors.black54,
                                decoration: todo.isCompleted == 1
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: _todos.length + 1,
                    ),
                  ),
                ),
              ]),
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'fab_new_task',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddTodoScreen(taskId: widget.taskId, heroIds: _hero),
                  ),
                );
              },
              tooltip: '새로운 할 일',
              backgroundColor: _color,
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

typedef void Callback();

class SimpleAlertDialog extends StatelessWidget {
  final Color color;
  final Callback onActionPressed;

  SimpleAlertDialog({
    required this.color,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: color,
      icon: Icon(Icons.delete),
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('이 카테고리 카드를 삭제하시겠어요?'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      '이 카테고리 카드를 삭제하면 여기에 등록된 모든 할 일 목록들도 함께 삭제됩니다',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('삭제'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    onActionPressed();
                  },
                ),
                FlatButton(
                  child: Text('취소'),
                  textColor: Colors.grey,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
