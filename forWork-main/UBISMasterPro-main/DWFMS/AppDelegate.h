//
//  AppDelegate.h
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 15..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

// 커밋 확인 (2022.10.12 Jung Mirae)
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ViewController.h"
#import "CameraViewController.h"
#import <CoreLocation/CoreLocation.h>    //2017년 2월 27일 Choi Yu Bin 추가
#import <UserNotifications/UserNotifications.h> // 추가 ( >= iOS10)

// S : FCM 적용 (2022년 10월 19일 Jung Mirae)
@import Firebase;
#import "FirebaseMessaging.h"
// E : FCM 적용 (2022년 10월 19일 Jung Mirae)


//@interface AppDelegate : UIResponder <UIApplicationDelegate>{
@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate>{ //2017년 2월 27일 Choi Yu Bin 추가
    //2017.05.18 주석처리
//    NSString *DEVICE_TOK;
//    NSString *GRP_CD;
//    NSString *EMC_ID;
//    NSString *EMC_MSG;
//    NSString *CODE;
    SystemSoundID ssid;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWebView *webview;  //2017년 2월 27일 Choi Yu Bin 추가
@property (strong, nonatomic) NSString *DEVICE_TOK;
@property (strong, nonatomic) NSString *GRP_CD;
@property (strong, nonatomic) NSString *EMC_ID;
@property (strong, nonatomic) NSString *EMC_MSG;
@property (strong, nonatomic) NSString *CODE;

// S : FCM 적용 (2022년 10월 19일 Jung Mirae)
@property (strong, nonatomic) NSString *fcmID;
// E : FCM 적용 (2022년 10월 19일 Jung Mirae)

@property (nonatomic, assign) BOOL isBackgroundMonitoringOn;

- (void) startBackgroundMonitoring;
- (void) stopBackgroundMonitoring;

@property (weak, nonatomic) ViewController * main;
@property (weak, nonatomic) CameraViewController * camera;


@property (strong, nonatomic) CLLocationManager *locationManager; //2017년 2월 27일 Choi Yu Bin 추가
@property CLProximity lastProximity;  //2017년 2월 27일 Choi Yu Bin 추가

@end

