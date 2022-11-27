//
//  ViewController.h
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 15..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZIINQRCodeReaderView.h"

//S : Google맵 추가(2019년 4월 18일 Park Jong Hoon)
#import "MapViewController.h"
#import "GpsViewController.h"
//E : Google맵 추가(2019년 4월 18일 Park Jong Hoon)

#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h> //2017년 2월 27일 Choi Yu Bin 추가

//S : 카카오 음성인식으로 인한 추가(2019년 10월 18일 Park Jong Hoon)
#import <KakaoNewtoneSpeech/KakaoNewtoneSpeech.h>
//E : 카카오 음성인식으로 인한 추가(2019년 10월 18일 Park Jong Hoon)

// S : 헤더 파일 테스트 중... (2022.11.03 Jung Mirae)
//#import "DWFMS-Swift.h"
// E : 헤더 파일 테스트 중... (2022.11.03 Jung Mirae)

//@interface ViewController : UIViewController <RECOBeaconManagerDelegate, CBCentralManagerDelegate> //2017년 2월 27일 Choi Yu Bin 주석처리
//@interface ViewController : UIViewController <CBCentralManagerDelegate, CLLocationManagerDelegate> //2017년 2월 27일 Choi Yu Bin 추가

@interface ViewController : UIViewController <CBCentralManagerDelegate, CLLocationManagerDelegate, UIApplicationDelegate, UIWebViewDelegate, MTSpeechRecognizerViewDelegate, MTTextToSpeechDelegate, NSObject> // , NSObject 추가 (2022.11.03 Jung Mirae)


@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet ZIINQRCodeReaderView *qrView;

//S : Google맵 추가(2019년 4월 18일 Park Jong Hoon)
@property (weak, nonatomic) IBOutlet GpsViewController *gpsView;
@property (weak, nonatomic) IBOutlet MapViewController *mapView;
//E : Google맵 추가(2019년 4월 18일 Park Jong Hoon)

//@property (nonatomic, strong) RECOBeacon *beacon; //2017년 2월 27일 Choi Yu Bin 주석처리
@property (strong) NSArray *beacons;//2017년 2월 27일 Choi Yu Bin 추가
@property (nonatomic, strong) CBCentralManager* blueToothManager;
@property (strong, nonatomic) CLLocationManager *locationManager;//2017년 2월 27일 Choi Yu Bin 추가
@property CLProximity lastProximity;//2017년 2월 27일 Choi Yu Bin 추가
@property  bool isUpdateQr;

- (void) setimage:(NSString*) path num:(NSNumber*)num;
//- (void) setimage:(NSString*) path num:(NSString*)num; //2022.11.17 Jung Mirae 주석처리
- (void) setQRcode:(NSString*) data;
- (void) rcvAspn:(NSString*) jsonstring ;//2017년 2월 27일 Choi Yu Bin 추가
- (void) beaconSet;

- (void)SttView; // 카카오 음성 STT 적용 관련 - (2022.11.07 Jung Mirae)
@property (nonatomic, readwrite) NSString *portStored; // 출퇴근 - (2022.11.08 Jung Mirae)

@end

@interface UIWebView(JavaScriptAlert)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
@end

// S : 카카오 음성 STT 적용 관련 - (2022.11.07 Jung Mirae)
//@interface OBjCModule : NSObject
//- (void)SttView;
//@end
// E : 카카오 음성 STT 적용 관련 - (2022.11.07 Jung Mirae)
