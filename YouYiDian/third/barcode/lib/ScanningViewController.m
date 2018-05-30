//
//  ScanningViewController.m
//  CXScanning
//
//  Created by artifeng on 16/1/7.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "ScanningViewController.h"
#define Height [UIScreen mainScreen].bounds.size.height
#define Width [UIScreen mainScreen].bounds.size.width
#define XCenter (Width/2)
#define YCenter (Height/2)

#define SHeight 20

#define SWidth (XCenter+30)
#define ScanBorder 220

@interface ScanningViewController ()
{
    UIImageView * imageView;
}
@end

@implementation ScanningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
     self.view.backgroundColor = [UIColor whiteColor];
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,220,220)];
    imageView.center = CGPointMake(Width/2, Height/2);
    imageView.image = [UIImage imageNamed:@"scanscanBg.png"];
    [self.view addSubview:imageView];
    
    Isup = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(imageView.frame)+5, CGRectGetMinY(imageView.frame)+5, SWidth-10,4)];
    _line.image = [UIImage imageNamed:@"scanLine@2x.png"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
     [self setupCamera];
    self.view.userInteractionEnabled = true;
}
-(void)viewDidAppear:(BOOL)animated{
    
}
-(void)viewWillDisappear:(BOOL)animated
{
   
}
-(void)animation
{
    if (Isup == NO) {
        num ++;
        _line.frame = CGRectMake(CGRectGetMinX(imageView.frame), CGRectGetMinY(imageView.frame)+5+2*num, ScanBorder,4);
       
        if (num ==(int)(( ScanBorder-10)/2)) {
            Isup = YES;
        }
    }else{
        num --;
        _line.frame =CGRectMake(CGRectGetMinX(imageView.frame), CGRectGetMinY(imageView.frame)+5+2*num, ScanBorder,4);
        
        if (num == 0) {
            Isup = NO;
        }
    }
}


- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    _output.rectOfInterest =[self rectOfInterestByScanViewRect:imageView.frame];
    
    // Session
    
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResize;
    _preview.frame =CGRectMake(0, 0, Width, Height);
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    //扫描线,放在最上层
    [self.view bringSubviewToFront:imageView];

    [self setOverView];
    
    // Start
    [_session startRunning];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        /**
         *  获取扫描结果
         */
        stringValue = metadataObject.stringValue;
    }
    if (self.delegate) {
        [self.delegate GetScanResult:stringValue];
    }
    [_session stopRunning];
    [self closeself:false];
}

- (CGRect)rectOfInterestByScanViewRect:(CGRect)rect {
    CGFloat width = Width;
    CGFloat height = Height;
    
    CGFloat x = (height - CGRectGetHeight(rect)) / 2.0 / height;
    CGFloat y = (width - CGRectGetWidth(rect)) / 2.0 / width;
    
    CGFloat w = CGRectGetHeight(rect) / height;
    CGFloat h = CGRectGetWidth(rect) / width;
   
    //(top left width height)---默认(0,0,1,1)
    return CGRectMake(x, y, w, h);
}

#pragma mark - 添加模糊效果
- (void)setOverView {

//    self.view.maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Width, Height)];
    CGFloat x = CGRectGetMinX(imageView.frame);
    CGFloat y = CGRectGetMinY(imageView.frame);
    CGFloat w = CGRectGetWidth(imageView.frame);
    CGFloat h = CGRectGetHeight(imageView.frame);
    
    [self creatView:CGRectMake(0, 0, Width, y)];//上
    [self creatView:CGRectMake(0, y, x, h)];//左
    [self creatView:CGRectMake(0, y + h, Width, Height/2 -  h/2)];//下
    [self creatView:CGRectMake(x + w, y, Width - x - w, h)];//右
}

- (void)creatView:(CGRect)rect {
    CGFloat alpha = 0.7;
    UIColor *backColor = [UIColor grayColor];
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = backColor;
    view.alpha = alpha;
    [self addMaskView:view];
}
-(void)addMaskView:(UIView*)View{
    [self.view addSubview:View];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeself:(BOOL)bWrite
{
    if(timer){
        [timer invalidate];
        timer = nil;
    }
    [self dismissViewControllerAnimated:true completion:^{
        if(self.delegate){
            [self.delegate BarcodeViewDidClosed:bWrite];
        }
    }];
}
-(void)clickLight{
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if (_device.torchMode == AVCaptureTorchModeOff) {
            [_device setTorchMode:AVCaptureTorchModeOn];
        }else{
            [_device setTorchMode:AVCaptureTorchModeOff];
        }
        [_device unlockForConfiguration];
    }
}
@end
