//
//  YXVideoListCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXVideoListCell.h"
#import "YXLiveDetailCell.h"
#import "YXLiveModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXVideoListCell()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation YXVideoListCell


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
    
    [self.collectionView registerClass:[YXLiveDetailCell class] forCellWithReuseIdentifier:@"YXLiveDetailCell"];
    
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.contentView);
    }];
}

- (void)setReplayList:(NSArray<YXLiveModel *> *)replayList {
    _replayList = replayList;
    
    self.layout.itemSize = CGSizeMake(160, self.mj_h);
    [self.collectionView reloadData];
}

#pragma mark - collectionview
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.replayList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        
    YXLiveDetailCell *cell = nil;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YXLiveDetailCell" forIndexPath:indexPath];
    YXLiveModel *model = self.replayList[indexPath.item];
    model.status = 4;
    cell.liveModel = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.clickItemCallBack) {
        self.clickItemCallBack(self.replayList[indexPath.item]);
    }
}


#pragma mark - 懒加载
- (UICollectionViewFlowLayout *)layout {
    if (_layout == nil) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = 10;
        _layout.minimumInteritemSpacing = 10;
        _layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize = CGSizeMake(160, 117);
    }
    return _layout;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = UIColor.whiteColor;
    }
    return _collectionView;
}


@end
