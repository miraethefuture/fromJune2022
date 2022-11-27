//
//  FileDownloadManager.m
//  CNEWAY_IOS
//
//  Created by kim yeon kyeong on 2016. 6. 9..
//  Copyright © 2016년 cneway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDownloadManager.h"
#import "GlobalDataManager.h"
#import "ToastAlertView.h"

@implementation FileDownloadManager {
    NSURLSessionConfiguration *configration;
    NSURLSession *session;
    NSURLSessionDownloadTask *downloadSession;
}

/*
 * Documents : 사용자가 생성한 데이터로 iCloud 자동 백업 대상
 * Library/Caches : 앱에서 재생성, 재다운로드 가능한 데이터
 * tmp : 임시 데이터
 * Documents/(Dir)에 백업 제외 옵션 또는 Library/Chches/(Dir)에 저장
 */

// The NSURLDownload class is not available in iOS, because downloading directly to the file system is discouraged.
// Use the NSURLSession or NSURLConnection class instead. See Using NSURLSession and Using NSURLConnection for more information.
- (void)initWithURL:(NSString *)paramURL {
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    fileView = [[FileViewController alloc] init];
    
    NSArray *fileData = [paramURL componentsSeparatedByString:@"/"];
    fileName = [fileData objectAtIndex:([fileData count]-1)];
    
    NSString *tempName = [fileName stringByAddingPercentEscapesUsingEncoding:-2147481280];
    
    url = [NSURL URLWithString:[paramURL stringByReplacingOccurrencesOfString:[fileData objectAtIndex:([fileData count]-1)] withString:tempName]];
    
    configration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:fileName];
    session = [NSURLSession sessionWithConfiguration:configration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    downloadSession = [session downloadTaskWithURL:url];
    [downloadSession resume];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"FileDownliadManagerStart====================================// param : %@ // tempName : %@ // url : %@",fileData, tempName, url);
}

// Tells the delegate that the task finished transferring data.
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(error) {
        [downloadSession cancel];
        downloadSession = NULL;
        
        NSLog(@"UBISMaster:%d | downloadTask didCompleteWithError : %@", __LINE__, error);
        NSLog(@"UBISMaster:%d | %@", __LINE__, [error localizedDescription]);
    }
}

// Tells the delegate that the download task has resumed downloading.
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"UBISMaster:%d | downloadTask Resumed at offset %lld", __LINE__, fileOffset);
}

// Periodically informs the delegate about the download’s progress.
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    int downloadSize = (int)(totalBytesWritten*100/totalBytesExpectedToWrite);
    NSLog(@"UBISMaster:%d | [%@] downloading......%d%%", __LINE__, fileName, downloadSize);
}

// Tells the delegate that a download task has finished downloading. : Required
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)[downloadTask response];
    int statusCode = (int)[response statusCode];
    if(statusCode != 200) {
        [downloadSession cancel];
        downloadSession = NULL;
        
        NSLog(@"---------------------- UBISMaster | 1.File Info ----------------------");
        NSLog(@"UBISMaster:%d | File Download Fail", __LINE__);
        NSLog(@"UBISMaster:%d | URL : %@", __LINE__, url);
        NSLog(@"UBISMaster:%d | Error Code : %d", __LINE__, statusCode);
        NSLog(@"----------------------------------------------------------------");
        
        //  상태바 안테나 옆 로딩 아이콘
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        [notification setTimeZone:[NSTimeZone defaultTimeZone]];
        [notification setAlertTitle:fileName];
        [notification setAlertBody:@"다운로드에 실패하였습니다."];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        
        return;
    }
    
    downloadData = [NSMutableData dataWithContentsOfURL:location];
    fileSize = (int)[response expectedContentLength];
    
    UIImage *downloadImage = [UIImage imageWithData:downloadData];
    if(downloadImage != nil) {
        // 다운로드 받은 데이터가 이미지일 경우
        UIImageWriteToSavedPhotosAlbum(downloadImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        NSLog(@"NSLog 첫번째1.........");
        // open file
        
        [[GlobalDataManager getinstance] setFileDir:@"CameraRoll"];
        [[GlobalDataManager getinstance] setFileName:fileName];
        [[GlobalDataManager getinstance] setFileData:downloadData];
        [[GlobalDataManager getinstance] setFileUrl:url];
//        NSLog(@"파라메터값확인 ///////////  ================ %@  ============ %@",fileName, downloadData);
        NSLog(@"NSLog 두번째1.........");
    } else {
        NSLog(@"NSLog 첫번째2.........");
        // 다운로드 받은 데이터가 이미지가 아닐 경우
        
        // save
        BOOL downloadFlag = [self saveDownloadedFile];
        if(downloadFlag) {
            NSLog(@"---------------------- UBISMaster | 2.File Info ----------------------");
            NSLog(@"UBISMaster:%d | File Download Success", __LINE__);
            NSLog(@"UBISMaster:%d | URL : %@", __LINE__, url);
            NSLog(@"UBISMaster:%d | Directory : %@", __LINE__, fileDir);
            NSLog(@"UBISMaster:%d | Name : %@", __LINE__, fileName);
            NSLog(@"UBISMaster:%d | Size : %d bytes", __LINE__, fileSize);
            NSLog(@"----------------------------------------------------------------");
        }
//        NSLog(@"파라메터값확인 ///////////  ================ %@  ============ %@",fileName, downloadData);
        NSLog(@"NSLog 두번째2.........");
        // open file
        [[GlobalDataManager getinstance] setFileDir:fileDir];
        [[GlobalDataManager getinstance] setFileName:fileName];
        [[GlobalDataManager getinstance] setFileData:downloadData];
        [[GlobalDataManager getinstance] setFileUrl:url];
        NSLog(@"NSLog 세번째3.........");
    }
    NSLog(@"NSLog 다시한번.........");
    // 상태바 안테나 옆 로딩 아이콘
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSDictionary *notiInfo = [NSDictionary dictionaryWithObject:@"download success" forKey:@"status"];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
    [notification setAlertTitle:fileName];
    [notification setAlertBody:@"다운로드를 완료하였습니다."];
    [notification setUserInfo:notiInfo];
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    NSLog(@"NSLog 다시한번222222.........");
    
    //2017.02.01 수정진행중
    //    [ViewController.webView performSegueWithIdentifier:@"FileViewer" sender:self];
//    NSLog(@"NSLog !!!!!!!!!!!!!! %@", appDelegate.main);
//    ViewController *viewController = (ViewController*)appDelegate.webview.inputViewController;
    [appDelegate.main performSegueWithIdentifier:@"FileViewer" sender:self];
    
    NSLog(@"NSLog 다시한번333333.........");
}

- (BOOL)saveDownloadedFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *subPath = @"/ubismaster";
    fileDir = [[path objectAtIndex:0] stringByAppendingPathComponent:subPath];
    
    BOOL isDir;
    if(![fileManager fileExistsAtPath:fileDir isDirectory:&isDir]) {
        if([fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"UBISMaster:%d | Make Directory", __LINE__);
        } else {
            NSLog(@"UBISMaster:%d | FAIL - Make Directory", __LINE__);
            NSLog(@"UBISMaster:%d | %@", __LINE__, [error localizedDescription]);
            return NO;
        }
    }
    
    NSString *savePath = [fileDir stringByAppendingPathComponent:fileName];
    if([downloadData writeToFile:savePath atomically:YES]) {
        NSLog(@"UBISMaster:%d | Save %@ at Directory", __LINE__, fileName);
    } else {
        NSLog(@"UBISMaster:%d | FAIL - Make %@ at Directory", __LINE__, fileName);
        NSLog(@"UBISMaster:%d | %@", __LINE__, [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

// 이미지 저장 결과
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo {
    if (error) {
        NSLog(@"UBISMaster:%d | FAIL - SAVE Image", __LINE__);
        NSLog(@"UBISMaster:%d | %@", __LINE__, [error localizedDescription]);
    } else {
        NSLog(@"UBISMaster:%d | Save %@ at Camera Roll", __LINE__, fileName);
    }
}


@end