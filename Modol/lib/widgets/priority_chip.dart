import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../utils/constants.dart';

class PriorityChip extends StatelessWidget {
  final Priority priority;
  final bool isSelected;
  final VoidCallback? onTap;

  const PriorityChip({
    Key? key,
    required this.priority,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (priority) {
      case Priority.low:
        backgroundColor = isSelected
            ? AppConstants.lowPriorityColor
            : AppConstants.lowPriorityColor.withOpacity(0.1);
        textColor = isSelected ? Colors.white : AppConstants.lowPriorityColor;
        break;
      case Priority.medium:
        backgroundColor = isSelected
            ? AppConstants.mediumPriorityColor
            : AppConstants.mediumPriorityColor.withOpacity(0.1);
        textColor =
            isSelected ? Colors.white : AppConstants.mediumPriorityColor;
        break;
      case Priority.high:
        backgroundColor = isSelected
            ? AppConstants.highPriorityColor
            : AppConstants.highPriorityColor.withOpacity(0.1);
        textColor = isSelected ? Colors.white : AppConstants.highPriorityColor;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          border: isSelected
              ? null
              : Border.all(
                  color: backgroundColor,
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getPriorityIcon(priority),
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: 4),
            Text(
              priority.name,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Icons.keyboard_arrow_down;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.keyboard_arrow_up;
    }
  }
}

class PrioritySelector extends StatelessWidget {
  final Priority? selectedPriority;
  final Function(Priority) onPrioritySelected;
  final bool showAllOption;

  const PrioritySelector({
    Key? key,
    this.selectedPriority,
    required this.onPrioritySelected,
    this.showAllOption = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.paddingSmall,
      children: [
        if (showAllOption)
          PriorityChip(
            priority: Priority.low, // Dummy priority for "All"
            isSelected: selectedPriority == null,
            onTap: () => onPrioritySelected(
                Priority.low), // This will be handled differently
          ),
        ...Priority.values.map((priority) => PriorityChip(
              priority: priority,
              isSelected: selectedPriority == priority,
              onTap: () => onPrioritySelected(priority),
            )),
      ],
    );
  }
}

class PriorityDropdown extends StatelessWidget {
  final Priority selectedPriority;
  final Function(Priority?) onChanged;

  const PriorityDropdown({
    Key? key,
    required this.selectedPriority,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Priority>(
      value: selectedPriority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        prefixIcon: Icon(Icons.flag),
      ),
      items: Priority.values.map((priority) {
        return DropdownMenuItem<Priority>(
          value: priority,
          child: Row(
            children: [
              Icon(
                _getPriorityIcon(priority),
                color: _getPriorityColor(priority),
                size: 20,
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(priority.name),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Icons.keyboard_arrow_down;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.keyboard_arrow_up;
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return AppConstants.lowPriorityColor;
      case Priority.medium:
        return AppConstants.mediumPriorityColor;
      case Priority.high:
        return AppConstants.highPriorityColor;
    }
  }
}
