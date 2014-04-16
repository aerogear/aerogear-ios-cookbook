# Keycloak demo

A simple example that uses Aerogear iOS lib to authorize against Keycloak. [video link](https://vimeo.com/87862111)

The project requires [CocoaPods](http://cocoapods.org/) for dependency management;

### Setup

Please make sure a [Keycloak server](http://www.jboss.org/keycloak) is running and the demo examples that come with the distribution have been deployed. [Click here](https://github.com/keycloak/keycloak/tree/master/examples/demo-template) for setup instructions.

Go to Keycloack OAuth Clients, make sure the client type is public and you added the redirect URI that matches the one expected in you client code.
![Keycloack OAUth2 configuration](https://github.com/corinnekrych/KeycloakDemo/raw/master/KeycloackConfigOAuth2.png "Keycloack OAUth2 configuration")

Once this is done, run the following command in the project's directory to install cocoapods dependencies.

    pod install

Now you are almost done! You just need to open the KeycloakDemo.xcworkspace in order to run the demo!


