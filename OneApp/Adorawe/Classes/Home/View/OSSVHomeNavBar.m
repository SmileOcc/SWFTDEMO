//
//  STLHomeNavigationBar.m
// XStarlinkProject
//
//  Created by odd on 2020/7/30.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVHomeNavBar.h"
#import "UIButton+STLCategory.h"
#import "JSBadgeView.h"
#import "SDCycleScrollView.h"
#import "OSSVLocaslHosstManager.h"
#import "UIView+WhenTappedBlocks.h"

@interface OSSVHomeNavBar ()<SDCycleScrollViewDelegate>

//@property (nonatomic, strong) UIButton                *leftCollectButton;
@property (nonatomic, strong) UIButton                *rightButton;
@property (nonatomic, strong) UIButton                *messageButton;
@property (nonatomic, strong) UIView                  *bottomLine;
@property (nonatomic, strong) UIView                  *backgroundView;
@property (nonatomic, assign) BOOL                    finishedAnimation;
@property (nonatomic, assign) CGFloat                 contentViewOffsetY;
@property (nonatomic, strong) SDCycleScrollView       *searchScroll; //搜索文字滚动
@property (nonatomic, strong) JSBadgeView             *badgeView;
//@property (nonatomic, strong) NSArray                 *titlesArray;
@property (nonatomic, strong) NSMutableArray          *titleGroupArray;
@end

@implementation OSSVHomeNavBar

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        self.finishedAnimation = YES;
        self.userInteractionEnabled = YES;
        CGFloat barHeight = 44 + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, barHeight);
        self.userInteractionEnabled = YES;
        [self setupView];
        [self layoutView];
        
        /**
         * ❗️❗️❗️警告不要修改这个❗️❗️❗️
         * 开发时: 非线上发布环境显示切换环境
         */
        if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {
            STLLog(@"⚠️⚠️⚠️ 此状态是线上发布生产环境, 切记不能显示切换环境入口 ⚠️⚠️⚠️");
        } else {
            // 开发时设置可以切换任何环境
            [self addGestures];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBagValues) name:kNotif_CartBadge object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrHiddenMessageDot) name:kNotif_ChangeMessageCountDot object:nil]; // 消息未读
    }
    return self;
}

/**
 * 切换开发环境按钮
 */
- (void)addGestures {
    
    UIView *rotView = [[UIView alloc] initWithFrame:CGRectMake(self.backgroundView.size.width / 2.0-2, 66, 44, 44)];
    rotView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    rotView.layer.cornerRadius = 22;
    rotView.layer.masksToBounds = YES;
    rotView.userInteractionEnabled = YES;
    [self.backgroundView addSubview:rotView];
    
    [rotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backgroundView.mas_centerX);
        make.width.height.equalTo(44);
        make.top.equalTo(self.backgroundView.mas_bottom).offset(-22);
    }];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:[OSSVLocaslHosstManager class] action:@selector(changeLocalHost)];
    [rotView addGestureRecognizer:tapGesture];
}


- (void)setupView {
    [self addSubview:self.backgroundView];
//    [self addSubview:self.leftCollectButton];
    [self addSubview:self.rightButton];
    [self addSubview:self.messageButton];
    [self addSubview:self.bottomLine];
    [self addSubview:self.searchBgView];
    [self.searchBgView addSubview:self.searchIconView];
//    [self.searchBgView addSubview:self.searchLabel];
//    [self.searchBgView addSubview:self.inputField];
    [self.searchBgView addSubview:self.searchScroll];
    [self.searchScroll addSubview:self.inputField];
    
    self.backgroundColor = [UIColor whiteColor];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    
    self.searchBgView.sensor_element_id = @"iv_search";
    self.searchIconView.sensor_element_id = @"iv_search";
    self.inputField.sensor_element_id = @"iv_search";
//    self.leftCollectButton.sensor_element_id = @"img_save";
    self.messageButton.sensor_element_id = @"img_message";
    self.rightButton.sensor_element_id = @"buy_icon";
    self.badgeView.sensor_element_id = @"buy_icon";
    
}

- (void)layoutView {
    NSInteger top = kSCREEN_BAR_HEIGHT+3 + 5;
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.backgroundView.mas_trailing).offset(-14);
        make.width.height.equalTo(24);
        make.top.equalTo(top);
    }];
    
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(24);
        make.trailing.equalTo(self.rightButton.mas_leading).offset(-16);
        make.top.equalTo(top);
    }];
    
    [self.searchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(APP_TYPE == 3 ? 0 : 12);
        make.height.equalTo(32);
        make.trailing.equalTo(self.messageButton.mas_leading).offset(-16);
        make.centerY.equalTo(self.messageButton.mas_centerY);
    }];
    
    [self.searchIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.searchBgView.mas_leading).offset(14);
        make.centerY.equalTo(self.searchBgView.mas_centerY);
        make.size.equalTo(CGSizeMake(18, 18));
    }];
    
    
        [self.searchScroll mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.searchIconView.mas_trailing).offset(5);
            make.top.bottom.mas_equalTo(self.searchBgView);
            make.trailing.mas_equalTo(self.searchBgView.mas_trailing);
        }];
    
        [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(self.searchScroll);
        }];


    
    [self showCartCount];
    [self showOrHiddenMessageDot];
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

- (void)showCartOrMessageCount {
    [self showCartCount];
    [self showOrHiddenMessageDot];
}

- (void)stl_showBottomLine:(BOOL)show {
    self.bottomLine.hidden = !show;
}

- (void)clickButtonAction:(UIButton *)button {
    [self targetActionType:button.tag];
}

- (void)targetActionType:(HomeNavBarActionType)actionType {
    if (actionType > HomeNavBarLeftCollectAction) return;
 
    if (self.navBarActionBlock) {
        self.navBarActionBlock(actionType);
    }
}

#pragma mark - Getter
- (UIView *)searchBgView {
    if (!_searchBgView) {
        _searchBgView = [[UIView alloc] initWithFrame:CGRectZero];
        if (APP_TYPE != 3) {
            _searchBgView.backgroundColor = [OSSVThemesColors col_F5F5F5];
            _searchBgView.layer.cornerRadius = 16;
        }else{
            UIView *underLine = [[UIView alloc] init];
            underLine.backgroundColor = [OSSVThemesColors col_000000:1.0];
            [_searchBgView addSubview:underLine];
            [underLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_searchBgView.mas_leading).offset(14);
                make.trailing.equalTo(_searchBgView.mas_trailing);
                make.bottom.equalTo(_searchBgView.mas_bottom);
                make.height.equalTo(1);
            }];
        }
        
        
        _searchBgView.userInteractionEnabled = YES;
        @weakify(self)
//        if (self.hotWordsArray.count == 0) {
//                    [_searchBgView whenTapped:^{
//                        @strongify(self)
//                        [self targetActionType:HomeNavBarLeftSearchAction];
//                    }];
//        }
        _searchBgView.layer.masksToBounds = YES;
    }
    
    return _searchBgView;
}

- (UIImageView *)searchIconView {
    if (!_searchIconView) {
        _searchIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_gray"]];
    }
    return _searchIconView;
}
//- (UILabel *)searchLabel {
//    if (!_searchLabel) {
//        _searchLabel = [UILabel new];
//        _searchLabel.text = [NSString stringWithFormat:@"%@", STLLocalizedString_(@"search", nil)];
//        _searchLabel.textColor = [OSSVThemesColors col_999999];
//        _searchLabel.font = [UIFont systemFontOfSize:14];
//    }
//
//    return _searchLabel;
//}

- (UITextField *)inputField {
    if (!_inputField) {
        _inputField = [[UITextField alloc] initWithFrame:CGRectZero];
        _inputField.backgroundColor = [OSSVThemesColors col_F5F5F5];
        _inputField.font = [UIFont systemFontOfSize:14];
        _inputField.textColor = OSSVThemesColors.col_999999;
        _inputField.hidden = YES;
        
        UIColor *placeHolderColor = OSSVThemesColors.col_B2B2B2;
        if (APP_TYPE == 3) {
            _inputField.backgroundColor = UIColor.clearColor;
            _inputField.textColor = [OSSVThemesColors col_000000:1.0];
            placeHolderColor = [OSSVThemesColors col_000000:0.5];
        }
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:STLLocalizedString_(@"search", nil) attributes:
        @{NSForegroundColorAttributeName:placeHolderColor,
                     NSFontAttributeName:_inputField.font
             }];
        _inputField.attributedPlaceholder = attrString;
        _inputField.userInteractionEnabled = NO;
        _inputField.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _inputField.textAlignment = NSTextAlignmentRight;
        }
    }
    return _inputField;
}




- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] init];
        [_rightButton setImage:[UIImage imageNamed:@"bag_new"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.imageView.contentMode = UIViewContentModeCenter;
        _rightButton.tag = HomeNavBarRightCarAction;
        [_rightButton setEnlargeEdge:10];
    }
    return _rightButton;
}
- (UIButton *)messageButton {
    if (!_messageButton) {
        _messageButton = [[UIButton alloc] init];
        [_messageButton setImage:[UIImage imageNamed:@"nav_message"] forState:UIControlStateNormal];
        [_messageButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _messageButton.imageView.contentMode = UIViewContentModeCenter;
        _messageButton.tag = HomeNavBarRighMessageAction;
        [_messageButton setEnlargeEdge:10];
    }
    return _messageButton;
}


- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [OSSVThemesColors col_CCCCCC];
    }
    return _bottomLine;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
    }
    return _backgroundView;
}


- (void)stl_setBarBackgroundImage:(UIImage *)image {
    self.backgroundView.backgroundColor = [UIColor clearColor];
    [self stl_showBottomLine:NO];
    self.image = image;
}

//文字滚动
- (SDCycleScrollView *)searchScroll {
    if (!_searchScroll) {
        _searchScroll = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage imageNamed:@""]];
        _searchScroll.onlyDisplayText = YES;
        _searchScroll.backgroundColor = [UIColor clearColor];
        _searchScroll.autoScrollTimeInterval = 2;
        _searchScroll.titleLabelHeight = 20;
//        _searchScroll.titlesGroup = self.titlesArray;
        _searchScroll.titleLabelTextColor = OSSVThemesColors.col_B2B2B2;
        if (APP_TYPE == 3) {
            _searchScroll.titleLabelTextColor = [OSSVThemesColors col_000000:0.5];
        }
        _searchScroll.titleLabelTextFont  = [UIFont systemFontOfSize:14];
        _searchScroll.titleLabelBackgroundColor = [UIColor clearColor];
        _searchScroll.scrollDirection = UICollectionViewScrollDirectionVertical;
        [_searchScroll disableScrollGesture];
    }
    return _searchScroll;
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

//消息中心红点
- (void)showOrHiddenMessageDot {
    for (UIView *v in self.subviews) {
        if (v.tag==999) {
            if ([v isKindOfClass:[UILabel class]]) {
                [v removeFromSuperview];
            }
        }
    }
    if (USERID) {

        if ([OSSVAccountsManager sharedManager].appUnreadMessageNum > 0) {
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
            lbl.tag = 999;
            lbl.backgroundColor = [OSSVThemesColors col_B62B21];
            lbl.layer.cornerRadius = 4;
            lbl.clipsToBounds = YES;
            [self addSubview:lbl];
            
            [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.messageButton.mas_top);
                make.width.height.mas_equalTo(8);
                make.trailing.equalTo(self.messageButton.mas_trailing).offset(4);
            }];
            
        }
    }
    
}

- (NSMutableArray *)titleGroupArray {
    if (!_titleGroupArray) {
        _titleGroupArray = [NSMutableArray array];
    }
    return _titleGroupArray;
}

- (void)setHotWordsArray:(NSArray *)hotWordsArray {
    _hotWordsArray = hotWordsArray;
    [self.titleGroupArray removeAllObjects];
    NSArray *subArray = [NSArray array];
    if (self.hotWordsArray.count > 3) {
       subArray = [self.hotWordsArray  subarrayWithRange:NSMakeRange(0, 3)];  //截取3个数据
    } else {
        subArray = self.hotWordsArray;
    }
    if (subArray.count > 0) {

        for (OSSVHotsSearchWordsModel *model in subArray) {
            [self.titleGroupArray addObject:STLToString(model.word)];
        }
        self.searchScroll.titlesGroup = self.titleGroupArray;

    } else {
        //没有热词返回时候，默认为search，可以点击
        self.searchScroll.userInteractionEnabled = YES;
        self.inputField.hidden = NO;
        @weakify(self)
        [self.inputField whenTapped:^{
            NSLog(@"点击搜索框");
            @strongify(self)
           [self targetActionType:HomeNavBarLeftSearchAction];

        }];
    }
}

#pragma mark ---SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSString *indexStr = [NSString stringWithFormat:@"%@",self.titleGroupArray[index]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpToSearchWithKey:)]) {
        [self.delegate jumpToSearchWithKey:indexStr];
    }
}


@end
