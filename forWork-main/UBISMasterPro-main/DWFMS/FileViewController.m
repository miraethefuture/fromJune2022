//
//  FileViewController.m
//  CNEWAY_IOS
//
//  Created by kim yeon kyeong on 2016. 5. 26..
//  Copyright © 2016년 cneway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileViewController.h"
#import "GlobalDataManager.h"
#import "ToastAlertView.h"

@implementation FileViewController {
    NSFileManager *fileManager;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"NSLog FileViewController START!!");
    
    [self.fileView setDelegate:self];
    [self.fileView setScalesPageToFit:YES];
    
    fDir = [[GlobalDataManager getinstance] fileDir];
    fName = [[GlobalDataManager getinstance] fileName];
    fMIMEType = [self setMIMEType:fName];
    fData = [[GlobalDataManager getinstance] fileData];
    fUrl = [[GlobalDataManager getinstance] fileUrl];
    
    NSLog(@"NSLog FileViewController data %@!!%d", fMIMEType, __LINE__);
    
    // UINavigation
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"뒤로" style:UIBarButtonItemStylePlain target:self action:@selector(navBackButton)]];
    
    [ToastAlertView showToastInParentView:self.view withText:@"다운로드가 완료되었습니다." withDuaration:3.0];
    
    if([@"Unknown" isEqual:fMIMEType]) {
        NSLog(@"nofile===============================");
        NSLog(@"CNEWAY:%d | 알 수 없는 형식의 파일입니다.", __LINE__);
        return;
    }else if([@"application/zip" isEqual:fMIMEType]){
        NSLog(@"zipfile===============================");
        
        //알집파일의 경우 로드 안됨
        [ToastAlertView showToastInParentView:self.view withText:@"실행할 수 없는 형식의 파일입니다." withDuaration:3.0];
        return;
        
    } else if([@"image/*" isEqual:fMIMEType]) {
        NSLog(@"imagefile===============================");
        // 이미지
        UIImage *img = [UIImage imageWithData:fData];
        NSData *imgData = UIImagePNGRepresentation(img);
        NSString *imageSource = [NSString stringWithFormat:@"data:%@;base64,%@", fMIMEType,[self base64forData:imgData]];
        NSString *imgStr = [NSString stringWithFormat:@"<img src='%@'>", imageSource];
        [self.fileView loadHTMLString:imgStr baseURL:nil];
        
        
    } else if([@"application/haansofthwp" isEqual:fMIMEType]) {
        NSLog(@"hwpfile===============================");
        // 한글파일
        NSURL *hwpFileURL = [NSURL fileURLWithPath:[fDir stringByAppendingPathComponent:fName]];
        self.documentInteractionController = [[UIDocumentInteractionController alloc] init];
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:hwpFileURL];
        self.documentInteractionController.delegate = self;
        [self.documentInteractionController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
    }else {
        NSLog(@"elsefile===============================");
        [self.fileView loadData:fData MIMEType:fMIMEType textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
    }
}

// webView Load Error : Sent if a web view failed to load a frame.
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // Unable to Read Document - An error occurred while reading the document
    
    // error 개수만큼 토스트;
    [ToastAlertView showToastInParentView:self.view withText:@"해당 파일을 실행할 수 없습니다." withDuaration:3.0];
    NSLog(@"CNEWAY:%d | Error : %@", __LINE__, [error localizedDescription]);
}

- (void)navBackButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)setMIMEType:(NSString *)fname {
    // .xlsx : application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    // unable to read document
    
    if([fname hasSuffix:@"pdf"] || [fname hasSuffix:@"PDF"]) {
        return @"application/pdf";
    } else if([fname hasSuffix:@"txt"] || [fname hasSuffix:@"TXT"] ||
              [fname hasSuffix:@"html"] || [fname hasSuffix:@"HTML"]) {
        return @"text/plain";
    } else if([fname hasSuffix:@"xml"] || [fname hasSuffix:@"XML"]) {
        return @"text/xml";
    } else if([fname hasSuffix:@"xls"] || [fname hasSuffix:@"XLS"]) {
        return @"application/vnd.ms-excel";
    } else if([fname hasSuffix:@"doc"] || [fname hasSuffix:@"DOC"]) {
        return @"application/msword";
    } else if([fname hasSuffix:@"ppt"] || [fname hasSuffix:@"PPT"]) {
        return @"application/vnd.ms-powerpoint";
    } else if([fname hasSuffix:@"xlsx"] || [fname hasSuffix:@"XLSX"]) {
        return @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    } else if([fname hasSuffix:@"docx"] || [fname hasSuffix:@"DOCX"]) {
        return @"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
    } else if([fname hasSuffix:@"pptx"] || [fname hasSuffix:@"PPTX"]) {
        return @"application/vnd.openxmlformats-officedocument.presentationml.presentation";
    } else if([fname hasSuffix:@"jpg"] || [fname hasSuffix:@"JPG"] ||
              [fname hasSuffix:@"jpeg"] || [fname hasSuffix:@"JPEG"] ||
              [fname hasSuffix:@"gif"] || [fname hasSuffix:@"GIF"] ||
              [fname hasSuffix:@"png"] || [fname hasSuffix:@"PNG"] ||
              [fname hasSuffix:@"bmp"] || [fname hasSuffix:@"BMP"]) {
        return @"image/*";
    } else if([fname hasSuffix:@"mp3"] || [fname hasSuffix:@"MP3"] ||
              [fname hasSuffix:@"wav"] || [fname hasSuffix:@"WAV"]) {
        return @"audio/*";
    } else if([fname hasSuffix:@"mp4"] || [fname hasSuffix:@"MP4"] ||
              [fname hasSuffix:@"mpeg"] || [fname hasSuffix:@"MPEG"] ||
              [fname hasSuffix:@"avi"] || [fname hasSuffix:@"AVI"]) {
        return @"video/*";
    } else if([fname hasSuffix:@"hwp"] || [fname hasSuffix:@"HWP"]) {
        return @"application/haansofthwp";
    } else if([fname hasSuffix:@"zip"] || [fname hasSuffix:@"ZIP"]) {
        return @"application/zip";
    } else {
        return @"Unknown";
    }
}

- (NSString *)base64forData:(NSData *)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for(i=0 ; i<length ; i+=3) {
        NSInteger value = 0;
        NSInteger j;
        for(j=i ; j<(i+3) ; j++) {
            value <<= 8;
            if (j<length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void)unZipDownloadedFile:(NSString *)zipDir {
    
}

- (void)getFileList:(NSString *)path {
    NSError *error;
    NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:path error:&error];
    BOOL isDirectory;
    
    for(int i=0 ; i<[fileArray count] ; i++) {
        if([fileManager fileExistsAtPath:[path stringByAppendingPathComponent:[fileArray objectAtIndex:i]] isDirectory:&isDirectory]) {
            if(isDirectory) {
                NSLog(@"directory : %@", [fileArray objectAtIndex:i]);
                [self getFileList:[path stringByAppendingPathComponent:[fileArray objectAtIndex:i]]];
            } else {
                NSLog(@"\t- %@, %llu", [fileArray objectAtIndex:i], [[fileManager attributesOfItemAtPath:[path stringByAppendingString:[fileArray objectAtIndex:i]] error:&error] fileSize]);
            }
        }
    }
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
