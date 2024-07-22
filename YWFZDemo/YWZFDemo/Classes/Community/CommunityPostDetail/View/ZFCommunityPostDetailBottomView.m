//
//  ZFCommunityPostDetailBottomView.m
//  ZZZZZ
//
//  Created by YW on 2018/7/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostDetailBottomView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "NSStringUtils.h"
#import "YWCFunctionTool.h"
#import "UIImage+ZFExtended.h"

@interface ZFCommunityPostDetailBottomView ()<ZFInitViewProtocol>

@property (nonatomic, strong) UIButton *likeButton;       // 点赞
@property (nonatomic, strong) UIButton *collectButton;    // 收藏
@property (nonatomic, strong) UIButton *commentButton;    // 评论
@property (nonatomic, strong) UIView   *separtorView;     // 分割线
@property (nonatomic, assign) BOOL     isLike;
@property (nonatomic, assign) BOOL     isCollect;



@end

@implementation ZFCommunityPostDetailBottomView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    [self addSubview:self.likeButton];
    [self addSubview:self.collectButton];
    [self addSubview:self.commentButton];
    [self addSubview:self.relationButton];
    [self addSubview:self.separtorView];
}

- (void)zfAutoLayoutView {
    [self.separtorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self);
        make.height.mas_equalTo(MIN_PIXEL);
    }];
    
    CGFloat width = KScreenWidth / 4.0;
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(self);
        make.width.mas_equalTo(width);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-kiphoneXHomeBarHeight);
    }];
    
    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.leading.mas_equalTo(self.likeButton.mas_trailing);
        make.width.mas_equalTo(self.likeButton.mas_width);
        make.height.mas_equalTo(self.likeButton.mas_height);
    }];
    
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.leading.mas_equalTo(self.collectButton.mas_trailing);
        make.width.mas_equalTo(self.collectButton.mas_width);
        make.height.mas_equalTo(self.collectButton.mas_height);
    }];
    
    [self.relationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.commentButton.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.width.mas_equalTo(72);
        make.height.mas_equalTo(32);
    }];
    
}

#pragma mark - event
- (void)likeAction:(UIButton *)button {
    if (self.likeHandle) {
        [button.imageView.layer addAnimation:[button.imageView zfAnimationFavouriteScale] forKey:@"communityLike"];
        self.likeHandle(button.selected);
    }
}

- (void)collectAction:(UIButton *)button {
    if (self.collectHandle) {
        [button.imageView.layer addAnimation:[button.imageView zfAnimationFavouriteScale] forKey:@"communityCollect"];
        self.collectHandle(button.selected);
    }
}
- (void)commentAction:(UIButton *)button {
    if (self.commentHandle) {
        self.commentHandle();
    }
}

- (void)relationAction:(UIButton *)button {
    if (self.relatedHandle) {
        button.selected = !button.selected;
        button.backgroundColor = button.isSelected ? ZFC0xFE5269() : ZFC0x2D2D2D();
        self.relatedHandle(button.selected);
        
        self.likeButton.enabled = !button.selected;
        self.commentButton.enabled = !button.selected;
        self.collectButton.enabled = !button.selected;
        
        if (self.isLike && !button.selected) {
            self.likeButton.selected = YES;
        } else {
            self.likeButton.selected = NO;
        }
        if (self.isCollect && !button.selected) {
            self.collectButton.selected = YES;
        } else {
            self.collectButton.selected = NO;
        }
    }
}

- (void)setRelateUnselected {
    
    self.relationButton.selected = NO;
    self.relationButton.backgroundColor = self.relationButton.isSelected ? ZFC0xFE5269() : ZFC0x2D2D2D();

    self.likeButton.enabled      = !self.relationButton.selected;
    self.commentButton.enabled   = !self.relationButton.selected;
    self.collectButton.enabled = !self.relationButton.selected;
    self.likeButton.selected     = self.isLike;
    self.collectButton.selected = self.isCollect;
}

#pragma mark - method
- (void)exChangeButtonEdge:(UIButton *)button {
    [button zfLayoutStyle:ZFButtonEdgeInsetsStyleTop imageTitleSpace:2.0];
}

- (void)setLikeNumber:(NSString *)likeNumber isMyLiked:(BOOL)isMyLiked {
    
    self.isLike = isMyLiked;
    NSString *countStr = [self formatNumberStr:likeNumber];
    NSString *titleString = [NSString stringWithFormat:ZFLocalizedString(@"community_topicdetail_like", nil), countStr];
    
    if (self.isLike) {
        titleString = [NSString stringWithFormat:ZFLocalizedString(@"community_topicdetail_liked", nil), countStr];
    }
    if (ZFIsEmptyString(countStr)) {
        titleString = [NSStringUtils trimmingStartEndWhitespace:titleString];
    }
    
    [self.likeButton setTitle:titleString forState:UIControlStateNormal];
    [self exChangeButtonEdge:self.likeButton];
    self.likeButton.selected = self.isLike;
    
}

- (void)setCommentNumber:(NSString *)commentNumber {
    NSString *countStr = [self formatNumberStr:commentNumber];
    NSString *titleString = [NSString stringWithFormat:ZFLocalizedString(@"community_topicdetail_commented", nil), countStr];
    if (ZFIsEmptyString(countStr)) {
        titleString = [NSStringUtils trimmingStartEndWhitespace:titleString];
    }
    
    [self.commentButton setTitle:titleString forState:UIControlStateNormal];
    [self exChangeButtonEdge:self.commentButton];
}

- (void)setCollectNumber:(NSString *)collectNumber isCollect:(BOOL)isCollect{
    self.isCollect = isCollect;
    NSString *countStr = [self formatNumberStr:collectNumber];
    NSString *titleString = [NSString stringWithFormat:ZFLocalizedString(@"Community_save", nil), countStr];
    
    if (self.isCollect) {
        titleString = [NSString stringWithFormat:ZFLocalizedString(@"Community_saved", nil), countStr];
    }
    if (ZFIsEmptyString(countStr)) {
        titleString = [NSStringUtils trimmingStartEndWhitespace:titleString];
    }
    
    [self.collectButton setTitle:titleString forState:UIControlStateNormal];
    [self exChangeButtonEdge:self.collectButton];
    self.collectButton.selected = self.isCollect;
}

- (NSString *)formatNumberStr:(NSString *)string {
    if (ZFIsEmptyString(string)) {
        return @"";
    }
    if ([string isEqualToString:@"0"]) {
        return @"";
    }
    return [NSStringUtils formatKMString:string];
}

+ (CGFloat)defaultHeight {
    return 49.0 + kiphoneXHomeBarHeight;
}

#pragma mark - getter/setter
- (UIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];

        _likeButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
        [_likeButton setTitleColor:ColorHex_Alpha(0x333333, 1.0) forState:UIControlStateNormal];
        [_likeButton setTitleColor:ZFC0xFE5269() forState:UIControlStateSelected];
        [_likeButton setTitleColor:ColorHex_Alpha(0x999999, 1.0) forState:UIControlStateDisabled];
        
        [_likeButton setImage:[UIImage imageNamed:@"community_topicdetail_like_normal"] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"community_topicdetail_like_disable"] forState:UIControlStateDisabled];
        
        UIImage *highLikeImage = [UIImage imageNamed:@"community_topicdetail_like_high"];
        [_likeButton setImage:[highLikeImage imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        
        [_likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_likeButton convertUIWithARLanguage];
    }
    return _likeButton;
}

- (UIButton *)collectButton {
    if (!_collectButton) {
        _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _collectButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
        [_collectButton setTitleColor:ColorHex_Alpha(0x333333, 1.0) forState:UIControlStateNormal];
        [_collectButton setTitleColor:ZFC0xFE5269() forState:UIControlStateSelected];
        [_collectButton setTitleColor:ColorHex_Alpha(0x999999, 1.0) forState:UIControlStateDisabled];
        
        [_collectButton setImage:[UIImage imageNamed:@"community_topicdetail_wishlist_normal"] forState:UIControlStateNormal];
        [_collectButton setImage:[UIImage imageNamed:@"community_topicdetail_wishlist_disable"] forState:UIControlStateDisabled];
        
        UIImage *highWishImage = [UIImage imageNamed:@"community_topicdetail_wishlist_high"];
        
        [_collectButton setImage:[highWishImage imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        
        [_collectButton addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];

        [_collectButton convertUIWithARLanguage];
    }
    return _collectButton;
}

- (UIButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_commentButton setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
        [_commentButton setTitleColor:[UIColor colorWithHex:0x999999] forState:UIControlStateDisabled];
        [_commentButton setImage:[UIImage imageNamed:@"community_topicdetail_comment_nomarl"] forState:UIControlStateNormal];
        [_commentButton setImage:[UIImage imageNamed:@"community_topicdetail_comment_unenble"] forState:UIControlStateDisabled];
        _commentButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
        
        [_commentButton addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_commentButton convertUIWithARLanguage];
    }
    return _commentButton;
}

- (UIButton *)relationButton {
    if (!_relationButton) {
        _relationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _relationButton.layer.cornerRadius = 2;
        _relationButton.layer.masksToBounds = YES;
        _relationButton.backgroundColor = ZFC0x2D2D2D();
        [_relationButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        [_relationButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateSelected];
        _relationButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_relationButton setTitle:@"Items" forState:UIControlStateNormal];
        [_relationButton addTarget:self action:@selector(relationAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _relationButton;
}

- (UIView *)separtorView {
    if (!_separtorView) {
        _separtorView = [[UIView alloc] init];
        _separtorView.backgroundColor = ColorHex_Alpha(0xdddddd, 1.0);
    }
    return _separtorView;
}


@end
