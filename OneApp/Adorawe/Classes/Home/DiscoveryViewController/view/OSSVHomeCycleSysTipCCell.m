//
//  OSSVHomeCycleSysTipCCell.m
// OSSVHomeCycleSysTipCCell
//
//  Created by odd on 2020/10/16.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVHomeCycleSysTipCCell.h"
#import "OSSVScrollAdvCCellModel.h"
#import "UIColor+STLColorChange.h"

@interface OSSVHomeCycleSysTipCCell ()<STLCycleTipViewDelegate>
@property (nonatomic, strong) NSArray *textArray;
@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSArray *marqueeTextColor;
@property (nonatomic, strong) NSArray *marqueeBgColor;
@property (nonatomic, strong) NSArray *listArray;

@end
@implementation OSSVHomeCycleSysTipCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;



- (void)dealloc {
    STLLog(@"----- STLCycleSystemTipCCell");
    if (_testCycle) {
        [_testCycle cancelMessageTimer];
        _testCycle = nil;
    }
}
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.testCycle cancelMessageTimer];
    
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _listArray = [NSArray array];
        _textArray = [NSArray array];
        _marqueeBgColor = [NSArray array];
        _marqueeTextColor = [NSArray array];
        
        _titleArray = [NSMutableArray array];
        self.contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];

        [self.contentView addSubview:self.testCycle];

        [self.testCycle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(self.contentView);
        }];
        
    }
    return self;
}

- (void)setChannelId:(NSString *)channelId {
    _channelId = channelId;
}

-(void)setModel:(OSSVCycleSysCCellModel *)model {
    
    _model = model;
    if ([_model.dataSource isKindOfClass:[NSArray class]]) {
        self.listArray = (NSArray *)model.dataSource;
        NSMutableArray *slideBannerArray = [[NSMutableArray alloc] init];
        NSMutableArray *textColorArray = [[NSMutableArray alloc] init];
        NSMutableArray *textBgColorArray = [[NSMutableArray alloc] init];
        
        [self.listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[OSSVAdvsEventsModel class]]) {*stop = YES;}
            OSSVAdvsEventsModel *model = obj;
            if (model.marqueeText.length) {
                [slideBannerArray addObject:model.marqueeText];
            }
            if (model.marqueeColor.length) {
                [textColorArray addObject:model.marqueeColor];
            }
            if (model.marqueeBgColor.length) {
                [textBgColorArray addObject:model.marqueeBgColor];
            }
        }];
        self.textArray = [slideBannerArray copy];
        self.marqueeTextColor = [textColorArray copy];
        self.marqueeBgColor = [textBgColorArray copy];
        
        
        self.testCycle.datasArray = self.listArray;
        [self.testCycle startMoveMessageAnimate];
        self.testCycle.layer.masksToBounds = YES;
    }
}

- (void)stl_CycleTipView:(OSSVCycleMSGView *)cycleTipView advEvent:(OSSVAdvsEventsModel *)advModel {
    
    if (advModel) {
        
        NSInteger index = [cycleTipView.datasArray indexOfObject:advModel];
        if (_delegate && [_delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:index:)]){
            [self.delegate STL_HomeBannerCCell:self advEventModel:advModel index:index];
        }
    }
}

- (void)stl_CycleTipView:(OSSVCycleMSGView *)cycleTipView currentAdv:(OSSVAdvsEventsModel *)advModel {
    if (advModel) {
        
        NSInteger index = [cycleTipView.datasArray indexOfObject:advModel];
        if (_delegate && [_delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:showCellIndex:)]){
            [self.delegate STL_HomeBannerCCell:self advEventModel:advModel showCellIndex:index];
        }
    }
}


- (OSSVCycleMSGView *)testCycle {
    if (!_testCycle) {
        _testCycle = [[OSSVCycleMSGView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32)];
        _testCycle.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _testCycle.delegate = self;
    }
    return _testCycle;
}

@end
