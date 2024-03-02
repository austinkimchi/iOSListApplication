//
//  ToDoItem.swift
//  ToDoListApp
//
//  Created by Austin Kim on 3/1/24.
//

import UIKit

class ToDoItem: NSObject {
    var name = "";
    var desc = "";
    var time = "";
    var cat = "";
    
    init(name: String = "", desc: String = "", time: String = "", cat: String = "") {
        self.name = name;
        self.desc = desc;
        self.time = time;
        self.cat = cat;
    }
}
