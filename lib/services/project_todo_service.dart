import 'package:flutter/foundation.dart';

import '../models/access_control.dart';

class ProjectTodoItem {
  final String id;
  final String orderNo;
  final String projectName;
  final String stage;
  final String assignee;
  final String task;
  final String createdBy;
  final String createdAt;
  final RobinBusinessDivision division;

  const ProjectTodoItem({
    required this.id,
    required this.orderNo,
    required this.projectName,
    required this.stage,
    required this.assignee,
    required this.task,
    required this.createdBy,
    required this.createdAt,
    this.division = RobinBusinessDivision.robot,
  });
}

final ValueNotifier<List<ProjectTodoItem>> projectTodoItems =
    ValueNotifier<List<ProjectTodoItem>>(<ProjectTodoItem>[]);

void addProjectTodo(ProjectTodoItem item) {
  projectTodoItems.value = [item, ...projectTodoItems.value];
}
