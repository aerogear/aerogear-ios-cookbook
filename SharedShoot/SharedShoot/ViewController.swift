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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginAsFacebook(sender: AnyObject) {
        var http = Http()
        let facebookConfig = FacebookConfig(
            clientId: "YYY",
            clientSecret: "XXX",
            scopes:["photo_upload, publish_actions"],
            isOpenIDConnect: true)
        var oauth2Module = AccountManager.addFacebookAccount(facebookConfig)
        http.authzModule = oauth2Module
        oauth2Module.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in
            println(">>> Facebook: \n\(claims)")
        }
    }
    
    @IBAction func loginAsKeycloak(sender: AnyObject) {
        var http = Http()
        let keycloakConfig = KeycloakConfig(
            clientId: "sharedshoot-third-party",
            host: "http://localhost:8080",
            realm: "shoot-realm",
            isOpenIDConnect: true)
        var oauth2Module = AccountManager.addKeycloakAccount(keycloakConfig)
        http.authzModule = oauth2Module
        oauth2Module.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in
            println(">>> Keycloak: \n\(claims)")
        }
    }
    
    @IBAction func loginAsGoogle(sender: AnyObject) {
        var http = Http()
        let googleConfig = GoogleConfig(
            clientId: "302356789040-eums187utfllgetv6kmbems0pm3mfhgl.apps.googleusercontent.com",
            scopes:["https://www.googleapis.com/auth/drive"],
            isOpenIDConnect: true)
        var oauth2Module = AccountManager.addGoogleAccount(googleConfig)
        http.authzModule = oauth2Module
        oauth2Module.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in
            println(">>> Google:\n\(claims)")
        }
    }
}

