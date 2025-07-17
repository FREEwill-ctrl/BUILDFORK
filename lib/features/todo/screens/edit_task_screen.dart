import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../../../shared/constants.dart';
import '../widgets/priority_chip.dart';
import 'package:file_picker/file_picker.dart';

class EditTaskScreen extends StatefulWidget {
  final Todo todo;

  const EditTaskScreen({
    Key? key,
    required this.todo,
  }) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late Priority _selectedPriority;
  DateTime? _selectedDueDate;
  late bool _isCompleted;
  bool _isLoading = false;

  // Tambahkan field untuk attachment dan checklist
  List<String> _attachments = [];
  List<ChecklistItem> _checklist = [];
  final _checklistController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
    _selectedPriority = widget.todo.priority;
    _selectedDueDate = widget.todo.dueDate;
    _isCompleted = widget.todo.isCompleted;
    _attachments = List<String>.from(widget.todo.attachments);
    _checklist = List<ChecklistItem>.from(widget.todo.checklist);
  }
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _checklistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          children: [
            // Completion Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Row(
                  children: [
                    Icon(
                      _isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: _isCompleted
                          ? AppConstants.successColor
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Text(
                        'Task Status',
                        style: AppConstants.subheadingStyle.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task title',
                prefixIcon: Icon(Icons.title),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters long';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter task description',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Priority Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Priority',
                          style: AppConstants.subheadingStyle.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Wrap(
                      spacing: AppConstants.paddingSmall,
                      children: Priority.values.map((priority) {
                        return PriorityChip(
                          priority: priority,
                          isSelected: _selectedPriority == priority,
                          onTap: () {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Due Date Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Due Date (Optional)',
                          style: AppConstants.subheadingStyle.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDueDate != null
                                ? 'Due: ${_selectedDueDate!.toString().split(' ')[0]}'
                                : 'No due date set',
                            style: AppConstants.bodyStyle.copyWith(
                              color: _selectedDueDate != null
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _selectDueDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                              _selectedDueDate != null ? 'Change' : 'Set Date'),
                        ),
                        if (_selectedDueDate != null)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDueDate = null;
                              });
                            },
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear due date',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Attachments
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/icons/attachment.png', width: 20, height: 20),
                        const SizedBox(width: AppConstants.paddingSmall),
                        const Text('Attachments'),
                        const Spacer(),
                        IconButton(
                          icon: Image.asset('assets/icons/add.png', width: 20, height: 20),
                          onPressed: _pickAttachment,
                          tooltip: 'Add Attachment',
                        ),
                      ],
                    ),
                    if (_attachments.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: _attachments.map((path) => Chip(
                          label: Text(path.split('/').last),
                          onDeleted: () {
                            setState(() {
                              _attachments.remove(path);
                            });
                          },
                        )).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Checklist
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/icons/checklist.png', width: 20, height: 20),
                        const SizedBox(width: AppConstants.paddingSmall),
                        const Text('Checklist'),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _checklistController,
                            decoration: const InputDecoration(hintText: 'Add checklist item'),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                setState(() {
                                  _checklist.add(ChecklistItem(text: val.trim()));
                                  _checklistController.clear();
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Image.asset('assets/icons/add.png', width: 20, height: 20),
                          onPressed: () {
                            final val = _checklistController.text.trim();
                            if (val.isNotEmpty) {
                              setState(() {
                                _checklist.add(ChecklistItem(text: val));
                                _checklistController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (_checklist.isNotEmpty)
                      Column(
                        children: _checklist.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          return ListTile(
                            leading: Checkbox(
                              value: item.isDone,
                              onChanged: (val) {
                                setState(() {
                                  _checklist[idx] = ChecklistItem(text: item.text, isDone: val ?? false);
                                });
                              },
                            ),
                            title: Text(item.text),
                            trailing: IconButton(
                              icon: Image.asset('assets/icons/delete.png', width: 20, height: 20),
                              onPressed: () {
                                setState(() {
                                  _checklist.removeAt(idx);
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Task Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Task Information',
                          style: AppConstants.subheadingStyle.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Created: ${widget.todo.createdAt.toString().split(' ')[0]}',
                          style: AppConstants.captionStyle,
                        ),
                      ],
                    ),
                    if (widget.todo.id != null) ...[
                      const SizedBox(height: AppConstants.paddingSmall),
                      Row(
                        children: [
                          Icon(
                            Icons.tag,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Text(
                            'ID: ${widget.todo.id}',
                            style: AppConstants.captionStyle,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingXLarge),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingMedium,
                ),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: AppConstants.paddingSmall),
                        Text('Saving...'),
                      ],
                    )
                  : const Text('Save Changes'),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Cancel Button
            OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingMedium,
                ),
              ),
              child: const Text('Cancel'),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Delete Button
            ElevatedButton(
              onPressed: _isLoading ? null : _deleteTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingMedium,
                ),
              ),
              child: const Text('Delete Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select due date',
      cancelText: 'Cancel',
      confirmText: 'Set Date',
    );

    if (picked != null) {
      // Show time picker
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: _selectedDueDate != null
            ? TimeOfDay.fromDateTime(_selectedDueDate!)
            : TimeOfDay.now(),
        helpText: 'Select due time',
        cancelText: 'Skip',
        confirmText: 'Set Time',
      );

      setState(() {
        if (timePicked != null) {
          _selectedDueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        } else {
          _selectedDueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _selectedDueDate?.hour ?? 23,
            _selectedDueDate?.minute ?? 59,
          );
        }
      });
    }
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachments.add(result.files.single.path!);
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final updatedTodo = widget.todo.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        isCompleted: _isCompleted,
        attachments: _attachments,
        checklist: _checklist,
      );
      await context.read<TodoProvider>().updateTodo(updatedTodo);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task updated successfully'),
            backgroundColor: AppConstants.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTask() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content:
            Text('Are you sure you want to delete "${widget.todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        await context.read<TodoProvider>().deleteTodo(widget.todo.id!);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Task deleted successfully'),
              backgroundColor: AppConstants.successColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting task: $e'),
              backgroundColor: AppConstants.errorColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
