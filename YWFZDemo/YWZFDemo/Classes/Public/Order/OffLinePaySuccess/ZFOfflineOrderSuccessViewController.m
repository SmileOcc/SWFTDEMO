//
//  ZFOfflineOrderSuccessViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOfflineOrderSuccessViewController.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"

#import "ZFOfflineOrderInfoCCell.h"
#import "ZFOfflineOrderQRCodeCCell.h"
#import "ZFOfflineOrderMethodCCell.h"

#import "ZFWebViewViewController.h"

#import <Masonry/Masonry.h>

@interface ZFOfflineOrderSuccessViewController ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    ZFOfflineOrderMethodCCellDelegate
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSourceList;

@end

@implementation ZFOfflineOrderSuccessViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //去掉返回按钮
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.backBarButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = ZFLocalizedString(@"paySuccess_title", nil);
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identi = self.dataSourceList[indexPath.row];
    id<ZFCollectionViewCellProtocol>cell = [collectionView dequeueReusableCellWithReuseIdentifier:identi forIndexPath:indexPath];
    cell.model = self.orderResultModel;
    cell.delegate = self;
    return (UICollectionViewCell *)cell;
}

#pragma mark - cell delegate

- (void)ZFOfflineOrderMethodCCellDidClickCheckOrderButton
{
    if (self.checkOrderHandler) {
        self.checkOrderHandler();
    }
}

- (void)ZFOfflineOrderMethodCCellDidClickCheckCode
{
    ZFWebViewViewController *paymentVC = [[ZFWebViewViewController alloc] init];
    paymentVC.link_url = self.orderResultModel.ebanxUrl;
    [self.navigationController pushViewController:paymentVC animated:YES];
}

#pragma mark - Property Method

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            //设置自动适配CollectionCell Size
            layout.estimatedItemSize = CGSizeMake(KScreenWidth, 50);
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.backgroundColor = [UIColor whiteColor];
            collectionView.delegate = self;
            collectionView.dataSource = self;
            
            [collectionView registerClass:[ZFOfflineOrderInfoCCell class] forCellWithReuseIdentifier:@"ZFOfflineOrderInfoCCell"];
            [collectionView registerClass:[ZFOfflineOrderQRCodeCCell class] forCellWithReuseIdentifier:@"ZFOfflineOrderQRCodeCCell"];
            [collectionView registerClass:[ZFOfflineOrderMethodCCell class] forCellWithReuseIdentifier:@"ZFOfflineOrderMethodCCell"];
            
            collectionView;
        });
    }
    return _collectionView;
}

-(NSMutableArray *)dataSourceList
{
    if (!_dataSourceList) {
        _dataSourceList = [[NSMutableArray alloc] init];
        
        //添加数据源
        [_dataSourceList addObject:@"ZFOfflineOrderInfoCCell"];
        [_dataSourceList addObject:@"ZFOfflineOrderQRCodeCCell"];
        [_dataSourceList addObject:@"ZFOfflineOrderMethodCCell"];
    }
    return _dataSourceList;
}

@end
