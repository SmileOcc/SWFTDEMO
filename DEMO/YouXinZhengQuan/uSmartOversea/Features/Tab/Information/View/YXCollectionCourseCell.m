//
//  YXCollectionViewCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXCollectionCourseCell.h"
#import "YXNewCourseModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXCollectionCourseCell()

@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, strong) UIButton *firstBtn;
@property (nonatomic, strong) UIButton *secondBtn;

@property (nonatomic, strong) QMUIButton *seeMoreBtn;

@end

@implementation YXCollectionCourseCell


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
    self.backgroundColor = UIColor.whiteColor;
    
    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.firstBtn];
    [self.contentView addSubview:self.secondBtn];
    [self.contentView addSubview:self.seeMoreBtn];
    
    self.layer.cornerRadius = 4;
    self.clipsToBounds = YES;
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(124);
    }];
    
    [self.firstBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImageView.mas_bottom).offset(10);
        make.left.equalTo(self).offset(8);
        make.right.equalTo(self).offset(-8);
        make.height.mas_equalTo(20);
    }];
    
    [self.secondBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.firstBtn.mas_bottom).offset(10);
        make.left.equalTo(self).offset(8);
        make.right.equalTo(self).offset(-8);
        make.height.mas_equalTo(20);
    }];
    
    [self.seeMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-10);
        make.left.equalTo(self).offset(8);
        make.height.mas_equalTo(20);
    }];
}

- (void)setCourseModel:(YXNewCourseSetVideoInfoSubModel *)courseModel {
    _courseModel = courseModel;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:courseModel.picture_url.show] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    if (courseModel.video_list.count > 0) {
        YXNewCourseVideoInfoSubModel *firstModel = courseModel.video_list.firstObject;
        self.firstBtn.hidden = NO;
        [self.firstBtn setTitle:[NSString stringWithFormat:@"1、%@", firstModel.title.show] forState:UIControlStateNormal];
        if (courseModel.video_list.count > 1) {
            YXNewCourseVideoInfoSubModel *model = courseModel.video_list[1];
            self.secondBtn.hidden = NO;
            [self.secondBtn setTitle:[NSString stringWithFormat:@"2、%@", model.title.show] forState:UIControlStateNormal];
        } else {
            self.secondBtn.hidden = YES;
        }
    } else {
        self.firstBtn.hidden = YES;
        self.secondBtn.hidden = YES;
    }
}

- (void)btnClick:(UIButton *)sender {
    if (self.clickCallBack) {
        if (sender == self.firstBtn) {
            self.clickCallBack(self.courseModel.video_list[0].video_id);
        } else if (sender == self.secondBtn) {
            self.clickCallBack(self.courseModel.video_list[1].video_id);
        } else {
            self.clickCallBack(@"");
        }        
    }
}

#pragma mark - 懒加载

- (UIImageView *)coverImageView {
    if (_coverImageView == nil) {
        _coverImageView = [[UIImageView alloc] init];
    }
    return _coverImageView;
}

- (UIButton *)firstBtn {
    if (_firstBtn == nil) {
        _firstBtn = [UIButton buttonWithType:UIButtonTypeCustom title:@"" font:[UIFont systemFontOfSize:14] titleColor:[UIColor qmui_colorWithHexString:@"#191919"] target:self action:@selector(btnClick:)];
        _firstBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _firstBtn;
}

- (UIButton *)secondBtn {
    if (_secondBtn == nil) {
        _secondBtn = [UIButton buttonWithType:UIButtonTypeCustom title:@"" font:[UIFont systemFontOfSize:14] titleColor:[UIColor qmui_colorWithHexString:@"#191919"] target:self action:@selector(btnClick:)];
        _secondBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _secondBtn;
}

- (QMUIButton *)seeMoreBtn {
    if (_seeMoreBtn == nil) {
        
        _seeMoreBtn = [QMUIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"newStock_detail_see_more"] font:[UIFont systemFontOfSize:12] titleColor:[[UIColor qmui_colorWithHexString:@"#191919"] colorWithAlphaComponent:0.45] target:self action:@selector(btnClick:)];
        [_seeMoreBtn setImage:[UIImage imageNamed:@"icons_news_more"] forState:UIControlStateNormal];
        [_seeMoreBtn setImagePosition:QMUIButtonImagePositionRight];
        _seeMoreBtn.spacingBetweenImageAndTitle = 2;
    }
    return _seeMoreBtn;
}

@end
