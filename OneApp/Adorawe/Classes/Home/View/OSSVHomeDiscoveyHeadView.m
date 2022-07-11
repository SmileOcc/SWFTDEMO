//
//  DiscoveryHeaderView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeDiscoveyHeadView.h"
#import "SDCycleScrollView.h"
#import "OSSVHomeDiscoverHeaderModel.h"

#import "OSSVAdvsEventsModel.h"
#import "OSSVAdvsEventsManager.h"


/**
 *  底部按钮选项(Three Item)
 */
typedef NS_ENUM(NSUInteger, DiscoveryBottomButtonType) {
    DiscoveryBottomSupperDealsType = 1030,
    DiscoveryBottomNewInType = 1031,
    DiscoveryBottomBestSellersType = 1032
};


static const CGFloat kDiscoverHeaderBottomOfThreeViewsSpace = 2.0; // 底部View三者之间的距离
static const NSInteger kDiscoverHeaderMiddleButtonTag = 1040; // 中部View Item 的tag


#pragma mark - Interface
@interface OSSVHomeDiscoveyHeadView ()<SDCycleScrollViewDelegate>

@property (nonatomic, strong) SDCycleScrollView         *bannerScrollerView;
@property (nonatomic, strong) UIView                    *middleBackView;
@property (nonatomic, strong) UIView                    *bottomBackView;
@property (nonatomic, strong) UIButton                  *superDealsButton;
@property (nonatomic, strong) UIButton                  *newinButton;
@property (nonatomic, strong) UIButton                  *bestSellersButton;
@property (nonatomic, strong) OSSVHomeDiscoverHeaderModel      *discoveryHeaderModel;

@end

@implementation OSSVHomeDiscoveyHeadView

#pragma mark - Init 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // 头部 Banner View
        [self addSubview:self.bannerScrollerView];
        // 中部 Topic View
        [self addSubview:self.middleBackView];
        // 底部 Three View
        [self addSubview:self.bottomBackView];
        
        // Three sub Views
        [self.bottomBackView addSubview:self.superDealsButton];
        [self.bottomBackView addSubview:self.newinButton];
        [self.bottomBackView addSubview:self.bestSellersButton];

        [self.bannerScrollerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(@0);
            make.height.mas_equalTo(@(kDiscoverHeaderTopViewHeight));
        }];
        
        [self.middleBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(@0);
            make.width.mas_equalTo(@(SCREEN_WIDTH));
            make.top.equalTo(_bannerScrollerView.mas_bottom);
            make.height.mas_equalTo(@(kDiscoverHeaderMiddleViewHeight));
        }];
        
        [self.bottomBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.equalTo(@0);
            make.bottom.equalTo(@(-kDiscoverHeaderBottomToOtherSpace));
            make.height.equalTo(@(kDiscoverHeaderBottomViewHeight));
        }];
        
        
        // ------------------- Three sub Views -------------------- //
        
        [self.superDealsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.bottom.equalTo(@0);
            
        }];
        
        [self.newinButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.top.mas_equalTo(@0);
            make.leading.equalTo(_superDealsButton.mas_trailing).offset(kDiscoverHeaderBottomOfThreeViewsSpace);
            make.width.mas_equalTo(@(SCREEN_WIDTH /2.0 - kDiscoverHeaderBottomOfThreeViewsSpace / 2.0));
        }];
        
        [self.bestSellersButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_newinButton.mas_bottom).offset(kDiscoverHeaderBottomOfThreeViewsSpace);
            make.trailing.bottom.mas_equalTo(@0);
            make.leading.height.width.equalTo(_newinButton);
        }];
        
    }
    return self;
}


#pragma mark - Model 赋值
- (void)setModel:(OSSVHomeDiscoverHeaderModel *)model {
    
    // 记住先赋值给本地Model
    self.discoveryHeaderModel = model;
    
    // 避免整个 Banner TopView 没有的情况
    if (self.discoveryHeaderModel.bannerArray.count > 0) {
        self.bannerScrollerView.hidden = NO;
        // banner 赋值
        [self setDataToBannerView];
    }
    else {
        self.bannerScrollerView.hidden = YES;
    }

    // 避免整个 Topic MiddleView 没有的情况
    if (self.discoveryHeaderModel.topicArray.count > 0) {
        self.middleBackView.hidden = NO;
        // topic 赋值
        [self setDataToTopicView];
    }
    else {
        self.middleBackView.hidden = YES;
    }
    
    // 避免整个 Three BottomView 没有的情况
    if (self.discoveryHeaderModel.threeArray.count > 0) {
        self.bottomBackView.hidden = NO;
        // 但实际上 ViewModel 处已经做了判断
        if (self.discoveryHeaderModel.threeArray.count != 3) return;
        // three 赋值
        [self setDataToThreeView];
    }
    else {
        self.bottomBackView.hidden = YES;
    }
    
}

#pragma mark ---- Banner TopView
- (void)setDataToBannerView {
    
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:self.discoveryHeaderModel.bannerArray.count];
    for (OSSVAdvsEventsModel *model in self.discoveryHeaderModel.bannerArray) {
        [imageArray addObject:model.imageURL];
    }
    // 网络URL
    self.bannerScrollerView.imageURLStringsGroup = imageArray;
    if (imageArray.count == 1) {
        self.bannerScrollerView.autoScroll = NO;
    }
    
}

#pragma mark ---- Topic MiddleView
- (void)setDataToTopicView {
    
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:self.discoveryHeaderModel.topicArray.count];
    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:self.discoveryHeaderModel.topicArray.count];
    for (OSSVAdvsEventsModel *model in self.discoveryHeaderModel.topicArray) {
        [imageArray addObject:model.imageURL];
        [titleArray addObject:model.name];
    }
//    NSArray *titleArray = @[@"The Wheel Of Fortune",@"Invite&Cet Cash",@"Community",@"Categories"];
//    NSArray *imageArray = @[
//                            @"http://uidesign.rosegal.com/RG/images/banner/eight/categories@2x.png",
//                            @"http://uidesign.rosegal.com/RG/images/banner/eight/community@2x.png",
//                            @"http://uidesign.rosegal.com/RG/images/banner/eight/fortune@2x.png",
//                            @"http://uidesign.rosegal.com/RG/images/banner/eight/input@2x.png"
//                            ];
//            NSArray *imageArray = @[@"home_wheel_icon",@"home_invite_cet_cash_icon",@"home_code_icon",@"home_boutuque_icon",@"home_boutuque_icon"];
    
    [self makeMiddleViewsWithTitleArray:titleArray imageArray:imageArray];
}

#pragma mark ----  Three BottomView
- (void)setDataToThreeView {
    
    for (NSInteger i = 0, max = self.discoveryHeaderModel.threeArray.count; i < max; i++) {
        OSSVAdvsEventsModel *model = self.discoveryHeaderModel.threeArray[i];
        if (i == 0) {
            [self.superDealsButton yy_setBackgroundImageWithURL:[NSURL URLWithString:model.imageURL]
                                                       forState:UIControlStateNormal
                                                    placeholder:[UIImage imageNamed:@"placeholder_pdf"]
                                                        options:YYWebImageOptionShowNetworkActivity
                                                       progress:nil
                                                      transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                                                    image = [image yy_imageByResizeToSize:CGSizeMake(SCREEN_WIDTH/2 - 1,kDiscoverHeaderBottomViewHeight) contentMode:UIViewContentModeScaleAspectFill];
                                                                    return image;
                                                                }
                                                     completion:nil];
            
        }
        else if (i == 1) {
            [self.newinButton yy_setBackgroundImageWithURL:[NSURL URLWithString:model.imageURL]
                                                       forState:UIControlStateNormal
                                                    placeholder:[UIImage imageNamed:@"placeholder_pdf"]
                                                        options:YYWebImageOptionShowNetworkActivity
                                                       progress:nil
                                                      transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                                          image = [image yy_imageByResizeToSize:CGSizeMake(SCREEN_WIDTH/2 - 1,kDiscoverHeaderBottomViewHeight/2 - 1) contentMode:UIViewContentModeScaleAspectFill];
                                                          return image;
                                                      }
                                                     completion:nil];
            
        }
        else if (i == 2) {
            [self.bestSellersButton yy_setBackgroundImageWithURL:[NSURL URLWithString:model.imageURL]
                                                  forState:UIControlStateNormal
                                               placeholder:[UIImage imageNamed:@"placeholder_pdf"]
                                                   options:YYWebImageOptionShowNetworkActivity
                                                  progress:nil
                                                 transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                                     image = [image yy_imageByResizeToSize:CGSizeMake(SCREEN_WIDTH/2 - 1,kDiscoverHeaderBottomViewHeight/2 - 1)  contentMode:UIViewContentModeScaleAspectFill];
                                                     return image;
                                                 }
                                                completion:nil];
            
        }
    }
}

#pragma mark - 三种点击事件
#pragma mark 点击 Banner 图片回调
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    
    OSSVAdvsEventsModel *OSSVAdvsEventsModel = self.discoveryHeaderModel.bannerArray[index];
    [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:OSSVAdvsEventsModel];
    STLLog(@"tap banner url=== %@ actionType == %lu",OSSVAdvsEventsModel.url,OSSVAdvsEventsModel.actionType);
    
}

#pragma mark 点击 Topic 中间 item
- (void)didTapMiddleOfTopicItemAction:(UIButton *)button {
    
    NSInteger index = button.tag - kDiscoverHeaderMiddleButtonTag;
    OSSVAdvsEventsModel *OSSVAdvsEventsModel = self.discoveryHeaderModel.topicArray[index];
    [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:OSSVAdvsEventsModel];
    STLLog(@"tap topic url=== %@ actionType == %lu",OSSVAdvsEventsModel.url,OSSVAdvsEventsModel.actionType);
}

#pragma mark 点击 Three  底部 item
- (void)didTapBottomOfThreeItemAction:(UIButton *)button {
    
    NSInteger index = button.tag - DiscoveryBottomSupperDealsType;
    OSSVAdvsEventsModel *OSSVAdvsEventsModel = self.discoveryHeaderModel.threeArray[index];
    [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:OSSVAdvsEventsModel];
    STLLog(@"tap three url=== %@ actionType == %lu",OSSVAdvsEventsModel.url,OSSVAdvsEventsModel.actionType);
}

#pragma mark - Private makeMiddleView
- (void)makeMiddleViewsWithTitleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray {
    
    if(titleArray.count > 0) {
        
        // 备注： 假如banner 图没有的时候
        if (self.discoveryHeaderModel.bannerArray.count > 0) {
            [self.bannerScrollerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(kDiscoverHeaderTopViewHeight);
            }];
        }
        else {
            [self.bannerScrollerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }
        
        /**
         *  因为这边 Item 的数目一直是不确定的
         与其直接改变它的内容，图片和位置，这边选择删除后重新布局
         */
        
        // 先将其子视图删除
        self.middleBackView.hidden = NO;
        for (UIView *subView in self.middleBackView.subviews) {
            [subView removeFromSuperview];
        }
        // 再布局
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:titleArray.count];
        for (int i = 0; i < titleArray.count; i++) {
            if (i < 4) {
                // 如果是5个的情况下，是不添加的
                UIButton *buttonView = [self makeCustomButtonWithTitle:titleArray[i] image:imageArray[i]];
                buttonView.backgroundColor = [UIColor clearColor];
                buttonView.tag = kDiscoverHeaderMiddleButtonTag + i;
                [buttonView addTarget:self action:@selector(didTapMiddleOfTopicItemAction:) forControlEvents:UIControlEventTouchUpInside];
                [self.middleBackView addSubview:buttonView];
                [tempArray addObject:buttonView];
            }
            
        }
        
        // 如果是一个的titleArray 的情况, 数组的那个方法必须大于1的
        if (titleArray.count == 1) {
            
            [tempArray.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.middleBackView.mas_centerX);
                make.centerY.equalTo(self.middleBackView.mas_centerY);
                make.height.mas_equalTo(@(kDiscoverHeaderMiddleViewHeight));
            }];
            return;
        }
        
        /**
         根据titleArray.count 适当调整 space, 主要是针对 2个 - 4个的情况,此处最多4个Item
         */
        CGFloat space = 12 * DSCREEN_WIDTH_SCALE; // 根据设计尺寸换算出来的
        [tempArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:0 leadSpacing:space tailSpacing:space];
        [tempArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.middleBackView.mas_centerY);
            make.height.mas_equalTo(@(kDiscoverHeaderMiddleViewHeight));
        }];
    }
    else {
        self.middleBackView.hidden = YES;
    }
    
    
}

#pragma mark - Custom middle Tpoic Item
/**
 为什么此处不用 系统的的Button 中的title 、image, 暂时没有那样用
 是因为有点调整EdgeInsets，比较麻烦
 */
- (UIButton *)makeCustomButtonWithTitle:(NSString *)title image:(NSString *)imageString {
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectZero;
    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleToFill;
    // 为了测试临时判断是网络还是本地  /** CGSizeMake(41, 41) 是产品给的大小 */
    if ([imageString hasPrefix:@"http"]){
        [imageView yy_setImageWithURL:[NSURL URLWithString:imageString]
                          placeholder:[UIImage imageNamed:@"small_placeholder"]
                              options:kNilOptions
                             progress:nil
                            transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                            image = [image yy_imageByResizeToSize:CGSizeMake(41* DSCREEN_WIDTH_SCALE, 41* DSCREEN_WIDTH_SCALE ) contentMode:UIViewContentModeScaleAspectFill];
                                            return image;
                                        }
                           completion:nil];
        
    }
    else {
        imageView.image = [UIImage imageNamed:imageString];
    }
    imageView.userInteractionEnabled = NO;
    [button addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@(10* DSCREEN_WIDTH_SCALE ));
        make.centerX.mas_equalTo(button.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(41* DSCREEN_WIDTH_SCALE, 41* DSCREEN_WIDTH_SCALE ));
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:11];
    label.textColor = OSSVThemesColors.col_333333;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [button addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(@(-5* DSCREEN_WIDTH_SCALE));
        make.leading.mas_equalTo(@5);
        make.trailing.mas_equalTo(@(-5));
        make.top.equalTo(imageView.mas_bottom).mas_equalTo(3* DSCREEN_WIDTH_SCALE);
    }];
    
    return button;
}

#pragma mark - LazyLoad

- (SDCycleScrollView *)bannerScrollerView {
    if (!_bannerScrollerView) {
        _bannerScrollerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage imageNamed:@"placeholder_banner_pdf"]];
        _bannerScrollerView.autoScrollTimeInterval = 3.0; // 间隔时间
        _bannerScrollerView.currentPageDotColor = OSSVThemesColors.col_FDF135;
        
        _bannerScrollerView.pageDotColor = OSSVThemesColors.col_F1F1F1;
        _bannerScrollerView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _bannerScrollerView;
}

- (UIView *)middleBackView {
    if (!_middleBackView) {
        _middleBackView = [[UIView alloc] init];
        _middleBackView.backgroundColor = [UIColor whiteColor];
    }
    return _middleBackView;
}

- (UIView *)bottomBackView {
    if (!_bottomBackView) {
        _bottomBackView = [[UIView alloc] init];
    }
    return _bottomBackView;
}

- (UIButton *)superDealsButton {
    if (!_superDealsButton) {
        _superDealsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _superDealsButton.tag = DiscoveryBottomSupperDealsType;
        [_superDealsButton setAdjustsImageWhenHighlighted:NO];
        [_superDealsButton addTarget:self action:@selector(didTapBottomOfThreeItemAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _superDealsButton;
}

- (UIButton *)newinButton {
    if (!_newinButton) {
        _newinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _newinButton.tag = DiscoveryBottomNewInType;
        [_newinButton setAdjustsImageWhenHighlighted:NO];
        [_newinButton addTarget:self action:@selector(didTapBottomOfThreeItemAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _newinButton;
}

- (UIButton *)bestSellersButton {
    if (!_bestSellersButton) {
        _bestSellersButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bestSellersButton setAdjustsImageWhenHighlighted:NO];
        _bestSellersButton.tag = DiscoveryBottomBestSellersType;
        [_bestSellersButton addTarget:self action:@selector(didTapBottomOfThreeItemAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bestSellersButton;
}
@end
