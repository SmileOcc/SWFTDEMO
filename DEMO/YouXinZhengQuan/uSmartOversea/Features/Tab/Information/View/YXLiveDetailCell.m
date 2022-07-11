//
//  YXLiveDetailCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveDetailCell.h"
#import "YXNewsLiveSectionView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXLiveDetailCell ()

@property (nonatomic, strong) YXNewsLiveDetailView *detailView;

@end

@implementation YXLiveDetailCell


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
    
    [self.contentView addSubview:self.detailView];
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setLiveModel:(YXLiveModel *)liveModel {
    _liveModel = liveModel;
    self.detailView.liveModel = liveModel;
}

- (void)setCourseModel:(YXNewCourseVideoInfoSubModel *)courseModel {
    _courseModel = courseModel;
    self.detailView.courseModel = courseModel;
}

#pragma mark - 懒加载
- (YXNewsLiveDetailView *)detailView {
    if (_detailView == nil) {
        _detailView = [[YXNewsLiveDetailView alloc] init];
    }
    return _detailView;
}

@end

#pragma mark - 推荐的cell
@interface YXLiveRecommendDetailCell ()

@property (nonatomic, strong) YXNewsLiveDetailView *detailView;

@end

@implementation YXLiveRecommendDetailCell


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
    
    [self.contentView addSubview:self.detailView];
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.detailView resetRecommendLayout];
}

- (void)setCourseModel:(YXNewCourseVideoInfoSubModel *)courseModel {
    _courseModel = courseModel;
    self.detailView.courseModel = courseModel;
}

#pragma mark - 懒加载
- (YXNewsLiveDetailView *)detailView {
    if (_detailView == nil) {
        _detailView = [[YXNewsLiveDetailView alloc] init];
    }
    return _detailView;
}
@end
