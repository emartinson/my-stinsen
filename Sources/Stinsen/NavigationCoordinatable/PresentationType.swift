import Foundation
import SwiftUI

public enum PresentationType {
    case modal
    case push
    case fullScreen
    case sheet(detents: [PresentationDetentWrapper] = [], dismissable: Bool = true, interactive: Bool = true)
    
    var isModal: Bool {
        switch self {
        case .modal: true
        default: false
        }
    }
    
    var isSheet: Bool {
        switch self {
        case .sheet: true
        default: false
        }
    }
    
    var isPush: Bool {
        switch self {
        case .push: true
        default: false
        }
    }

    var isFullScreen: Bool {
        switch self {
        case .fullScreen: true
        default: false
        }
    }
}

extension PresentationType {
    var detents: [PresentationDetentWrapper] {
        switch self {
        case .sheet(detents: let detents, dismissable: _, interactive: _):
            return detents
        default:
            return []
        }
    }
    
    var dismissable: Bool {
        switch self {
        case .sheet(detents: _, dismissable: let dismissable, interactive: _):
            return dismissable
        default:
            return true
        }
    }
    
    var interactive: Bool {
        switch self {
        case .sheet(detents: _, dismissable: _, interactive: let interactive):
            return interactive
        default:
            return true
        }
    }
}
