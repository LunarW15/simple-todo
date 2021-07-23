import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:simple_todo/scopedmodel/todo_list_model.dart';
import 'package:simple_todo/gradient_background.dart';
import 'package:simple_todo/task_progress_indicator.dart';
import 'package:simple_todo/page/add_task_screen.dart';
import 'package:simple_todo/model/hero_id_model.dart';
import 'package:simple_todo/model/task_model.dart';
import 'package:simple_todo/route/scale_route.dart';
import 'package:simple_todo/utils/color_utils.dart';
import 'package:simple_todo/utils/datetime_utils.dart';
import 'package:simple_todo/page/detail_screen.dart';
import 'package:simple_todo/component/todo_badge.dart';
import 'package:simple_todo/utils/text_utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var app = MaterialApp(
      title: 'Simple Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: ''),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('ko', 'KR')],
      locale: const Locale('ko', 'KR'),
    );

    return ScopedModel<TodoListModel>(
      model: TodoListModel(),
      child: app,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  HeroId _generateHeroIds(Task task) {
    return HeroId(
      codePointId: 'code_point_id_${task.id}',
      progressId: 'progress_id_${task.id}',
      titleId: 'title_id_${task.id}',
      remainingTaskId: 'remaining_task_id_${task.id}',
    );
  }

  String currentDay(BuildContext context) {
    return DateTimeUtils.currentDay;
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TodoListModel>(
        builder: (context, child, model) {
      var _isLoading = model.isLoading;
      var _tasks = model.tasks;
      var _todos = model.todos;
      var backgroundColor = _tasks.isEmpty || _tasks.length == _currentPageIndex
          ? Colors.blueGrey
          : ColorUtils.getColorFrom(id: _tasks[_currentPageIndex].color);
      if (!_isLoading) {
        // move the animation value towards upperbound only when loading is complete
        _controller.forward();
      }
      return GradientBackground(
        color: backgroundColor,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(widget.title),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1.0,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : FadeTransition(
                  opacity: _animation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 0.0, left: 56.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${DateTimeUtils.currentMonth} ${DateTimeUtils.currentDate}',
                              style: tHeadTextStyle,
                            ),
                            Container(
                              // margin: EdgeInsets.only(top: 22.0),
                              child: Text(
                                '${widget.currentDay(context)}',
                                style: tHeadTextStyle,
                              ),
                            ),
                            Container(height: 16.0),
                            _todos
                                        .where((todo) => todo.isCompleted == 0)
                                        .length ==
                                    0
                                ? Container()
                                : Text(
                                    '아직 ${_todos.where((todo) => todo.isCompleted == 0).length}개의 할 일이 남아있어요!',
                                    style: tTaskRemainTextStyle),
                            Container(
                              height: 16.0,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        key: _backdropKey,
                        flex: 1,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is ScrollEndNotification) {
                              print(
                                  "ScrollNotification = ${_pageController.page}");
                              var currentPage =
                                  _pageController.page?.round().toInt() ?? 0;
                              if (_currentPageIndex != currentPage) {
                                setState(() => _currentPageIndex = currentPage);
                              }
                            }
                            return true;
                          },
                          child: PageView.builder(
                            controller: _pageController,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == _tasks.length) {
                                return AddPageCard(
                                  color: Colors.blueGrey,
                                );
                              } else {
                                return TaskCard(
                                  backdropKey: _backdropKey,
                                  color: ColorUtils.getColorFrom(
                                      id: _tasks[index].color),
                                  getHeroIds: widget._generateHeroIds,
                                  getTaskCompletionPercent:
                                      model.getTaskCompletionPercent,
                                  getTotalTodos: model.getTotalTodosFrom,
                                  task: _tasks[index],
                                );
                              }
                            },
                            itemCount: _tasks.length + 1,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 32.0),
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AddPageCard extends StatelessWidget {
  final Color color;

  const AddPageCard({Key? key, this.color = Colors.black}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTaskScreen(),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 52.0,
                  color: color,
                ),
                Container(
                  height: 8.0,
                ),
                Text(
                  '카테고리 추가',
                  style: TextStyle(
                    color: color,
                    fontFamily: 'Nanum Gothic Bold',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

typedef TaskGetter<T, V> = V Function(T value);

class TaskCard extends StatelessWidget {
  final GlobalKey backdropKey;
  final Task task;
  final Color color;

  final TaskGetter<Task, int> getTotalTodos;
  final TaskGetter<Task, HeroId> getHeroIds;
  final TaskGetter<Task, int> getTaskCompletionPercent;

  TaskCard({
    required this.backdropKey,
    required this.color,
    required this.task,
    required this.getTotalTodos,
    required this.getHeroIds,
    required this.getTaskCompletionPercent,
  });

  @override
  Widget build(BuildContext context) {
    var heroIds = getHeroIds(task);

    return ScopedModelDescendant<TodoListModel>(
      builder: (context, child, model) {
        var _todos = model.todos.where((it) => it.parent == task.id).toList();

        return GestureDetector(
          onTap: () {
            final RenderBox? renderBox =
                backdropKey.currentContext?.findRenderObject() as RenderBox;
            var backDropHeight = renderBox?.size.height ?? 0;
            var bottomOffset = 60.0;
            var horizontalOffset = 52.0;
            var topOffset = MediaQuery.of(context).size.height - backDropHeight;

            var rect = RelativeRect.fromLTRB(
                horizontalOffset, topOffset, horizontalOffset, bottomOffset);
            Navigator.push(
              context,
              ScaleRoute(
                rect: rect,
                widget: DetailScreen(
                  taskId: task.id,
                  heroIds: heroIds,
                ),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 4.0,
            margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TodoBadge(
                    id: heroIds.codePointId,
                    codePoint: task.codePoint,
                    color: ColorUtils.getColorFrom(
                      id: task.color,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 4.0),
                    child: Hero(
                      tag: heroIds.remainingTaskId,
                      child: Text(
                        getTotalTodos(task) == 0
                            ? "할 일 없음"
                            : "${getTotalTodos(task)}개의 할 일",
                        style: tTaskTextStyle,
                      ),
                    ),
                  ),
                  Container(
                    child: Hero(
                      tag: heroIds.titleId,
                      child: Text(task.name, style: tTitleTextStyle),
                    ),
                  ),
                  Container(
                    height: 250,
                    margin: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        if (index == _todos.length) {
                          return SizedBox(
                            height: 32,
                          );
                        }
                        var todo = _todos[index];
                        return Container(
                          child: ListTile(
                            onTap: () => model.updateTodo(todo.copy(
                                isCompleted: todo.isCompleted == 1 ? 0 : 1)),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 8.0),
                            leading: Checkbox(
                                activeColor: color,
                                onChanged: (value) => model.updateTodo(todo
                                    .copy(isCompleted: value == true ? 1 : 0)),
                                value: todo.isCompleted == 1 ? true : false),
                            title: Text(
                              todo.name,
                              style: TextStyle(
                                fontFamily: 'Nanum Gothic Bold',
                                fontSize: 14.0,
                                color: Colors.black54,
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
                  Hero(
                    tag: heroIds.progressId,
                    child: TaskProgressIndicator(
                      color: color,
                      progress: getTaskCompletionPercent(task),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
