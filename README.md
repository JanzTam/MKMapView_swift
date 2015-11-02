# MKMapView_swift
Swift CLLocationManager demo,and show userLocation in mapView.
Build:Swift 2.0 , Xcode 7.1

**tips**

if your Xcode project only used Swift,you should set [Build settings->Embedded Content Contains Swift Code] 'yes'.

# Location
### asks user permission
add the key to info.plist

```objc
NSLocationWhenInUseUsageDescription
```

```objc
NSLocationAlwaysUsageDescription
```

I try ro add one key ,  however it is not even asks user permission. I add all that it worked.

### CLLocationManager

```objc

self.locateManage.delegate = self //请求定位权限

 if self.locateManage.respondsToSelector(Selector("requestAlwaysAuthorization")) {
            self.locateManage.requestAlwaysAuthorization()
        }
        
 self.locateManage.desiredAccuracy = kCLLocationAccuracyBest//定位精准度
 self.locateManage.startUpdatingLocation()//开始定位
 ```
