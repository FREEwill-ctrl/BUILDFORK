import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import 'package:file_picker/file_picker.dart';
import '../../analytics/widgets/task_timer_widget.dart';
import '../../analytics/providers/time_tracking_provider.dart';

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
  TimeOfDay? _dueTime;
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
      if (_dueDate != null) {
        _dueTime = TimeOfDay(hour: _dueDate!.hour, minute: _dueDate!.minute);
      }
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
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      letterSpacing: 0.5,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    minLines: 4,
                    maxLines: 12,
                    expands: false,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: InputBorder.none,
                      alignLabelWithHint: true,
                    ),
                  ),
                  // --- Task Timer Widget Integration (Detail) ---
                  if (widget.todo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                      child: Consumer<TimeTrackingProvider>(
                        builder: (context, timerProvider, _) {
                          final isActive = timerProvider._activeTaskId == widget.todo!.id.toString();
                          final totalTime = timerProvider.getTaskTotalTime(widget.todo!.id.toString());
                          return TaskTimerWidget(
                            isActive: isActive,
                            totalTime: totalTime,
                            onStart: () => timerProvider.startTaskTimer(widget.todo!.id.toString()),
                            onPause: () => timerProvider.pauseTaskTimer(widget.todo!.id.toString()),
                            onStop: () => timerProvider.stopTaskTimer(widget.todo!.id.toString()),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _dueDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dueDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  _dueTime?.hour ?? 23,
                                  _dueTime?.minute ?? 59,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _dueDate == null
                                ? 'Tenggat (Deadline)'
                                : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _dueDate == null ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: _dueTime ?? const TimeOfDay(hour: 23, minute: 59),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _dueTime = pickedTime;
                              if (_dueDate != null) {
                                _dueDate = DateTime(
                                  _dueDate!.year,
                                  _dueDate!.month,
                                  _dueDate!.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 4),
                              Text(_dueTime?.format(context) ?? 'Jam'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<EisenhowerPriority>(
                    value: _priority,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: EisenhowerPriority.urgentImportant, child: Text('Penting & Mendesak')),
                      DropdownMenuItem(value: EisenhowerPriority.importantNotUrgent, child: Text('Penting & Tidak Mendesak')),
                      DropdownMenuItem(value: EisenhowerPriority.notImportantUrgent, child: Text('Tidak Penting & Mendesak')),
                      DropdownMenuItem(value: EisenhowerPriority.notImportantNotUrgent, child: Text('Tidak Penting & Tidak Mendesak')),
                    ],
                    onChanged: (val) => setState(() => _priority = val),
                    decoration: const InputDecoration(labelText: 'Prioritas', border: InputBorder.none),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
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
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Upload Lampiran'),
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
                    if (result != null) {
                      setState(() {
                        _attachments.addAll(result.paths.whereType<String>());
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                if (_attachments.isNotEmpty)
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: _attachments.map((file) => Chip(label: Text(file.split('/').last))).toList(),
                    ),
                  ),
              ],
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