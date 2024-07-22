//
//  ZFCommunityPostReplyCommentCell.m
//  ZZZZZ
//
//  Created by YW on 2018/7/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostReplyCommentCell.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "UIButton+ZFButtonCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "UIView+ZFViewCategorySet.h"
#import "Masonry.h"
#import "Constants.h"

static CGFloat const kUserImageHeight = 40.0f;
@interface ZFCommunityPostReplyCommentCell ()

@property (nonatomic, strong) YYAnimatedImageView   *userImageView;
@property (nonatomic, strong) UILabel               *nickNameLabel;
@property (nonatomic, strong) UILabel               *commentLabel;
@property (nonatomic, strong) UIButton              *replyButton;
@property (nonatomic, strong) UIView                *lineView;
@property (nonatomic, strong) UIButton              *userButton;
@property (nonatomic, strong) UIImageView           *rankImageView;


@end

@implementation ZFCommunityPostReplyCommentCell

+ (instancetype)commentCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSString *identifer = NSStringFromClass([self class]);
    [tableView registerClass:[self class] forCellReuseIdentifier:identifer];
    ZFCommunityPostReplyCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupView];
        [self layout];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.userImageView];
    [self.contentView addSubview:self.nickNameLabel];
    [self.contentView addSubview:self.commentLabel];
    [self.contentView addSubview:self.replyButton];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.userButton];
    [self.contentView addSubview:self.rankImageView];

}

- (void)layout {
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(16.0f);
        make.top.mas_equalTo(self.contentView).offset(12.0f);
        make.width.height.mas_equalTo(kUserImageHeight);
    }];
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(8.0f);
        make.trailing.mas_equalTo(self.contentView).offset(-16.0f);
        make.top.mas_equalTo(self.userImageView.mas_top).offset(2.0f);
        make.height.mas_equalTo(16.0f);
    }];
    
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(8.0f);
        make.trailing.mas_equalTo(self.contentView).offset(-16.0f);
        make.top.mas_equalTo(self.nickNameLabel.mas_bottom).offset(4.0f);
        make.height.mas_greaterThanOrEqualTo(16.0f);
    }];
        
    [self.replyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(8.0f);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12.0f);
        make.top.mas_equalTo(self.commentLabel.mas_bottom).offset(4.0f);
        make.height.mas_equalTo(16.0f);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(16.0f);
        make.trailing.mas_equalTo(self.contentView).offset(-16.0f);
        make.height.mas_equalTo(MIN_PIXEL);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-MIN_PIXEL);
    }];
    
    [self.userButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.userImageView.mas_centerX);
        make.centerY.mas_equalTo(self.userImageView.mas_centerY);
        make.width.mas_equalTo(kUserImageHeight + 16);
        make.height.mas_equalTo(kUserImageHeight + 12);
    }];
    
    [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.userImageView.mas_trailing);
        make.bottom.mas_equalTo(self.userImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self layoutIfNeeded];
    [self.replyButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:2.0];
}

//- (void)replyButtonAction {
//    if (self.replyCommentHandle) {
//        self.replyCommentHandle();
//    }
//}

- (void)actionUser:(UIButton *)sender {
    if (self.userBlock) {
        self.userBlock(self.model);
    }
}

- (void)setModel:(ZFCommunityPostDetailReviewsListMode *)model {
    _model = model;
    
    [self.userImageView yy_setImageWithURL:[NSURL URLWithString:ZFToString(_model.avatar)]
                               placeholder:[UIImage imageNamed:@"public_user"]];
    self.nickNameLabel.text = ZFToString(model.nickname);
    
    NSString *tmpContentString = [model.content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([model.isSecondFloorReply boolValue]) {
        tmpContentString = [NSString stringWithFormat:@"Re %@:%@", model.replyNickName, tmpContentString];
    }
    NSString *commentStr = [tmpContentString stringByRemovingPercentEncoding];
    self.commentLabel.text = commentStr;
    
    
    self.replyButton.hidden = [model.userId isEqualToString:USERID];
    if (self.replyButton.hidden) {
        [self.replyButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-8);
            make.height.mas_equalTo(0.0f);
        }];
    } else {
        [self.replyButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12.0f);
            make.height.mas_equalTo(16.0f);
        }];
    }
    
    self.rankImageView.hidden = YES;
    if ([_model.identify_type integerValue] > 0) {
        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:_model.identify_icon] options:kNilOptions];
        self.rankImageView.hidden = NO;
    }
    
}

- (void)setIsHideLine:(BOOL)isHideLine {
    _isHideLine = isHideLine;
    self.lineView.hidden = _isHideLine;
}

#pragma mark - getter/setter
- (YYAnimatedImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [[YYAnimatedImageView alloc] init];
        _userImageView.layer.cornerRadius  = kUserImageHeight / 2;
        _userImageView.layer.masksToBounds = YES;
    }
    return _userImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont systemFontOfSize:14.0];
        _nickNameLabel.textColor = [UIColor colorWithHex:0x999999];
    }
    return _nickNameLabel;
}

- (UILabel *)commentLabel {
    if (!_commentLabel) {
        _commentLabel = [[UILabel alloc] init];
        _commentLabel.font = [UIFont systemFontOfSize:14.0];
        _commentLabel.textColor = [UIColor colorWithHex:0x2D2D2D];
        _commentLabel.numberOfLines = 0;
    }
    return _commentLabel;
}

- (UIButton *)replyButton {
    if (!_replyButton) {
        _replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _replyButton.titleLabel.font = [UIFont systemFontOfSize:10.0];
        _replyButton.userInteractionEnabled = NO;
//        [_replyButton addTarget:self action:@selector(replyButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_replyButton setTitleColor:[UIColor colorWithHex:0x999999] forState:UIControlStateNormal];
        [_replyButton setImage:[UIImage imageNamed:@"community_topiccomment_reply"] forState:UIControlStateNormal];
        _replyButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_replyButton setTitle:ZFLocalizedString(@"community_topiccomment_reply", nil) forState:UIControlStateNormal];
        [_replyButton convertUIWithARLanguage];
    }
    return _replyButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHex:0xdddddd];
    }
    return _lineView;
}


- (UIButton *)userButton {
    if (!_userButton) {
        _userButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userButton addTarget:self action:@selector(actionUser:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _userButton;
}

- (UIImageView *)rankImageView {
    if (!_rankImageView) {
        _rankImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _rankImageView.backgroundColor = [UIColor clearColor];
        _rankImageView.userInteractionEnabled = YES;
        _rankImageView.hidden = YES;
    }
    return _rankImageView;
}
@end
