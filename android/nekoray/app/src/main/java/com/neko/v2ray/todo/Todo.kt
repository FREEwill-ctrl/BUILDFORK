package com.neko.v2ray.todo

data class ChecklistItem(
    val text: String,
    val isDone: Boolean = false
)

data class Todo(
    val id: Long = 0L,
    val title: String,
    val description: String = "",
    val createdAt: Long = System.currentTimeMillis(),
    val dueDate: Long? = null,
    val priority: Int = 0, // 0: urgent/important, dst
    val isCompleted: Boolean = false,
    val attachments: List<String> = emptyList(),
    val checklist: List<ChecklistItem> = emptyList()
)