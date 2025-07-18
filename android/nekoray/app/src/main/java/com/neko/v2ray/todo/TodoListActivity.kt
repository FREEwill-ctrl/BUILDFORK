package com.neko.v2ray.todo

import android.os.Bundle
import android.view.LayoutInflater
import android.widget.EditText
import androidx.activity.viewModels
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.neko.v2ray.R
import kotlinx.android.synthetic.main.activity_todo_list.*
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class TodoListActivity : AppCompatActivity() {
    private lateinit var adapter: TodoAdapter
    private val viewModel: TodoViewModel by viewModels {
        object : ViewModelProvider.Factory {
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                val db = TodoDatabase.getInstance(applicationContext)
                @Suppress("UNCHECKED_CAST")
                return TodoViewModel(db.todoDao()) as T
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_todo_list)

        adapter = TodoAdapter(emptyList(), onEdit = { showAddEditDialog(it) }, onDelete = { viewModel.deleteTodo(it) })
        recyclerViewTodos.layoutManager = LinearLayoutManager(this)
        recyclerViewTodos.adapter = adapter

        fabAddTodo.setOnClickListener { showAddEditDialog(null) }

        lifecycleScope.launch {
            viewModel.todos.collectLatest { todos ->
                adapter.updateData(todos)
            }
        }
        viewModel.loadTodos()
    }

    private fun showAddEditDialog(todo: TodoEntity?) {
        val dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_add_edit_todo, null)
        val editTitle = dialogView.findViewById<EditText>(R.id.editTitle)
        val editDesc = dialogView.findViewById<EditText>(R.id.editDesc)
        val editChecklist = dialogView.findViewById<EditText>(R.id.editChecklist)
        if (todo != null) {
            editTitle.setText(todo.title)
            editDesc.setText(todo.description)
        }
        AlertDialog.Builder(this)
            .setTitle(if (todo == null) "Tambah Todo" else "Edit Todo")
            .setView(dialogView)
            .setPositiveButton("Simpan") { _, _ ->
                val title = editTitle.text.toString().trim()
                val desc = editDesc.text.toString().trim()
                if (title.isNotBlank()) {
                    val newTodo = TodoEntity(
                        id = todo?.id ?: 0L,
                        title = title,
                        description = desc
                    )
                    if (todo == null) viewModel.addTodo(newTodo)
                    else viewModel.updateTodo(newTodo)
                }
            }
            .setNegativeButton("Batal", null)
            .show()
    }
}