import Foundation
import SwiftUI

public extension View {
    func showPartialSheet<Sheet: View, Item: Identifiable>(
        item: Binding<Item?>,
        sheetSize: Binding<CGSize> = .constant(.zero),
        @ViewBuilder content: @escaping (Item) -> Sheet) -> some View
    {
        modifier(
            PrtialSheetModifier(
                        item: item,
                        detents: [
                            sheetSize.wrappedValue.height != 0 ?
                                .height(sheetSize.wrappedValue.height) :
                                    .fraction(0.7),
                            .large
                        ],
                        sheetContent: content
            )
        )
    }
    
    func showPartialSheet<Sheet: View, Item: Identifiable>(
        item: Binding<Item?>,
        detents: [PresentationDetentWrapper],
        dismissable: Bool = true,
        interaction: Bool = true,
        @ViewBuilder content: @escaping (Item) -> Sheet) -> some View
    {
        modifier(
            PrtialSheetModifier(
                item: item,
                detents: detents.isEmpty ? [.fraction(0.5)] : detents,
                dismissable: dismissable,
                interaction: interaction,
                sheetContent: content
            )
        )
    }
}

public enum PresentationDetentWrapper : Hashable, Sendable {
    case meduim, large, fraction(_ fraction: CGFloat), height(_ height: CGFloat)
}

public extension PresentationDetentWrapper {
    @available(iOS 16.0, *)
    var detent: PresentationDetent {
        switch self {
        case .meduim: .medium
        case .large: .large
        case .fraction(let fraction): .fraction(fraction)
        case .height(let height): .height(height)
        }
    }
}

public struct PrtialSheetModifier<Sheet: View, Item: Identifiable>: ViewModifier {
	var dismissable = true
    var interaction = true
    @Binding var item: Item?
    var detents: [PresentationDetentWrapper] = []
    let onDismiss: () -> Void

    init(
        item: Binding<Item?>,
        detents: [PresentationDetentWrapper],
        dismissable: Bool = true,
        interaction: Bool = true,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder sheetContent: @escaping (Item) -> Sheet
    ) {
        self.onDismiss = onDismiss
        self.dismissable = dismissable
        self.interaction = interaction
        self._item = item
        self.detents = detents
        self.sheetContent = sheetContent
    }
    
    @ViewBuilder var sheetContent: (Item) -> Sheet
    
    @State private var sheetSize: CGSize = .zero

    public func body(content: Content) -> some View {
        content
            .sheet(item: $item, onDismiss: onDismiss) { item in
                if #available(iOS 16.4, *) {
                    makeSheetContent(item)
                        .presentationDragIndicator(.hidden)
						.interactiveDismissDisabled(!dismissable)
                        .presentationBackgroundInteraction(
                            interaction ? .enabled : .disabled/*dismissable ? .automatic : .enabled*/
                        )
                } else {
					sheetContent(item)
                }
            }
    }

    @available(iOS 16.0, *)
    @ViewBuilder func makeSheetContent(_ item: Item) -> some View {
        sheetContent(item)
            .presentationDetents(
                Set(detents.map { $0.detent })
            )
    }
}

struct InnerHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
