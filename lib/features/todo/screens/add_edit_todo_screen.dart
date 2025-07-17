import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo? todo;
  const AddEditTodoScreen({super.key, this.todo});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  EisenhowerPriority? _priority = EisenhowerPriority.urgentImportant;
  bool _isCompleted = false;
  List<ChecklistItem> _checklist = [];
  List<String> _attachments = [];
  final _checklistController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descController.text = widget.todo!.description;
      _dueDate = widget.todo!.dueDate;
      _priority = widget.todo!.priority;
      _isCompleted = widget.todo!.isCompleted;
      _checklist = List.from(widget.todo!.checklist);
      _attachments = List.from(widget.todo!.attachments);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _checklistController.dispose();
    super.dispose();
  }

  void _addChecklistItem() {
    final text = _checklistController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _checklist.add(ChecklistItem(text: text));
        _checklistController.clear();
      });
    }
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklist.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.todo == null ? 'Add Todo' : 'Edit Todo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
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
                Checkbox(
                  value: _isCompleted,
                  onChanged: (val) => setState(() => _isCompleted = val ?? false),
                ),
                const Text('Selesai'),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Checklist', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checklistController,
                    decoration: const InputDecoration(hintText: 'Tambah item checklist'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addChecklistItem),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _checklist.length,
              itemBuilder: (context, index) {
                final item = _checklist[index];
                return ListTile(
                  title: Text(item.text),
                  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeChecklistItem(index)),
                );
              },
            ),
            const SizedBox(height: 8),
            const Text('Lampiran (dummy)', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _attachments.map((file) => Chip(label: Text(file.split('/').last))).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final desc = _descController.text.trim();
                if (title.isNotEmpty && _priority != null) {
                  final todo = Todo(
                    title: title,
                    description: desc,
                    createdAt: widget.todo?.createdAt ?? DateTime.now(),
                    dueDate: _dueDate,
                    priority: _priority!,
                    isCompleted: _isCompleted,
                    checklist: _checklist,
                    attachments: _attachments,
                  );
                  if (widget.todo == null) {
                    Provider.of<TodoProvider>(context, listen: false).addTodo(todo);
                  } else {
                    Provider.of<TodoProvider>(context, listen: false).editTodo(widget.todo!.id ?? 0, todo);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(widget.todo == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}