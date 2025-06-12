import SwiftUI

/// MARK: - Working Approach

extension View {

    func measureSize(to viewSize: Binding<CGSize> = .constant(.zero), _ action: @escaping (CGSize) -> Void = { _ in }) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear.preference(key: DimensionsKey.self, value: [ViewSizeData(size: geometry.size)])
            }
        )
        .onPreferenceChange(DimensionsKey.self, perform: { value in
            let newSize = value.first?.size ?? .zero
            DispatchQueue.main.async {
                viewSize.wrappedValue = newSize
                action(newSize)
            }
        })
    }
}

struct DimensionsKey: PreferenceKey {

    static var defaultValue: [ViewSizeData] = []

    static func reduce(value: inout [ViewSizeData], nextValue: () -> [ViewSizeData]) {
        value.append(contentsOf: nextValue())
    }
    typealias Value = [ViewSizeData]
}

struct ViewSizeData: Identifiable, Equatable, Hashable {

    let id: UUID = UUID()
    let size: CGSize

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: Used app-wide

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let nextValue = nextValue()
        value = nextValue != defaultValue ? nextValue : value
    }
}
