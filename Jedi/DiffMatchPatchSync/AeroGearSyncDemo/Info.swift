/*
* JBoss, Home of Professional Open Source.
* Copyright Red Hat, Inc., and individual contributors
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation
import AeroGearSync

public class Info : Printable {
    
    public typealias Json = [String: AnyObject]
    
    public let name: String
    public let profession: String
    public let hobbies: [Hobby]
    
    public init(name: String, profession: String, hobbies: [Hobby]) {
        self.name = name;
        self.profession = profession
        self.hobbies = hobbies
    }
    
    public convenience init(dict: Json) {
        self.init(name: dict["name"]! as String,
            profession: dict["profession"]! as String,
            hobbies: (dict["hobbies"] as [Json]).map { Hobby(desc: $0["description"]! as String) })
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
            return "Hobby[description=\(desc)]"
        }
    }
}
