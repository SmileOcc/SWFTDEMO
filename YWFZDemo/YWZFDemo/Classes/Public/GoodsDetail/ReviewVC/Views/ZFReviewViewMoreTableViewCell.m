
//
//  ZFReviewViewMoreTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/11/30.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFReviewViewMoreTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFReviewViewMoreTableViewCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UIView            *containView;
@property (nonatomic, strong) UILabel           *viewAllLabel;
@property (nonatomic, strong) UIImageView       *arrowImageView;
@end

@implementation ZFReviewViewMoreTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark -  <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.containView];
    [self.containView addSubview:self.viewAllLabel];
    [self.containView addSubview:self.arrowImageView];
}

- (void)zfAutoLayoutView {
    
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.viewAllLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.containView);
        make.centerY.mas_equalTo(self.containView);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.viewAllLabel.mas_trailing).offset(8);
        make.trailing.centerY.mas_equalTo(self.containView);
    }];
}

#pragma mark - getter
- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc] initWithFrame:CGRectZero];
        _containView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _containView;
}

- (UILabel *)viewAllLabel {
    if (!_viewAllLabel) {
        _viewAllLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _viewAllLabel.backgroundColor = [UIColor whiteColor];
        _viewAllLabel.font = [UIFont systemFontOfSize:14];
        _viewAllLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _viewAllLabel.textAlignment = NSTextAlignmentCenter;
        _viewAllLabel.text = ZFLocalizedString(@"TopicHead_Cell_ViewAll", nil);
    }
    return _viewAllLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"size_arrow_right"];
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

@end
