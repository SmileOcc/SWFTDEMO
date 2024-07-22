//
//  ZFCommunityVideoRecommendCell.m
//  ZZZZZ
//
//  Created by YW on 16/11/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityVideoRecommendCell.h"
#import "ZFThemeManager.h"
#import "ExchangeManager.h"
#import "Masonry.h"
#import "ZFPubilcKeyDefiner.h"

@interface ZFCommunityVideoRecommendCell ()
@property (nonatomic, strong) UIView *border;//边框
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *pricelLabel;
@end

@implementation ZFCommunityVideoRecommendCell

+ (ZFCommunityVideoRecommendCell *)recommendCellWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[ZFCommunityVideoRecommendCell class] forCellReuseIdentifier:VIDEO_RECOMMEND_CELL_INENTIFIER];
    return [tableView dequeueReusableCellWithIdentifier:VIDEO_RECOMMEND_CELL_INENTIFIER forIndexPath:indexPath];
}

- (void)setData:(NSDictionary *)data {
    _data = data;
    
    [self.iconImg yy_setImageWithURL:[NSURL URLWithString:data[@"pic_url"]]         
                     placeholder:[UIImage imageNamed:@"community_loading_product"]
                     options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                     progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                     transform:^UIImage *(UIImage *image, NSURL *url) {
                         return image;
                     }
                    completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                    }];
    
    self.titleLabel.text = data[@"description"];
    self.pricelLabel.text = [ExchangeManager transforPrice:data[@"price"]];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = ZFCOLOR(246, 246, 246, 1.0);
        
        self.border = [UIView new];
        self.border.backgroundColor = ZFCOLOR_WHITE;
        [self.contentView addSubview:self.border];
        
        //暂时不要边框 modify: YW
        [self.border mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        self.iconImg = [YYAnimatedImageView new];
        self.iconImg.contentMode = UIViewContentModeScaleAspectFill;
        self.iconImg.clipsToBounds = YES;
        [self.border addSubview:self.iconImg];
        
        [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.border.mas_top).mas_offset(10);
            make.bottom.mas_equalTo(self.border.mas_bottom).mas_offset(-10);
            make.leading.mas_equalTo(self.border.mas_leading).mas_offset(10);
            make.width.height.mas_equalTo(84);
        }];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = ZFCOLOR(102, 102, 102, 1.0);
        [self.border addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.iconImg.mas_trailing).mas_offset(10);
            make.trailing.mas_equalTo(self.border.mas_trailing).mas_offset(-40);
            make.top.mas_equalTo(self.iconImg.mas_top).mas_offset(2);
        }];
        
        self.pricelLabel = [UILabel new];
        self.pricelLabel.font = [UIFont systemFontOfSize:14];
        self.pricelLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        [self.border addSubview:self.pricelLabel];
        
        [self.pricelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.bottom.mas_equalTo(self.iconImg.mas_bottom).mas_offset(-2);
        }];
        
        YYAnimatedImageView *nextImg = [YYAnimatedImageView new];
        [self.border addSubview:nextImg];
        
        //暂时不要箭头 modify: YW
//        if ([SystemConfigUtils isRightToLeftShow]) {
//            nextImg.image = [UIImage imageNamed:@"detail_left_arrow"];
//        } else {
//            nextImg.image = [UIImage imageNamed:@"detail_right_arrow"];
//        }
        
        [nextImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.border.mas_centerY);
            make.trailing.mas_equalTo(self.border.mas_trailing).mas_offset(-20);
        }];
        
        UITapGestureRecognizer *tapCurrentVIew = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCurrentVIew:)];
        [self addGestureRecognizer:tapCurrentVIew];
    }
    return self;
}

- (void)tapCurrentVIew:(UITapGestureRecognizer*)sender {
    if (self.jumpBlock) {
        self.jumpBlock();
    }
}

@end
