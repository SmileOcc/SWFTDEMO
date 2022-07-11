//
//  OSSVAccountsHeadView.m
// XStarlinkProject
//
//  Created by odd on 2020/8/3.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVAccountsHeadView.h"
#import "UIColor+Extend.h"
#import "UIButton+STLCategory.h"

#import "OSSVAccountAdvertiView.h"
#import "OSSVAccountsServicesMenuView.h"

#import "Adorawe-Swift.h"

@interface OSSVAccountsHeadView()

@property (nonatomic, strong) UIView                    *settingBarView;
@property (nonatomic, strong) UIView                    *userInfoView;
@property (nonatomic, strong) UIView                    *topBlackBgView;
@property (nonatomic, strong) UIView                    *bottomBgColorView;

/// 用户信息、设置
@property (nonatomic, strong) YYAnimatedImageView       *headImageView;
@property (nonatomic, strong) UIButton                  *photoButton;
@property (nonatomic, strong) UIImageView               *registerArrowImageView;
@property (nonatomic, strong) UIButton                  *loginRegisterButton;
@property (nonatomic, strong) UserNameLevelView         *userNameButton;
@property (nonatomic, strong) UILabel                   *registerTipLabel;
@property (nonatomic, strong) UIButton                  *settingButton;
@property (nonatomic, strong) UIButton                  *messageButton;
@property (nonatomic, strong) UIView                    *redDotMessageView;

/// 优惠券、收藏、会员、金币
@property (nonatomic, strong) UIView                    *typeView;
/// 绑定电话号码
@property (nonatomic, strong) UIView                    *bindIphoneView;
@property (nonatomic, strong) UIView                    *phoneTipView;
@property (nonatomic, strong) UIImageView               *phoneActivtyImageView;
@property (nonatomic, strong) UILabel                   *phoneTipLabel;
@property (nonatomic, strong) UIButton                  *phoneBindButton;
@property (nonatomic, strong) UIButton                  *phoneCloseButton;
/// 订单
@property (nonatomic, strong) UIView                    *orderTopSpaceView;
@property (nonatomic, strong) UIView                    *orderView;
@property (nonatomic, strong) UIView                    *orderTitleView;
@property (nonatomic, strong) UIView                    *orderLineView;
@property (nonatomic, strong) UIView                    *orderContentView;
@property (nonatomic, strong) UILabel                   *orderTitleLabel;
@property (nonatomic, strong) UIButton                  *orderMoreButton;
@property (nonatomic, strong) UIImageView               *lineImageView;

/// 其他服务
@property (nonatomic, strong) UIView                    *servicesView;
///列表形式
@property (nonatomic, strong) OSSVAccountHeadServicTableView *serviceTableView;
///格子按钮形式
@property (nonatomic, strong) OSSVAccountsServicesMenuView  *serviceMenuView;
/// 关注我们
@property (nonatomic, strong) OSSVFollowsUssView           *followUsView;
@property (nonatomic, strong) NSMutableArray                                     *typeArrays;
@property (nonatomic, strong) NSMutableArray<OSSVAccountsMenuItemsModel*>           *orderArrays;
@property (nonatomic, strong) NSMutableArray            *servicesArrays;

@property (nonatomic, strong) NSMutableArray            *orderStatusArray;
@property (nonatomic, strong) OSSVAccountAdvertiView   *advertiseView;


@end


@implementation OSSVAccountsHeadView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        [self updateServiceDatas];
        
        [self stlInitView];
        [self stlAutoLayoutView];
        
        [self reloadUserInfo];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)updateServiceDatas {
    
    [self.servicesArrays removeAllObjects];
    BOOL isLogin = [OSSVAccountsManager sharedManager].isSignIn;
    NSInteger count = isLogin ? 4 : 2;
    for(int i=0; i<count; i++) {
        OSSVAccountsMenuItemsModel *itemModel = [[OSSVAccountsMenuItemsModel alloc] init];
        itemModel.index = i;
        [_servicesArrays addObject:itemModel];
        
        itemModel.itemCount = @"";
        if (isLogin) {
            if(i == 0) {
                itemModel.itemTitle = STLLocalizedString_(@"Address", nil);
                itemModel.itemImage = @"account_address";
                itemModel.type = AccountServicesAddress;

            } else if(i == 1) {
                itemModel.itemTitle = STLLocalizedString_(@"Setting_Cell_Languege", nil);
                itemModel.itemImage = @"account_language";
                itemModel.type = AccountServicesLanguage;

            } else if(i == 2) {
                itemModel.itemTitle = STLLocalizedString_(@"Currency", nil);
                itemModel.itemImage = @"account_currency";
                itemModel.type = AccountServicesCurrency;
                
            }  else if(i == 3) {
                itemModel.itemTitle = STLLocalizedString_(@"My_Size", nil);
                itemModel.itemImage = @"account_mySize";
                itemModel.type = AccountServicesMySize;
            }
        } else {
            
            if(i == 0) {
                itemModel.itemTitle = STLLocalizedString_(@"Setting_Cell_Languege", nil);
                itemModel.itemImage = @"account_language";
                itemModel.type = AccountServicesLanguage;

            } else if(i == 1) {
                itemModel.itemTitle = STLLocalizedString_(@"Currency", nil);
                itemModel.itemImage = @"account_currency";
                itemModel.type = AccountServicesCurrency;
            }
        }
    }
}
-(OSSVAccountAdvertiView *)advertiseView{
    if (!_advertiseView) {
        _advertiseView = [[OSSVAccountAdvertiView alloc] initWithFrame:CGRectZero];
        _advertiseView.hidden = YES;
    }
    return _advertiseView;
}

- (void)stlInitView {
    [self addSubview:self.topBlackBgView];
    [self addSubview:self.bottomBgColorView];
    [self addSubview:self.settingBarView];
    [self addSubview:self.userInfoView];
    
    [self.settingBarView addSubview:self.settingButton];
    [self.settingBarView addSubview:self.messageButton];
    
    [self.userInfoView addSubview:self.headImageView];
    [self.userInfoView addSubview:self.photoButton];
    [self.userInfoView addSubview:self.registerArrowImageView];
    [self.userInfoView addSubview:self.loginRegisterButton];
    [self.userInfoView addSubview:self.registerTipLabel];
    [self.userInfoView addSubview:self.userNameButton];
    [self.userInfoView addSubview:self.redDotMessageView];
    
    [self addSubview:self.typeView];
    [self addSubview:self.bindIphoneView];
    
    [self.bindIphoneView addSubview:self.phoneTipView];
    [self.bindIphoneView addSubview:self.phoneActivtyImageView];
    [self.bindIphoneView addSubview:self.phoneTipLabel];
    [self.bindIphoneView addSubview:self.phoneBindButton];
    [self.bindIphoneView addSubview:self.phoneCloseButton];
    
    [self addSubview:self.orderTopSpaceView];
    [self addSubview:self.orderView];
    [self.orderView addSubview:self.orderTitleView];
    [self.orderView addSubview:self.orderContentView];
    [self.orderView addSubview:self.orderTitleLabel];
    [self.orderView addSubview:self.lineImageView];
    [self.orderView addSubview:self.orderMoreButton];
    [self.orderView addSubview:self.orderLineView];

    [self addSubview:self.servicesView];
    [self.servicesView addSubview:self.serviceTableView];
    [self.servicesView addSubview:self.serviceMenuView];
    [self.servicesView addSubview:self.followUsView];
    
    ///1.3.8 加入两个广告入口
    [self addSubview:self.advertiseView];
    
    [self.bottomBgColorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.top.mas_equalTo(self.topBlackBgView.mas_bottom);
    }];
    
    if (APP_TYPE == 3) {
        self.lineImageView.hidden = NO;
    }
    
}

+ (CGFloat)pheneViewHeight:(BOOL)hasPhone {
    CGFloat phoneH = 0;

    //8 间距
    if (hasPhone) {
        phoneH = 28 + 8;
        if (APP_TYPE == 3) {
            phoneH = 28;
        }
    }
    return phoneH;
}

+ (CGFloat)accountHeaderContentH:(BOOL)showAdvbanner {
    CGFloat topSpaec = kSCREEN_BAR_HEIGHT;
    
    CGFloat settingBarHeight = 44;
    //往上移动8
    CGFloat userHeader = 60-8;
    CGFloat typeViewH = 62;
    CGFloat phoneSpaace = 8;
    CGFloat orderTopSpace = 0;
    //3站有8的间隙
    if (APP_TYPE == 3) {
        orderTopSpace = 8;
    }

    CGFloat phoneH = 0;
    NSInteger isBind = [OSSVAccountsManager sharedManager].account.is_bind_phone; //是否绑定
    BOOL isCloseBindView = [OSSVAccountsManager sharedManager].isCloseBindPhone;// 是否关闭
    BOOL isLoging = [OSSVAccountsManager sharedManager].isSignIn;
    if (isLoging && isBind == 0 && !isCloseBindView && !STLIsEmptyString([OSSVAccountsManager sharedManager].account.bind_phone_award)) {
        phoneH = [self pheneViewHeight:YES];
    }
   
    CGFloat orderViewH = 40 + 58 + 6;
    if (APP_TYPE == 3) {
        orderViewH = 40 + 58 + 6 + 5;
    }

    CGFloat serviceViewH = [OSSVAccountsHeadView serviceHeight];
    
    CGFloat advBannerHeight = 0;
//    if (showAdvbanner) {
//        if (app_type == 3) {
//            CGFloat advertiseW = (SCREEN_WIDTH - 14 * 2 -7) / 2.0;
//            CGFloat ratio = (76.0/172);
//            advBannerHeight= advertiseW * ratio + 8 + 14*2;
//        } else {
//            CGFloat advertiseW = (SCREEN_WIDTH - 12 * 2 -7) / 2.0;
//            CGFloat ratio = (76.0/172);
//            advBannerHeight= advertiseW * ratio + 8;
//        }
//    }
    return topSpaec + settingBarHeight + userHeader + typeViewH + phoneSpaace + phoneH + orderTopSpace + orderViewH + 8 + serviceViewH + 8 + advBannerHeight;
}

+ (CGFloat)serviceHeight {
    
    CGFloat serviceH = 40 * 5;
    if (APP_TYPE == 3) {
        serviceH = [OSSVAccountsServicesMenuView contentHeight] + [OSSVFollowsUssView contentHeigth];
    } else {
        if (USERID) {
            serviceH = 40 * 6 + [OSSVFollowsUssView contentHeigth];
        }
    }
    return serviceH;
}

+ (CGFloat)topBlackBgHeight {
    return kIPHONEX_TOP_SPACE + 44 + 74 + 124;
}

- (void)stlAutoLayoutView {
    
    CGFloat topSpaec = kSCREEN_BAR_HEIGHT;
    CGFloat leftSpace = 24;
    if (APP_TYPE == 3) {
        leftSpace = 14;
    }
    [self.settingBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(topSpaec);
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(44);
    }];
    
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.settingBarView.mas_bottom).offset(-8);
        make.height.mas_equalTo(60);
        make.leading.trailing.mas_equalTo(self);
    }];
    
    [self.topBlackBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self);
        make.height.mas_equalTo([OSSVAccountsHeadView topBlackBgHeight]);
    }];
    
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.settingBarView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.settingBarView.mas_top).offset(8);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.settingButton.mas_leading).offset(-16);
        make.centerY.mas_equalTo(self.settingButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.redDotMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageButton.mas_top);
        make.width.height.mas_equalTo(8);
        make.leading.equalTo(self.messageButton.mas_trailing).offset(-2);
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userInfoView.mas_leading).offset(leftSpace);
        make.size.mas_equalTo(CGSizeMake(48, 48));
        make.top.mas_equalTo(self.userInfoView.mas_top);
    }];
    
    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(48, 48));
        make.centerX.centerY.mas_equalTo(self.headImageView);
    }];
    
    [self.registerArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.loginRegisterButton.mas_trailing);
        make.centerY.mas_equalTo(self.loginRegisterButton.mas_centerY);
    }];
    
    [self.loginRegisterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userInfoView.mas_leading).offset(24);
        make.top.mas_equalTo(self.userInfoView);
    }];
    
    [self.userNameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.headImageView.mas_trailing).offset(8);
        make.centerY.mas_equalTo(self.headImageView.mas_centerY);
        make.trailing.mas_equalTo(self.userInfoView.mas_trailing).offset(-(48 + 24 + 16));
    }];
    
    [self.registerTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.loginRegisterButton.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.loginRegisterButton.mas_leading);
        make.width.mas_lessThanOrEqualTo((SCREEN_WIDTH - 48));
    }];
    
    ////
    [self.typeView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE==3) {
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
        } else {
            make.leading.mas_equalTo(self.mas_leading).offset(12+14);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-26);
        }
        make.top.mas_equalTo(self.userInfoView.mas_bottom);
        make.height.mas_equalTo(62);
    }];
    
    ////
    [self.bindIphoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.leading.mas_equalTo(self);
            make.trailing.mas_equalTo(self.mas_trailing);
        } else {
            make.leading.mas_equalTo(self).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        }
        make.top.mas_equalTo(self.typeView.mas_bottom).offset(8);
        make.height.mas_equalTo(0);
    }];
    
    [self.phoneTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.bindIphoneView);
        make.height.mas_equalTo(28);
    }];
    
    [self.phoneActivtyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.phoneTipView.mas_leading).offset(14);
        make.centerY.mas_equalTo(self.phoneTipView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    
    [self.phoneCloseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.phoneTipView.mas_trailing).offset(-14);
        make.width.height.mas_equalTo(12);
        make.centerY.mas_equalTo(self.phoneTipView.mas_centerY);
    }];
    
    [self.phoneTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.phoneActivtyImageView.mas_trailing).offset(4);
        make.centerY.mas_equalTo(self.phoneTipView.mas_centerY);
        make.trailing.mas_equalTo(self.phoneCloseButton.mas_trailing).offset(-2);
    }];
    
    [self.phoneBindButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self.phoneTipView);
        make.trailing.mas_equalTo(self.phoneCloseButton.mas_leading);
    }];
    
    self.orderTopSpaceView.hidden = YES;
    if (APP_TYPE == 3) {
        self.orderTopSpaceView.hidden = NO;
    }
    [self.orderTopSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.bindIphoneView.mas_bottom);
        if (APP_TYPE == 3) {
            make.height.mas_equalTo(8);
        } else {
            make.height.mas_equalTo(0);
        }
    }];
    
    ///
    [self.orderView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.leading.mas_equalTo(self);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.height.mas_equalTo(40 + 58 + 6 + 5);
        } else {
            make.leading.mas_equalTo(self).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.height.mas_equalTo(40 + 58 + 6);
        }
        make.top.mas_equalTo(self.orderTopSpaceView.mas_bottom);
    }];
    
    
    [self.orderTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.orderView);
        make.height.mas_equalTo(40);
    }];
    
    [self.orderContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.leading.mas_equalTo(self.orderView.mas_leading);
            make.trailing.mas_equalTo(self.orderView.mas_trailing);
            make.top.mas_equalTo(self.orderTitleView.mas_bottom).offset(5);
        } else {
            make.leading.mas_equalTo(self.orderView.mas_leading).offset(14);
            make.trailing.mas_equalTo(self.orderView.mas_trailing).offset(-14);
            make.top.mas_equalTo(self.orderTitleView.mas_bottom);
        }

        make.bottom.mas_equalTo(self.orderView);
    }];
    
    [self.orderTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.orderTitleView.mas_leading).offset(14);
        make.top.mas_equalTo(self.orderTitleView.mas_top).offset(14);
    }];
    
    [self.orderMoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.orderTitleView.mas_trailing).offset(-14);
        make.centerY.mas_equalTo(self.orderTitleLabel.mas_centerY);
    }];
    
    [self.lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.orderMoreButton);
        make.bottom.mas_equalTo(self.orderMoreButton.mas_bottom).offset(-4);
        make.height.mas_equalTo(1);
    }];
    
    [self.orderLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.orderTitleView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.orderTitleView.mas_trailing).offset(-14);
        make.bottom.mas_equalTo(self.orderTitleView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.servicesView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
        } else {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        }
        
        make.top.mas_equalTo(self.orderView.mas_bottom).offset(8);
        make.height.mas_equalTo([OSSVAccountsHeadView serviceHeight]);
    }];
    
    if (APP_TYPE == 3) {
        self.serviceTableView.hidden = YES;
        self.serviceMenuView.hidden = NO;
        [self.serviceMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.servicesView);
            make.top.mas_equalTo(self.servicesView.mas_top);
            make.bottom.mas_equalTo(self.servicesView.mas_bottom).offset(-[OSSVFollowsUssView contentHeigth]);
        }];
        
        [self.followUsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.serviceMenuView);
            make.top.mas_equalTo(self.serviceMenuView.mas_bottom);
            make.bottom.mas_equalTo(self.servicesView.mas_bottom);
        }];
    } else {
        self.serviceTableView.hidden = NO;
        self.serviceMenuView.hidden = YES;
        [self.serviceTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.servicesView);
            make.top.mas_equalTo(self.servicesView.mas_top);
            make.bottom.mas_equalTo(self.servicesView.mas_bottom).offset(-[OSSVFollowsUssView contentHeigth]);
        }];
        
        [self.followUsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.servicesView);
            make.top.mas_equalTo(self.serviceTableView.mas_bottom);
            make.bottom.mas_equalTo(self.servicesView.mas_bottom);
        }];
    }
    
        
    OSSVAccountsItemsView *tempView = nil;
    CGFloat itemW = (SCREEN_WIDTH - 12 * 2 - 14 * 2) / self.typeArrays.count;
    if (APP_TYPE == 3) {
        itemW = SCREEN_WIDTH / self.typeArrays.count;
    }
    for (int i=0; i< self.typeArrays.count; i++) {
        OSSVAccountsMenuItemsModel *itemModel = self.typeArrays[i];
        OSSVAccountsItemsView *itemView = [[OSSVAccountsItemsView alloc] initWithFrame:CGRectZero image:itemModel.itemImage title:itemModel.itemTitle];
        itemView.titleLabel.textColor = [OSSVThemesColors stlWhiteColor];
        
        itemView.tag = 4000+i;
        [itemView addTarget:self action:@selector(actionType:) forControlEvents:UIControlEventTouchUpInside];
        [self.typeView addSubview:itemView];
        
        if (tempView) {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(tempView.mas_trailing);
                make.width.mas_equalTo(tempView.mas_width);
                make.height.mas_equalTo(tempView.mas_height);
                make.centerY.mas_equalTo(tempView.mas_centerY);
            }];
        } else {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.top.bottom.mas_equalTo(self.typeView);
                make.width.mas_equalTo(itemW);
            }];
        }
        tempView = itemView;
    }
        
    tempView = nil;
    itemW = (SCREEN_WIDTH - 12 * 2 - 14 * 2) / 4.0;
    if (APP_TYPE == 3) {
        itemW = SCREEN_WIDTH / self.orderArrays.count;
    }
    for (int i=0; i< self.orderArrays.count; i++) {
        OSSVAccountsMenuItemsModel *itemModel = self.orderArrays[i];
        OSSVAccountsItemsView *itemView = [[OSSVAccountsItemsView alloc] initWithFrame:CGRectZero image:itemModel.itemImage title:itemModel.itemTitle];
        itemView.tag = 4000+i;
        [itemView addTarget:self action:@selector(actionOrder:) forControlEvents:UIControlEventTouchUpInside];

        [self.orderContentView addSubview:itemView];
        
        if (tempView) {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(tempView.mas_trailing);
                make.top.mas_equalTo(tempView.mas_top);
                make.width.mas_equalTo(tempView.mas_width);
                make.height.mas_equalTo(tempView.mas_height);
            }];
        } else {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.top.mas_equalTo(self.orderContentView);
                make.height.mas_equalTo(58);
                make.width.mas_equalTo(itemW);
            }];
        }
        tempView = itemView;
    }
    
//    if (app_type == 3) {
//        CGFloat advertiseW = (SCREEN_WIDTH - 14 * 2 -7) / 2.0;
//        CGFloat ratio = (76.0/172);
//        CGFloat advertiseH = advertiseW * ratio;
//        [self.advertiseView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.servicesView.mas_bottom).offset(8);
//            make.height.mas_equalTo(advertiseH + 14 * 2);
//            make.leading.trailing.mas_equalTo(self);
//        }];
//
//    } else {
//
//        CGFloat advertiseW = (SCREEN_WIDTH - 12 * 2 -7) / 2.0;
//        CGFloat ratio = (76.0/172);
//        CGFloat advertiseH = advertiseW * ratio;
//        [self.advertiseView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.servicesView.mas_bottom).offset(8);
//            make.height.mas_equalTo(advertiseH);
//            make.leading.trailing.mas_equalTo(self);
//        }];
//    }
    
}

#pragma mark - datas

- (NSMutableArray *)typeArrays {
    if (!_typeArrays) {
        _typeArrays = [[NSMutableArray alloc] init];
        int count = 3;
        for(NSInteger i=0; i<count; i++) {
            OSSVAccountsMenuItemsModel *itemModel = [[OSSVAccountsMenuItemsModel alloc] init];
            itemModel.index = i;
            [_typeArrays addObject:itemModel];
            
            itemModel.itemCount = @"";
            if (i == 0) {
                itemModel.itemTitle = STLLocalizedString_(@"Coupon", nil);
                itemModel.itemImage = @"account_coupon";
            } else if(i == 1) {
                itemModel.itemTitle = STLLocalizedString_(@"My_WishList", nil);
                itemModel.itemImage = @"account_wishlist";

            }
            else if(i == 2) {
                itemModel.itemTitle = STLLocalizedString_(@"Help", nil);
                itemModel.itemImage = @"spic_help_white";
            }
//            else if(i == 2) {
//                itemModel.itemTitle = STLLocalizedString_(@"user_center_member", nil);
//                itemModel.itemImage = @"account_member";
//            }
//            else if (i == 3) {
//                itemModel.itemTitle = STLLocalizedString_(@"Coins_Center", nil);
//                itemModel.itemImage = @"account_coins";
//            }
        }
    }
    return _typeArrays;
}

- (NSMutableArray *)orderArrays {
    if (!_orderArrays) {
        _orderArrays = [[NSMutableArray alloc] init];
        for(NSInteger i=0; i<4; i++) {
            OSSVAccountsMenuItemsModel *itemModel = [[OSSVAccountsMenuItemsModel alloc] init];
            itemModel.index = i;
            [_orderArrays addObject:itemModel];
            
            itemModel.itemCount = @"";
            if (i == 0) {
                itemModel.itemTitle = STLLocalizedString_(@"Unpaid", nil);
                itemModel.itemImage = @"order_unPay";
            } else if(i == 1) {
                itemModel.itemTitle = STLLocalizedString_(@"Processing", nil);
                itemModel.itemImage = @"order_processing";

            } else if(i == 2) {
                itemModel.itemTitle = STLLocalizedString_(@"Shipped", nil);
                itemModel.itemImage = @"order_shipped";
                
            } else if(i == 3) {
                itemModel.itemTitle = STLLocalizedString_(@"Reviewed", nil);
                itemModel.itemImage = @"order_reviewed";
            }
        }
    }
    return _orderArrays;
}

- (NSMutableArray *)servicesArrays {
    if (!_servicesArrays) {
        _servicesArrays = [[NSMutableArray alloc] init];
    }
    return _servicesArrays;
}

#pragma mark - action


- (void)reloadUserInfo {
    
    self.userNameButton.hidden = YES;
    self.loginRegisterButton.hidden = YES;
    self.registerArrowImageView.hidden = YES;
    self.registerTipLabel.hidden = YES;
    self.photoButton.hidden = YES;
    self.headImageView.hidden = YES;
    
    //v v2.0.0 强制去掉
    [OSSVAccountsManager sharedManager].isCloseBindPhone = YES;
    
    CGFloat phoneHeight = 0;
    if ([OSSVAccountsManager sharedManager].isSignIn) {
        self.userNameButton.hidden = NO;
        self.photoButton.hidden = NO;
        self.headImageView.hidden = NO;
        
        NSString *nickName = [NSString stringWithFormat:@"%@,%@",STLLocalizedString_(@"Hi", nil), STLToString([OSSVAccountsManager sharedManager].account.nickName)];
        
        [self.userNameButton.nameBtn setTitle:nickName forState:UIControlStateNormal];
//        CGSize size = [_userNameButton.nameBtn.titleLabel sizeThatFits:CGSizeMake(_userNameButton.bounds.size.width, MAXFLOAT)];
        self.userNameButton.nameHeight = 22;
        self.userNameButton.imgUrl = [NSURL URLWithString:OSSVAccountsManager.sharedManager.account.vip_icon_url];

        NSInteger isBind = [OSSVAccountsManager sharedManager].account.is_bind_phone; //是否绑定
        BOOL isCloseBindView = [OSSVAccountsManager sharedManager].isCloseBindPhone; //是否绑定
        if (isBind == 0 && !isCloseBindView && !STLIsEmptyString([OSSVAccountsManager sharedManager].account.bind_phone_award)) {
            phoneHeight = [OSSVAccountsHeadView pheneViewHeight:YES];
            self.phoneTipLabel.text = [OSSVAccountsManager sharedManager].account.bind_phone_award;
            self.bindIphoneView.hidden = NO;
        }
        
    } else {
        self.userNameButton.nameHeight = 0;
        self.loginRegisterButton.hidden = NO;
        self.registerArrowImageView.hidden = NO;
        NSString *buttonTitle = APP_TYPE == 3 ? STLLocalizedString_(@"Login/Register", nil) : STLLocalizedString_(@"Login/Register", nil).uppercaseString;
        
        [self.loginRegisterButton setTitle:buttonTitle forState:UIControlStateNormal];
        
        NSString *userTip =  [STLPushManager sharedInstance].tip_user_page_text;
        if (!STLIsEmptyString(userTip)) {
            self.registerTipLabel.text = userTip;
            self.registerTipLabel.hidden = NO;
        }
    }
    
    [self.headImageView yy_setImageWithURL:[NSURL URLWithString:[OSSVAccountsManager sharedManager].account.avatar]
                               placeholder:[UIImage imageNamed:@"user_photo_new"]
                                   options:YYWebImageOptionShowNetworkActivity
                                  progress:nil
                                 transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                        image = [image yy_imageByResizeToSize:CGSizeMake(60 ,60) contentMode:UIViewContentModeScaleAspectFill];
                                        // 此处如果borderWidth 由于比例的关系，实际上位置是向里面缩了一点点，所以用一个0.5
                                        image = [image yy_imageByRoundCornerRadius:38.5*DSCREEN_WIDTH_SCALE borderWidth:1.0f borderColor:[UIColor whiteColor]];
                                        return image;
                                }
                                
                                completion:nil];
    [self updateServiceDatas];
    if (APP_TYPE == 3) {
        [self.serviceMenuView updateDatas:self.servicesArrays];
    } else {
        [self.serviceTableView updateDatasWithDatas:self.servicesArrays];
    }

    [self.servicesView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([OSSVAccountsHeadView serviceHeight]);
    }];
    //是否需要绑定电话号码提示
    
    [self.bindIphoneView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(phoneHeight);
    }];
    
    self.bindIphoneView.hidden = phoneHeight > 0 ? NO : YES;
    
    [self showHeaderRedDot];
    [self updateFollowingDatas];
    
    if (APP_TYPE == 3) {
        [self.serviceMenuView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.servicesView.mas_bottom).offset(-[OSSVFollowsUssView contentHeigth]);
        }];
        
    }
}

- (void)showHeaderRedDot {
    [self showOrHiddenMessageDot];
    [self showOrHiddenMyOrderDot];
    [self handleTypeItems];
}

//消息中心红点
- (void)showOrHiddenMessageDot {
    self.redDotMessageView.hidden = YES;
    if (USERID) {
        if ([OSSVAccountsManager sharedManager].appUnreadMessageNum > 0) {
            self.redDotMessageView.hidden = NO;
        }
    }
}

- (void)updateFollowingDatas {
    [self.followUsView updatePlatomsWithDatas:[OSSVAccountsManager sharedManager].socialPlatforms];
}

//订单状态小红点-----新增
- (void)showOrHiddenMyOrderDot {
    OSSVAccountsItemsView *unPaidItemView     = [self.orderContentView viewWithTag:4000];    //未支付
    OSSVAccountsItemsView *processingItemView = [self.orderContentView viewWithTag:4001];    //已支付(处理中)
    OSSVAccountsItemsView *shippedItemView    = [self.orderContentView viewWithTag:4002];    //已发货
    OSSVAccountsItemsView *reviewItemView     = [self.orderContentView viewWithTag:4003];    //评价

    //未支付订单状态
    if (unPaidItemView && [unPaidItemView isMemberOfClass:OSSVAccountsItemsView.class]) {
        if ([OSSVAccountsManager sharedManager].account.outstandingOrderNum > 0) {
            [unPaidItemView confirmCounts:[NSString stringWithFormat:@"%ld",(long)[OSSVAccountsManager sharedManager].account.outstandingOrderNum] titleNumber:-1 showRed:NO];
        }else{
            [unPaidItemView confirmCounts:@"" titleNumber:-1 showRed:NO];
        }
    }
    //已支付订单状态
    if (processingItemView && [processingItemView isMemberOfClass:OSSVAccountsItemsView.class]) {
        if ([OSSVAccountsManager sharedManager].account.processingOrderNum > 0) {
            [processingItemView confirmCounts:[NSString stringWithFormat:@"%ld",(long)[OSSVAccountsManager sharedManager].account.processingOrderNum] titleNumber:-1 showRed:NO];
        }else{
            [processingItemView confirmCounts:@"" titleNumber:-1 showRed:NO];
        }
    }
    
    //运输中订单状态
    if (shippedItemView && [shippedItemView isMemberOfClass:OSSVAccountsItemsView.class]) {
        if ([OSSVAccountsManager sharedManager].account.shippedOrderNum > 0) {
            [shippedItemView confirmCounts:[NSString stringWithFormat:@"%ld",(long)[OSSVAccountsManager sharedManager].account.shippedOrderNum] titleNumber:-1 showRed:NO];
        }else{
            [shippedItemView confirmCounts:@"" titleNumber:-1 showRed:NO];
        }
    }
    //待评价状态
    if (reviewItemView && [reviewItemView isMemberOfClass:OSSVAccountsItemsView.class]) {
        if ([OSSVAccountsManager sharedManager].account.reviewedNum > 0) {
            [reviewItemView confirmCounts:[NSString stringWithFormat:@"%ld",(long)[OSSVAccountsManager sharedManager].account.reviewedNum] titleNumber:-1 showRed:NO];
        }else{
            [reviewItemView confirmCounts:@"" titleNumber:-1 showRed:NO];
        }
    }
}

- (void)handleTypeItems {
    
    OSSVAccountsItemsView *couponItemView     = [self.typeView viewWithTag:4000];    //优惠券
    OSSVAccountsItemsView *wishlistItemView = [self.typeView viewWithTag:4001];    //收藏
    //OSSVAccountsItemsView *memberItemView    = [self.typeView viewWithTag:4002];    //会员
    OSSVAccountsItemsView *coinsItemView     = [self.typeView viewWithTag:4003];    //金币中心
    
    if (USERID) {
        
        [wishlistItemView confirmCounts:@"" titleNumber:[OSSVAccountsManager sharedManager].account.collect_num showRed:NO];
        [coinsItemView confirmCounts:@"" titleNumber:-1 showRed:[OSSVAccountsManager sharedManager].account.has_new_coin];
        if ([OSSVAccountsManager sharedManager].account.appUnreadCouponNum > 0) {
            [couponItemView confirmCounts:@"" titleNumber:[OSSVAccountsManager sharedManager].account.appUnusedCouponNum showRed:YES];
        }else{
            [couponItemView confirmCounts:@"" titleNumber:[OSSVAccountsManager sharedManager].account.appUnusedCouponNum showRed:NO];
        }
    } else {
        [couponItemView confirmCounts:@"" titleNumber:-1 showRed:NO];
        [wishlistItemView confirmCounts:@"" titleNumber:-1 showRed:NO];
        [coinsItemView confirmCounts:@"" titleNumber:-1 showRed:NO];
    }
}

- (void)actionSetting:(UIButton *)button {
    if (self.eventBlock) {
        self.eventBlock(AccountEventSetting);
    }
}

- (void)actionMessage:(UIButton *)button {
    if (self.eventBlock) {
        self.eventBlock(AccountEventMessage);
    }
}

- (void)actionType:(UIButton *)button {
    if (self.typeBlock) {
        NSInteger tag = button.tag - 4000;
        if (self.typeArrays.count > tag) {
            
            OSSVAccountsMenuItemsModel *model = self.typeArrays[tag];
            self.typeBlock(model.index,STLToString(model.itemTitle));
        }
    }
}

- (void)actionOrder:(UIButton *)button {
    if (self.orderBlock) {
        NSInteger tag = button.tag - 4000;
        if (self.orderArrays.count > tag) {
            
            OSSVAccountsMenuItemsModel *model = self.orderArrays[tag];
            self.orderBlock(model.index,model.itemTitle);
        }
    }
}

- (void)actionServices:(UIButton *)button {
    if (self.servicesBlock) {
        NSInteger tag = button.tag - 4000;
        
        if (self.servicesArrays.count > tag) {
            OSSVAccountsMenuItemsModel *model = self.servicesArrays[tag];
            self.servicesBlock(model.index,model.itemTitle);
        }
    }
}


- (void)actionOrderAll:(UIButton *)button {
    if (self.orderBlock) {
        self.orderBlock(AccountOrderAll,@"");
    }
}


- (void)actionLogin:(UIButton *)button {
    if(self.eventBlock) {
        self.eventBlock(AccountEventLogin);
    }
}

- (void)actionEditUserInfo:(UIButton *)button {
    if (self.eventBlock) {
        self.eventBlock(AccountEventEditUserInfo);
    }
}

- (void)phoneCloseButtonAction:(UIButton *)sender{
    if (self.bindPhoneBlock) {
        [OSSVAccountsManager sharedManager].isCloseBindPhone = YES;
        self.bindPhoneBlock(AccountBindPhoneClose);
    }
}

- (void)phoneBindButtonAction:(UIButton *)sender{
    if (self.bindPhoneBlock) {
        self.bindPhoneBlock(AccountBindPhoneEnterIn);
    }
}
#pragma mark - 懒加载创建UI

- (UIView *)settingBarView {
    if (!_settingBarView) {
        _settingBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        _settingBarView.backgroundColor = [OSSVThemesColors stlClearColor];
    }
    return _settingBarView;
}
- (UIView *)userInfoView {
    if (!_userInfoView) {
        _userInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
    }
    return _userInfoView;
}


- (UIView *)topBlackBgView {
    if (!_topBlackBgView) {
        _topBlackBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [OSSVAccountsHeadView topBlackBgHeight])];
        _topBlackBgView.backgroundColor = [OSSVThemesColors col_0D0D0D];
    }
    return _topBlackBgView;
}

- (UIView *)bottomBgColorView {
    if (!_bottomBgColorView) {
        _bottomBgColorView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomBgColorView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    }
    return _bottomBgColorView;
}

- (YYAnimatedImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[YYAnimatedImageView alloc] init];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        _headImageView.layer.allowsEdgeAntialiasing = true;
        _headImageView.layer.borderColor = OSSVThemesColors.col_FFFFFF.CGColor;
        _headImageView.layer.borderWidth = 1.0f;
        _headImageView.layer.cornerRadius = 24;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.image = [UIImage imageNamed:@"user_photo_new"];
        _headImageView.hidden = YES;
    }
    return _headImageView;
}

- (UIImageView *)registerArrowImageView {
    if (!_registerArrowImageView) {
        _registerArrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _registerArrowImageView.image = [UIImage imageNamed:@"account_circle_arrow"];
        _registerArrowImageView.hidden = YES;
        [_registerArrowImageView convertUIWithARLanguage];
    }
    return _registerArrowImageView;
}
- (UIButton *)loginRegisterButton {
    if (!_loginRegisterButton) {
        _loginRegisterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _loginRegisterButton.backgroundColor = [OSSVThemesColors stlClearColor];
        [_loginRegisterButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];

        if (APP_TYPE == 3) {
            _loginRegisterButton.titleLabel.font = [UIFont vivaiaSemiBoldFont:18];
            [_loginRegisterButton setTitle:STLLocalizedString_(@"Login/Register", nil) forState:UIControlStateNormal];

        } else {
            _loginRegisterButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            [_loginRegisterButton setTitle:STLLocalizedString_(@"Login/Register", nil).uppercaseString forState:UIControlStateNormal];

        }
        [_loginRegisterButton addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_loginRegisterButton setContentEdgeInsets:UIEdgeInsetsMake(0, 22, 0, 0)];

        } else {
            [_loginRegisterButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 22)];
        }
    }
    return _loginRegisterButton;
}

- (UserNameLevelView *)userNameButton {
    if (!_userNameButton) {
        _userNameButton = [[UserNameLevelView alloc] init];
        _userNameButton.nameBtn.titleLabel.numberOfLines = 1;
        _userNameButton.hidden = YES;
        _userNameButton.backgroundColor = [OSSVThemesColors stlClearColor];
        [_userNameButton.nameBtn setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];

        if ([OSSVAccountsManager sharedManager].isSignIn) {
            
            NSString *nickName = [NSString stringWithFormat:@"%@,%@",STLLocalizedString_(@"Hi", nil), STLToString([OSSVAccountsManager sharedManager].account.nickName)];

            [_userNameButton.nameBtn setTitle:nickName forState:UIControlStateNormal];
            CGFloat height = 22;
            
//            CGSize size = [_userNameButton.nameBtn.titleLabel sizeThatFits:CGSizeMake(_userNameButton.bounds.size.width, MAXFLOAT)];
//            _userNameButton.nameHeight = size.height;
            
            _userNameButton.nameHeight = height;
            _userNameButton.hidden = NO;
            self.loginRegisterButton.hidden = YES;
            self.userNameButton.imgUrl = [NSURL URLWithString:OSSVAccountsManager.sharedManager.account.vip_icon_url];
        }
        if (APP_TYPE == 3) {
            _userNameButton.nameBtn.titleLabel.font = [UIFont vivaiaSemiBoldFont:18];

        } else {
            _userNameButton.nameBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        }
        [_userNameButton.nameBtn addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchUpInside];
        [_userNameButton.nameBtn setContentEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _userNameButton.nameBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        } else {
            _userNameButton.nameBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
    }
    return _userNameButton;
}

- (UILabel *)registerTipLabel {
    if (!_registerTipLabel) {
        _registerTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _registerTipLabel.textColor = [OSSVThemesColors col_B2B2B2];
        _registerTipLabel.font = [UIFont systemFontOfSize:12];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _registerTipLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _registerTipLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _registerTipLabel;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoButton addTarget:self action:@selector(actionEditUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        _photoButton.hidden = YES;
    }
    return _photoButton;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_settingButton setImage:[UIImage imageNamed:@"account_setting"] forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(actionSetting:) forControlEvents:UIControlEventTouchUpInside];
        [_settingButton setEnlargeEdge:5];
    }
    return _settingButton;
}

- (UIButton *)messageButton {
    if (!_messageButton) {
        _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_messageButton setImage:[UIImage imageNamed:@"account_message_new"] forState:UIControlStateNormal];
        [_messageButton addTarget:self action:@selector(actionMessage:) forControlEvents:UIControlEventTouchUpInside];
        [_messageButton setEnlargeEdge:5];
    }
    return _messageButton;
}

- (UIView *)redDotMessageView {
    if (!_redDotMessageView) {
        _redDotMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        _redDotMessageView.tag = 999;
        _redDotMessageView.backgroundColor = [OSSVThemesColors col_B62B21];
        _redDotMessageView.layer.cornerRadius = 4;
        _redDotMessageView.clipsToBounds = YES;
        _redDotMessageView.layer.borderColor = [OSSVThemesColors stlWhiteColor].CGColor;
        _redDotMessageView.layer.borderWidth = 1.0;
        _redDotMessageView.hidden = YES;
    }
    return _redDotMessageView;
}


- (UIView *)typeView {
    if (!_typeView) {
        _typeView = [[UIView alloc] initWithFrame:CGRectMake(0, 160, SCREEN_WIDTH, 62)];
        _typeView.backgroundColor = [OSSVThemesColors stlClearColor];

    }
    return _typeView;
}

- (UIView *)orderTopSpaceView {
    if (!_orderTopSpaceView) {
        _orderTopSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 8)];
        _orderTopSpaceView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        _orderTopSpaceView.hidden = YES;
    }
    return _orderTopSpaceView;
}

- (UIView *)orderView {
    if (!_orderView) {
        _orderView = [[UIView alloc] initWithFrame:CGRectMake(0, 230, SCREEN_WIDTH, 106)];
        _orderView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        if (APP_TYPE == 3) {
            
        } else {
            _orderView.layer.cornerRadius = 6;
        }
    }
    return _orderView;
}
//my Orders 的背景视图
- (UIView *)orderTitleView {
    if (!_orderTitleView) {
        _orderTitleView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _orderTitleView;
}

- (UIView *)orderLineView {
    if (!_orderLineView) {
        _orderLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _orderLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
        _orderLineView.hidden = YES;
    }
    return _orderLineView;
}

//订单状态BgView
- (UIView *)orderContentView {
    if (!_orderContentView) {
        _orderContentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _orderContentView;
}

- (UILabel *)orderTitleLabel {
    if(!_orderTitleLabel) {
        _orderTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _orderTitleLabel.text = STLLocalizedString_(@"My_Orders", nil);
        if (APP_TYPE == 3) {
            _orderTitleLabel.font = [UIFont vivaiaRegularFont:16];
        } else {
            _orderTitleLabel.font = [UIFont systemFontOfSize:14];
        }
        _orderTitleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _orderTitleLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _orderTitleLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _orderTitleLabel;;
}

- (UIButton *)orderMoreButton {
    if (!_orderMoreButton) {
        
        _orderMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_orderMoreButton addTarget:self action:@selector(actionOrderAll:) forControlEvents:UIControlEventTouchUpInside];
        [_orderMoreButton setTitleColor:[OSSVThemesColors col_6C6C6C] forState:UIControlStateNormal];
        _orderMoreButton.titleLabel.font = [UIFont systemFontOfSize:12];
        if (APP_TYPE == 3) {
            [_orderMoreButton setTitle:STLLocalizedString_(@"viewAll", nil) forState:UIControlStateNormal];
        } else {
            [_orderMoreButton setImage:[UIImage imageNamed:@"account_arrow"] forState:UIControlStateNormal];
            [_orderMoreButton.imageView convertUIWithARLanguage];
            [_orderMoreButton setTitle:STLLocalizedString_(@"viewAll", nil) forState:UIControlStateNormal];
            [_orderMoreButton stl_LayoutStyle:STLButtonEdgeInsetsStyleRight imageTitleSpace:2];
        }
        
        [_orderMoreButton setEnlargeEdge:8];
    }
    return _orderMoreButton;
}

- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        UIImage *backImg = STLImageWithName(@"spic_dash_line_black");
        UIColor*bcColor =[UIColor colorWithPatternImage:backImg];
        _lineImageView.hidden = YES;
        _lineImageView.backgroundColor = bcColor;
    }
    return _lineImageView;
}

- (UIView *)servicesView {
    if (!_servicesView) {
        _servicesView = [[UIView alloc] initWithFrame:CGRectMake(0, 242, SCREEN_WIDTH, 110)];
        _servicesView.backgroundColor = [OSSVThemesColors col_FAFAFA];
        _servicesView.layer.cornerRadius = 6;
        _servicesView.layer.masksToBounds = YES;
    }
    return _servicesView;
}

- (OSSVAccountsServicesMenuView *)serviceMenuView {
    if (!_serviceMenuView) {
        _serviceMenuView = [[OSSVAccountsServicesMenuView alloc] initWithFrame:CGRectZero];
        _serviceMenuView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _serviceMenuView.hidden = YES;
        [_serviceMenuView updateDatas:self.servicesArrays];
        @weakify(self)
        _serviceMenuView.didSelectBlock = ^(NSInteger index, OSSVAccountsMenuItemsModel * _Nonnull model) {
            @strongify(self)
            if (self.servicesBlock) {
                self.servicesBlock(model.type,model.itemTitle);
            }
        };
    }
    return _serviceMenuView;
}

- (OSSVAccountHeadServicTableView *)serviceTableView {
    if (!_serviceTableView) {
        _serviceTableView = [[OSSVAccountHeadServicTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _serviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_serviceTableView updateDatasWithDatas:self.servicesArrays];
        _serviceTableView.layer.cornerRadius = 6;
        _serviceTableView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _serviceTableView.hidden = YES;
        
        @weakify(self)
        _serviceTableView.didSelectBlock = ^(NSInteger index, OSSVAccountsMenuItemsModel * _Nonnull model) {
            @strongify(self)
            if (self.servicesBlock) {
                self.servicesBlock(model.type,model.itemTitle);
            }
        };
    }
    return _serviceTableView;
}



- (OSSVFollowsUssView *)followUsView {
    if (!_followUsView) {
        _followUsView = [[OSSVFollowsUssView alloc] initWithFrame:CGRectZero];
        
        //里面处理的跳转事件
//        @weakify(self)
//        _followUsView.followSelectBlock = ^(FollowPloatmModel * _Nonnull model) {
//            @strongify(self)
//        };
        
        if (APP_TYPE == 3) {
            _followUsView.hidden = YES;
        }
    }
    return _followUsView;
}

///绑定电话号码提示
- (UIView *)bindIphoneView {
    if (!_bindIphoneView) {
        _bindIphoneView = [[UIView alloc] initWithFrame:CGRectZero];
        _bindIphoneView.backgroundColor = [OSSVThemesColors stlClearColor];
        _bindIphoneView.userInteractionEnabled = YES;
        _bindIphoneView.hidden = YES;
    }
    return _bindIphoneView;;
}

- (UIView *)phoneTipView {
    if (!_phoneTipView) {
        _phoneTipView = [[UIView alloc] initWithFrame:CGRectZero];
        _phoneTipView.backgroundColor = [OSSVThemesColors col_FFF3E4];
        if (APP_TYPE == 3) {
        } else {
            _phoneTipView.layer.cornerRadius = 6;
        }
        _phoneTipView.userInteractionEnabled = YES;
    }
    return _phoneTipView;
}

- (UIImageView *)phoneActivtyImageView {
    if (!_phoneActivtyImageView) {
        _phoneActivtyImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _phoneActivtyImageView.image = [UIImage imageNamed:@"sign_up_coin"];
    }
    return _phoneActivtyImageView;
}

- (UILabel *)phoneTipLabel {
    if (!_phoneTipLabel) {
        _phoneTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _phoneTipLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _phoneTipLabel.font = [UIFont systemFontOfSize:12];
        _phoneTipLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _phoneTipLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _phoneTipLabel;
}

- (UIButton *)phoneCloseButton{
    if (!_phoneCloseButton) {
        _phoneCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_phoneCloseButton setImage:[UIImage imageNamed:@"close_bind"] forState:UIControlStateNormal];
        [_phoneCloseButton addTarget:self action:@selector(phoneCloseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_phoneCloseButton setEnlargeEdge:6];
    }
    return _phoneCloseButton;
}

-(UIButton *)phoneBindButton{
    if (!_phoneBindButton) {
        _phoneBindButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_phoneBindButton addTarget:self action:@selector(phoneBindButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _phoneBindButton;
}

@end
