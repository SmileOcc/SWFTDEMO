//
//  OKZBarView.m
//  AFNetworking
//
//  Created by Mac on 2017/8/26.
//

#import "OKZBarView.h"
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "ZFFrameDefiner.h"
//#import "UIView+OKExtension.h"
//#import "OkdeerCommDefine.h"

/**
 *  扫描区域的宽度,高度
 */
#define scanWidth                   242
#define scanHeight                  scanWidth
#define UIColorFromHexA(hexValue,a) ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >> 8))/255.0 blue:((float)(hexValue & 0x0000FF))/255.0 alpha:(a)])
@interface OKZBarView()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureDevice            *device;
@property (nonatomic, strong) AVCaptureDeviceInput       *input;
@property (nonatomic, strong) AVCaptureMetadataOutput    *output;
@property (nonatomic, strong) AVCaptureSession           *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, weak  ) UIViewController           *currViewController;
@property (nonatomic, strong) UIView                     *customContentView;
@property (nonatomic, strong) UIImageView                *scanRectangle;
@property (nonatomic, strong) UIImageView                *line;
@property (nonatomic, strong) UIView                     *upView;
@property (nonatomic, strong) UIView                     *leftView;
@property (nonatomic, strong) UIView                     *rightView;
@property (nonatomic, strong) UIView                     *downView;
@property (nonatomic, strong) UILabel                    *topTipLabel;
@property (nonatomic, strong) UIButton                   *bottomTipBtn;
@property (nonatomic, strong) NSTimer                    *scanTimer;
@property (nonatomic, strong) UIActivityIndicatorView    *indicatorView;
@property (nonatomic, strong) UIAlertView                *scanErrorTipAlertView;
@property (nonatomic, copy)void(^resultBlock)(BOOL ret, NSString *scanCodeType, NSString *result);//扫描完成回调
@property (nonatomic, assign) BOOL                       delayPatchScanResult;//是否回调了扫码结果
@property (nonatomic, strong) NSTimer                    *delayTimer;
@property (nonatomic, strong) UIButton                   *flashButton;             /**< 闪光灯按钮*/
@property (nonatomic, strong) UILabel                    *flashLabel;              /**< 闪光灯提示语*/
@property (nonatomic, assign) CGFloat                    height;                   /**< 高度*/
@property (nonatomic, assign) BOOL                       lastIsFlashWhenStop;      /** 上一次停止扫描时是否为打开的闪光灯 */
@property (nonatomic, copy)  void (^bottomBtnClickBlock)(void); //底部按钮事件
@end

@implementation OKZBarView{
    int num;
    BOOL upOrdown;
}
+ (instancetype)openZbarView:(UIViewController *)viewcomtroller
                   startScan:(BOOL)startScan
                      height:(CGFloat)height
             completionBlock:(void(^)(BOOL ret, NSString *scanCodeType, NSString *result))completionBlock 

{
    if (!viewcomtroller) {
        YWLog(@"传入控制器空");
        return nil;
    }
    OKZBarView *zbar = [[OKZBarView alloc] init];
    zbar.currViewController = viewcomtroller;
    zbar.resultBlock = completionBlock;
    zbar.height = height;
    //显示自定义扫描视图
    [zbar customContentView];
    
    //开始扫描
    if (startScan) {
        [zbar startScane];
    }
    return zbar;
}

/**
 * 初始化二维码扫描器
 *
 * @return 是否初始化成功
 */
- (BOOL)initZbarScaner
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        [self.scanErrorTipAlertView show];
        YWLog(@"权限没有开");
        return NO;
    }
    
    // Input
    NSError *error = nil ;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        [self.scanErrorTipAlertView show];
        
        return NO;
    }
    
    if (self.session) return YES;
    
    // Output
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([session canAddInput:input]) {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,
                                   AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN8Code,
                                   AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeUPCECode,
                                   AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode128Code];
    
    // 相机背景区域
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = CGRectMake(0,0,KScreenWidth,_height);
    [_currViewController.view.layer insertSublayer:preview atIndex:0];
    
    //设置扫码区域位置
    [self setUpScanRect];
    
    self.device = device;
    self.output = output;
    self.input = input;
    self.session = session;
    self.preview = preview;
    
    @weakify(self)
    //监听通知调整扫描区域
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      @strongify(self)
                                                      if (self){
                                                          self.output.rectOfInterest = [self.preview metadataOutputRectOfInterestForRect:self.scanRectangle.frame];
                                                      }
                                                  }];
    
    return YES;
}

/**
 * 自定义扫描视图
 */
- (UIView *)customContentView
{
    if (!_customContentView) {
        UIView *customContentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,KScreenWidth,_height)];
        customContentView.tag = kCustomViewTag;
        customContentView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        [_currViewController.view addSubview:customContentView];
        self.customContentView = customContentView;
        
        //中间扫描框
        UIImageView *scanRectangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scanWidth, scanHeight) ] ;
        scanRectangle.image = _scanRectangleImage ? _scanRectangleImage : [self imageFromBundleName:@"OKZBar" inDirectory:@"" imageName:@"zbar_scaneframe"];
        scanRectangle.contentMode = UIViewContentModeScaleToFill;
        scanRectangle.center = customContentView.center;
        scanRectangle.userInteractionEnabled = YES;
        [customContentView addSubview:scanRectangle];
        self.scanRectangle = scanRectangle;
        
        UILabel *flashLabel = [[UILabel alloc] init];
        flashLabel.frame = CGRectMake(0, scanRectangle.bounds.size.height - 20, scanRectangle.bounds.size.width, 10);
        flashLabel.font = [UIFont boldSystemFontOfSize:10];
        flashLabel.textAlignment = NSTextAlignmentCenter;
        flashLabel.textColor = [UIColor whiteColor];
        self.flashLabel = flashLabel;
        [scanRectangle addSubview:flashLabel];
        
        //手电筒开关
        UIButton *flashButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [flashButton setImage:[self imageFromBundleName:@"OKZBar" inDirectory:@"" imageName:@"zbar_flashoff"] forState:UIControlStateNormal];
        [flashButton setImage:[self imageFromBundleName:@"OKZBar" inDirectory:@"" imageName:@"zbar_flashon"] forState:UIControlStateSelected];
        flashButton.frame = CGRectMake( (scanRectangle.bounds.size.width - 37)/2.0f, CGRectGetMinY(flashLabel.frame) - 39 - 1, 37, 39);
        [flashButton addTarget:self action:@selector(clickFlashAction) forControlEvents:(UIControlEventTouchUpInside)];
        [scanRectangle addSubview:flashButton];
        self.flashButton = flashButton;
         self.flashLabel.text = [self obtainFlashTitle];
        
        //基准线
        UIImageView *line= [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, scanWidth-16, 10)];
        line.image = _lineImage ? _lineImage : [self imageFromBundleName:@"OKZBar" inDirectory:@"" imageName:@"zbar_QrcodebgImage"];
        line.hidden = YES;
        [scanRectangle addSubview:line];
        self.line = line;
        
        //转圈
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] init];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        indicatorView.color = [UIColor whiteColor];
        indicatorView.center = CGPointMake(scanRectangle.bounds.size.width/2, scanRectangle.bounds.size.height/2);
        indicatorView.hidesWhenStopped = YES;
        [indicatorView startAnimating];
        [scanRectangle addSubview:indicatorView];
        self.indicatorView = indicatorView;
        
        //最上部view
        UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, customContentView.bounds.size.width, scanRectangle.frame.origin.y)];
        upView.backgroundColor = UIColorFromHexA(0x000000,0.4);
        [customContentView addSubview:upView];
        self.upView = upView;
        
        
        //左侧的view
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, scanRectangle.frame.origin.y, scanRectangle.frame.origin.x, scanHeight)];
        leftView.backgroundColor = UIColorFromHexA(0x000000,0.4);
        [customContentView addSubview:leftView];
        self.leftView = leftView;
        
        //右侧的view
        CGFloat rightViewX = CGRectGetMaxX(scanRectangle.frame);
        CGFloat rightViewW = customContentView.bounds.size.width-rightViewX;
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(rightViewX, scanRectangle.frame.origin.y, rightViewW, scanHeight)];
        rightView.backgroundColor = UIColorFromHexA(0x000000,0.4);
        [customContentView addSubview:rightView];
        self.rightView = rightView;
        
        //底部view
        CGFloat downHeight = customContentView.bounds.size.height-CGRectGetMaxY(scanRectangle.frame);
        UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scanRectangle.frame) , customContentView.bounds.size.width, downHeight)];
        downView.backgroundColor = UIColorFromHexA(0x000000,0.4);
        [customContentView addSubview:downView];
        self.downView = downView;
        
        
        //顶部文字
        UILabel *topTipLabel= [[UILabel alloc] init];
        topTipLabel.backgroundColor = [UIColor clearColor];
        topTipLabel.frame=CGRectMake(0, CGRectGetMinY(scanRectangle.frame)-14 - 16, customContentView.bounds.size.width, 14);
        topTipLabel.textColor=[UIColor whiteColor];
        topTipLabel.font = [UIFont systemFontOfSize:14.0];
        topTipLabel.textAlignment = NSTextAlignmentCenter;
        [customContentView addSubview:topTipLabel];
        self.topTipLabel = topTipLabel;
        
        //底部文字
        UIButton *bottomTipBtn= [[UIButton alloc] init];
        bottomTipBtn.backgroundColor = [UIColor clearColor];
        bottomTipBtn.frame=CGRectMake(0, CGRectGetMaxY(scanRectangle.frame)+8, customContentView.bounds.size.width, 20);
        [bottomTipBtn setTitleColor:[UIColor whiteColor] forState:0];
        bottomTipBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        bottomTipBtn.adjustsImageWhenHighlighted = NO;
        [customContentView addSubview:bottomTipBtn];
        self.bottomTipBtn = bottomTipBtn;
    }
    return _customContentView;
}

- (void)setLineImage:(UIImage *)lineImage
{
    _lineImage = lineImage;
    if (lineImage) {
        self.line.image = lineImage;
    }
}

- (void)setScanRectangleImage:(UIImage *)scanRectangleImage
{
    _scanRectangleImage = scanRectangleImage;
    if (scanRectangleImage) {
        self.scanRectangle.image = scanRectangleImage;
    }
}

#pragma mark -===========没有摄像机权限提示===========

/**
 * 没有摄像机权限提示
 */
- (UIAlertView *)scanErrorTipAlertView{
    if (!_scanErrorTipAlertView) {
        _scanErrorTipAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[self getOpenScanErrortipString] delegate:self cancelButtonTitle:@"完成" otherButtonTitles: nil];
    }
    return _scanErrorTipAlertView;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.resultBlock) {
        self.resultBlock(NO,@"",[self getOpenScanErrortipString]);
    }
}
/*** 获取相机没有开启权限的提示语 ***/
- (NSString *)getOpenScanErrortipString{
    return [NSString stringWithFormat:@"您没开启相机功能 请在设置->隐私->相机->%@ 设置为打开状态", [self obtainAPPName]];
}
/**
 获取app的名称
 
 @return app名称
 */
-  (NSString *)obtainAPPName{
    NSDictionary *infoDic = [self obtainInfoDictionary];
    if (infoDic) {
        return infoDic[@"CFBundleDisplayName"];
    }
    return @"";
}
/**
 获取info plist的字典
 
 @return  info plist的字典
 */
- (NSDictionary *)obtainInfoDictionary{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"Info.plist"];
    NSDictionary *infoDic = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    return infoDic;
}

#pragma mark -===========添加自定义视图===========

/**
 * 添加顶部和底部提示文字
 */
- (void)addScanTopTipText:(NSString *)topText
            bottomTipText:(NSString *)bottomText
               startRectY:(CGFloat)startY
{
    //顶部提示文字
    if (topText) {
        self.topTipLabel.text = topText;
    }
    //底部提示文字
    if (bottomText) {
        [self.bottomTipBtn setTitle:bottomText forState:0];
    }
    
    //修改扫码背景变蓝色的bug, 不需要没事都刷新位置
    if (startY != self.scanRectangle.frame.origin.y) {
        self.scanRectangle.frame = CGRectMake(self.scanRectangle.frame.origin.x, startY, self.scanRectangle.bounds.size.width, self.scanRectangle.bounds.size.height);
        self.leftView.frame = CGRectMake(self.leftView.frame.origin.x, startY, self.leftView.bounds.size.width, self.leftView.bounds.size.height);
        self.rightView.frame = CGRectMake(self.rightView.frame.origin.x, startY, self.rightView.bounds.size.width, self.rightView.bounds.size.height);
        self.downView.frame = CGRectMake(self.downView.frame.origin.x, CGRectGetMaxY(self.scanRectangle.frame), self.downView.bounds.size.width, self.downView.bounds.size.height);
        self.topTipLabel.frame = CGRectMake(self.topTipLabel.frame.origin.x, CGRectGetMinY(self.scanRectangle.frame)-self.topTipLabel.bounds.size.height - 16, self.topTipLabel.bounds.size.width, self.topTipLabel.bounds.size.height);
        self.upView.frame = CGRectMake(self.upView.frame.origin.x, self.upView.frame.origin.y, self.upView.bounds.size.width, self.scanRectangle.frame.origin.y);
        self.bottomTipBtn.frame = CGRectMake(self.bottomTipBtn.frame.origin.x, CGRectGetMaxY(self.scanRectangle.frame)+8, self.bottomTipBtn.bounds.size.width, self.bottomTipBtn.bounds.size.height);
        self.downView.frame = CGRectMake(self.downView.frame.origin.x, self.downView.frame.origin.y, self.downView.bounds.size.width, self.customContentView.bounds.size.height-CGRectGetMaxY(self.scanRectangle.frame));
//        self.scanRectangle.y =startY;
//        self.leftView.y = startY;
//        self.rightView.y = startY;
//        self.downView.y = CGRectGetMaxY(self.scanRectangle.frame);
//        self.topTipLabel.y  = CGRectGetMinY(self.scanRectangle.frame)-self.topTipLabel.height - 16 ;
//        self.upView.height = self.scanRectangle.y;
//        self.bottomTipBtn.y = CGRectGetMaxY(self.scanRectangle.frame)+8;
//        self.downView.height = self.customContentView.height-CGRectGetMaxY(self.scanRectangle.frame);
        
        //设置扫码区域位置
        [self setUpScanRect];
    }
}

/**
 * 设置底部提示信息
 */
- (void)refreshBottomText:(NSString *)text
                     font:(UIFont *)font
                    image:(UIImage *)image
               clickBlock:(void(^)(void))clickBlock
{
    if ([text isKindOfClass:[NSString class]] && text.length>0) {
        [self.bottomTipBtn setTitle:text forState:0];
        
        NSInteger space = 25;
        if (IPHONE_4X_3_5) {
            space = 5;
        } else if (IPHONE_5X_4_0) {
            space = 12;
        }
//        self.bottomTipBtn.y = CGRectGetMaxY(self.scanRectangle.frame)+space;
        self.bottomTipBtn.frame = CGRectMake(self.bottomTipBtn.frame.origin.x, CGRectGetMaxY(self.scanRectangle.frame)+space, self.bottomTipBtn.bounds.size.width, self.bottomTipBtn.bounds.size.height);
    }
    
    if (font) {
        self.bottomTipBtn.titleLabel.font = font;
    }
    
    if (image) {
        [self.bottomTipBtn setImage:image forState:0];
    }
    
    if (clickBlock) {
        self.bottomBtnClickBlock = clickBlock;
        [self.bottomTipBtn addTarget:self action:@selector(bottomBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
}

/**
 * 底部按钮事件
 */
- (void)bottomBtnAction
{
    if (self.bottomBtnClickBlock) {
        self.bottomBtnClickBlock();
    }
}

/**
 *  设置扫码区域位置
 */
- (void)setUpScanRect
{
    CGFloat vcWidth = KScreenWidth;
    CGFloat vcHeight = _height;
    self.output.rectOfInterest = CGRectMake((self.scanRectangle.frame.origin.y)/vcHeight,
                                            self.scanRectangle.frame.origin.x/vcWidth,
                                            scanHeight/vcHeight,
                                            scanWidth/vcWidth);
}

#pragma mark -===========操作定时器===========

/**
 * 初始化扫描定时器
 */
- (NSTimer *)scanTimer
{
    if (!_scanTimer) {
        _scanTimer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(fireTimer) userInfo:nil repeats:YES];
    }
    return _scanTimer;
}

/**
 *  销毁定时器
 */
- (void)invalidateTimer
{
    if (_scanTimer) {
        [_scanTimer invalidate];
        _scanTimer = nil;
    }
}

/**
 * 循环扫码
 */
-(void)fireTimer
{
    //YWLog(@"========循环扫码中========");
    if (upOrdown == NO) {
        num ++;
        if (num == scanHeight-30) {
            upOrdown = YES;
        }
    } else {
        num --;
        if (num == 0) {
            upOrdown = NO;
        }
    }
//    _line.y = 10+num;
    _line.frame = CGRectMake(_line.frame.origin.x, 10+num, _line.bounds.size.width, _line.bounds.size.height);
}

/**
 *  开始扫描
 */
- (void)startScane {
    if (!_session) {
        if (![self initZbarScaner]) return;
    }
    if (_session && !_session.isRunning) {
        //开始扫描定时器
        [self scanTimer];
        
        [self.indicatorView stopAnimating];
        [self.indicatorView removeFromSuperview];
        self.indicatorView = nil;
        self.line.hidden = NO;
        self.customContentView.backgroundColor = [UIColor clearColor];
        
        self.line.hidden = NO;
//        self.line.y = 10;
        self.line.frame = CGRectMake(self.line.frame.origin.x, 10, self.line.bounds.size.width, self.line.bounds.size.height);
        num = 0;
        upOrdown = NO;
        
        //开始会话
        [self.session startRunning];
        self.delayPatchScanResult = NO;
    }
}

/**
 *  停止扫描
 */
- (void)stopScane
{
    //停止会话
    [self.session stopRunning];
    
    //记住停止扫描时闪光灯的状态
    self.lastIsFlashWhenStop = (self.device.flashMode==AVCaptureFlashModeOn);
    
    //设置闪光灯图片为关闭
    [self showFlash:NO];
    
    self.delayPatchScanResult = NO;
    
    //销毁扫码条定时器
    [self invalidateTimer];
    
    //销毁返回条件定时器
    [self invalidateDelayTimer];
    
    self.line.hidden = YES;
//    self.line.y = 10;
    self.line.frame = CGRectMake(self.line.frame.origin.x, 10, self.line.bounds.size.width, self.line.bounds.size.height);
    num = 0;
    upOrdown = NO;
}

/**
 * 开始扫描延迟返回扫描结果 -->(产品要求:扫码太块需要延迟)
 */
- (void)startScaneDelayPatchResult:(NSTimeInterval)delay
{
    YWLog(@"注意:这里顺序有区别===%@",_session);
    if (!_session) {
        [self startScane];//扫码
        
    } else{
        [self startScane];//扫码
        self.delayPatchScanResult = YES;
        
        //延迟放开扫码返回, <为什么不用disPatch, 考虑到切换到后台disPatch的定时器可能会失效>
        if (_delayTimer) {
            [self invalidateDelayTimer];
        }
        _delayTimer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(seCanPatchData) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_delayTimer forMode:NSRunLoopCommonModes];
    }
    
    //这里需要延迟打开闪光灯,(立即调用无效果)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //恢复停止扫描时闪光灯的状态
        [self recoverFlashStatus];
    });
}

/**
 * 放开扫码回调条件
 */
- (void)seCanPatchData
{
    self.delayPatchScanResult = NO;
    [self invalidateDelayTimer];
    YWLog(@"放开扫码回调条件");
}

/**
 * 恢复停止扫描时闪光灯的状态
 */
- (void)recoverFlashStatus
{
    if (self.lastIsFlashWhenStop && !self.device.isFlashActive) {
        [self showFlash:YES];
    }
}

/**
 * 移除定时器
 */
- (void)invalidateDelayTimer
{
    [self.delayTimer invalidate];
    self.delayTimer = nil;
}

#pragma mark - //****************** 事件 action ******************//

- (void)clickFlashAction{
    YWLog(@"点击了闪光灯按钮");
    self.flashButton.selected = !self.flashButton.isSelected;
    self.flashLabel.text = [self obtainFlashTitle];
    if (!self.device.hasFlash) {
        return;
    }
    
    [self.session beginConfiguration];
    [self.device lockForConfiguration:nil];
    if (self.flashButton.isSelected) {
        [self.device setTorchMode:(AVCaptureTorchModeOn)];
        [self.device setFlashMode:(AVCaptureFlashModeOn)];
    }else{
        [self.device setTorchMode:AVCaptureTorchModeOff];
        [self.device setFlashMode:(AVCaptureFlashModeOff)];
    }
    [self.device unlockForConfiguration];
    [self.session commitConfiguration];
}

- (NSString *)obtainFlashTitle{
    if (self.flashButton.isSelected) {
        return @"轻点关闭";
    }else{
        return @"轻点照亮";
    }
}

/**
 控制闪光灯
 
 @param show 是否开打闪光灯
 */
- (void)showFlash:(BOOL)show
{
    YWLog(@"控制闪光灯===%zd",show);
    if (show) { //开打闪光灯
        self.flashButton.selected = NO;
    } else { //关闭闪光灯
        self.flashButton.selected = YES;
    }
    //点击事件
    [self clickFlashAction];
}

#pragma mark -===========输出代理方法===========

/**
 * 此方法是在识别到QRCode，并且完成转换,如果QRCode的内容越大，转换需要的时间就越长
 * 会频繁的扫描，调用代理方法
 */
- (void)captureOutput:(AVCaptureOutput*)captureOutput didOutputMetadataObjects:(NSArray*)metadataObjects fromConnection:(AVCaptureConnection*)connection
{
    if (!self.delayPatchScanResult) {
        self.delayPatchScanResult = YES;
        
        // 2.回调扫描结果
        if(metadataObjects.count> 0) {
            AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
            // 提示：如果需要对url或者名片等信息进行扫描，可以在此进行扩展！
            if (self.resultBlock) {
                self.resultBlock(YES,obj.type,obj.stringValue);
            }
        } else {
            if (self.resultBlock) {
                self.resultBlock(NO,@"",@"");
            }
        }
    }
}
/**
 *  读取bundle中的image
 *
 *  @param bundleName  bundle名称
 *  @param imageName  图片名称
 *  @param inDirectory 目录
 *  @return 图片Image
 */
- (UIImage *)imageFromBundleName:(NSString *)bundleName inDirectory:(NSString *)inDirectory imageName:(NSString *)imageName{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"]];
    //没有找到bundle
    if (!bundle) {
        if (imageName.length) {
            return [UIImage imageNamed:imageName];
        }
        return nil;
    }
    
    UIImage *image = nil;
    
    NSString *imageBundleName = [NSString stringWithFormat:@"%@.bundle%@/%@",bundleName,(inDirectory.length > 0 ? [NSString stringWithFormat:@"/%@",inDirectory] : @""),imageName];
    if (imageBundleName.length){
        image = [UIImage imageNamed:imageBundleName];
    }
    NSString *imagePath = [bundle pathForResource:imageName ofType:@"png" inDirectory:inDirectory];
    if (!image){
        //图片路径是nil
        if (!imagePath.length) {
            if (imageName.length) {
                image = [UIImage imageNamed:imageName];
            }
        }
    }
    if(!image){
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    return image;
}

#pragma mark -===========移除所有扫描视图===========

/**
 * 移除所有扫描视图
 */
- (void)removeAllScanView{
    // 1.停止扫描
    [self stopScane];
    
    // 2.删除预览图层
    [self.preview removeFromSuperlayer];
    
    // 3.移除自定义视图
    [self.customContentView removeFromSuperview];
}

- (void)dealloc
{
    YWLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
