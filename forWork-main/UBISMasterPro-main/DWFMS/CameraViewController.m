//
//  CameraViewController.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 26..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "CameraViewController.h"
#import "AppDelegate.h"
#import "GlobalData.h"
#import "GlobalDataManager.h"
#import "DWFMS-Swift.h" // 이미지 다중 선택 기능 구현 - Swift 파일 연결 (2022.11.03 Jung Mirae)

// S: 사진 다중 선택 기능 추가 중... Swift 함수 사용할 수 있는지 확인(2022.11.17 Jung Mirae)
//@class PickerController;
//@implementation OBjCModule : NSObject
//-(void)selectMultiImages {
//    if (@available(iOS 14, *)) {
//        PickerController *pickerController = [[PickerController alloc] init];
//        [pickerController picker];
//    } else {
//        // Fallback on earlier versions
//    }
//}
//@end
// E: 사진 다중 선택 기능 추가 중... Swift 함수 사용할 수 있는지 확인(2022.11.17 Jung Mirae)

@implementation CameraViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"??callcamera1");
    NSMutableDictionary * cData =  [[GlobalDataManager getgData] cameraData] ;
    
    makeFilename =[NSString stringWithFormat:@"%@_%@.jpg",[cData valueForKey:@"key"],[cData valueForKey:@"num"]];
    
    NSString * searchWord = @"-";
    NSString * replaceWord = @"";
    makeFilename =  [makeFilename stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    searchWord = @":";
    replaceWord = @"";
    makeFilename =  [makeFilename stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    searchWord = @" ";
    replaceWord = @"";
    makeFilename =  [makeFilename stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    searchWord = @"'";
    replaceWord = @"";
    makeFilename =  [makeFilename stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    
    NSLog(@"filename %@",makeFilename);
//    filepath = [NSString stringWithFormat:@"resources/App_Company/%@/%@.jpg",[[GlobalDataManager getgData] compCd],[cData valueForKey:@"type"],filename];
     filepath = [NSString stringWithFormat:@"resources/App_Company/%@/%@/",[[GlobalDataManager getgData] compCd],[cData valueForKey:@"type"]];
     num = [cData valueForKey:@"num"];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@" 00 %@ ",(getImage ? @"YES" : @"NO"));
    if(!getImage){
    
        self.open; // 액션 시트 올라오는...
        NSLog(@"num in CV: %@", num);
    
    }
    //2017년 2월 27일 Choi Yu Bin 추가
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-  (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) open
{
    getImage = NO;
    
    //2017년 2월 27일 Choi Yu Bin 추가
    /**************************************************/
//    UIImagePickerController *imagepickerController = [[UIImagePickerController alloc] init];
//    [imagepickerController setDelegate:self];
//    [imagepickerController setAllowsEditing:YES];
//    //카메라 자동 호출
//    [imagepickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
//    //2017.05.18 deprecated in IOS 6.0
//    //[self presentModalViewController:imagepickerController animated:YES];
//    [self presentViewController:imagepickerController animated:YES completion:nil];
    /**************************************************/
    
    //2017년 2월 27일 Choi Yu Bin 주석
    /**************************************************/
    UIActionSheet *actionsheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"취소"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"사진 촬영", @"앨범에서 가져오기", nil];
    
    [actionsheet showInView:self.view];
    /**************************************************/
    
}
#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // S : 주석처리 (임시) - (2022.11.03 Jung Mirae)
    UIImagePickerController *imagepickerController = [[UIImagePickerController alloc] init];
    [imagepickerController setDelegate:self];
    [imagepickerController setAllowsEditing:YES];
    // E : 주석처리 (임시) - (2022.11.03 Jung Mirae)
    NSLog(@" 11 %@ ",(getImage ? @"YES" : @"NO"));
    if(!getImage){
        if(buttonIndex == 0){
            
            [imagepickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
            //2017.05.18 deprecated in IOS 6.0
            //[self presentModalViewController:imagepickerController animated:YES];
            [self presentViewController:imagepickerController animated:YES completion:nil];
            NSLog(@"num in button 0: %@", num);

        }
        else if(buttonIndex == 1){
            
            // S : 다중 이미지 선택 기능 추가 중 (2022.11.09 Jung Mirae)

            PickerController *pc = [[PickerController alloc] init]; // 살릴 코드

            [self presentViewController: pc animated: YES completion: nil]; // 살릴 코드
            

        
        }else{
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
 
    }
    else{
        
        if(buttonIndex == 0){
            
            UIImageWriteToSavedPhotosAlbum([imageView image], self, @selector(saveImage:didFinishedSavingWhithError:contextInfo:),nil);
            
            NSLog(@"?? save??? ");
          
            
        }
        [self fileUp];
    }
    
}

#pragma mark UIImagePickerContoller Delegate
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    imageView.image = image;
    float hi =  image.size.height;
    float wh = image.size.width;
    
    NSLog(@"?? hi %f  wh %f ",hi,wh);
    NSData *dataObj = UIImageJPEGRepresentation(image, 0.3);
    
    NSLog(@"?? size? %d ",dataObj.length);
    NSLog(@" 22 %@ ",(getImage ? @"YES" : @"NO"));
    
    //2017.05.18 deprecated in IOS 6.0
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    if(!getImage){
        getImage = YES;
         NSLog(@" 33 %@ ",(getImage ? @"YES" : @"NO"));
        
        
        /*****2017년 2월 27일 Choi Yu Bin 추가****************/
        [self fileUp];
        /**************************************************/
        /*******2017년 2월 27일 Choi Yu Bin 주석처리***********
         UIActionSheet *isSave = [[UIActionSheet alloc]
         initWithTitle:nil
         delegate:self
         cancelButtonTitle:@"저장 안함"
         destructiveButtonTitle:nil
         otherButtonTitles:@"사진 저장", nil];
         [isSave showInView:self.view];
         **************************************************/
    }
    else{
        [self fileUp];
    }
    
}

-(void) saveImage:(UIImage*) image didFinishedSavingWhithError:(NSError*) error contextInfo:(void *) contextInfo
{
    if(error){
        NSLog(@" image save error!!!!");
    }else{
        NSLog(@" image save!!!!");
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[picker dismissModalViewControllerAnimated:YES]; //2017년 2월 27일 Choi Yu Bin 주석처리
    
    //****2017년 2월 27일 Choi Yu Bin 추가*****
    NSLog(@" ~~~~~~~~~~~  image call cancel   !!!!");
    //[picker dismissModalViewControllerAnimated:NO];
    //[self dismissModalViewControllerAnimated:NO];
    //[self dismissViewControllerAnimated:YES completion:nil];
    getImage = YES;
    //S : 앨범 FullScreen변경으로 인한 수정(2019년 10월 18일 Park Jin Su)
    //[picker dismissViewControllerAnimated:NO completion:nil];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    //E : 앨범 FullScreen변경으로 인한 수정(2019년 10월 18일 Park Jin Su)
    //****2017년 2월 27일 Choi Yu Bin 추가*****
}

-(void) fileUp {
    
    NSLog(@"???filepath %@ " ,filepath);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30.0f];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"YAGOM_Boundary";
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSString *senders = @"yagom";
    NSString *receiver = @"prettyWoman";
    
    NSDictionary *params = @{@"sender": senders, @"receiver" : receiver};
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    //UIImage *imageToUpload = [UIImage imageNamed:@"/Library/Desktop Pictures/Moon.jpg"];
    NSData *imageData = UIImageJPEGRepresentation([imageView image], 0.3);
    
    NSLog(@"image length : %lu",(unsigned long)[imageData length]);
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imageToLove\"; filename=\"%@\"\r\n", makeFilename]dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    
    // S: ServerIp -> server로 변경 (2022.11.10 Jung Mirae)
    NSString *server = [GlobalData getServerIp]; // 추가
    
    //NSString *makeUrl = [NSString stringWithFormat:@"%@/resources/filedown.jsp?path=%@",ServerIp, filepath];
    NSString *makeUrl = [NSString stringWithFormat:@"%@/resources/filedown.jsp?path=%@",server, filepath];
    // E: ServerIp -> server로 변경 (2022.11.10 Jung Mirae)
    
    NSLog(@"make url = %@",makeUrl);
    [request setURL:[NSURL URLWithString:makeUrl]];
                     //@"http://211.253.9.3:8080/resources/filedown.jsp"]];
    
    NSLog(@"request = %@", request);
    
    // start upload
    // 2017.04.27 Choi Yu Bin NSURLConeeciont 주석
    
    //요부분 추가함~~~~~~
    //NSURLRequest *Urlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", request.URL]]];
    //NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    //[connection start];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask * uploadTask = [defaultSession dataTaskWithRequest:
                                         request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if((error == nil)&&[(NSHTTPURLResponse *)response statusCode] == 200){
            NSLog(@"Response[정상업로드]:%@\n", data);
            
            NSLog(@"dd %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            AppDelegate * ad =  [[UIApplication sharedApplication] delegate] ;
            [[ad main]setimage:[NSString stringWithFormat:@"%@%@",filepath,makeFilename] num:num];
            
            PickerController *pc = [[PickerController alloc] init];
            pc.imgCnt = 1;
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
            
        } else {
            NSLog(@"Response[업로드 Fail]:%@\n", error);
        }
    }];
    [uploadTask resume];
    // 요기까지 추가함....
}

//S : 2018년 2월 6일 Park Jong Hoon 주석처리(위에 변경을 통한 미사용처리)
//// connection 실행되는동안 실행되는 메소드 (현재는 file upload되는 %를 log에 출력하는 소스 적용중)
//- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
//    NSLog(@"%.2f Percent complete", (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite * 100.0f);
//}
//
//// connection 실행을 맞치고 aalert 메지시장 출력
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSLog(@"dd %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//     AppDelegate * ad =  [[UIApplication sharedApplication] delegate] ;
//    [[ad main]setimage:[NSString stringWithFormat:@"%@%@",filepath,makeFilename] num:num];
//     [self dismissViewControllerAnimated:YES completion:nil];
//}
//E : 2018년 2월 6일 Park Jong Hoon 주석처리(위에 변경을 통한 미사용처리)

@end
