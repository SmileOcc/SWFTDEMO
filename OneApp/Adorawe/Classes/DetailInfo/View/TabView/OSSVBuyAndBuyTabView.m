//
//  OSSVBuyAndBuyTabView.m
// XStarlinkProject
//
//  Created by fan wang on 2021/6/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBuyAndBuyTabView.h"
#import "STLPreference.h"

@interface OSSVBuyAndBuyTabView ()

@end

@implementation OSSVBuyAndBuyTabView

-(void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setuptabs];
    }
    return self;
}

-(void)setuptabs{
    OSSVBuyAndBuyButton *alsoLike = [[OSSVBuyAndBuyButton alloc] initWithFrame:CGRectZero];
    _youMayAlsoLike = alsoLike;
    alsoLike.title = STLLocalizedString_(@"alsoLike", nil);
    alsoLike.tag = 0;
    [self addSubview:alsoLike];
    OSSVBuyAndBuyButton *oftenBuy = [[OSSVBuyAndBuyButton alloc] initWithFrame:CGRectZero];
    oftenBuy.title = STLLocalizedString_(@"oftenBought", nil);
    _oftenBoughtWith = oftenBuy;
    oftenBuy.tag = 1;
    [self addSubview:oftenBuy];
    
    NSArray *distributeArr = @[alsoLike,oftenBuy];
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        distributeArr = @[oftenBuy,alsoLike];
    }
    [distributeArr mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    [distributeArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    
    [alsoLike addTarget:self action:@selector(didtapButton:) forControlEvents:UIControlEventTouchUpInside];
    [oftenBuy addTarget:self action:@selector(didtapButton:) forControlEvents:UIControlEventTouchUpInside];
    alsoLike.heightLighted = YES;
    self.oftenBoughtWith.redDotShow = STLPreference.isFirstIntoDetails;
    
    @weakify(self)
    [NSNotificationCenter.defaultCenter addObserverForName:STLBuyAndBuyShowRedDotNotifiName object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        BOOL needShowRedDot = [note.userInfo[kNeedShowRedDot] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            if (STLPreference.isFirstIntoDetails) {
                self.oftenBoughtWith.redDotShow = needShowRedDot;
            }
        });
    }];
}

-(void)didtapButton:(OSSVBuyAndBuyButton *)button{
    _youMayAlsoLike.heightLighted = NO;
    _oftenBoughtWith.heightLighted = NO;
    button.heightLighted = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:STLBuyAndBuySwitchNotifiName object:self userInfo:@{@"index":@(button.tag)}];
    if(button.tag == 1){
        button.redDotShow = NO;
        [NSNotificationCenter.defaultCenter postNotificationName:STLBuyAndBuyShowRedDotNotifiName object:nil userInfo:@{kNeedShowRedDot:@NO,@"sender":self}];
    }
}

-(void)setCurrentIndex:(NSInteger)index{
    _youMayAlsoLike.heightLighted = NO;
    _oftenBoughtWith.heightLighted = NO;
    
    if (index == 0) {
        _youMayAlsoLike.heightLighted = YES;
    }else if(index == 1){
        _oftenBoughtWith.heightLighted = YES;
    }
}

@end
