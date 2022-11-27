//
//  CameraViewController.h
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 26..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import <UIKit/UIKit.h>
// S : 헤더 파일 테스트 중... (2022.11.03 Jung Mirae)
//#import "DWFMS-Swift.h"
// E : 헤더 파일 테스트 중... (2022.11.03 Jung Mirae)

//@interface CameraViewController : UIViewController<UIActionSheetDelegate,UINavigOBjCModuleollerDelegate, UIImagePickerControllerDelegate>{
// 2017.05.18 NUURLSessionDeledate 정의 추가

@interface CameraViewController : UIViewController<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLSessionDelegate> {
    IBOutlet UIImageView *imageView;
    NSString * filepath;
    NSString * num;
    BOOL getImage;
    NSString *makeFilename;
}

@end

// S : 사진 다중 선택 적용 관련 - (2022.11.07 Jung Mirae)
@interface OBjCModule : NSObject
- (void)selectMultiImages;
@end
// E : 사진 다중 선택 적용 관련 - (2022.11.07 Jung Mirae)
