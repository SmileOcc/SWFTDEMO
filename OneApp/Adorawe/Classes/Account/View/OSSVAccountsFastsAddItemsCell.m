//
//  OSSVAccountsFastsAddItemsCell.m
// XStarlinkProject
//
//  Created by fan wang on 2021/6/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVAccountsFastsAddItemsCell.h"
#import "CommendModel.h"
#import "OSSVHomeGoodsListModel.h"
#import "UIButton+STLCategory.h"

@interface OSSVAccountsFastsAddItemsCell ()

@property (strong,nonatomic) UIButton *addToBagButton;

@end

@implementation OSSVAccountsFastsAddItemsCell
+ (OSSVAccountsFastsAddItemsCell *)fastAddItemCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [collectionView registerClass:[OSSVAccountsFastsAddItemsCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVAccountsFastsAddItemsCell.class)];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVAccountsFastsAddItemsCell.class) forIndexPath:indexPath];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.collecBtn.alpha = 0;
        UIButton *addToBagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addToBagBtn setImage:[UIImage imageNamed:@"cart_bag"] forState:UIControlStateNormal];
        _addToBagButton = addToBagBtn;
        _addToBagButton.sensor_element_id = @"add_to_cart";
        [self.contentView addSubview:addToBagBtn];
        [addToBagBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-6);
            make.top.mas_equalTo(self.contentImageView.mas_bottom).offset(6);
        }];
        
        [self.addToBagButton setEnlargeEdgeWithTop:8 right:6 bottom:8 left:8];
        
        [addToBagBtn addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)addToCart{
    if (self.addToCartDelegate) {
        NSDictionary *item = nil;
        if (self.commendModel) {
            item = @{
                @"goodsId": STLToString(self.commendModel.goodsId),
                @"wid": STLToString(self.commendModel.wid),
                @"goodsTitle" : STLToString(self.commendModel.goodsTitle)
            };
        }
        else if (self.model) {
            item = @{
                @"goodsId": STLToString(self.model.goodsId),
                @"wid": STLToString(self.model.wid),
                @"goodsTitle" : STLToString(self.commendModel.goodsTitle)

            };
        }
        [self.addToCartDelegate fastAddItemCell:self addToCart:item];
    }
}

@end
