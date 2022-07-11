//
//  YXNewsLiveSectionView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/5.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXNewsLiveSectionView.h"
#import <Lottie/Lottie.h>
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "YXNewCourseModel.h"

#pragma mark - 组
@interface YXNewsLiveSectionView ()

@property (nonatomic, strong) UIView *bottomView;

@end

@implementation YXNewsLiveSectionView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.clipsToBounds = YES;
    
    UILabel *titleLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"news_live_preview"] textColor:[UIColor qmui_colorWithHexString:@"#353547"] textFont:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium]];
    
    UIControl *tapControl = [[UIControl alloc] init];
    [tapControl addTarget:self action:@selector(arrowClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons_news_more"]];
    
    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = QMUITheme.themeTextColor;

    [self addSubview:leftView];
    [self addSubview:titleLabel];
    [self addSubview:arrow];
    [self addSubview:tapControl];
    
    
    [self addSubview:self.bottomView];
    [self addSubview:arrow];
    
    
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.mas_equalTo(4);
        make.height.mas_equalTo(17);
        make.top.equalTo(self).offset(16);
    }];
    
    [tapControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(12);
        make.height.mas_equalTo(25);
        make.left.equalTo(self).offset(12);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(47);
        make.bottom.equalTo(self).offset(-5);
        make.right.left.equalTo(self);
    }];
    
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-18);
        make.centerY.equalTo(titleLabel);
    }];

}

- (void)arrowClick:(UIButton *)sender {
    if (self.arrowCallBack) {
        self.arrowCallBack();
    }
}

- (void)setList:(NSArray *)list {
    _list = list;
    for (UIView *view in self.bottomView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat leftPadding = 12;
    CGFloat margin = 9;
    CGFloat width = (YXConstant.screenWidth - 12 * 2 - 9) * 0.5;
    NSInteger count = list.count > 2 ? 2 : list.count;
    for (int i = 0; i < count; ++i) {
        YXNewsLiveDetailView *view = [[YXNewsLiveDetailView alloc] init];
        view.liveModel = list[i];
        
        UIControl *click = [[UIControl alloc] init];
        [click addTarget:self action:@selector(clickDetail:) forControlEvents:UIControlEventTouchUpInside];
        click.tag = i;
        [view addSubview:click];
        [click mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
        
        [self.bottomView addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(i * (width + margin) + leftPadding);
            make.top.bottom.equalTo(self.bottomView);
            make.width.mas_equalTo(width);
        }];
    }
}

- (void)clickDetail:(UIControl *)sender {
    YXLiveModel *model = self.list[sender.tag];
    if (self.detailViewClickCallBack) {
        self.detailViewClickCallBack(model);
    }
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}


@end

#pragma mark - 直播状态的view
@interface YXNewsLiveStatusView ()
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) LOTAnimationView *iconView;
@property (nonatomic, strong) UILabel *leftLabel;

@property (nonatomic, strong) CAGradientLayer *glLayer;
@end

@implementation YXNewsLiveStatusView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.layer.cornerRadius = 1;
    self.clipsToBounds = YES;
    
    self.glLayer = [[CAGradientLayer alloc] init];
    self.glLayer.startPoint = CGPointMake(0, 0.5);
    self.glLayer.endPoint = CGPointMake(1, 0.5);
    self.glLayer.locations = @[@(0), @(1.0f)];
    
    [self.layer addSublayer:self.glLayer];
    
    self.backgroundColor = UIColor.clearColor;
    
    self.leftView = [[UIView alloc] init];
    self.leftView.clipsToBounds = YES;
    
    self.rightLabel = [QMUILabel labelWithText:@"--" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:10]];
    self.rightLabel.backgroundColor = [[UIColor qmui_colorWithHexString:@"#191919"] colorWithAlphaComponent:0.5];
    self.rightLabel.textAlignment = NSTextAlignmentCenter;
    self.rightLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    
    self.leftLabel = [UILabel labelWithText:@"" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:10]];
    self.leftLabel.textAlignment = NSTextAlignmentRight;
    
    self.iconView = [LOTAnimationView animationNamed:@"living"];
    self.iconView.frame = CGRectMake(0, 0, 12, 12);
    self.iconView.loopAnimation = YES;
    [self.iconView play];
        
    [self addSubview:self.rightLabel];
    [self addSubview:self.leftView];
    
    [self.leftView addSubview:self.iconView];
    [self.leftView addSubview:self.leftLabel];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self);
        make.left.equalTo(self.leftView.mas_right);
    }];
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftView).offset(3);
        make.centerY.equalTo(self.leftView);
        make.width.height.mas_equalTo(12);
    }];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.leftView);
        make.right.equalTo(self.leftView).offset(-4);
        make.left.equalTo(self.iconView.mas_right).offset(2);
    }];
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.glLayer.frame = self.leftView.frame;
    if (self.status == YXNewsLiveStatusPre) {
        self.glLayer.colors = @[(__bridge id)[UIColor colorWithRed:107/255.0 green:184/255.0 blue:255/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:47/255.0 green:121/255.0 blue:255/255.0 alpha:1.0].CGColor];
    } else if (self.status == YXNewsLiveStatusLive){
        self.glLayer.colors = @[(__bridge id)[UIColor colorWithRed:253/255.0 green:154/255.0 blue:161/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:234/255.0 green:61/255.0 blue:61/255.0 alpha:1.0].CGColor];
    } else {
        self.glLayer.colors = @[(__bridge id)[UIColor qmui_colorWithHexString:@"#FA6400"].CGColor, (__bridge id)[UIColor qmui_colorWithHexString:@"#FA6400"].CGColor];
    }
}

- (void)setStatus:(YXNewsLiveStatus)status {
    _status = status;
    if (status == YXNewsLiveStatusPre) {
        // 预告
        self.leftLabel.text = [YXLanguageUtility kLangWithKey:@"news_preview"];
        [self.leftLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.leftView);
            make.right.equalTo(self.leftView).offset(-4);
            make.left.equalTo(self.leftView).offset(4);
        }];

        self.iconView.hidden = YES;
        [self.iconView stop];
    } else if (status == YXNewsLiveStatusLive) {
        // 直播中
        self.leftLabel.text = [YXLanguageUtility kLangWithKey:@"news_live"];
        [self.leftLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.leftView);
            make.right.equalTo(self.leftView).offset(-4);
            make.left.equalTo(self.iconView.mas_right).offset(2);
        }];
        self.iconView.hidden = NO;
        [self.iconView play];
    } else {
        // 回放
        if (self.tagStr.length > 0) {
            self.leftLabel.text = self.tagStr;
            [self.leftLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self.leftView);
                make.right.equalTo(self.leftView).offset(-4);
                make.left.equalTo(self.leftView).offset(4);
            }];
        } else {
            self.leftLabel.text = @"";
            [self.leftLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self.leftView);
                make.right.equalTo(self.leftView).offset(0);
                make.left.equalTo(self.leftView).offset(0);
            }];
        }
        self.iconView.hidden = YES;
        [self.iconView stop];
    }
    
    [self setNeedsDisplay];
}


@end

#pragma mark - 直播详情的view
@interface YXNewsLiveDetailView ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, strong) UIImageView *liveStatus;
@property (nonatomic, strong) YXNewsLiveStatusView *statusView;

@property (nonatomic, strong) UILabel *desLabel;

@property (nonatomic, strong) CAGradientLayer *glLayer;

@end

@implementation YXNewsLiveDetailView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    UIView *glView = [[UIView alloc] init];
    self.glLayer = [[CAGradientLayer alloc] init];
    self.glLayer.startPoint = CGPointMake(0.5, 0);
    self.glLayer.endPoint = CGPointMake(0.5, 1);
    self.glLayer.locations = @[@(0), @(1.0f)];
    self.glLayer.cornerRadius = 2;
    self.glLayer.masksToBounds = YES;
    self.glLayer.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1.0].CGColor];
    [glView.layer addSublayer:self.glLayer];
    
    self.backgroundColor = UIColor.whiteColor;
    
    self.coverImageView.layer.cornerRadius = 2;
    self.coverImageView.clipsToBounds = YES;
    self.iconView.layer.cornerRadius = 9;
    self.iconView.clipsToBounds = YES;
    
    
    [self addSubview:self.coverImageView];
    [self addSubview:glView];
    [self addSubview:self.statusView];
    [self addSubview:self.iconView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.dateLabel];
    [self addSubview:self.durationLabel];
    [self addSubview:self.desLabel];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(self.coverImageView.mas_width).multipliedBy(9 / 16.0);
    }];
    
    [glView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.coverImageView);
        make.height.mas_equalTo(30);
    }];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.coverImageView.mas_bottom).offset(8);
        make.height.mas_lessThanOrEqualTo(40);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView).offset(6);
        make.width.height.mas_equalTo(18);
        make.bottom.equalTo(self.coverImageView).offset(-6);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconView);
        make.left.equalTo(self.iconView.mas_right).offset(4);
        make.right.equalTo(self);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView).offset(6);
        make.bottom.equalTo(self.coverImageView).offset(-6);
    }];
    
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.dateLabel);
        make.right.equalTo(self.coverImageView).offset(-6);
        make.bottom.equalTo(self.coverImageView).offset(-6);
    }];
    
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView).offset(6);
        make.height.mas_equalTo(16);
        make.top.equalTo(self.coverImageView).offset(6);
    }];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.glLayer.frame = CGRectMake(0, 0, self.coverImageView.mj_w, 30);
}

- (void)setLiveModel:(YXLiveModel *)liveModel {
    _liveModel = liveModel;
    
    if (liveModel.status == 1) {
        self.statusView.rightLabel.text = liveModel.timeStr;
        self.statusView.status = YXNewsLiveStatusPre;
        self.dateLabel.hidden = YES;
        self.durationLabel.hidden = YES;
        self.iconView.hidden = NO;
        self.nameLabel.hidden = NO;
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:liveModel.anchor.image_url?:@""] placeholderImage:[UIImage imageNamed:@"nav_user"]];
        self.nameLabel.text = liveModel.anchor.nick_name;
    } else if (liveModel.status == 2) {        
        self.statusView.rightLabel.text = liveModel.watchUserCountStr;
        self.statusView.status = YXNewsLiveStatusLive;
        self.dateLabel.hidden = YES;
        self.durationLabel.hidden = YES;
        self.iconView.hidden = NO;
        self.nameLabel.hidden = NO;
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:liveModel.anchor.image_url?:@""] placeholderImage:[UIImage imageNamed:@"nav_user"]];
        self.nameLabel.text = liveModel.anchor.nick_name;
    } else {
        // 回放
        self.statusView.tagStr = liveModel.tag.name;
        self.statusView.rightLabel.text = [NSString stringWithFormat:@"%@", liveModel.viewCountStr];
        self.statusView.status = YXNewsLiveStatusReplay;
        self.dateLabel.hidden = NO;
        self.durationLabel.hidden = NO;
        self.iconView.hidden = YES;
        self.nameLabel.hidden = YES;
        self.durationLabel.text = liveModel.show_urls.finalTime;
        self.dateLabel.text = liveModel.replayTimeStr;
    }
    self.desLabel.text = liveModel.title;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:liveModel.cover_images.image.lastObject] placeholderImage:[UIImage imageNamed:@"placeholder_5bi2"]];
}


- (void)setCourseModel:(YXNewCourseVideoInfoSubModel *)courseModel {
    _courseModel = courseModel;

    self.dateLabel.hidden = NO;
    self.durationLabel.hidden = NO;
    self.iconView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.durationLabel.text = courseModel.video_extra_info.finalTime;
    self.dateLabel.text = courseModel.dateStr;
    
    if (courseModel.hot_flag) {
        self.statusView.tagStr = courseModel.corner_mark;
    } else {
        self.statusView.tagStr = @"";
    }
    self.statusView.rightLabel.text = [NSString stringWithFormat:@"%@", courseModel.video_extra_info.viewCountStr];
    self.desLabel.text = courseModel.title.show;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:courseModel.picture_url.show] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
        
    
    self.statusView.status = YXNewsLiveStatusReplay;
}

- (void)resetRecommendLayout {
    
    UIView *bgView = [[UIView alloc] init];
    bgView.layer.cornerRadius = 2;
    bgView.clipsToBounds = YES;
    [self insertSubview:bgView atIndex:0];
    bgView.backgroundColor = [UIColor qmui_colorWithHexString:@"#F1F6FF"];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // 计算高度
    CGFloat leftPadding = 12;
    CGFloat margin = 9;
    CGFloat width = (YXConstant.screenWidth - leftPadding * 2 - margin) * 0.5;
        
    [self.coverImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(12);
        make.bottom.equalTo(self).offset(-14);
        make.width.mas_equalTo(width);
        make.height.equalTo(self.coverImageView.mas_width).multipliedBy(9 / 16.0);
    }];
    
    [self.desLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(8);
        make.top.equalTo(self.coverImageView);
        make.right.equalTo(self).offset(-12);
    }];
}


#pragma mark - 懒加载

- (UIImageView *)coverImageView {
    if (_coverImageView == nil) {
        _coverImageView = [[UIImageView alloc] init];
    }
    return _coverImageView;
}

- (UIImageView *)iconView {
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [UILabel labelWithText:@"--" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:12]];
    }
    return _nameLabel;
}

- (UILabel *)dateLabel {
    if (_dateLabel == nil) {
        _dateLabel = [UILabel labelWithText:@"--" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:12]];
    }
    return _dateLabel;
}

- (UILabel *)durationLabel {
    if (_durationLabel == nil) {
        _durationLabel = [UILabel labelWithText:@"--" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:12]];
    }
    return _durationLabel;
}


- (UILabel *)desLabel {
    if (_desLabel == nil) {
        _desLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14]];
        _desLabel.numberOfLines = 2;
    }
    return _desLabel;
}

- (YXNewsLiveStatusView *)statusView {
    if (_statusView == nil) {
        _statusView = [[YXNewsLiveStatusView alloc] init];
    }
    return _statusView;
}

@end
