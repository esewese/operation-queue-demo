//
//  Item.swift
//  OperationQueueExample
//
//  Created by Esko Vähämäki on 25/09/16.
//  Copyright © 2016 Tuxera. All rights reserved.
//

import Foundation

/// Example Item to be presented on the collection view
class Item {
    
    let i: Int
    
    static func createItems(n: Int) -> [Item] {
        var items = [Item]()
        for i in 0...n {
            items.append(Item(i: i))
        }
        return items
    }
    
    init(i: Int = 0) {
        self.i = i
    }
    
    func url() -> URL? {
        return URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=image+\(i)&w=300&h=300")
    }
}
