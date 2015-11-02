//
//  ViewController.swift
//  MKMapView_Swift
//
//  Created by kuaikuaizuche on 15/10/30.
//  Copyright © 2015年 JanzTam. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var mapViewLoca: MKMapView!
    
    var locateManage = CLLocationManager()
    
    var currentCoordinate:CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-------------CLLocationManager-------------
        self.locateManage.delegate = self
        //请求定位权限
        if self.locateManage.respondsToSelector(Selector("requestAlwaysAuthorization")) {
            self.locateManage.requestAlwaysAuthorization()
        }
        
        self.locateManage.desiredAccuracy = kCLLocationAccuracyBest//定位精准度
        self.locateManage.startUpdatingLocation()//开始定位
        
        //显示定位点
        self.mapViewLoca.showsUserLocation = true
        
    }
    
    //CLLocationManager定位代理方法
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("hello")
        if let newLoca = locations.last {
            CLGeocoder().reverseGeocodeLocation(newLoca, completionHandler: { (pms, err) -> Void in
                if let newCoordinate = pms?.last?.location?.coordinate {
                    //此处设置地图中心点为定位点，缩放级别18
                    self.mapViewLoca.setCenterCoordinateLevel(newCoordinate, zoomLevel: 15, animated: true)
                    manager.stopUpdatingLocation()//停止定位，节省电量，只获取一次定位
                    
                    self.currentCoordinate = newCoordinate
                    
                    //取得最后一个地标，地标中存储了详细的地址信息，注意：一个地名可能搜索出多个地址
                    let placemark:CLPlacemark = (pms?.last)!
                    let location = placemark.location;//位置
                    let region = placemark.region;//区域
                    let addressDic = placemark.addressDictionary;//详细地址信息字典,包含以下部分信息
//                    let name=placemark.name;//地名
//                    let thoroughfare=placemark.thoroughfare;//街道
//                    let subThoroughfare=placemark.subThoroughfare; //街道相关信息，例如门牌等
//                    let locality=placemark.locality; // 城市
//                    let subLocality=placemark.subLocality; // 城市相关信息，例如标志性建筑
//                    let administrativeArea=placemark.administrativeArea; // 州
//                    let subAdministrativeArea=placemark.subAdministrativeArea; //其他行政区域信息
//                    let postalCode=placemark.postalCode; //邮编
//                    let ISOcountryCode=placemark.ISOcountryCode; //国家编码
//                    let country=placemark.country; //国家
//                    let inlandWater=placemark.inlandWater; //水源、湖泊
//                    let ocean=placemark.ocean; // 海洋
//                    let areasOfInterest=placemark.areasOfInterest; //关联的或利益相关的地标
                    print(location,region,addressDic)
                }
            })
        }
    }


    @IBAction func resetLocate(sender: UIButton) {
        if let _coordinate = self.currentCoordinate {
            self.mapViewLoca.setCenterCoordinate(_coordinate, animated: true)
        }
        else {
            self.locateManage.startUpdatingLocation()
        }
        
        print("点击定位")
    }
}

extension MKMapView {
    
    var MERCATOR_OFFSET:Double {
        return 268435456.0
    }
    var MERCATOR_RADIUS:Double {
        return 85445659.44705395
    }

    public func setCenterCoordinateLevel(centerCoordinate:CLLocationCoordinate2D,var zoomLevel:Double,animated:Bool) {
        //设置最小缩放级别
        zoomLevel  = min(zoomLevel, 22)
        
        let span   = self.coordinateSpanWithMapView(self, centerCoordinate: centerCoordinate, zoomLevel: zoomLevel);
        let region = MKCoordinateRegionMake(centerCoordinate, span);
        
        self.setRegion(region, animated: animated)
        
    }
    
    func longitudeToPixelSpaceX(longitude:Double) ->Double {
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0)
    }
    
    func latitudeToPixelSpaceY(latitude:Double) ->Double {
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * M_PI / 180.0)) / (1 - sin(latitude * M_PI / 180.0))) / 2.0)
    }
    
    func pixelSpaceXToLongitude(pixelX:Double) ->Double {
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI
    }
    
    func pixelSpaceYToLatitude(pixelY:Double) ->Double {
        return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI
    }
    
    func coordinateSpanWithMapView(mapView:MKMapView,
                          centerCoordinate:CLLocationCoordinate2D,
                                 zoomLevel:Double) -> MKCoordinateSpan
    {
        let centerPixelX = self.longitudeToPixelSpaceX(centerCoordinate.longitude)
        let centerPixelY = self.latitudeToPixelSpaceY(centerCoordinate.latitude)
        let zoomExponent = 20.0 - zoomLevel
        let zoomScale = pow(2.0, zoomExponent)
        
        let mapSizeInPixels = mapView.bounds.size
        let scaledMapWidth  = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        let topLeftPixelX = centerPixelX - (scaledMapWidth/2)
        let topLeftPixelY = centerPixelY - (scaledMapHeight/2)
        
        let minLng = self.pixelSpaceXToLongitude(topLeftPixelX)
        let maxLng = self.pixelSpaceXToLongitude(topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        
        let minLat = self.pixelSpaceYToLatitude(topLeftPixelY);
        let maxLat = self.pixelSpaceYToLatitude(topLeftPixelY + scaledMapHeight);
        let latitudeDelta = -1 * (maxLat - minLat);
        
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        return span
    }
}


