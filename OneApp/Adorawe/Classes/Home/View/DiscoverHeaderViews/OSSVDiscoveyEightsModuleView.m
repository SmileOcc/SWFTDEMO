//
//  STLDiscoveryEightModuleView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscoveyEightsModuleView.h"
#import "OSSVPuresImgCCell.h"

@interface OSSVDiscoveyEightsModuleView ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
@property (nonatomic, strong) YYAnimatedImageView *topImageView;
@property (nonatomic, strong) YYAnimatedImageView *bottomImageView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger pageIndex;
@end

@implementation OSSVDiscoveyEightsModuleView
@synthesize modelArray = _modelArray;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.topImageView];
        [self addSubview:self.collectionView];
        [self addSubview:self.bottomImageView];
        
        [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(@0);
            make.height.mas_equalTo(45 * DSCREEN_WIDTH_SCALE);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.topImageView.mas_bottom).mas_offset(0);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_offset(EightModuleContentHeight);
        }];
    }
    return self;
}

#pragma mark - datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.tempModelArray count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVPuresImgCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellEight" forIndexPath:indexPath];
    OSSVAdvsEventsModel *model = self.tempModelArray[indexPath.row];
    cell.imageUrl = [NSURL URLWithString:model.imageURL];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapModuleViewActionWithModel:moduleType:position:)]) {
        [self.delegate tapModuleViewActionWithModel:self.tempModelArray[indexPath.row] moduleType:[self gainModule] position:indexPath.row];
    }
}

#pragma mark - target

- (void)didTapModuleViewAction :(UIGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapModuleViewActionWithModel: moduleType:position:)]) {
        [self.delegate tapModuleViewActionWithModel:self.modelArray[index] moduleType:[self gainModule] position:index];
    }
}

-(void)didTapBottomButtonAction:(UIButton *)sender
{
    if ([self gainModule] == SixteenModuleType) {
        if (self.pageIndex == 0) {
            self.pageIndex = 1;
            self.tempModelArray = [self.modelArray subarrayWithRange:NSMakeRange(9, 8)];
        }else{
            self.pageIndex = 0;
            self.tempModelArray = [self.modelArray subarrayWithRange:NSMakeRange(1, 8)];
        }
        [self.collectionView reloadData];
    }
}

#pragma mark - private method

-(ModuleViewType)gainModule
{
    ModuleViewType type = EightModuleType;
    if ([self.modelArray count] > 16) {
        type = SixteenModuleType;
    }
    return type;
}

#pragma mark - setter and getter

-(void)setModelArray:(NSArray<OSSVAdvsEventsModel *> *)modelArray
{
    ///当modelAryy的数据源不等于9 或者不等于18 都不会进入到这里
    _modelArray = modelArray;
    if (![modelArray count]) {return;}
    if (modelArray.count > 16) {
        self.bottomImageView.hidden = NO;
        [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@0);
            make.top.equalTo(self.collectionView.mas_bottom);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(45 * DSCREEN_WIDTH_SCALE);
        }];
        //十六分馆的时候，第一条数据是顶部的数据
        OSSVAdvsEventsModel *model = modelArray[0];
        [self.topImageView yy_setImageWithURL:[NSURL URLWithString:model.imageURL]
                                  placeholder:nil
                                      options:kNilOptions
                                   completion:nil];
        self.topImageView.tag = 0;
        //十六分馆的时候，最后一条数据是底部的数据
        OSSVAdvsEventsModel *lastModel = [modelArray lastObject];
        [self.bottomImageView yy_setImageWithURL:[NSURL URLWithString:lastModel.imageURL]
                                     placeholder:nil
                                         options:kNilOptions
                                      completion:nil];
        //去掉首尾的数据，取8条数据
        NSArray *dataSourceArray = [modelArray subarrayWithRange:NSMakeRange(1, 8)];
        self.tempModelArray = dataSourceArray;
    }else{
        self.bottomImageView.hidden = YES;
        [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@0);
            make.top.equalTo(self.collectionView.mas_bottom);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(0);
        }];
        //八分馆的时候，第一条数据是顶部的数据
        OSSVAdvsEventsModel *model = modelArray[0];
        [self.topImageView yy_setImageWithURL:[NSURL URLWithString:model.imageURL]
                                  placeholder:nil
                                      options:kNilOptions
                                   completion:nil];
        self.topImageView.tag = 0;
        //去掉首的数据
        NSArray *dataSourceArray = [modelArray subarrayWithRange:NSMakeRange(1, modelArray.count - 1)];
        self.tempModelArray = dataSourceArray;
    }
    
    [self.collectionView reloadData];
}

- (YYAnimatedImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[YYAnimatedImageView alloc] init];
        _topImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapModuleViewAction:)];
        [_topImageView addGestureRecognizer:tap];
    }
    return _topImageView;
}

- (YYAnimatedImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView = [[YYAnimatedImageView alloc] init];
        _bottomImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBottomButtonAction:)];
        [_bottomImageView addGestureRecognizer:tap];
    }
    return _bottomImageView;
}

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
            CGFloat scale = floor(EightCellWidth * EightCellScale);
            layout.itemSize = CGSizeMake(EightCellWidth, scale);
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.showsVerticalScrollIndicator = YES;
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.backgroundColor = OSSVThemesColors.col_F6F6F6;
            collectionView.scrollEnabled = NO;
            [collectionView registerClass:[OSSVPuresImgCCell class] forCellWithReuseIdentifier:@"CellEight"];
            
            collectionView;
        });
    }
    return _collectionView;
}

@end
