//
//  NfcReader.m
//  DWFMS
//
//  Created by Park Jonh Hoon on 2019/11/21.
//  Copyright © 2019 DWFMS. All rights reserved.
//

#import "NfcReaderController.h"

@import CoreNFC;

@interface NfcReaderController () <NFCNDEFReaderSessionDelegate>

@property (nonatomic, strong)   NFCNDEFReaderSession *session;
@property (nonatomic, strong)   NFCNDEFReaderSession *alert;

@property (nonatomic, weak)     IBOutlet UIButton *scanButton;
@property (nonatomic, weak)     IBOutlet UITextView *logView;
@property (nonatomic, weak)     IBOutlet UIButton *close;

@end

@implementation NfcReaderController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scanButton.layer.cornerRadius = 4.f;
    _scanButton.layer.borderWidth  = 1.f;
    _scanButton.layer.borderColor  =        _scanButton.currentTitleColor.CGColor;
    
    
    _close.layer.cornerRadius = 4.f;
    _close.layer.borderWidth  = 1.f;
    _close.layer.borderColor  =        _close.currentTitleColor.CGColor;
    
    [self beginSession];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [_session invalidateSession];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - NFCNDEFReaderSessionDelegate

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error
{
    NSLog(@"Error: %@", [error debugDescription]);
    
    if (error.code == NFCReaderSessionInvalidationErrorUserCanceled) {
        // User cancellation.
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _logView.text = [NSString stringWithFormat:@"[%@] Error: %@ (%ld)\n%@",
                         [NSDate date],
                         [error localizedDescription],
                         error.code,
                         _logView.text];
    });
}

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didDetectNDEFs:(nonnull NSArray<NFCNDEFMessage *> *)messages
{
    for (NFCNDEFMessage *message in messages) {
        for (NFCNDEFPayload *payload in message.records) {
            NSLog(@"Payload: %@", payload);
            const NSDate *date = [NSDate date];
            dispatch_async(dispatch_get_main_queue(), ^{
                _logView.text = [NSString stringWithFormat:
                                 @"[%@] Identifier: %@ (%@)\n"
                                 @"[%@] Type: %@ (%@)\n"
                                 @"[%@] Format: %d\n"
                                 @"[%@] Payload: %@ (%@)\n%@",
                                 date,
                                 payload.identifier,
                                 [[NSString alloc] initWithData:payload.identifier
                                                       encoding:NSASCIIStringEncoding],
                                 date,
                                 payload.type,
                                 [[NSString alloc] initWithData:payload.type
                                                       encoding:NSASCIIStringEncoding],
                                 date,
                                 payload.typeNameFormat,
                                 date,
                                 payload.payload,
                                 [[NSString alloc] initWithData:payload.payload
                                                       encoding:NSASCIIStringEncoding],
                                 _logView.text];
            });
        }
    }
}

#pragma mark - Methods

- (void)beginSession
{
    _session
    = [[NFCNDEFReaderSession alloc] initWithDelegate:self
                                               queue:dispatch_queue_create(NULL,
                                                                           DISPATCH_QUEUE_CONCURRENT)
                            invalidateAfterFirstRead:NO];
    [_session beginSession];
}

#pragma mark - IBActions

- (IBAction)scan:(id)sender
{
    [self beginSession];
}

- (IBAction)clear:(id)sender
{
    _logView.text = @"";
}

- (IBAction)close:(id)sender {
    NSLog(@"메인화면으로 이동");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
