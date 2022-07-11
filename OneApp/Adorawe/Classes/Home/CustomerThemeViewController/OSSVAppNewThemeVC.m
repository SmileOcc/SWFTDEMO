//
//  OSSVAppNewThemeVC.m
// OSSVAppNewThemeVC
//
//  Created by odd on 2021/3/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVAppNewThemeVC.h"
#import "OSSVCartVC.h"
#import "OSSVDetailsVC.h"
#import "OSSVCategorysNewZeroListVC.h"

#import "OSSVCustomThemeMultiMould.h"
#import "OSSVAsinglViewMould.h"
#import "OSSVWaterrFallViewMould.h"
#import "OSSVMultiColumnsGoodItemsViewMould.h"
#import "OSSVMutilBranchMould.h"

#import "OSSVThemesMainLayout.h"
#import "OSSVAsinglesAdvCCell.h"
#import "OSSVPrGoodsSPecialCCell.h"
#import "OSSVMultiPGoodsSPecialCCell.h"
#import "OSSVThemesChannelsCCell.h"
#import "OSSVThemeZeorsActivyCCell.h"
#import "OSSVCouponsAlertView.h"
#import "STLActionSheet.h"


#import "OSSVScrollCCellModel.h"
#import "OSSVDetailsBaseInfoModel.h"
#import "OSSVHomeCThemeModel.h"
#import "OSSVDetailsViewModel.h"
#import "OSSVProGoodsCCellModel.h"
#import "OSSVMultProGoodsCCellModel.h"
#import "OSSVHomeChannelCCellModel.h"
#import "OSSVCustThemePrGoodsListCacheModel.h"
#import "OSSVAPPNewThemeMultiCCellModel.h"

#import "OSSVThemesSpecialsAip.h"
#import "OSSVCustomThemesChannelsGoodsAip.h"
#import "OSSVHomesCouponsAip.h"

#import "JSBadgeView.h"
#import "UIColor+Extend.h"
#import "OSSVAdvsEventsManager.h"


@interface OSSVAppNewThemeVC ()

@property (nonatomic, strong) OSSAPPThemesMainView               *themeMainView;

@property (nonatomic, strong) UIButton                          *rightButton;
@property (nonatomic, strong) JSBadgeView                       *badgeView;

// GA统计
@property (nonatomic, assign) long long int beginTime;
@property (nonatomic, assign) long long int endTime;


@end

@implementation OSSVAppNewThemeVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setNavigationBar];
    
    [self.view addSubview:self.themeMainView];
    [self.themeMainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];

    [self.themeMainView viewDidShow];
    [self.themeMainView addListViewRefreshKit];
    self.themeMainView.rightButton = self.rightButton;
    
    [self showCartCount];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBagValues) name:kNotif_CartBadge object:nil];
}

// 设置购物车的按钮图标
- (void)setNavigationBar {
    _rightButton = [[UIButton alloc] init];
    [_rightButton setImage:[UIImage imageNamed:@"bag_new"] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _rightButton.imageView.contentMode = UIViewContentModeCenter;

    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButtonItem.width = -10.0;
    UIBarButtonItem *rihtItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    [self.navigationItem setRightBarButtonItems:@[spaceButtonItem, rihtItem]];

}

- (void)refreshBagValues {
    [self showCartCount];
}

- (void)showCartCount {
    NSInteger allGoodsCount = [[OSSVCartsOperateManager sharedManager] cartValidGoodsAllCount];
    self.badgeView.badgeText = nil;
    if (allGoodsCount > 0) {
        self.badgeView.badgeText = [NSString stringWithFormat:@"%lu",(unsigned long)allGoodsCount];
        if (allGoodsCount > 99) {
            allGoodsCount = 99;
            self.badgeView.badgeText = [NSString stringWithFormat:@"%lu+",(unsigned long)allGoodsCount];
        }
    }
}




- (void)clickButtonAction:(id)sender {
    OSSVCartVC *cartVC = [[OSSVCartVC alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
    [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":[NSString stringWithFormat:@"Theme_%@",STLToString(self.customId)],
           @"button_name":@"Cart"}];
}

#pragma mark - request

- (OSSAPPThemesMainView *)themeMainView {
    if (!_themeMainView) {
//        _themeMainView = [[STLThemeMainView alloc] initWithFrame:self.view.bounds
//                                                    firstChannel:@""
//                                                         channel:STLToString(self.customId)
//                                                           title:STLToString(self.customName)];
        _themeMainView = [[OSSAPPThemesMainView alloc] initWithFrame:self.view.bounds
                                                    firstChannel:@""
                                                         channel:STLToString(self.customId)
                                                        deeplink:STLToString(self.deepLinkId)
                                                           title:STLToString(self.customName)];
        @weakify(self)
        _themeMainView.showFloatBannerBlock = ^(BOOL show) {
            @strongify(self)
            if (self.showFloatBannerBlock) {
                self.showFloatBannerBlock(show);
            }
        };
        _themeMainView.showFloatInputBarBlock = ^(BOOL show, CGFloat offetY) {
            @strongify(self)
            if (self.showFloatInputBarBlock) {
                self.showFloatInputBarBlock(show, offetY);
            }
        };
    }
    return _themeMainView;
}


- (JSBadgeView *)badgeView {
    if (!_badgeView) {
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            // 阿语
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.rightButton alignment:JSBadgeViewAlignmentTopLeft];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(0), 5);
        }else{
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.rightButton alignment:JSBadgeViewAlignmentTopRight];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(16), -10);
        }
        _badgeView.userInteractionEnabled = NO;
        _badgeView.badgeBackgroundColor = [OSSVThemesColors col_B62B21];
        _badgeView.badgeTextFont = [UIFont systemFontOfSize:9];
        _badgeView.badgeStrokeColor = [OSSVThemesColors stlWhiteColor];
        _badgeView.badgeStrokeWidth = 1.0;

    }
    return _badgeView;
}

@end
