//
//  ZFGoodsDetailGoodsReviewViewAllCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailGoodsReviewViewAllCell.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFInitViewProtocol.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFGoodsDetailGoodsReviewViewAllCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UIButton          *viewAllButton;
@property (nonatomic, strong) UIImageView       *arrowImageView;
@end

@implementation ZFGoodsDetailGoodsReviewViewAllCell

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark -  <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.viewAllButton];
}

- (void)zfAutoLayoutView {
    [self.viewAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth, kCellDefaultHeight));
    }];
}

/** view All */
- (void)viewAllButtonAction {
    if (self.cellTypeModel.detailCellActionBlock) {
        self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, self.indexPath, nil);
    }
}

#pragma mark - getter

- (UIButton *)viewAllButton {
    if (!_viewAllButton) {
        _viewAllButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _viewAllButton.backgroundColor = [UIColor clearColor];
        _viewAllButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_viewAllButton setTitleColor:ZFCOLOR(51, 51, 51, 1.f) forState:0];;
        _viewAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_viewAllButton setTitle:ZFLocalizedString(@"TopicHead_Cell_ViewAll", nil) forState:0];
        [_viewAllButton setImage:[UIImage imageNamed:@"size_arrow_right"] forState:0];
        [_viewAllButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleRight) imageTitleSpace:3];
        [_viewAllButton convertUIWithARLanguage];
        [_viewAllButton addTarget:self action:@selector(viewAllButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _viewAllButton;
}

@end
