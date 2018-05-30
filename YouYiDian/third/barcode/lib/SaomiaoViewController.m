//
//  SaomiaoViewController.m
//  DouYU
//
//  Created by SiYugui on 16/4/25.
//  Copyright © 2016年 Alesary. All rights reserved.
//

#import "SaomiaoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SaomiaoViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>
{
    BOOL isFirst;
}
@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * preview;
@property ( strong , nonatomic )CALayer *scanLayer;
@property ( strong , nonatomic )UIView* boxView;
@end

@implementation SaomiaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUp];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUp
{
    isFirst = YES;
    
    NSError *error;
    
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.用captureDevice创建输入流
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (!_input) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    //3.创建媒体数据输出流
    _output = [[AVCaptureMetadataOutput alloc] init];
    
    //4.实例化捕捉会话
    _session = [[AVCaptureSession alloc] init];
    
    //4.1.将输入流添加到会话
    [_session addInput:_input];
    
    //4.2.将媒体输出流添加到会话中
    [_session addOutput:_output];

    //5.设置输出媒体数据类型为QRCode
    [_output setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    /***IOS7支持Type
     @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeFace,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode39Code];
     **/

    //5.创建串行队列，并加媒体输出流添加到队列当中
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //6.实例化预览图层
    _preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    
    //7.设置预览图层填充方式
    [_preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //8.设置图层的frame
    [_preview setFrame:self.view.layer.bounds];
    
    //9.将图层添加到预览view的图层上
    //[self.view.layer addSublayer:_preview];
    [self.view.layer insertSublayer:_preview atIndex : 0];
    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    float width =rx.size.width;
    float height =rx.size.height;
    
    //10.设置扫描范围
    [ _output setRectOfInterest : CGRectMake (( 124 )/ height ,(( width - 180 )/ 2 )/ width , 220 / height , 220 / width )];
     //10.1.扫描框
    _boxView = [[UIView alloc] initWithFrame:CGRectMake (( width - 220 )/ 2 , 20+60 + 64 , 220 , 220 )];
    _boxView.layer.borderColor = [UIColor greenColor].CGColor;
    _boxView.layer.borderWidth = 3.0f;
    
    [self.view addSubview:_boxView];
    
    //10扫描线
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.bounds.size.width, 1);
    _scanLayer.backgroundColor = [UIColor redColor].CGColor;
    
    [_boxView.layer addSublayer:_scanLayer];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    
    [timer fire];
    
    //10.1设定扫描背景
    [self setPreviewBackground];
    
    //11定义提示语
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, _boxView.frame.origin.y+220+10, width, 44)];
    [lab setTextColor:[UIColor blackColor]];
    [lab setText:@"将二维码放入框内,即可自动扫描"];
    lab.backgroundColor = [UIColor clearColor];
    lab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lab];
    
    
    //12.开始扫描
    [_session startRunning];
    

}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- ( void )captureOutput:( AVCaptureOutput *)captureOutput didOutputMetadataObjects:( NSArray *)metadataObjects fromConnection:( AVCaptureConnection *)connection
{
    if(isFirst){
        NSMutableArray *arr = [NSMutableArray arrayWithArray:metadataObjects];
        
        if (arr != nil && [arr count] > 0) {
            AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
            NSString *result;
            if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
                result = metadataObj.stringValue;
            } else {
                result=@"不是二维码";
            }
            [arr removeAllObjects];
            isFirst = NO;
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alertView.delegate =self;
            [alertView show];

        }
    }

}
#pragma mark 扫描线移动
- (void)moveScanLayer:(NSTimer *)timer
{
    CGRect frame = _scanLayer.frame;
    if (_boxView.frame.size.height < _scanLayer.frame.origin.y+10) {
        frame.origin.y = 0;
        _scanLayer.frame = frame;
    }else{
        
        frame.origin.y += 10;
        
        [UIView animateWithDuration:0.1 animations:^{
            _scanLayer.frame = frame;
        }];
    }
}
#pragma mark alertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            isFirst = YES;
            break;
        default:
            break;
    }
}
#pragma mark 设置除扫描框以外背景
- (void)setPreviewBackground{

    CALayer *coverLayer = [[CALayer alloc] init];
    coverLayer.frame = _preview.bounds;
    coverLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor;
    [self.preview addSublayer:coverLayer];
    
    UIBezierPath *outerBorderPath = [UIBezierPath bezierPathWithRect:_preview.bounds];
    
    UIBezierPath *innderBorderPath = [UIBezierPath bezierPathWithRect:_boxView.frame];
    
    [outerBorderPath appendPath:innderBorderPath];
    
    CAShapeLayer *visibleRectLayer = [CAShapeLayer layer];
    
    visibleRectLayer.fillRule = kCAFillRuleEvenOdd;
    
    visibleRectLayer.path = outerBorderPath.CGPath;
    
    coverLayer.mask = visibleRectLayer;
}
@end
