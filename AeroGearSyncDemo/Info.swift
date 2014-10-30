//
//  Info.swift
//  AeroGearSyncDemo
//
//  Created by Daniel Bevenius on 30/10/14.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import Foundation

public class Info {

    public let name: String
    public let profession: String
    public let hobbies: Array<String>

    public init(name: String, profession: String, hobbies: Array<String>) {
        self.name = name;
        self.profession = profession
        self.hobbies = hobbies
    }

    public func asJson() -> String {
        var json = "{\"name\":\"\(name)\",\"profession\":\"\(profession)\",\"hobbies\":["
        var i : Int
        for i = 0; i < hobbies.count; i++ {
            json += "\"\(hobbies[i])\""
            if i != hobbies.count-1 {
                json += ","
            }
        }
        json += "]}"
        return json
    }

}

