//
//  AppDelegate.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 15..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "AppDelegate.h"
#import "CallServer.h"
#import "GlobalData.h"
#import "GlobalDataManager.h"
#import "Commonutil.h"
#import <CoreLocation/CoreLocation.h>
#import "ToastAlertView.h"
// S : 헤더 파일 테스트 중... (2022.11.07 Jung Mirae)
//#import "DWFMS-Swift.h"
// E : 헤더 파일 테스트 중... (2022.11.07 Jung Mirae)

//S:iOS NFC기능 추가(2019년 11월 28일 Park Jong Hoon)
#import <sys/utsname.h>
//E:iOS NFC기능 추가(2019년 11월 28일 Park Jong Hoon)

//S : 카카오 newTone소리 해결을 위한 추가(2021년 4월 12일 Park Jong Hoon)
#import <AVFoundation/AVFoundation.h>
#import <KakaoNewtoneSpeech/KakaoNewtoneSpeech.h>
//E : 카카오 newTone소리 해결을 위한 추가(2021년 4월 12일 Park Jong Hoon)

// S: FCM 적용 (2022년 10월 19일 Jung Mirae)
@import UserNotifications;
// E: FCM 적용 (2022년 10월 19일 Jung Mirae)

@interface AppDelegate ()

@end

@implementation AppDelegate{
    
    NSMutableArray *_registeredRegions;
    NSArray *_uuidList;
    BOOL isInside;
    // S: VERSION_NM 추가 (2022.11.09 Jung Mirae)
    NSDictionary *infoDict;
    NSString *appVersion;
    // E: VERSION_NM 추가 (2022.11.09 Jung Mirae)
}
#define isOSVersionOver10 ([[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >= 10)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    // Override point for customization after application launch.
    if (isOSVersionOver10) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ) {
                // 푸시 서비스 등록 성공

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                        NSLog(@"%@",@"iOS10이상등록 성공");
                    });
            }
            else {
                // 푸시 서비스 등록 실패
                NSLog(@"%@",@"iOS10이상등록 실패");
            }
            
        }];

    } else {
             if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                 UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
                 [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
                 dispatch_async(dispatch_get_main_queue(), ^{
                         [[UIApplication sharedApplication] registerForRemoteNotifications];
                     });
                     NSLog(@"TEST실패%@",@"11111");
                 NSLog(@"%@",@"등록완료");
             } else {
                 [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [[UIApplication sharedApplication]registerForRemoteNotifications];
                     });
                 NSLog(@"TEST실패%@",@"222222");
                 NSLog(@"%@",@"등록완료");
             }
    }

    [self setMain:(ViewController *)self.window.rootViewController];  //2017년 2월 27일 Choi Yu Bin 추가

    //S : Google맵 추가(2019년 4월 18일 Park Jong Hoon)
    [GMSServices provideAPIKey:@"AIzaSyDxqqzcCZVeWxEsFz5JxqPWkWXtR2GqDCs"];
    //E : Google맵 추가(2019년 4월 18일 Park Jong Hoon)

    
    
    
    
    NSLog(@"TEST %@", @"PJH~~~~~~0");
    // launchOptions가 없는지 아래 if문 타지 않음 (2022.11.10 Jung Mirae)
    if(launchOptions)//push로 인해 앱이 살아날 경우
    {
        NSLog(@"TEST %@", @"PJH~~~~~~0-1");
        NSLog(@" launchOptions %@ ",launchOptions);

        CallServer *res = [CallServer alloc];
        UIDevice *device = [UIDevice currentDevice];
        NSString* idForVendor = [device.identifierForVendor UUIDString];
        //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
        NSInteger *iosVer = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *iosModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)

        __block NSMutableDictionary* param = [[NSMutableDictionary alloc] init];

        [param setValue:idForVendor forKey:@"HP_TEL"];
        //[param setValue:@"ffffffff" forKey:@"GCM_ID"];
        [param setValue:_fcmID forKey:@"GCM_ID"];
        [param setObject:@"I" forKey:@"DEVICE_FLAG"];
        //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
        [param setObject: [NSString stringWithFormat:@"%d",iosVer] forKey:@"BUILD_SDK"];
        [param setObject: iosModel forKey:@"PACKAGE_ID"];
        //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{

            __block NSString* str = [res stringWithUrl:@"loginByPhon.do" VAL:param];
            NSLog(@"AppDelegate.m에 있는 loginByPhon 탄 후");
            dispatch_async(dispatch_get_main_queue(), ^{

                NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                //NSLog(str);
                //2017.05.18 아규값 형식 변경
                NSLog(@"%@", str);

                NSLog(@"TEST %@", @"PJH~~~~~~0-2");
                NSLog(@"TEST %@", @"rv");
                /*
                 자동로그인 부분
                 */
                if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
                {
                    if(     [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
                    {
                        NSDictionary *data = [jsonInfo valueForKey:(@"data")];
                        [GlobalDataManager initgData:(data)];
                        NSArray * timelist = [jsonInfo objectForKey:@"inout"];
                        [GlobalDataManager setTime:[timelist objectAtIndex:0]];
                        NSArray * authlist = [jsonInfo objectForKey:@"auth"];
                        [GlobalDataManager initAuth:authlist];
                        //beacon  start
                        //[self checkPermission];  //2017년 2월 27일 Choi Yu Bin 주석처리

                        //_registeredRegions = [[NSMutableArray alloc] init]; //2017년 2월 27일 Choi Yu Bin 주석처리
                        if(![@"N" isEqualToString:[data valueForKey:@"BEACON_YN"]]){    //2017년 10월 27일 Park Jong Hoon 비콘일 경우 만 아래 로직 타게...
                            _uuidList = @[
                                          [[NSUUID alloc] initWithUUIDString:[data valueForKey:@"BEACON_UUID"]]
                                          //24DDF411-8CF1-440C-87CD-E368DAF9C93E
                                          // you can add other NSUUID instance here.
                                          ];
                            //_recoManager = [[RECOBeaconManager alloc] init]; //2017년 2월 27일 Choi Yu Bin 주석처리
                            //_recoManager.delegate = self; //2017년 2월 27일 Choi Yu Bin 주석처리

                            //2017년 2월 27일 Choi Yu Bin 주석처리 시작
                            //NSSet *monitoredRegion = [_recoManager getMonitoredRegions];
                            //if ([monitoredRegion count] > 0) {
                            //    NSLog(@"isBackgroundMonitoringOn start ");
                            //    self.isBackgroundMonitoringOn = YES;
                            //} else {
                            //    NSLog(@"isBackgrSPRINGBOARDoundMonitoringOn no ");
                            //    self.isBackgroundMonitoringOn = NO;
                            //}
                            //2017년 2월 27일 Choi Yu Bin 주석처리 종료

                            for (int i = 0; i < [_uuidList count]; i++) {
                                NSLog(@"_uuidList  ");
                                //NSUUID *uuid = [_uuidList objectAtIndex:i]; //2017년 2월 27일 Choi Yu Bin 주석처리
                                //NSString *identifier = [NSString stringWithFormat:@"RECOBeaconRegion-%d", i]; //2017년 2월 27일 Choi Yu Bin 주석처리

                                //[self registerBeaconRegionWithUUID:uuid andIdentifier:identifier]; //2017년 2월 27일 Choi Yu Bin 주석처리
                            }

                        }   //2017년 10월 27일 Park Jong Hoon 비콘일 경우 만 아래 로직 타게...
                    }
                }

                param = [[NSMutableDictionary alloc] init];

                [param setValue:idForVendor forKey:@"hp_tel"];

                //deviceIdb

                //R 수신

                str = [res stringWithUrl:@"searchPushMsg.do" VAL:param];


                NSLog(@"gcmmessage %@ ",str);

                [self  rcvAspnA:str];

                //[[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
                //[[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
                //[[UIApplication sharedApplication] cancelAllLocalNotifications];


            });
        });
    }
    

    //if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
    if (!isOSVersionOver10) {
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
    }

    // S: FCM 적용 (2022년 10월 19일 Jung Mirae)
    [FIRApp configure];

    [FIRMessaging messaging].delegate = self;

    _fcmID = [FIRMessaging messaging].FCMToken;
    NSLog(@"fcmId: %@", _fcmID);

    //_fcmID = fcmToken;

    if([UNUserNotificationCenter class] != nil) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
        UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:authOptions
         completionHandler:^(BOOL granted, NSError * _Nullable error) {
            // ...
        }];
    } else {
        UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: allNotificationTypes categories: nil];
        [application registerUserNotificationSettings: settings];
    }
    [application registerForRemoteNotifications];
    // E: FCM 적용 (2022년 10월 19일 Jung Mirae)

    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSLog(@"My token is: %@", deviceToken);
  
    NSMutableString *deviceId = [NSMutableString string];
    const unsigned char* ptr = (const unsigned char*) [deviceToken bytes];
    
    for(int i = 0 ; i < 32 ; i++)
    {
        [deviceId appendFormat:@"%02x", ptr[i]];
    }
    
    NSLog(@"APNS Device Token: %@", deviceId);
    // deviceTok = deviceId;
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.DEVICE_TOK = _fcmID;
    
    
    //S : 2018년 2월 5일 Park Jong Hoon 추가(NSArrary변수로 선언 시 "<"로 변경되어 들어감)
    //2017.05.18 Incompatible pointer type Sending 'NSString *' to parameter of type 'NSArray *'
    //[[GlobalDataManager getgData] setGcmId:app.DEVICE_TOK];
    //[[GlobalDataManager getgData] setGcmId:[NSArray arrayWithObject:app.DEVICE_TOK]];
    
    //[[GlobalDataManager getgData] setGcmId:app.DEVICE_TOK]; // 원소스
    //[[GlobalDataManager getgData] setGcmId: _fcmID]; // Mirae
    //E : 2018년 2월 5일 Park Jong Hoon 추가(NSArrary변수로 선언 시 "<"로 변경되어 들어감)
    
    //NSLog(@"AppDelegate get GCM ID==> %@", [[GlobalDataManager getgData] gcmId]);
    
    CallServer *res = [CallServer alloc];
    NSLog(@"res ====> %@",res);
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    NSInteger *iosVer = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *iosModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    
    // S: VERSION_NM 추가하기 위해 앱 버전 정보 가져오기 (2022.11.09 Jung Mirae)
    infoDict = [[NSBundle mainBundle] infoDictionary];
    appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // 1.1.1
    //NSLog(@"앱 버전 확인하기 - AppDelegate.m ==== %@", appVersion);
    // S: VERSION_NM 추가하기 위해 앱 버전 정보 가져오기 (2022.11.09 Jung Mirae)
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:idForVendor forKey:@"HP_TEL"];
    
    // S : FCM 적용 (2022년 10월 19일 Jung Mirae)
    //[param setValue:app.DEVICE_TOK forKey:@"GCM_ID"]; // 원소스 주석처리
    [param setValue:_fcmID forKey:@"GCM_ID"];
    // E : FCM 적용 (2022년 10월 19일 Jung Mirae)

    [param setObject:@"I" forKey:@"DEVICE_FLAG"];
    //S : FCM추가로 인한 수정(2018년 11월 21일 Park Jong Hoon)
    //[param setObject:@"TEST" forKey:@"TEST"];
    //[param setValue:@"0" forKey:@"BUILD_SDK"];
    //E : FCM추가로 인한 수정(2018년 11월 21일 Park Jong Hoon)
    
    //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    [param setObject: [NSString stringWithFormat:@"%d",iosVer] forKey:@"BUILD_SDK"];
    [param setObject: iosModel forKey:@"PACKAGE_ID"];
    //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    
    // S: VERSION_NM 추가 (2022.11.09 Jung Mirae)
    [param setObject: appVersion forKey:@"VERSION_NM"];
    // E: VERSION_NM 추가 (2022.11.09 Jung Mirae)
    
    //R 수신
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSString* str = [res stringWithUrl:@"registGCM.do" VAL:param];
        NSLog(@"str ====> %@",str);
    
        NSLog(@"APNS Device Tok: %@", app.DEVICE_TOK);
    });
    
    // S : FCM 적용 (2022년 10월 19일 Jung Mirae)
    [[FIRMessaging messaging] APNSToken]; // 필요하지 않을 수 있음 (아래 것과 같은 소스?)
    [FIRMessaging messaging].APNSToken = deviceToken;
    NSLog(@"######### APNS token : %@", deviceToken);
    // E : FCM 적용 (2022년 10월 19일 Jung Mirae)
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@" recive aspn %@ ",userInfo);
    
    //S : 사운드 파일 구하기(2018년 12월 6일 Park Jong Hoon)
    NSLog(@" recive aspn soundDetail :  %@ ",[userInfo objectForKey:@"aps"][@"sound"]);
    NSString *soundFile = [userInfo objectForKey:@"aps"][@"sound"]; //파일명
    //E : 사운드 파일 구하기(2018년 12월 6일 Park Jong Hoon)
    
    if(application.applicationState == UIApplicationStateActive){
        //S : 사운드 파일 구하기(2018년 12월 6일 Park Jong Hoon)
        //NSString sndPath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"wav" inDirectory:@"/"];
        NSString *sndPath;
        
        //1.wav가 아니면...
        if(![@"1.wav"isEqual:soundFile]){
            NSLog(@"TESK GB : PMS ");
            sndPath = [[NSBundle mainBundle] pathForResource:@"CARHORN" ofType:@"wav" inDirectory:@"/"];
        }
        else{
            NSLog(@"TESK GB : UBISMaster ");
            sndPath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"wav" inDirectory:@"/"];
        }
        
        NSLog(@"사운드 경로는? : %@", sndPath);
        //E : 사운드 파일 구하기(2018년 12월 6일 Park Jong Hoon)
        
        CFURLRef sndURL = nil;
        sndURL = (CFURLRef)CFBridgingRetain([[NSURL alloc] initFileURLWithPath:sndPath]);
        AudioServicesCreateSystemSoundID(sndURL, &ssid);
        
        AudioServicesPlaySystemSound(ssid);
        
    }
    
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:idForVendor forKey:@"hp_tel"];
    
    //deviceId
    
    //R 수신
    
    NSString* str = [res stringWithUrl:@"searchPushMsg.do" VAL:param];
   
    NSLog(@"gcmmessage %@ ",str);
    [[self main] rcvAspn:str];
    
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

// S : FCM 적용 (2022년 10월 19일 Jung Mirae)
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"%@", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}
// E : FCM 적용 (2022년 10월 19일 Jung Mirae)


- (void) rcvAspnA:(NSString*) jsonstring {
    NSLog(@"nslog");
    NSData *jsonData = [jsonstring dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSString *msg = [jsonInfo valueForKey:@"MESSAGE"];
    NSString *title = [jsonInfo valueForKey:@"TITLE"];
    
    // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
    NSDictionary *data = [jsonInfo valueForKey:(@"data")];
    [GlobalDataManager initgData:(data)];
    NSString *port = [data valueForKey:@"PORT"];
    // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
    
    //S : 출차 시 출타통보 알랑 띄우기(2019년 11월 13일 Park Jong Hoon)
    if([@"PMS_OUT_CAR_CONFIRM"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
    {
        NSLog(@"PMS_OUT_CAR_CONFIRM::AppDelegate");
        // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
        NSString *server = [GlobalData getServerIp];
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
        
        alert.title = [jsonInfo valueForKey:@"TITLE"];
        alert.message = [jsonInfo valueForKey:@"MESSAGE"];
        alert.delegate = self;
        
        [alert addButtonWithTitle:@"닫기"];
        [alert addButtonWithTitle:@"출타통보"];
        alert.tag=103;
        //[alert addSubview:txtView];
        [alert show] ;
        
    }
    //E : 출차 시 출타통보 알랑 띄우기(2019년 11월 13일 Park Jong Hoon)
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
        
        
        if([@"AS"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
        {
            if([GlobalDataManager hasAuth:@"fms113"]){
                NSLog(@"권한 없음1");
                return ;
            }
            
            if([ [[GlobalDataManager getgData] compCd] isEqual:[jsonInfo valueForKey:@"TASK_CD"] ]){
                NSLog(@"로그인한 사업장이 다릅니다 ");
                return;
            }
         
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *pageUrl = @"/DWFMSASDetail.do";
            NSString *callUrl = @"";
            NSString * urlParam = [NSString stringWithFormat:@"JOB_CD=%@&sh_DEPT_CD=%@&sh_JOB_JISI_DT=%@&GYULJAE_YN=N",[jsonInfo valueForKey:@"JOB_CD"],[jsonInfo valueForKey:@"DEPT_CD"],[jsonInfo valueForKey:@"JOB_JISI_DT"]];
            
            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [requestURL setHTTPMethod:@"POST"];
            [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 550)];
            
            alert.title = @"A/S작업지시";
            alert.message = [jsonInfo valueForKey:@"TITLE"];
            alert.delegate = self;
            
            [alert addButtonWithTitle:@"취소"];
            [alert addButtonWithTitle:@"확인"];
            alert.tag=101;
            //[alert addSubview:txtView];
            [alert show] ;
            
        }
        else if([@"NOTIFY"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
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
            NSString *server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *pageUrl = @"/beforeService.do";
            NSString *callUrl = @"";
            
            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [self.main.webView loadRequest:requestURL];
        }
        else if([@"AS_RES"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
        {
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *pageUrl = @"/afterService.do";
            NSString *callUrl = @"";
            
            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [self.main.webView loadRequest:requestURL];
            
        }
        
        //MHR 공지사항 알림(2017.02.06 CYB추가)
        else if([@"NOTICE"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
        {
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            NSString *pageUrl = @"/noticeServiceDetail.do";
            NSString *callUrl = @"";
            NSString * urlParam = [NSString stringWithFormat:@"LIST_ID=%@",[jsonInfo valueForKey:@"JOB_CD"]];
            
            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [requestURL setHTTPMethod:@"POST"];
            [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
            [self.main.webView loadRequest:requestURL];
            
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@";alert ?? %d",alertView.tag);
    if(alertView.tag==101)     // check alert by tag
    {
        if(buttonIndex ==1)
        {
            CallServer *res = [CallServer alloc];
            UIDevice *device = [UIDevice currentDevice];
            NSString* idForVendor = [device.identifierForVendor UUIDString];
            
            
            NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
            
            [param setValue:idForVendor forKey:@"hp_tel"];
            
            //deviceId
            
            //R 수신
            
            NSString* str = [res stringWithUrl:@"searchPushMsg.do" VAL:param];
            
            NSLog(@"gcmmessage %@ ",str);
            [[self main] rcvAspn:str];
        }else{
            
        }
    }
    //S : 출차 시 출타통보 알랑 띄우기(2019년 11월 13일 Park Jong Hoon)
    else if(alertView.tag==103)     // check alert by tag
    {
        NSLog(@"출타통보 AppDelegate.m");
        if(buttonIndex ==1)
        {
            NSLog(@"출타통보 클릭 AppDelegate.m");
            
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            //NSString *server = [GlobalData getServerIp];
//            NSString *server = [GlobalData getServerIp:(port)];
//            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
//            NSString *pageUrl = @"/pms_carInOutReg.do";
//            NSString *callUrl = @"";
//
//            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
//
//            NSURL *url=[NSURL URLWithString:callUrl];
//            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
//            [self.main.webView loadRequest:requestURL];
            // 잠깐 주석처리 Mirae
        }else{
            exit(0);
        }
    }
    //E : 출차 시 출타통보 알랑 띄우기(2019년 11월 13일 Park Jong Hoon)
    else{
        if(buttonIndex ==1)
        {
            //
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


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ([UNUserNotificationCenter class] != nil) {
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
            UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter]
             requestAuthorizationWithOptions:authOptions
             completionHandler:^(BOOL granted, NSError * _Nullable error) {
                 // ...
             }];
        } else {
            // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [application registerUserNotificationSettings:settings];
        }
        
        [application registerForRemoteNotifications];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"??? onResume applicationWillEnterForeground ?? ");
    
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    NSInteger *iosVer = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *iosModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    
    // S: VERSION_NM 추가하기 위해 앱 버전 정보 가져오기 (2022.11.09 Jung Mirae)
    infoDict = [[NSBundle mainBundle] infoDictionary];
    appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // 1.1.1
    //NSLog(@"앱 버전 확인하기 ==== %@", appVersion);
    // S: VERSION_NM 추가하기 위해 앱 버전 정보 가져오기 (2022.11.09 Jung Mirae)
    
    NSString *currentURL = self.main.webView.request.URL.absoluteString;
    
    
    NSLog(@"currentURL:::::%@", currentURL);
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:idForVendor forKey:@"HP_TEL"];
    //[param setValue:@"ffffffff" forKey:@"GCM_ID"]; // 원소스 Mirae
    [param setValue:_fcmID forKey:@"GCM_ID"];
    [param setObject:@"I" forKey:@"DEVICE_FLAG"];
    //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    [param setObject: [NSString stringWithFormat:@"%d",iosVer] forKey:@"BUILD_SDK"];
    [param setObject: iosModel forKey:@"PACKAGE_ID"];
    //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
    
    // S: VERSION_NM 추가 (2022.11.09 Jung Mirae)
    [param setObject: appVersion forKey:@"VERSION_NM"];
    //NSLog(@"버전 확인====%@", appVersion);
    // E: VERSION_NM 추가 (2022.11.09 Jung Mirae)
    
    //deviceId
    
    //R 수신
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        __block NSString* str = [res stringWithUrl:@"loginByPhon.do" VAL:param];
        
        NSLog(@"타는지 확인"); // 안탐
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            //NSLog(str);
            NSLog(@"%@", str);
            
            NSString *urlParam=@"";
            // S: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            //NSString *server = [GlobalData getServerIp];
//            NSDictionary *data = [jsonInfo valueForKey:(@"data")];
//            [GlobalDataManager initgData:(data)];
//            NSString *port = [data valueForKey:@"PORT"];
//
//            NSString *server = [GlobalData getServerIp:(port)];
            // E: 포트 변경 로직 추가하며 함수 변경(2022.11.09 Jung Mirae)
            
            NSString *server = [GlobalData getServerIp];
            NSString *pageUrl = @"/DWFMS";
            NSString *callUrl = @"";
            NSString *callWelcome = @"false";
            /*
             자동로그인 부분
             */
            if([@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
            {
                if( [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
                {
                    NSDictionary *data = [jsonInfo valueForKey:(@"data")];
                    [GlobalDataManager initgData:(data)];
                    NSArray * timelist = [jsonInfo objectForKey:@"inout"];
                    [GlobalDataManager setTime:[timelist objectAtIndex:0]];
                    NSArray * authlist = [jsonInfo objectForKey:@"auth"];
                    [GlobalDataManager initAuth:authlist];
                    
                    
                    NSMutableDictionary * session =[GlobalDataManager getAllData];
                    
                    [session setValue:[GlobalDataManager getAuth] forKey:@"auth"];
                    [session setValue:[[GlobalDataManager getgData] inTime]  forKey:@"inTime"];
                    [session setValue:[[GlobalDataManager getgData] outTime]  forKey:@"outTime"];
                    
                    //S : 점심시작/종료시간 추가(2022년 4월 29일 Park Jong Hoon)
                    [session setValue:[[GlobalDataManager getgData] lunchInTime]  forKey:@"lunchInTime"];
                    [session setValue:[[GlobalDataManager getgData] lunchOutTime]  forKey:@"lunchOutTime"];
                    //E : 점심시작/종료시간 추가(2022년 4월 29일 Park Jong Hoon)
                    
                    //S : 비콘 추가(2022.07.21 Jung Mirae)
                    [session setValue:[[GlobalDataManager getgData] beaconYn]  forKey:@"BEACON_YN"];
                    //E : 비콘 추가(2022.07.21 Jung Mirae)
                    
                    urlParam = [Commonutil serializeJson:session];
                    
                    NSString * text =@"본 어플리케이션은 원할한 서비스를\n제공하기 위해 휴대전화번호등의 개인정보를 사용합니다.\n[개인정보보호법]에 의거해 개인정보 사용에 대한 \n사용자의 동의를 필요로 합니다.\n개인정보 사용에 동의하시겠습니까?\n";
                    NSLog(@"urlParam %@",urlParam);
                    callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
                    NSLog(@"%@",callUrl);
                    
                    if(![@"Y" isEqualToString:[data valueForKey:@"INFO_YN"]])
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:text delegate:self
                                                              cancelButtonTitle:@"취소"
                                                              otherButtonTitles:@"동의", nil];
                        [alert show];
                    }
                    
                    //viewType = @"LOGIN";
                    callWelcome= @"true";
                    
                    
                }else{
                    //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
                    NSInteger *iosVer = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
                    struct utsname systemInfo;
                    uname(&systemInfo);
                    NSString *iosModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
                    //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
                    
                    //S : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
//                    urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I",idForVendor,@"22222222"];
                    urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I&BUILD_SDK=%@&PACKAGE_ID=%@&session_VERSION=%@",idForVendor,@"22222222", [NSString stringWithFormat:@"%d",iosVer], iosModel, @"P"];
                    //E : iOS 정보추출 로그인 추가(2019년 11월 27일 Park Jong Hoon)
                    NSLog(@"%@",urlParam);
                    callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
                    
                    //self.main.webView.loadUrl(server+"#login");
                    //  Toast.makeText(context, "다른 폰에서 로그인 되었습니다  ", Toast.LENGTH_LONG).show();
                    NSURL *url=[NSURL URLWithString:callUrl];
                    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                    [self.main.webView loadRequest:requestURL];
                    return;
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
            
            if( [@"true"isEqual:callWelcome] ){
                [self callWelcome];
            }            
        });
    });
}

-(void) callWelcome{
    NSError *error;
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    //출근시간
    if([@"" isEqualToString:[[GlobalDataManager getgData] inTime]])
    {
        [param setObject:@"-" forKey:@"INTIME"];
    }else{
        
        [param setObject:[[GlobalDataManager getgData] inTime]  forKey:@"INTIME"];
    }
    
    //퇴근시간
    if([@"" isEqualToString:[[GlobalDataManager getgData] outTime]])
    {
        [param setObject:@"-" forKey:@"OUTTIME"];
    }else{
        [param setObject:[[GlobalDataManager getgData] outTime]  forKey:@"OUTTIME"];
    }
    
    //S : 점심시간 시작/종료시간 추가(2022년 4월 29일 Park Jong Hoon)
    //점심시작
    if([@"" isEqualToString:[[GlobalDataManager getgData] lunchInTime]])
    {
        [param setObject:@"-" forKey:@"LUNCHINTIME"];
    }else{
        
        [param setObject:[[GlobalDataManager getgData] lunchInTime]  forKey:@"LUNCHINTIME"];
    }
    
    //점심종료
    if([@"" isEqualToString:[[GlobalDataManager getgData] lunchOutTime]])
    {
        [param setObject:@"-" forKey:@"LUNCHOUTTIME"];
    }else{
        [param setObject:[[GlobalDataManager getgData] lunchOutTime]  forKey:@"LUNCHOUTTIME"];
    }
    //E : 점심시간 시작/종료시간 추가(2022년 4월 29일 Park Jong Hoon)
    
    
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
    [self.main.webView stringByEvaluatingJavaScriptFromString:scriptString];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
//- (void)checkPermission {
//    if ([RECOBeaconManager isMonitoringAvailable]){
//        UIApplication *application = [UIApplication sharedApplication];
//        if (application.backgroundRefreshStatus != UIBackgroundRefreshStatusAvailable) {
//            NSString *title = @"Background App Refresh Permission Denied";
//            NSString *message = @"To re-enable, please go to Settings > General and turn on Background App Refresh for this app.";
//            [self showAlertWithTitle:title andMessage:message];
            
//        }
//    }
    
//    if([RECOBeaconManager locationServicesEnabled]){
//        NSLog(@"Location Services Enabled");
//        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
//            NSString *title = @"Location Service Permission Denied";
//            NSString *message = @"To re-enable, please go to Settings > Privacy and turn on Location Service for this app.";
//            [self showAlertWithTitle:title andMessage:message];
//        }
//    }
//}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


//- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID andIdentifier:(NSString*)Identifier {
//    RECOBeaconRegion *recoRegion = [[RECOBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:Identifier];
    
//    [recoRegion setNotifyOnEntry:YES];
//    [recoRegion setNotifyOnExit:YES];
//    [_registeredRegions addObject:recoRegion];
//}


#pragma mark notificadtion
- (void)_sendEnterLocalNotificationWithMessage:(NSString *)message {
    if (!isInside) {
        UILocalNotification *notice = [[UILocalNotification alloc] init];
        
        notice.alertBody = message;
        notice.alertAction = @"Open";
        notice.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notice];
    }
    
    isInside = YES;
}

- (void)_sendExitLocalNotificationWithMessage:(NSString *)message {
    if (isInside) {
        UILocalNotification *notice = [[UILocalNotification alloc] init];
        
        notice.alertBody = message;
        notice.alertAction = @"Open";
        notice.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notice];
    }
    
    isInside = NO;
}

- (void) startBackgroundMonitoring {
   
}

- (void) stopBackgroundMonitoring {
    
}

// S : FCM 적용 (2022년 10월 20일 Jung Mirae)
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    NSLog(@"%@", userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
}

// E : FCM 적용 (2022년 10월 20일 Jung Mirae)



//2017년 2월 27일 Choi Yu Bin 주석시작
/******
- (void) startBackgroundMonitoring {
    if (![RECOBeaconManager isMonitoringAvailable]) {
        NSLog(@"startBackgroundMonitoring return");
        return;
    }
    for (RECOBeaconRegion *recoRegion in _registeredRegions) {
        [_recoManager startMonitoringForRegion:recoRegion];
    }
}

- (void) stopBackgroundMonitoring {
    NSSet *monitoredRegions = [_recoManager getMonitoredRegions];
    for (RECOBeaconRegion *recoRegion in monitoredRegions) {
        [_recoManager stopMonitoringForRegion:recoRegion];
    }
}

#pragma mark RECOBeaconManager delegate methods
- (void) recoManager:(RECOBeaconManager *)manager didDetermineState:(RECOBeaconRegionState)state forRegion:(RECOBeaconRegion *)region {
    NSLog(@"didDetermineState(background) %@", region.identifier);
}

- (void) recoManager:(RECOBeaconManager *)manager didEnterRegion:(RECOBeaconRegion *)region {
    NSLog(@"appdelegate 1didEnterRegion(background) %@", region.identifier);
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
    NSLog(@"appdelegate 1didExitRegion(background) %@", region.identifier);
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
 ******/
//2017년 2월 27일 Choi Yu Bin 주석종료
@end
