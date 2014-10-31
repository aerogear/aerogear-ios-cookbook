//
//  Info.swift
//  AeroGearSyncDemo
//
//  Created by Daniel Bevenius on 30/10/14.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import Foundation

public class Info : Printable {

    public typealias Json = Dictionary<String, AnyObject>

    public let name: String
    public let profession: String
    public let hobbies: Array<Json>

    public init(name: String, profession: String, hobbies: Array<Json>) {
        self.name = name;
        self.profession = profession
        self.hobbies = hobbies
    }

    public convenience init(dict: Dictionary<String, AnyObject>) {
        self.init(name: dict["name"]! as String,
            profession: dict["profession"]! as String,
            hobbies: dict["hobbies"]! as Array<Json>)
    }

    public var description: String {
        return "Info[name=\(name), profession=\(profession), hobbies=\(hobbies)"
    }
}

