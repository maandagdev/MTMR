//
//  CustomGroupItem.swift
//  MTMR
//
//  Created by D on 05/02/2020.
//  Copyright © 2020 Anton Palgunov. All rights reserved.
//

import Foundation
import Cocoa

class CustomGroupBarItem: CustomButtonTouchBarItem, NSTouchBarDelegate {
    static var name: String = "customGroupBar"
    static var identifier: String = "com.toxblh.mtmr.customGroupBar"
    
    var jsonItems: [BarItemDefinition]
    
    var itemDefinitions: [NSTouchBarItem.Identifier: BarItemDefinition] = [:]
    var items: [NSTouchBarItem.Identifier: NSTouchBarItem] = [:]
    var leftIdentifiers: [NSTouchBarItem.Identifier] = []
    var centerIdentifiers: [NSTouchBarItem.Identifier] = []
    var centerItems: [NSTouchBarItem] = []
    var rightIdentifiers: [NSTouchBarItem.Identifier] = []
    var scrollArea: NSCustomTouchBarItem?
    var centerScrollArea = NSTouchBarItem.Identifier("com.toxblh.mtmr.scrollArea.".appending(UUID().uuidString))
    
    
    
    var touchar: NSTouchBar = NSTouchBar();
    var nsTouchItems: [NSTouchBarItem.Identifier] = []
    private let activity: NSBackgroundActivityScheduler
    
    init(identifier: NSTouchBarItem.Identifier, items: [BarItemDefinition]) {
        jsonItems = items
        activity = NSBackgroundActivityScheduler(identifier: "\(identifier.rawValue).updatecheck")
        activity.interval = 5.0
        //touchar = nil;
        super.init(identifier: identifier, title: "")
        
        
        tapClosure = { [weak self] in self?.showGroupBar() }
        //         longTapClosure = { [weak self] in self?.startStopRest() }
        
        
        activity.repeats = true
        activity.qualityOfService = .utility
        activity.schedule { (completion: NSBackgroundActivityScheduler.CompletionHandler) in
            DispatchQueue.main.async {
//                self.setMoonPhase();
            }
            completion(NSBackgroundActivityScheduler.Result.finished)
        }
    }
    
    func setMoonPhase() {
        
        // minimizeSystemModal(  TouchBarController.shared.touchBar)
        DispatchQueue.main.async {
            print("bye")
            //TouchBarController.shared.touchBar.defaultItemIdentifiers = []
            TouchBarController.shared.touchBar.defaultItemIdentifiers = self.nsTouchItems;
                
        }
    }
    deinit {
                activity.invalidate()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func showGroupBar() {
        touchar = TouchBarController.shared.touchBar
        if let oldBar = TouchBarController.shared.touchBar {
            
            minimizeSystemModal(oldBar)
        }
        
        TouchBarController.shared.touchBar = NSTouchBar()
        itemDefinitions = [:]
        items = [:]
        leftIdentifiers = []
        centerItems = []
        rightIdentifiers = []
        
        loadItemDefinitions(jsonItems: jsonItems)
        createItems()
        
        centerItems = centerIdentifiers.compactMap({ (identifier) -> NSTouchBarItem? in
            items[identifier]
        })
        
        centerScrollArea = NSTouchBarItem.Identifier("com.toxblh.mtmr.scrollArea.".appending(UUID().uuidString))
        scrollArea = ScrollViewItem(identifier: centerScrollArea, items: centerItems)
        
        TouchBarController.shared.touchBar.delegate = self
        TouchBarController.shared.touchBar.defaultItemIdentifiers = []
        TouchBarController.shared.touchBar.defaultItemIdentifiers = leftIdentifiers + [centerScrollArea] + rightIdentifiers
        
        nsTouchItems = TouchBarController.shared.touchBar.defaultItemIdentifiers
        if AppSettings.showControlStripState {
            presentSystemModal(TouchBarController.shared.touchBar, systemTrayItemIdentifier: .controlStripItem)
        } else {
            presentSystemModal(TouchBarController.shared.touchBar, placement: 1, systemTrayItemIdentifier: .controlStripItem)
        }
    }
    
    func touchBar(_: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        if identifier == centerScrollArea {
            return scrollArea
        }
        
        guard let item = self.items[identifier],
            let definition = self.itemDefinitions[identifier],
            definition.align != .center else {
                return nil
        }
        return item
    }
    
    func loadItemDefinitions(jsonItems: [BarItemDefinition]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH-mm-ss"
        let time = dateFormatter.string(from: Date())
        for item in jsonItems {
            let identifierString = item.type.identifierBase.appending(time + "--" + UUID().uuidString)
            let identifier = NSTouchBarItem.Identifier(identifierString)
            itemDefinitions[identifier] = item
            if item.align == .left {
                leftIdentifiers.append(identifier)
            }
            if item.align == .right {
                rightIdentifiers.append(identifier)
            }
            if item.align == .center {
                centerIdentifiers.append(identifier)
            }
        }
    }
    
    func createItems() {
        for (identifier, definition) in itemDefinitions {
            items[identifier] = TouchBarController.shared.createItem(forIdentifier: identifier, definition: definition)
        }
    }
}
