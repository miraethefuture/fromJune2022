//
//  CallServer.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 16..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "CallServer.h"
#import "GlobalDataManager.h"
#import "GlobalData.h"

@implementation CallServer

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didReceiveData");
    
    NSLog(@"str = %@",str);
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonData);
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSLog(@"%@",jsonInfo);
    
    
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"connectionDidFinishLoading");
    
}

- (NSString *)stringWithUrl:(NSString *)url VAL:(NSMutableDictionary*)param
{    
    // S: 출퇴근 시간 사용자 증가 관련 이슈 해결 위해 port 변수 추가중 (2022.11.10 Jung Mirae)
    NSString *server = [GlobalData getServerIp];
    
    //NSString *serverUrl = [NSString stringWithFormat:@"%@/%@",ServerIp,url];
    //ServerIp -> server로 변경 / url은 @"loginByPhon.do"
    NSString *serverUrl = [NSString stringWithFormat:@"%@/%@",server,url];
    // E: 출퇴근 시간 사용자 증가 관련 이슈 해결 위해 port 변수 추가중 (2022.11.10 Jung Mirae)
    
    NSLog(@"callserver stringWithUrl : %@",serverUrl);
    
    NSMutableURLRequest  *urlRequest = [NSMutableURLRequest  requestWithURL:[ NSURL URLWithString:serverUrl]
                                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                            timeoutInterval:30];
    
    NSArray* keys = param.allKeys;
    
    NSLog(@"keys cont %d",keys.count);
    
    NSString * urlParam =@"";
    for (int i=0; i<keys.count; i++) {
        urlParam = [NSString stringWithFormat:@"%@%@=%@&",urlParam,[keys objectAtIndex:i],[param objectForKey:[keys objectAtIndex:i]]];
        NSLog(@"key %@  value %@",[keys objectAtIndex:i],[param objectForKey:[keys objectAtIndex:i]] );
    }
    
    // This is how we set header fields
    //[urlRequest setHTTPBody:[[NSString stringWithFormat:urlParam] dataUsingEncoding:NSUTF8StringEncoding]];
    //2017.05.18 아규값 형식 변경
    [urlRequest setHTTPBody:[[NSString stringWithFormat:@"%@", urlParam] dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPMethod:@"POST"];
    
    // Fetch the JSON response
    __block NSData *urlData;
    //NSURLResponse *response;
    //NSError *error;
    
    
    // Make synchronous request
    //urlData = [NSURLConnection sendSynchronousRequest:urlRequest
    //                                returningResponse:&response
    //                                            error:&error];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSLog(@"TEST %@", @"PJH callServer~~~~~~3-0");
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", urlRequest.URL]]];
    //NSLog(@"urlRequest ==> %@", urlRequest);
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.HTTPAdditionalHeaders = @{
                                                   @"api-key"       : @"API_KEY"
                                                   };
    //S : 푸시알람 시 Param값 못넘겨 주는 증상해결(2018년 3월 7일 Hwang Ja Young)
    //    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject];
    //E : 푸시알람 시 Param값 못넘겨 주는 증상해결(2018년 3월 7일 Hwang Ja Young)
    NSLog(@"TEST %@", @"PJH callServer~~~~~~3-1");
    NSLog(@"TEST %@", urlRequest);
    [[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"TEST %@", @"PJH callServer~~~~~~3-2");
        
        if((error == nil)&&[(NSHTTPURLResponse *)response statusCode] == 200){
            
            NSLog(@"Response:%@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSLog(@"Response:%@\n", data);
            urlData = data;
            NSLog(@"로직을 탔을 경우%@\n", urlData);
            
        
            //return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        }
        dispatch_semaphore_signal(semaphore);
        //return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    }] resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"TEST %@", @"PJH callServer~~~~~~3-4");
    //NSLog(@"error :%@",error);
    // Construct a String around the Data from the response

    return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

@end
