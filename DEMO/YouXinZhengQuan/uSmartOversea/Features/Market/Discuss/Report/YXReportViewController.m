//
//  YXReportViewController.m
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXReportViewController.h"
#import "YXReportViewModel.h"
#import "YXReportTextParser.h"
#import "YXTextLinePositionModifier.h"
#import "uSmartOversea-Swift.h"
#import "YYTextContainerView.h"
#import "UIImage+Compress.h"
#import "TZImagePickerController.h"
#import "YXAlertViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "XLPhotoBrowser.h"
#import <Masonry/Masonry.h>
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <ReactiveObjC/ReactiveObjC.h>

#define kMaxReportImageCount 9

@interface YXReportViewController () <YYTextViewDelegate, YYTextKeyboardObserver, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) YXReportViewModel *viewModel;
@property (nonatomic, strong) YYTextView *textView;
@property (nonatomic, strong) YXReportToolbar *toolbar;
@property (nonatomic, strong) QMUIGridView *gridView;
@property (nonatomic, assign) CGFloat rowHeight;

@property (nonatomic, strong) UIButton *reportButton;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, strong) NSMutableArray *imageViewArr;
@property (nonatomic, strong) NSMutableArray *imagePathArr;
@property (nonatomic, strong) NSMutableArray *imageUrlArr;
@property (nonatomic, strong) NSMutableArray *stockIdList;

@property (nonatomic, assign) BOOL isUploadFailed;
@property (nonatomic, assign) BOOL isPostSuccess;


@end

@implementation YXReportViewController
@dynamic viewModel;

- (instancetype)initWithViewModel:(YXViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        [[YYTextKeyboardManager defaultManager] addObserver:self];
    }
    return self;
}

- (void)dealloc {
    if (self.isPostSuccess && self.viewModel.successBlock) {
        self.viewModel.successBlock();
    } else if (self.viewModel.cancelBlock){
        self.viewModel.cancelBlock();
    }
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageArr = [NSMutableArray array];
    self.imageUrlArr = [NSMutableArray array];
    self.imagePathArr = [NSMutableArray array];
    self.imageViewArr = [NSMutableArray array];
    self.stockIdList = [NSMutableArray array];
    
//    [self.yx_navigationbar setupRightButton:self.reportButton];
    self.title = @"";
    

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.reportButton];
    //默认不可点击
    self.reportButton.enabled = NO;
    
    self.view.backgroundColor = QMUITheme.foregroundColor;
    [self.view addSubview:self.textView];

    UIView *textContainerView;
    for (UIView *subView in [self.textView subviews]) {
        if ([subView isKindOfClass:[YYTextContainerView class]]) {
            textContainerView = subView;
        }
    }
    
    self.rowHeight = floor((YXConstant.screenWidth - 32)/3.0);
    
    [self.textView addSubview:self.gridView];
    [self.gridView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
        make.top.equalTo(textContainerView.mas_bottom).offset(20);
        make.height.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.toolbar];
    YXSecu *secu = self.viewModel.secu;
    if (secu) {
        [self.textView replaceRange:self.textView.selectedTextRange withText: [NSString stringWithFormat:@"$%@(%@.%@)$ ", secu.name, secu.symbol, [secu.market uppercaseString]]];
        [self.stockIdList addObject:secu.secuId.ID];
    }

    for (UIImage *image in self.viewModel.images) {
        NSData *data = [image compressQualityWithMaxLength:1000*1000];
        UIImage *compressImage = [UIImage imageWithData:data];
        //临时保存路径
        NSString* tempPath = QCloudTempFilePathWithExtension(@"png");
        [data writeToFile:tempPath atomically:YES];

        [self.imagePathArr addObject:tempPath];
        [self.imageArr addObject:compressImage];
    }
    [self updateGrid];
    
    @weakify(self)
    RACSignal *textViewSetter = RACObserve(self.textView, text);
    [textViewSetter subscribeNext:^(NSString*  _Nullable str) {
        @strongify(self)
        if (self.textView.text.length > 300) {
            self.toolbar.textNumLabel.textColor = [UIColor qmui_colorWithHexString:@"#EE3D3D"];
        } else {
            self.toolbar.textNumLabel.textColor = [QMUITheme textColorLevel4];
        }
        self.toolbar.textNumLabel.text = [NSString stringWithFormat:@"%lu/300",(unsigned long)self.textView.text.length];
    }];
}

- (void)setupNavigationItems {
    UIBarButtonItem *backBtn1 = [UIBarButtonItem qmui_itemWithImage:[UIImage imageNamed:@"nav_back"] target:self action:@selector(popBack)];
    UIBarButtonItem *backBtn2 = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];

    UIBarButtonItem *spaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceBar.width = -15;

//    backItem.imageInsets = UIEdgeInsets(top: 0, left: -3.0, bottom: 0, right: 3.0)
//    backBtn2.imageInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    self.navigationItem.leftBarButtonItems = @[backBtn1];
}

- (void)popBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] forState:UIControlStateNormal];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        [_backButton setTitleColor:QMUITheme.textColorLevel1 forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
    
- (UIButton *)reportButton {
    if (_reportButton == nil) {
        _reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reportButton setTitle:[YXLanguageUtility kLangWithKey:@"publish"] forState:UIControlStateNormal];
        _reportButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_reportButton setTitleColor:QMUITheme.themeTextColor forState:UIControlStateNormal];

        @weakify(self)
        [_reportButton setQmui_tapBlock:^(__kindof UIControl *sender) {
            @strongify(self)
            
            for (UIImage* image in self.imageArr) {
                if ([image hasSensitiveQRCode]) {
                    [self showText: [YXLanguageUtility kLangWithKey:@"sensitive_info_tip"]];
                    return;
                }
            }
            
            if (self.textView.text.length > 300) {
                [self showText:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"publish_tips"], self.textView.text.length - 300]];
                return;
            }
            [self showLoading:@""];
            if (self.imagePathArr.count > 0) {
                NSString *fileName = @"bbs/*";
                NSString *region = [YXQCloudService keyQCloudGuangZhou];
                NSString *bucket = [YXUrlRouterConstant frontEndTopicBucket];
                if (YXConstant.targetMode == YXTargetModePrd || YXConstant.targetMode == YXTargetModePrd_hk) {
                    region = [YXQCloudService keyQCloudSingapore];
                    bucket = [YXUrlRouterConstant frontEndTopicBucket];
                }
                [YXUserManager updateTokenWithFileName:fileName region:region bucket:bucket success:^{
                    [self uploadPicture:nil region:region bucket:bucket];
                } failed:^(NSString * _Nonnull error) {
                    [self hideHud];
                    [self showError:[YXLanguageUtility kLangWithKey:@"network_timeout"]];
                }];
            } else {
                [self submitReport];
            }
        }];
    }
    return _reportButton;
}

- (void)submitReport{
    YXCreatePostRequestModel *requestModel = [[YXCreatePostRequestModel alloc] init];
    requestModel.content = self.textView.attributedText.string;
    requestModel.pictures = self.imageUrlArr;
    [self updateStockId];
    requestModel.stock_id_list = [self.stockIdList copy];
    YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
    @weakify(self)
    [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
        @strongify(self)
        [self hideHud];
        if (responseModel.code == 0) {
            [self showSuccess:[YXLanguageUtility kLangWithKey:@"publish_success"]];
            self.isPostSuccess = YES;
            [self.viewModel.services popViewModelAnimated:YES];
        } else {
            [self showError:responseModel.msg];
        }
       
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        @strongify(self)
        [self hideHud];
        [self showError:[YXLanguageUtility kLangWithKey:@"network_timeout"]];
    }];
}

- (void)updateStockId {
    NSAttributedString *attributeString = self.textView.attributedText;
    NSArray<NSTextCheckingResult *> *topicResults = [[YXReportTextParser regexStock] matchesInString:attributeString.string options:kNilOptions range:NSMakeRange(0, attributeString.length)];
    NSUInteger clipLength = 0;
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSTextCheckingResult *topic in topicResults) {
        if (topic.range.location == NSNotFound && topic.range.length <= 1) continue;
        NSRange range = topic.range;
        range.location -= clipLength;
        
        [attributeString enumerateAttribute:YYTextBindingAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) {
                NSString *valueString = [attributeString attributedSubstringFromRange:range].string;
                NSInteger from = [valueString rangeOfString:@"(" options:NSBackwardsSearch].location + 1;
                NSInteger length = [valueString rangeOfString:@")" options:NSBackwardsSearch].location - from;
                NSArray *stockItems = [[valueString substringWithRange:NSMakeRange(from, length)] componentsSeparatedByString:@"."];
                NSString *market = ((NSString *)stockItems.lastObject).lowercaseString;
                NSMutableString *symbol = [[NSMutableString alloc] initWithString:@""];
                for (int i = 0; i < stockItems.count - 1; i ++) {
                    [symbol appendString:stockItems[i]];
                    if (i != stockItems.count - 2) {
                        [symbol appendString:@"."];
                    }
                }
                [array addObject:[NSString stringWithFormat:@"%@%@", market, [symbol copy]]];
                *stop = YES;
            }
        }];
    }
    
    YXSecu *secu = self.viewModel.secu;
    if (secu) {
        if (![secu.secuId.ID isEqualToString:array.firstObject]) {
            [array  insertObject:secu.secuId.ID atIndex:0];
        }
    }
    self.stockIdList = array;
}

- (void)uploadPicture:(nullable NSString *)fileName region: (NSString * _Nonnull)region bucket: (NSString * _Nonnull)bucket {
    dispatch_group_t group = dispatch_group_create();
    self.imageUrlArr = [NSMutableArray array];
    for (int i = 0; i<self.imagePathArr.count; i++) {
        [self.imageUrlArr addObject:@""];
        dispatch_group_enter(group);
        NSURL *url = [NSURL fileURLWithPath:self.imagePathArr[i]];
        QCloudCOSXMLUploadObjectRequest *put = [QCloudCOSXMLUploadObjectRequest new];
        UIImage *image = self.imageArr[i];
        put.object = [NSString stringWithFormat:@"bbs/iOS-%ld-%d_%dx%d.jpg", (long)([NSDate date].timeIntervalSince1970), arc4random()%100000, (int)image.size.width, (int)image.size.height];
        put.bucket = bucket;
        put.body = url;
        [put.customHeaders setObject:@"www.yxzq.com" forKey:@"Referer"];
        
        [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            LOG_VERBOSE(kOther, @"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
        }];
        
        @weakify(self)
        [put setFinishBlock:^(QCloudUploadObjectResult *outputObject, NSError* error) {
            @strongify(self)
            
            if (error) {
                self.isUploadFailed = YES;
                dispatch_group_leave(group);
                
            }else{
                self.imageUrlArr[i] = outputObject.location;
                dispatch_group_leave(group);
            }
        }];
        
        [[QCloudCOSTransferMangerService costransfermangerServiceForKey:region] UploadObject:put];
    }
    
    @weakify(self)
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        @strongify(self)
        if (!self.isUploadFailed) {
            [self submitReport];
        }else{
            [self.imageUrlArr removeAllObjects];
            self.isUploadFailed = NO;
            [self hideHud];
            [self showError:[YXLanguageUtility kLangWithKey:@"mine_upload_failure"]];
                    
            
        }
    });
    
}


- (YYTextView *)textView {
    if (_textView == nil) {
        _textView = [[YYTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _textView.textContainerInset = UIEdgeInsetsMake(12, 16, 12, 16);
        _textView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textView.extraAccessoryViewHeight = 60;
        _textView.showsVerticalScrollIndicator = NO;
        _textView.alwaysBounceVertical = YES;
        _textView.allowsCopyAttributedString = NO;
        _textView.font = [UIFont systemFontOfSize:16];
        YXReportTextParser *parser = [YXReportTextParser new];
        parser.editing = YES;
        _textView.textParser = parser;
        _textView.delegate = self;
        _textView.inputAccessoryView = [UIView new];
        _textView.textColor = QMUITheme.textColorLevel1;
        
        YXTextLinePositionModifier *modifier = [YXTextLinePositionModifier new];
        modifier.font = [UIFont systemFontOfSize:16];
        modifier.paddingTop = 12;
        modifier.paddingBottom = 12;
        modifier.lineHeightMultiple = 1.5;
        _textView.linePositionModifier = modifier;

        NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:[YXLanguageUtility kLangWithKey:@"live_comment"]];
        atr.yy_color = QMUITheme.textColorLevel3;
        atr.yy_font = [UIFont systemFontOfSize:16];
        _textView.placeholderAttributedText = atr;
    }
    return _textView;
}

- (YXReportToolbar *)toolbar {
    if (_toolbar == nil) {
        _toolbar = [[YXReportToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _toolbar.qmui_bottom = self.view.height;
        
        @weakify(self)
        [_toolbar.reportStockButton setQmui_tapBlock:^(__kindof UIControl *sender) {
            @strongify(self)
            @weakify(self)
            [(NavigatorServices *)self.viewModel.services presentToNoPopularSearchWithShowLike:NO showHistory:YES didSelectedItem:^(YXSearchItem * _Nonnull secu) {
                @strongify(self)
                [self.textView replaceRange:self.textView.selectedTextRange withText: [NSString stringWithFormat:@"$%@(%@.%@)$ ", secu.name, secu.symbol, [secu.market uppercaseString]]];
                [self.stockIdList addObject:secu.secuId.ID];
            }];
            
        }];
        
        [_toolbar.reportImageButton setQmui_tapBlock:^(__kindof UIControl *sender) {
            @strongify(self)
            [self showNewImageAlert];
        }];
    }
    return _toolbar;
}

- (void)updateGrid {
    [self.gridView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViewArr removeAllObjects];
    @weakify(self)
    for (int i = 0; i < self.imageArr.count; i++) {
        UIImage *image = self.imageArr[i];
        NSString *path = self.imagePathArr[i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapGes:)];
        [imageView addGestureRecognizer:tapGesture];
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setImage:[UIImage imageNamed:@"report_delete"] forState:UIControlStateNormal];
        [imageView addSubview:deleteButton];
        [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(imageView);
            make.width.mas_equalTo(16);
            make.height.mas_equalTo(16);
        }];
        
        [deleteButton setQmui_tapBlock:^(__kindof UIControl *sender) {
            @strongify(self)
            [self.imageArr removeObject:image];
            [self.imagePathArr removeObject:path];
            [self.imageViewArr removeObject:imageView];
            [imageView removeFromSuperview];
            
            [self.gridView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(ceilf(self.imageArr.count / 3.0) * self.rowHeight);
            }];
        }];
        
        [self.gridView addSubview:imageView];
        [self.imageViewArr addObject:imageView];
    }
    
    [self.gridView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(ceilf(self.imageArr.count / 3.0) * self.rowHeight);
    }];
    
    if (self.imageArr.count > 0) {
        self.reportButton.enabled = YES;
    } else if (self.textView.attributedText.length > 0) {
        self.reportButton.enabled = YES;
    } else {
        self.reportButton.enabled = NO;
    }

}

- (void)imageTapGes:(UIGestureRecognizer *) ges {
    UIView *tapView = ges.view;
    NSInteger index = [self.imageViewArr indexOfObject:tapView];
    [XLPhotoBrowser showPhotoBrowserWithImages:self.imageArr currentImageIndex:index];
}


- (void)showNewImageAlert{
    if (self.imageArr.count >= kMaxReportImageCount) {
        [YXProgressHUD showMessage:[NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Select a maximum of %zd photos"], kMaxReportImageCount]];
        return;
    }
        //弹框
        QMUIAlertController *alertController = [[QMUIAlertController alloc] initWithTitle:nil message:nil preferredStyle:QMUIAlertControllerStyleActionSheet];
        
        @weakify(self, alertController)
        UIButton *albumButton = [self creatButtonWithTitle:[YXLanguageUtility kLangWithKey:@"mine_camera"]];
        albumButton.frame = CGRectMake(0, 0, YXConstant.screenWidth, 54);
        albumButton.layer.maskedCorners = QMUILayerMinXMinYCorner | QMUILayerMaxXMinYCorner;
        albumButton.layer.cornerRadius = 16;
        albumButton.layer.masksToBounds = YES;
        [[[albumButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:alertController.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self, alertController)
            [alertController hideWithAnimated:NO];
            [YXToolUtility checkCameraPermissionsWith:nil closure:^{
                [self showCamera];
            }];

        }];

        UIButton *cameraButton = [self creatButtonWithTitle:[YXLanguageUtility kLangWithKey:@"mine_photo_upload"]];
        cameraButton.frame = CGRectMake(0, 54, YXConstant.screenWidth, 54);
        [[[cameraButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:alertController.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self, alertController)
            [alertController hideWithAnimated:NO];
            [self showImageLibrary];

        }];

        UIButton *cancelButton = [self creatButtonWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"]];
        cancelButton.frame = CGRectMake(0, 116, YXConstant.screenWidth, 54);
        [[[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:alertController.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(alertController)
            [alertController hideWithAnimated:YES];
        }];
        
        
        UIView *line = [UIView lineView];
        line.backgroundColor = QMUITheme.popSeparatorLineColor;
        line.frame = CGRectMake(0, 54, YXConstant.screenWidth, 0.5);

        UIView *greyView = [[UIView alloc] init];
        greyView.backgroundColor = QMUITheme.blockColor;
        greyView.frame = CGRectMake(0, 108, YXConstant.screenWidth, 8);

        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 170)];

        [containerView addSubview:albumButton];
        [containerView addSubview:cameraButton];
        [containerView addSubview:cancelButton];
        [containerView addSubview:line];
        [containerView addSubview:greyView];

        [alertController addCustomView:containerView];
        alertController.sheetCancelButtonMarginTop = 0;
        alertController.sheetButtonBackgroundColor = [QMUITheme popupLayerColor];
        alertController.sheetHeaderBackgroundColor = [UIColor clearColor];
        alertController.isExtendBottomLayout = YES;
        [alertController showWithAnimated:YES];

}

- (void)showImageAlert {
    if (self.imageArr.count >= kMaxReportImageCount) {
        [YXProgressHUD showMessage:[NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Select a maximum of %zd photos"], kMaxReportImageCount]];
        return;
    }
    
    QMUIAlertAction *cancel = [QMUIAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        
    }];
    
    @weakify(self)
    QMUIAlertAction *camera = [QMUIAlertAction actionWithTitle: [YXLanguageUtility kLangWithKey:@"mine_camera"] style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        @strongify(self)
        if (![YXToolUtility checkCameraAlbumPermissions]) {
            [YXToolUtility showCameraPermissionsAlertInVc:self];
        } else {
            [self showCamera];
        }
    }];
    
    QMUIAlertAction *album  = [QMUIAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"mine_photo_upload"] style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        @strongify(self)
        [self showImageLibrary];
    }];
    
    YXAlertViewController *alertController = [[YXAlertViewController alloc] initWithTitle:nil message:nil preferredStyle:QMUIAlertControllerStyleActionSheet];
    alertController.containerViewColor = QMUITheme.backgroundColor;
    [alertController addAction:cancel];
    [alertController addAction:camera];
    [alertController addAction:album];
    [alertController showWithAnimated:YES];
}


- (UIButton *)creatButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [QMUITheme popupLayerColor];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:QMUITheme.textColorLevel1 forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}


- (void)showCamera {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    UIViewController *vc = [UIViewController currentViewController];
    [vc presentViewController:imagePickerController animated:YES completion:nil];
}

//展示照片选择
- (void)showImageLibrary{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:kMaxReportImageCount - self.imageArr.count delegate:nil];
    imagePickerVc.preferredLanguage = YXLanguageUtility.identifier;
    imagePickerVc.iconThemeColor = QMUITheme.themeTextColor;
    imagePickerVc.naviBgColor = [QMUITheme foregroundColor];
//    imagePickerVc.naviTitleFont = [UIFont systemFontOfSize:kYXDefaultTitleFontSize];
    imagePickerVc.naviTitleColor = [QMUITheme textColorLevel1];
    imagePickerVc.barItemTextColor = [QMUITheme textColorLevel1];
    imagePickerVc.oKButtonTitleColorNormal = QMUITheme.themeTextColor;
    imagePickerVc.oKButtonTitleColorDisabled = [QMUITheme.themeTextColor colorWithAlphaComponent:0.4];
    imagePickerVc.navLeftBarButtonSettingBlock = ^(UIButton *leftButton) {
        
        [leftButton setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -32, 0, 0)];
    };
    imagePickerVc.sortAscendingByModificationDate = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.showSelectedIndex = YES;
    
    @weakify(self)
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        @strongify(self)
        
        for (UIImage *image in photos) {
            NSData *data = [image compressQualityWithMaxLength:1000*1000];
            UIImage *compressImage = [UIImage imageWithData:data];
            //临时保存路径
            NSString* tempPath = QCloudTempFilePathWithExtension(@"png");
            [data writeToFile:tempPath atomically:YES];
           
            [self.imagePathArr addObject:tempPath];
            [self.imageArr addObject:compressImage];
        }
        [self updateGrid];
    }];
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    UIViewController *vc = [UIViewController currentViewController];
    [vc presentViewController:imagePickerVc animated:YES completion:nil];
}

//预览图片
- (void)PreviewImageWithIndex:(NSInteger)index{
    [XLPhotoBrowser showPhotoBrowserWithImages:self.imageArr currentImageIndex:index];
}

- (QMUIGridView *)gridView {
    if (_gridView == nil) {
        _gridView = [[QMUIGridView alloc] initWithFrame:CGRectMake(0, 0, 0, QMUIViewSelfSizingHeight)];
        _gridView.columnCount = 3;
        _gridView.rowHeight = self.rowHeight;
        _gridView.separatorWidth = PixelOne;
        _gridView.separatorColor = [UIColor clearColor];
        _gridView.separatorDashed = NO;
        _gridView.separatorWidth = 4;
    }
    return _gridView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)textViewDidChange:(YYTextView *)textView {
    if (textView.attributedText.length > 0 || self.imageArr.count > 0) {
        self.reportButton.enabled = YES;
    } else {
        self.reportButton.enabled = NO;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if(image.imageOrientation!=UIImageOrientationUp){
            UIGraphicsBeginImageContext(image.size);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        NSData *data = [image compressQualityWithMaxLength:1000*1000];
        UIImage *compressImage = [UIImage imageWithData:data];
        NSString* tempPath = QCloudTempFilePathWithExtension(@"png");
        [data writeToFile:tempPath atomically:YES];
        [self.imagePathArr addObject:tempPath];
        [self.imageArr addObject:compressImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateGrid];
        });
    });
    [picker dismissViewControllerAnimated:YES completion:nil];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark YYTextKeyboardObserver
- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition {
    CGRect toFrame = [[YYTextKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
    if (transition.animationDuration == 0) {
        self.toolbar.qmui_bottom = CGRectGetMinY(toFrame);
    } else {
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption | UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.toolbar.qmui_bottom = CGRectGetMinY(toFrame);
        } completion:NULL];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


