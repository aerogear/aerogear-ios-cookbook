Watch Howdy app
================
Level: Beginner  
Technologies: Swift, iOS9, WatchOS2  
Summary: A basic example of aerogear-ios-push with actionable action (text input).  

What is it?
-----------

Howdy is a very simple app that receive push notification asking you "how do you do?". You can do a direct reply on the push notification itself ([actionable push notification](http://blogs.imediaconnection.com/blog/2015/04/16/actionable-notifications-and-the-apple-watch/) available since iOS8). You can answer canned responses and since iOS9 "input text" is also possible. When push notification are received on watch the dictation is activated instead of keybord access.

Configuration
-------------
### Server side
Actionnable notification are supported in UnifiedPush 1.1.x+. 
You will need to deploy either [UnifiedPush Server locally or using OpenShift](https://aerogear.org/push/).

### Client side
In ```helloworldpush\info.plist``` configure plist with UPS information:
Replace SERVERL-URL, VARIANT-ID, VARIANT-SECRET from the on one provided for your Push app and variant.

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>  
    <key>serverURL</key>
    <string>https://SERVER-URL:SERVER-PORT/ag-push</string>
    <key>variantID</key>
    <string>VARIANT-ID</string>
    <key>variantSecret</key>
    <string>VARIANT-SECRET</string>    
</dict>
</plist>

```

**Note:** If you're running the server locally on development mode (ie: without TLS), you need to add a TLS1.2 exception in iOS9.

System requirements
-------------------
- iOS 9.X / WatchOS2
- Xcode version 7

Build and Deploy
----------------
### iOS app
In Xcode, select the target ```helloworldpush``` select either your iPhone or simulator.

### Watch
In Xcode, select the target ```helloworldpush WatchKit App``` select either your iPhone + paired watch or simulator.

Send Push Notification
----------------------

You can send simple push notification using the UnifiedPush Server console. But to be able to use actionable notification, we need to provide the ```action-category``` payload.

In this CURL replace your YOUR-APP-ID and YOUR-APP-MASTER-SECRET but the one available in the UnifiedPush Server console. Run this command to send a message.

```
curl -u "YOUR-APP-ID:YOUR-APP-MASTER-SECRET" -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"message": {"alert": "Howdy?","sound": "default","badge": 2, "apns": { "title" : "Hello apple watch", "action-category": "CATEGORY_ID", "content-available": true}},"config": {"ttl": 3600}}' http://SERVER-URL:SERVER-PORT/ag-push/rest/sender
```
