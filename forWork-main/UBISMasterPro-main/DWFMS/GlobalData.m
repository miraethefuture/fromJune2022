//
//  GlobalData.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 17..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "GlobalData.h"

@implementation GlobalData

- (id)init {
    self = [super init];
//    if(self) {
//        // this is RECO beacon uuid
//        _supportedUUIDs = @[
//                            [[NSUUID alloc] initWithUUIDString:@"24DDF411-8CF1-440C-87CD-E368DAF9C93E"]
//                            //24DDF411-8CF1-440C-87CD-E368DAF9C93E
//                            // you can add other NSUUID instance here.
//                            ];
//
//    }
    return self;
}

//@synthesize compCd;

// S: 수정한 getServerIp 함수 (2022.11.08 Jung Mirae)
+(NSString*) getServerIp {
    
    // 저장된 포트값 확인 위해 생성
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // 값이 없다면 null or 빈값, 있다면 포트 번호
    NSString *portStoredInHere = [[NSUserDefaults standardUserDefaults] stringForKey:@"portStored"];
    NSLog(@"portStoredInHere ==== %@", portStoredInHere);

    // null or 빈값
    if(portStoredInHere.length == 0) {

        // 값 확인
        NSLog(@"portStoredInHere 빈 값==== %@", portStoredInHere);
        
        //port는 GlobalData.h에 static으로 선언
        port = @"8045";
        //port = @"8446";
    }
    
    // user defaults에 저장된 포트값이 있으면...
    if(portStoredInHere.length > 0) {
        
        NSLog(@"portStoredInHere 있을 때 ==== %@", portStoredInHere);
        
        //저장된 값을 port 변수에 할당 (port는 GlobalData.h에 static으로 선언)
        port = portStoredInHere;
    } 
    
    
    NSString *serverIp = @"https://ubistest.ubismaster.com:";
    //NSString *serverIp = @"https://www.ubismaster.com:";
    //NSString *serverIp = @"https://pro.ubismaster.com:";
    
    
    // serverIp와 port를 결합하여 최종 주소를 리턴
    NSString *returnIp = [serverIp stringByAppendingString: port];
    NSLog(@"returnIp 최종 주소 ==== %@", returnIp);
    
    return returnIp;
}
// E: 수정한 getServerIp 함수 (2022.11.08 Jung Mirae)

// S: 원래 getServerIp 함수 - 포트 변경 로직 추가하며 주석처리 (2022.11.08 Jung Mirae)
//+(NSString*) getServerIp{
//    return ServerIp;
//}
// E: 원래 getServerIp 함수 - 포트 변경 로직 추가하며 주석처리 (2022.11.08 Jung Mirae)

+(NSString*) getHomedir{
    return homedir;
}

+(void) setbeacon:(NSString*) tfvalue{
    beaconTF = tfvalue;
}

+(NSString*) getbeacon{
    return beaconTF;
}

+ (GlobalData *)sharedDefaults {
    static id sharedDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[self alloc] init];
    });
    
    return sharedDefaults;
}

@end
