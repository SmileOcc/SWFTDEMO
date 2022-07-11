//
//  YXLivingAndAdvanceView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//


#import "YXLivingAndAdvanceView.h"
#import "NewPagedFlowView.h"
#import "PGIndexBannerSubiew.h"
#import <Lottie/Lottie.h>
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXLivingAndAdvanceStatusView: UIView

@property (nonatomic, strong) LOTAnimationView *iconView;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, assign) BOOL isLiving;
@property (nonatomic, strong) UIImageView *bgImageView;

@end

@implementation YXLivingAndAdvanceStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.bgImageView = [[UIImageView alloc] init];
    [self addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.iconView = [LOTAnimationView animationNamed:@"living"];
    self.iconView.frame = CGRectMake(0, 0, 12, 12);
    self.iconView.loopAnimation = YES;
    
    self.rightLabel = [UILabel labelWithText:@"" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:14]];
    [self addSubview:self.iconView];
    [self addSubview:self.rightLabel];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(5);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(12);
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.right.equalTo(self).offset(-4);
        make.left.equalTo(self.iconView.mas_right).offset(2);
    }];
}

- (void)setIsLiving:(BOOL)isLiving {
    _isLiving = isLiving;
    if (isLiving) {
        // 直播中
        self.rightLabel.text = [YXLanguageUtility kLangWithKey:@"news_live"];
        [self.rightLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.right.equalTo(self).offset(-4);
            make.left.equalTo(self.iconView.mas_right).offset(2);
        }];
        self.rightLabel.textAlignment = NSTextAlignmentLeft;        
        self.iconView.hidden = NO;
        self.bgImageView.image = [UIImage imageNamed:@"bg_living"];
        [self.iconView play];
    } else {
        // 预告
        self.rightLabel.text = [YXLanguageUtility kLangWithKey:@"news_preview"];        
        [self.rightLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.right.equalTo(self).offset(-4);
            make.left.equalTo(self).offset(4);
        }];
        self.rightLabel.textAlignment = NSTextAlignmentCenter;
        self.iconView.hidden = YES;
        self.bgImageView.image = [UIImage imageNamed:@"bg_advance"];
        [self.iconView stop];
    }
}


@end

@interface YXLivingAndAdvanceSubView: PGIndexBannerSubiew

@property (nonatomic, strong) YXLiveModel *liveModel;

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) QMUILabel *dateLabel;

@property (nonatomic, strong) UILabel *desLabel;

@property (nonatomic, strong) QMUILabel *tagLabel;

@property (nonatomic, strong) YXLivingAndAdvanceStatusView *statusView;

@property (nonatomic, strong) CAGradientLayer *glLayer;

@end

@implementation YXLivingAndAdvanceSubView


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
    self.glLayer.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1.0].CGColor];
    self.glLayer.frame = CGRectMake(0, 0, YXConstant.screenWidth - 56, 30);
    [glView.layer addSublayer:self.glLayer];
    
    self.coverImageView.layer.cornerRadius = 4;
    self.coverImageView.clipsToBounds = YES;
    self.iconView.layer.cornerRadius = 11;
    self.iconView.clipsToBounds = YES;
    
    self.backgroundColor = UIColor.whiteColor;

    [self addSubview:self.coverImageView];
    [self addSubview:self.statusView];
    [self.coverImageView addSubview:glView];
    [self addSubview:self.iconView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.tagLabel];
    [self addSubview:self.desLabel];
    [self addSubview:self.dateLabel];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(self.coverImageView.mas_width).multipliedBy(9 / 16.0);
        make.bottom.equalTo(self).offset(-30);
    }];
    
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(72);
    }];
    
    [glView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.coverImageView);
        make.height.mas_equalTo(30);
    }];
    
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.height.mas_equalTo(21);
        make.top.equalTo(self.coverImageView.mas_bottom).offset(9);
    }];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self);
        make.height.mas_equalTo(22);
        make.left.equalTo(self).offset(0);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView).offset(6);
        make.width.height.mas_equalTo(22);
        make.bottom.equalTo(self.coverImageView).offset(-6);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconView);
        make.left.equalTo(self.iconView.mas_right).offset(4);
        make.right.equalTo(self);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImageView).offset(6);
        make.right.equalTo(self.coverImageView).offset(-6);
        make.height.mas_equalTo(21);
    }];

}


- (void)setLiveModel:(YXLiveModel *)liveModel {
    _liveModel = liveModel;
        
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:liveModel.anchor.image_url?:@""] placeholderImage:[UIImage imageNamed:@"nav_user_WhiteSkin"]];
    self.nameLabel.text = liveModel.anchor.nick_name;
    
    self.desLabel.text = liveModel.title;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:liveModel.cover_images.image.lastObject] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    if (liveModel.status == 1) {
        // 预告
        self.statusView.isLiving = NO;
        self.dateLabel.hidden = NO;
        self.dateLabel.text = [NSString stringWithFormat:@"%@: %@", [YXLanguageUtility kLangWithKey:@"live_start_time"],  liveModel.timeStr];
        
        
    } else {
        self.statusView.isLiving = YES;
        self.dateLabel.hidden = YES;
    }
    
    if (liveModel.tag.name.length > 0) {
        self.tagLabel.hidden = NO;
        self.tagLabel.text = liveModel.tag.name;
        [self.tagLabel sizeToFit];
        [self.desLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(self.tagLabel.mj_w + 4);
        }];
    } else {
        self.tagLabel.hidden = YES;
        [self.desLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(0);
        }];
    }
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
        _nameLabel = [UILabel labelWithText:@"--" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:14]];
    }
    return _nameLabel;
}


- (UILabel *)desLabel {
    if (_desLabel == nil) {
        _desLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16]];
        _desLabel.numberOfLines = 1;
    }
    return _desLabel;
}

- (YXLivingAndAdvanceStatusView *)statusView  {
    if (_statusView == nil) {
        _statusView = [[YXLivingAndAdvanceStatusView alloc] init];
    }
    return _statusView;
}

- (QMUILabel *)dateLabel {
    if (_dateLabel == nil) {
        _dateLabel = [[QMUILabel alloc] init];
        _dateLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        _dateLabel.textColor = UIColor.whiteColor;
        _dateLabel.font = [UIFont systemFontOfSize:12];
        _dateLabel.backgroundColor = [[UIColor qmui_colorWithHexString:@"#191919"] colorWithAlphaComponent:0.5];
    }
    return _dateLabel;
}

- (QMUILabel *)tagLabel {
    if (_tagLabel == nil) {
        _tagLabel = [[QMUILabel alloc] init];
        _tagLabel.layer.borderColor = [UIColor qmui_colorWithHexString:@"#D4A980"].CGColor;
        _tagLabel.layer.borderWidth = 1.0;
        _tagLabel.textColor = [UIColor qmui_colorWithHexString:@"#D4A980"];
        _tagLabel.font = [UIFont systemFontOfSize:12];
        _tagLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        _tagLabel.layer.cornerRadius = 3;
        _tagLabel.clipsToBounds = YES;
    }
    return _tagLabel;
}

@end


@interface YXLivingAndAdvanceView ()<NewPagedFlowViewDelegate, NewPagedFlowViewDataSource>

@property (nonatomic, strong) NewPagedFlowView *pageFlowView;

@end


@implementation YXLivingAndAdvanceView


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

- (void)setLiveList:(NSArray *)liveList {
    _liveList = liveList;
    [self.pageFlowView reloadData];
}

#pragma mark - 设置UI
- (void)setUI {
    
    NewPagedFlowView *pageFlowView = [[NewPagedFlowView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, (YXConstant.screenWidth - 56) * 9 / 16 + 42)];
    pageFlowView.delegate = self;
    pageFlowView.dataSource = self;
    pageFlowView.minimumPageAlpha = 0.01;
    pageFlowView.isCarousel = YES;
    pageFlowView.orientation = NewPagedFlowViewOrientationHorizontal;
    pageFlowView.isOpenAutoScroll = YES;
    pageFlowView.autoTime = 3;
    pageFlowView.leftRightMargin = 28;
    pageFlowView.topBottomMargin = 20;
    self.pageFlowView = pageFlowView;
    [self.contentView addSubview:pageFlowView];
}



#pragma mark NewPagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(NewPagedFlowView *)flowView {
    return CGSizeMake(YXConstant.screenWidth - 56, (YXConstant.screenWidth - 56) * 9 / 16 + 42);
}

- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex {
    
//    NSLog(@"点击了第%ld张图",(long)subIndex + 1);
    if (self.clickItemCallBack) {
        self.clickItemCallBack(self.liveList[subIndex]);
    }
}

- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(NewPagedFlowView *)flowView {
    
//    NSLog(@"ViewController 滚动到了第%ld页",pageNumber);
}

#pragma mark NewPagedFlowView Datasource
- (NSInteger)numberOfPagesInFlowView:(NewPagedFlowView *)flowView {
    
    return self.liveList.count;
    
}

- (PGIndexBannerSubiew *)flowView:(NewPagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    YXLivingAndAdvanceSubView *bannerView = (YXLivingAndAdvanceSubView *)[flowView dequeueReusableCell];
    if (!bannerView) {
        bannerView = [[YXLivingAndAdvanceSubView alloc] init];
        bannerView.tag = index;
        bannerView.layer.cornerRadius = 4;
        bannerView.layer.masksToBounds = YES;
    }
    
    bannerView.liveModel = self.liveList[index];
    return bannerView;
}


@end
