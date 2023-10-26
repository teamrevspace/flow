//
//  TodoService.swift
//  Flow Work
//
//  Created by Allen Lin on 10/17/23.
//

import Foundation
import Swinject
import Combine
import Firebase

class TodoService: TodoServiceProtocol, ObservableObject {
    @Published private var todoState = TodoState()
    @Published private var categoryState = CategoryState()
    
    @Published var storeService: StoreServiceProtocol
    @Published var authService: AuthServiceProtocol
    
    private let resolver: Resolver
    
    var todoStatePublisher: AnyPublisher<TodoState, Never> {
        $todoState.eraseToAnyPublisher()
    }
    var categoryStatePublisher: AnyPublisher<CategoryState, Never> {
        $categoryState.eraseToAnyPublisher()
    }
    
    init(resolver: Resolver) {
        self.resolver = resolver
        
        self.storeService = resolver.resolve(StoreServiceProtocol.self)!
        self.authService = resolver.resolve(AuthServiceProtocol.self)!
    }
    
    func initTodoList(todos: [Todo]) {
        let todoList = todos.filter({!$0.completed}).sorted(by: { $1.createdAt.seconds > $0.createdAt.seconds })
        self.todoState.todoItems = todoList
        self.resetTodoList(todos: todoList)
        self.todoState.isTodoListInitialized = true
    }
    
    private func resetTodoList(todos: [Todo]) {
        self.todoState.isHoveringActionButtons = Array(repeating: false, count: todos.count + 1)
    }
    
    func sanitizeTodoItems() {
        if (self.todoState.todoItems.count > 1) {
            self.todoState.todoItems = self.todoState.todoItems.enumerated().filter { (index, item) in
                return !item.title.isEmpty
            }.map { $0.element }
        }
    }
    
    func updateDraftTodo(todo: Todo) {
        self.todoState.draftTodo = todo
    }
    
    func initCategoryList(categories: [Category]) {
        let categoryList = categories
        self.categoryState.categoryItems = categoryList
        self.categoryState.isCategoryListInitialized = true
    }
}
