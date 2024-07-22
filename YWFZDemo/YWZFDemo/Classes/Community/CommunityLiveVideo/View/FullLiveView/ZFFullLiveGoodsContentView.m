//
//  ZFFullLiveGoodsContentView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveGoodsContentView.h"

@interface ZFFullLiveGoodsContentView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView                               *changeControlView;
@property (nonatomic, strong) YYAnimatedImageView                  *typeImageView;
@property (nonatomic, strong) UILabel                              *typeLabel;
@property (nonatomic, strong) UIButton                             *changeButton;
@property (nonatomic, strong) UIButton                             *closeButton;

@property (nonatomic, strong) UIView                               *contentView;

@property (nonatomic, strong) NSArray<ZFGoodsModel*>               *goodsArray;



@property (nonatomic, copy) NSString                                *cateName;
@property (nonatomic, copy) NSString                                *cateID;
@property (nonatomic, copy) NSString                                *skus;

@property (nonatomic, assign) BOOL firstShow;


@end

@implementation ZFFullLiveGoodsContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.contentView];
        [self addSubview:self.changeControlView];
        [self addSubview:self.closeButton];
        [self addSubview:self.changeButton];
        
        [self.changeControlView addSubview:self.typeImageView];
        [self.changeControlView addSubview:self.typeLabel];
        
        [self.contentView addSubview:self.goodsListView];
        [self.contentView addSubview:self.goodsAttributeListView];
        [self bringSubviewToFront:self.changeButton];
        
        CGFloat contentH = [ZFVideoLiveConfigureInfoUtils liveShowViewHeight];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(contentH);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(contentH - 44);
        }];
        
        [self.changeControlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.bottom.mas_equalTo(self.contentView.mas_top).offset(-12);
            make.height.mas_equalTo(32);
            make.width.mas_lessThanOrEqualTo(200);
            make.width.mas_greaterThanOrEqualTo(100);
        }];
        
        [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.changeControlView);
        }];
        
        [self.typeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.changeControlView.mas_leading).offset(10);
            make.centerY.mas_equalTo(self.changeControlView.mas_centerY);
        }];
        
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.typeImageView.mas_trailing).offset(2);
            make.centerY.mas_equalTo(self.changeControlView.mas_centerY);
            make.trailing.mas_equalTo(self.changeControlView.mas_trailing).offset(-8);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.changeControlView.mas_centerY);
        }];
        
        [self.goodsListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        
        [self.goodsAttributeListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        
        [self.typeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.typeImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.typeImageView setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
        
        self.contentView.backgroundColor = ZFCClearColor();
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
}

- (void)cateName:(NSString *)cateName cateID:(NSString *)cateID skus:(NSString *)skus {
    self.cateName = cateName;
    self.cateID = cateID;
    self.skus = skus;
    
    [self.goodsListView cateName:cateName cateID:cateID skus:skus];
}

- (void)setVideoModel:(ZFCommunityLiveListModel *)videoModel {
    _videoModel = videoModel;
    self.goodsAttributeListView.liveVideoId = ZFToString(videoModel.idx);
}

- (void)showGoodsView:(BOOL)show {
    
    if (show && !self.firstShow) {
        self.firstShow = YES;
        if (self.goodsListView.currentGoodsArray.count > 0) {
            [self actionChange:self.changeButton];
        }
    }
    CGFloat topX;
    if (show) {
        topX = 0;
        self.hidden = NO;
        self.backgroundColor = ZFC0x000000_A(0);
    } else {
        topX = [ZFVideoLiveConfigureInfoUtils liveShowViewHeight];
    }
    
    [self setNeedsUpdateConstraints];
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.userInteractionEnabled = YES;
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(topX);
        }];
        self.backgroundColor = show ? ZFC0x000000_A(0.4) : ZFC0x000000_A(0);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = !show;
    }];
}
- (void)actionChange:(UIControl *)sender {
    if (self.goodsListView.currentGoodsArray.count > 0) {
        
        self.goodsAttributeListView.hidden = !self.goodsAttributeListView.isHidden;
        self.goodsListView.hidden = !self.goodsListView.isHidden;
        
        if (self.goodsListView.isHidden) {
            self.typeImageView.image = [UIImage imageNamed:@"live_product_image"];
            self.typeLabel.text = ZFLocalizedString(@"Live_item_display", nil);
        } else {
            self.typeLabel.text = ZFLocalizedString(@"Live_Product_list", nil);
            self.typeImageView.image = [UIImage imageNamed:@"live_product"];
        }
    }
}

- (void)actionClose:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

#pragma mark - 手势
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([self.contentView pointInside:[touch locationInView:self.contentView] withEvent:nil] && !self.contentView.isHidden) {
        return NO;
    }
    if ([self.changeControlView pointInside:[touch locationInView:self.changeControlView] withEvent:nil] && !self.changeControlView.isHidden) {
        return NO;
    }
    
    return YES;
}

- (void)actionTap:(UITapGestureRecognizer *)tap {
    [self showGoodsView:NO];
}

#pragma mark - Property Method

- (void)setCurrentRecommendGoodsId:(NSString *)currentRecommendGoodsId {
    _currentRecommendGoodsId = currentRecommendGoodsId;
    if (!ZFIsEmptyString(currentRecommendGoodsId)) {
        self.goodsListView.recommendGoodsId = currentRecommendGoodsId;
        self.goodsAttributeListView.recommendGoodsId = currentRecommendGoodsId;
    }
}

- (NSMutableArray<ZFGoodsModel *> *)currentGoodsArray {
    return self.goodsListView.currentGoodsArray;
}
- (UIView *)changeControlView {
    if (!_changeControlView) {
        _changeControlView = [[UIView alloc] initWithFrame:CGRectZero];
        _changeControlView.backgroundColor = ZFC0x000000_A(0.4);
        _changeControlView.layer.cornerRadius = 16;
        _changeControlView.layer.masksToBounds = YES;
    }
    return _changeControlView;
}

- (UIButton *)changeButton {
    if (!_changeButton) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeButton addTarget:self action:@selector(actionChange:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeButton;
}

- (YYAnimatedImageView *)typeImageView {
    if (!_typeImageView) {
        _typeImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _typeImageView.image = [UIImage imageNamed:@"live_product"];
    }
    return _typeImageView;
}

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.textColor = ZFC0xFFFFFF();
        _typeLabel.font = [UIFont systemFontOfSize:14];
        _typeLabel.text = ZFLocalizedString(@"Live_Product_list", nil);
    }
    return _typeLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"versionGuide_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _contentView;
}

- (ZFFullLiveGoodsListView *)goodsListView {
    if (!_goodsListView) {
        _goodsListView = [[ZFFullLiveGoodsListView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _goodsListView.goodsArrayBlock = ^(NSMutableArray<ZFGoodsModel *> * _Nonnull goodsArray) {
            @strongify(self)
            if (ZFJudgeNSArray(goodsArray) && goodsArray.count > 0) {
                self.goodsArray = goodsArray;
                self.changeControlView.hidden = NO;
                self.goodsAttributeListView.goodsArray = [[NSArray alloc] initWithArray:goodsArray];
            }
        };
        
        _goodsListView.selectBlock = ^(ZFGoodsModel * _Nonnull goodModel) {
            @strongify(self)
            if (self.selectBlock) {
                self.selectBlock(goodModel);
            }
        };
        
        _goodsListView.cartGoodsBlock = ^(ZFGoodsModel * _Nonnull goodModel) {
            @strongify(self)
            if (self.cartGoodsBlock) {
                self.cartGoodsBlock(goodModel);
            }
        };
        
        _goodsListView.similarGoodsBlock = ^(ZFGoodsModel * _Nonnull goodModel) {
            @strongify(self)
            if (self.similarGoodsBlock) {
                self.similarGoodsBlock(goodModel);
            }
        };
    }
    return _goodsListView;
}

- (ZFFullLiveGoodsAttributesListView *)goodsAttributeListView {
    if (!_goodsAttributeListView) {
        _goodsAttributeListView = [[ZFFullLiveGoodsAttributesListView alloc] initWithFrame:CGRectZero contentHeight:[ZFVideoLiveConfigureInfoUtils liveShowViewHeight]];
        _goodsAttributeListView.hidden = YES;
        
        @weakify(self)
        _goodsAttributeListView.cartBlock = ^{
            @strongify(self)
            if (self.cartBlock) {
                self.cartBlock();
            }
        };
        
        _goodsAttributeListView.commentListBlock = ^(GoodsDetailModel * _Nonnull goodsDetailModel) {
            @strongify(self)
            if (self.commentListBlock) {
                self.commentListBlock(goodsDetailModel);
            }
        };
        
        _goodsAttributeListView.attributeGuideSizeBlock = ^(NSString * _Nonnull sizeUrl) {
            @strongify(self)
            if (self.goodsGuideSizeBlock) {
                self.goodsGuideSizeBlock(sizeUrl);
            }
        };
    }
    return _goodsAttributeListView;
}
@end
