//
//  ZFSubmitOverallFitView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSubmitOverallFitView.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "ZFThemeManager.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "UIImage+ZFExtended.h"

#pragma mark - ZFSubmitOverallFitViewCell

@interface ZFSubmitOverallFitCCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *selectButton;

@end

@implementation ZFSubmitOverallFitCCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.selectButton];
    }
    return self;
}

#pragma mark - Property Method

-(UIButton *)selectButton
{
    if (!_selectButton) {
        _selectButton = ({
            UIButton *button = [[UIButton alloc] initWithFrame:self.bounds];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.userInteractionEnabled = NO;
            [button setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"address_unchoose"] forState:UIControlStateNormal];
            [button setImage:[[UIImage imageNamed:@"address_choose"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
            button;
        });
    }
    return _selectButton;
}

@end

#pragma mark - ZFSubmitOverallFitView

@interface ZFSubmitOverallFitView ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@end

@implementation ZFSubmitOverallFitView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.collectionView];
}

#pragma mark - datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFSubmitOverallFitCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFSubmitOverallFitCCell" forIndexPath:indexPath];
    [cell.selectButton setTitle:[self titleList][indexPath.row] forState:UIControlStateNormal];
    if (self.currentIndexPath.row == indexPath.row) {
        cell.selectButton.selected = YES;
    } else {
        cell.selectButton.selected = NO;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndexPath = indexPath;
    [collectionView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFSubmitOverallFitViewDidClick:content:)]) {
        NSString *content = [self titleList][indexPath.row];
        NSInteger index = 0;
        if (indexPath.row == 0) {
            index = 2;
        } else if (indexPath.row == 1) {
            index = 0;
        } else if (indexPath.row == 2) {
            index = 1;
        }
        [self.delegate ZFSubmitOverallFitViewDidClick:index content:content];
    }
}

- (NSArray *)titleList
{
    return @[
             ZFLocalizedString(@"OverallFit_Small", nil),      //2
             ZFLocalizedString(@"OverallFit_TrueToSize", nil),   //0
             ZFLocalizedString(@"OverallFit_Large", nil),      //1
             ];
}

#pragma mark - Property

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.itemSize = CGSizeMake(floor(KScreenWidth / 3), 36);
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
            UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 36) collectionViewLayout:layout];
            view.backgroundColor = [UIColor whiteColor];
            view.delegate = self;
            view.dataSource = self;
            view.showsVerticalScrollIndicator = NO;
            view.showsHorizontalScrollIndicator = NO;
            [view registerClass:[ZFSubmitOverallFitCCell class] forCellWithReuseIdentifier:@"ZFSubmitOverallFitCCell"];
            view;
        });
    }
    return _collectionView;
}

@end
