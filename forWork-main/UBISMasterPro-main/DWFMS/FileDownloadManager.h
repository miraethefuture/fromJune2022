//
//  FileDownloadManager.h
//  CNEWAY_IOS
//
//  Created by kim yeon kyeong on 2016. 6. 9..
//  Copyright © 2016년 cneway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "FileViewController.h"

@interface FileDownloadManager : NSObject <NSURLSessionDownloadDelegate> {
    AppDelegate *appDelegate;
    FileViewController *fileView;
    
    NSMutableData *downloadData;    // 다운로드 받는 파일 데이터
    
    NSURL *url;             // 파일 URL
    NSString *fileDir;      // 파일 저장 경로
    NSString *fileName;     // 파일명
    int fileSize;           // 파일 크기
}

- (void)initWithURL:(NSString *)paramURL;
- (BOOL)saveDownloadedFile;

@end
