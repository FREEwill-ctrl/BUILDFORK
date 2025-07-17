import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import '../widgets/todo_tile.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  EisenhowerPriority? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo Modular')),
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
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, provider, _) {
                final todos = _selectedDay == null
                  ? provider.filterByPriority(_selectedPriority)
                  : provider.getTodosByDate(_selectedDay!).where((t) => _selectedPriority == null || t.priority == _selectedPriority).toList();
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    final todoIndex = provider.todos.indexOf(todo);
                    return TodoTile(
                      todo: todo,
                      onDelete: () => provider.deleteTodo(todoIndex),
                      onToggle: () => provider.toggleTodoStatus(todoIndex),
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
            if (title.isNotEmpty && _priority != null) {
              Provider.of<TodoProvider>(context, listen: false).addTodo(
                Todo(
                  title: title,
                  description: desc,
                  createdAt: DateTime.now(),
                  dueDate: _dueDate,
                  priority: _priority!,
                ),
              );
              Navigator.pop(context);
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

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.todo.title);
    _descController = TextEditingController(text: widget.todo.description);
    _dueDate = widget.todo.dueDate;
    _priority = widget.todo.priority;
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
            if (title.isNotEmpty && _priority != null) {
              Provider.of<TodoProvider>(context, listen: false).editTodo(
                widget.index,
                widget.todo.copyWith(
                  title: title,
                  description: desc,
                  dueDate: _dueDate,
                  priority: _priority,
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}