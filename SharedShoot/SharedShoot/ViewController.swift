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
import UIKit

class ViewController: UIViewController {
    var userInfo: OpenIDClaim?
    var keycloakHttp = Http()
    var facebookHttp = Http()
    var googleHttp = Http()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "seeImages:" {
        
        self.keycloakHttp.GET("http://localhost:8080/shoot/photos", parameters: nil, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
                if error != nil {
                    println("ERROR::\(error)")
                }
                println("Get list of photos::\(response)")
            })
        }
    }

    @IBAction func loginAsFacebook(sender: AnyObject) {
        let facebookConfig = FacebookConfig(
            clientId: "YYY",
            clientSecret: "XXX",
            scopes:["photo_upload, publish_actions"],
            isOpenIDConnect: true)
        var oauth2Module = AccountManager.addFacebookAccount(facebookConfig)
        self.facebookHttp.authzModule = oauth2Module
        oauth2Module.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in
            println(">>> Facebook: \n\(claims)")
            self.userInfo = claims
            self.performSegueWithIdentifier("seeImages:", sender: self)
        }
    }
    
    @IBAction func loginAsKeycloak(sender: AnyObject) {
        let keycloakConfig = KeycloakConfig(
            clientId: "sharedshoot-third-party",
            host: "http://localhost:8080",
            realm: "shoot-realm",
            isOpenIDConnect: true)
        var oauth2Module = AccountManager.addKeycloakAccount(keycloakConfig)
        self.keycloakHttp.authzModule = oauth2Module
        oauth2Module.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in
            println(">>> Keycloak: \n\(claims)")
            self.userInfo = claims
            //self.performSegueWithIdentifier("seeImages:", sender: self)
            
            
            self.keycloakHttp.GET("http://localhost:8080/shoot/photos", parameters: nil, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
                if error != nil {
                    println("ERROR::\(error)")
                }
                println("Get list of photos::\(response)")
            })


        }
    }
    
    @IBAction func loginAsGoogle(sender: AnyObject) {
        let googleConfig = GoogleConfig(
            clientId: "302356789040-eums187utfllgetv6kmbems0pm3mfhgl.apps.googleusercontent.com",
            scopes:["https://www.googleapis.com/auth/drive"],
            isOpenIDConnect: true)
        var oauth2Module = AccountManager.addGoogleAccount(googleConfig)
        self.googleHttp.authzModule = oauth2Module
        oauth2Module.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in
            println(">>> Google:\n\(claims)")
            self.userInfo = claims
            self.performSegueWithIdentifier("seeImages:", sender: self)
        }
    }
}

