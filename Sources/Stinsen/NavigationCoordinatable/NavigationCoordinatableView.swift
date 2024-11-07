import Foundation
import SwiftUI
import Combine

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return InnerView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }

    private class InnerView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()

            superview?.superview?.backgroundColor = .clear
            DispatchQueue.main.async {
                self.superview?.superview?.backgroundColor = .clear
            }
        }
    }
}

struct NavigationCoordinatableView<T: NavigationCoordinatable>: View {
    var coordinator: T
    private let id: Int
    private let router: NavigationRouter<T>
    @ObservedObject var presentationHelper: PresentationHelper<T>
    @ObservedObject var root: NavigationRoot

    @State var fade: CGFloat = 0.0
    @State var isPresentedInternal = false

    var start: AnyView?

    var body: some View {
        #if os(macOS)
        commonView
            .environmentObject(router)
        #else
        if #available(iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            commonView
                .environmentObject(router)
                .background(
                    // WORKAROUND for iOS < 14.5
                    // A bug hinders us from using modal and fullScreenCover on the same view
                    Color
                        .clear
                        .fullScreenCover(isPresented: Binding<Bool>.init(get: { () -> Bool in
                            return presentationHelper.presented?.type.isFullScreen == true
                        }, set: { _ in
                            self.coordinator.appear(self.id)
                        }), onDismiss: {
                            self.coordinator.stack.dismissalAction[id]?()
                            self.coordinator.stack.dismissalAction[id] = nil
                        }, content: {
                            if let view = presentationHelper.presented?.view {
                                view
                                    .background(ClearBackgroundView())
                                    .transition(.opacity)
                                    .opacity(fade)
                                    .scaleEffect(fade)
                                    .onAppear {
                                        fade = 1
                                    }
                                    .onDisappear {
                                        fade = 0
                                    }
                            } else {
                                EmptyView()
                            }
                        })
                        .transaction({ transaction in
                            // disable the default FullScreenCover animation
//                            transaction.disablesAnimations = true

                            // add custom animation for presenting and dismissing the FullScreenCover
                            transaction.animation = .easeInOut(duration: 0.1) //.linear(duration: 0.1)
                        })
                        .environmentObject(router)
                )
        } else {
            commonView
                .background(ClearBackgroundView())
                .environmentObject(router)
        }
        #endif
    }
    
    @ViewBuilder
    var commonView: some View {
        (id == -1 ? AnyView(self.coordinator.customize(AnyView(root.item.child.view()))) : AnyView(self.start!))
            .background(
                NavigationLink(
                    destination: { () -> AnyView in
                        if let view = presentationHelper.presented?.view {
                            return AnyView(view.onDisappear {
                                self.coordinator.stack.dismissalAction[id]?()
                                self.coordinator.stack.dismissalAction[id] = nil
                            })
                        } else {
                            return AnyView(EmptyView())
                        }
                    }(),
                    isActive: Binding<Bool>.init(get: { () -> Bool in
                        return presentationHelper.presented?.type.isPush == true
                    }, set: { _ in
                        self.coordinator.appear(self.id)
                    }),
                    label: {
                        EmptyView()
                    }
                )
                .hidden()
            )
            .sheet(isPresented: Binding<Bool>.init(get: { () -> Bool in
                return presentationHelper.presented?.type.isModal == true
            }, set: { _ in
                self.coordinator.appear(self.id)
            }), onDismiss: {
                self.coordinator.stack.dismissalAction[id]?()
                self.coordinator.stack.dismissalAction[id] = nil
            }, content: { () -> AnyView in
                return { () -> AnyView in
                    if let view = presentationHelper.presented?.view {
                        return AnyView(view)
                    } else {
                        return AnyView(EmptyView())
                    }
                }()
            })
    }
    
    init(id: Int, coordinator: T) {
        self.id = id
        self.coordinator = coordinator
        
        self.presentationHelper = PresentationHelper(
            id: self.id,
            coordinator: coordinator
        )
        
        self.router = NavigationRouter(
            id: id,
            coordinator: coordinator.routerStorable
        )
        
        if coordinator.stack.root == nil {
            coordinator.setupRoot()
        }
        
        self.root = coordinator.stack.root

        RouterStore.shared.store(router: router)
        
        if let presentation = coordinator.stack.value[safe: id] {
            if let view = presentation.presentable as? AnyView {
                self.start = view
            } else {
                fatalError("Can only show views")
            }
        } else if id == -1 {
            self.start = nil
        } else {
            fatalError()
        }
    }
}
