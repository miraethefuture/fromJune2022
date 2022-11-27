//
//  ViewController.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 15..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "ViewController.h"
#import "CallServer.h"
#import "GlobalData.h"
#import "GlobalDataManager.h"
#import "Commonutil.h"
#import "ZIINQRCodeReaderView.h"
#import "AppDelegate.h"
#import "ToastAlertView.h"
#import "FileDownloadManager.h" //2017년 2월 27일 Choi Yu Bin 추가
#import <CoreLocation/CoreLocation.h> //2017년 2월 27일 Choi Yu Bin
#import "DWFMS-Swift.h" //스위프트 파일 연결 위해 추가 (2022.11.03 Jung Mirae)

//S : Google맵 추가(2019년 4월 18일 Park Jong Hoon)
#import "MapViewController.h"
#import "GpsViewController.h"
//E : Google맵 추가(2019년 4월 18일 Park Jong Hoon)

//S:음성인식으로 인한 추가(2019년 11월 6일 Park Jong Hoon)
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>
//E:음성인식으로 인한 추가(2019년 11월 6일 Park Jong Hoon)

//S:iOS NFC기능 추가(2019년 11월 22일 Park Jong Hoon)
@import CoreNFC;
#import <sys/utsname.h>
//@interface ViewController ()
@interface ViewController () <NFCNDEFReaderSessionDelegate, CBCentralManagerDelegate>
@property (nonatomic, strong)   NFCNDEFReaderSession *session;
@property (nonatomic, strong)   NFCNDEFReaderSession *alert;
//E:iOS NFC기능 추가(2019년 11월 22일 Park Jong Hoon)
@end

// S : 카카오 음성인식 적용 위해 스위프트 파일 추가 테스트 중... (2022.11.07 Jung Mirae)
//@class KakaoSTT;
//@implementation OBjCModule
//-(void)SttView {
//    KakaoSTT *kakaoStt = [[KakaoSTT alloc] init];
//    [kakaoStt setupView];
//}
//@end
// E : 카카오 음성인식 적용 위해 스위프트 파일 추가 테스트 중... (2022.11.07 Jung Mirae)

@implementation ViewController{
    NSArray *_uuidList;
    //NSArray *_stateCategory;
}

NSString *viewType =@"LOGOUT";
NSString *beaconYN =@"Y";
NSString *bluetoothYN = @"N";

// S: 출퇴근 시간 사용자 증가 관련 이슈 해결 위해 port 변수 추가 (2022.11.08 Jung Mirae)
NSString *portStored = @""; // 필요한지 확인 후 필요 없으면 지우기 (2022.11.15 Jung Mirae)
NSString *server = @"";
// E: 출퇴근 시간 사용자 증가 관련 이슈 해결 위해 port 변수 추가 (2022.11.08 Jung Mirae)

/*******2017년 2월 27일 Choi Yu Bin 추가시작*******/
NSString *senderinfo = @"";
NSString *titleinfo = @"";
NSString *EmcCode = @"";
NSString *beaconKey = @"";

NSMutableArray *beaconDistanceList; //Using the Beacon Value set set set~~~
NSMutableArray *beaconList;
NSMutableArray *beaconBatteryLevelList;
int seqBeacon = 0;
int beaconSkeepCount = 0;
int beaconSkeepMaxCount = 1;

CLBeaconRegion *beaconRegion;
/*******2017년 2월 27일 Choi Yu Bin 추가종료*******/

//S:iOS NFC기능 추가(2019년 11월 22일 Park Jong Hoon)
NSString *nfcId = @"";
NSString *nfcSerialNo = @"";
//E:iOS NFC기능 추가(2019년 11월 22일 Park Jong Hoon)

// S: VERSION_NM 추가하며 앱 버전 정보 가져오기 위해 추가 (2022.11.09 Jung Mirae)
NSDictionary *infoDict;
NSString *appVersion;
// E: VERSION_NM 추가 앱 버전 정보 가져오기 위해 추가 (2022.11.09 Jung Mirae)

// S: 연속해서 필요한 코드 전역 범위로 이동 (2022.11.09 Jung Mirae)
//CallServer *res;
//UIDevice *device;
//NSString* idForVendor;
//NSInteger *iosVer;
//NSString *iosModel;
//NSString *fcmToken;
//NSMutableDictionary* param; // 정리하기
// E: 연속해서 필요한 코드 전역 범위로 이동 (2022.11.09 Jung Mirae)

// S: DB에 저장된 포트 번호 서버에서 가져오기 위해 작성한 변수 (2022.11.15 Jung Mirae)
NSString *chkPort = @"";
NSString *callBackWelcomePort = @"";
// E: DB에 저장된 포트 번호 서버에서 가져오기 위해 작성한 변수 (2022.11.15 Jung Mirae)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self detectBluetooth]; // 블루투스 (2022.07.21 Jung Mirae)
    
    [GlobalData setbeacon:@"F"];
    
    [self setIsUpdateQr:NO];
    AppDelegate * ad =  [[UIApplication sharedApplication] delegate] ;
    [ad setMain:self];
    
    [self.webView setDelegate:self];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    server = [GlobalData getServerIp];
    NSInteger *iosVer = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *iosModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    // FCM 토큰 가져오기(2022.11.11 Jung Mirae)
    NSString *fcmToken = ((AppDelegate*)[UIApplication sharedApplication].delegate).fcmID;
    // S: VERSION_NM 추가하기 위해 앱 버전 정보 가져오기 (2022.11.09 Jung Mirae)
    infoDict = [[NSBundle mainBundle] infoDictionary];
    appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // 1.1.1
    //NSLog(@"앱 버전 확인하기 ==== %@", appVersion);
    //NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; // 2
    //NSLog(@"앱 빌드 넘버 확인하기 ==== %@", buildNumber)
    // E: VERSION_NM 추가하기 위해 앱 버전 정보 가져오기 (2022.11.09 Jung Mirae)

    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue: idForVendor forKey:@"HP_TEL"];
    //[param setValue:@"ffffffff" forKey:@"GCM_ID"]; 원소스
    [param setValue: fcmToken forKey:@"GCM_ID"]; // Mirae 변경
    [param setObject:@"I" forKey:@"DEVICE_FLAG"];
    [param setObject: appVersion forKey:@"VERSION_NM"]; // VERSION_NM 추가 (2022.11.09 Jung Mirae)
    //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    [param setObject: [NSString stringWithFormat:@"%d",iosVer] forKey:@"BUILD_SDK"];
    [param setObject: iosModel forKey:@"PACKAGE_ID"];
    //E : iOS 정보추출 로그인 추가 (2019년 11월 27일 Park Jong Hoon)
    
    //NSLog(@"server 값 확인 ===> %@", server);
    //NSLog(@"GCM_ID 값 확인 ===> %@", fcmToken);
    
    // S : 화면 확대/축소 추가(2018년 3월 20일 Park Jong Hoon)
    [self.webView setScalesPageToFit:YES];
    // E : 화면 확대/축소 추가(2018년 3월 20일 Park Jong Hoon)
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        //R 수신
        NSLog(@"타는지 확인 - VC 위쪽1 param ==> %@", param); // 탐. loginByPhon 여기만 탐
        
        NSString* str = [res stringWithUrl:@"loginByPhon.do" VAL: param];
        
        NSLog(@"타는지 확인 - VC 위쪽2"); // 탐. loginByPhon 여기만 탐
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            //NSLog(str);
            NSLog(@"%@", str);

            chkPort = [[NSUserDefaults standardUserDefaults] stringForKey:@"portStored"];

            NSString *urlParam=@"";
            //NSString *server = [GlobalData getServerIp]; // 원코드
            server = [GlobalData getServerIp]; // server를 전역으로 뺌
            NSString *pageUrl = @"/DWFMS";
            NSString *callUrl = @"";
            
            /*
             자동로그인 부분
             */
            if([@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
            {
                if([@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
                {
                    NSDictionary *data = [jsonInfo valueForKey:(@"data")];
                    [GlobalDataManager initgData:(data)];
                    NSArray * timelist = [jsonInfo objectForKey:@"inout"];
                    [GlobalDataManager setTime:[timelist objectAtIndex:0]];
                    NSArray * authlist = [jsonInfo objectForKey:@"auth"];
                    [GlobalDataManager initAuth:authlist];
                    
                    beaconYN = [data valueForKey:@"BEACON_YN"];
                    NSMutableDictionary * session =[GlobalDataManager getAllData];
                    
                    // 전역 변수 portStored 에 가져온 port 값 할당 (2022.11.14 Jung Mirae)
                    portStored = [data valueForKey:@"PORT"];
                    NSLog(@"VC 위쪽에서 할당한 포트 번호 ==> %@", portStored);
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:portStored forKey:@"portStored"];
                  
                    // S: 비콘 추가 (2022.07.21 Jung Mirae)
                    [session setValue:[[GlobalDataManager getgData] beaconYn] forKey: beaconYN];
                    // E: 비콘 추가(2022.07.21 Jung Mirae)
                    
                    [session setValue:[GlobalDataManager getAuth] forKey:@"auth"];
                    [session setValue:[[GlobalDataManager getgData] inTime]  forKey:@"inTime"];
                    [session setValue:[[GlobalDataManager getgData] outTime]  forKey:@"outTime"];
                    
                    //S : 점심시작/종료 시간 추가(2022년 4월 29일 Park Jong Hoon)
                    [session setValue:[[GlobalDataManager getgData] lunchInTime]  forKey:@"lunchInTime"];
                    [session setValue:[[GlobalDataManager getgData] lunchOutTime]  forKey:@"lunchOutTime"];
                    //E : 점심시작/종료 시간 추가(2022년 4월 29일 Park Jong Hoon)
                    
                    urlParam = [Commonutil serializeJson:session];
                    
                    NSString * text =@"본 어플리케이션은 원할한 서비스를\n제공하기 위해 휴대전화번호등의 개인정보를 사용합니다.\n[개인정보보호법]에 의거해 개인정보 사용에 대한 \n사용자의 동의를 필요로 합니다.\n개인정보 사용에 동의하시겠습니까?\n";
                    NSLog(@"urlParam %@",urlParam);
                    callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
                    
                    
                    if(![@"Y" isEqualToString:[data valueForKey:@"INFO_YN"]])
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:text delegate:self
                                                              cancelButtonTitle:@"취소"
                                                              otherButtonTitles:@"동의", nil];
                        [alert show];
                    }
                    
                    viewType = @"LOGIN";
                    //_uuidList = [GlobalData sharedDefaults].supportedUUIDs;
                    
                    if(![@"N" isEqualToString:[data valueForKey:@"BEACON_YN"]]){    //2017년 10월 27일 Park Jong Hoon 비콘일 경우 만 아래 로직 타게...
                        _uuidList = @[
                                      [[NSUUID alloc] initWithUUIDString:[data valueForKey:@"BEACON_UUID"]]
                                      //24DDF411-8CF1-440C-87CD-E368DAF9C93E
                                      // you can add other NSUUID instance here.
                                      ];

                        //2017년 2월 27일 Choi Yu Bin 추가
                        [_uuidList enumerateObjectsUsingBlock:^(NSUUID *uuid, NSUInteger idx, BOOL *stop) {
                            NSString *identifier = @"us.iBeaconModules";
                            
                            [self registerBeaconRegionWithUUID:uuid andIdentifier:identifier];
                        }];
                        NSLog(@"일단 여기 걸리나?? Authorized when in use");
                        
                        //2017년 2월 27일 Choi Yu Bin 추가
                        switch ([CLLocationManager authorizationStatus]) {
                            case kCLAuthorizationStatusAuthorizedAlways:
                                NSLog(@"Authorized Always");
                                break;
                            case kCLAuthorizationStatusAuthorizedWhenInUse:
                                NSLog(@"Authorized when in use");
                                break;
                            case kCLAuthorizationStatusDenied:
                                NSLog(@"Denied");
                                break;
                            case kCLAuthorizationStatusNotDetermined:
                                NSLog(@"Not determined");
                                break;
                            case kCLAuthorizationStatusRestricted:
                                NSLog(@"Restricted");
                                break;
                                
                            default:
                                break;
                        }
                        self.locationManager = [[CLLocationManager alloc] init];
                        //            if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                        //                [self.locationManager requestAlwaysAuthorization];
                        //            }
                        //2017년 04월 03일 Choi Yu Bin 추가 - 위치서비스 항상허용 제외, 앱을 사용하는 동안만 사용 하도록 설정
                        if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                            [self.locationManager requestWhenInUseAuthorization];
                        }
                        self.locationManager.distanceFilter = YES;
                        
                        self.locationManager.delegate = self;
                        self.locationManager.pausesLocationUpdatesAutomatically = YES;//pause상태에서의 스캔여부
                        [self.locationManager startMonitoringForRegion:beaconRegion];
                        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
                        [self.locationManager startUpdatingLocation];
                    }//2017년 10월 27일 Park Jong Hoon 비콘일 경우 만 아래 로직 타게...
                }
                else{
                    //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
                    
                    //S: 주석처리 후 VERSION_NM / GCM_ID 값으로 [[GlobalDataManager getgData] gcmId] 추가(2022.11.09 Jung Mirae)
                    //urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I&BUILD_SDK=%@&PACKAGE_ID=%@",idForVendor,@"22222222", [NSString stringWithFormat:@"%d",iosVer], iosModel];
                    
                    urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I&BUILD_SDK=%@&PACKAGE_ID=%@&VERSION_NM=%@",idForVendor,fcmToken, [NSString stringWithFormat:@"%d",iosVer], iosModel, appVersion];
                    //E: VERSION_NM 추가(2022.11.09 Jung Mirae)
                    
                    //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
                    callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                }
            }
            
            NSLog(@"??callurl:%@",callUrl);
            
            //2018년 1월 2일 Park Jong Hoon 네트워크 끊겼을 시 이벤트 버튼 추가
            if(callUrl == @"")
            {
                NSLog(@"PJH~~~ %@", @"통신불가");
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"네트워크 오류"
                                                               message:@"통신상태 연결에 이상이 있습니다..!!"
                                                              delegate:self
                                                     cancelButtonTitle:@"닫기"    /* nil 로 지정할 경우 cancel button 없음 */
                                                     otherButtonTitles: nil];
                
                // alert창을 띄우는 method는 show이다.
                alert.tag=190;
                [alert show];
                return;
            }
            else{
                NSLog(@"PJH~~~ %@", @"통신가능");
                NSURL *url=[NSURL URLWithString:callUrl];
                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                [requestURL setHTTPMethod:@"POST"];
                [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                [self.webView loadRequest:requestURL];
                NSLog(@"??????? urlParam %@",urlParam);
            }
        });
    });
    
    //S : Gps처리 후 넘겨 받은 코드(2019년 4월 24일 Park Jong Hoon)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveGpsResult:) name:@"GpsResult" object:nil];    // noti 등록
    //E : Gps처리 후 넘겨 받은 코드(2019년 4월 24일 Park Jong Hoon)
}

//S:iOS NFC기능 추가(2019년 11월 22일 Park Jong Hoon)
#pragma mark - Methods
- (void)beginSession
{
    NSLog(@"??????? 최초 먼저 시작?");
    if (@available(iOS 11.0, *)) {
        NSLog(@"??????? 11버젼이상");
        _session
        = [[NFCNDEFReaderSession alloc] initWithDelegate:self
                                                   queue:dispatch_queue_create(NULL,
                                                                               DISPATCH_QUEUE_CONCURRENT)
                                invalidateAfterFirstRead:NO];
        [_session beginSession];
    } else {
        NSLog(@"??????? 11버젼이하");
        // Fallback on earlier versions
    }
}

- (void)dealloc
{
    [_session invalidateSession];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - NFCNDEFReaderSessionDelegate

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error
{
    NSLog(@"Error: %@", [error debugDescription]);
    
    if (error.code == NFCReaderSessionInvalidationErrorUserCanceled) {
        // User cancellation.
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        _logView.text = [NSString stringWithFormat:@"[%@] Error: %@ (%ld)\n%@",
//                         [NSDate date],
//                         [error localizedDescription],
//                         error.code,
//                         _logView.text];
        NSString *tmpError =[NSString stringWithFormat:@"Error: %@ (%ld)",
                                 [error localizedDescription],
                             error.code];
        [ToastAlertView showToastInParentView:self.view withText:tmpError withDuaration:3.0];
    });
}

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didDetectNDEFs:(nonnull NSArray<NFCNDEFMessage *> *)messages
{
    NSLog(@"NFC태깅함");
    //NSArray *foundTags = [session valueForKey:@"_foundTags"];
//    NSObject *tag = foundTags[0];
//    NSData *uid = [tag valueForKey:@"_tagID"];

    if (@available(iOS 11.0, *)) {
        //self.locationManager = [[CLLocationManager alloc] init]; //비콘 중자
        
        for (NFCNDEFMessage *message in messages) {
            for (NFCNDEFPayload *payload in message.records) {
                NSLog(@"Payload: %@", payload);
                const NSDate *date = [NSDate date];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSInteger *nfcFormat = payload.typeNameFormat;
                    if([@"4"isEqualToString:[NSString stringWithFormat:@"%d",nfcFormat]]){
                        nfcId = [[NSString alloc] initWithData:payload.payload encoding:NSASCIIStringEncoding];
                    }
                    if([@"1"isEqualToString:[NSString stringWithFormat:@"%d",nfcFormat]]){
                        nfcSerialNo = [[[[NSString alloc] initWithData:payload.payload encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"ko" withString:@""];
                    }
                });
            }
        }
        
        //dispatch_async 실행 후 새로운 dispatch_async 비동기화 실행
        dispatch_async(dispatch_get_main_queue(), ^{
            
            nfcSerialNo = [[nfcSerialNo componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];

            NSLog(@"????? NFC Serial_No : %@",nfcSerialNo);
            
            NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
            
            [param setValue:nfcSerialNo forKey:@"SERIAL_NO"];
            
            CallServer *res = [CallServer alloc];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                NSString* str = [res stringWithUrl:@"getIosNFCJobTpy.do" VAL:param];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error;
                    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                    NSLog(@"getIosNFCJobTpy str ====> %@",str);
                    
                    if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
                    {
                        if(     [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
                        {
                            //2017.05.18 변수형식 변경
                            //NSDictionary *resdata = [jsonInfo valueForKey:(@"data")];
                            NSMutableDictionary *resdata = [jsonInfo valueForKey:(@"data")];
                            
                            if(![[[GlobalDataManager getgData] compCd ]isEqual:[resdata valueForKey:@"COMP_CD"]])
                            {
                                //NSLog(@"다른사업장의 업무 입니다.");
                                [ToastAlertView showToastInParentView:self.view withText:@"다른사업장의 업무 입니다." withDuaration:3.0];
                                return;
                            }
                            
                            if([@"00"isEqual:[resdata valueForKey:@"JOB_TPY"]])
                            {
                                [ToastAlertView showToastInParentView:self.view withText:@"QR업무를 등록해 주세요." withDuaration:3.0];
                                NSString *pageUrl = @"/registrationQR.do";
                                NSString *callurl = [NSString stringWithFormat:@"%@%@?SERIAL_NO=%@",server,pageUrl,nfcSerialNo];
                                
                                NSLog(@"???????%@",callurl);
                                NSURL *url=[NSURL URLWithString:callurl];
                                
                                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];

                                [self.webView loadRequest:requestURL];

                                return;
                                
                            }
                            
                            if([self isUpdateQr])
                            {
                                [ToastAlertView showToastInParentView:self.view withText:@"QR업무를 수정합니다." withDuaration:3.0];
                                
                                NSString *pageUrl = @"/registrationQR.do";
                                
                                // S: ServerIp -> server로 변경 (2022.11.10 Jung Mirae)
                                //NSString *callurl = [NSString stringWithFormat:@"%@%@?SERIAL_NO=%@",ServerIp,pageUrl,nfcSerialNo];
                                NSString *callurl = [NSString stringWithFormat:@"%@%@?SERIAL_NO=%@",server,pageUrl,nfcSerialNo];
                                // E: ServerIp -> server로 변경 (2022.11.10 Jung Mirae)
                                
                                NSLog(@"???????%@",callurl);
                                NSURL *url=[NSURL URLWithString:callurl];
                                
                                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                                
                                
                                [self.webView loadRequest:requestURL];
                                
                                return;
                                
                            }
                            
                            //보안순찰 시...
                            if([@"01"isEqual:[resdata valueForKey:@"JOB_TPY"]])
                            {
                                [ToastAlertView showToastInParentView:self.view withText:@"보안순찰업무로 이동합니다." withDuaration:3.0];
                                
                                [self callPatrol:resdata];
                            }
                            
                            //출근업무 시...
                            if([@"02"isEqual:[resdata valueForKey:@"JOB_TPY"]])
                            {
                                //S : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
                                //[self setInOutCommitInfo:resdata];
                                [self setInOutCommitInfo:resdata nfcYn:@"Y"];
                                //E : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
                                
                            }
                            
                            //퇴근업무시...
                            if([@"03"isEqual:[resdata valueForKey:@"JOB_TPY"]])
                            {
                                //S : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
                                //[self setInOutCommitInfo:resdata];
                                [self setInOutCommitInfo:resdata nfcYn:@"Y"];
                                //E : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
                            }
                            
                            //S : 원폴라리스 점심시간 출퇴근시간 로직추가(2022년 4월 25일 Park Jong Hoon)
                            //점심시간 시작 시...
                            if([@"12"isEqual:[resdata valueForKey:@"JOB_TPY"]])
                            {
                                [self setInOutCommitInfo:resdata nfcYn:@"Y"];
                            }
                            
                            //점심시간 종료 시...
                            if([@"13"isEqual:[resdata valueForKey:@"JOB_TPY"]])
                            {
                                [self setInOutCommitInfo:resdata nfcYn:@"Y"];
                            }
                            //E : 원폴라리스 점심시간 출퇴근시간 로직추가(2022년 4월 25일 Park Jong Hoon)
                            
                            //시설점검 업무시...
                            if([@"04"isEqual:[resdata valueForKey:@"JOB_TPY"]])
                            {
                                [ToastAlertView showToastInParentView:self.view withText:@"시설점검업무로 이동합니다." withDuaration:3.0];
                                [self callChkWork:resdata];
                            }
                            
                            //S: 미화점검 로직 추가(2022.02.03 Hwang Ja Young)
                            //미화점검 업무시...
                            if([@"06"isEqual:[resdata valueForKey:@"JOB_TPY"]])
                            {
                                [ToastAlertView showToastInParentView:self.view withText:@"미화점검업무로 이동합니다." withDuaration:3.0];
                                [self callCleanWork:resdata];
                            }
                            //E: 미화점검 로직 추가(2022.02.03 Hwang Ja Young)
                            
                            //S : PMS입/출차처리 로직 추가(2018년 11월 20일 Park Jong Hoon)
                            //PMS입차처리...
                            if([@"21"isEqual:[resdata valueForKey:@"JOB_TPY"]])
                            {
                                [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 입차처리 중입니다.." withDuaration:3.0];
                                [self callPmsIn:resdata];
                            }

                            //PMS출차처리...
                            if([@"22"isEqual:[resdata valueForKey:@"JOB_TPY"]])
                            {
                                [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 출차처리 중입니다.." withDuaration:3.0];
                                [self callPmsOut:resdata];
                            }
                            //E : PMS입/출차처리 로직 추가(2018년 11월 19일 Park Jong Hoon)
                        }

                    }
                    
                    else
                    {
                        [ToastAlertView showToastInParentView:self.view withText:@"UBISMaster 전용NFC가 아닙니다..관리자에게 문의하세요.." withDuaration:3.0];
                    }
                });
            });
        });
    }

    //[ToastAlertView showToastInParentView:self.view withText:[NSString stringWithFormat:@"%@%@",nfcId,nfcSerialNo] withDuaration:3.0];
    [_session invalidateSession];
}
//E:iOS NFC기능 추가(2019년 11월 22일 Park Jong Hoon)

///S : 화면회전기능 추가(2018년 3월 20일 Park Jong Hoon)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    NSLog(@"화면회전 OK");
    return UIInterfaceOrientationMaskAll;
}
///E : 화면회전기능 추가(2018년 3월 20일 Park Jong Hoon)

- (BOOL)detectBluetooth
{
    if ([@"N"isEqual:beaconYN]) {
        return FALSE;
    }
    if(!self.blueToothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.blueToothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    [self centralManagerDidUpdateState:self.blueToothManager]; // Show initial state
    
    switch(self.blueToothManager.state)
    {
        case CBCentralManagerStateResetting: return FALSE; break;
        case CBCentralManagerStateUnsupported: return FALSE; break;
        case CBCentralManagerStateUnauthorized: return FALSE; break;
        case CBCentralManagerStatePoweredOff: return FALSE; break;
        case CBCentralManagerStatePoweredOn: return TRUE; break;
        default: return FALSE; break;
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(self.blueToothManager.state)
    {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off."; bluetoothYN = @"N"; break;
        case CBCentralManagerStatePoweredOn: stateString = @"Bluetooth is currently powered on and available to use."; bluetoothYN = @"Y"; break;
        default: stateString = @"State unknown, update imminent."; break;
    }
    NSLog(@"bluetoothstate :: %@", stateString);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self startRanging];
}
- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //[self stopRanging];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //javascript => document.location = "somelink://yourApp/form_Submitted:param1:param2:param3";
    //scheme : somelink
    //absoluteString : somelink://yourApp/form_Submitted:param1:param2:param3
    
    //2017년 2월 27일 Choi Yu Bin 추가 시작
    NSLog(@"?? request ===>>> %@", request);
    NSString *requestDownUrl = [[request URL] absoluteString];
    NSLog(@"?? requestDownUrl111===<>>> %@", requestDownUrl);
    NSRange range = [requestDownUrl rangeOfString: @"Download.jsp:" options:NSCaseInsensitiveSearch];
    NSLog(@"my range is %@", NSStringFromRange(range));
    
    if(range.location != NSNotFound){
        // S: ServerIp -> server로 변경 (2022.11.10 Jung Mirae)
        //NSString *DownUrl = [requestDownUrl stringByReplacingOccurrencesOfString:[ServerIp stringByAppendingString: @"/views/Download.jsp:"] withString:@""];
        NSString *DownUrl = [requestDownUrl stringByReplacingOccurrencesOfString:[server stringByAppendingString: @"/views/Download.jsp:"] withString:@""];
        // E: ServerIp -> server로 변경 (2022.11.10 Jung Mirae)
        //NSLog(@"ServerIp ===>>> %@",ServerIp);
        
        //URL 디코딩
        NSString *escapeStr = [DownUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[FileDownloadManager alloc] initWithURL:(escapeStr)];
        NSLog(@"확인!!!!%@", escapeStr);
        return NO;
    }
    else
    { //2017년 2월 27일 Choi Yu Bin 종료
        
        NSString *requesturl1 = [[request URL] scheme];
        NSLog(@"?? requesturl1===>>> %@",requesturl1);
        if([@"toapp" isEqual:requesturl1])
        {
            NSString *requesturl2 = [[request URL] absoluteString];
            NSString *decoded = [requesturl2 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSArray* list = [decoded componentsSeparatedByString:@":"];
            NSString *type  = [list objectAtIndex:1];
            NSLog(@"?? type %@",type);
            
            //NSLog(@"toapp 안 requesturl2 ==> %@", requesturl2);
            //NSLog(@"toapp 안 list ==> %@", list);
            //NSLog(@"toapp 안 decoded ==> %@", decoded);
            
            //Webview : web call case
            if([@"login" isEqual:type])
            {
                NSLog(@"LOGIN - toapp START");
                [self login:[decoded substringFromIndex:([type length]+7)]];
                
            } else if ([@"QRun" isEqual:type]) {
                NSLog(@"QR START");
                [self detectBluetooth];
                [self setIsUpdateQr:NO];
                
                _qrView.hidden = NO;
                _qrView.isHiddenCam;
                NSLog(@"QR end");
                //[self performSegueWithIdentifier:@"callQRScan" sender:self];
            
            } else if ([@"updateQRun" isEqual:type]) {
                NSLog(@"updateQRun START");
                [self setIsUpdateQr:YES];
                
                _qrView.hidden = NO;
                _qrView.isHiddenCam;
                NSLog(@"updateQRun end");
                //[self performSegueWithIdentifier:@"callQRScan" sender:self];
            
            } else if([@"callImge" isEqual:type]){

                [self callImge:[decoded substringFromIndex:([type length]+7)]];
            
                NSLog(@"decoded ==> %@", decoded); // 2022.11.22 Jung Mirae 값 확인하기 위해 추가
                
            } else if([@"logout" isEqual:type]){
                
                [self logout];
            
            } else if ([@"setSession" isEqual:type]) {
                
                NSMutableDictionary *reSession =[GlobalDataManager getAllData];
                [reSession setValue:[GlobalDataManager getAuth] forKey:@"auth"];
                [reSession setValue:[[GlobalDataManager getgData] inTime ]forKey:@"inTime"];
                [reSession setValue:[[GlobalDataManager getgData] outTime ]forKey:@"outTime"];
                
                //S : 점심시작/종료시간 추가(2022년 4월 29일 Park Jong Hoon)
                [reSession setValue:[[GlobalDataManager getgData] lunchInTime ]forKey:@"lunchInTime"];
                [reSession setValue:[[GlobalDataManager getgData] lunchOutTime ]forKey:@"lunchOutTime"];
                //E : 점심시작/종료시간 추가(2022년 4월 29일 Park Jong Hoon)
                
                // S: 비콘 추가 (2022.07.21 Jung Mirae)
                [reSession setValue:[[GlobalDataManager getgData] beaconYn ]forKey:@"BEACON_YN"];
                // E: 비콘 추가 (2022.07.21 Jung Mirae)
                
                NSString *scriptParameter = [NSString stringWithFormat:@"setsession('%@&reCall=%@');", [Commonutil serializeJson:reSession],[decoded substringFromIndex:([type length]+7)]];
                NSLog(@"setSession : call Script value : %@", scriptParameter);
                //json data return
                
                [webView stringByEvaluatingJavaScriptFromString:scriptParameter];
                
            } else if ([@"reCall" isEqual:type]) {
                NSString *scriptString = [NSString stringWithFormat:@"%@;", [decoded substringFromIndex:([type length]+7)]];
                NSLog(@"reCall : call Script value : %@", scriptString);
                
                [webView stringByEvaluatingJavaScriptFromString:scriptString];
            
            } else if([@"callbackwelcome"isEqual:type]) {
                
                //S : 서버에서 com000에 있는 port 번호 넘겨 받기 (2022.11.14 Jung Mirae)
                NSLog(@"콜백웰컴 안 list ==> %@", list);
                
                // list 배열의 세번째 요소가 port 번호를 전역변수 callBackWelcomePort에 할당
                // 가져온 포트 번호가 기존에 가져왔던 포트 번호와 다르면 새 포트 번호를
                if (![chkPort isEqual: [list objectAtIndex:2]]) {
                    NSLog(@"맨 처음 유저 디포트에 포트 저장 전 여기 타는지");
                    callBackWelcomePort = [list objectAtIndex:2];
                }
                
                NSLog(@"콜백웰컴 안 callBackWelcomePort 8047 이어야 함 ==> %@", callBackWelcomePort);
                //E : 서버에서 com000에 있는 port 번호 넘겨 받기 (2022.11.14 Jung Mirae)
                
                [self callbackwelcome];
                
            }
            //2017년 2월 27일 Choi Yu Bin 추가시작
            else if([@"setJobMode" isEqual:type]) {
                NSLog(@"############### ~~~ %@", [decoded substringFromIndex:([type length]+7)]);
                viewType = [decoded substringFromIndex:([type length]+7)];
                
            } else if ([@"getPageInfo" isEqual:type]) {
                NSString *scriptString = [NSString stringWithFormat:@"%@;", [decoded substringFromIndex:([type length]+7)]];
                NSLog(@"getPageInfo : call Script value : %@", scriptString);
                
                [self senderInfoText:[decoded substringFromIndex:([type length]+7)]];
                
                NSString *returnString = [NSString stringWithFormat:@"setSenderInfo('%@','%@');",titleinfo,senderinfo];
                NSLog(@"scriptString => %@", returnString);
                [webView stringByEvaluatingJavaScriptFromString:returnString];
                
                NSString *arg = [decoded substringFromIndex:([type length]+7)];
                if ([@"7" isEqual:arg]) {
                    returnString = [NSString stringWithFormat:@"setLocationTitle('내용 : ');"];
                } else {
                    returnString = [NSString stringWithFormat:@"setLocationTitle('장소 : ');"];
                }
                viewType = @"EMC";
                [webView stringByEvaluatingJavaScriptFromString:returnString];
            } else if ([@"sendEmc" isEqual:type]) {
                [self sendEmc:[decoded substringFromIndex:([type length]+7)]];
                
                //2017.01.31 CYB추가(MHR 홈페이지 바로가기)
            }else if ([@"callHomepage" isEqual:type]) {
                NSLog(@"CallHomePage START : %@" , [list objectAtIndex:2]);
                NSString *paramurl = [list objectAtIndex:2];
                
                //파라메터로 받은 홈페이지 주소랑 http:// 문자열 합쳐서 사파리로 열기
                NSURL *homepageUrl = [[NSURL alloc]initWithString:[@"https://" stringByAppendingString:paramurl]];
                [[UIApplication sharedApplication]openURL:homepageUrl];
                
                NSLog(@"CallHomePage end  :::::!!!!" );
            }
            //S : Google맵 추가(2019년 4월 18일 Park Jong Hoon)
            else if ([@"GPSRun" isEqual:type]) {
                NSLog(@"GPSRun START");
                
                //self.locationManager = [[CLLocationManager alloc] init]; //비콘 초기화
                
                //S : 위치선택여부에 따라 권한 획득 및 설정에서 처리하게 하기(2021년 1월 26일 Park Jong Hoon)
//                UIStoryboard *sb = [self storyboard];
//                GpsViewController *gpsMap = [sb instantiateViewControllerWithIdentifier:@"GpsViewController"];
//
//                if(self.navigationController){
//                    [self.navigationController pushViewController:gpsMap animated:true];
//                }
//                else{
//                    [self presentViewController:gpsMap animated:YES completion:nil];
//                }
                
                //위치선택 했는지 여부를 체크하여 팝업 닫거나 하기...
                CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
                NSString *locationChkYn = @"N";
                
                switch (status) {
                    case kCLAuthorizationStatusNotDetermined:
                        //한번도 인증을 하지 않은 경우..
                        NSLog(@"kCLAuthorizationStatusNotDetermined");
                        //The user hasn't yet chosen whether your app can use location services or not.
                        locationChkYn = @"N";
                        NSLog(@"위치기반 어떤것을 선택? : %d", 0);
                        break;
                        
                    case kCLAuthorizationStatusAuthorizedAlways:
                        //앱은 항상 사용자의 위치기반을 사용
                        NSLog(@"kCLAuthorizationStatusAuthorizedAlways");
                        //The user has let your app use location services all the time, even if the app is in the background.
                        locationChkYn = @"Y";
                        NSLog(@"위치기반 어떤것을 선택? : %d", 1);
                        break;
                        
                    case kCLAuthorizationStatusAuthorizedWhenInUse:
                        //앱을 사용하는 동안만 허용
                        NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse");
                        //The user has let your app use location services only when the app is in the foreground.
                        locationChkYn = @"Y";
                        NSLog(@"위치기반 어떤것을 선택? : %d", 2);
                        break;
                        
                    case kCLAuthorizationStatusRestricted:
                        //위치 정보를 사용한다고 말을 하지 않은 앱. 개발자가 프로젝트에 이 앱은 위치 정보를 사용한다고 설정을 해두지 않은 경우
                        NSLog(@"kCLAuthorizationStatusRestricted");
                        //The user can't choose whether or not your app can use location services or not, this could be due to parental controls for example.
                        locationChkYn = @"N";
                        NSLog(@"위치기반 어떤것을 선택? : %d", 3);
                        break;
                        
                    case kCLAuthorizationStatusDenied:
                        //사용자가 위치정보를 허용하지 않았을 경우...
                        NSLog(@"kCLAuthorizationStatusDenied");
                        //The user has chosen to not let your app use location services.
                        locationChkYn = @"N";
                        NSLog(@"위치기반 어떤것을 선택? : %d", 4);
                        break;
                        
                    default:
                        NSLog(@"default");
                        locationChkYn = @"Y";
                        NSLog(@"위치기반 어떤것을 선택? : %d", 5);
                        break;
                }
                
                //승인허가가 있으면...
                if([locationChkYn isEqual: @"Y"]){
                    //일반로직 적용
                    UIStoryboard *sb = [self storyboard];
                    GpsViewController *gpsMap = [sb instantiateViewControllerWithIdentifier:@"GpsViewController"];
                    
                    if(self.navigationController){
                        [self.navigationController pushViewController:gpsMap animated:true];
                    }
                    else{
                        [self presentViewController:gpsMap animated:YES completion:nil];
                    }
                }
                else{
                    NSLog(@"승인을 하여야 함" );
                    
                    //한번도 선택한 것이 아닌 거부 또는 다른 것을 선택했으면...
                    if(status != 0){
                        [ToastAlertView showToastInParentView:self.view withText:@"위치정보 셋팅을 거부하셨습니다. 환경설정에서 변경하시기 바랍니다." withDuaration:3.0];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                    //최초선택이면...
                    else{
                        //위치기반 팝업 묻기...
                        self.locationManager = [[CLLocationManager alloc] init];
                        if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                            [self.locationManager requestWhenInUseAuthorization];
                        }
                        self.locationManager.delegate = self;
                        [self.locationManager startUpdatingLocation];
                        
                        [ToastAlertView showToastInParentView:self.view withText:@"위치권한 선택 후 출퇴근을 다시 수행해 주세요." withDuaration:3.0];
                    }
                    
                }
                //E : 위치선택여부에 따라 권한 획득 및 설정에서 처리하게 하기(2021년 1월 26일 Park Jong Hoon)
                NSLog(@"GPSRun end  :::::!!!!" );
            }
            //E : Google맵 추가(2019년 4월 18일 Park Jong Hoon)
            //S : 카카오 음성인식 추가로 인한 수정(2019년 10월 18일 Park Jong Hoon)
            else if ([@"VoiceToText" isEqual:type]) {
                NSLog(@"VoiceToText START");
                
                // S: 카카오 음성인식 적용 중 (2022.11.14 Jung Mirae)
                //KakaoSTT *stt = [[KakaoSTT alloc] initWithNibName:@"KakaoSTT" bundle:nil];
                //[stt viewDidLoad];
                // S: 카카오 음성인식 적용 중 (2022.11.14 Jung Mirae)
                
                UIStoryboard *sb = [self storyboard];
                BOOL *available = [MTSpeechRecognizer isRecordingAvailable]; //사용자에게 마이크 접근 허용 여부를 묻는 확인 창
                BOOL *grantedPermission = [MTSpeechRecognizer isGrantedRecordingPermission]; //마이크 접근 허용이 승인되어 있는지를 확인

                NSString *availableYn = @"N";
                if(available){
                    availableYn = @"Y";
                }

                NSString *grantedPermissionYn = @"N";
                if(grantedPermission){
                    grantedPermissionYn = @"Y";
                }


                NSLog(@"available : %@", availableYn);
                NSLog(@"grantedPermission : %@", grantedPermissionYn);

                // 설정 정보 생성
                NSDictionary *config = @{SpeechRecognizerConfigKeyApiKey : @"kakaobf18f87221412dec803ed22b4798d1e9",SpeechRecognizerConfigKeyCustomStrings : @"SpeechRecognizerDefault", SpeechRecognizerConfigKeyServiceType:SpeechRecognizerServiceTypeDictation, SpeechRecognizerConfigKeyAudioCategory:AVAudioSessionCategoryPlayAndRecord, SpeechRecognizerConfigKeyRecgTimeout:@90, SpeechRecognizerConfigKeyAudioConfigOn:@(YES), SpeechRecognizerConfigKeyShowSuggestView : @(NO)};


                // 클라이언트 생성
                MTSpeechRecognizerView *speechRecognizerView = [[MTSpeechRecognizerView alloc]  initWithFrame:self.qrView.frame withConfig:config];

                //델리게이크 설정
                speechRecognizerView.delegate = self; // view의 delegate 설정

                [self.view addSubview:speechRecognizerView];
                [speechRecognizerView show];
            }
            //E : 카카오 음성인식 추가로 인한 수정(2019년 10월 18일 Park Jong Hoon)
            //S : 카카오 텍스트 ->음성전환 추가로 인한 수정(2019년 11월 20일 Park Jong Hoon)
            else if ([@"TextToVoice" isEqual:type]) {
                NSLog(@"TextToVoice START : %@" , [list objectAtIndex:2]);
                NSString *param = [list objectAtIndex:2];
                
                // 설정 정보 생성
                NSDictionary *config =
                @{TextToSpeechConfigKeySpeechSpeed: @(1.0),TextToSpeechConfigKeyVoiceType: TextToSpeechVoiceTypeWoman, TextToSpeechConfigServiceMode:NewtoneTalk_2};

                // 클라이언트 생성
                 MTTextToSpeechClient *textToSpeechClient =
                     [[MTTextToSpeechClient alloc] initWithConfig:config];

                // 델리게이트 설정
                textToSpeechClient.delegate = self;

                [textToSpeechClient play:param];
            }
            //E : 카카오 텍스트 ->음성전환 추가로 인한 수정(2019년 11월 20일 Park Jong Hoon
            //S:iOS NFC기능 추가(2019년 11월 22일 Park Jong Hoon)
            else if ([@"IosNFCScan" isEqual:type]) {
                NSLog(@"NFC START");
                
//                UIStoryboard *sb = [self storyboard];
//                NfcReaderController *nfcReader = [sb instantiateViewControllerWithIdentifier:@"NfcReaderController"];
//                //[self callImge:[decoded substringFromIndex:([type length]+7)]];
//                NSLog(@"NFC 11111  :::::!!!!" );
//                if(self.navigationController){
//                    [self.navigationController pushViewController:nfcReader animated:true];
//                }
//                else{
//                    [self presentViewController:nfcReader animated:YES completion:nil];
//                }
                if (@available(iOS 11.0, *)) {
                    NSLog(@"11버젼 이상임!!");
                    [self beginSession];;
                }
                else{
                    NSLog(@"11버젼 이하임!!");
                    [ToastAlertView showToastInParentView:self.view withText:@"iOS 11버젼 이상부터 사용가능합니다.!!" withDuaration:3.0];
                }
                
                NSLog(@"NFC end  :::::!!!!" );
            
            }
            //E : iOS NFC기능 추가(2019년 11월 22일 Park Jong Hoon)

        }
        else if([@"https" isEqual:requesturl1]) {
            NSLog(@"https start and end  :::::!!!!" );
            
        }
    }
    //2017년 2월 27일 Choi Yu Bin 추가종료
    return YES;
}

//S : 카카오 음성인식 추가로 인한 수정(2019년 11월 6일 Park Jong Hoon)
- (void) onPartialResult:(NSString *)partialResult {
    // 음성 인식 실행 중 중간 결과가 있을 때 호출됩니다.
}

- (void) onResults:(NSArray *)results confidences:(NSArray *)confidences marked:(BOOL)marked {
    // results : 음성 인식 결과 리스트로 신뢰도 순으로 정렬.
    // confidences : results 각각의 결과에 대한 신뢰도 값 리스트.
    // marked : results의 신뢰도가 가장 높은 0번째 data가 신뢰할 만한 값인지의 여부.
    NSInteger i = 0;
    for(i = 0; i<[results count]; i++){
        NSLog(@"onResults : %@ / confidences : %@ / marked : %hhd", results[i], confidences[i], marked);
    }
    
    NSString *returnString = [NSString stringWithFormat:@"setTextSend('%@');",results[0]];
    NSLog(@"scriptString => %@", returnString);
    [_webView stringByEvaluatingJavaScriptFromString:returnString];
}

// 음성 인식 도중 에러가 발생했을 때 호출됩니다.
- (void) onError: (MTSpeechRecognizerError) errorCode message:(NSString *) message {
    NSLog(@"errorCode : %ld / %@", (long)errorCode, message);
}

- (void)onReady {
    // 음성 인식을 위한 준비가 완료되었을 때 호출됩니다.
}

- (void)onBeginningOfSpeech {
    // 녹음 시작이될 때 호출됩니다.
}

- (void)onEndOfSpeech {
    // 녹음 후 분석 중일때 호출됩니다.
}

- (void)onAudioLevel:(float)level {
    // 음성 audio level. (0 ~ 1)
}

//S : TextToVoice 분치처리(2021년 4월 12일 Park Jong Hoon)
-(void)readToText:(NSString*) arg{
    NSLog(@"readToTextString => %@", arg);
    
    // 설정 정보 생성
    NSUInteger intOption = AVAudioSessionCategoryOptionMixWithOthers;
    
    NSDictionary *config =
    @{TextToSpeechConfigKeySpeechSpeed: @(1.0),TextToSpeechConfigKeyVoiceType: TextToSpeechVoiceTypeWoman,
      TextToSpeechConfigServiceMode:NewtoneTalk_2, TextToSpeechConfigKeyAudioType: [NSNumber numberWithInt:intOption],
      TextToSpeechConfigKeyAudioCategory: AVAudioSessionCategoryPlayback, TextToSpeechConfigKeyAudioSessionConfigOn: [NSNumber numberWithBool:YES] };
    
    // 클라이언트 생성
     MTTextToSpeechClient *textToSpeechClient =
         [[MTTextToSpeechClient alloc] initWithConfig:config];

    // 델리게이트 설정
    textToSpeechClient.delegate = self;

    [textToSpeechClient play:arg];
    //[textToSpeechClient stop];
}
//E : TextToVoice 분치처리(2021년 4월 12일 Park Jong Hoon)
//E : 카카오 음성인식 추가로 인한 수정(2019년 11월 6일 Park Jong Hoon)


//2017년 2월 27일 Choi Yu Bin 추가시작
-(void) senderInfoText:(NSString*) arg{
    if ([@"1" isEqual:arg]) {
        senderinfo = @"[화재]";
        EmcCode = @"FR01";
    } else if ([@"2" isEqual:arg]) {
        senderinfo = @"[누수/동파]";
        EmcCode = @"WT01";
    } else if ([@"3" isEqual:arg]) {
        senderinfo = @"[정전/누전]";
        EmcCode = @"KW01";
    } else if ([@"4" isEqual:arg]) {
        senderinfo = @"[안전사고]";
        EmcCode = @"HA01";
    } else if ([@"5" isEqual:arg]) {
        senderinfo = @"[가스]";
        EmcCode = @"GS01";
    } else if ([@"6" isEqual:arg]) {
        senderinfo = @"[승강기고장]";
        EmcCode = @"EV01";
    } else if ([@"7" isEqual:arg]) {
        senderinfo = @"[긴급공지]";
        EmcCode = @"EM01";
    }
    titleinfo = [NSString stringWithFormat:@"%@%@", senderinfo, @"발신"];
    senderinfo = [NSString stringWithFormat:@"%@%@", senderinfo, [[GlobalDataManager getgData] empNo]];
    NSLog(@"~~~~~~~~~~~~~~~ titleinfo : %@", titleinfo);
    NSLog(@"~~~~~~~~~~~~~~~ senderinfo : %@", senderinfo);
}
//2017년 2월 27일 Choi Yu Bin 추가종료

//개인정보동의 alert 창 callback
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@";alert ?? %ld",(long)buttonIndex);
    //S : 출차 시 출타통보 알랑 띄우기(2019년 11월 13일 Park Jong Hoon)
     if(alertView.tag==103)     // check alert by tag
    {
        NSLog(@"출타통보 ViewControoler");
        if(buttonIndex ==1)
        {
            NSLog(@"출타통보 ViewControoler 클릭");
            
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            //NSString *server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            
            NSString *pageUrl = @"/pms_carInOutReg.do";
            NSString *callUrl = @"";

            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];

            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [self.webView loadRequest:requestURL];
        }
    }
    //E : 출차 시 출타통보 알랑 띄우기(2019년 11월 13일 Park Jong Hoon)
     else{
        if(buttonIndex ==1)
        {
            CallServer *res = [CallServer alloc];
            NSLog(@"%@",res);
            
            NSMutableDictionary* param = [GlobalDataManager getAllData];
            NSLog(@"%@",param);
            
            NSString* str = [res stringWithUrl:@"invInfo.do" VAL:param];
            NSLog(@"%@",str);
        }else{
            exit(0);
        }
     }
}
//Error시 실행
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"IDI FAIL");
}

//WebView 시작시 실행
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"START LOAD");
    
    
}

//WebView 종료 시행
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"FNISH LOAD");
}

//script => app funtion
-(void) login:(NSString*) data{
    NSError *error;
    
    NSLog(@"?logindata %@",data);
    NSData *sessionjsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *sessionjsonInfo = [NSJSONSerialization JSONObjectWithData:sessionjsonData options:kNilOptions error:&error];
    
    if([@"s"isEqual:[sessionjsonInfo valueForKey:@"rv"] ] )
    {
        if([@"Y"isEqual:[sessionjsonInfo valueForKey:@"result"] ] )
        {
            viewType = @"LOGIN";
            NSDictionary *sessiondata = [sessionjsonInfo valueForKey:(@"data")];
            [GlobalDataManager initgData:(sessiondata)];
            NSArray * timelist = [sessionjsonInfo objectForKey:@"inout"];
            [GlobalDataManager setTime:[timelist objectAtIndex:0]];
            NSArray * authlist = [sessionjsonInfo objectForKey:@"auth"];
            [GlobalDataManager initAuth:authlist];
            beaconYN = [sessiondata valueForKey:@"BEACON_YN"];
            NSString * text =@"본 어플리케이션은 원할한 서비스를\n제공하기 위해 휴대전화번호등의 개인정보를 사용합니다.\n[개인정보보호법]에 의거해 개인정보 사용에 대한 \n사용자의 동의를 필요로 합니다.\n개인정보 사용에 동의하시겠습니까?\n";
            if(![@"Y" isEqualToString:[sessiondata valueForKey:@"INFO_YN"]])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:text delegate:self
                                                      cancelButtonTitle:@"취소"
                                                      otherButtonTitles:@"동의", nil];
                [alert show];
            }
            
            NSLog(@"gcmid = %@",[[GlobalDataManager getgData] gcmId]);
            NSLog(@"PJH TEST~~~~~~ = %@",[[GlobalDataManager getgData] gcmId]);
            
            CallServer *res = [CallServer alloc];
            NSLog(@"res = %@",res);
            UIDevice *device = [UIDevice currentDevice];
            NSString* idForVendor = [device.identifierForVendor UUIDString];
            NSString *fcmToken = ((AppDelegate*)[UIApplication sharedApplication].delegate).fcmID; // FCM 토큰 가져오기(2022.11.11
            
            NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
            
            [param setValue:idForVendor forKey:@"HP_TEL"];
            [param setValue: fcmToken forKey:@"GCM_ID"];
            [param setObject:@"I" forKey:@"DEVICE_FLAG"];
            
            NSInteger *iosVer = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
            struct utsname systemInfo;
            uname(&systemInfo);
            NSString *iosModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
            
            
            [param setObject: appVersion forKey:@"VERSION_NM"]; // VERSION_NM 추가 (2022.11.09 Jung Mirae)
            [param setObject:[sessiondata valueForKey:@"COMP_CD"] forKey:@"COMP_CD"];//2017년 2월 27일 Choi Yu Bin 추가
            [param setObject:[sessiondata valueForKey:@"EMPNO"] forKey:@"EMPNO"];//2017년 2월 27일 Choi Yu Bin 추가
            
            //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
            [param setObject:[NSString stringWithFormat:@"%d",iosVer] forKey:@"BUILD_SDK"];
            [param setObject: iosModel forKey:@"PACKAGE_ID"];
            //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
            
            //R 수신
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                NSString* str = [res stringWithUrl:@"registGCM.do" VAL:param];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"response data ===> %@",str);

                    //server = [GlobalData getServerIp]; //server 전역 범위로 변경 (2022.11.09 Jung Mirae)
       
                    NSString *pageUrl = @"/DWFMS";
                    NSString *callUrl = @"";
                    
                    NSLog(@"비콘 사용 체크인가?? Authorized when in use");
                    callUrl = [NSString stringWithFormat:@"%@%@#home", server, pageUrl];
                    
                    NSURL *url = [NSURL URLWithString:callUrl];
                    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                    
                    [self.webView loadRequest:requestURL];
                });
            });
            
            if(![@"N" isEqualToString:[data valueForKey:@"BEACON_YN"]]){    //2017년 10월 27일 Park Jong Hoon 비콘일 경우 만 아래 로직 타게...
                _uuidList = @[
                              [[NSUUID alloc] initWithUUIDString:[sessiondata valueForKey:@"BEACON_UUID"]]
                              //24DDF411-8CF1-440C-87CD-E368DAF9C93E
                              // you can add other NSUUID instance here.
                              ];

                [_uuidList enumerateObjectsUsingBlock:^(NSUUID *uuid, NSUInteger idx, BOOL *stop) {
                    //NSString *identifier = [NSString stringWithFormat:@"RECOBeaconRegion-%lu", (unsigned long)idx];/2017년 2월 27일 Choi Yu Bin 주석처리
                    NSString *identifier = @"us.iBeaconModules";//2017년 2월 27일 Choi Yu Bin 추가
                    
                    [self registerBeaconRegionWithUUID:uuid andIdentifier:identifier];
                    
                }];

                //2017년 2월 27일 Choi Yu Bin 추가
                switch ([CLLocationManager authorizationStatus]) {
                    case kCLAuthorizationStatusAuthorizedAlways:
                        NSLog(@"Authorized Always");
                        break;
                    case kCLAuthorizationStatusAuthorizedWhenInUse:
                        NSLog(@"Authorized when in use");
                        break;
                    case kCLAuthorizationStatusDenied:
                        NSLog(@"Denied");
                        break;
                    case kCLAuthorizationStatusNotDetermined:
                        NSLog(@"Not determined");
                        break;
                    case kCLAuthorizationStatusRestricted:
                        NSLog(@"Restricted");
                        break;
                        
                    default:
                        break;
                        
                }
                self.locationManager = [[CLLocationManager alloc] init];

                //2017년 04월 03일 Choi Yu Bin 추가 - 위치서비스 항상허용 제외, 앱을 사용하는 동안만 사용 하도록 설정
                if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [self.locationManager requestWhenInUseAuthorization];
                }
                self.locationManager.distanceFilter = YES;
                
                self.locationManager.delegate = self;
                self.locationManager.pausesLocationUpdatesAutomatically = YES;//pause상태에서의 스캔여부
                [self.locationManager startMonitoringForRegion:beaconRegion];
                [self.locationManager startRangingBeaconsInRegion:beaconRegion];
                [self.locationManager startUpdatingLocation];
            }  //2017년 10월 27일 Park Jong Hoon 비콘일 경우 만 아래 로직 타게...
        } else {
            
            [ToastAlertView showToastInParentView:self.view withText:@"아이디와 패스워드를 확인해주세요." withDuaration:3.0];
 
        }
        
    } else {
        
    }
}


//2017년 2월 27일 Choi Yu Bin 추가
//script => app funtion
-(void) sendEmc:(NSString*) data{
    NSLog(@"????? sendEmc data: %@",data);
    NSArray *locationImages = [data componentsSeparatedByString:@"\\"];
    NSString *argLocation = [locationImages objectAtIndex:0];
    NSString *argImages = [locationImages objectAtIndex:1];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:argLocation forKey:@"location"];
    [param setValue:argImages forKey:@"save_IMGS"];
    [param setValue:EmcCode forKey:@"code"];
    [param setValue:@"S" forKey:@"gubun"];
    [param setObject:idForVendor forKey:@"deviceId"];
    [param setValue:beaconKey forKey:@"beacon_key"];
    
    //R 수신
    
    CallServer *res = [CallServer alloc];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        //R 수신
        NSString* str = [res stringWithUrl:@"emcInfoPush.do" VAL:param];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            NSLog(@"emcInfoPush str ====> %@", str);
            
            if(     [@"SUCCESS"isEqual:[jsonInfo valueForKey:@"RESULT"] ] )
            {
                //전송완료 되었음.....
                [ToastAlertView showToastInParentView:self.view withText:@"전송이 완료되었습니다." withDuaration:3.0];
                                
                NSString* callActionGuide = @"";
                
                if (![@"EM01" isEqual:EmcCode]) {
                    NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
                    
                    // S: 포트 변경 로직 추가하며 getServerIp -> server 수정(2022.11.09 Jung Mriae)
                    callActionGuide = [NSString stringWithFormat:@"%@/emcActionGuide_master.do?COMP_CD=%@&CODE=%@&BEACON_KEY=%@", server, [sessiondata valueForKey:@"session_COMP_CD"], EmcCode, beaconKey];
//                    callActionGuide = [NSString stringWithFormat:@"%@/emcActionGuide_master.do?COMP_CD=%@&CODE=%@&BEACON_KEY=%@", [GlobalData getServerIp:(port)], [sessiondata valueForKey:@"session_COMP_CD"], EmcCode, beaconKey];
                    // S: 포트 변경 로직 추가하며 getServerIp 수정(2022.11.09 Jung Mriae)
                } else {
                    // S: 포트 변경 로직 추가하며 getServerIp -> server 수정(2022.11.09 Jung Mriae)
                    callActionGuide = [NSString stringWithFormat:@"%@/#home", server];
//                    callActionGuide = [NSString stringWithFormat:@"%@/#home", [GlobalData getServerIp:(port)]];
                }
                
                NSString *urlParam=@"";
                NSURL *url=[NSURL URLWithString:callActionGuide];
                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                [requestURL setHTTPMethod:@"POST"];
                [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                [self.webView loadRequest:requestURL];
                
                NSLog(@"??????? urlParam %@",callActionGuide);
                
            }
            else{
                //S : 전송이 실패되었을 경우 확인 필요(2019년 5월 20일 Park Jong Hoon) - 발신앱이 설치가 안되어 Deviced_id로 Hp번호를 못가져올 경우
                [ToastAlertView showToastInParentView:self.view withText:@"전송이 실패되었습니다.!!UBISEcall 발신앱을 설치해주세요.!!또는 관리자에게 권한부여를 요청하세요.!!" withDuaration:3.0];
                //E : 전송이 실패되었을 경우 확인 필요(2019년 5월 20일 Park Jong Hoon)
            }
        });
    });
}



-(void) callImge:(NSString*) data{
    NSLog(@"callimge??");
    NSArray* list = [data componentsSeparatedByString:@"&"];
    
    
    NSMutableDictionary * temp =[[NSMutableDictionary alloc] init];
    
    for(int i =0;i<[list count];i++){
        NSArray* listTemp =   [[list objectAtIndex:i] componentsSeparatedByString:@"="];
        [temp setValue:[listTemp objectAtIndex:1] forKey:[listTemp objectAtIndex:0]];
        
        NSLog(@" key %@  value %@ ",[listTemp objectAtIndex:0],[listTemp objectAtIndex:1]);
    }
    [[GlobalDataManager getgData]setCameraData:temp];
    
    [self performSegueWithIdentifier:@"CameraCall" sender:self];
}

// S: 잠깐 주석처리 (이미지 다중 선택 구현 중.. 2022.11.17 Jung Mirae)
- (void) setimage:(NSString*) path num:(NSNumber*) num {
    //       NSString * searchWord = @"/";
    //    NSString * replaceWord = @"\\\\";
    //    path =  [path stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    NSLog(@"ddd path %@ num %@",path,num);

    NSString *scriptString = [NSString stringWithFormat:@"setimge('%@','%@');",path,num];
    NSLog(@"scriptString => %@", scriptString);
    [self.webView stringByEvaluatingJavaScriptFromString:scriptString];
}

// 원코드
//- (void) setimage:(NSString*) path num:(NSString*)num{
//    //       NSString * searchWord = @"/";
//    //    NSString * replaceWord = @"\\\\";
//    //    path =  [path stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
//    NSLog(@"ddd path %@ num %@",path,num);
//
//    NSString *scriptString = [NSString stringWithFormat:@"setimge('%@','%@');",path,num];
//    NSLog(@"scriptString => %@", scriptString);
//    [self.webView stringByEvaluatingJavaScriptFromString:scriptString];
//}
// E: 잠깐 주석처리 (이미지 다중 선택 구현 중.. 2022.11.17 Jung Mirae)

//QR코드 넘겨받았을 시....
- (void) setQRcode:(NSString*) data {
    //    request_contents.put("SERIAL_NO", SERIAL_NO);
    //    request_contents.put("url", "getQRJobTpy.do");
    NSLog(@"????? setQRcode data: %@",data);
    NSLog(@"????? PJH TEST setQRcode data: %@",data);
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:data forKey:@"SERIAL_NO"];
    
    //deviceId
    
    //R 수신
    CallServer *res = [CallServer alloc];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSString* str = [res stringWithUrl:@"getQRJobTpy.do" VAL:param];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            
            NSLog(@"getQRJobTpy.do str ====> %@",str);
            
            if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
            {
                if(     [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
                {
                    //2017.05.18 변수형식 변경
                    //NSDictionary *resdata = [jsonInfo valueForKey:(@"data")];
                    NSMutableDictionary *resdata = [jsonInfo valueForKey:(@"data")];
                    
                    if(  !   [[[GlobalDataManager getgData] compCd ]isEqual:[resdata valueForKey:@"COMP_CD"] ] )
                    {
                        //다른 사업장 업무입니다.
                        //NSLog(@"다른사업장의 업무 입니다.");
                        [ToastAlertView showToastInParentView:self.view withText:@"다른사업장의 업무 입니다." withDuaration:3.0];
                        return;
                    }
                    
                    if(     [@"00"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
                    {
                        [ToastAlertView showToastInParentView:self.view withText:@"QR업무를 등록해 주세요." withDuaration:3.0];
                        NSString *pageUrl = @"/registrationQR.do";
                        
                        // S: ServerIp -> server로 변경 (2022.11.10 Jung Mirae)
                        //NSString *callurl = [NSString stringWithFormat:@"%@%@?SERIAL_NO=%@",ServerIp,pageUrl,data];
                        NSString *callurl = [NSString stringWithFormat:@"%@%@?SERIAL_NO=%@",server,pageUrl,data];
                        // E: ServerIp -> server로 변경 (2022.11.10 Jung Mirae)
                        
                        NSLog(@"???????%@",callurl);
                        NSURL *url=[NSURL URLWithString:callurl];
                        
                        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                        
                        
                        [self.webView loadRequest:requestURL];
                        
                        
                        return;
                        
                    }
                    
                    if(     [self isUpdateQr] )
                    {
                        [ToastAlertView showToastInParentView:self.view withText:@"QR업무를 수정합니다." withDuaration:3.0];
                        
                        NSString *pageUrl = @"/registrationQR.do";
                        // S: ServerIp -> server로 변경 (2022.11.10 Jung Mirae)
                        //NSString *callurl = [NSString stringWithFormat:@"%@%@?SERIAL_NO=%@",ServerIp,pageUrl,data];
                        NSString *callurl = [NSString stringWithFormat:@"%@%@?SERIAL_NO=%@",server,pageUrl,data];
                        // E: ServerIp -> server로 변경 (2022.11.10 Jung Mirae)
                        
                        NSLog(@"???????%@",callurl);
                        NSURL *url=[NSURL URLWithString:callurl];
                        
                        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                        
                        
                        [self.webView loadRequest:requestURL];
                        
                        return;
                        
                    }
                    
                    //보안순찰 시...
                    if(     [@"01"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
                    {
                        [ToastAlertView showToastInParentView:self.view withText:@"보안순찰업무로 이동합니다." withDuaration:3.0];
                        
                        [self callPatrol:resdata];
                    }
                    
                    //출근업무 시...
                    if( [@"02"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
                    {
                        //S : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
                        //[self setInOutCommitInfo:resdata];
                        [self setInOutCommitInfo:resdata nfcYn:@"N"];
                        //E : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
                    }
                    
                    //퇴근업무시...
                    if( [@"03"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
                    {
                        //S : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
                        //[self setInOutCommitInfo:resdata];
                        [self setInOutCommitInfo:resdata nfcYn:@"N"];
                        //E : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
                    }
                    
                    //S : 원폴라리스 점심시간 출퇴근시간 로직추가(2022년 4월 25일 Park Jong Hoon)
                    //점심시간 시작 시...
                    if( [@"12"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
                    {
                        [self setInOutCommitInfo:resdata nfcYn:@"N"];
                    }
                    
                    //점심시간 종료 시...
                    if( [@"13"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
                    {
                        [self setInOutCommitInfo:resdata nfcYn:@"N"];
                    }
                    //E : 원폴라리스 점심시간 출퇴근시간 로직추가(2022년 4월 25일 Park Jong Hoon)
                    
                    //시설점검 업무시...
                    if( [@"04"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
                    {
                        [ToastAlertView showToastInParentView:self.view withText:@"시설점검업무로 이동합니다." withDuaration:3.0];
                        [self callChkWork:resdata];
                    }
                    
                    //S: 미화점검 로직 추가(2022.02.03 Hwang Ja Young)
                    //미화점검 업무시...
                    if( [@"06"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
                    {
                        [ToastAlertView showToastInParentView:self.view withText:@"미화점검업무로 이동합니다." withDuaration:3.0];
                        [self callCleanWork:resdata];
                    }
                    //E: 미화점검 로직 추가(2022.02.03 Hwang Ja Young)
                    
                    //S : PMS입/출차처리 로직 추가(2018년 11월 20일 Park Jong Hoon)
                    //PMS입차처리...
                    if( [@"21"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
                    {
                        [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 입차처리 중입니다.." withDuaration:3.0];
                        [self callPmsIn:resdata];
                    }

                    //PMS출차처리...
                    if( [@"22"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
                    {
                        [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 출차처리 중입니다.." withDuaration:3.0];
                        [self callPmsOut:resdata];
                    }
                    //E : PMS입/출차처리 로직 추가(2018년 11월 19일 Park Jong Hoon)
                }
                
            }
        });
    });
    
}

-(void) callPatrol:(NSMutableDictionary * ) param{
    CallServer *res = [CallServer alloc];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        //R 수신
        NSString* str = [res stringWithUrl:@"PSTag.do" VAL:param];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            NSLog(@"PSTag.do str ====> %@",str);
            
            NSArray * authlist = [[GlobalDataManager getgData] auth];
            
            
            NSLog(@" ?? %@ ",(  [authlist containsObject:@"fms653"] ? @"YES" : @"NO"));
            if(![authlist containsObject:@"fms653"]){
                //권한이 없습니다.
                return;
            }
            if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
            {
                NSArray * temparray = [jsonInfo valueForKey:(@"data")];
                NSDictionary *resdata = [temparray objectAtIndex:0];
                
                //mWebView.loadUrl(GlobalData.getServerIp()+"/patrolService.do?LOC_ID="+psdata.getString("PAT_LOC_ID")+"&PAT_CHECK_DT="+psdata.getString("sh_PAT_CHECK_DT")+"#detail");
                //NSLog([resdata valueForKey:@"sh_PAT_CHECK_DT"]);
                NSLog(@"%@", [resdata valueForKey:@"sh_PAT_CHECK_DT"]);
                NSMutableDictionary * tempParam = [[NSMutableDictionary alloc] init];
                [tempParam setValue:[resdata valueForKey:@"sh_PAT_CHECK_DT"] forKey:@"PAT_CHECK_DT"];
                [tempParam setValue:[resdata valueForKey:@"PAT_LOC_ID"] forKey:@"LOC_ID"];
                
                //S : iOS 등록/조회 권한에 따른 수정(2018년 9월 7일 Park Jong Hoon)
                [tempParam setValue:[resdata valueForKey:@"WRITE_YN"] forKey:@"WRITE_YN"];
                [tempParam setValue:[resdata valueForKey:@"PAT_EDIT_YN"] forKey:@"PAT_EDIT_YN"];
                //E : iOS 등록/조회 권한에 따른 수정(2018년 9월 7일 Park Jong Hoon)
                
                //S : 순찰관리 QR코드 분개 시 처리를 위한 추가(2022년 5월 11일  Park Jong Hoon)
                NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
                [tempParam setValue:@"I" forKey:@"DEVICE_FLAG"];
                [tempParam setValue:[sessiondata valueForKey:@"session_VERSION"] forKey:@"VERSION"];
                //E : 순찰관리 QR코드 분개 시 처리를 위한 추가(2022년 5월 11일  Park Jong Hoon)
                
                
                NSString *urlParam=[Commonutil serializeJson:tempParam];
                NSLog(@"??????? %@",urlParam);
                
                // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
                //NSString *server = [GlobalData getServerIp];
//                NSString *server = [GlobalData getServerIp:(port)];
                // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
                
                NSString *pageUrl = @"/patrolService.do#detail";
                NSString *callurl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                //        NSString *pageUrl = @"/patrolService.do?";
                //        NSString *callurl = [NSString stringWithFormat:@"%@%@%@#detail",server,pageUrl,urlParam];
                NSLog(@"???????%@",callurl);
                NSURL *url=[NSURL URLWithString:callurl];
                
                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                [requestURL setHTTPMethod:@"POST"];
                [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                
                // S : 순찰 pro 버전 화면이 나타나지 않아 주석처리 (2022년 9월 29일 Jung Mirae)
                //[requestURL setHTTPShouldHandleCookies:NO];
                // E : 순찰 pro 버전 화면이 나타나지 않아 주석처리 (2022년 9월 29일 Jung Mirae)

                requestURL.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                
                NSString *currentURL = [[[self.webView request] URL] absoluteString];
                NSLog(@"???currentURL???%@",currentURL);
                
                if ([currentURL rangeOfString:@"patrolService"].location == NSNotFound) {
                    [self.webView loadRequest:requestURL];
                    NSLog(@"string does not contain bla");
                    
                } else {
                    NSString *scriptParameter = [NSString stringWithFormat:
                                                 @"viewDetailIos('%@','%@');",
                                                 [resdata valueForKey:@"PAT_LOC_ID"] ,
                                                 [resdata valueForKey:@"sh_PAT_CHECK_DT"],
                                                 //S : iOS 등록/조회 권한에 따른 수정(2018년 9월 7일 Park Jong Hoon)
                                                 [resdata valueForKey:@"WRITE_YN"],
                                                 [resdata valueForKey:@"PAT_EDIT_YN"]
                                                 //E : iOS 등록/조회 권한에 따른 수정(2018년 9월 7일 Park Jong Hoon)
                                                 ];
                    NSLog(@"scriptString => %@", scriptParameter);
                    
                    [self.webView stringByEvaluatingJavaScriptFromString:scriptParameter];
                    NSLog(@"string does contain bla");
                    
                }
                //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:testURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0]];
                NSLog(@"???????%@",requestURL);
                
                
                
                
            }
        });
    });
    //
}


//QR 출퇴근 로직처리
//S : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
//-(void) setInOutCommitInfo :(NSMutableDictionary * ) param nfcYn:(NSString *) nfcYn{
-(void) setInOutCommitInfo :(NSMutableDictionary * ) param nfcYn:(NSString *) nfcYn{
//E : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
    //S : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
    //NFC구분자 이면 블루투스 로직 타지 않도록 추가
    NSLog(@"nfcYn : %@", nfcYn);
    //E : Nfc추가하였기 때문에 구분자 추가(2021년 1월 26일 Park Jong Hoon)
    
    if(![@"Y"isEqual:nfcYn]){
        NSLog(@"beaconstatus ::::::: %@, %@", [GlobalData getbeacon], beaconYN);
        
        if([self detectBluetooth] == TRUE){
            NSLog(@"bluetooth use");
            bluetoothYN = @"Y";
        }else{
            
            NSLog(@"bluetooth unuse");
            bluetoothYN = @"N";
        }
        
        NSLog(@"bluethooth YN 1 ::::%@", bluetoothYN);
        
        
        //if ([@"Y"isEqual:beaconYN] && [@"Y"isEqual:bluetoothYN]) {
        if ([@"Y"isEqual:beaconYN]) {
            if([@"F"isEqual:[GlobalData getbeacon]] || [@"N"isEqual:bluetoothYN]){
                NSLog(@"beacon access Fail~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                [ToastAlertView showToastInParentView:self.view withText:@"근무지를 벗어난 곳에서는 QR업무를 사용 하실 수 없습니다.\n[ 블루투스를 확인해 주세요 ]" withDuaration:3.0];
                return;
            }
        }
    }
    
    CallServer *res = [CallServer alloc];
    NSLog(@"%@",res);
    
    
    NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
    
    [sessiondata addEntriesFromDictionary:param];
    
    NSLog(@"??? sessiondata ?? %@" ,sessiondata);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        //R 수신
        NSString* str = [res stringWithUrl:@"setInOutCommitInfo.do" VAL:sessiondata];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"%@",str);
            
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"%@",jsonData);
            NSError *error;
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            NSLog(@"%@",jsonInfo);
            
            //S : 원폴라리스 점심시간 출퇴근시간 로직추가(2022년 4월 25일 Park Jong Hoon)
            //if(     [@"02"isEqual:[sessiondata valueForKey:@"JOB_TPY"] ] ) {
            //    [ToastAlertView showToastInParentView:self.view withText:@"출근이 정상적으로 등록되었습니다." withDuaration:3.0];
            //} else if(     [@"03"isEqual:[sessiondata valueForKey:@"JOB_TPY"] ] ) {
            //    [ToastAlertView showToastInParentView:self.view withText:@"퇴근이 정상적으로 등록되었습니다." withDuaration:3.0];
            //} else {
            //    [ToastAlertView showToastInParentView:self.view withText:@"출/퇴근이 정상적으로 등록되었습니다." withDuaration:3.0];
            //}
            
            //출근
            if([@"02"isEqual:[sessiondata valueForKey:@"JOB_TPY"] ] ) {
                [ToastAlertView showToastInParentView:self.view withText:@"출근이 정상적으로 등록되었습니다." withDuaration:3.0];
            }
            //퇴근
            else if([@"03"isEqual:[sessiondata valueForKey:@"JOB_TPY"] ] ) {
                [ToastAlertView showToastInParentView:self.view withText:@"퇴근이 정상적으로 등록되었습니다." withDuaration:3.0];
            }
            //점심시작
            else if([@"12"isEqual:[sessiondata valueForKey:@"JOB_TPY"] ] ) {
                [ToastAlertView showToastInParentView:self.view withText:@"점심시작 시간이 정상적으로 등록되었습니다." withDuaration:3.0];
            }
            //졈심종료
            else if([@"13"isEqual:[sessiondata valueForKey:@"JOB_TPY"] ] ) {
                [ToastAlertView showToastInParentView:self.view withText:@"점심종료 시간이 정상적으로 등록되었습니다." withDuaration:3.0];
            }
            else {
                [ToastAlertView showToastInParentView:self.view withText:@"출/퇴근이 정상적으로 등록되었습니다." withDuaration:3.0];
            }
            //E : 원폴라리스 점심시간 출퇴근시간 로직추가(2022년 4월 25일 Park Jong Hoon)
            
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//            NSString *server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *pageUrl = @"/DWFMS";
            NSString *callUrl = @"";
            
            
            
            callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [self.webView loadRequest:requestURL];
        });
    });
}

//QR시설점검 로직처리..
-(void) callChkWork:(NSMutableDictionary * ) param{
    CallServer *res = [CallServer alloc];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        //R 수신
        NSString* str = [res stringWithUrl:@"CHKWORKTag.do" VAL:param];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            NSLog(@"?? %@",str);
            
            NSArray * authlist = [[GlobalDataManager getgData] auth];
            
            
            NSLog(@" ?? %@ ",(  [authlist containsObject:@"fms653"] ? @"YES" : @"NO"));
            if(![authlist containsObject:@"fms113"]){
                //권한이 없습니다.
                return;
            }
            if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
            {
                NSArray * temparray = [jsonInfo valueForKey:(@"data")];
                NSDictionary *resdata = [temparray objectAtIndex:0];
                
                //mWebView.loadUrl(GlobalData.getServerIp()+"/patrolService.do?LOC_ID="+psdata.getString("PAT_LOC_ID")+"&PAT_CHECK_DT="+psdata.getString("sh_PAT_CHECK_DT")+"#detail");
                //NSLog([resdata valueForKey:@"sh_PAT_CHECK_DT"]);
                NSLog(@"%@", [resdata valueForKey:@"sh_PAT_CHECK_DT"]);
                NSMutableDictionary * tempParam = [[NSMutableDictionary alloc] init];
                [tempParam setValue:[resdata valueForKey:@"sh_PAT_CHECK_DT"] forKey:@"PAT_CHECK_DT"];
                [tempParam setValue:[resdata valueForKey:@"PAT_LOC_ID"] forKey:@"LOC_ID"];
                
                
                
                
                NSString *urlParam=[Commonutil serializeJson:tempParam];
                NSLog(@"??????? %@",urlParam);
                // S: 포트 변경 로직 추가하며 server 전역 범위로 이동 (2022.11.09 Jung Mirae)
//                NSString *server = [GlobalData getServerIp];
                // E: 포트 변경 로직 추가하며 server 전역 범위로 이동 (2022.11.09 Jung Mirae)
                NSString *pageUrl = @"/chkWorkService.do#detail";
                NSString *callurl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                NSURL *url=[NSURL URLWithString:callurl];
                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                [requestURL setHTTPMethod:@"POST"];
                [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                //[self.webView loadRequest:requestURL];
                NSLog(@"???????");
                
                NSString *currentURL = [[[self.webView request] URL] absoluteString];
                NSLog(@"???currentURL???%@",currentURL);
                
                if ([currentURL rangeOfString:@"chkWorkService"].location == NSNotFound) {
                    [self.webView loadRequest:requestURL];
                    NSLog(@"string does not contain bla");
                    
                } else {
                    NSString *scriptParameter = [NSString stringWithFormat:
                                                 @"viewDetailIos('%@','%@', '');",
                                                 [resdata valueForKey:@"PAT_LOC_ID"] ,
                                                 [resdata valueForKey:@"sh_PAT_CHECK_DT"]];
                    NSLog(@"scriptString => %@", scriptParameter);
                    
                    [self.webView stringByEvaluatingJavaScriptFromString:scriptParameter];
                    NSLog(@"string does contain bla");
                    
                }
                
                
            }
        });
    });
    //
}

//S: 미화점검 로직 추가(2022.02.03 Hwang Ja Young)
//QR미화점검 로직처리..
-(void) callCleanWork:(NSMutableDictionary * ) param{
    CallServer *res = [CallServer alloc];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        //R 수신
        NSString* str = [res stringWithUrl:@"CLEANWORKTag.do" VAL:param];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            NSLog(@"?? %@",str);
            
            NSArray * authlist = [[GlobalDataManager getgData] auth];
            
            
            NSLog(@" ?? %@ ",(  [authlist containsObject:@"ubis_C661"] ? @"YES" : @"NO"));
            if(![authlist containsObject:@"ubis_C661"]){
                //권한이 없습니다.
                return;
            }
            if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
            {
                NSArray * temparray = [jsonInfo valueForKey:(@"data")];
                NSDictionary *resdata = [temparray objectAtIndex:0];
                
                //mWebView.loadUrl(GlobalData.getServerIp()+"/patrolService.do?LOC_ID="+psdata.getString("PAT_LOC_ID")+"&PAT_CHECK_DT="+psdata.getString("sh_PAT_CHECK_DT")+"#detail");
                //NSLog([resdata valueForKey:@"sh_PAT_CHECK_DT"]);
                NSLog(@"%@", [resdata valueForKey:@"sh_PAT_CHECK_DT"]);
                NSMutableDictionary * tempParam = [[NSMutableDictionary alloc] init];
                [tempParam setValue:[resdata valueForKey:@"sh_PAT_CHECK_DT"] forKey:@"PAT_CHECK_DT"];
                [tempParam setValue:[resdata valueForKey:@"PAT_LOC_ID"] forKey:@"LOC_ID"];
                
                
                
                
                NSString *urlParam=[Commonutil serializeJson:tempParam];
                NSLog(@"??????? %@",urlParam);
                // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//                NSString *server = [GlobalData getServerIp];
//                NSString *server = [GlobalData getServerIp:(port)];
                // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
                NSString *pageUrl = @"/cleanWorkService.do#detail";
                NSString *callurl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                NSURL *url=[NSURL URLWithString:callurl];
                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                [requestURL setHTTPMethod:@"POST"];
                [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                //[self.webView loadRequest:requestURL];
                NSLog(@"???????");
                //
                
                NSString *currentURL = [[[self.webView request] URL] absoluteString];
                NSLog(@"???currentURL???%@",currentURL);
                
                if ([currentURL rangeOfString:@"cleanWorkService"].location == NSNotFound) {
                    [self.webView loadRequest:requestURL];
                    NSLog(@"string does not contain bla");
                    
                } else {
                    NSString *scriptParameter = [NSString stringWithFormat:
                                                 @"viewDetailIos('%@','%@', '');",
                                                 [resdata valueForKey:@"PAT_LOC_ID"] ,
                                                 [resdata valueForKey:@"sh_PAT_CHECK_DT"]];
                    NSLog(@"scriptString => %@", scriptParameter);
                    
                    [self.webView stringByEvaluatingJavaScriptFromString:scriptParameter];
                    NSLog(@"string does contain bla");
                }
            }
        });
    });
}
//E: 미화점검 로직 추가(2022.02.03 Hwang Ja Young)

//S : Gps처리 후 넘겨 받은 코드(2019년 4월 24일 Park Jong Hoon)
- (void)receiveGpsResult:(NSNotification *) noti {
    //bDataCreate = YES;  // 자식뷰컨트롤러로 부터 변경하라는 노티가 왔다면 YES로 변경
    NSString *gpsLogicGb;
    gpsLogicGb = [[noti userInfo] objectForKey:@"JOB_TPY"];
    
    if([gpsLogicGb isEqualToString:@"02"]){
        [ToastAlertView showToastInParentView:self.view withText:@"출근이 정상적으로 등록되었습니다." withDuaration:3.0];
        
        //화면불러오기
        // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//        NSString *server = [GlobalData getServerIp];
//        NSString *server = [GlobalData getServerIp:(port)];
        // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
        NSString *pageUrl = @"/DWFMS";
        NSString *callUrl = @"";
        
        
        
        callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
        
        NSURL *url=[NSURL URLWithString:callUrl];
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        [self.webView loadRequest:requestURL];
    }
    else if([gpsLogicGb isEqualToString:@"03"]){
        [ToastAlertView showToastInParentView:self.view withText:@"퇴근이 정상적으로 등록되었습니다." withDuaration:3.0];
        
        //화면불러오기
        // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//        NSString *server = [GlobalData getServerIp];
//        NSString *server = [GlobalData getServerIp:(port)];
        // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
        NSString *pageUrl = @"/DWFMS";
        NSString *callUrl = @"";
        
        
        
        callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
        
        NSURL *url=[NSURL URLWithString:callUrl];
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        [self.webView loadRequest:requestURL];
    }
    else if([gpsLogicGb isEqualToString:@"99"]){
        [ToastAlertView showToastInParentView:self.view withText:@"UBISMaster 위치정보가 비활성화 되어 있습니다.!!환경설정에서 설정을 변경해 주세요.!!" withDuaration:3.0];
    }
}
//E : Gps처리 후 넘겨 받은 코드(2019년 4월 24일 Park Jong Hoon)

//S : PMS입차처리 시 로직추가(2018년 11월 19일 Park Jong Hoon)
-(void) callPmsIn :(NSMutableDictionary * ) param{
    CallServer *res = [CallServer alloc];
    NSLog(@"%@",res);
    NSLog(@"PJH PMS IN CAR param : %@",param);
    
    
    NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
    
    [sessiondata addEntriesFromDictionary:param];
    
    NSLog(@"??? IN CAR sessiondata ?? %@" ,sessiondata);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        //차량 번호 가져오기
        NSString* str = [res stringWithUrl:@"pmsInputCard.do" VAL:sessiondata];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"PJH PMS IN CAR Start : %@",str);
            
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"PJH PMS IN CAR jsonData : %@",jsonData);
            NSError *error;
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            NSLog(@"PJH PMS IN CAR jsonInfo : %@",jsonInfo);
            
            NSArray * temparray = [jsonInfo valueForKey:(@"data")];
            
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//            NSString *server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            
            NSString* tagDt =  [jsonInfo valueForKey:(@"time")]; //태깅한 시간
            NSString* tagId =  [param valueForKey:(@"TAG_ID")]; //tagId
            NSString* serialNo =  [param valueForKey:(@"SERIAL_NO")]; //SERIAL_NO
            
            //태깅한 인원이 주차관리 반장인지 여부
            if([@"Y"isEqual:[jsonInfo valueForKey:(@"fildYn")]])
            {
                NSLog(@"PJH PMS IN CAR 주차반장 영역입니다!!~~~~~~~~~~~~~~~~~~~~");
                NSLog(@"PJH PMS IN CAR QR정보 TAG시간 : %@", tagDt);
                NSLog(@"PJH PMS IN CAR QR정보 TAG_ID : %@", tagId);
                NSLog(@"PJH PMS IN CAR QR정보 SERIAL_NO : %@", serialNo);
                
                NSMutableDictionary * tempParam = [[NSMutableDictionary alloc] init];
                [tempParam setValue:tagDt forKey:@"TAG_DT"];
                [tempParam setValue:tagId forKey:@"TAG_ID"];
                [tempParam setValue:serialNo forKey:@"SERIAL_NO"];

                NSString *urlParam=[Commonutil serializeJson:tempParam];
                NSLog(@"??????? IN CAR %@",urlParam);

                NSString *pageUrl = @"/setCarGuestInfo.do";
                NSString *callurl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                NSLog(@"??????? IN CAR %@",callurl);
                NSURL *url=[NSURL URLWithString:callurl];
                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                [requestURL setHTTPMethod:@"POST"];
                [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                [requestURL setHTTPShouldHandleCookies:NO];

                requestURL.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                NSString *currentURL = [[[self.webView request] URL] absoluteString];
                NSLog(@"???IN CAR currentURL???%@",currentURL);

                [self.webView loadRequest:requestURL];
                
                [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 입차처리 정보를 입력하세요.." withDuaration:3.0];
            }
            else{
                NSLog(@"PJH PMS IN CAR jsonInfo Count: %@", [NSString stringWithFormat:@"%d",temparray.count]);
                
                NSLog(@"PJH PMS IN CAR 일반인원 영역입니다!!~~~~~~~~~~~~~~~~~~~~");
                //관리 차량이 1개 이상일 경우..
                if(temparray.count > 1){
                    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"[관리차량선택]" message:@"차량을 선택해 주세요.!!" preferredStyle:UIAlertControllerStyleActionSheet];
                   
                    for (int i = 0; i<temparray.count; i++) {
                       NSLog(@"PJH IN CAR PMS temparray %@번째 CARNO : %@", [NSString stringWithFormat:@"%d", (i + 1)], [NSString stringWithFormat:@"%@",temparray[i][@"CAR_NO"]]);
                       
                       NSString* tmpCarNo = temparray[i][@"CAR_NO"]; //자동차 번호 가져오기..
                       
                        //선택 시...
                       UIAlertAction* tmpUIAlert = [UIAlertAction actionWithTitle:tmpCarNo style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                           NSLog(@"PJH PMS IN CAR 선택한 차량 번호 : %@", tmpCarNo);
                           NSLog(@"PJH PMS IN CAR QR정보 TAG시간 : %@", tagDt);
                           NSLog(@"PJH PMS IN CAR QR정보 TAG_ID : %@", tagId);
                           NSLog(@"PJH PMS IN CAR QR정보 SERIAL_NO : %@", serialNo);
                           
                           NSMutableDictionary *requstParam =[[NSMutableDictionary alloc] init];
                           [requstParam setValue:tmpCarNo forKey: @"CAR_NO"];
                           [requstParam setValue:tagDt forKey: @"TAG_DT"];
                           [requstParam setValue:tagId forKey: @"TAG_ID"];
                           [requstParam setValue:serialNo forKey: @"SERIAL_NO"];
                           [requstParam addEntriesFromDictionary:sessiondata];

                           NSLog(@"PJH PMS IN CAR requstParam : %@", requstParam);
                           CallServer *resInCar = [CallServer alloc];
                           NSString* inCarUrl = [resInCar stringWithUrl:@"setInCarCommitInfo.do" VAL:requstParam];
                           
                           NSLog(@"PJH PMS IN CAR inCarUrl : %@", inCarUrl);
                           
                           NSData *requestJsonData = [inCarUrl dataUsingEncoding:NSUTF8StringEncoding];
                           NSLog(@"PJH PMS IN CAR requestJsonData : %@",requestJsonData);
                           NSError *requestError;
                           NSDictionary *requestJsonInfo = [NSJSONSerialization JSONObjectWithData:requestJsonData options:kNilOptions error:&requestError];
                           NSLog(@"PJH PMS IN CAR requestJsonInfo : %@",requestJsonInfo);
                           
                           if([@"s"isEqual:[requestJsonInfo valueForKey:@"rv"] ] )
                           {
                               [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 입차처리 되었습니다.." withDuaration:3.0];
                           }
                           else{
                              [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 입차 중 오류가 발생하였습니다..다시 시도하시기 바랍니다.." withDuaration:3.0];
                           }

                           NSString *pageUrl = @"/DWFMS";
                           NSString *callUrl = @"";
               
                           callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
               
                           NSURL *url=[NSURL URLWithString:callUrl];
                           NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                           [self.webView loadRequest:requestURL];
                           
                       }];

                       [view addAction:tmpUIAlert];
                    }
                   
                    //취소버튼 클릭
                    UIAlertAction *CANCEL = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                       [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 입차처리를 취소하였습니다.." withDuaration:3.0];
                    }];

                    [view addAction:CANCEL];
                    [self presentViewController:view animated:YES completion:nil];
                }
                //관리차량이 1개일 경우..
               else{
                   NSArray * temparray = [jsonInfo valueForKey:(@"data")];
                   NSString* tmpCarNo = temparray[0][@"CAR_NO"]; //자동차 번호 가져오기..
                   
                   NSLog(@"PJH PMS IN CAR 선택한 차량 번호 : %@", tmpCarNo);
                   NSLog(@"PJH PMS IN CAR QR정보 TAG시간 : %@", tagDt);
                   NSLog(@"PJH PMS IN CAR QR정보 TAG_ID : %@", tagId);
                   NSLog(@"PJH PMS IN CAR QR정보 SERIAL_NO : %@", serialNo);
                   
                   NSMutableDictionary *requstParam =[[NSMutableDictionary alloc] init];
                   [requstParam setValue:tmpCarNo forKey: @"CAR_NO"];
                   [requstParam setValue:tagDt forKey: @"TAG_DT"];
                   [requstParam setValue:tagId forKey: @"TAG_ID"];
                   [requstParam setValue:serialNo forKey: @"SERIAL_NO"];
                   [requstParam addEntriesFromDictionary:sessiondata];
                   
                   NSLog(@"PJH PMS IN CAR requstParam : %@", requstParam);
                   CallServer *resInCar = [CallServer alloc];
                   NSString* inCarUrl = [resInCar stringWithUrl:@"setInCarCommitInfo.do" VAL:requstParam];
                   
                   NSLog(@"PJH PMS IN CAR inCarUrl : %@", inCarUrl);
                   
                   NSData *requestJsonData = [inCarUrl dataUsingEncoding:NSUTF8StringEncoding];
                   NSLog(@"PJH PMS IN CAR requestJsonData : %@",requestJsonData);
                   NSError *requestError;
                   NSDictionary *requestJsonInfo = [NSJSONSerialization JSONObjectWithData:requestJsonData options:kNilOptions error:&requestError];
                   NSLog(@"PJH PMS IN CAR requestJsonInfo : %@",requestJsonInfo);
                   
                   if([@"s"isEqual:[requestJsonInfo valueForKey:@"rv"] ] )
                   {
                       [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 입차처리 되었습니다.." withDuaration:3.0];
                   }
                   else{
                       [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 입차 중 오류가 발생하였습니다..다시 시도하시기 바랍니다.." withDuaration:3.0];
                   }
                   
                   NSString *pageUrl = @"/DWFMS";
                   NSString *callUrl = @"";
                   
                   callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
                   
                   NSURL *url=[NSURL URLWithString:callUrl];
                   NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                   [self.webView loadRequest:requestURL];
               }
            }
        });
    });
}
//E : PMS입차처리 시 로직추가(2018년 11월 19일 Park Jong Hoon)

//S : PMS출차처리 시 로직추가(2018년 11월 20일 Park Jong Hoon)
-(void) callPmsOut :(NSMutableDictionary * ) param{
    CallServer *res = [CallServer alloc];
    NSLog(@"%@",res);
    NSLog(@"PJH PMS OUT CAR param : %@",param);
    
    
    NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
    
    [sessiondata addEntriesFromDictionary:param];
    
    NSLog(@"??? OUT CARsessiondata ?? %@" ,sessiondata);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        //차량 번호 가져오기
        NSString* str = [res stringWithUrl:@"pmsOutCard.do" VAL:sessiondata];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"PJH PMS OUT CAR Start : %@",str);
            
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"PJH PMS OUT CAR jsonData : %@",jsonData);
            NSError *error;
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            NSLog(@"PJH PMS OUT CAR sonInfo : %@",jsonInfo);
            
            NSArray * temparray = [jsonInfo valueForKey:(@"data")];
            
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//            NSString *server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            
            NSString* tagDt =  [jsonInfo valueForKey:(@"time")]; //태깅한 시간
            NSString* tagId =  [param valueForKey:(@"TAG_ID")]; //tagId
            NSString* serialNo =  [param valueForKey:(@"SERIAL_NO")]; //SERIAL_NO
            
            //태깅한 인원이 주차관리 반장인지 여부
            if([@"Y"isEqual:[jsonInfo valueForKey:(@"fildYn")]])
            {
                NSLog(@"PJH PMS OUT CAR 주차반장 영역입니다!!~~~~~~~~~~~~~~~~~~~~");
                NSLog(@"PJH PMS OUT CAR QR정보 TAG시간 : %@", tagDt);
                NSLog(@"PJH PMS OUT CAR QR정보 TAG_ID : %@", tagId);
                NSLog(@"PJH PMS OUT CAR QR정보 SERIAL_NO : %@", serialNo);
                
                NSMutableDictionary * tempParam = [[NSMutableDictionary alloc] init];
                [tempParam setValue:tagDt forKey:@"TAG_DT"];
                [tempParam setValue:tagId forKey:@"TAG_ID"];
                [tempParam setValue:serialNo forKey:@"SERIAL_NO"];
                
                NSString *urlParam=[Commonutil serializeJson:tempParam];
                NSLog(@"??????? OUT CAR %@",urlParam);
                
                NSString *pageUrl = @"/setCarGuestInfo.do";
                NSString *callurl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                NSLog(@"???????OUT CAR %@",callurl);
                NSURL *url=[NSURL URLWithString:callurl];
                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                [requestURL setHTTPMethod:@"POST"];
                [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                [requestURL setHTTPShouldHandleCookies:NO];
                
                requestURL.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                NSString *currentURL = [[[self.webView request] URL] absoluteString];
                NSLog(@"???OUT CAR currentURL???%@",currentURL);
                
                [self.webView loadRequest:requestURL];
                
                [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 입차처리 정보를 입력하세요.." withDuaration:3.0];
            }
            else{
                NSLog(@"PJH PMS OUT CAR jsonInfo Count: %@", [NSString stringWithFormat:@"%d",temparray.count]);
                
                NSLog(@"PJH PMS OUT CAR 일반인원 영역입니다!!~~~~~~~~~~~~~~~~~~~~");
                //관리 차량이 1개 이상일 경우..
                if(temparray.count > 1){
                    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"[관리차량선택]" message:@"차량을 선택해 주세요.!!" preferredStyle:UIAlertControllerStyleActionSheet];
                    
                    for (int i = 0; i<temparray.count; i++) {
                        NSLog(@"PJH PMS OUT CAR temparray %@번째 CARNO : %@", [NSString stringWithFormat:@"%d", (i + 1)], [NSString stringWithFormat:@"%@",temparray[i][@"CAR_NO"]]);
                        
                        NSString* tmpCarNo = temparray[i][@"CAR_NO"]; //자동차 번호 가져오기..
                        
                        //선택 시...
                        UIAlertAction* tmpUIAlert = [UIAlertAction actionWithTitle:tmpCarNo style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                            NSLog(@"PJH PMS OUT CAR 선택한 차량 번호 : %@", tmpCarNo);
                            NSLog(@"PJH PMS OUT CAR QR정보 TAG시간 : %@", tagDt);
                            NSLog(@"PJH PMS OUT CAR QR정보 TAG_ID : %@", tagId);
                            NSLog(@"PJH PMS OUT CAR QR정보 SERIAL_NO : %@", serialNo);
                            // 비교 여기까지
                            NSMutableDictionary *requstParam =[[NSMutableDictionary alloc] init];
                            [requstParam setValue:tmpCarNo forKey: @"CAR_NO"];
                            [requstParam setValue:tagDt forKey: @"TAG_DT"];
                            [requstParam setValue:tagId forKey: @"TAG_ID"];
                            [requstParam setValue:serialNo forKey: @"SERIAL_NO"];
                            [requstParam addEntriesFromDictionary:sessiondata];
                            
                            NSLog(@"PJH PMS OUT CAR requstParam : %@", requstParam);
                            CallServer *resOutCar = [CallServer alloc];
                            NSString* outCarUrl = [resOutCar stringWithUrl:@"setOutCarCommitInfo.do" VAL:requstParam];
                            
                            NSLog(@"PJH PMS OUT CAR outCarUrl : %@", outCarUrl);
                            
                            NSData *requestJsonData = [outCarUrl dataUsingEncoding:NSUTF8StringEncoding];
                            NSLog(@"PJH PMS OUT CAR requestJsonData : %@",requestJsonData);
                            NSError *requestError;
                            NSDictionary *requestJsonInfo = [NSJSONSerialization JSONObjectWithData:requestJsonData options:kNilOptions error:&requestError];
                            NSLog(@"PJH PMS OUT CAR requestJsonInfo : %@",requestJsonInfo);
                            
                            if([@"s"isEqual:[requestJsonInfo valueForKey:@"rv"] ] )
                            {
                                [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 출차처리 되었습니다.." withDuaration:3.0];
                            }
                            else{
                                [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 출차 중 오류가 발생하였습니다..다시 시도하시기 바랍니다.." withDuaration:3.0];
                            }
                            
                            NSString *pageUrl = @"/DWFMS";
                            NSString *callUrl = @"";
                            
                            callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
                            
                            NSURL *url=[NSURL URLWithString:callUrl];
                            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                            [self.webView loadRequest:requestURL];
                            
                        }];
                        
                        [view addAction:tmpUIAlert];
                    }
                    
                    //취소버튼 클릭
                    UIAlertAction *CANCEL = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 출차처리를 취소하였습니다.." withDuaration:3.0];
                    }];
                    
                    [view addAction:CANCEL];
                    [self presentViewController:view animated:YES completion:nil];
                }
                //관리차량이 1개일 경우..
                else{
                    NSArray * temparray = [jsonInfo valueForKey:(@"data")];
                    NSString* tmpCarNo = temparray[0][@"CAR_NO"]; //자동차 번호 가져오기..
                    
                    NSLog(@"PJH PMS OUT CAR 선택한 차량 번호 : %@", tmpCarNo);
                    NSLog(@"PJH PMS OUT CAR QR정보 TAG시간 : %@", tagDt);
                    NSLog(@"PJH PMS OUT CAR QR정보 TAG_ID : %@", tagId);
                    NSLog(@"PJH PMS OUT CAR QR정보 SERIAL_NO : %@", serialNo);
                    
                    NSMutableDictionary *requstParam =[[NSMutableDictionary alloc] init];
                    [requstParam setValue:tmpCarNo forKey: @"CAR_NO"];
                    [requstParam setValue:tagDt forKey: @"TAG_DT"];
                    [requstParam setValue:tagId forKey: @"TAG_ID"];
                    [requstParam setValue:serialNo forKey: @"SERIAL_NO"];
                    [requstParam addEntriesFromDictionary:sessiondata];
                    
                    NSLog(@"PJH PMS OUT CAR requstParam : %@", requstParam);
                    CallServer *resOutCar = [CallServer alloc];
                    NSString* outCarUrl = [resOutCar stringWithUrl:@"setOutCarCommitInfo.do" VAL:requstParam];
                    
                    NSLog(@"PJH PMS OUT CAR outCarUrl : %@", outCarUrl);
                    
                    NSData *requestJsonData = [outCarUrl dataUsingEncoding:NSUTF8StringEncoding];
                    NSLog(@"PJH PMS OUT CAR requestJsonData : %@",requestJsonData);
                    NSError *requestError;
                    NSDictionary *requestJsonInfo = [NSJSONSerialization JSONObjectWithData:requestJsonData options:kNilOptions error:&requestError];
                    NSLog(@"PJH PMS OUT CAR requestJsonInfo : %@",requestJsonInfo);
                    
                    if([@"s"isEqual:[requestJsonInfo valueForKey:@"rv"] ] )
                    {
                        [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 출차처리 되었습니다.." withDuaration:3.0];
                    }
                    else{
                        [ToastAlertView showToastInParentView:self.view withText:@"주차관리시스템 출차 중 오류가 발생하였습니다..다시 시도하시기 바랍니다.." withDuaration:3.0];
                    }
                    
                    NSString *pageUrl = @"/DWFMS";
                    NSString *callUrl = @"";
                    
                    callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
                    
                    NSURL *url=[NSURL URLWithString:callUrl];
                    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                    [self.webView loadRequest:requestURL];
                }
            }
        });
    });
}
//E : PMS출차처리 시 로직추가(2018년 11월 20일 Park Jong Hoon)

-(void) callWelcome{
    NSError *error;
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    if([@"" isEqualToString:[[GlobalDataManager getgData] inTime]])
    {
        [param setObject:@"-" forKey:@"INTIME"];
    }else{
        
        [param setObject:[[GlobalDataManager getgData] inTime]  forKey:@"INTIME"];
    }
    
    if([@"" isEqualToString:[[GlobalDataManager getgData] outTime]])
    {
        [param setObject:@"-" forKey:@"OUTTIME"];
    }else{
        [param setObject:[[GlobalDataManager getgData] outTime]  forKey:@"OUTTIME"];
    }
    
    //S : 점심시작/종료 시간 추가(2022년 4월 29일 Park Jong Hoon)
    if([@"" isEqualToString:[[GlobalDataManager getgData] lunchInTime]])
    {
        [param setObject:@"-" forKey:@"LUNCHINTIME"];
    }else{
        
        [param setObject:[[GlobalDataManager getgData] lunchInTime]  forKey:@"LUNCHINTIME"];
    }
    
    if([@"" isEqualToString:[[GlobalDataManager getgData] lunchOutTime]])
    {
        [param setObject:@"-" forKey:@"LUNCHOUTTIME"];
    }else{
        [param setObject:[[GlobalDataManager getgData] lunchOutTime]  forKey:@"LUNCHOUTTIME"];
    }
    //E : 점심시작/종료 시간 추가(2022년 4월 29일 Park Jong Hoon)
    
    
    [param setObject:[[GlobalDataManager getgData] empNm] forKey:@"EMPNM"];
    
    
    //     NSString *jsonInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"saltfactory",@"name",@"saltfactory@gmail.com",@"e-mail", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (error) {
        NSLog(@"error : %@", error.localizedDescription);
        return;
    }
    
    NSString* searchWord = @"\"";
    NSString* replaceWord = @"";
    //   jsonString =  [jsonString stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    
    
    
    jsonString =  [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"jsonString => %@", jsonString);
    
    NSString *escaped = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"escaped string :\n%@", escaped);
    
    searchWord = @"%20";
    replaceWord = @"";
    escaped =  [escaped stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    searchWord = @"%0A";
    replaceWord = @"";
    escaped =  [escaped stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    
    
    NSString *decoded = [escaped stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"decoded string :\n%@", decoded);
    
    NSString *scriptString = [NSString stringWithFormat:@"welcome(%@);",decoded];
    NSLog(@"scriptString => %@", scriptString);
    [self.webView stringByEvaluatingJavaScriptFromString:scriptString];
}

-(void) logout{
    viewType = @"LOGOUT";
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    NSString *fcmToken = ((AppDelegate*)[UIApplication sharedApplication].delegate).fcmID; // FCM 토큰 가져오기(2022.11.11

//    NSString *server = [GlobalData getServerIp];
    NSString *pageUrl = @"/DWFMS";
    NSString *callUrl = @"";
    
    // S: GCM_ID 값 변경 (2022.11.10 Jung Mirae)
    //NSString * urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I",idForVendor,@"22222222"];
    NSString * urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I",idForVendor,fcmToken];
    
    
    
    
    callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
    
    NSURL *url=[NSURL URLWithString:callUrl];
    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
    [requestURL setHTTPMethod:@"POST"];
    [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
    [self.webView loadRequest:requestURL];
    
}
-(void)callbackwelcome{
    NSLog(@"callbackwelcome  %@: okkkk", viewType);
    
    
    if(!chkPort) {
        // callBackWelcomePort = 8047 이어야
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        // 가져온 port 번호를 user defaults portStored 라는 키값에 할당 (2022.11.14 Jung Mirae)
        [userDefaults setObject: callBackWelcomePort forKey:@"portStored"];
        
        // 저장된 포트값 확인 (DB에서 가져온 포트값이어야 함)
        NSLog(@"키 값 portStored 에 저장된 user defaults 값 =====>  %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"portStored"]);
        
        chkPort = [[NSUserDefaults standardUserDefaults] stringForKey:@"portStored"];
        
        server = [GlobalData getServerIp];
        NSString *pageUrl = @"/DWFMS";
        NSString *callUrl = @"";
        
        callUrl = [NSString stringWithFormat:@"%@%@#home", server, pageUrl];
        
        NSLog(@"callUrl ====== %@", callUrl);
        
        NSURL *url = [NSURL URLWithString:callUrl];
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        
        [self.webView loadRequest:requestURL];
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        
        CallServer *res = [CallServer alloc];
        UIDevice *device = [UIDevice currentDevice];
        NSString *idForVendor = [device.identifierForVendor UUIDString];
        server = [GlobalData getServerIp];
        
        NSLog(@"서버 맨 처음 ====> %@", server);
        NSString *fcmToken = ((AppDelegate*)[UIApplication sharedApplication].delegate).fcmID; // FCM 토큰 가져오기(2022.11.11 Jung Mirae)
        //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
        NSInteger *iosVer = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
        // S: VERSION_NM 추가하기 위해 앱 버전 정보 가져오기 (2022.11.09 Jung Mirae)
        infoDict = [[NSBundle mainBundle] infoDictionary];
        appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // 1.1.1
        NSLog(@"앱 버전 확인하기 ==== %@", appVersion);
        //NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; //2
        //NSLog(@"앱 빌드 넘버 확인하기 ==== %@", buildNumber);
        // E: VERSION_NM 추가하기 위해 앱 버전 정보 가져오기 (2022.11.09 Jung Mirae)
        
        
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *iosModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
        
        NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
        
        [param setValue: idForVendor forKey:@"HP_TEL"];
        //[param setValue:@"ffffffff" forKey:@"GCM_ID"]; 원소스
        [param setValue: fcmToken forKey:@"GCM_ID"]; // Mirae 변경
        
        NSLog(@"server 값 확인 ===> %@", server);
        NSLog(@"GCM_ID 값 확인 ===> %@", fcmToken);
        
        [param setObject:@"I" forKey:@"DEVICE_FLAG"];
        [param setObject: appVersion forKey:@"VERSION_NM"]; // VERSION_NM 추가 (2022.11.09 Jung Mirae)
        //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
        [param setObject: [NSString stringWithFormat:@"%d",iosVer] forKey:@"BUILD_SDK"];
        [param setObject: iosModel forKey:@"PACKAGE_ID"];
        //E : iOS 정보추출 로그인 추가 (2019년 11월 27일 Park Jong Hoon)
        
        // S : 화면 확대/축소 추가(2018년 3월 20일 Park Jong Hoon)
        [self.webView setScalesPageToFit:YES];
        // E : 화면 확대/축소 추가(2018년 3월 20일 Park Jong Hoon)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            //R 수신
            NSLog(@"타는지 확인 - VC 위쪽1 param ==> %@", param); // 탐. loginByPhon 여기만 탐
            
            NSString* str = [res stringWithUrl:@"loginByPhon.do" VAL: param];
            
            NSLog(@"타는지 확인 - VC 위쪽2"); // 탐. loginByPhon 여기만 탐
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                //NSLog(str);
                NSLog(@"%@", str);
                
                chkPort = [[NSUserDefaults standardUserDefaults] stringForKey:@"portStored"];
                
                NSString *urlParam=@"";
                //NSString *server = [GlobalData getServerIp]; // 원코드
                server = [GlobalData getServerIp]; // server를 전역으로 뺌
                NSString *pageUrl = @"/DWFMS";
                NSString *callUrl = @"";
                
                /*
                 자동로그인 부분
                 */
                if([@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
                {
                    if([@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
                    {
                        NSDictionary *data = [jsonInfo valueForKey:(@"data")];
                        [GlobalDataManager initgData:(data)];
                        NSArray * timelist = [jsonInfo objectForKey:@"inout"];
                        [GlobalDataManager setTime:[timelist objectAtIndex:0]];
                        NSArray * authlist = [jsonInfo objectForKey:@"auth"];
                        [GlobalDataManager initAuth:authlist];
                        
                        beaconYN = [data valueForKey:@"BEACON_YN"];
                        NSMutableDictionary * session =[GlobalDataManager getAllData];
                        
                        // 전역 변수 portStored 에 가져온 port 값 할당 (2022.11.14 Jung Mirae)
                        portStored = [data valueForKey:@"PORT"];
                        NSLog(@"VC 위쪽에서 할당한 포트 번호 ==> %@", portStored);
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:portStored forKey:@"portStored"];
                        
                        // S: 비콘 추가 (2022.07.21 Jung Mirae)
                        [session setValue:[[GlobalDataManager getgData] beaconYn] forKey: beaconYN];
                        // E: 비콘 추가(2022.07.21 Jung Mirae)
                        
                        [session setValue:[GlobalDataManager getAuth] forKey:@"auth"];
                        [session setValue:[[GlobalDataManager getgData] inTime]  forKey:@"inTime"];
                        [session setValue:[[GlobalDataManager getgData] outTime]  forKey:@"outTime"];
                        
                        //S : 점심시작/종료 시간 추가(2022년 4월 29일 Park Jong Hoon)
                        [session setValue:[[GlobalDataManager getgData] lunchInTime]  forKey:@"lunchInTime"];
                        [session setValue:[[GlobalDataManager getgData] lunchOutTime]  forKey:@"lunchOutTime"];
                        //E : 점심시작/종료 시간 추가(2022년 4월 29일 Park Jong Hoon)
                        
                        urlParam = [Commonutil serializeJson:session];
                        
                        NSString * text =@"본 어플리케이션은 원할한 서비스를\n제공하기 위해 휴대전화번호등의 개인정보를 사용합니다.\n[개인정보보호법]에 의거해 개인정보 사용에 대한 \n사용자의 동의를 필요로 합니다.\n개인정보 사용에 동의하시겠습니까?\n";
                        NSLog(@"urlParam %@",urlParam);
                        callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
                        
                        
                        if(![@"Y" isEqualToString:[data valueForKey:@"INFO_YN"]])
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                            message:text delegate:self
                                                                  cancelButtonTitle:@"취소"
                                                                  otherButtonTitles:@"동의", nil];
                            [alert show];
                        }
                        
                        viewType = @"LOGIN";
                        //_uuidList = [GlobalData sharedDefaults].supportedUUIDs;
                        
                        if(![@"N" isEqualToString:[data valueForKey:@"BEACON_YN"]]){    //2017년 10월 27일 Park Jong Hoon 비콘일 경우 만 아래 로직 타게...
                            _uuidList = @[
                                [[NSUUID alloc] initWithUUIDString:[data valueForKey:@"BEACON_UUID"]]
                                //24DDF411-8CF1-440C-87CD-E368DAF9C93E
                                //you can add other NSUUID instance here.
                                //COM000 - BEACON_UUID 컬럼이 비어있고 BEACON_YN 이 Y이면 에러납니다..
                            ];
                            
                            //2017년 2월 27일 Choi Yu Bin 추가
                            [_uuidList enumerateObjectsUsingBlock:^(NSUUID *uuid, NSUInteger idx, BOOL *stop) {
                                NSString *identifier = @"us.iBeaconModules";
                                
                                [self registerBeaconRegionWithUUID:uuid andIdentifier:identifier];
                            }];
                            NSLog(@"일단 여기 걸리나?? Authorized when in use");
                            
                            //2017년 2월 27일 Choi Yu Bin 추가
                            switch ([CLLocationManager authorizationStatus]) {
                                case kCLAuthorizationStatusAuthorizedAlways:
                                    NSLog(@"Authorized Always");
                                    break;
                                case kCLAuthorizationStatusAuthorizedWhenInUse:
                                    NSLog(@"Authorized when in use");
                                    break;
                                case kCLAuthorizationStatusDenied:
                                    NSLog(@"Denied");
                                    break;
                                case kCLAuthorizationStatusNotDetermined:
                                    NSLog(@"Not determined");
                                    break;
                                case kCLAuthorizationStatusRestricted:
                                    NSLog(@"Restricted");
                                    break;
                                    
                                default:
                                    break;
                            }
                            self.locationManager = [[CLLocationManager alloc] init];
                            //            if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                            //                [self.locationManager requestAlwaysAuthorization];
                            //            }
                            //2017년 04월 03일 Choi Yu Bin 추가 - 위치서비스 항상허용 제외, 앱을 사용하는 동안만 사용 하도록 설정
                            if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                                [self.locationManager requestWhenInUseAuthorization];
                            }
                            self.locationManager.distanceFilter = YES;
                            
                            self.locationManager.delegate = self;
                            self.locationManager.pausesLocationUpdatesAutomatically = YES;//pause상태에서의 스캔여부
                            [self.locationManager startMonitoringForRegion:beaconRegion];
                            [self.locationManager startRangingBeaconsInRegion:beaconRegion];
                            [self.locationManager startUpdatingLocation];
                        }//2017년 10월 27일 Park Jong Hoon 비콘일 경우 만 아래 로직 타게...
                    }
                    else{
                        //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
                        
                        //S: 주석처리 후 VERSION_NM / GCM_ID 값으로 [[GlobalDataManager getgData] gcmId] 추가(2022.11.09 Jung Mirae)
                        //urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I&BUILD_SDK=%@&PACKAGE_ID=%@",idForVendor,@"22222222", [NSString stringWithFormat:@"%d",iosVer], iosModel];
                        
                        urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I&BUILD_SDK=%@&PACKAGE_ID=%@&VERSION_NM=%@",idForVendor,fcmToken, [NSString stringWithFormat:@"%d",iosVer], iosModel, appVersion];
                        //E: VERSION_NM 추가(2022.11.09 Jung Mirae)
                        
                        //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
                        callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                    }
                }
                
                NSLog(@"??callurl:%@",callUrl);
                
                //2018년 1월 2일 Park Jong Hoon 네트워크 끊겼을 시 이벤트 버튼 추가
                if(callUrl == @"")
                {
                    NSLog(@"PJH~~~ %@", @"통신불가");
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"네트워크 오류"
                                                                   message:@"통신상태 연결에 이상이 있습니다..!!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"닫기"    /* nil 로 지정할 경우 cancel button 없음 */
                                                         otherButtonTitles: nil];
                    
                    // alert창을 띄우는 method는 show이다.
                    alert.tag=190;
                    [alert show];
                    return;
                }
                else{
                    NSLog(@"PJH~~~ %@", @"통신가능");
                    NSURL *url=[NSURL URLWithString:callUrl];
                    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                    [requestURL setHTTPMethod:@"POST"];
                    [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                    [self.webView loadRequest:requestURL];
                    NSLog(@"??????? urlParam %@",urlParam);
                }
            });
        });
        
    }
    
    
    
    
    // S: 포트 변경 로직 작성 (2022.11.14 Jung Mirae)
    // if user defaults에 저장된 포트 값이 없다면...
//    if(![[NSUserDefaults standardUserDefaults] stringForKey:@"portStored"]) {
//        NSLog(@"callbackwelcome NSUserDefaults에 값이 없을 때 %@", portStored);
//
//        // 기존 포트(8045)와 가져온 포트(8047)이 다르다면
//        if(port != portStored) {
//            NSLog(@"callbackwelcome if - if (DB에서 가져온 포트값) ===> %@", portStored);
//            // NSUserDefaults 사용하기 위해 생성 (2022.11.14 Jung Mirae)
//            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//            // 가져온 port 번호를 user defaults portStored 라는 키값에 할당 (2022.11.14 Jung Mirae)
//            [userDefaults setObject:portStored forKey:@"portStored"];
//        }
//    }
    // E: 포트 변경 로직 작성 (2022.11.14 Jung Mirae)
    
    
    
    if([viewType isEqual:@"LOGOUT"]){
       return;
    }
    NSLog(@"callbackwelcome  : okkkk");
    //CallServer *res = [CallServer alloc];
    NSLog(@"callbackwelcome  : 2222");
    //UIDevice *device = [UIDevice currentDevice];
    //NSString* idForVendor = [device.identifierForVendor UUIDString];
    //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    //NSInteger *iosVer = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    //struct utsname systemInfo;
    //uname(&systemInfo);
    //NSString *iosModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    //NSString *fcmToken = ((AppDelegate*)[UIApplication sharedApplication].delegate).fcmID; // FCM 토큰 가져오기(2022.11.11

    
    //NSMutableDictionary* param = [[NSMutableDictionary alloc] init];

    // S : 잠시 주석처리 (원래 callbackwelcome안에 작성되어 있는 소스) (2022.11.15 Jung Mirae)
//    [param setValue:idForVendor forKey:@"HP_TEL"];
//    //[param setValue:@"ffffffff" forKey:@"GCM_ID"]; // 원소스
//    [param setValue: fcmToken forKey:@"GCM_ID"]; // 위 소스 변경 Mirae
//    [param setObject:@"I" forKey:@"DEVICE_FLAG"];
//    //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
//    [param setObject: [NSString stringWithFormat:@"%d",iosVer] forKey:@"BUILD_SDK"];
//    [param setObject: iosModel forKey:@"PACKAGE_ID"];
//    //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
//
//    // S: VERSION_NM 추가 (2022.11.09 Jung Mirae)
//    [param setObject: appVersion forKey:@"VERSION_NM"];
//    // E: VERSION_NM 추가 (2022.11.09 Jung Mirae)
//
//    //deviceId
//    NSLog(@"callbackwelcome  : 3333");
//    //R 수신
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
//        //R 수신
//        NSString* str = [res stringWithUrl:@"loginByPhon.do" VAL:param];
//
//        NSLog(@"타는지 확인 - ViewController %@");
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
//            NSError *error;
//            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
//            //NSLog(str);
//            NSLog(@"%@", str);
//
//
//            if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
//            {
//                if(     [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
//                {
//
//                    NSString * oldempon = [[GlobalDataManager getgData]empNo];
//                    NSDictionary *data = [jsonInfo valueForKey:(@"data")];
//                    [GlobalDataManager initgData:(data)];
//                    NSArray * timelist = [jsonInfo objectForKey:@"inout"];
//                    [GlobalDataManager setTime:[timelist objectAtIndex:0]];
//                    NSArray * authlist = [jsonInfo objectForKey:@"auth"];
//                    [GlobalDataManager initAuth:authlist];
//                    beaconYN = [data valueForKey:@"BEACON_YN"];
//
//                    if(![oldempon isEqual:[[GlobalDataManager getgData] empNo] ]){
//                        [self logout];
//                    }
//                    else{
//                        NSLog(@"타는지 확인 - callWelcome전 %@");
//                        [self callWelcome];
//                    }
//
//
//
//
//                }
//                else{
//                    [ToastAlertView showToastInParentView:self.view withText:@"다른폰에서 로그인 되었습니다.." withDuaration:3.0];
//                    [self logout];
//                }
//            }
//        });
//    });
    // S : 잠시 주석처리 (원래 callbackwelcome안에 작성되어 있는 소스) (2022.11.15 Jung Mirae)
}


- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID andIdentifier:(NSString*)identifier {
    //RECOBeaconRegion *recoRegion = [[RECOBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:identifier]; //2017년 2월 27일 Choi Yu Bin 주석처리
    
    //_rangedRegions[recoRegion] = [NSArray array];//2017년 2월 27일 Choi Yu Bin 주석처리
    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:identifier];//2017년 2월 27일 Choi Yu Bin 추가
}
//- (void) startRanging {
//    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~StartRanging~~~~~");
//    if (![RECOBeaconManager isRangingAvailable]) {
//        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~return : not not not not isRangingAvailable");
//        return;
//    }
//    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~");
//    [_rangedRegions enumerateKeysAndObjectsUsingBlock:^(RECOBeaconRegion *recoRegion, NSArray *beacons, BOOL *stop) {
//        [_recoManager startRangingBeaconsInRegion:recoRegion];
//    }];
//}

//- (void) stopRanging; {
//    [_rangedRegions enumerateKeysAndObjectsUsingBlock:^(RECOBeaconRegion *recoRegion, NSArray *beacons, BOOL *stop) {
//        [_recoManager stopRangingBeaconsInRegion:recoRegion];
//    }];
//}

//#pragma mark - RECOBeaconManager delegate methods

/*****2017년 2월 27일 Choi Yu Bin 주석시작
 - (void)recoManager:(RECOBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(RECOBeaconRegion *)region {
 NSLog(@"didRangeBeaconsInRegion: %@, ranged %lu beacons", region.identifier, (unsigned long)[beacons count]);
 
 if((unsigned long)[beacons count] > 0){
 [GlobalData setbeacon:@"T"];
 }
 
 _rangedRegions[region] = beacons;
 [_rangedBeacon removeAllObjects];
 
 NSMutableArray *allBeacons = [NSMutableArray array];
 
 NSArray *arrayOfBeaconsInRange = [_rangedRegions allValues];
 [arrayOfBeaconsInRange enumerateObjectsUsingBlock:^(NSArray *beaconsInRange, NSUInteger idx, BOOL *stop){
 [allBeacons addObjectsFromArray:beaconsInRange];
 }];
 
 [_stateCategory enumerateObjectsUsingBlock:^(NSNumber *range, NSUInteger idx, BOOL *stop){
 NSArray *beaconsInRange = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
 
 if ([beaconsInRange count]) {
 _rangedBeacon[range] = beaconsInRange;
 }
 }];
 //[self.tableView reloadData];
 }
 
 - (void)recoManager:(RECOBeaconManager *)manager rangingDidFailForRegion:(RECOBeaconRegion *)region withError:(NSError *)error {
 NSLog(@"rangingDidFailForRegion: %@ error: %@", region.identifier, [error localizedDescription]);
 [GlobalData setbeacon:@"F"];
 }
 2017년 2월 27일 Choi Yu Bin 주석시작**************/


/*****2017년 2월 27일 Choi Yu Bin 추가시작******/
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self.locationManager startUpdatingLocation];
    
    NSLog(@"You entered the region.");
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [manager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self.locationManager stopUpdatingLocation];
    
    NSLog(@"You exited the region.");
}

- (void)locationManager:(CLLocationManager *)manager rangingDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"rangingDidFailForRegion: %@ error: %@", region.identifier, [error localizedDescription]);
    [GlobalData setbeacon:@"F"];
}
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSString *message = @"";
    
    NSLog(@"bluetoothYN : %@", bluetoothYN);
    
    if([@"Y" isEqual:bluetoothYN]){
        self.beacons = beacons;
        [self beaconSet];
        
        
        
        if(beacons.count > 0) {
            [GlobalData setbeacon:@"T"];
            message = @"~~~~~~Yes beacons are nearby";
            //S : 비콘 스캔에 따른 로직 분개처리(2022년 6월 20일 Park Jong Hoon)
            if(!_qrView.hidden){ //네이티브에서 스캔할때
                NSLog(@"%@", @"네이티브");
            }
            else{ //웹뷰로 보낼 때
                NSLog(@"%@", @"메인화면");
                [self.webView stringByEvaluatingJavaScriptFromString:@"beaconConnectView('Y')"]; //메인화면일 때 / 초록색
            }
            //E : 비콘 스캔에 따른 로직 분개처리(2022년 6월 20일 Park Jong Hoon)
        } else {
            [GlobalData setbeacon:@"F"];
            message = @"~~~~~~No beacons are nearby";
            
            //S : 비콘 스캔에 따른 로직 분개처리(2022년 6월 20일 Park Jong Hoon)
            if(!_qrView.hidden){ //네이티브에서 스캔할때
                NSLog(@"%@", @"네이티브");
            }
            else{ //웹뷰로 보낼 때
                NSLog(@"%@", @"메인화면");
                [self.webView stringByEvaluatingJavaScriptFromString:@"beaconConnectView('N')"]; //메인화면일 때 / 초록색
            }
            //E : 비콘 스캔에 따른 로직 분개처리(2022년 6월 20일 Park Jong Hoon)
        }
    }
    else{
        NSLog(@"%@", @"메인화면");
        [self.webView stringByEvaluatingJavaScriptFromString:@"beaconConnectView('N')"]; //메인화면일 때 / 초록색
    }
    
    NSLog(@"%@", message);
}


- (void) beaconSet {
    
    if (beaconSkeepCount < beaconSkeepMaxCount) {
        
        beaconSkeepCount = beaconSkeepCount + 1;
        NSLog(@"Beacon Access Skeep ~~~~~~~~~~~~~~~~~~~~ [%d]", beaconSkeepCount);
        return;
    }
    beaconSkeepCount = 0;
    
    NSLog(@"beacon set ~!~~~~~~~~~");
    beaconDistanceList = [NSMutableArray array];
    beaconList = [NSMutableArray array];
    beaconBatteryLevelList = [NSMutableArray array];
    
    for (int i = 0 ; i < self.beacons.count ; i++) {
        CLBeacon *beacon = (CLBeacon*)[self.beacons  objectAtIndex:i];
        //CLBeacon *beacon = self.beacons.firstObject;
        NSString *proximityLabel = @"";
        
        switch (beacon.proximity) {
            case CLProximityFar:
                proximityLabel = @"Far";
                break;
            case CLProximityNear:
                proximityLabel = @"Near";
                break;
            case CLProximityImmediate:
                proximityLabel = @"Immediate";
                break;
            case CLProximityUnknown:
                proximityLabel = @"Unknown";
                break;
        }
        
        NSLog(@"proximityLabel[%lu] : %@", (unsigned long)i, proximityLabel);
        
        //NSString *detailLabel = [NSString stringWithFormat:@"Major: %d, Minor: %d, RSSI: %d, UUID: %@, ACC: %2fm",
        //                         beacon.major.intValue, beacon.minor.intValue, (int)beacon.rssi, beacon.proximityUUID.UUIDString, beacon.accuracy];
        
        NSString *detailLabel = [NSString stringWithFormat:@"Major: %d, Minor: %d, RSSI: %d, ACC: %2fm",
                                 beacon.major.intValue, beacon.minor.intValue, (int)beacon.rssi, beacon.accuracy];
        
        NSLog(@"beacon detail contents[%lu] : %@", (unsigned long)i, detailLabel);
        
        [beaconDistanceList insertObject:[NSString stringWithFormat:@"%2fm", beacon.accuracy] atIndex:i];
        [beaconList insertObject:[NSString stringWithFormat:@"%@%d%d", beacon.proximityUUID.UUIDString, beacon.major.intValue, beacon.minor.intValue] atIndex:i];
        
        
        
        
    }
    NSLog(@"!!!!! ~~~ %@", viewType);
    if([@"EMC" isEqual:viewType]) {
        [self getNearBeaconLocation];
    } else if([@"BEACON_MNG" isEqual:viewType]) {
        [self getBeaconMng];
    }
    //초기화
    beaconDistanceList = [NSMutableArray array];
    beaconList = [NSMutableArray array];
    beaconBatteryLevelList = [NSMutableArray array];
    
    self.beacons = nil;
    //NSLog(@"Beacon count [%lu]", (unsigned long)self.beacons.count);
}


- (void) getNearBeaconLocation {
    NSLog(@"!!!!! getNearBeaconLocation Exec~~~");
    NSString *nearBeacon = [self getNearBeacon];
    
    if (![@"" isEqual:nearBeacon]) {
        beaconKey = [NSString stringWithFormat:@"%@", nearBeacon];;
        
        NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
        
        NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
        
        [param setValue:nearBeacon forKey:@"BEACON_KEY"];
        [param setValue:[sessiondata valueForKey:@"session_COMP_CD"] forKey:@"COMP_CD"];
        //R 수신
        CallServer *res = [CallServer alloc];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            //R 수신
            NSString* str = [res stringWithUrl:@"getLocationName.do" VAL:param];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                NSLog(@"?? %@",str);
                
                if (![@"EM01" isEqual:EmcCode]) {
                    
                    NSString *locationName = [NSString stringWithFormat:@"%@",[jsonInfo valueForKey:@"LOCATION_NAME"]];
                    if(![@""isEqual:locationName ])
                    {
                        NSString *scriptString = [NSString stringWithFormat:@"setLocationName('%@');",locationName];
                        NSLog(@"scriptString => %@", scriptString);
                        [self.webView stringByEvaluatingJavaScriptFromString:scriptString];
                    }
                }
            });
        });
    } else {
        return;
    }
    
    
    
}

- (NSString *) getNearBeacon {
    int nearBeaconSeq = 0;
    NSString *nearBeaconValue = @"";
    if(beaconDistanceList.count > 0) {
        for (int i = 1 ; i < beaconDistanceList.count ; i++) {
            if ([beaconDistanceList objectAtIndex:nearBeaconSeq] > [beaconDistanceList objectAtIndex:i]) {
                nearBeaconSeq = i;
            }
        }
        nearBeaconValue = [beaconList objectAtIndex:nearBeaconSeq];
    }
    //초기화
    beaconDistanceList = [NSMutableArray array];
    beaconList = [NSMutableArray array];
    beaconBatteryLevelList = [NSMutableArray array];
    return nearBeaconValue;
}

- (void) getBeaconMng {
    
}
/*****2017년 2월 27일 Choi Yu Bin 추가종료******/


- (void) rcvAspn:(NSString*) jsonstring {
    NSLog(@"nslog");
    NSData *jsonData = [jsonstring dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSLog(@"[PJH_TEST] jsonInfo : %@", jsonInfo);
    
    NSString *msg = [jsonInfo valueForKey:@"MESSAGE"];
    NSString *title = [jsonInfo valueForKey:@"TITLE"];
    
    //S : 출차 시 출타통보 알랑 띄우기(2019년 11월 4일 Park Jong Hoon)
    if([@"PMS_OUT_CAR_CONFIRM"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
    {
        NSLog(@"PMS_OUT_CAR_CONFIRM::ViewController");
        // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//        NSString *server = [GlobalData getServerIp];
//        NSString *server = [GlobalData getServerIp:(port)];
        // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
        NSString *pageUrl = @"/pms_carInOutReg.do";
        NSString *callUrl = @"";
        NSString * urlParam = @"";
        
        callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
        
        NSURL *url=[NSURL URLWithString:callUrl];
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        [requestURL setHTTPMethod:@"POST"];
        [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 550)];
        
        alert.title = title;
        alert.message = msg;
        alert.delegate = self;
        
        [alert addButtonWithTitle:@"닫기"];
        [alert addButtonWithTitle:@"출타통보"];
        alert.tag=103;
        //[alert addSubview:txtView];
        [alert show] ;
        
    }
    //E : 출차 시 출타통보 알랑 띄우기(2019년 11월 4일 Park Jong Hoon)
    else{
        // 설정 정보 생성
        //S : 소리확장을 위한 수정(2021년 4월 12일 Park Jong Hoon)
        //NSDictionary *config =
        //@{TextToSpeechConfigKeySpeechSpeed: @(1.0),TextToSpeechConfigKeyVoiceType: TextToSpeechVoiceTypeWoman, TextToSpeechConfigServiceMode:NewtoneTalk_2};
        NSUInteger intOption = AVAudioSessionCategoryOptionMixWithOthers;
        
        NSDictionary *config =
        @{TextToSpeechConfigKeySpeechSpeed: @(1.0),TextToSpeechConfigKeyVoiceType: TextToSpeechVoiceTypeWoman,
          TextToSpeechConfigServiceMode:NewtoneTalk_2, TextToSpeechConfigKeyAudioType: [NSNumber numberWithInt:intOption],
          TextToSpeechConfigKeyAudioCategory: AVAudioSessionCategoryPlayback, TextToSpeechConfigKeyAudioSessionConfigOn: [NSNumber numberWithBool:YES] };
        //E : 소리확장을 위한 수정(2021년 4월 12일 Park Jong Hoon)

        // 클라이언트 생성
         MTTextToSpeechClient *textToSpeechClient =
             [[MTTextToSpeechClient alloc] initWithConfig:config];

        // 델리게이트 설정
        textToSpeechClient.delegate = self;

        NSString *tmpMsg = [NSString stringWithFormat:@"%@%@%@",title,@"  ",msg];
        [textToSpeechClient play:tmpMsg];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
        [alert show];
        
        
        if([@"AS"isEqual:[jsonInfo valueForKey:@"TASK_CD"]])
        {
            //mWebView.loadUrl(GlobalData.getServerIp()+"/DWFMSASDetail.do?JOB_CD="+gcmIntent.getStringExtra("JOB_CD")+"&GYULJAE_YN=N&sh_DEPT_CD="+ gcmIntent.getStringExtra("DEPT_CD")+"&sh_JOB_JISI_DT="+ gcmIntent.getStringExtra("JOB_JISI_DT"));
            if([GlobalDataManager hasAuth:@"fms113"]){
                NSLog(@"권한 없음");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"권한 없음" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
                [alert show];
                return ;
            }
            
            if([ [[GlobalDataManager getgData] compCd] isEqual:[jsonInfo valueForKey:@"TASK_CD"] ]){
                NSLog(@"로그인한 사업장이 다릅니다 ");
                return;
            }
            
            if ([[jsonInfo valueForKey:@"TASK_CD"] isEqual: @"AIR"]) {
                NSDateFormatter *today = [[NSDateFormatter alloc] init];
                
                [today setDateFormat:@"yyyy-MM-dd"];
                NSString *nowDate = [today stringFromDate:[NSDate date]];
                
                [today setDateFormat:@"hh:mm"];
                NSString *time = [today stringFromDate:[NSDate date]];
                
                NSString *fullWccd = [jsonInfo valueForKey:@"JOB_TPY"];
                NSString *jobTpy = [fullWccd substringWithRange:NSMakeRange(2, 4) ];
                NSString *wccd = [fullWccd substringWithRange:NSMakeRange(0, 2) ];
                NSString *deptWccd = [jsonInfo valueForKey:@"WORK_CLASS_CD"];
                NSString *jobCd = [jsonInfo valueForKey:@"JOB_CD"];
                NSString *deptCd = [jsonInfo valueForKey:@"DEPT_CD"];
                
                NSLog(@"@@@@@@@@@ JOB_TPY %@", jobTpy);
                NSLog(@"@@@@@@@@@ WORK_CLASS_CD %@", deptWccd);
                
                NSLog(@"@@@@@@@@@@@@@@ WORK_CLASS_CD : /asManagementP1%@.do?req_JOB_CD=%@&req_GYULJAE_YN=N&req_txt_schDate=%@&req_selDEPT_CD=%@&req_selWORK_CLASS=%@&req_selWORK_CLASS1=%@&req_selWORK_CLASS2=%@&req_txt_schTime=%@", jobTpy, jobCd, nowDate, deptCd, deptWccd, wccd, fullWccd, time);
                
                // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//                NSString *server = [GlobalData getServerIp];
//                NSString *server = [GlobalData getServerIp:(port)];
                // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
                NSString *pageUrl =  [NSString stringWithFormat:@"/asManagementP1%@.do",jobTpy];
                NSString *callUrl = @"";
                NSString * urlParam = [NSString stringWithFormat:@"req_JOB_CD=%@&req_GYULJAE_YN=N&req_txt_schDate=%@&req_selDEPT_CD=%@&req_selWORK_CLASS=%@&req_selWORK_CLASS1=%@&req_selWORK_CLASS2=%@&req_txt_schTime=%@", jobCd, nowDate, deptCd, deptWccd, wccd, fullWccd, time];
                
                
                callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                
                NSURL *url=[NSURL URLWithString:callUrl];
                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                [requestURL setHTTPMethod:@"POST"];
                [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                [self.webView loadRequest:requestURL];
                
                
            }else{
                // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//                NSString *server = [GlobalData getServerIp];
//                NSString *server = [GlobalData getServerIp:(port)];
                // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
                NSString *pageUrl = @"/DWFMSASDetail.do";
                NSString *callUrl = @"";
                NSString * urlParam = [NSString stringWithFormat:@"JOB_CD=%@&sh_DEPT_CD=%@&sh_JOB_JISI_DT=%@&GYULJAE_YN=N",[jsonInfo valueForKey:@"JOB_CD"],[jsonInfo valueForKey:@"DEPT_CD"],[jsonInfo valueForKey:@"JOB_JISI_DT"]];
                
                
                
                callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                
                NSURL *url=[NSURL URLWithString:callUrl];
                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                [requestURL setHTTPMethod:@"POST"];
                [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                [self.webView loadRequest:requestURL];
            }
            
        }
        
        else if([@"NOTIFY"isEqual:[jsonInfo valueForKey:@"TASK_CD"]])
        {
            CallServer *res = [CallServer alloc];
            NSLog(@"%@",res);
            
            NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
            
            [sessiondata setValue:[jsonInfo valueForKey:@"COMP_CD"] forKey:@"comp_cd"];
            [sessiondata setValue:[[GlobalDataManager getgData] empNo] forKey:@"empno"];
            [sessiondata setValue:[jsonInfo valueForKey:@"COMMUTE_TYPE"] forKey:@"type"];
            
            NSLog(@"??? sessiondata ?? %@" ,sessiondata);
            NSString* str = [res stringWithUrl:@"confirmNoti.do" VAL:sessiondata];
            NSLog(@"%@",str);
            
            if([GlobalDataManager hasAuth:@"fms114"]){
                NSLog(@"권한 없음");
                return ;
            }
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//            NSString *server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *pageUrl = @"/beforeService.do";
            NSString *callUrl = @"";
            
            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [self.webView loadRequest:requestURL];
        }
        
        else if([@"AS_RES"isEqual:[jsonInfo valueForKey:@"TASK_CD"]])
        {
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//            NSString *server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *pageUrl = @"/afterService.do";
            NSString *callUrl = @"";
            
            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [self.webView loadRequest:requestURL];
            
        }
        
        //MHR 공지사항 알림(2017.02.06 CYB추가)
        else if([@"NOTICE"isEqual:[jsonInfo valueForKey:@"TASK_CD"]])
        {
            NSLog(@"test=============================================");
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            //server = [GlobalData getServerIp];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *pageUrl = @"/noticeServiceDetail.do";
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                //R 수신
                NSString * urlParam = [NSString stringWithFormat:@"LIST_ID=%@",[jsonInfo valueForKey:@"JOB_CD"]];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"notice param go____________=+============================= %@", urlParam);
                    
                    NSString *callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                    
                    NSURL *url=[NSURL URLWithString:callUrl];
                    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                    [requestURL setHTTPMethod:@"POST"];
                    [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                    [self.webView loadRequest:requestURL];
                });
            });
            
        }
        //S : 전자결재 분개처리에 따른 추가(2019년 5월 13일 Park Jong Hoon)
        else if([@"GYULJAE"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
        {
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//            server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            
            NSString * gyuljaeGb = [jsonInfo valueForKey:@"GYULJAE_CODE"];
            
            NSString *pageUrl = @"";
            
            //일일점검일 경우
            if([@"1"isEqual:gyuljaeGb]){
                pageUrl = @"/gyuljaeDetail_work.do";
            }
            else if([@"5"isEqual:gyuljaeGb]){ //보안순찰일 경우
                pageUrl = @"/gyuljaeDetail_pat.do";
            }
            else if([@"6"isEqual:gyuljaeGb]){ //시설점검일 경우
                pageUrl = @"/gyuljaeDetail_chkWrk.do";
            }
            
            else if([@"9"isEqual:gyuljaeGb]){ //공사안전점검일 경우
                pageUrl = @"/gyuljaeDetail_gongsa.do";
            }
            
            NSString *callUrl = @"";
            NSString * urlParam = [NSString stringWithFormat:@"ID=%@&CODE=%@&DEPTCD=%@&GYULJAEDATE=%@&CMT1=%@&CMT2=%@",[jsonInfo valueForKey:@"ARG_C_GYULJAE_NO"],[jsonInfo valueForKey:@"GYULJAE_CODE"],[jsonInfo valueForKey:@"DEPT_CD"],[jsonInfo valueForKey:@"GYULJAE_DATE"],[jsonInfo valueForKey:@"CMT1"],[jsonInfo valueForKey:@"CMT2"]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"[PJH_TEST] urlParam : %@", urlParam);
                    
                    NSString *callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                    
                    NSURL *url=[NSURL URLWithString:callUrl];
                    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                    [requestURL setHTTPMethod:@"POST"];
                    [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
                    [self.webView loadRequest:requestURL];
                });
            });
        }
        //E : 전자결재 분개처리에 따른 추가(2019년 5월 13일 Park Jong Hoon)
        //S : 임계치 초과 시 알림 분개처리에 따른 추가(2022년 10월 14일 Jung Mirae)
        else if ([@"ATE_OVERTIME_RES"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] ) {
            
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            //NSString *server = [GlobalData getServerIp]; // 전역범위 변수로 대체 (2022.11.11 Jung Mirae)
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *pageUrl = @"/airSpushLimit.do";
            NSString *callUrl = @"";
    
            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
            
            NSString * urlParam =
            [NSString stringWithFormat:@"COMP_CD=%@&TIME=%@&MAC=%@&POINT=%@&TITLE=%@&MESSAGE=%@&HP_TEL=%@&BUILD_SDK=%@&VERSION_NM=%@", // VERSION_NM 추가 (2022.11.09 Jung Mirae)
             [jsonInfo valueForKey:@"COMP_CD"],
             [jsonInfo valueForKey:@"TIME"],
             [jsonInfo valueForKey:@"MAC"],
             [jsonInfo valueForKey:@"POINT"],
             [jsonInfo valueForKey:@"TITLE"],
             [jsonInfo valueForKey:@"MESSAGE"],
             [jsonInfo valueForKey:@"HP_TEL"],
             [jsonInfo valueForKey:@"BUILD_SDK"],
             [jsonInfo valueForKey:@"VERSION_NM"] // VERSION_NM 추가 (2022.11.09 Jung Mirae)
            ];
            
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [requestURL setHTTPMethod:@"POST"];
            [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
            //[self.webView loadRequest:requestURL];
            
        }
        //E : 임계치 초과 시 알림 분개처리에 따른 추가(2022년 10월 14일 Jung Mirae)
    }
}

/************************* 2017년 2월 27일 Choi Yu Bin 주석처리
 #pragma mark RECOBeaconManager delegate methods
 - (void) recoManager:(RECOBeaconManager *)manager didDetermineState:(RECOBeaconRegionState)state forRegion:(RECOBeaconRegion *)region {
 NSLog(@"didDetermineState(background) %@", region.identifier);
 }
 
 - (void) recoManager:(RECOBeaconManager *)manager didEnterRegion:(RECOBeaconRegion *)region {
 NSLog(@"viewcontroller didEnterRegion(background) %@", region.identifier);
 [GlobalData setbeacon:@"T"];
 
 if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
 // don't send any notifications
 NSLog(@"app active: not sending notification");
 return;
 }
 
 
 //  NSString *msg = [NSString stringWithFormat:@"didEnterRegion: %@", region.identifier];
 //  [self _sendEnterLocalNotificationWithMessage:msg];
 }
 
 - (void) recoManager:(RECOBeaconManager *)manager didExitRegion:(RECOBeaconRegion *)region {
 NSLog(@"viewcontroller didExitRegion(background) %@", region.identifier);
 [GlobalData setbeacon:@"F"];
 
 if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
 // don't send any notifications
 NSLog(@"app active: not sending notification");
 return;
 }
 
 //NSString *msg = [NSString stringWithFormat:@"didExitRegion: %@", region.identifier];
 //[self _sendExitLocalNotificationWithMessage:msg];
 }
 
 - (void) recoManager:(RECOBeaconManager *)manager didStartMonitoringForRegion:(RECOBeaconRegion *)region {
 NSLog(@"didStartMonitoringForRegion(background) %@", region.identifier);
 }
 
 - (void) recoManager:(RECOBeaconManager *)manager monitoringDidFailForRegion:(RECOBeaconRegion *)region withError:(NSError *)error {
 NSLog(@"monitoringDidFailForRegion(background) %@, error: %@", region.identifier, [error localizedDescription]);
 }
 ********************/
@end
@implementation UIWebView (JavaScriptAlert)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
    [alert show];
}



static BOOL diagStat = NO;
static NSInteger bIdx = -1;
- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    UIAlertView *confirmDiag = [[UIAlertView alloc] initWithTitle:nil
                                                          message:message
                                                         delegate:self
                                                cancelButtonTitle:@"취소"
                                                otherButtonTitles:@"확인", nil];
    
    [confirmDiag show];
    bIdx = -1;
    
    while (bIdx==-1) {
        //[NSThread sleepForTimeInterval:0.2];
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
    if (bIdx == 0){
        diagStat = NO;
    }
    else if (bIdx == 1) {
        diagStat = YES;
    }
    return diagStat;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    bIdx = buttonIndex;
}

// S: 카카오 음성인식 적용 중...(2022.11.07 Jung Mirae)
-(void)SttView {
    KakaoSTT *kakaoStt = [[KakaoSTT alloc] initWithNibName:@"" bundle:nil];
    [kakaoStt loadRecordingUI];
}
// E: 카카오 음성인식 적용 중...(2022.11.07 Jung Mirae)


@end
