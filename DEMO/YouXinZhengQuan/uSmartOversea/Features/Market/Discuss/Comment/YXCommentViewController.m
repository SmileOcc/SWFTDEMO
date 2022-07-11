//
//  YXCommentViewController.m
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXCommentViewController.h"
#import "YXCommentViewModel.h"
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

#define kMaxCommentImageCount 1

@interface YXCommentViewController () <YYTextViewDelegate, YYTextKeyboardObserver, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) YXCommentViewModel *viewModel;
@property (nonatomic, strong) YYTextView *textView;
@property (nonatomic, strong) YXReportToolbar *toolbar;
@property (nonatomic, strong) QMUIGridView *gridView;
@property (nonatomic, assign) CGFloat rowHeight;

@property (nonatomic, strong) UIButton *reportButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, strong) NSMutableArray *imagePathArr;
@property (nonatomic, strong) NSMutableArray *imageUrlArr;
@property (nonatomic, strong) NSMutableArray *stockIdList;

@property (nonatomic, assign) BOOL isUploadFailed;
@property (nonatomic, assign) BOOL isPostSuccess;
@property (nonatomic, assign) BOOL isPostDelete;

@property (nonatomic, strong) NSString * commentId;

@end

@implementation YXCommentViewController
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
        self.viewModel.successBlock(self.commentId);
    } else if (self.isPostDelete && self.viewModel.postDeleteBlock) {
        self.viewModel.postDeleteBlock();
    } else  if (self.viewModel.cancelBlock) {
        self.viewModel.cancelBlock();
    }
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.commentId = @"";
    self.imageArr = [NSMutableArray array];
    self.imageUrlArr = [NSMutableArray array];
    self.imagePathArr = [NSMutableArray array];
    self.stockIdList = [NSMutableArray array];
        
//    self.view.backgroundColor = QMUITheme.foregroundColor
    self.view.backgroundColor= UIColor.clearColor;
    
    UIView *topView = [[UIView alloc] init];
    
    topView.backgroundColor = QMUITheme.foregroundColor;
    [self.view addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    
    [topView addSubview:self.cancelButton];
    [topView addSubview:self.reportButton];
    [topView addSubview:self.titleLabel];
    
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.equalTo(topView);
        make.bottom.equalTo(topView);
        make.width.mas_equalTo(80);
    }];
    
    [self.reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topView).offset(-12);
        make.top.equalTo(topView);
        make.bottom.equalTo(topView);
        make.width.mas_equalTo(80);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(topView);
    }];
    
    UIView *breakLine = [[UIView alloc] init];
    breakLine.backgroundColor = QMUITheme.separatorLineColor;
    [topView addSubview:breakLine];
    
    [breakLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(topView.mas_bottom);
        make.width.mas_equalTo(0.5);
        make.left.mas_equalTo(topView.mas_left);
        make.right.mas_equalTo(topView.mas_right);
    }];
    
    [topView layoutIfNeeded];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:topView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = topView.bounds;
    maskLayer.path = maskPath.CGPath;
    topView.layer.mask = maskLayer;
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textView becomeFirstResponder];
    self.navigationController.navigationBar.hidden = YES;
}

- (UIButton *)reportButton {
    if (_reportButton == nil) {
        _reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reportButton setTitle:[YXLanguageUtility kLangWithKey:@"publish"] forState:UIControlStateNormal];
        _reportButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _reportButton.enabled = NO;
        _reportButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_reportButton setTitleColor:[UIColor qmui_colorWithHexString:@"#414FFF"] forState:UIControlStateNormal];
        [_reportButton setTitleColor:[[UIColor qmui_colorWithHexString:@"#414FFF"] colorWithAlphaComponent:0.45] forState:UIControlStateDisabled];

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
                NSString *fileName = @"bbs/*"; // 因为有多图，所以申请通配符权限
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

- (UIButton *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] forState:UIControlStateNormal];
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_cancelButton setTitleColor:QMUITheme.textColorLevel1 forState:UIControlStateNormal];
 
        @weakify(self)
        [_cancelButton setQmui_tapBlock:^(__kindof UIControl *sender) {
            @strongify(self)
            [self.view hideView];
        }];
    }
    return _cancelButton;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = QMUITheme.textColorLevel1;
        _titleLabel.text = [YXLanguageUtility kLangWithKey:@"comment"];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        
        if (self.viewModel.isReply) {
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", [YXLanguageUtility kLangWithKey:@"reply"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: QMUITheme.textColorLevel1}];
            [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:self.viewModel.params[@"nick_name"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: QMUITheme.textColorLevel2}]];
            _titleLabel.attributedText = attrString;
        }
    }
    return _titleLabel;
}

- (void)submitReport{
    [self updateStockId];
    YXHZBaseRequestModel *requestModel;
    if (self.viewModel.isReply) {
        YXReplyCommentRequestModel *replyRequestModel = [[YXReplyCommentRequestModel alloc] init];
        replyRequestModel.content = self.textView.attributedText.string;
        replyRequestModel.pictures = self.imageUrlArr;
        replyRequestModel.stock_id_list = self.stockIdList;

        if ([self.viewModel.params[@"comment_id"] length] > 0) {
            replyRequestModel.comment_id = self.viewModel.params[@"comment_id"];
        } else {
            replyRequestModel.reply_id = self.viewModel.params[@"reply_id"];
        }
        
        replyRequestModel.reply_target_uid = self.viewModel.params[@"reply_target_uid"];
        if (self.viewModel.params[@"post_type"]) {
            replyRequestModel.post_type = [self.viewModel.params[@"post_type"] intValue];
        }else{
            replyRequestModel.post_type = 5;
        }
        requestModel = replyRequestModel;
    } else {
        YXCommentPostRequestModel *commentRequestModel = [[YXCommentPostRequestModel alloc] init];
        commentRequestModel.content = self.textView.attributedText.string;
        commentRequestModel.pictures = self.imageUrlArr;
        commentRequestModel.stock_id_list = self.stockIdList;
        commentRequestModel.post_id = self.viewModel.params[@"post_id"];
        if (self.viewModel.params[@"post_type"]) {
            commentRequestModel.post_type = [self.viewModel.params[@"post_type"] intValue];
        }else{
            commentRequestModel.post_type = 5;  //个股讨论
        }
        requestModel = commentRequestModel;
    }
    
    YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
    @weakify(self)
    [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
        @strongify(self)
        [self hideHud];
        if (responseModel.code == 0) {
            [self showSuccess:[YXLanguageUtility kLangWithKey:@"publish_success"]];
            if( responseModel.data[@"comment_id"]) {
                self.commentId = responseModel.data[@"comment_id"];
            }
            self.isPostSuccess = YES;
            [self.view hideView];
        }else if(responseModel.code == 6) {
            [self showError:responseModel.msg];
            self.isPostDelete = YES;
            [self.view hideView];
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
    
    self.stockIdList = array;
}

- (void)uploadPicture:(nullable NSString *)fileName region: (NSString * _Nonnull)region bucket: (NSString * _Nonnull)bucket {
    dispatch_group_t group = dispatch_group_create();
    for (int i = 0; i < self.imagePathArr.count; i++) {
        dispatch_group_enter(group);
        NSURL *url = [NSURL fileURLWithPath:self.imagePathArr[i]];
        QCloudCOSXMLUploadObjectRequest *put = [QCloudCOSXMLUploadObjectRequest new];
        UIImage *image = self.imageArr[i];
        put.object = fileName;
        put.bucket = bucket;
        put.object = [NSString stringWithFormat:@"bbs/iOS-%ld-%d_%dx%d.jpg", (long)([NSDate date].timeIntervalSince1970), arc4random()%100000, (int)image.size.width, (int)image.size.height];
        put.bucket = [YXUrlRouterConstant frontEndTopicBucket];
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
                [self.imageUrlArr addObject:outputObject.location];
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
        _textView = [[YYTextView alloc] initWithFrame:CGRectMake(0, 40, self.view.width, self.view.height - 40)];
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
        _textView.backgroundColor = QMUITheme.foregroundColor;
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
            [self showImageAlert];
        }];
    }
    return _toolbar;
}

- (void)updateGrid {
    [self.gridView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    @weakify(self)
    for (int i = 0; i < self.imageArr.count; i++) {
        UIImage *image = self.imageArr[i];
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
            [self.imageArr removeAllObjects];
            [self.imagePathArr removeAllObjects];
            [self.imageUrlArr removeAllObjects];
            [imageView removeFromSuperview];
            
            [self.gridView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(ceilf(self.imageArr.count / 3.0) * self.rowHeight);
            }];
        }];
        [self.gridView addSubview:imageView];
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
    [XLPhotoBrowser showPhotoBrowserWithImages:self.imageArr currentImageIndex:0];
}

- (void)showImageAlert {
    if (self.imageArr.count >= kMaxCommentImageCount) {
        [YXProgressHUD showMessage:[NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Select a maximum of %zd photos"], kMaxCommentImageCount]];
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
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:kMaxCommentImageCount - self.imageArr.count delegate:nil];
    // 设置tz的bundle
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
            NSString* tempPath = QCloudTempFilePathWithExtension(@"jpg");
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

- (void)textViewDidChange:(YYTextView *)textView {
    if (textView.attributedText.length > 0  || self.imageArr.count > 0) {
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
        NSString* tempPath = QCloudTempFilePathWithExtension(@"jpg");
        [data writeToFile:tempPath atomically:YES];
        [self.imageArr addObject:compressImage];
        [self.imagePathArr addObject:tempPath];
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
    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
    if (transition.animationDuration == 0) {
        CGFloat offset = screenH - transition.toFrame.origin.y;        
        self.toolbar.qmui_bottom = self.view.height - offset;
    } else {
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption | UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGFloat offset = screenH - transition.toFrame.origin.y;
            self.toolbar.qmui_bottom = self.view.height - offset;
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
