//
//  MapViewController.h
//  DWFMS
//
//  Created by Park Jonh Hoon on 18/04/2019.
//  Copyright © 2019 DWFMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@import GoogleMaps;

@interface MapViewController : UIViewController <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    
    //구글에서 제공하는 GMSMapView를 사용하기 위한 변수
    GMSMapView *mapView_;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString *chkGpsY;
@property (strong, nonatomic) NSString *chkGpsX;

@property (strong, nonatomic) NSMutableArray *mutableGpsNm;
@property (strong, nonatomic) NSMutableArray *mutableGpsY;
@property (strong, nonatomic) NSMutableArray *mutableGpsX;
@property (strong, nonatomic) NSMutableArray *mutableDistance;

@property (strong, nonatomic) NSString *goalDistance;//가장 가까운 것과의 거리...

@end


