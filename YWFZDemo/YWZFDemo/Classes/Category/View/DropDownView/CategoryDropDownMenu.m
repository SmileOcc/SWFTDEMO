//
//  DropDownMenu.m
//  ListPageViewController
//
//  Created by YW on 2/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryDropDownMenu.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "SystemConfigUtils.h"
#import "UIView+ZFViewCategorySet.h"


@interface ZFCategoryMenuBarItemView : UIView
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIImageView   *arrowImageView;
@property (nonatomic, strong) UIView        *contentView;

@property (nonatomic, strong) UILabel       *countsLabel;
@property (nonatomic, strong) UIView        *countsView;

@end

@implementation ZFCategoryMenuBarItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImageView];
    [self addSubview:self.countsView];
    [self addSubview:self.countsLabel];
}

- (void)zfAutoLayoutView {
    
    CGFloat kitemW = CGRectGetWidth(self.frame);
    if(kitemW <= 0) {
        kitemW = KScreenWidth/3;
    }
    kitemW -= 32;
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(5);
        make.width.mas_lessThanOrEqualTo(kitemW);
    }];

    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_trailing);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.trailing.mas_equalTo(self.contentView);
    }];
    
    [self.countsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.arrowImageView.mas_trailing).offset(-10);
        make.bottom.mas_equalTo(self.arrowImageView.mas_top).offset(5);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(14);
    }];
    [self.countsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.countsView);
        make.height.mas_equalTo(14);
        make.top.mas_equalTo(self.countsView.mas_top);
    }];
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _contentView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.contentMode = UIViewContentModeScaleAspectFill;
        _arrowImageView.image = ZFImageWithName(@"sift_arrow_down");
    }
    return _arrowImageView;
}

- (UILabel *)countsLabel {
    if (!_countsLabel) {
        _countsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countsLabel.textColor = ZFC0xFFFFFF();
        _countsLabel.font = [UIFont systemFontOfSize:9];
        _countsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countsLabel;
}

- (UIView *)countsView {
    if (!_countsView) {
        _countsView = [[UIView alloc] initWithFrame:CGRectZero];
        _countsView.layer.cornerRadius = 7.0;
        _countsView.layer.masksToBounds = YES;
        _countsView.backgroundColor = ZFC0xCCCCCC();
        _countsView.hidden = YES;
    }
    return _countsView;
}

@end

@interface CategoryDropDownMenu ()
@property (nonatomic, assign) NSInteger         numOfMenu;
@property (nonatomic, strong) NSArray           *indicatorArray;
@property (nonatomic, strong) NSMutableArray<CATextLayer *>    *titlesLayers;
@property (nonatomic, strong) CALayer           *topLine;
@property (nonatomic, strong) CALayer           *bottomLine;
@property (nonatomic, strong) CAGradientLayer   *spaceLine;
@property (nonatomic, assign) NSInteger         currentTapIndex;
@property (nonatomic, assign) BOOL              isSelect;

//是否标红筛选
@property (nonatomic, assign) BOOL              isMarkRefine;
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, strong) ZFCategoryMenuBarItemView *lastSelectItemView;

@end

@implementation CategoryDropDownMenu
#pragma mark - init method
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, height)];
    if (self) {
        [self configureSubViews];
        [self autoLayoutSubViews];
        self.currentTapIndex = -1; // 默认值
        self.isSelect = NO;
    }
    return self;
}

#pragma mark - Initialize
- (void)configureSubViews {
    self.backgroundColor = [UIColor whiteColor];
//    [self.layer addSublayer:self.topLine];
    [self.layer addSublayer:self.bottomLine];
}

- (void)autoLayoutSubViews {
//    self.topLine.frame = CGRectMake(0, 0 ,KScreenWidth, MIN_PIXEL);
    self.bottomLine.frame = CGRectMake(0, self.frame.size.height - 0.5 , KScreenWidth, 0.5);
}

#pragma mark - Gesture Handle
//- (void)menuTapped:(UITapGestureRecognizer *)paramSender {
//    if (_isDropAnimation) {
//        return ;
//    }
//    _isDropAnimation = YES;
//    CGPoint touchPoint = [paramSender locationInView:self];
//    // 获取下标
//    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / self.numOfMenu);
//
//    for (int i = 0; i < self.indicatorArray.count; i++) {
//        if (i != tapIndex) {
//            [self animateIndicator:self.indicatorArray[i] Forward:NO complete:^{}];
//        }
//    }
//
//    self.isSelect = (tapIndex == self.currentTapIndex && self.isSelect) ? NO : YES;
//
//    [self animateIndicator:self.indicatorArray[tapIndex] Forward:self.isSelect complete:^{
//        self.currentTapIndex = tapIndex;
//        if (self.chooseCompletionHandler) {
//            self.chooseCompletionHandler(tapIndex,self.isSelect);
//        }
//    }];
//}

- (void)animateIndicatorWithIndex:(NSInteger)index {
//    [self animateIndicator:self.indicatorArray[index] Forward:NO complete:^{}];
//    self.isSelect = (index == self.currentTapIndex && self.isSelect) ? NO : YES;
//
//    [self animateIndicator:self.indicatorArray[index] Forward:self.isSelect complete:^{
//        self.currentTapIndex = index;
//        if (self.chooseCompletionHandler) {
//            self.chooseCompletionHandler(index,self.isSelect);
//        }
//    }];
}

#pragma mark - Setter
//- (void)setTitles:(NSArray<NSString *> *)titles {
//    _titles = titles;
//    self.numOfMenu = titles.count;
//
//    self.topLine.hidden = titles.count==0;
//    self.bottomLine.hidden = titles.count==0;
//    if (self.isHideTopLine) {
//        self.topLine.hidden = YES;
//    }
//    if (self.isHideBottomLine) {
//        self.bottomLine.hidden = YES;
//    }
//
//    NSInteger numOfMenu = self.numOfMenu > 0 ? self.numOfMenu : 1;
//    CGFloat textLayerInterval = self.frame.size.width / ( numOfMenu * 2.0 );
//    CGFloat bgLayerInterval = self.frame.size.width / numOfMenu;
//
//    NSMutableArray *tempIndicatorArray = [NSMutableArray arrayWithCapacity:self.numOfMenu];
//    for (int i = 0; i < numOfMenu; i++) {
//        //bgLayer
//        CGPoint bgLayerPosition = CGPointMake((i + 0.5) * bgLayerInterval, self.frame.size.height / 2.0);
//        CALayer *bgLayer = [self createBgLayerWithColor:[UIColor whiteColor] andPosition:bgLayerPosition];
//        [self.layer addSublayer:bgLayer];
//
//        //title
//        NSString *titleString = [self.titles objectAtIndex:i];
//        CGPoint titlePosition = CGPointMake(textLayerInterval , self.frame.size.height / 2.0);
//        CATextLayer *titleLayer = [self createTextLayerWithNSString:titleString withColor:[UIColor blackColor] andPosition:titlePosition];
//        titleLayer.masksToBounds = YES;
//        [bgLayer addSublayer:titleLayer];
//        [self.titlesLayers addObject:titleLayer];
//
//        //indicator
//        if (titleLayer.frame.size.width >= (IPHONE_X_5_15 ? 90 : 100)) { //防止过长
//            titlePosition.x -= 10;
//        }
//        CAShapeLayer *indicatorLayer = [self createIndicatorWithColor:[UIColor colorWithHex:0x2d2d2d] andPosition:CGPointMake(titlePosition.x + titleLayer.bounds.size.width / 2.0 + 10, self.frame.size.height / 2.0)];
//        [bgLayer addSublayer:indicatorLayer];
//        [tempIndicatorArray addObject:indicatorLayer];
//
//        // spaceLine
//        if (i < self.numOfMenu - 1 && !self.isHideSpaceLine) {
//            CGPoint spaceLinePosition = CGPointMake(bgLayerInterval, self.frame.size.height / 2);
//            CAGradientLayer *spaceLineLayer = [self creatSpaceLineWithPosition:spaceLinePosition];
//            [bgLayer addSublayer: spaceLineLayer];
//        }
//    }
//
//    [self markRefineColor:self.isMarkRefine];
//    self.indicatorArray = [tempIndicatorArray copy];
//}

- (void)updateIndex:(NSInteger)index counts:(NSString *)counts {
    ZFCategoryMenuBarItemView *itemView = [self viewWithTag:2002 + index];
    if (itemView) {
        if (ZFIsEmptyString(counts)) {
            itemView.countsView.hidden = YES;
        } else {
            itemView.countsView.hidden = NO;
            
            if ([counts integerValue] >= 100) {
                counts = @"99";
            }
            itemView.countsLabel.text = counts;
        }
    }
}

- (void)updateIndex:(NSInteger)index title:(NSString *)title {
   ZFCategoryMenuBarItemView *itemView = [self viewWithTag:2002 + index];
    if (itemView && !ZFIsEmptyString(title)) {
        itemView.titleLabel.text = title;
    }
}

- (void)setTitles:(NSArray<NSString *> *)titles {
    if ([SystemConfigUtils isRightToLeftShow] && titles.count > 1) { //阿语时交换第一个和最后按钮位置
        NSMutableArray *tmpTitles = [NSMutableArray arrayWithArray:titles];
        [tmpTitles exchangeObjectAtIndex:0 withObjectAtIndex:(titles.count -1)];
        titles = tmpTitles;
    }
    
    _titles = titles;
    
    NSArray *subViews = self.subviews;
    for (ZFCategoryMenuBarItemView *itemView in subViews) {
        if ([itemView isKindOfClass:[ZFCategoryMenuBarItemView class]]) {
            [itemView removeFromSuperview];
        }
    }
    
    self.numOfMenu = titles.count;
    if (titles.count >= 3) {
        self.numOfMenu = 3;
    }
    

    self.topLine.hidden = titles.count==0;
    self.bottomLine.hidden = titles.count==0;
    if (self.isHideTopLine) {
        self.topLine.hidden = YES;
    }
    if (self.isHideBottomLine) {
        self.bottomLine.hidden = YES;
    }

    NSInteger numOfMenu = self.numOfMenu > 0 ? self.numOfMenu : 1;
    CGFloat kItemW = KScreenWidth / numOfMenu;

    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    for (int i=0; i<numOfMenu; i++) {
        ZFCategoryMenuBarItemView *itemView = [[ZFCategoryMenuBarItemView alloc] initWithFrame:CGRectMake(0, 0, kItemW, 44)];
        itemView.tag = 2002 + i;
        
        if (_titles.count > i) {
            itemView.titleLabel.text = ZFToString(_titles[i]);
            itemView.arrowImageView.hidden = NO;
        } else {
            itemView.arrowImageView.hidden = YES;
        }
        
        if (i == _titles.count - 1 && _titles.count == 3) {
            itemView.arrowImageView.image = [UIImage imageNamed:@"sift_filter"];
            
        } else if(i == _titles.count - 1 && self.isLastFilter) {
            itemView.arrowImageView.image = [UIImage imageNamed:@"sift_filter"];
        }

        if ([SystemConfigUtils isRightToLeftShow]) { //阿语时交换第一个和最后按钮(图片)位置
            if (i == _titles.count - 1) {
                itemView.arrowImageView.image = [UIImage imageNamed:@"sift_arrow_down"];
                
            } else if (i == 0) {
                itemView.arrowImageView.image = ZFImageWithName(@"sift_filter");
            }
        }
        
        @weakify(self);
        [itemView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            [self menuTapped:view];
        }];
        
        [self addSubview:itemView];
        [itemsArray addObject:itemView];
    }
    
    if (itemsArray.count > 1) {
        [itemsArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        [itemsArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self);
        }];
        
    } else {
        ZFCategoryMenuBarItemView *itemView = itemsArray.firstObject;
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    
}

- (void)menuTapped:(UIView *)tapView {
    if (self.isAnimating) {
        return;
    }
    
    if ([tapView isKindOfClass:[ZFCategoryMenuBarItemView class]]) {
        
        self.isAnimating = YES;
        NSInteger tapIndex = tapView.tag - 2002;
        
        if ([tapView isEqual:self.lastSelectItemView]) {
            self.isSelect = NO;
            self.currentTapIndex = -1;
            
            @weakify(self)
            [self showButtonAnimation:self.lastSelectItemView complete:^{
                @strongify(self)
                self.lastSelectItemView = nil;
                self.isAnimating = NO;
            }];
            
        } else {
            
            self.isSelect = YES;
            self.currentTapIndex = tapIndex;
            @weakify(self)
            [self showButtonAnimation:(ZFCategoryMenuBarItemView*)tapView complete:^{
                @strongify(self)
                self.lastSelectItemView = (ZFCategoryMenuBarItemView*)tapView;
                self.isAnimating = NO;
            }];

        }
        if (self.chooseCompletionHandler) {
            self.chooseCompletionHandler(tapIndex,self.isSelect);
        }
    }
    
}


- (void)setIsDropAnimation:(BOOL)isDropAnimation {
    _isDropAnimation = isDropAnimation;
}

#pragma mark - Prviate Methods
- (void)updateSelectInfoOptionWithApply:(BOOL)apply {
    if (self.titlesLayers.count==0) return;
}

//是否以及设置筛选条件
- (void)markRefineColor:(BOOL)flag {
}


#pragma mark - Public Methods
-(void)restoreIndicator:(NSInteger)index{
    [self recoverChangeButtonArrow];
}

- (void)recoverChangeButtonArrow {
    if (self.lastSelectItemView) {
        @weakify(self)
        [self showButtonAnimation:self.lastSelectItemView complete:^{
            @strongify(self)
            self.lastSelectItemView = nil;
        }];
    }
}

- (void)showButtonAnimation:(ZFCategoryMenuBarItemView *)lastItemView complete:(void (^)(void))completion{

    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if ([lastItemView isEqual:self.lastSelectItemView]) {
            lastItemView.arrowImageView.transform = CGAffineTransformIdentity;
        } else {
            if (self.lastSelectItemView) {
                self.lastSelectItemView.arrowImageView.transform = CGAffineTransformIdentity;
            }
            if (lastItemView.tag != (2002 + self.numOfMenu - 1)) {
                lastItemView.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            }
        }
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Animation Methods


#pragma mark - Getter
- (CALayer *)topLine {
    if (!_topLine) {
        _topLine = [CALayer layer];
        _topLine.backgroundColor = ZFC0xDDDDDD().CGColor;
        _topLine.hidden = YES;
    }
    return _topLine;
}

- (CALayer *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [CALayer layer];
        _bottomLine.backgroundColor = ZFC0xDDDDDD().CGColor;
        _bottomLine.hidden = YES;
    }
    return _bottomLine;
}

- (NSArray *)indicatorArray {
    if (!_indicatorArray) {
        _indicatorArray = [NSArray array];
    }
    return _indicatorArray;
}

- (NSMutableArray *)titlesLayers {
    if (!_titlesLayers) {
        _titlesLayers = [NSMutableArray array];
    }
    return _titlesLayers;
}
@end
