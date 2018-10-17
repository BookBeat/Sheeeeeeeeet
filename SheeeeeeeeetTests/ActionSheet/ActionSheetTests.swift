//
//  ActionSheetTests.swift
//  SheeeeeeeeetTests
//
//  Created by Daniel Saidi on 2017-11-28.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

import Quick
import Nimble
@testable import Sheeeeeeeeet

class ActionSheetTests: QuickSpec {
    
    override func spec() {
        
        func createButton(_ title: String) -> ActionSheetButton {
            return ActionSheetOkButton(title: title)
        }
        
        func createItem(_ title: String) -> ActionSheetItem {
            return ActionSheetItem(title: title)
        }
        
        func createSheet(_ items: [ActionSheetItem] = []) -> MockActionSheet {
            return MockActionSheet(items: items, action: { _, _ in })
        }
        
        
        // MARK: - Initialization
        
        describe("when initialized with parameters") {
            
            it("applies provided items") {
                let item1 = createItem("foo")
                let item2 = createItem("bar")
                let sheet = createSheet([item1, item2])
                
                expect(sheet.items.count).to(equal(2))
                expect(sheet.items[0]).to(be(item1))
                expect(sheet.items[1]).to(be(item2))
            }

            it("separates provided items and buttons") {
                let button = createButton("Sheeeeeeeeet")
                let item1 = createItem("foo")
                let item2 = createItem("bar")
                let sheet = createSheet([button, item1, item2])

                expect(sheet.items.count).to(equal(2))
                expect(sheet.items[0]).to(be(item1))
                expect(sheet.items[1]).to(be(item2))
                expect(sheet.buttons.count).to(equal(1))
                expect(sheet.buttons[0]).to(be(button))
            }

            it("applies default presenter if none is provided") {
                let sheet = createSheet()
                let isStandard = sheet.presenter is ActionSheetStandardPresenter
                let isPopover = sheet.presenter is ActionSheetPopoverPresenter
                let isValid = isStandard || isPopover
                
                expect(isValid).to(beTrue())
            }

            it("applies provided presenter") {
                let presenter = ActionSheetPopoverPresenter()
                let sheet = MockActionSheet(items: [], presenter: presenter, action: { _, _ in })
                
                expect(sheet.presenter).to(be(presenter))
            }

            it("applies provided action") {
                var counter = 0
                let sheet = MockActionSheet(items: []) { _, _  in counter += 1 }
                sheet.selectAction(sheet, createItem("foo"))
                
                expect(counter).to(equal(1))
            }
        }
        
        
        // MARK: - Properties

        describe("appearance") {
            
            it("is initially a copy of standard appearance") {
                let original = ActionSheetAppearance.standard.popover.width
                ActionSheetAppearance.standard.popover.width = -1
                let sheet = createSheet()
                let appearance = sheet.appearance
                ActionSheetAppearance.standard.popover.width = original
                
                expect(appearance.popover.width).to(equal(-1))
            }
        }
        
        
        // MARK: - Header Properties
        
        describe("header view") {
            
            it("refreshes the sheet when set") {
                let sheet = createSheet()
                expect(sheet.refreshInvokeCount).to(equal(0))
                sheet.headerView = UIView()
                
                expect(sheet.refreshInvokeCount).to(equal(1))
            }
        }
        
        describe("header view container") {
            
            it("gets clear background color when set") {
                let sheet = createSheet()
                let view = UIView()
                view.backgroundColor = .red
                sheet.headerViewContainer = view
                
                expect(view.backgroundColor).to(equal(.clear))
            }
        }
        
        
        // MARK: - Item Properties
        
        describe("items height") {
            
            it("is sum of all item appearances") {
                let item1 = createItem("foo")
                let item2 = createItem("bar")
                let item3 = createButton("baz")
                item1.appearance.height = 100
                item2.appearance.height = 110
                item3.appearance.height = 120
                let sheet = createSheet([item1, item2, item3])
                
                expect(sheet.itemsHeight).to(equal(210))
            }
        }
        
        describe("item handler") {
            
            it("has correct item type") {
                let sheet = createSheet()
                expect(sheet.itemHandler.itemType).to(equal(.items))
            }
            
            it("has correct items") {
                let item1 = createItem("foo")
                let item2 = createItem("bar")
                let item3 = createButton("baz")
                let sheet = createSheet([item1, item2, item3])
                
                expect(sheet.itemHandler.items.count).to(equal(2))
                expect(sheet.itemHandler.items[0]).to(be(item1))
                expect(sheet.itemHandler.items[1]).to(be(item2))
            }
        }
        
        describe("item table view") {
            
            it("is correctly setup when set") {
                let sheet = createSheet()
                let view = UITableView(frame: .zero)
                sheet.itemsTableView = view
                
                expect(view.delegate).to(be(sheet.itemHandler))
                expect(view.dataSource).to(be(sheet.itemHandler))
                expect(view.estimatedRowHeight).to(equal(44))
                expect(view.rowHeight).to(equal(UITableView.automaticDimension))
                expect(view.cellLayoutMarginsFollowReadableWidth).to(beFalse())
            }
        }
        
        
        // MARK: - Button Properties
        
        describe("buttons height") {
            
            it("is sum of all button appearances") {
                let item1 = createItem("foo")
                let item2 = createButton("bar")
                let item3 = createButton("baz")
                item1.appearance.height = 100
                item2.appearance.height = 110
                item3.appearance.height = 120
                let sheet = createSheet([item1, item2, item3])
                
                expect(sheet.buttonsHeight).to(equal(230))
            }
        }
        
        describe("button handler") {
            
            it("has correct item type") {
                let sheet = createSheet()
                expect(sheet.buttonHandler.itemType).to(equal(.buttons))
            }
            
            it("has correct items") {
                let item1 = createItem("foo")
                let item2 = createButton("bar")
                let item3 = createButton("baz")
                let sheet = createSheet([item1, item2, item3])
                
                expect(sheet.buttonHandler.items.count).to(equal(2))
                expect(sheet.buttonHandler.items[0]).to(be(item2))
                expect(sheet.buttonHandler.items[1]).to(be(item3))
            }
        }
        
        describe("button table view") {
            
            it("is correctly setup when set") {
                let sheet = createSheet()
                let view = UITableView(frame: .zero)
                sheet.buttonsTableView = view
                
                expect(view.delegate).to(be(sheet.buttonHandler))
                expect(view.dataSource).to(be(sheet.buttonHandler))
                expect(view.estimatedRowHeight).to(equal(44))
                expect(view.rowHeight).to(equal(UITableView.automaticDimension))
                expect(view.cellLayoutMarginsFollowReadableWidth).to(beFalse())
            }
        }
        
        
        // MARK: - Presentation Functions
        
        context("presentation") {
            
            var presenter: MockActionSheetPresenter!
            
            func createSheet() -> MockActionSheet {
                presenter = MockActionSheetPresenter()
                return MockActionSheet(items: [], presenter: presenter, action: { _, _ in })
            }
            
            describe("when dismissed") {
                
                it("dismisses itself by calling presenter") {
                    var counter = 0
                    let completion = { counter += 1 }
                    let sheet = createSheet()
                    sheet.dismiss(completion: completion)
                    presenter.dismissInvokeCompletions[0]()
                    
                    expect(presenter.dismissInvokeCount).to(equal(1))
                    expect(counter).to(equal(1))
                }
            }
            
            describe("when presented from view") {
                
                it("refreshes itself") {
                    let sheet = createSheet()
                    sheet.present(in: UIViewController(), from: UIView())
                    
                    expect(sheet.refreshInvokeCount).to(equal(1))
                }
                
                it("presents itself by calling presenter") {
                    var counter = 0
                    let completion = { counter += 1 }
                    let sheet = createSheet()
                    let vc = UIViewController()
                    let view = UIView()
                    sheet.present(in: vc, from: view, completion: completion)
                    presenter.presentInvokeCompletions[0]()
                    
                    expect(presenter.presentInvokeCount).to(equal(1))
                    expect(presenter.presentInvokeViewControllers[0]).to(be(vc))
                    expect(presenter.presentInvokeViews[0]).to(be(view))
                    expect(counter).to(equal(1))
                }
            }
            
            describe("when presented from bar button item") {
                
                it("refreshes itself") {
                    let sheet = createSheet()
                    sheet.present(in: UIViewController(), from: UIBarButtonItem())
                    
                    expect(sheet.refreshInvokeCount).to(equal(1))
                }
                
                it("presents itself by calling presenter") {
                    var counter = 0
                    let completion = { counter += 1 }
                    let sheet = createSheet()
                    let vc = UIViewController()
                    let item = UIBarButtonItem()
                    sheet.present(in: vc, from: item, completion: completion)
                    presenter.presentInvokeCompletions[0]()
                    
                    expect(presenter.presentInvokeCount).to(equal(1))
                    expect(presenter.presentInvokeViewControllers[0]).to(be(vc))
                    expect(presenter.presentInvokeItems[0]).to(be(item))
                    expect(counter).to(equal(1))
                }
            }
        }
        
        
        // MARK: - Refresh Functions
        
        describe("when refreshed") {
            
            var sheet: ActionSheet!
            var headerViewContainer: UIView!
            var itemsView: UITableView!
            var buttonsView: UITableView!
            
            beforeEach {
                sheet = createSheet()
                sheet.appearance.cornerRadius = 90
                headerViewContainer = UIView(frame: .zero)
                itemsView = UITableView(frame: .zero)
                buttonsView = UITableView(frame: .zero)
                sheet.headerViewContainer = headerViewContainer
                sheet.itemsTableView = itemsView
                sheet.buttonsTableView = buttonsView
            }
            
            it("applies round corners") {
                sheet.refresh()
                
                expect(headerViewContainer.layer.cornerRadius).to(equal(90))
                expect(itemsView.layer.cornerRadius).to(equal(90))
                expect(buttonsView.layer.cornerRadius).to(equal(90))
            }
            
            context("when refreshing header") {
                
                it("hides header container if header is nil") {
                    sheet.refresh()
                    
                    expect(headerViewContainer.isHidden).to(beTrue())
                }
                
                it("shows header container if header is nil") {
                    let header = UIView(frame: .zero)
                    sheet.headerView = header
                    sheet.refresh()
                    
                    expect(headerViewContainer.isHidden).to(beFalse())
                }
                
                it("adds header view to header container") {
                    let header = UIView(frame: .zero)
                    sheet.headerView = header
                    expect(header.constraints.count).to(equal(0))
                    sheet.refresh()
                    
                    expect(headerViewContainer.subviews.count).to(equal(1))
                    expect(headerViewContainer.subviews[0]).to(be(header))
                    expect(header.translatesAutoresizingMaskIntoConstraints).to(beFalse())
                }
            }
            
            context("when refreshing items") {
                
                it("applies appearances to all items") {
                    let item1 = MockActionSheetItem(title: "foo")
                    let item2 = MockActionSheetItem(title: "foo")
                    sheet.setup(items: [item1, item2])
                    sheet.refresh()
                    
                    expect(item1.applyAppearanceInvokeCount).to(equal(1))
                    expect(item2.applyAppearanceInvokeCount).to(equal(1))
                    expect(item1.applyAppearanceInvokeAppearances[0]).to(be(sheet.appearance))
                    expect(item2.applyAppearanceInvokeAppearances[0]).to(be(sheet.appearance))
                }
                
                it("applies separator color") {
                    sheet.appearance.itemsSeparatorColor = .yellow
                    let view = UITableView(frame: .zero)
                    sheet.itemsTableView = view
                    sheet.refresh()
                    
                    expect(view.separatorColor).to(equal(.yellow))
                }
            }
            
            context("when refreshing buttons") {
                
                it("applies appearances to all buttons") {
                    let item1 = MockActionSheetButton(title: "foo")
                    let item2 = MockActionSheetButton(title: "foo")
                    sheet.setup(items: [item1, item2])
                    sheet.refresh()
                    
                    expect(item1.applyAppearanceInvokeCount).to(equal(1))
                    expect(item2.applyAppearanceInvokeCount).to(equal(1))
                    expect(item1.applyAppearanceInvokeAppearances[0]).to(be(sheet.appearance))
                    expect(item2.applyAppearanceInvokeAppearances[0]).to(be(sheet.appearance))
                }
                
                it("applies separator color") {
                    sheet.appearance.buttonsSeparatorColor = .yellow
                    let view = UITableView(frame: .zero)
                    sheet.buttonsTableView = view
                    sheet.refresh()
                    
                    expect(view.separatorColor).to(equal(.yellow))
                }
            }
        }
        
        
        
        // MARK: - Setup
        
//        describe("setup") {
//
//            it("makes view background clear") {
//                let sheet = createSheet(withItems: [])
//                sheet.view.backgroundColor = .red
//                sheet.setup()
//                expect(sheet.view.backgroundColor).to(equal(UIColor.clear))
//            }
//        }
//
//
//        // MARK: - View Controller Lifecycle
//
//        describe("laying out subviews") {
//
//            it("refreshes sheet") {
//                let sheet = createSheet(withItems: [])
//                sheet.viewDidLayoutSubviews()
//                expect(sheet.refreshInvokeCount).to(equal(1))
//            }
//        }
//
//
//        // MARK: - Actions
//
//        describe("item select action") {
//
//            it("can be overwritten") {
//                var counter = 0
//                let sheet = createSheet(withItems: [])
//                sheet.selectAction = { _, _  in counter += 1 }
//                sheet.selectAction(sheet, ActionSheetItem(title: "foo"))
//                expect(counter).to(equal(1))
//            }
//        }
//
//        describe("item tap action") {
//
//            var counter = 0
//
//            beforeEach {
//                counter = 0
//                sheet = MockActionSheet(items: []) { _, _  in counter += 1 }
//            }
//
//            it("can be overwritten") {
//                var counter = 0
//                sheet = createSheet(withItems: [])
//                sheet.tapAction = { _  in counter += 1 }
//                sheet.tapAction(ActionSheetItem(title: "foo"))
//                expect(counter).to(equal(1))
//            }
//
//            it("triggers select action") {
//                let item = ActionSheetItem(title: "foo")
//                sheet.tapAction(item)
//                expect(counter).to(beGreaterThan(0))
//            }
//
//            it("dismisses sheet if item should") {
//                let item = ActionSheetItem(title: "foo")
//                sheet.tapAction(item)
//                expect(sheet.dismissInvokeCount).to(equal(1))
//            }
//
//            it("does not dismiss sheet if item should not") {
//                let item = ActionSheetItem(title: "foo")
//                item.tapBehavior = .none
//                sheet.tapAction(item)
//                expect(sheet.dismissInvokeCount).to(equal(0))
//            }
//        }
//
//
//        // MARK: - Properties
//
//        describe("available item height") {
//
//            func getReducedHeight(for sheet: ActionSheet) -> CGFloat {
//                let screenHeight = UIScreen.main.bounds.height
//                let margins = 2 * sheet.margin(at: .top) + sheet.margin(at: .bottom)
//                let availableHeight = screenHeight - margins
//                return availableHeight - sheet.availableItemHeight
//            }
//
//            it("uses all available space if sheet takes up no other space") {
//                let sheet = createSheet(withItems: [])
//                sheet.appearance.contentInset = 0
//                let height = getReducedHeight(for: sheet)
//                expect(height).to(equal(0))
//            }
//
//            it("removes header view size") {
//                let sheet = createSheet(withItems: [])
//                sheet.appearance.contentInset = 0
//                sheet.headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
//                let height = getReducedHeight(for: sheet)
//                expect(height).to(equal(100))
//            }
//
//            it("removes button total size") {
//                let item = ActionSheetOkButton(title: "")
//                let sheet = createSheet(withItems: [item, item])
//                sheet.appearance.contentInset = 0
//                sheet.appearance.okButton.height = 40
//                sheet.refresh()
//                let height = getReducedHeight(for: sheet)
//                expect(height).to(equal(80))
//            }
//        }
//
//        describe("buttons section height") {
//
//            let ok = ActionSheetOkButton(title: "OK")
//            let cancel = ActionSheetCancelButton(title: "Cancel")
//            let item1 = ActionSheetItem(title: "foo")
//            let item2 = ActionSheetItem(title: "bar")
//
//            it("is zero if sheet has no buttons") {
//                let sheet = createSheet(withItems: [item1, item2])
//                expect(sheet.buttonsSectionHeight).to(equal(0))
//            }
//
//            it("has correct value if sheet has buttons") {
//                let sheet = createSheet(withItems: [item1, item2, ok, cancel])
//                sheet.refresh()
//                expect(sheet.buttonsSectionHeight).to(equal(50))
//            }
//        }
//
//        describe("buttons view height") {
//
//            let ok = ActionSheetOkButton(title: "OK")
//            let cancel = ActionSheetCancelButton(title: "Cancel")
//            let item1 = ActionSheetItem(title: "foo")
//            let item2 = ActionSheetItem(title: "bar")
//
//            it("is zero if sheet has no buttons") {
//                let sheet = createSheet(withItems: [item1, item2])
//                expect(sheet.buttonsViewHeight).to(equal(0))
//            }
//
//            it("has correct value if sheet has buttons") {
//                let sheet = createSheet(withItems: [item1, item2, ok, cancel])
//                sheet.refresh()
//                expect(sheet.buttonsViewHeight).to(equal(50))
//            }
//        }
//
//        describe("content size height") {
//
//            let title = ActionSheetTitle(title: "Sheeeeeeeeet!")
//            let item1 = ActionSheetItem(title: "foo")
//            let item2 = ActionSheetItem(title: "bar")
//            let button = ActionSheetOkButton(title: "OK")
//
//            context("with only items") {
//
//                beforeEach {
//                    sheet = createSheet(withItems: [title, item1, item2])
//                    sheet.refresh()
//                }
//
//                it("has correct content height") {
//                    expect(sheet.contentSize.height).to(equal(150))
//                }
//            }
//
//            context("with header") {
//
//                beforeEach {
//                    sheet = createSheet(withItems: [title, item1, item2])
//                    sheet.headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
//                    sheet.refresh()
//                }
//
//                it("has correct content height") {
//                    expect(sheet.contentSize.height).to(equal(260))
//                }
//            }
//
//            context("with buttons") {
//
//                beforeEach {
//                    sheet = createSheet(withItems: [title, item1, item2, button])
//                    sheet.refresh()
//                }
//
//                it("has correct content height") {
//                    expect(sheet.contentSize.height).to(equal(180))
//                }
//            }
//
//            context("with header and buttons") {
//
//                beforeEach {
//                    sheet = createSheet(withItems: [title, item1, item2, button])
//                    sheet.headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
//                    sheet.refresh()
//                }
//
//                it("has correct content height") {
//                    expect(sheet.contentSize.height).to(equal(290))
//                }
//            }
//        }
//
//        describe("content size width") {
//
//            it("uses preferred content size width") {
//                let sheet = createSheet(withItems: [])
//                sheet.preferredContentSize.width = 123
//                expect(sheet.contentSize.width).to(equal(123))
//            }
//        }
//
//        describe("header section height") {
//
//            it("is zero of sheet has no header view") {
//                let sheet = createSheet(withItems: [])
//                expect(sheet.headerSectionHeight).to(equal(0))
//            }
//
//            it("has correct value if sheet has header view") {
//                let sheet = createSheet(withItems: [])
//                let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
//                sheet.headerView = view
//                expect(sheet.headerSectionHeight).to(equal(110))
//            }
//        }
//
//        describe("header view height") {
//
//            it("is zero of sheet has no header view") {
//                let sheet = createSheet(withItems: [])
//                sheet.refresh()
//                expect(sheet.headerViewHeight).to(equal(0))
//            }
//
//            it("has correct value if sheet has header view") {
//                let sheet = createSheet(withItems: [])
//                let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
//                sheet.headerView = view
//                expect(sheet.headerViewHeight).to(equal(100))
//            }
//        }
//
//        describe("items section height") {
//
//            let ok = ActionSheetOkButton(title: "OK")
//            let cancel = ActionSheetCancelButton(title: "Cancel")
//            let item1 = ActionSheetItem(title: "foo")
//            let item2 = ActionSheetItem(title: "bar")
//
//            it("is zero if sheet has no items") {
//                let sheet = createSheet(withItems: [ok, cancel])
//                expect(sheet.itemsSectionHeight).to(equal(0))
//            }
//
//            it("has correct value if sheet has items") {
//                let sheet = createSheet(withItems: [item1, item2, ok, cancel])
//                sheet.refresh()
//                expect(sheet.itemsSectionHeight).to(equal(110))
//            }
//        }
//
//        describe("items view height") {
//
//            let ok = ActionSheetOkButton(title: "OK")
//            let cancel = ActionSheetCancelButton(title: "Cancel")
//            let item1 = ActionSheetItem(title: "foo")
//            let item2 = ActionSheetItem(title: "bar")
//
//            it("is zero if sheet has no items") {
//                let sheet = createSheet(withItems: [ok, cancel])
//                expect(sheet.itemsViewHeight).to(equal(0))
//            }
//
//            it("has correct value if sheet has items") {
//                let sheet = createSheet(withItems: [item1, item2, ok, cancel])
//                sheet.refresh()
//                expect(sheet.itemsViewHeight).to(equal(100))
//            }
//        }
//
//        describe("preferred content size") {
//
//            it("uses content height") {
//                let item1 = ActionSheetItem(title: "foo")
//                let item2 = ActionSheetItem(title: "bar")
//                let items = [item1, item2]
//                let sheet = createSheet(withItems: items)
//                sheet.preferredContentSize = CGSize(width: 10, height: 20)
//
//                expect(sheet.preferredContentSize.height).to(equal(100))
//            }
//        }
//
//        describe("preferred popover width") {
//
//            let item1 = ActionSheetItem(title: "foo")
//            let item2 = ActionSheetItem(title: "bar")
//
//            beforeEach {
//                sheet = createSheet(withItems: [item1, item2])
//            }
//
//            it("uses appearance width") {
//                sheet.appearance.popover.width = 123
//                expect(sheet.preferredPopoverSize.width).to(equal(123))
//            }
//
//            it("uses content height") {
//                expect(sheet.preferredPopoverSize.height).to(equal(100))
//            }
//        }
//
//
//        // MARK: - View Properties
//
//        describe("buttons view") {
//
//            it("is lazily created") {
//                let sheet = createSheet(withItems: [])
//                let view = sheet.buttonsView
//                expect(view.dataSource).to(be(sheet.buttonHandler))
//                expect(view.delegate).to(be(sheet.buttonHandler))
//                expect(view.isScrollEnabled).to(beFalse())
//            }
//        }
//
//        describe("header view") {
//
//            describe("when set") {
//
//                it("adds header view to action sheet view") {
//                    let sheet = createSheet(withItems: [])
//                    let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
//                    sheet.headerView = header
//                    expect(header.superview).to(be(sheet.view))
//                }
//
//                it("removes previous header view from superview") {
//                    let sheet = createSheet(withItems: [])
//                    let header1 = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
//                    let header2 = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
//                    sheet.headerView = header1
//                    sheet.headerView = header2
//                    expect(header1.superview).to(beNil())
//                    expect(header2.superview).to(be(sheet.view))
//                }
//            }
//        }
//
//        describe("items view") {
//
//            it("is lazily created") {
//                let sheet = createSheet(withItems: [])
//                let view = sheet.itemsView
//                expect(view.dataSource).to(be(sheet.itemHandler))
//                expect(view.delegate).to(be(sheet.itemHandler))
//                expect(view.isScrollEnabled).to(beFalse())
//            }
//        }
//
//
//        // MARK: - Presentation Function
//
//        describe("dismissing sheet") {
//
//            beforeEach {
//                sheet = createSheet(withItems: [])
//                presenter = MockActionSheetPresenter()
//                sheet.presenter = presenter
//            }
//
//            it("calls presenter with completion") {
//                var count = 0
//                let completion: () -> () = { count += 1 }
//                sheet.dismiss(completion: completion)
//                presenter.dismissInvokeCompletions[0]()
//                expect(presenter.dismissInvokeCount).to(equal(1))
//                expect(count).to(equal(1))
//            }
//        }
//
//        describe("presenting from view") {
//
//            beforeEach {
//                sheet = createSheet(withItems: [])
//                presenter = MockActionSheetPresenter()
//                sheet.presenter = presenter
//            }
//
//            it("refreshes sheet") {
//                sheet.present(in: UIViewController(), from: UIView())
//                expect(sheet.refreshInvokeCount).to(equal(1))
//            }
//
//            it("calls presenter with values and completion") {
//                let vc = UIViewController()
//                let view = UIView()
//                sheet.present(in: vc, from: view)
//                expect(presenter.presentInvokeCount).to(equal(1))
//                expect(presenter.presentInvokeViewControllers[0]).to(be(vc))
//                expect(presenter.presentInvokeViews[0]).to(be(view))
//            }
//        }
//
//        describe("presenting from bar button item") {
//
//            beforeEach {
//                sheet = createSheet(withItems: [])
//                presenter = MockActionSheetPresenter()
//                sheet.presenter = presenter
//            }
//
//            it("refreshes sheet") {
//                sheet.present(in: UIViewController(), from: UIView())
//                expect(sheet.refreshInvokeCount).to(equal(1))
//            }
//
//            it("calls presenter with values and completion") {
//                let vc = UIViewController()
//                let item = UIBarButtonItem()
//                sheet.present(in: vc, from: item)
//                expect(presenter.presentInvokeCount).to(equal(1))
//                expect(presenter.presentInvokeViewControllers[0]).to(be(vc))
//                expect(presenter.presentInvokeTabBarItems[0]).to(be(item))
//            }
//        }
//
//
//        // MARK: - Public Functions
//
//        describe("item at index path") {
//
//            it("returns correct item") {
//                let item1 = ActionSheetItem(title: "")
//                let item2 = ActionSheetItem(title: "")
//                let item3 = ActionSheetItem(title: "")
//                sheet = createSheet(withItems: [item1, item2, item3])
//                let index = IndexPath(row: 1, section: 0)
//                expect(sheet.item(at: index)).to(be(item2))
//            }
//
//            it("looks in adjusted item collection") {
//                let item1 = ActionSheetItem(title: "")
//                let item2 = ActionSheetOkButton(title: "")
//                let item3 = ActionSheetItem(title: "")
//                sheet = createSheet(withItems: [item1, item2, item3])
//                let index = IndexPath(row: 1, section: 0)
//                expect(sheet.item(at: index)).to(be(item3))
//            }
//        }
//
//        describe("setting up items and buttons with item array") {
//
//            it("separates items into items and buttons") {
//                let button = ActionSheetOkButton(title: "Sheeeeeeeeet!")
//                let item1 = ActionSheetItem(title: "foo")
//                let item2 = ActionSheetItem(title: "bar")
//                let items = [item1, item2, button]
//                let sheet = createSheet(withItems: [])
//                sheet.setupItemsAndButtons(with: items)
//
//                expect(sheet.items.count).to(equal(2))
//                expect(sheet.items[0]).to(be(item1))
//                expect(sheet.items.last!).to(be(item2))
//
//                expect(sheet.buttons.count).to(equal(1))
//                expect(sheet.buttons[0]).to(be(button))
//            }
//        }
    }
}
