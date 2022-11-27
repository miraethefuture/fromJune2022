//
//  GpsViewController.h
//  DWFMS
//
//  Created by Park Jonh Hoon on 19/04/2019.
//  Copyright © 2019 DWFMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GpsViewController : UIViewController<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

//버튼들 셋팅
@property (strong, nonatomic) IBOutlet UIButton *btn_ateIn;
@property (strong, nonatomic) IBOutlet UIButton *btn_ateOut;

- (IBAction)MoveMain:(UIButton *)sender;

- (IBAction)AteIn:(UIButton *)sender;
- (IBAction)AteOut:(UIButton *)sender;

@property (assign, nonatomic) NSString *viewManGpsY;
@property (assign, nonatomic) NSString *viewManGpsX;
@property (assign, nonatomic) NSString *viewPointDistance;

@property (assign, nonatomic) NSString *gpsCtlYn; //GPS활성화여부


@property (nonatomic, strong) CLLocationManager *locationManager;
@end
