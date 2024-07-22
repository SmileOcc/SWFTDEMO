//
//  ZFCommunityVideoCommentsCell.m
//  ZZZZZ
//
//  Created by YW on 16/11/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityVideoCommentsCell.h"
#import "ZFCommunityPostDetailReviewsListMode.h"
#import "YYText.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "NSStringUtils.h"
#import "NSString+Extended.h"
#import "UIColor+ExTypeChange.h"
#import "Masonry.h"
#import "Configuration.h"
#import "ZFPubilcKeyDefiner.h"

@interface ZFCommunityVideoCommentsCell ()

@property (nonatomic, strong) YYAnimatedImageView         *avatar;
@property (nonatomic, strong) UILabel                     *nickName;
@property (nonatomic, strong) UILabel                     *comments;
@property (nonatomic, strong) UIView                      *separatorWhiteLine;
@property (nonatomic, strong) UIImageView                 *rankImageView;

@end

@implementation ZFCommunityVideoCommentsCell

+ (ZFCommunityVideoCommentsCell *)commentsCellWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[ZFCommunityVideoCommentsCell class] forCellReuseIdentifier:VIDEO_COMMENTS_CELL_INENTIFIER];
    return [tableView dequeueReusableCellWithIdentifier:VIDEO_COMMENTS_CELL_INENTIFIER forIndexPath:indexPath];
}

- (void)setReviesModel:(ZFCommunityPostDetailReviewsListMode *)reviesModel {
    _reviesModel = reviesModel;
    
    //头像
    [self.avatar yy_setImageWithURL:[NSURL URLWithString:reviesModel.avatar]
                  placeholder:[UIImage imageNamed:@"public_user_small"]
                  options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                  transform:^UIImage *(UIImage *image, NSURL *url) {
                      return image;
                  }
                  completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                  }];
    //昵称
    self.nickName.text = reviesModel.nickname;
    
    //评论内容
    if (![NSStringUtils isEmptyString:reviesModel.isSecondFloorReply]) {
        if ([reviesModel.isSecondFloorReply isEqualToString:@"1"]) {
            NSString *content = [reviesModel.content replaceBrAndEnterChar];
            
            NSMutableAttributedString *mutableAttribuedString=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"Re %@ : %@",reviesModel.replyNickName,content]];
            NSRange range = NSMakeRange(0, reviesModel.replyNickName.length + 5);
            [mutableAttribuedString addAttribute:NSForegroundColorAttributeName value:ZFCOLOR(51, 51, 51, 1.0) range:range];
            [mutableAttribuedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:range];
            self.comments.attributedText = mutableAttribuedString;
        }else {
            self.comments.text = [reviesModel.content replaceBrAndEnterChar];
        }
    }
    
    self.rankImageView.hidden = YES;
    if ([reviesModel.identify_type integerValue] > 0) {
        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:reviesModel.identify_icon] options:kNilOptions];
        self.rankImageView.hidden = NO;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.avatar = [YYAnimatedImageView new];
        self.avatar.contentMode = UIViewContentModeScaleToFill;
        self.avatar.clipsToBounds = YES;
        self.avatar.userInteractionEnabled = YES;
        self.avatar.layer.cornerRadius = 20.0;
        [self.contentView addSubview:self.avatar];
        [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(12);
            make.width.height.mas_equalTo(40);
        }];
        
        [self.contentView addSubview:self.rankImageView];
        
        [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.avatar.mas_trailing);
            make.bottom.mas_equalTo(self.avatar.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(16, 16));
        }];
        
        
        self.nickName = [UILabel new];
        self.nickName.font = [UIFont systemFontOfSize:14];
        self.nickName.textColor = [UIColor colorWithHex:0x2d2d2d];
        [self.contentView addSubview:self.nickName];
        [self.nickName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
            make.leading.mas_equalTo(self.avatar.mas_trailing).mas_offset(12);
        }];

        
        self.comments = [UILabel new];
        self.comments.userInteractionEnabled = YES;
        self.comments.numberOfLines = 0;
        self.comments.font = [UIFont systemFontOfSize:12];
        self.comments.textColor = ZFCOLOR(102, 102, 102, 1.0);
        [self.contentView addSubview:self.comments];
        [self.comments mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.nickName.mas_bottom).offset(8);
            make.leading.mas_equalTo(self.avatar.mas_trailing).mas_offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        }];
        
        // 这条线的作用只是为了盖住最后一栏的系统分割线
        self.separatorWhiteLine = [[UIView alloc] initWithFrame:CGRectZero];
        self.separatorWhiteLine.backgroundColor = [UIColor whiteColor];
        self.separatorWhiteLine.hidden = YES;
        [self addSubview:self.separatorWhiteLine];
        [self.separatorWhiteLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom).offset(0.5);
            make.height.mas_equalTo(1);
        }];
        
        UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAvatar:)];
        [self.avatar addGestureRecognizer:tapAvatar];

        UITapGestureRecognizer *tapComments = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapComments:)];
        [self.comments addGestureRecognizer:tapComments];
    }
    return self;
}

- (void)hideBottomLine:(BOOL)show
{
    self.separatorWhiteLine.hidden = !show;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self bringSubviewToFront:self.separatorWhiteLine];
}

- (void)tapAvatar:(UITapGestureRecognizer*)sender {
    if (self.jumpBlock) {
        self.jumpBlock(self.reviesModel.userId);
    }
}

- (void)tapComments:(UITapGestureRecognizer*)sender {
    if (self.replyBlock) {
        self.replyBlock();
    }
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
