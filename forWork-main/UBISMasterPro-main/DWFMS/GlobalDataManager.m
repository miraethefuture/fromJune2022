//
//  GlobalDataManager.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 18..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "GlobalDataManager.h"
#import <UIKit/UIKit.h>

@implementation GlobalDataManager

+ (GlobalData*) getgData {
    
    NSLog(@"dddd?? %@",gData);
    
    if(gData == nil)
    {
     
        gData = [GlobalData alloc];
        
        NSLog(@"make??/?? %@",gData);
         return gData;
    }
    return gData;
}
+ (void) initgData:(NSDictionary *)data {
    NSLog(@" ?? initgData %@",self.getgData);
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    [self.getgData setCompCd:[data valueForKey:@"COMP_CD"]];
    [self.getgData setHpTel:idForVendor];
    [self.getgData setAuthInd:[data valueForKey:@"AUTH_IND"]];
    [self.getgData setEmpNm:[data valueForKey:@"EMPNO_NM"] ];
    [self.getgData setEmpNo:[data valueForKey:@"EMPNO"]];
    [self.getgData setDeptCd:[data valueForKey:@"DEPT_CD"]];
    [self.getgData setPmsId:[data valueForKey:@"PMS_ID"]];//PMS추가로 인한 session추가(2018년 11월 21일 Park Jong Hoon)
    
    //S : 점심시작/종료시간 추가(2022년 4월 29일 Park Jong Hoon)
    [self.getgData setLunchYn:[data valueForKey:@"LUNCH_YN"]];
    //E : 점심시작/종료시간 추가(2022년 4월 29일 Park Jong Hoon)
    
    // S : EMC_YN, VERSION 추가 (2022.07.12 Jung Mirae)
    [self.getgData setEmcYn:[data valueForKey:@"EMC_YN"]];
    [self.getgData setVersion:[data valueForKey:@"VERSION"]];
    // E : EMC_YN 추가 (2022.07.12 Jung Mirae)
        
    // S: 비콘 추가, VERSION (2022.07.21 Jung Mirae)
    [self.getgData setBeaconYn:[data valueForKey:@"BEACON_YN"]];
    // E: 비콘 추가 (2022.07.21 Jung Mirae)

}
+ (void) initAuth:(NSArray *)data {
    NSMutableArray *tempAuth = [[NSMutableArray alloc] init];
    for(int i=0;i<[data count];i++){
        
        [tempAuth addObject:[[data objectAtIndex:i] valueForKey:@"WIN_CE"]];
        NSLog(@"??auth %d:%@",i,[[data objectAtIndex:i] valueForKey:@"WIN_CE"]);
        
    }
    [[self getgData] setAuth:tempAuth];
}
+ (void) setTime:(NSDictionary *)data {
    
    NSArray *keys = [data allKeys];
    GlobalData *global =[self getgData];
    if([keys containsObject:@"tdayout"]){
        [global setOutTime:[data valueForKey:@"tdayout"]];
    }else{
         [global setOutTime:@"-"];
    }
    
    if([keys containsObject:@"tdayin"]){
        
        [global setInTime:[data valueForKey:@"tdayin"]];
    }else{
        
        if(![keys containsObject:@"ydayout"] && [keys containsObject:@"ydayin"]){
            [global setInTime:[data valueForKey:@"ydayin"]];
        }else{
             [global setInTime:@"-"];
        }
    }
 
    //S : 점심시간 시작/종료 시간 추가(2022년 4월 29일 Park Jong Hoon)
    //점심종료
    if([keys containsObject:@"tdaylunchout"]){
        [global setLunchOutTime:[data valueForKey:@"tdaylunchout"]];
    }else{
         [global setLunchOutTime:@"-"];
    }
    
    //점심시작
    if([keys containsObject:@"tdaylunchin"]){
        [global setLunchInTime:[data valueForKey:@"tdaylunchin"]];
    }else{
         [global setLunchInTime:@"-"];
    }
    //E : 점심시간 시작/종료 시간 추가(2022년 4월 29일 Park Jong Hoon)
}
+ (NSMutableDictionary *) getAllData{
    GlobalData *global =[self getgData];
//    returnData.put("session_COMP_CD", data.getCompCd());
//    returnData.put("session_EMPNO", data.getEmpNo());
//    returnData.put("session_EMPNO_NM", data.getEmpNm());
//    returnData.put("session_AUTH_IND", data.getAuthInd());
//    returnData.put("session_DEPT_CD", data.getDeptCd());
//    returnData.put("session_HP_TEL", data.getHpTel());
//    returnData.put("APPTYPE", "DWFMS");
    
    
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    NSMutableDictionary * tempData = [[NSMutableDictionary alloc] init];
    
    [tempData setValue:[global compCd] forKey:@"session_COMP_CD"];
    [tempData setValue:[global empNo] forKey:@"session_EMPNO"];
    [tempData setValue:[global empNm] forKey:@"session_EMPNO_NM"];
    [tempData setValue:[global authInd] forKey:@"session_AUTH_IND"];
    [tempData setValue:[global deptCd] forKey:@"session_DEPT_CD"];
    [tempData setValue:idForVendor forKey:@"session_HP_TEL"];
    [tempData setValue:[global pmsId] forKey:@"session_PMS_ID"];//PMS추가로 인한 session추가(2018년 11월 21일 Park Jong Hoon)
    [tempData setValue:@"/DWFMS" forKey:@"APPTYPE"];
    
    //S : 점심시작/종료 시간에 따른 추가(2022년 4월 29일 Park Jong Hoon)
    [tempData setValue:[global lunchYn]  forKey:@"session_LUNCH_YN"];
    //E : 점심시작/종료 시간에 따른 추가(2022년 4월 29일 Park Jong Hoon)
    
    // S : EMC_YN 추가 (2022.07.12 Jung Mirae)
    [tempData setValue:[global emcYn]  forKey:@"session_EMC_YN"];
    [tempData setValue:[global version]  forKey:@"session_VERSION"];
    // E : EMC_YN 추가 (2022.07.12 Jung Mirae)
     
    // S: 비콘 추가 (2022.07.21 Jung Mirae)
    [tempData setValue:[global beaconYn]  forKey:@"BEACON_YN"];
    // E: 비콘 추가 (2022.07.21 Jung Mirae)

    
    
    NSLog(@"ddd");
    NSLog(@"ddd %d",[[tempData allKeys] count]);
    
    return tempData;
}

+ (NSString * ) getAuth{
    NSArray *authlist = [[self getgData] auth];
    NSString *retauth=@"";
    for(int i = 0 ; i<[authlist count];i++){
     
        if(i==0){
            retauth = [authlist objectAtIndex:i];
        }else{
            retauth = [NSString stringWithFormat:@"%@,%@",retauth,[authlist objectAtIndex:i]];
        }
    }
    return retauth;
}
+(BOOL) hasAuth:(NSString*) auth{
    
    
    NSArray* authlist = [[self getgData] auth];
    if( [authlist containsObject:auth])
    {
        return NO;
    }
    return YES;
    
}

//2017년 2월 27일 Choi Yu Bin 추가
+ (GlobalData*) getinstance {
    
    NSLog(@"dddd?? %@",gData);
    
    if(gData == nil)
    {
        gData = [GlobalData alloc];
        
    }
    return gData;
}

@end
