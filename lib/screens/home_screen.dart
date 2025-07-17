import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';
import '../widgets/task_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/priority_chip.dart';
import '../widgets/celebration_widget.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'pomodoro_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  final void Function(ThemeMode)? onThemeModeChanged;
  final ThemeMode? currentThemeMode;
  const HomeScreen({Key? key, this.onThemeModeChanged, this.currentThemeMode}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showStats = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: Image.asset('assets/icons/timer.png', width: 22, height: 22),
            tooltip: 'Pomodoro Timer',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PomodoroScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Image.asset('assets/icons/app_icon_192.png', width: 22, height: 22),
            tooltip: 'Update Home Widget',
            onPressed: () async {
              final todoProvider = context.read<TodoProvider>();
              await updateHomeWidget(todoProvider.totalTodos);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Home widget updated!')),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              final provider = context.read<TodoProvider>();
              switch (value) {
                case 'all':
                  provider.clearFilters();
                  break;
                case 'completed':
                  provider.filterByCompleted(true);
                  break;
                case 'pending':
                  provider.filterByCompleted(false);
                  break;
                case 'theme_light':
                  widget.onThemeModeChanged?.call(ThemeMode.light);
                  break;
                case 'theme_dark':
                  widget.onThemeModeChanged?.call(ThemeMode.dark);
                  break;
                case 'theme_system':
                  widget.onThemeModeChanged?.call(ThemeMode.system);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Tasks'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('Pending Tasks'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Completed Tasks'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'theme_light',
                child: Row(
                  children: [
                    Icon(Icons.light_mode, color: widget.currentThemeMode == ThemeMode.light ? Theme.of(context).colorScheme.primary : null),
                    const SizedBox(width: 8),
                    const Text('Light Mode'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'theme_dark',
                child: Row(
                  children: [
                    Icon(Icons.dark_mode, color: widget.currentThemeMode == ThemeMode.dark ? Theme.of(context).colorScheme.primary : null),
                    const SizedBox(width: 8),
                    const Text('Dark Mode'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'theme_system',
                child: Row(
                  children: [
                    Icon(Icons.brightness_auto, color: widget.currentThemeMode == ThemeMode.system ? Theme.of(context).colorScheme.primary : null),
                    const SizedBox(width: 8),
                    const Text('System Default'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(_showStats ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showStats = !_showStats;
              });
            },
            tooltip: _showStats ? 'Hide Stats' : 'Show Stats',
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Stats Card
              if (_showStats)
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: StatsCard(
                    totalTodos: todoProvider.totalTodos,
                    completedTodos: todoProvider.completedTodos,
                    pendingTodos: todoProvider.pendingTodos,
                  ),
                ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              todoProvider.searchTodos('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    todoProvider.searchTodos(value);
                  },
                ),
              ),

              // Priority Filter
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // All filter
                      PriorityChip(
                        priority: Priority.low, // Dummy priority for "All"
                        isSelected: todoProvider.filterPriority == null,
                        onTap: () => todoProvider.filterByPriority(null),
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      // Priority filters
                      ...Priority.values.map((priority) => Padding(
                            padding: const EdgeInsets.only(
                                right: AppConstants.paddingSmall),
                            child: PriorityChip(
                              priority: priority,
                              isSelected:
                                  todoProvider.filterPriority == priority,
                              onTap: () =>
                                  todoProvider.filterByPriority(priority),
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              // Task List
              Expanded(
                child: todoProvider.todos.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                        ),
                        itemCount: todoProvider.todos.length,
                        itemBuilder: (context, index) {
                          final todo = todoProvider.todos[index];
                          return TaskCard(
                            todo: todo,
                            onTap: () => _showTaskDetails(context, todo),
                            onToggleComplete: () {
                              final wasCompleted = todo.isCompleted;
                              todoProvider.toggleTodoComplete(todo);

                              // Show celebration if task was just completed
                              if (!wasCompleted && !todo.isCompleted) {
                                Future.delayed(
                                    const Duration(milliseconds: 300), () {
                                  if (mounted) {
                                    showCelebration(context);
                                  }
                                });
                              }
                            },
                            onEdit: () => _editTask(context, todo),
                            onDelete: () =>
                                _deleteTask(context, todo, todoProvider),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context),
        child: Image.asset('assets/icons/add.png', width: 24, height: 24),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<TodoProvider>();

    String message;
    String subtitle;
    String imagePath;

    if (provider.searchQuery.isNotEmpty) {
      message = 'No tasks found';
      subtitle = 'Try adjusting your search or filters';
      imagePath = 'assets/images/no_search_results.png';
    } else if (provider.filterPriority != null ||
        provider.filterCompleted != null) {
      message = 'No tasks match your filters';
      subtitle = 'Try clearing filters or add new tasks';
      imagePath = 'assets/images/empty_tasks.png';
    } else {
      message = 'No tasks yet';
      subtitle = 'Tap the + button to add your first task';
      imagePath = 'assets/images/empty_tasks.png';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            message,
            style: AppConstants.subheadingStyle.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            subtitle,
            style: AppConstants.captionStyle,
            textAlign: TextAlign.center,
          ),
          if (provider.searchQuery.isNotEmpty ||
              provider.filterPriority != null ||
              provider.filterCompleted != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                provider.clearFilters();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  void _addTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );
  }

  void _editTask(BuildContext context, Todo todo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(todo: todo),
      ),
    );
  }

  void _deleteTask(BuildContext context, Todo todo, TodoProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTodo(todo.id!);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Todo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => _TaskDetailsSheet(
          todo: todo,
          scrollController: scrollController,
          onEdit: () {
            Navigator.of(context).pop();
            _editTask(context, todo);
          },
          onDelete: () {
            Navigator.of(context).pop();
            _deleteTask(context, todo, context.read<TodoProvider>());
          },
        ),
      ),
    );
  }
}

class _TaskDetailsSheet extends StatelessWidget {
  final Todo todo;
  final ScrollController scrollController;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskDetailsSheet({
    Key? key,
    required this.todo,
    required this.scrollController,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Title and Status
          Row(
            children: [
              Expanded(
                child: Text(
                  todo.title,
                  style: AppConstants.headingStyle.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (todo.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.successColor.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: AppConstants.successColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Priority
          Row(
            children: [
              const Text('Priority: '),
              PriorityChip(priority: todo.priority),
            ],
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Description
          if (todo.description.isNotEmpty) ...[
            Text(
              'Description',
              style: AppConstants.subheadingStyle.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              todo.description,
              style: AppConstants.bodyStyle.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          // Dates
          if (todo.dueDate != null) ...[
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Due: ${todo.dueDate!.toString().split(' ')[0]}',
                  style: AppConstants.bodyStyle.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
          ],

          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                'Created: ${todo.createdAt.toString().split(' ')[0]}',
                style: AppConstants.bodyStyle.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
