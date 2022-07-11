//
//  OSSVAccountAdvertiView.m
// XStarlinkProject
//
//  Created by fan wang on 2021/6/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVAccountAdvertiView.h"
#import "OSSVAccountAdvertiItemView.h"
#import "STLActivityWWebCtrl.h"
#import "RateModel.h"
#import "OSSVWapsBannersAip.h"

@interface OSSVAccountAdvertiView ()
/*
 "result": {
         "wap_invite": {
             "banner_url": "",
             "link_url": ""
         },
         "wap_rotation": {
             "banner_url": "",
             "link_url": ""
         }
     },
 */
@property (strong,nonatomic) NSDictionary *jumpData;
@property (weak,nonatomic) OSSVAccountAdvertiItemView *coinEnter;
@property (weak,nonatomic) OSSVAccountAdvertiItemView *luckyDrawEnter;
@end

@implementation OSSVAccountAdvertiView

-(void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
//        UIView *devider = [[UIView alloc] init];
//        [self addSubview:devider];
//        devider.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
//        [devider mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.trailing.mas_equalTo(self);
//            make.height.mas_equalTo(12);
//        }];
        [self setupItems];
    }
    return self;
}

-(void)setupItems{
    OSSVAccountAdvertiItemView *coinEnter = [[OSSVAccountAdvertiItemView alloc] init];
    _coinEnter = coinEnter;
    coinEnter.tag = 1001;
    OSSVAccountAdvertiItemView *luckyDrawEnter = [[OSSVAccountAdvertiItemView alloc] init];
    luckyDrawEnter.tag = 1002;
    _luckyDrawEnter = luckyDrawEnter;
    
    if (APP_TYPE == 3) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
    } else {
        coinEnter.layer.cornerRadius = 6.0;
        coinEnter.layer.masksToBounds = YES;
        luckyDrawEnter.layer.cornerRadius = 6.0;
        luckyDrawEnter.layer.masksToBounds = YES;
    }

    [self addSubview:coinEnter];
    [self addSubview:luckyDrawEnter];
    NSArray *arr = @[coinEnter,luckyDrawEnter];
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        arr = @[luckyDrawEnter,coinEnter];
        ///阿语环境替换图片
    }
    
    if (APP_TYPE == 3) {
        [arr mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:7 leadSpacing:14 tailSpacing:14];
        [arr mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(14);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-14);
        }];
    } else {
        
        [arr mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:7 leadSpacing:12 tailSpacing:12];
        [arr mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    
    ///1.3.8 全埋点
    coinEnter.sensor_element_id = @"to_pull_new_image_view";
    luckyDrawEnter.sensor_element_id = @"to_lucky_draw_new_image_view";
//    coinEnter.backgroundColor = luckyDrawEnter.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
    [coinEnter addTarget:self action:@selector(didtapedButton:) forControlEvents:UIControlEventTouchUpInside];
    [luckyDrawEnter addTarget:self action:@selector(didtapedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceieveBannerInfo:) name:kAccountBannerNotiName object:nil];
}

-(void)didReceieveBannerInfo:(NSNotification *)noti{
    self.jumpData = noti.userInfo;
}

-(void)setJumpData:(NSDictionary *)jumpData{
    _jumpData = jumpData;
    self.luckyDrawEnter.bgUrl = jumpData[@"wap_rotation"][@"banner_url"];
    self.coinEnter.bgUrl = jumpData[@"wap_invite"][@"banner_url"];
}

-(void)didtapedButton:(OSSVAccountAdvertiItemView *)itemView{
    
    if (!USERID) {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        signVC.modalBlock = ^{

        };
        [self.viewController presentViewController:signVC animated:YES completion:nil];
        return;
    }
    
    NSString *urlString = nil;
    switch (itemView.tag) {
        case 1001:{
                
             [OSSVAnalyticsTool analyticsGAEventWithName:@"personal_action" parameters:@{
                    @"screen_group":@"Me",
                    @"action":@"Share_Earn"}];
            //拉新
            urlString = self.jumpData[@"wap_invite"][@"link_url"];
        }
            break;
        case 1002:{
            [OSSVAnalyticsTool analyticsGAEventWithName:@"personal_action" parameters:@{
                   @"screen_group":@"Me",
                   @"action":@"Lucky_Draw"}];
            //大转盘
            urlString = self.jumpData[@"wap_rotation"][@"link_url"];
        }
        default:
            break;
    }
    
    
    
    STLActivityWWebCtrl *webViewVC = [[STLActivityWWebCtrl alloc] init];
    NSString *lang = [STLLocalizationString shareLocalizable].nomarLocalizable; //语言
    RateModel *rate = [ExchangeManager localCurrency]; //当前货币
    NSString  *versionStr = kAppVersion; //APP版本号
    NSString *device_id = [OSSVAccountsManager sharedManager].device_id;
    NSString *platform = @"ios";
    NSString *urlStr = [NSString stringWithFormat:@"%@?token=%@&lang=%@&currency=%@&version=%@&platform=%@&device_id=%@",urlString,STLToString(USER_TOKEN),lang,rate.code,versionStr,platform,device_id];
    webViewVC.strUrl = urlStr;
    [self.navigationController pushViewController:webViewVC animated:YES];
}

@end
