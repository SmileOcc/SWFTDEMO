//
//  ZFSelectLiveCommentHeader.m
//  ZZZZZ
//
//  Created by YW on 2019/12/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSelectLiveCommentHeader.h"
#import "ZFInitViewProtocol.h"
#import "UILabel+HTML.h"
#import "ZFThemeManager.h"
#import "UIView+LayoutMethods.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFFullLiveTryOnView.h"

@interface ZFSelectLiveCommentHeader() <ZFInitViewProtocol>

@property (nonatomic, strong) ZFFullLiveTryOnView   *tryOnView;

@property (nonatomic, strong) UIButton              *commentButton;
@property (nonatomic, strong) UIImageView           *arrowImageView;

@end

@implementation ZFSelectLiveCommentHeader

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.tryOnView];

    [self addSubview:self.arrowImageView];
    [self addSubview:self.commentButton];
}

- (void)zfAutoLayoutView {
    
    [self.tryOnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(16);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
    }];
    
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.trailing.mas_equalTo(self.arrowImageView.mas_leading).offset(-8);
        make.width.mas_greaterThanOrEqualTo(40);
    }];
}

- (void)updateCommentNums:(NSInteger)nums liveMark:(BOOL)isMrak {
    self.commentNums = nums;
    self.isLiveMark = isMrak;
}

- (void)commentButtonAction:(UIButton *)sender {
    if (self.commentBlock) {
        self.commentBlock();
    }
}
#pragma mark - setter

- (void)setCommentNums:(NSInteger)commentNums {
    _commentNums = commentNums;
    if (_commentNums < 0) {
        _commentNums = 0;
    }
    
    NSString *title = [NSString stringWithFormat:@"%@(%li)",ZFLocalizedString(@"Live_comment_item", nil),(long)_commentNums];
    [self.commentButton setTitle:title forState:UIControlStateNormal];
}

- (void)setIsLiveMark:(BOOL)isLiveMark {
    _isLiveMark = isLiveMark;
    
    if (isLiveMark) {
        self.tryOnView.hidden = NO;
        [self.tryOnView startLoading];
    } else {
        self.tryOnView.hidden = YES;
        [self.tryOnView endLoading];
    }
}

#pragma mark - getter

- (ZFFullLiveTryOnView *)tryOnView {
    if (!_tryOnView) {
        _tryOnView = [[ZFFullLiveTryOnView alloc] initWithFrame:CGRectZero];
        _tryOnView.backgroundColor = ZFC0xFE5269();
        _tryOnView.layer.cornerRadius = 8;
        _tryOnView.layer.masksToBounds = YES;
        _tryOnView.hidden = YES;
    }
    return _tryOnView;
}

- (UIButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentButton.titleLabel.backgroundColor = [UIColor whiteColor];
        _commentButton.titleLabel.font = ZFFontSystemSize(14);
        [_commentButton setTitleColor:ColorHex_Alpha(0x999999, 1.0) forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(commentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentButton;
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
