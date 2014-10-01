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

    var oauth2Module:OAuth2Module
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var revokeButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        var config = Config(base: "http://localhost:8080/auth",
            authzEndpoint: "realms/keycloak/tokens/login",
            redirectURL: "org.aerogear.KeycloakDemo://oauth2Callback",
            accessTokenEndpoint: "realms/keycloak/tokens/access/codes",
            clientId: "third-party",
            clientSecret: "3523250e-14c7-48fe-8be2-92aef4bcb149",
            refreshTokenEndpoint: "realms/keycloak/tokens/refresh",
            revokeTokenEndpoint: "realms/keycloak/tokens/logout")
        var session = UntrustedMemoryOAuth2Session(accountId: "MyAccount")
        self.oauth2Module = KeycloakOAuth2Module(config: config, accountId: "MyAccount", session: session)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.refreshButton.enabled = false
        self.revokeButton.enabled = false
        self.getButton.enabled = true
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getProductInventory(sender: UIButton) {
        var http = Http(url: "http://localhost:8080/keycloak/rest/products")
        http.authzModule = self.oauth2Module
        http.GET(completionHandler: { (response, error) in
            println("GET sucess \(response!)")
            dispatch_async(dispatch_get_main_queue(), {
                if (error == nil) {
                    self.revokeButton.enabled = true
                    self.refreshButton.enabled = true
                }
            })
        })
    }
    
    @IBAction func requestAccessToken(sender: UIButton) {
        println("---> Request access token")
        self.oauth2Module.requestAccess({(response, error) in
            println("AccessToken \(response)")
            dispatch_async(dispatch_get_main_queue(), {
                if (error == nil) {
                    self.revokeButton.enabled = true
                    self.refreshButton.enabled = true
                }
            })
        });
    }

    @IBAction func revokeTokens(sender: AnyObject) {
        println("---> Revoke tokens")
        // TODO AGIOS-206 waiting for KEYCLOAK-312
        self.oauth2Module.revokeAccess({(response, error) in
            println("RevokeToken .....")
            dispatch_async(dispatch_get_main_queue(), {
                if (error == nil) {
                    self.revokeButton.enabled = false
                    self.refreshButton.enabled = false
                }
            })

        })
    }
    
    @IBAction func requestRefreshToken(sender: UIButton) {       
        println("---> Request refresh token")
        self.oauth2Module.refreshAccessToken({(response, error) in
            println("RefreshToken \(response!)")
        })
    }
}
