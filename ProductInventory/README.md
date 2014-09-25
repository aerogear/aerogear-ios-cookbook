# Keycloak demo

A simple example that uses aerogear-ios-http and aerogear-ios-oauth2 lib to authorize against Keycloak. 

### Pre-requisites
Please make sure a [Keycloak server](http://www.jboss.org/keycloak) is running, please refer to [server side readme instructions](https://github.com/aerogear/aerogear-backend-cookbook). 

Go to Keycloack OAuth Clients, make sure the client type is public and you added the redirect URI that matches the one expected in you client code. It should be all configured properly if you imported testrealm.json.
![Keycloack OAUth2 configuration](https://github.com/aerogear/aerogear-ios-cookbook/raw/swift/ProductInventory/keycloak-oauth2-condole.png "Keycloack OAuth2 configuration")

### Setup

If you want to test on actual device, rather than on simulator, don't forget to change localhost for your IP address in ```ProductsViewController.swift```.

### How does it work?
In ```KeycloakDemo-Info.plist```, a URL schema has been defined as below

```
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>org.aerogear.KeycloakDemo</string>
			</array>
		</dict
	</array>
```
to be able to come back from external browser to the app

In ```AppDelegate.swift```, implement ```application:openURL:sourceApplication``` callback to notify OAuth2Module the user has granted or cancel access:


```
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        var notification = NSNotification(name: "AGAppLaunchedWithURLNotification", object: nil, userInfo: [UIApplicationLaunchOptionsURLKey: url])
        NSNotificationCenter.defaultCenter().postNotification(notification)
        return true
    }
```

### Build and deploy
Run it on simulator or device from Xcode.

