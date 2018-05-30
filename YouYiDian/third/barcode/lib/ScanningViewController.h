//
//  ScanningViewController.h
//  CXScanning
//
//  Created by artifeng on 16/1/7.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ScanDelegate <NSObject>
@optional
-(void)GetScanResult:(NSString*)strRet;
-(void)BarcodeViewDidClosed:(BOOL)bWrite;
@end
@interface ScanningViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL Isup;
    NSTimer * timer;

}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, retain) UIImageView * line;
@property (weak,nonatomic)id<ScanDelegate>  delegate;
-(void)closeself:(BOOL)bWrite;
-(void)addMaskView:(UIView*)View;
-(void)clickLight;
@end
