//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Виталий on 11.03.2021.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let storageManager = StorageManager.shared
    private let cellId = "cell"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.AppTheme.backgroundColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        setupNavigationBar()
        fetchData()
    }
    
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearence = UINavigationBarAppearance()
        navBarAppearence.configureWithOpaqueBackground()
        
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.AppTheme.inverseTextColor]
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.AppTheme.inverseTextColor]
        
        navBarAppearence.backgroundColor = UIColor.AppTheme.primaryColor
        
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        
        // Add add button to navigation bar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = UIColor.AppTheme.inverseTextColor
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func fetchData() {
        storageManager.fetchData { tasks in
            taskList = tasks
            tableView.reloadData()
        }
    }
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        storageManager.save(taskName) { task in
            taskList.append(task)
            let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
            tableView.insertRows(at: [cellIndex], with: .automatic)
        }
    }
    
    private func showEditAlert(with title: String, and message: String, task: Task) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            guard
                let taskName = alert.textFields?.first?.text,
                !taskName.isEmpty,
                taskName != task.name
            else { return }
            
            self.renameTask(task, to: taskName)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField { textField in
            textField.text = task.name
        }
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func renameTask(_ task: Task, to newTaskName: String) {
        storageManager.renameTask(task, to: newTaskName) {
            guard let taskIndex = taskList.firstIndex(of: task) else { return }
            let indexPath = IndexPath(row: taskIndex, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Table View Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = taskList[indexPath.row]
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, success) in
            let task = self.taskList[indexPath.row]
            self.showEditAlert(with: "Edit", and: "Edit your task", task: task)
            success(true)
        }
        editAction.backgroundColor = .orange
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, success) in
            let task = self.taskList[indexPath.row]
            self.storageManager.delete(task) {
                self.taskList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            success(true)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        swipeActions.performsFirstActionWithFullSwipe = false
        return swipeActions
    }
}
