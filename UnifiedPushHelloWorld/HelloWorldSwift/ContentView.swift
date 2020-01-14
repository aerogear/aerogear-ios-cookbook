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

import SwiftUI

struct ContentView: View {
    @ObservedObject var notificationListModel = ListViewModel()
    
    init() {
        UINavigationBar.appearance().backgroundColor = UIColor.orange
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notificationListModel.items, id: \.self) { msg in
                    Text(msg)
                }
            }
            .navigationBarTitle(Text("Notifications"), displayMode: .inline)
        }.navigationViewStyle(StackNavigationViewStyle())
            .onAppear(perform: notificationListModel.registerForEvents)
            .alert(isPresented: $notificationListModel.failure, content: {
                Alert(title: Text("Registration Error!"), message: Text("Please verify the provisionioning profile and the UPS details have been setup correctly."))
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class ListViewModel: ObservableObject {
    @Published var items: [String] = []
    @Published var failure = false
    
    func addItem() {
        items.append("Item");
    }
    
    fileprivate func registerForEvents() {
        // register to be notified when state changes
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewModel.registered), name: Notification.Name(rawValue: "success_registered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewModel.errorRegistration), name: Notification.Name(rawValue: "error_register"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewModel.messageReceived(_:)), name: Notification.Name(rawValue: "message_received"), object: nil)
    }
    
    @objc func registered() {
        print("registered")
        
        // workaround to get messages when app was not running
        let defaults: UserDefaults = UserDefaults.standard;
        if let obj = defaults.object(forKey: "message_received") {
            defaults.removeObject(forKey: "message_received")
            defaults.synchronize()
    
            if let msg = obj as? String {
                items.append(msg)
            }
        }
    }
    
    @objc func errorRegistration() {
        failure = true
    }
    
    @objc func messageReceived(_ notification: Notification) {
        print("received")
        if let userInfo = notification.userInfo, let aps = userInfo["aps"] as? [String: Any] {
            // if alert is a flat string
            if let msg = aps["alert"] as? String {
                items.append(msg)
            } else if let obj = aps["alert"] as? [String: Any], let msg = obj["body"] as? String {
                // if the alert is a dictionary we need to extract the value of the body key
                items.append(msg)
            }
        }
    }
}
