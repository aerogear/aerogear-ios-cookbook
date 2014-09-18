# Keycloak demo

A simple example that uses Aerogear iOS lib to authorize against Keycloak. 

The project requires [CocoaPods](http://cocoapods.org/) for dependency management;

### Pre-requisites
Please make sure a [Keycloak server](http://www.jboss.org/keycloak) is running, please refer to [server side readme instructions](https://github.com/aerogear/aerogear-backend-cookbook). 

Go to Keycloack OAuth Clients, make sure the client type is public and you added the redirect URI that matches the one expected in you client code. It should be all configured properly if you imported testrealm.json.
![Keycloack OAUth2 configuration](https://github.com/aerogear/aerogear-ios-cookbook/raw/master/ProductInventory/KeycloackConfigOAuth2.png "Keycloack OAUth2 configuration")

### Setup

In ```ProductsViewController.m```, change localhost for your address.

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

In ```AppDelegate.m```, implement ```application:openURL:sourceApplication``` callback to notify OAuth2Module the user has granted or cancel access:


```
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSNotification *notification = [NSNotification notificationWithName:@"AGAppLaunchedWithURLNotification" object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:UIApplicationLaunchOptionsURLKey]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    return YES;
}
```

### Build and deploy

Once this is done, run the following command in the project's directory to install cocoapods dependencies.

    pod install

Now you are almost done! You just need to open the KeycloakDemo.xcworkspace in order to run the demo!


