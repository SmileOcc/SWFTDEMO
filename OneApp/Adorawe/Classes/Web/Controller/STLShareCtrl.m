//
//  STLShareCtrl.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLShareCtrl.h"
#import <Twitter/Twitter.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "STLPinterestCtrl.h"
#import "UIView+STLCategory.h"
#import "RateModel.h"
#import "STLShareViewModel.h"
#import "STLShareEarnModel.h"
#import "STLStrongFellCtrl.h"
#import "STLShareItemCell.h"
#import "Adorawe-Swift.h"

@import SCSDKCreativeKit;



static NSInteger const KPlatformCount    = 3;
static NSInteger const KContentViewHight = 300;
static NSInteger const KContentViewHightNew = 300;
static NSInteger const KFacebookTag      = 0;
static NSInteger const KMessenageTag          = 1;
static NSInteger const KCopyTag      = 2;
static NSInteger const KPinterestTag     = 3;
static NSInteger const KMaskViewTag      = 4;

@interface STLShareCtrl ()<STLPinterestDelegate,FBSDKSharingDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UIView   *contentView;
@property (nonatomic,strong) UIButton *topBtn;
@property (nonatomic,strong) UIButton *disBtn;
@property (nonatomic,strong) UIView   *topView;
@property (nonatomic,strong) UILabel  *titleLabel;
@property (nonatomic,strong) UIView   *topLineView;
@property (nonatomic,strong) UIView   *centerView;
@property (nonatomic,strong) UICollectionView   *centerColl;
@property (nonatomic,strong) UIView   *line;
@property (nonatomic,strong) UIButton *closeBtn;
@property (nonatomic,strong) YYAnimatedImageView *earnImgV;
@property (nonatomic,strong) UIActivityIndicatorView *actView;

@property (nonatomic,strong) STLShareViewModel *viewModel;
@property (nonatomic,strong) STLShareEarnModel *shareModel;
@property (nonatomic,strong) STLStrongFellCtrl *fellCtrl;

@property (nonatomic,strong) NSArray *itemArray;

@property (nonatomic,strong) SCSDKSnapAPI *snapApi;

@property (nonatomic,strong) YYAnimatedImageView *imgView;

@end

@implementation STLShareCtrl

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.actView];
    [self.actView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
    }];
    [self requstData];
    _snapApi = [[SCSDKSnapAPI alloc] init];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIView animateWithDuration:0.2 animations:^{
        if (self.sourceViewController) {
            self.sourceViewController.navigationController.tabBarController.tabBar.hidden = NO;
        }
    }];
}

#pragma mark - initUI
- (void)congifUI
{
//    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDismiss:)];
//    [self.view addGestureRecognizer:tap];
//    self.view.tag = 4;
    [self.view addSubview:self.topBtn];
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.topView];
    [self.contentView addSubview:self.centerView];
    [self.centerView addSubview:self.centerColl];
    [self.contentView addSubview:self.topLineView];
    [self.contentView addSubview:self.line];
    [self.contentView addSubview:self.closeBtn];
    [self.topView addSubview:self.titleLabel];
    [self.view addSubview:self.earnImgV];
//    [self.topView addSubview:self.disBtn];
    
    /// test
    CGFloat contentViewHeight = 0.0f;
    CGFloat topOffSet = 0.0f;
    CGFloat w = 1.0;
    CGFloat h = 1.0;
    // h5分享展示图片  详情页分享展示图片
    if (!self.shareModel.flow_pic || self.type == 2) {
        contentViewHeight = KContentViewHight;
        topOffSet = 0.0f;
        self.earnImgV.hidden = YES;
    }else{
        contentViewHeight = KContentViewHightNew;
        topOffSet = KContentViewHightNew - KContentViewHight;
        self.earnImgV.hidden = NO;
        NSString *flowpic = self.shareModel.flow_pic[@"url"];
        [self.earnImgV yy_setImageWithURL:[NSURL URLWithString:flowpic] placeholder:nil];
        
        w = [self.shareModel.flow_pic[@"width"] floatValue];
        h = [self.shareModel.flow_pic[@"height"] floatValue];
    }
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom);
        if (kIS_IPHONEX) {
            make.height.mas_equalTo(contentViewHeight+STL_TABBAR_IPHONEX_H);
        } else {
            make.height.mas_equalTo(contentViewHeight);
        }
    }];
//    [self.contentView layoutIfNeeded];
//    [self.contentView stlAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(6, 6)];
    
    [self.topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.contentView.mas_top);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView.mas_top).offset(topOffSet);
        make.height.mas_equalTo(@49);
    }];
    
//    [self.disBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.trailing.mas_equalTo(self.topView.mas_trailing).offset(-12);
//        make.centerY.mas_equalTo(self.topView.mas_centerY);
//        make.width.height.mas_equalTo(@20);
//    }];
    
    CGFloat width = SCREEN_WIDTH - 72;
    [self.earnImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(36);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-36);
        make.bottom.mas_equalTo(self.titleLabel.mas_top).offset(-32);
        make.height.mas_equalTo(width*h/w);
    }];
    
    [self.earnImgV layoutIfNeeded];
    if (APP_TYPE != 3) {
        [self.earnImgV stlAddCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(6, 6)];
    }
   
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.topView.mas_bottom);
        make.center.mas_equalTo(self.topView);
    }];
    
    [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.topView.mas_bottom);
    }];
    
    [self.centerColl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.centerView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
    
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.centerView);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.height.mas_equalTo(@0.5);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.closeBtn.mas_top);
        make.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(@0.5);
    }];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).mas_offset(12);
        make.trailing.equalTo(self.contentView.mas_trailing).mas_offset(-12);
        make.top.mas_equalTo(self.centerView.mas_bottom);
        make.height.mas_equalTo(@48);
        if (kIS_IPHONEX) {
            make.bottom.mas_equalTo(self.contentView).offset(-STL_TABBAR_IPHONEX_H);
        } else {
            make.bottom.mas_equalTo(self.contentView).offset(-12);
        }
    }];
    
    if (!self.shareModel.flow_pic || self.type == 2) {
        //不展示
    }else{
        // 展示
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (kIS_IPHONEX) {
                make.height.mas_equalTo(contentViewHeight+STL_TABBAR_IPHONEX_H + 51);
            } else {
                make.height.mas_equalTo(contentViewHeight + 51);
            }
        }];
        
        
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@110);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.topView.mas_bottom).offset(-24);
            make.centerX.mas_equalTo(self.topView.mas_centerX);
        }];
    }
    [self.contentView layoutIfNeeded];
    if (APP_TYPE != 3) {
        [self.contentView stlAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(6, 6)];
    }
    
    
    [self.centerColl reloadData];
}

- (void)configStrongFellUI{
    NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:3];
    if (self.shareModel.flow_notice_detail && self.shareModel.flow_notice_detail.count > 0) {
        for (int i = 0; i<self.shareModel.flow_notice_detail.count; i++) {
            NSDictionary *dic = self.shareModel.flow_notice_detail[i];
            NSString *imgUrl = [dic objectForKey:@"url"];
            [imgs addObject:imgUrl];
        }
    }
    
    STLStrongFellCtrl *fellCtrl = [STLStrongFellCtrl new];
    fellCtrl.imgsArr = [imgs copy];
    fellCtrl.imgsObjestArr = self.shareModel.flow_notice_detail;
    self.fellCtrl = fellCtrl;
    [self.view addSubview:self.fellCtrl.view];
    [self.fellCtrl.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view.mas_height);
    }];
    
    [self performSelector:@selector(addStrongFellAnimation) withObject:nil afterDelay:0.1];
    
    fellCtrl.closeblock = ^{
        [UIView animateWithDuration:0.8 animations:^{
            [self.fellCtrl.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.view.mas_bottom);
            }];
            [self.fellCtrl.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.fellCtrl.view removeFromSuperview];
            [self.fellCtrl removeFromParentViewController];
            [self congifUI];
            
            [self performSelector:@selector(addInAnimation) withObject:nil afterDelay:0.1];
        }];
        
    };
    
    [self addChildViewController:self.fellCtrl];
}

- (void)addStrongFellAnimation{
    [UIView animateWithDuration:0.5 animations:^{
        [self.fellCtrl.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top);
        }];
        [self.fellCtrl.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        // 已经展示过强烈感知模块了
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kShareStrongFell];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)addInAnimation
{
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat contentViewHeight = 0.0f;
        if (!self.shareModel.flow_pic || self.type == 2) {
            contentViewHeight = KContentViewHight;
        }else{
            contentViewHeight = KContentViewHightNew + 51;
        }

        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (kIS_IPHONEX) {
                make.top.mas_equalTo(self.view.mas_bottom).offset(-contentViewHeight-STL_TABBAR_IPHONEX_H);
            } else {
                make.top.mas_equalTo(self.view.mas_bottom).offset(-contentViewHeight);
            }
        }];
        [self.view layoutIfNeeded];
    }];
    
}

- (void)addOutAnimation:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                             
                             make.top.mas_equalTo(self.view.mas_bottom);
                         }];
                         [self.view layoutIfNeeded];
                     }
                     completion:completion];
}

#pragma mark - Action
- (void)tapDismiss:(UITapGestureRecognizer *)sender
{

    NSInteger tag = sender.view.tag;
    switch (tag) {

        case KMaskViewTag:
        {
            CGPoint point = [sender locationInView:self.view];
            [self dismissShareViewControllerIfContainsPoint:point];
        }
            break;
        default:
            break;
    }
    
}

- (void)closeBtnClick
{
    @weakify(self);
    [self addOutAnimation:^(BOOL finished) {
        @strongify(self);
        if (finished) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(STL_dismissViewControllerAnimated:channel:success:completion:)]) {
                [self.delegate STL_dismissViewControllerAnimated:NO channel:@"" success:NO completion:nil];
            }
            
            [self dismissViewControllerAnimated:NO completion:^{
            }];
        }
    }];
    
}
/// 网络请求
- (void)requstData{
    [self requestShareWithCompletion];
}

/// 通过接口获取带归因的短链
- (void)requestShareWithCompletion{
    NSDictionary *parm = nil;
    if ([OSSVNSStringTool isEmptyString:self.h5UrlStr]) {
        parm = @{@"type":@(self.type), @"sku":self.sku};
    }else{
        parm = @{@"type":@(self.type), @"h_url":self.h5UrlStr};
    }
    @weakify(self);
    [self.actView startAnimating];
    [self.viewModel requestShareAndEarnNetwork:parm completion:^(id  _Nonnull obj) {
        @strongify(self);
        [self.actView stopAnimating];
        self.shareModel = (STLShareEarnModel *)obj;
        // 是否展示强烈感知
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:kShareStrongFell]) {
            // 已经展示过强烈感知模块
            [self congifUI];
            [self performSelector:@selector(addInAnimation) withObject:nil afterDelay:0.1];
        }else{
            [self configStrongFellUI];
        }
        
        self.shareContent = self.shareModel.share[@"description"];
        if (self.type == 2) {
            // h5页面没有title
            self.shareTitle = self.shareModel.share[@"title"];
        }
        
    } failure:^(id  _Nonnull obj) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.actView stopAnimating];
    }];
}

/// 分享结果
- (void)shareResult:(BOOL)success channel:(NSString *)channel shareTip:(NSString *)shareTip{
    
    
    @weakify(self);
    [self addOutAnimation:^(BOOL finished) {
        @strongify(self);
        if (finished) {
            
            if (success) {
                
                //        NSString *pageName = [UIViewController currentTopViewControllerPageName];
                //        pageName = STLToString(self.shareSourcePageName);
                NSDictionary *sensorsDic = @{@"share_source":STLToString(channel),
                                             @"referrer":STLToString(self.shareSourcePageName),
                                             @"url":STLToString(self.shareSourceId),
                };
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"Share" parameters:sensorsDic];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(STL_dismissViewControllerAnimated:channel:success:completion:)]) {
                    [self.delegate STL_dismissViewControllerAnimated:success channel:STLToString(channel) success:YES completion:nil];
                }
            } else {
                
                if ([self.delegate respondsToSelector:@selector(STL_shareFailWithError:)]) {
                    [self.delegate STL_shareFailWithError:nil];
                }
            }
            
            [self dismissViewControllerAnimated:NO completion:^{
                [HUDManager showHUDWithMessage:STLToString(shareTip)];
            }];
        }
    }];
    
}

#pragma mark - Private method
- (void)dismissShareViewControllerIfContainsPoint:(CGPoint)point {
    CGRect tapRect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KContentViewHight);
    if (CGRectContainsPoint(tapRect, point)) {
        [self closeBtnClick];
    }
    
}

- (NSString *)handShareUrl:(NSString *)sharePlatom {
    
//    NSString *url = self.shareURL;
//    if (self.isAddUser && !STLIsEmptyString(self.shareURL)) {
//
//        NSString *version = kAppVersion;
//        NSString *lang = [STLLocalizationString shareLocalizable].nomarLocalizable;
//        NSString *platform = @"ios";
//        NSString *device = STLToString([OSSVAccountsManager sharedManager].device_id);
//        RateModel *rate = [ExchangeManager localCurrency];
//
//        NSString *parmsString = [NSString stringWithFormat:@"uid=%@&currency=%@&lang=%@&version=%@&platform=%@&device_id=%@",USERID_STRING, rate.code,lang,version,platform,device];
//
//        if (!STLIsEmptyString(sharePlatom)) {
//            parmsString = [NSString stringWithFormat:@"%@&channel=%@",parmsString,sharePlatom];
//        }
//
//        STLLog(@"shareUrl: %@&params=%@",self.shareURL,parmsString);
//
//        if ([self.shareURL rangeOfString:@"?"].location != NSNotFound) {
//            url = [NSString stringWithFormat:@"%@&params=%@",self.shareURL,[parmsString base64String]];
//        } else {
//            url = [NSString stringWithFormat:@"%@?params=%@",self.shareURL,[parmsString base64String]];
//        }
//    }
//
//    return url;
    if ([sharePlatom isEqualToString:@"Facebook"]) {
        return STLToString(self.shareModel.url[@"facebook"]);
    }else if ([sharePlatom isEqualToString:@"Copylink"]){
        return STLToString(self.shareModel.url[@"Copylink"]);
    }else if ([sharePlatom isEqualToString:@"WhatsApp"]){
        return STLToString(self.shareModel.url[@"whatsapp"]);
    }else if ([sharePlatom isEqualToString:@"SnapChat"]){
        return STLToString(self.shareModel.url[@"Snapchat"]);
    }else if ([sharePlatom isEqualToString:@"Instagram"]){
        return STLToString(self.shareModel.url[@"Instagram"]);
    }
    return STLToString(self.shareURL);
}

- (void)shareWhatsApp {
    NSString *url = [NSString stringWithFormat:@"whatsapp://send?text=%@%@%@%@%@", self.shareTitle, @"\n",self.shareContent, @"\n",[self handShareUrl:@"WhatsApp"]];
    url =  URLENCODING(url);
    NSURL *whatsappURL = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL:whatsappURL options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:nil];
        
        [self shareResult:YES channel:@"WhatsApp" shareTip:STLLocalizedString_(@"shareSucceess", nil)];
        
    } else {
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if (self.shareURL) {
            pasteboard.string = [self handShareUrl:@"Copylink"];
        }
        
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id310633997"];
        [[UIApplication sharedApplication]openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:^(BOOL success) {
            if (success) {
                STLLog(@"10以后可以跳转url");
            }else{
                STLLog(@"10以后不可以跳转url");
            }
        }];
    }
}

- (void)shareToFacebook {
    
    FBSDKShareLinkContent  *content = [[FBSDKShareLinkContent alloc] init];

    if (self.shareURL)      content.contentURL = [NSURL URLWithString:[self handShareUrl:@"Facebook"]];
    
    NSString *shareContent = @"";
    if (self.shareTitle) {
        shareContent = self.shareTitle;
    }
    if (self.shareContent) {
        if (!STLIsEmptyString(shareContent)) {
            shareContent = [NSString stringWithFormat:@"%@ \n\n %@",shareContent, self.shareContent];
        } else {
            shareContent = self.shareContent;
        }
    }
    if (!STLIsEmptyString(shareContent)) {
        content.quote = shareContent;
    }

    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.mode = FBSDKShareDialogModeNative;
    if (![dialog canShow]) {
        dialog.mode = FBSDKShareDialogModeFeedWeb;
    }
    dialog.shareContent = content;
    dialog.delegate = self;
    [dialog show];
}

- (void)shareToMessenger {
//    FBSDKShareLinkContent  *content = [[FBSDKShareLinkContent alloc] init];
//    if (self.shareContent)  content.contentDescription = self.shareContent;
//    if (self.shareURL)      content.contentURL = [NSURL URLWithString:self.shareURL];
//    if (self.shareTitle)    content.contentTitle = self.shareTitle;
//    if (self.shareImage)    content.imageURL = [NSURL URLWithString:self.shareImage];
//    
//    [FBSDKMessageDialog showWithContent:content delegate:self];
    
//    FBSDKMessengerShareOptions *content = [[FBSDKMessengerShareOptions alloc] init];
//    content.sourceURL = [NSURL URLWithString:self.shareURL];
//    content.renderAsSticker = YES;
//    [FBSDKMessengerSharer shareImage:[UIImage imageNamed:@"enjoy"] withOptions:content];
    
    
//    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//    
//    
//    [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
//    {
//        
//        if (error)
//        {
//            // Process error
//        }
//        else if (result.isCancelled)
//        {
//            // Handle cancellations
//        }
//        else
//        {
//            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
////            content.imageURL = [NSURL URLWithString:self.shareImage];
////            content.contentTitle = self.shareTitle;
//            NSString *url = self.shareURL;
//            if ([url containsString:@"?"]) {
//                url = [url stringByAppendingString:@"utm_source=APPShare&utm_campaign=Messenger"];
//            }else{
//                url = [url stringByAppendingString:@"?utm_source=APPShare&utm_campaign=Messenger"];
//            }
//            content.contentURL = [NSURL URLWithString:url];
//
//            FBSDKMessageDialog *messageDialog = [[FBSDKMessageDialog alloc] init];
//            messageDialog.delegate = self;
//            [messageDialog setShareContent:content];
//            if ([messageDialog canShow]) {
//                [messageDialog show];
//            } else {
//                // Messenger isn't installed. Redirect the person to the App Store.
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/en/app/facebook-messenger/ffxxxxxid454638411xx?mt=8"] options:@{} completionHandler:nil];
//
//            }
//        }
//    }];
}

- (void)shareToTwitter {
    BOOL isAvailable = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
    if (isAvailable)
    {
        SLComposeViewController *composeVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        if (!composeVC) {
            return;
        }

        [HUDManager showLoading];
        [self presentViewController:composeVC animated:YES completion:^{

            [HUDManager hiddenHUD];
        }];
        
        //文本
        if (self.shareContent) [composeVC setInitialText:@"@Adorawe, really <3 this! So many boutiques on Adorawe. Check it out!"];

        //超链接
        if (self.shareURL) [composeVC addURL:[NSURL URLWithString:self.shareURL]];
        
        //图片
        YYAnimatedImageView *imgView = [[YYAnimatedImageView alloc] init];
        
        [imgView yy_setImageWithURL:[NSURL URLWithString:self.shareImage]
                        placeholder:nil
                            options:YYWebImageOptionShowNetworkActivity
                           progress:nil
                          transform:nil
                         completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                      if (image) [composeVC addImage:image];
        }];
        
        __weak SLComposeViewController *weakComposeVC = composeVC;
        //完成后回调
        [composeVC setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             switch (result) {
                 case SLComposeViewControllerResultCancelled:
                     if (APP_TYPE == 3) {
                         [HUDManager showHUDWithMessage:STLLocalizedString_(@"cancel",nil)];
                     } else {
                         [HUDManager showHUDWithMessage:STLLocalizedString_(@"cancel",nil).uppercaseString];
                     }
                     break;
                 case SLComposeViewControllerResultDone:
                 {
//                     [HUDManager showShimmerMessage:@"Shared successfully"];
                     [HUDManager showHUDWithMessage:STLLocalizedString_(@"shareSucceess", nil)];

                 }
                     break;
                 default:
                     [HUDManager showHUDWithMessage:@"Unkown error"];
                     break;
             }
             [weakComposeVC dismissViewControllerAnimated:YES completion:nil];
             
         }];
        
        return;
    }
    
    
    STLAlertViewController *alertController =  [STLAlertViewController alertControllerWithTitle: STLLocalizedString_(@"noTwitterAccount", nil) message: STLLocalizedString_(@"noTwitterAccountMessage", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * doneAction = [UIAlertAction actionWithTitle:STLLocalizedString_(@"Iknow", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
    [alertController addAction:doneAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)shareToSnapChat {

    NSString *shareUrl = [self handShareUrl:@"SnapChat"];
    NSURL *imgURL = [NSURL URLWithString:self.shareImage];
    
    
    SCSDKSnapPhoto *photo = [[SCSDKSnapPhoto alloc] initWithImageUrl:imgURL];
    SCSDKPhotoSnapContent *photoContent = [[SCSDKPhotoSnapContent alloc] initWithSnapPhoto:photo];
    photoContent.attachmentUrl = shareUrl;
    photoContent.caption = self.title;
    
    //self.shareTitle, @"\n",self.shareContent,
    
    [self.snapApi startSendingContent:photoContent completionHandler:^(NSError * _Nullable error) {
        if (error) {
            [self dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"SCSDKSnapAPI error: %@",error);
        }else{
            [self shareResult:YES channel:@"SnapChat" shareTip:STLLocalizedString_(@"shareSucceess", nil)];
        }
    }];
        
    
    
}

-(void)saveImageToAlibum:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didfinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didfinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if(!error){
        NSLog(@"保存成功");
//        NSString *url = [NSString stringWithFormat:@"instagram//library?AssetPath=assets-library&text=%@%@%@%@%@", self.shareTitle, @"\n",self.shareContent, @"\n",[self handShareUrl:@"Instagram"]];
        NSString *url = [NSString stringWithFormat:@"instagram://library?AssetPath=assets-library"];
        url =  URLENCODING(url);
        NSURL *instagramURL = [NSURL URLWithString:url];
        if ([[UIApplication sharedApplication] canOpenURL: instagramURL]) {
            [[UIApplication sharedApplication] openURL:instagramURL options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:nil];
            
            [self shareResult:YES channel:@"Instagram" shareTip:STLLocalizedString_(@"shareSucceess", nil)];
            
        } else {
            
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            if (self.shareURL) {
                pasteboard.string = [self handShareUrl:@"Copylink"];
            }
            
            NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id389801252"];
            [[UIApplication sharedApplication]openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:^(BOOL success) {
                if (success) {
                    STLLog(@"10以后可以跳转url");
                }else{
                    STLLog(@"10以后不可以跳转url");
                }
            }];
        }

    }else{
        NSLog(@"保存失败");
    }
}

- (void)shareToInstegma {
    if (!_imgView) {
        _imgView = [[YYAnimatedImageView alloc] init];
    }
    
    [self.actView startAnimating];
    
    @weakify(self);
    [self.imgView yy_setImageWithURL:[NSURL URLWithString:self.shareImage]
                    placeholder:nil
                        options:YYWebImageOptionShowNetworkActivity
                       progress:nil
                      transform:nil
                     completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        @strongify(self);
        [self.actView stopAnimating];
        if (image) {
            [self saveImageToAlibum:image];
        }else{
            [self saveImageToAlibum:self.imgView.image];
        }
    }];
    
    
}

- (void)copyShareURL {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.shareURL) {
        pasteboard.string = [self handShareUrl:@"Copylink"];
    }
    
    [self shareResult:YES channel:@"Copylink" shareTip:STLLocalizedString_(@"copiedSuccessfully", nil)];
}

- (void)shareToPinterest {
    
    STLPinterestCtrl *pin = [[STLPinterestCtrl alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    pin.delegate = self;
    pin.url = [self handShareUrl:@"Pinterest"];
    pin.image = self.shareImage;
    pin.content = @"Pretty little thing from Adorawe! Total <3! Check it out on Adorawe.";
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pin];
    nav.navigationBar.tintColor = OSSVThemesColors.col_EE4D4D;
    [self presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark - FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    
    [self shareResult:YES channel:@"Facebook" shareTip:STLLocalizedString_(@"shareSucceess", nil)];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    
    [self shareResult:NO channel:@"Facebook" shareTip:STLLocalizedString_(@"shareFail", nil)];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    @weakify(self);
    [self addOutAnimation:^(BOOL finished) {
        @strongify(self);
        
        if (finished) {
            [self dismissViewControllerAnimated:NO completion:^{
                if (APP_TYPE == 3) {
                    [HUDManager showHUDWithMessage:STLLocalizedString_(@"cancel",nil)];
                } else {
                    [HUDManager showHUDWithMessage:STLLocalizedString_(@"cancel",nil).uppercaseString];
                }
            }];
        }
    }];
    
}

#pragma mark --- collection
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.itemArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    STLShareItemCell *cell = [STLShareItemCell stlShareItemCellWithCollection:collectionView indexPath:indexPath];
    NSDictionary *dataDic = self.itemArray[indexPath.item];
    cell.dataDic = dataDic;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(collectionView.bounds.size.width/4-0.05, collectionView.bounds.size.width/4 - 0.05);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dataDic = self.itemArray[indexPath.item];
    ///尽量用逻辑index 方便修改
    NSInteger index = [dataDic[@"shareType"] integerValue];
    if (index == 0) {
        // facebook
        [GATools logGoodsDetailSimpleEventWithEventName:@"share_channel"
                                            screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.goodsBaseInfo.goodsTitle)]
                                             buttonName:@"facebook"];

        [self shareToFacebook];
    }else if(index == 1){
        // whatsapp
        [GATools logGoodsDetailSimpleEventWithEventName:@"share_channel"
                                            screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.goodsBaseInfo.goodsTitle)]
                                             buttonName:@"facebook"];
        [self shareWhatsApp];
    }else if(index == 2){
        // snapchat
        [GATools logGoodsDetailSimpleEventWithEventName:@"share_channel"
                                            screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.goodsBaseInfo.goodsTitle)]
                                             buttonName:@"whatsapp"];
        [self shareToSnapChat];
    }else if(index == 3){
        // instagram
        [GATools logGoodsDetailSimpleEventWithEventName:@"share_channel"
                                            screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.goodsBaseInfo.goodsTitle)]
                                             buttonName:@"instagram"];
        [self shareToInstegma];
    }else if(index == 4){
        // coplink
        [GATools logGoodsDetailSimpleEventWithEventName:@"share_channel"
                                            screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.goodsBaseInfo.goodsTitle)]
                                             buttonName:@"coplink"];
        [self copyShareURL];
    }
}

#pragma mark - PinterestDelegate
-(void)dismissPinterest
{
    NSLog(@"wocao!");
}

#pragma mark - Getter
-(UIView *)contentView
{
    if (!_contentView) {
//        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, kIS_IPHONEX ? KContentViewHight+STL_TABBAR_IPHONEX_H : KContentViewHight)];
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];

    }
    return _contentView;
}

-(UIView *)line
{
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _line;
}

-(UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.layer.borderColor = [OSSVThemesColors col_000000:1].CGColor;
        _closeBtn.layer.borderWidth = 2;
        _closeBtn.backgroundColor = [UIColor whiteColor];
        if (APP_TYPE == 3) {
            [_closeBtn setTitle:STLLocalizedString_(@"pay_CANCEL", nil)  forState:UIControlStateNormal];
        } else {
            [_closeBtn setTitle:[STLLocalizedString_(@"pay_CANCEL", nil) uppercaseString]  forState:UIControlStateNormal];
        }
        _closeBtn.titleLabel.font = [UIFont stl_buttonFont:14];
        [_closeBtn setTitleColor:[OSSVThemesColors stlBlackColor] forState:UIControlStateNormal];
        _closeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
 
    }
    return _closeBtn;
}

- (UIButton *)disBtn{
    if (!_disBtn) {
        _disBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_disBtn setImage:[UIImage imageNamed:@"share_close"] forState:UIControlStateNormal];
        [_disBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _disBtn;
}

- (UIView *)centerView {
    if (!_centerView) {
        _centerView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _centerView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _topView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.text = STLLocalizedString_(@"shareTo", nil);
    }
    return _titleLabel;
}

- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _topLineView.backgroundColor = [UIColor whiteColor];
    }
    return _topLineView;
}

- (YYAnimatedImageView *)earnImgV{
    if (!_earnImgV) {
        _earnImgV = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _earnImgV.backgroundColor = OSSVThemesColors.col_EEEEEE;
        _earnImgV.contentMode = UIViewContentModeScaleAspectFill;
        _earnImgV.clipsToBounds = YES;
    }
    return _earnImgV;
}

- (UIButton *)topBtn{
    if (!_topBtn) {
        _topBtn = [UIButton new];
        [_topBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topBtn;
}

- (STLShareViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[STLShareViewModel alloc] init];
    }
    return _viewModel;
}

- (UIActivityIndicatorView *)actView {
    if (!_actView) {
        _actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _actView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }
    return _actView;
}

- (UICollectionView *)centerColl{
    if (!_centerColl) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0.01;
        layout.minimumInteritemSpacing = 0.01;
        _centerColl = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _centerColl.dataSource = self;
        _centerColl.delegate = self;
        _centerColl.backgroundColor = [UIColor whiteColor];
        _centerColl.showsVerticalScrollIndicator = NO;
        _centerColl.showsHorizontalScrollIndicator = NO;
        _centerColl.scrollEnabled = NO;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _centerColl.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _centerColl;
}

-(NSArray *)itemArray{
    if (!_itemArray) {
        ///APP站点区分使用
        if(APP_TYPE == 1){
            _itemArray = @[@{@"imgStr":@"Share_Facebook", @"titStr":STLLocalizedString_(@"facebook", nil),@"shareType":@0},
                           @{@"imgStr":@"Share_Whats", @"titStr":STLLocalizedString_(@"WhatsApp", nil),@"shareType":@1},
                           @{@"imgStr":@"Share_Snap", @"titStr":STLLocalizedString_(@"snapchat", nil),@"shareType":@2},
                           @{@"imgStr":@"Share_ins", @"titStr":STLLocalizedString_(@"instagram", nil),@"shareType":@3},
                           @{@"imgStr":@"Share_Link", @"titStr":STLLocalizedString_(@"copyLink", nil),@"shareType":@4}];
        }else{
            _itemArray = @[@{@"imgStr":@"Share_Facebook", @"titStr":STLLocalizedString_(@"facebook", nil),@"shareType":@0},
                           @{@"imgStr":@"Share_Whats", @"titStr":STLLocalizedString_(@"WhatsApp", nil),@"shareType":@1},
                          // @{@"imgStr":@"Share_Snap", @"titStr":STLLocalizedString_(@"snapchat", nil),@"shareType":@2},
                           @{@"imgStr":@"Share_ins", @"titStr":STLLocalizedString_(@"instagram", nil),@"shareType":@3},
                           @{@"imgStr":@"Share_Link", @"titStr":STLLocalizedString_(@"copyLink", nil),@"shareType":@4}];
        }
        
    }
    return _itemArray;
}

@end
