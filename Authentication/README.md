Authentication
=======
Level: Beginner  
Technologies: Swift, iOS  
Summary: A basic example of performing http basic/digest authentication using aerogear-ios-http

What is it?
-----------

This project is a very simple app, to show how to perform an HTTP Basic/Digest authentication against a simple REST endpoint. The demo is implemented in [Swift](https://developer.apple.com/swift/) and uses the [aerogear-ios-http](https://github.com/aerogear/aerogear-ios-http) library. Backend REST endpoint is implemented in this [repo](https://github.com/aerogear/aerogear-backend-cookbook/tree/master/Authentication). For convenience an [OpenShift instance](http://igtests-cvasilak.rhcloud.com/rest/team/developers) has been deployed and the demo has been preconfigured to use it. Please make sure it is not idle before running the app, by hitting the URL in your browser. 

System requirements
-------------------
- iOS7, iOS8, iOS9
- Xcode7

Configure
---------
Either run a [backend instance locally](https://github.com/aerogear/aerogear-backend-cookbook/tree/master/Authentication) or use the [OpenShift instance](http://igtests-cvasilak.rhcloud.com/) . To verify that the server is indeed running, [click here](https://igtests-cvasilak.rhcloud.com/rest/grocery/beers) (user: ```john``` pass:```123```) for the HTTP Basic protected endpoint, or [click here](https://igtests-cvasilak.rhcloud.com/rest/grocery/bacons) (user: ```agnes``` pass: ```123```) for the HTTP Digest authentication endpoint.


> **NOTE:**  It is advised that HTTPS should be used by default when performing authentication of this type. For convenience of deployment, in this example we use HTTP in the backend example but you should opt to enable HTTPS in your application server of choice.

Build and Deploy
------------------------

### Change URL

If you deploy the backend locally, in Network.swift, update the URL accordingly:

```swift
    static let instance = Http(baseURL: "http://localhost:8080/authentication")
...
}
```

### Run it in Xcode

The project uses [cocoapods](http://cocoapods.org) for handling its dependencies. As a pre-requisite, install [cocoapods](http://blog.cocoapods.org/) and then install the pod. On the root directory of the project run:

```bash
pod install
```
and then double click on the generated .xcworkspace to open in Xcode.

Application Flow
----------------
When the application is launched, you will presented with two tabs in which the former fetches data after performing HTTP basic and the latter after performing HTTP digest.

 ![import](screenshot-auth-basic.png)   ![import](screenshot-auth-digest.png) 
