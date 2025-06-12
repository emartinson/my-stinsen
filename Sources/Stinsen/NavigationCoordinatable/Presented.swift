import SwiftUI

struct Presented: Identifiable {
    let id = UUID()
    var view: AnyView
    var type: PresentationType
}
