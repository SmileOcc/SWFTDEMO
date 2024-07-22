//
//  ZFCommentPostDetailMoreCommentView.m
//  ZZZZZ
//
//  Created by YW on 2019/11/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommentPostDetailMoreCommentView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIImage+ZFExtended.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "UIView+ZFViewCategorySet.h"

@implementation ZFCommentPostDetailMoreCommentView


+ (ZFCommentPostDetailMoreCommentView *)commentPostDetailMoreCommentViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSString *identifer = NSStringFromClass([self class]);
    [collectionView registerClass:[self class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:identifer];
    
    ZFCommentPostDetailMoreCommentView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:identifer forIndexPath:indexPath];
    
    return headerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        [self setupView];
        [self layout];
    }
    return self;
}

- (void)configurateNums:(NSInteger)counts {

    if (counts > 0) {
        self.infoLabel.text = [NSString stringWithFormat:@"%@(%li)",ZFLocalizedString(@"Community_Post_Detail_See_All_Comments", nil),(long)counts];
    } else {
        self.infoLabel.text = ZFLocalizedString(@"Community_Post_Detail_See_All_Comments", nil);
    }
}

- (void)setupView {
    
    self.backgroundColor = ZFC0xF2F2F2();
    [self addSubview:self.mainView];
    [self addSubview:self.infoLabel];
    [self addSubview:self.arrowImageView];
    [self addSubview:self.moreButton];
}

- (void)layout {
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self);
        make.height.mas_equalTo(40);
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mainView.mas_centerY);
        make.centerX.mas_equalTo(self.mainView.mas_centerX);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 32);
        make.height.mas_equalTo(40);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.moreButton.mas_leading);
        make.centerY.mas_equalTo(self.moreButton.mas_centerY);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.moreButton.mas_trailing);
        make.centerY.mas_equalTo(self.moreButton.mas_centerY);
        make.leading.mas_equalTo(self.infoLabel.mas_trailing).offset(-2);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
}
- (void)actionMore:(UIButton *)sender {
    if (self.tapMoreBlock) {
        self.tapMoreBlock();
    }
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton addTarget:self action:@selector(actionMore:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _infoLabel.textColor = ZFC0x999999();
        _infoLabel.font = [UIFont systemFontOfSize:14];
    }
    return _infoLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"account_arrow"];
        [_arrowImageView convertUIWithARLanguage];
        
    }
    return _arrowImageView;
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectZero];
        _mainView.backgroundColor = ZFC0xFFFFFF();
    }
    return _mainView;
}
@end
