import Foundation
import SwiftUI
import Stinsen

final class TodosCoordinator: NavigationCoordinatable {
    let stack = NavigationStack(initial: \TodosCoordinator.start)

    @Root var start = makeStart
    @Route(.push) var todo = makeTodo
//    @Route(.modal) var createTodo = makeCreateTodo
    @Route(.sheet(detents: [.fraction(0.33)])) var createTodo = makeCreateTodo
    
    let todosStore: TodosStore
    
    init(todosStore: TodosStore) {
        self.todosStore = todosStore
    }
    
    deinit {
        print("Deinit TodosCoordinator")
    }
}
