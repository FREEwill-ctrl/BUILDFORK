package com.neko.v2ray.todo

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class TodoViewModel(private val dao: TodoDao) : ViewModel() {
    private val _todos = MutableStateFlow<List<TodoEntity>>(emptyList())
    val todos: StateFlow<List<TodoEntity>> = _todos

    fun loadTodos() {
        viewModelScope.launch {
            _todos.value = dao.getAllTodos()
        }
    }

    fun addTodo(todo: TodoEntity) {
        viewModelScope.launch {
            dao.insertTodo(todo)
            loadTodos()
        }
    }

    fun updateTodo(todo: TodoEntity) {
        viewModelScope.launch {
            dao.updateTodo(todo)
            loadTodos()
        }
    }

    fun deleteTodo(todo: TodoEntity) {
        viewModelScope.launch {
            dao.deleteTodo(todo)
            loadTodos()
        }
    }
}