//
//  ZFTrackingListCell.m
//  ZZZZZ
//
//  Created by YW on 4/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFTrackingListCell.h"
#import "ZFTrackingListModel.h"
#import "ZFTrackingListContentView.h"
#import "ZFInitViewProtocol.h"
#import "Masonry.h"

@interface ZFTrackingListCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) ZFTrackingListContentView   *customView;
@end

@implementation ZFTrackingListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark -<ZFInitViewProtocol>
- (void)zfInitView {
    [self addSubview:self.customView];
}

- (void)zfAutoLayoutView {
    [self.customView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}


#pragma mark - Public Methods
+ (NSString *)setIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - Setter

- (void)setModel:(ZFTrackingListModel *)model {
    _model = model;
    [self.customView reloadDataWithModel:model];
}

- (void)setHasUpLine:(BOOL)hasUpLine {
    
    self.customView.hasUpLine = hasUpLine;
}

- (void)setHasDownLine:(BOOL)hasDownLine {
    
    self.customView.hasDownLine = hasDownLine;
}

- (void)setCurrented:(BOOL)currented {
    
    self.customView.currented = currented;
}


#pragma mark - Getter
- (ZFTrackingListContentView *)customView {
    if (!_customView) {
        _customView = [[ZFTrackingListContentView alloc] init];
        _customView.currented = NO;
        _customView.hasUpLine = YES;
        _customView.hasDownLine = YES;
    }
    return _customView;
}

@end
