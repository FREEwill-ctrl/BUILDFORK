import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import '../widgets/todo_tile.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_modular/shared/app_theme.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  EisenhowerPriority? _selectedPriority;
  String _searchQuery = '';
  String _statusFilter = 'Semua';
  String _sortBy = 'Tanggal Dibuat';

  List<String> get _sortOptions => [
    'Tanggal Dibuat',
    'Tanggal Tenggat',
    'Prioritas',
    'Status',
  ];

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> _scheduleNotification(Todo todo) async {
    if (todo.reminder == null) return;
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'todo_reminder', 'Todo Reminder',
      channelDescription: 'Pengingat todo',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notifications.zonedSchedule(
      todo.hashCode,
      'Pengingat Todo',
      todo.title,
      tz.TZDateTime.from(todo.reminder!, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<TodoProvider>(context, listen: false).loadTodos()
    );
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await _notifications.initialize(initSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Modular'),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.week,
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _selectedPriority == null,
                    onSelected: (_) => setState(() => _selectedPriority = null),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Penting & Mendesak'),
                    selected: _selectedPriority == EisenhowerPriority.urgentImportant,
                    onSelected: (_) => setState(() => _selectedPriority = EisenhowerPriority.urgentImportant),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Penting & Tidak Mendesak'),
                    selected: _selectedPriority == EisenhowerPriority.importantNotUrgent,
                    onSelected: (_) => setState(() => _selectedPriority = EisenhowerPriority.importantNotUrgent),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Tidak Penting & Mendesak'),
                    selected: _selectedPriority == EisenhowerPriority.notImportantUrgent,
                    onSelected: (_) => setState(() => _selectedPriority = EisenhowerPriority.notImportantUrgent),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Tidak Penting & Tidak Mendesak'),
                    selected: _selectedPriority == EisenhowerPriority.notImportantNotUrgent,
                    onSelected: (_) => setState(() => _selectedPriority = EisenhowerPriority.notImportantNotUrgent),
                  ),
                ],
              ),
            ),
          ),
          // Search bar dan filter status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari todo...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                    DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                    DropdownMenuItem(value: 'Belum Selesai', child: Text('Belum Selesai')),
                  ],
                  onChanged: (val) => setState(() => _statusFilter = val!),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  items: _sortOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _sortBy = val!),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, provider, _) {
                final todos = _selectedDay == null
                  ? provider.filterByPriority(_selectedPriority)
                  : provider.getTodosByDate(_selectedDay!).where((t) => _selectedPriority == null || t.priority == _selectedPriority).toList();
                final filteredTodos = todos.where((todo) {
                  final matchSearch = _searchQuery.isEmpty ||
                    todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    todo.description.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchStatus = _statusFilter == 'Semua' ||
                    (_statusFilter == 'Selesai' && todo.isCompleted) ||
                    (_statusFilter == 'Belum Selesai' && !todo.isCompleted);
                  return matchSearch && matchStatus;
                }).toList();

                // Sorting
                filteredTodos.sort((a, b) {
                  switch (_sortBy) {
                    case 'Tanggal Dibuat':
                      return b.createdAt.compareTo(a.createdAt);
                    case 'Tanggal Tenggat':
                      if (a.dueDate == null && b.dueDate == null) return 0;
                      if (a.dueDate == null) return 1;
                      if (b.dueDate == null) return -1;
                      return a.dueDate!.compareTo(b.dueDate!);
                    case 'Prioritas':
                      return a.priority.index.compareTo(b.priority.index);
                    case 'Status':
                      return a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1);
                    default:
                      return 0;
                  }
                });
                return filteredTodos.isEmpty
                  ? Center(child: Text('Belum ada todo.'))
                  : ListView.builder(
                      itemCount: filteredTodos.length,
                      itemBuilder: (context, index) {
                        final todo = filteredTodos[index];
                        final todoIndex = provider.todos.indexOf(todo);
                        return TodoTile(
                          todo: todo,
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Konfirmasi'),
                                content: Text('Hapus todo ini?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus')),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              provider.deleteTodo(todoIndex);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Todo dihapus'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () => provider.undoDelete(),
                                  ),
                                ),
                              );
                            }
                          },
                          onToggle: () {
                            provider.toggleTodoStatus(todoIndex);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(todo.isCompleted ? 'Todo dibatalkan' : 'Todo selesai')),
                            );
                          },
                          onEdit: () => showDialog(
                            context: context,
                            builder: (context) => _EditTodoDialog(index: todoIndex, todo: todo),
                          ),
                        );
                      },
                    );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => _AddTodoDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddTodoDialog extends StatefulWidget {
  @override
  State<_AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<_AddTodoDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  EisenhowerPriority? _priority = EisenhowerPriority.urgentImportant;
  DateTime? _reminder;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Todo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Tenggat: '),
              Text(_dueDate == null ? '-' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<EisenhowerPriority>(
            value: _priority,
            items: const [
              DropdownMenuItem(value: EisenhowerPriority.urgentImportant, child: Text('Penting & Mendesak')),
              DropdownMenuItem(value: EisenhowerPriority.importantNotUrgent, child: Text('Penting & Tidak Mendesak')),
              DropdownMenuItem(value: EisenhowerPriority.notImportantUrgent, child: Text('Tidak Penting & Mendesak')),
              DropdownMenuItem(value: EisenhowerPriority.notImportantNotUrgent, child: Text('Tidak Penting & Tidak Mendesak')),
            ],
            onChanged: (val) => setState(() => _priority = val),
            decoration: const InputDecoration(labelText: 'Prioritas'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Pengingat: '),
              Text(_reminder == null ? '-' : '${_reminder!.day}/${_reminder!.month}/${_reminder!.year}'),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _reminder ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _reminder = picked);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final desc = _descController.text.trim();
            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Judul tidak boleh kosong')),
              );
              return;
            }
            if (_dueDate != null && _dueDate!.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tanggal tenggat tidak valid')),
              );
              return;
            }
            final todo = Todo(
              title: title,
              description: desc,
              createdAt: DateTime.now(),
              dueDate: _dueDate,
              priority: _priority!,
              reminder: _reminder,
            );
            Provider.of<TodoProvider>(context, listen: false).addTodo(todo);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Todo ditambahkan')),
            );
            if (todo.reminder != null) {
              _scheduleNotification(todo);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EditTodoDialog extends StatefulWidget {
  final int index;
  final Todo todo;
  const _EditTodoDialog({required this.index, required this.todo});
  @override
  State<_EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<_EditTodoDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _dueDate;
  EisenhowerPriority? _priority;
  DateTime? _reminder;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.todo.title);
    _descController = TextEditingController(text: widget.todo.description);
    _dueDate = widget.todo.dueDate;
    _priority = widget.todo.priority;
    _reminder = widget.todo.reminder;
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Todo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Tenggat: '),
              Text(_dueDate == null ? '-' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<EisenhowerPriority>(
            value: _priority,
            items: const [
              DropdownMenuItem(value: EisenhowerPriority.urgentImportant, child: Text('Penting & Mendesak')),
              DropdownMenuItem(value: EisenhowerPriority.importantNotUrgent, child: Text('Penting & Tidak Mendesak')),
              DropdownMenuItem(value: EisenhowerPriority.notImportantUrgent, child: Text('Tidak Penting & Mendesak')),
              DropdownMenuItem(value: EisenhowerPriority.notImportantNotUrgent, child: Text('Tidak Penting & Tidak Mendesak')),
            ],
            onChanged: (val) => setState(() => _priority = val),
            decoration: const InputDecoration(labelText: 'Prioritas'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Pengingat: '),
              Text(_reminder == null ? '-' : '${_reminder!.day}/${_reminder!.month}/${_reminder!.year}'),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _reminder ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _reminder = picked);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final desc = _descController.text.trim();
            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Judul tidak boleh kosong')),
              );
              return;
            }
            if (_dueDate != null && _dueDate!.isBefore(widget.todo.createdAt)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tanggal tenggat tidak valid')),
              );
              return;
            }
            final todo = widget.todo.copyWith(
              title: title,
              description: desc,
              dueDate: _dueDate,
              priority: _priority,
              reminder: _reminder,
            );
            Provider.of<TodoProvider>(context, listen: false).updateTodo(
              widget.index,
              todo,
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Todo diubah')),
            );
            if (todo.reminder != null) {
              _scheduleNotification(todo);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}