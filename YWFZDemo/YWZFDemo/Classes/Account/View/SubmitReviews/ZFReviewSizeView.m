//
//  ZFReviewSizeView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFReviewSizeView.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import <Masonry/Masonry.h>

#define cellHeight 14

@interface ZFReviewSizeCCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation ZFReviewSizeCCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.contentLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.top.mas_equalTo(self);
            make.height.mas_offset(frame.size.height);
            make.width.priorityLow();
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_trailing);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.top.mas_equalTo(self);
        }];
    }
    return self;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _titleLabel;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _contentLabel;
}

@end

@interface ZFReviewSizeView ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ZFReviewSizeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.collectionView];
    self.collectionView.frame = CGRectMake(0, 0, KScreenWidth, (2 * cellHeight) + 4);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFReviewSizeCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFReviewSizeCCell" forIndexPath:indexPath];
    cell.titleLabel.text = [self titleList][indexPath.row];
    NSString *content = [self contentList][indexPath.row];
    if (ZFToString(content).length) {
        cell.contentLabel.text = content;
    } else {
        cell.contentLabel.text = @"-";
    }
    return cell;
}

- (NSArray *)titleList
{
    return @[
             [NSString stringWithFormat:@"%@ : ", ZFLocalizedString(@"Reviews_Height", nil)],
             [NSString stringWithFormat:@"%@ : ", ZFLocalizedString(@"Reviews_Waist", nil)],
             [NSString stringWithFormat:@"%@ : ", ZFLocalizedString(@"Reviews_Hips", nil)],
             [NSString stringWithFormat:@"%@ : ", ZFLocalizedString(@"Reviews_BustSize", nil)],
             ];
}

-(void)setContentList:(NSArray *)contentList
{
    _contentList = contentList;
    
    [self.collectionView reloadData];
}

#pragma mark - Property Method

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.itemSize = CGSizeMake(floor(KScreenWidth / 2), cellHeight);
            layout.minimumLineSpacing = 4;
            layout.minimumInteritemSpacing = 0;
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.backgroundColor = [UIColor whiteColor];
            collectionView.delegate = self;
            collectionView.dataSource = self;
            collectionView.showsVerticalScrollIndicator = YES;
            collectionView.showsHorizontalScrollIndicator = NO;
            collectionView.directionalLockEnabled = YES;
            collectionView.scrollEnabled = NO;
            [collectionView registerClass:[ZFReviewSizeCCell class] forCellWithReuseIdentifier:@"ZFReviewSizeCCell"];
            collectionView;
        });
    }
    return _collectionView;
}

@end
