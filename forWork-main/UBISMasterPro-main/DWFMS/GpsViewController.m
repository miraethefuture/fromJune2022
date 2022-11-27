//
//  GpsViewController.m
//  DWFMS
//
//  Created by Park Jonh Hoon on 19/04/2019.
//  Copyright © 2019 DWFMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CallServer.h"
#import "GlobalData.h"
#import "GlobalDataManager.h"
#import "Commonutil.h"
#import "ToastAlertView.h"
#import "GpsViewController.h"
#import "MapViewController.h"
#import "AppDelegate.h"

@interface GpsViewController()

@end

@implementation GpsViewController


////구글맵 좌표 가져오기
@synthesize viewManGpsY;
@synthesize viewManGpsX;
@synthesize viewPointDistance; //거리
@synthesize gpsCtlYn;// gps화면 넘기려는 bool

BOOL bDataCreate; // 데이터를 갱신해야 하는지 확인용으로 bool형 변수 하나 선언

- (void)viewDidLoad {

    [super viewDidLoad];
    
    //버튼들 셋팅
    _btn_ateIn.layer.cornerRadius = 15;
    _btn_ateIn.layer.borderWidth = 2.0;
    _btn_ateIn.layer.borderColor = UIColor.orangeColor.CGColor;
    
    _btn_ateOut.layer.cornerRadius = 15;
    _btn_ateOut.layer.borderWidth = 2.0;
    _btn_ateOut.layer.borderColor = UIColor.orangeColor.CGColor;
    
    bDataCreate = NO; // NO로 초기화(안해도 되지만)
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotiDataCreate:) name:@"NotiDataCreate" object:nil];    // noti 등록
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
    //Dispose of any resources that can be recreated.
}


//연결되어 있는 것 우선 수행...viewDidLoad보다 우선수행
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"show"]){
        //iphoen 자체가 위치정보를 동의하였으면...
        if([CLLocationManager locationServicesEnabled]){
            
            //해당app에 대한 위치정보가 켜져 있으면..
            if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse){
                gpsCtlYn = @"N";
                
                NSLog(@"UBISMaster 위치정보가 비활성화...메인화면으로 이동");
                //[ToastAlertView showToastInParentView:self.view withText:@"UBISMaster 위치정보가 비활성화 되어 있습니다.!!설정을 변경해 주세요.!!" withDuaration:3.0];
            }
            else{
                gpsCtlYn = @"Y";
            }
        }
        else{
            gpsCtlYn = @"N";
            
            NSLog(@"iPhone 위치정보가 비활성화..메인화면으로 이동");
            //[ToastAlertView showToastInParentView:self.view withText:@"iPhone 위치정보가 비활성화 되어 있습니다.!!설정을 변경해 주세요.!!" withDuaration:3.0];
        }
    }
    NSLog(gpsCtlYn);
}

- (IBAction)MoveMain:(UIButton *)sender {
    NSLog(@"메인화면으로 이동");
    [self dismissViewControllerAnimated:YES completion:nil];
}

//출근버튼 클릭..
- (IBAction)AteIn:(UIButton *)sender {
    NSLog(@"출근버튼 클릭");
    NSLog(@"GpsViewController viewManGpsY : %@", viewManGpsY);
    NSLog(@"GpsViewController viewManGpsX : %@", viewManGpsX);
    NSLog(@"GpsViewController viewPointDistance : %@", viewPointDistance);
    
    //GPS가 꺼져 있으면..
    if(gpsCtlYn == @"N"){
        [ToastAlertView showToastInParentView:self.view withText:@"UBISMaster 위치정보가 비활성화 되어 있습니다.!!설정을 변경해 주세요.!!" withDuaration:3.0];
    }
    else{
        //위치정보가 수신되었으면...
        if((viewManGpsY != NULL)&&(viewPointDistance != NULL)){
            if([viewPointDistance intValue] > 200){
                NSString *msg = [NSString stringWithFormat:@"목적지와의 거리가 200m 이상 차이가 있습니다. 가까이 이동하세요!!(현재거리 : %@m)", [NSString stringWithFormat:@"%d", [viewPointDistance intValue]]];
                [ToastAlertView showToastInParentView:self.view withText: msg withDuaration:3.0];
            }
            else{
                CallServer *res = [CallServer alloc];
                NSLog(@"%@",res);
                
                
                NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
                
                
                [sessiondata setObject:@"02" forKey:@"JOB_TPY"];//JOB_TPY추가하기
                [sessiondata setObject:@"GPS" forKey:@"TAG_ID"];//TAG_ID추가하기
                [sessiondata setObject:@"GPS" forKey:@"SERIAL_NO"];//TAG_ID추가하기
                
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
                    
                        
                        if([@"02"isEqual:[sessiondata valueForKey:@"JOB_TPY"] ] ) {
                            //viewController와의 결과처리를 위한 방법
                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"02", @"JOB_TPY",nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"GpsResult" object:self userInfo:dic];
                            
                            [self dismissViewControllerAnimated:YES completion:nil]; //현재 팝업 닫기
                        }
                    });
                });
            }
        }
        else{
            [ToastAlertView showToastInParentView:self.view withText:@"위치정보가 수신되지 않았습니다.!!잠시만 기다려 주세요.." withDuaration:3.0];
        }
    }
}

- (IBAction)AteOut:(UIButton *)sender {
    NSLog(@"퇴근버튼 클릭");
    NSLog(@"GpsViewController viewManGpsY : %@", viewManGpsY);
    NSLog(@"GpsViewController viewManGpsX : %@", viewManGpsX);
    NSLog(@"GpsViewController viewPointDistance : %@", viewPointDistance);
    
    //GPS가 꺼져 있으면..
    if(gpsCtlYn == @"N"){
        [ToastAlertView showToastInParentView:self.view withText:@"UBISMaster 위치정보가 비활성화 되어 있습니다.!!설정을 변경해 주세요.!!" withDuaration:3.0];
    }
    else{
        //위치정보가 수신되었으면...
        if((viewManGpsY != NULL)&&(viewPointDistance != NULL)){
            if([viewPointDistance intValue] > 200){
                NSString *msg = [NSString stringWithFormat:@"목적지와의 거리가 200m 이상 차이가 있습니다. 가까이 이동하세요!!(현재거리 : %@m)", [NSString stringWithFormat:@"%d", [viewPointDistance intValue]]];
                [ToastAlertView showToastInParentView:self.view withText: msg withDuaration:3.0];
            }
            else{
                CallServer *res = [CallServer alloc];
                NSLog(@"%@",res);
                
                
                NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
                
                
                [sessiondata setObject:@"03" forKey:@"JOB_TPY"];//JOB_TPY추가하기
                [sessiondata setObject:@"GPS" forKey:@"TAG_ID"];//TAG_ID추가하기
                [sessiondata setObject:@"GPS" forKey:@"SERIAL_NO"];//TAG_ID추가하기
                
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
                        
                        
                        if([@"03"isEqual:[sessiondata valueForKey:@"JOB_TPY"] ] ) {
                            //viewController와의 결과처리를 위한 방법
                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"03", @"JOB_TPY",nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"GpsResult" object:self userInfo:dic];
                            
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                    });
                });
            }
        }
        else{
            [ToastAlertView showToastInParentView:self.view withText:@"위치정보가 수신되지 않았습니다.!!잠시만 기다려 주세요.." withDuaration:3.0];
        }
    }
}

//S : 자식 데이터를 가져오기 위한 선언
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"데이터 초기화");
    if (bDataCreate == YES) {   // 되돌아왔을때 YES면 데이터 갱신 후 다시 NO로 초기화
        // 데이터 갱신 (ex: data select add .... [tableview reload] )
        bDataCreate = NO;
    }
}

//화면로드된 직후에 처리
-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"화면로드 완료");
    
    //GPS가 꺼져 있으면..
    if([gpsCtlYn isEqual: @"N"]){
        //viewController와의 결과처리를 위한 방법
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"99", @"JOB_TPY",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GpsResult" object:self userInfo:dic];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc {   // 뷰 날라갈땐 등록한 noti 제거
    NSLog(@"noti 닫기");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)receiveNotiDataCreate:(NSNotification *) note {
    bDataCreate = YES;  // 자식뷰컨트롤러로 부터 변경하라는 노티가 왔다면 YES로 변경
    //NSLog(notification.object);
    viewManGpsY = [[note userInfo] objectForKey:@"gpsY"];
    viewManGpsX = [[note userInfo] objectForKey:@"gpsX"];
    viewPointDistance = [[note userInfo] objectForKey:@"pointDistance"];
    
    NSLog(@"데이터 수신");
}
//E : 자식 데이터를 가져오기 위한 선언

@end
