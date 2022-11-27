//
//  VoiceToTextController.m
//  DWFMS
//
//  Created by Park Jonh Hoon on 2019/11/05.
//  Copyright © 2019 DWFMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CallServer.h"
#import "GlobalData.h"
#import "GlobalDataManager.h"
#import "Commonutil.h"
#import "ToastAlertView.h"
#import "VoiceToTextController.h"
#import "SpeechViewController.h"
#import "AppDelegate.h"

@interface VoiceToTextController()

@end

@implementation VoiceToTextController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
    //Dispose of any resources that can be recreated.
}


//연결되어 있는 것 우선 수행...viewDidLoad보다 우선수행
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"연결되어 있는것 수행");
}


- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"데이터 초기화");
}

//화면로드된 직후에 처리
-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"화면로드 완료");
}

- (void)dealloc {
}
@end
