//
//  Info.swift
//  AeroGearSyncDemo
//
//  Created by Daniel Bevenius on 30/10/14.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import Foundation
import AeroGearSync

public class Info : Printable {

    public let name: String
    public let profession: String
    public let hobbies: Array<Hobby>

    public init(name: String, profession: String, hobbies: Array<Hobby>) {
        self.name = name;
        self.profession = profession
        self.hobbies = hobbies
    }

    public convenience init(dict: JsonNode) {
        self.init(name: dict["name"]! as String,
            profession: dict["profession"]! as String,
            hobbies: (dict["hobbies"] as Array<JsonNode>).map { Hobby(desc: $0["description"]! as String) })
    }

    public var description: String {
        return "Info[name=\(name), profession=\(profession), hobbies=\(hobbies)"
    }

    public class Hobby : Printable {

        public let desc: String

        public init(desc: String) {
            self.desc = desc
        }

        public var description: String {
            return "Hobby[description=\(description)]"
        }
    }
}

