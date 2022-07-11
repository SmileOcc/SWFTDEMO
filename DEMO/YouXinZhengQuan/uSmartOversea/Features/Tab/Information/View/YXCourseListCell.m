//
//  YXCourseListCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXCourseListCell.h"
#import "YXLiveDetailCell.h"
#import "YXCollectionCourseCell.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXCourseListCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *setCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *setLayout;

@property (nonatomic, strong) UICollectionView *videoCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *videoLayout;

@property (nonatomic, strong) NSMutableArray *setArr;
@property (nonatomic, strong) NSMutableArray *videoArr;

@end

@implementation YXCourseListCell


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

- (void)setList:(NSArray<YXNewCourseVideoInfoModel *> *)list {
    
    _list = list;
    
    NSMutableArray *setArr = [NSMutableArray array];
    NSMutableArray *videoArr = [NSMutableArray array];
    
    for (YXNewCourseVideoInfoModel *model in list) {
        if (model.type == 1 && model.video_info) {
            [videoArr addObject:model.video_info];
        } else if (model.type == 2 && model.set_video_info) {
            [setArr addObject:model.set_video_info];
        }
    }
    self.videoArr = videoArr;
    self.setArr = setArr;
    
    self.setCollectionView.hidden = setArr.count == 0;
    self.videoCollectionView.hidden = videoArr.count == 0;
    
    CGFloat height = 118;
    for (YXNewCourseVideoInfoSubModel *model in self.videoArr) {
        if (model.height > height) {
            height = model.height;
        }
    }
    
    [self.videoCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    self.videoLayout.itemSize = CGSizeMake(160, height);
    
    [self.setCollectionView reloadData];
    [self.videoCollectionView reloadData];
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.backgroundColor = UIColor.whiteColor;
    [self.videoCollectionView registerClass:[YXLiveDetailCell class] forCellWithReuseIdentifier:@"YXLiveDetailCell"];
    [self.setCollectionView registerClass:[YXCollectionCourseCell class] forCellWithReuseIdentifier:@"YXCollectionCourseCell"];
    
    [self.contentView addSubview:self.setCollectionView];
    [self.setCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(274);
    }];
    
    [self.contentView addSubview:self.videoCollectionView];
    [self.videoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(137);
    }];
}

#pragma mark - collectionview
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.videoCollectionView) {
        return self.videoArr.count;
    }
    return self.setArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.videoCollectionView) {
        YXLiveDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YXLiveDetailCell" forIndexPath:indexPath];
        cell.courseModel = self.videoArr[indexPath.row];
        return cell;
    } else {
        YXCollectionCourseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YXCollectionCourseCell" forIndexPath:indexPath];
        cell.courseModel = self.setArr[indexPath.row];
        
        @weakify(self);
        [cell setClickCallBack:^(NSString * _Nonnull videoId) {
            if (self.clickSetItemCallBack) {
                @strongify(self);
                self.clickSetItemCallBack(self.setArr[indexPath.item], videoId);
            }
        }];
        
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.videoCollectionView) {
        if (self.clickVideoItemCallBack) {
            self.clickVideoItemCallBack(self.videoArr[indexPath.item]);
        }
    } else {
        if (self.clickSetItemCallBack) {
            self.clickSetItemCallBack(self.setArr[indexPath.item], @"");
        }
    }
}

#pragma mark - 懒加载
- (UICollectionViewFlowLayout *)setLayout {
    if (_setLayout == nil) {
        _setLayout = [[UICollectionViewFlowLayout alloc] init];
        _setLayout.minimumLineSpacing = 10;
        _setLayout.minimumInteritemSpacing = 10;
        _setLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        _setLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _setLayout.itemSize = CGSizeMake(220, 226);
    }
    return _setLayout;
}

- (UICollectionView *)setCollectionView {
    if (_setCollectionView == nil) {
        _setCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.setLayout];
        _setCollectionView.delegate = self;
        _setCollectionView.dataSource = self;
        _setCollectionView.showsHorizontalScrollIndicator = NO;
        _setCollectionView.backgroundColor = [UIColor qmui_colorWithHexString:@"#EFF5FF"];
    }
    return _setCollectionView;
}


- (UICollectionViewFlowLayout *)videoLayout {
    if (_videoLayout == nil) {
        _videoLayout = [[UICollectionViewFlowLayout alloc] init];
        _videoLayout.minimumLineSpacing = 10;
        _videoLayout.minimumInteritemSpacing = 10;
        _videoLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        _videoLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _videoLayout.itemSize = CGSizeMake(160, 137);
    }
    return _videoLayout;
}

- (UICollectionView *)videoCollectionView {
    if (_videoCollectionView == nil) {
        _videoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.videoLayout];
        _videoCollectionView.delegate = self;
        _videoCollectionView.dataSource = self;
        _videoCollectionView.showsHorizontalScrollIndicator = NO;
        _videoCollectionView.backgroundColor = UIColor.whiteColor;
    }
    return _videoCollectionView;
}


@end
