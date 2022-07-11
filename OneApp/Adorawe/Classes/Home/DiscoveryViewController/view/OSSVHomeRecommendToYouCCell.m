//
//  OSSVHomeRecommendToYouCCell.m
// OSSVHomeRecommendToYouCCell
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeRecommendToYouCCell.h"

@interface OSSVHomeRecommendToYouCCell ()

//@property (nonatomic, strong) UILabel       *centerTitleLabel;
//@property (nonatomic, strong) UIImageView   *iconImageView;

@property (nonatomic, strong) UIImageView     *contentImageView;
@end

@implementation OSSVHomeRecommendToYouCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        [self addSubview:self.contentImageView];
        
        [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
//        [self addSubview:self.centerTitleLabel];
//        [self addSubview:self.iconImageView];
//
//        CGFloat textWith = [self.centerTitleLabel.text
//                            boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 40)
//                            options:NSStringDrawingUsesLineFragmentOrigin
//                            attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
//                            context:nil].size.width + 10;
//
//        [self.centerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self).offset(15);
//            make.width.mas_equalTo(textWith);
//            make.top.bottom.equalTo(self);
//        }];
//
//        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.centerTitleLabel.mas_right).offset(5);
//            make.centerY.equalTo(self.centerTitleLabel);
//            make.width.mas_equalTo(9);
//            make.height.mas_equalTo(12);
//        }];
    }
    return self;
}

#pragma mark - LazyLoad
//- (UILabel *)centerTitleLabel {
//    if (!_centerTitleLabel) {
//        _centerTitleLabel = [[UILabel alloc] init];
//        _centerTitleLabel.textColor = OSSVThemesColors.col_212121;
//        _centerTitleLabel.text = STLLocalizedString_(@"Recommendations", nil);
//        _centerTitleLabel.textAlignment = NSTextAlignmentLeft;
//        _centerTitleLabel.font = [UIFont boldSystemFontOfSize:16];
//    }
//    return _centerTitleLabel;
//}
//
//- (UIImageView *)iconImageView {
//    if (!_iconImageView) {
//        _iconImageView = [[UIImageView alloc] init];
//        _iconImageView.image = [UIImage imageNamed:@"Tinder"];
//    }
//    return _iconImageView;
//}

- (UIImageView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _contentImageView.image = [OSSVSystemsConfigsUtils isRightToLeftShow] ?  [UIImage imageNamed:@"you_may_like_ar"] : [UIImage imageNamed:@"you_may_like_en"];
    }
    return _contentImageView;
}

@end


@implementation STLJustForYouCellModel
@synthesize dataSource = _dataSource;
@synthesize channelId = _channelId;
@synthesize channelName = _channelName;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)setDataSource:(NSObject *)dataSource
{
    _dataSource = dataSource;
}

- (void)setChannelId:(NSString *)channelId {
    _channelId = channelId;
}
- (void)setChannelName:(NSString *)channelName {
    _channelName = channelName;
}
-(CGSize)customerSize {
    return CGSizeMake(SCREEN_WIDTH, floor(SCREEN_WIDTH * 119.0 / 1242.0));
}

-(NSString *)reuseIdentifier {
    return @"JustForYouCellID";
}

+(NSString *)reuseIdentifier {
    return @"JustForYouCellID";
}

@end
