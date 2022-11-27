//
//  FileViewController.h
//  CNEWAY_IOS
//
//  Created by kim yeon kyeong on 2016. 5. 26..
//  Copyright © 2016년 cneway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileViewController : UIViewController <UIWebViewDelegate, UIImagePickerControllerDelegate, UIDocumentInteractionControllerDelegate> {
    NSMutableData *fData;
    NSString *fDir;
    NSString *fName;
    NSString *fMIMEType;
    NSURL *fUrl;
}

- (void)navBackButton;
- (NSString *)setMIMEType:(NSString *)fname;
- (NSString *)base64forData:(NSData *)theData;
- (void)unZipDownloadedFile:(NSString *)zipDir;
- (void)getFileList:(NSString *)path;

@property (strong, nonatomic) IBOutlet UIWebView *fileView;
@property (strong, nonatomic) UINavigationController *navigation;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, readonly) __kindof UIViewController *fileViewController;


@end
