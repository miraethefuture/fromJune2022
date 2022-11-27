//
//  GlobalData.h
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 17..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//  8045, 8047

#import <Foundation/Foundation.h>

//static NSString *homedir= @"D:/40_application";
//static NSString *ServerIp=@"http://ubism.dwfms.co.kr:8090";


//static NSString *ServerIp=@"https://m.ubismaster.com:8442"; //운영
//static NSString *ServerIp=@"https://www.ubismaster.com:8445"; //테스트 - 공기질 받는 곳
//static NSString *ServerIp=@"https://www.ubismaster.com:8111"; //테스트 - Mirae
//static NSString *ServerIp=@"https://pro.ubismaster.com:8446"; //테스트프로
//static NSString *ServerIp=@"https://ubistest.ubismaster.com:8045";
//static NSString *ServerIp=@"https://ubistest.ubismaster.com:";

//static NSString *homedir= @"D:/ubis_mobile_application"; // 공기질 받는 곳
//static NSString *homedir= @"E:/ubis_mobile_smart_application"; //테스트프로
static NSString *homedir= @"D:/UBISMaster_SERVER";

//S: 포트 변경 로직 추가 - (2022.11.09 Jung Mirae)
//static NSString *ServerIp;  //포트 번호 가져와서 붙이기
static NSString *port;
//E: 포트 변경 로직 추가 - (2022.11.09 Jung Mirae)

static NSString *beaconTF = @"F";;
@interface GlobalData : NSObject{
    
    //    private String compCd;
    //    private String empNo;
    //    private String empNm;
    //    private String authInd;
    //    private String deptCd;
    //    private String hpTel;
    //    private ArrayList<String> auth;
    //    private static String ServerIp = "http://175.114.60.91:8081";// 개발
    //    //	private static String ServerIp = "http://61.102.223.71:8090"; // 인천공항운영
    //    //	private static String ServerIp = "http://61.102.223.80:8089"; //우운영
    //    private String inTime;
    //    private String outTime;
    //    private static String homedir = "D:/AIRapplication/";// 개발
    
//    NSString *compCd;
//    NSString *empNo;
//    NSString *empNm;
//    NSString *authInd;
//    NSString *deptCd;
//    NSString *hpTel;
//    NSString *ServerIp;
//    NSString *inTime;
//    NSString *outTime;
   
//    NSArray *auth;
}
// S: 포트 변경 로직 추가하며 주석처리 및 패러미터 추가한 함수 작성 (2022.11.09 Jung Mirae)
+(NSString*) getServerIp;
//+(NSString*) getServerIp:(NSString*) port;
// E: 포트 변경 로직 추가하며 주석처리 및 패러미터 추가한 함수 작성 (2022.11.09 Jung Mirae)
+(NSString*) getHomedir;
+(NSString*) getbeacon;
+(void) setbeacon:(NSString*) tfvalue;
@property(strong,nonatomic) NSString *compCd;
@property(strong,nonatomic) NSString *empNo;
@property(strong,nonatomic) NSString *empNm;
@property(strong,nonatomic) NSString *authInd;
@property(strong,nonatomic) NSString *deptCd;
@property(strong,nonatomic) NSString *hpTel;
@property(strong,nonatomic) NSString *inTime; //출근시간
@property(strong,nonatomic) NSString *outTime; //퇴근시간
@property(strong,nonatomic) NSArray *auth;
@property(strong,nonatomic) NSArray *gcmId;
/*****2017년 2월 27일 Choi Yu Bin 추가 ********/
@property(strong,nonatomic) NSString *fileDir;
@property(strong,nonatomic) NSString *fileName;
@property(strong,nonatomic) NSMutableData *fileData;
@property(strong,nonatomic) NSURL *fileUrl;

//S : 점심시간에 따른 시작/종료시간 추가(2022년 4월 29일 Park Jong Hoon)
@property(strong,nonatomic) NSString *lunchYn;
@property(strong,nonatomic) NSString *lunchInTime; //점심시작시간
@property(strong,nonatomic) NSString *lunchOutTime; //점심종료시간
//E : 점심시간에 따른 시작/종료시간 추가(2022년 4월 29일 Park Jong Hoon)

+ (GlobalData *)sharedDefaults;
//@property (nonatomic, copy, readonly) NSArray *supportedUUIDs;

@property(strong,nonatomic) NSMutableDictionary * cameraData;

@property(strong,nonatomic) NSString *pmsId; //PMS추가로 인한 session추가(2018년 11월 21일 Park Jong Hoon)

// S : EMC_YN 추가 (2022-07-12 JMR)
@property(strong,nonatomic) NSString *version; // 현재 소스에 없는 것 같아 추가
@property(strong,nonatomic) NSString *emcYn;

@property(strong,nonatomic) NSString *beaconYn;
// E : EMC_YN 추가 (2022-07-12 JMR)

@end
