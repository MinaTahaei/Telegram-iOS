import Foundation
import UIKit
import Display

public protocol ItemListItemTag {
    func isEqual(to other: ItemListItemTag) -> Bool
}

public protocol ItemListItem {
    var sectionId: ItemListSectionId { get }
    var tag: ItemListItemTag? { get }
    var isAlwaysPlain: Bool { get }
    var requestsNoInset: Bool { get }
}

public extension ItemListItem {
    public var isAlwaysPlain: Bool {
        return false
    }
    
    public var tag: ItemListItemTag? {
        return nil
    }
    
    public var requestsNoInset: Bool {
        return false
    }
}

public protocol ItemListItemNode {
    var tag: ItemListItemTag? { get }
}

public protocol ItemListItemFocusableNode {
    func focus()
}

public enum ItemListInsetWithOtherSection {
    case none
    case full
    case reduced
}

public enum ItemListNeighbor {
    case none
    case otherSection(ItemListInsetWithOtherSection)
    case sameSection(alwaysPlain: Bool)
}

public struct ItemListNeighbors {
    public var top: ItemListNeighbor
    public var bottom: ItemListNeighbor
    
    public init(top: ItemListNeighbor, bottom: ItemListNeighbor) {
        self.top = top
        self.bottom = bottom
    }
}

public func itemListNeighbors(item: ItemListItem, topItem: ItemListItem?, bottomItem: ItemListItem?) -> ItemListNeighbors {
    let topNeighbor: ItemListNeighbor
    if let topItem = topItem {
        if topItem.sectionId != item.sectionId {
            let topInset: ItemListInsetWithOtherSection
            if topItem.requestsNoInset {
                topInset = .none
            } else {
                if topItem is ItemListTextItem {
                    topInset = .reduced
                } else {
                    topInset = .full
                }
            }
            topNeighbor = .otherSection(topInset)
        } else {
            topNeighbor = .sameSection(alwaysPlain: topItem.isAlwaysPlain)
        }
    } else {
        topNeighbor = .none
    }
    
    let bottomNeighbor: ItemListNeighbor
    if let bottomItem = bottomItem {
        if bottomItem.sectionId != item.sectionId {
            let bottomInset: ItemListInsetWithOtherSection
            if bottomItem.requestsNoInset {
                bottomInset = .none
            } else {
                bottomInset = .full
            }
            bottomNeighbor = .otherSection(bottomInset)
        } else {
            bottomNeighbor = .sameSection(alwaysPlain: bottomItem.isAlwaysPlain)
        }
    } else {
        bottomNeighbor = .none
    }
    
    return ItemListNeighbors(top: topNeighbor, bottom: bottomNeighbor)
}

public func itemListNeighborsPlainInsets(_ neighbors: ItemListNeighbors) -> UIEdgeInsets {
    var insets = UIEdgeInsets()
    switch neighbors.top {
    case .otherSection:
        insets.top += 22.0
    case .none, .sameSection:
        break
    }
    switch neighbors.bottom {
    case .none:
        insets.bottom += 22.0
    case .otherSection, .sameSection:
        break
    }
    return insets
}

public func itemListNeighborsGroupedInsets(_ neighbors: ItemListNeighbors) -> UIEdgeInsets {
    let topInset: CGFloat
    switch neighbors.top {
    case .none:
        topInset = UIScreenPixel + 35.0
    case .sameSection:
        topInset = 0.0
    case let .otherSection(otherInset):
        switch otherInset {
        case .none:
            topInset = 0.0
        case .full:
            topInset = UIScreenPixel + 35.0
        case .reduced:
            topInset = UIScreenPixel + 16.0
        }
    }
    let bottomInset: CGFloat
    switch neighbors.bottom {
    case .sameSection, .otherSection:
        bottomInset = 0.0
    case .none:
        bottomInset = UIScreenPixel + 35.0
    }
    return UIEdgeInsets(top: topInset, left: 0.0, bottom: bottomInset, right: 0.0)
}