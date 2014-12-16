Weather
=======
Level: Beginner  
Technologies: Swift, iOS  
Summary: A basic example of aerogear-ios-http  

What is it?
-----------

This project is a very simple app, to show how to do a http call against a simple REST endpoint. The demo is implemented in [Swift](https://developer.apple.com/swift/) and uses the [aerogear-ios-http](https://github.com/aerogear/aerogear-ios-http) library. 

System requirements
-------------------
- iOS 8.X
- Xcode version 6 Beta 6

Configure
---------
Nothing to be done. 
The app fetches data from http://api.openweathermap.org/data/2.5/weather

Build and Deploy Buddies
------------------------

### Run it in Xcode

The demo utilizes [cocoapods](http://cocoapods.org) for handling it's dependencies. On the root directory, simply execute the following:

```bash
bundle install
bundle exec pod install
```

and then double click on the generated .xcworkspace to open in Xcode.

Application Flow
----------------

When the application is launched for the first time, it will prompt you to accept to share your current location

![import](weather.png)

Once you've accepted, it will display weather forecast in your area:

![import](weather2.png)
