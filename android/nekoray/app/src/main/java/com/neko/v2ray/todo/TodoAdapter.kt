package com.neko.v2ray.todo

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.neko.v2ray.R

class TodoAdapter(
    private var todos: List<TodoEntity>,
    private val onEdit: (TodoEntity) -> Unit,
    private val onDelete: (TodoEntity) -> Unit
) : RecyclerView.Adapter<TodoAdapter.TodoViewHolder>() {

    fun updateData(newTodos: List<TodoEntity>) {
        todos = newTodos
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): TodoViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_todo, parent, false)
        return TodoViewHolder(view)
    }

    override fun onBindViewHolder(holder: TodoViewHolder, position: Int) {
        val todo = todos[position]
        holder.bind(todo)
        holder.btnEdit.setOnClickListener { onEdit(todo) }
        holder.btnDelete.setOnClickListener { onDelete(todo) }
    }

    override fun getItemCount(): Int = todos.size

    class TodoViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val textTitle: TextView = itemView.findViewById(R.id.textTitle)
        val textDesc: TextView = itemView.findViewById(R.id.textDesc)
        val btnEdit: ImageButton = itemView.findViewById(R.id.btnEdit)
        val btnDelete: ImageButton = itemView.findViewById(R.id.btnDelete)

        fun bind(todo: TodoEntity) {
            textTitle.text = todo.title
            if (todo.description.isNotBlank()) {
                textDesc.visibility = View.VISIBLE
                textDesc.text = todo.description
            } else {
                textDesc.visibility = View.GONE
            }
        }
    }
}