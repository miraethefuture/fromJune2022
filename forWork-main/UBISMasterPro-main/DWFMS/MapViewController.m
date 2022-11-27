//
//  MapViewController.m
//  DWFMS
//
//  Created by Park Jonh Hoon on 18/04/2019.
//  Copyright © 2019 DWFMS. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import "CallServer.h"
#import "GlobalData.h"
#import "GlobalDataManager.h"
#import "Commonutil.h"
#import "ToastAlertView.h"

@interface MapViewController()

@end

@implementation MapViewController

//사용자 좌표
@synthesize chkGpsY;
@synthesize chkGpsX;

//목적지 좌표
@synthesize mutableGpsY;
@synthesize mutableGpsX;
@synthesize mutableGpsNm;

//가장 가까운 목적지와의 거리
@synthesize mutableDistance;
@synthesize goalDistance;

- (void)viewDidLoad {
    [super viewDidLoad];

    MapViewController *mapViewController = [[MapViewController alloc]init];
    //mapViewController.delegate = self;
    
    //사용중에만 위치정보 요청
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    //내 위치 가져오기
    //초기화
    locationManager = [[CLLocationManager alloc]init];
    
    //delegate연결
    locationManager.delegate = self;
    
    
    
    //현재위치 업데이트
    [locationManager startUpdatingLocation];
    NSLog(@"최초한번만 실행??");
    //camera는 처음 화면에 보일 지도위치를 지정하는 역할
    //cameraWithLatitude = 위도 / longitude = 경도 / zoom = Zoom
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude zoom:17];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    //내 위치 활성화 여부
    mapView_.myLocationEnabled = YES;
    
    //내 위치 표시버튼
    mapView_.settings.myLocationButton = YES;
    
    //나침판 표시
    mapView_.settings.compassButton = YES;
    
    self.view = mapView_;
    
    //마커표시
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:idForVendor forKey:@"HP_TEL"];
    
    // S: GCM_ID 값 변경 (2022.11.10 Jung Mirae)
    //[param setValue:@"ffffffff" forKey:@"GCM_ID"];
    [param setValue:[[GlobalDataManager getgData] gcmId] forKey:@"GCM_ID"];
    // E: GCM_ID 값 변경 (2022.11.10 Jung Mirae)
    
    [param setObject:@"I" forKey:@"DEVICE_FLAG"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSString* str = [res stringWithUrl:@"getGpsPointList.do" VAL:param];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            //NSLog(str);
            NSLog(@"%@", str);
            
            /*
             자동로그인 부분
             */
            if([@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
            {
                NSDictionary *data = [jsonInfo valueForKey:(@"data")];
                NSLog(@"data가 모니?? : %@", data);
                
                NSArray *dicts = data; // wherever you get the array

                //초기화
                NSArray *arrayGoalGpsY = [[NSArray alloc]init];
                NSArray *arrayGoalGpsX = [[NSArray alloc]init];
                NSArray *arrayGoalGpsNm = [[NSArray alloc]init];
                
                mutableGpsNm = [NSMutableArray arrayWithArray:arrayGoalGpsNm];
                mutableGpsY = [NSMutableArray arrayWithArray:arrayGoalGpsY];
                mutableGpsX = [NSMutableArray arrayWithArray:arrayGoalGpsX];
                
                for(int i =0; i<dicts.count; i++){
                    NSDictionary *mijnDict = [dicts objectAtIndex: i];
                    
                    NSLog(@"mijnDict가 모니?? : %@", mijnDict);
                    
                    NSString *pointGpsY = [mijnDict objectForKey:@"GPS_Y"];
                    NSString *pointGpsX = [mijnDict objectForKey:@"GPS_X"];
                    NSString *pointTitle = [mijnDict objectForKey:@"GPS_NM"];
                    
                    //목적지 배열안에 넣기
                    [mutableGpsY addObject:pointGpsY];
                    [mutableGpsX addObject:pointGpsX];
                    [mutableGpsNm addObject:pointTitle];
                    
                    NSLog(@"MapViewController 목적지 수량 : %i", mutableGpsX.count);
                    
                    double gpsY = [pointGpsY doubleValue];
                    double gpsX = [pointGpsX doubleValue];
                    
                    NSString *strSnippet = [NSString stringWithFormat:@"%@%@%@%@", @"위도 : ", pointGpsY,@" 경도 : ",pointGpsX];
                    
                    NSLog(@"TITLE : %@", pointTitle);
                    NSLog(@"GPSY : %@", pointGpsY);
                    NSLog(@"GPSX : %@", pointGpsX);
                    NSLog(@"MSG : %@", strSnippet);
                    
                    GMSMarker *maker = [[GMSMarker alloc]init]; //마커 초기화
                    
                    maker.icon = [UIImage imageNamed:@"ate_goal"];
                    maker.title = pointTitle;
                    maker.snippet = strSnippet;
                    maker.position = CLLocationCoordinate2DMake(gpsY, gpsX);
                    maker.map = mapView_;
                }
            }
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //Dispose of any resources that can be recreated.
}


//실행되는 동안 수행
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if([locations count] != 0)
    {
        for(int i=0 ; i < [locations count] ; i++)
        {
            CLLocation *currentLocation = [locations objectAtIndex:i];
            NSLog([NSString stringWithFormat:@"iOS Corelocation location : %f , %f" , currentLocation.coordinate.latitude , currentLocation.coordinate.longitude]);
            
            chkGpsY =[NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
            chkGpsX =[NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
            
            NSLog(@"MapViewController chkGpsY 값 : %@", chkGpsY);
            NSLog(@"MapViewController chkGpsX 값 : %@", chkGpsX);
            
            //NSLog(@"MapViewController 목적지 수량 : %i", mutableGpsX.count);
            
            self.distanceGoalPoint;
            
            NSLog(@"MapViewController 거리 값 : %@", goalDistance);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:chkGpsY, @"gpsY", chkGpsX, @"gpsX", goalDistance, @"pointDistance" ,nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotiDataCreate" object:self userInfo:dic];
            
        }
        
    }
}

//S : 두 지점간의 거리 계산(2019년 4월 2일 Park Jong Hoon)
-(void)distanceGoalPoint{
    //사용자 좌표
    CLLocation *userPoint = [[CLLocation alloc] initWithLatitude:[chkGpsY doubleValue] longitude:[chkGpsX doubleValue]];
    CLLocation *goalPoint;
    
    NSArray *arrayDistane = [[NSArray alloc]init]; //사용할 변수 초기화
    mutableDistance = [NSMutableArray arrayWithArray:arrayDistane];
    
    for(int i = 0; i<mutableGpsX.count; i++){
        goalPoint = [[CLLocation alloc] initWithLatitude:[mutableGpsY[i] doubleValue] longitude:[mutableGpsX[i] doubleValue]];
        
        CLLocationDistance distance = [userPoint distanceFromLocation:goalPoint];
        NSLog(@"두 지점간의 거리 : %@(%f)", mutableGpsNm[i],  distance);
        
        [mutableDistance addObject:[NSString stringWithFormat:@"%f", distance]];
    }
    
    //가장 가까운 지점 구하기..
    for(int j = 0; j<mutableDistance.count; j++){
        if(j > 0){
            if([mutableDistance[j] doubleValue] < [mutableDistance[j-1] doubleValue])
            {
                goalDistance = mutableDistance[j];
            }
        }
        else{
            goalDistance = mutableDistance[j];
        }
    }

    NSLog(@"%@", goalDistance);
}
@end

