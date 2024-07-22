//
//  ZFGoodsDetailGoodsQualifiedCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailGoodsQualifiedCell.h"
#import "ZFInitViewProtocol.h"
#import "UILabel+HTML.h"
#import "SDCycleScrollView.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "GoodsDetailModel.h"
#import "ZFGoodsDetailEnumDefiner.h"

@interface ZFGoodsDetailGoodsQualifiedCell() <ZFInitViewProtocol,SDCycleScrollViewDelegate>
@property (nonatomic, strong) UIImageView           *iconImageView;
@property (nonatomic, strong) UIImageView           *arrowImageView;
@property (nonatomic, strong) UIView                *lineView;
@property (nonatomic, strong) SDCycleScrollView     *scrollView;
@end

@implementation ZFGoodsDetailGoodsQualifiedCell

@synthesize cellTypeModel = _cellTypeModel;

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addTapGestureBock];
    }
    return self;
}

- (void)addTapGestureBock {
    @weakify(self);
    [self addTapGestureWithComplete:^(UIView * _Nonnull view) {
        @strongify(self);
        if (![NSStringUtils isEmptyString:self.cellTypeModel.detailModel.reductionModel.url]) {
            if (self.cellTypeModel.detailCellActionBlock) { // Deeplink跳转
                self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, @(ZFQualified_ReductionType), nil);
            }
        } else {
            if (!ZFIsEmptyString(self.cellTypeModel.detailModel.reductionModel.reduc_id) &&
                !ZFIsEmptyString(self.cellTypeModel.detailModel.reductionModel.activity_type)) {
                if (self.cellTypeModel.detailCellActionBlock) { // 满减活动跳转
                    self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, @(ZFQualified_MangJianType), nil);
                }
            }
        }
    }];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.scrollView];
    [self.contentView addSubview:self.arrowImageView];
    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.size.mas_equalTo(CGSizeMake(7, 13));
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconImageView.mas_trailing).offset(10);
        make.trailing.equalTo(self.arrowImageView.mas_leading).offset(-8);
        make.top.bottom.mas_equalTo(self);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconImageView);
        make.bottom.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - setter
- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    
    // 使用 NSHTMLTextDocumentType 时，要在子线程初始化，在主线程赋值，否则会不定时出现 webthread crash
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        GoodsReductionModel *reductionModel = cellTypeModel.detailModel.reductionModel;
        NSArray *msgArray = reductionModel.showAttrTextArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scrollView.titlesGroup = [msgArray copy];
            
            if (![NSStringUtils isEmptyString:reductionModel.url]) {
                self.arrowImageView.hidden = NO;
                
            } else if(!ZFIsEmptyString(reductionModel.reduc_id) &&
                      !ZFIsEmptyString(reductionModel.activity_type)){
                self.arrowImageView.hidden = NO;
                
            } else {
                self.arrowImageView.hidden = YES;
            }
        });
    });
}

#pragma mark - getter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.image = [UIImage imageNamed:@"topic"];
        _iconImageView.userInteractionEnabled = YES;
    }
    return _iconImageView;
}

- (SDCycleScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:nil];
        _scrollView.scrollDirection = UICollectionViewScrollDirectionVertical;
        _scrollView.onlyDisplayText = YES;
        [_scrollView disableScrollGesture];
        _scrollView.backgroundColor = ZFCOLOR_WHITE;
        
    }
    return _scrollView;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *arrowIImage = [UIImage imageNamed:@"size_arrow_right"];
        _arrowImageView.image = arrowIImage;
        _arrowImageView.userInteractionEnabled = YES;
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _lineView;
}

@end
