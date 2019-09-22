//
//  SelectItem.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2019-09-17.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 Select items can be used to let users select one or several
 items in a menu.
 
 This item type is not meant to be used directly. You should
 instead use the single- and multi-select subclasses.
 */
open class SelectItem: MenuItem {
    
    
    // MARK: - Initialization
    
    public init(
        title: String,
        subtitle: String? = nil,
        isSelected: Bool,
        group: String = "",
        value: Any? = nil,
        image: UIImage? = nil,
        tapBehavior: TapBehavior = .dismiss) {
        self.isSelected = isSelected
        self.group = group
        super.init(
            title: title,
            subtitle: subtitle,
            value: value,
            image: image,
            tapBehavior: tapBehavior
        )
    }
    
    
    // MARK: - Properties
    
    public let group: String
    public var isSelected: Bool
    
    
    // MARK: - Functions
    
    open override func handleSelection(in menu: Menu) {
        super.handleSelection(in: menu)
        isSelected = !isSelected
    }
    
    
    // MARK: - ActionSheet
    
    open override func cell(for tableView: UITableView) -> ActionSheetItemCell {
        ActionSheetSelectItemCell(style: cellStyle)
    }
}