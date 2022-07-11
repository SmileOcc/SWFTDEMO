//
//  OSSVDetailFastAddCCell.m
// XStarlinkProject
//
//  Created by fan wang on 2021/6/21.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailFastAddCCell.h"
#import "UIButton+STLCategory.h"

@interface OSSVDetailFastAddCCell ()
@property (weak,nonatomic) UIButton *addToBagButton;
@end

@implementation OSSVDetailFastAddCCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIButton *collectButton = [self valueForKey:@"collectButton"];
        collectButton.hidden = YES;
        UIButton *addToBagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addToBagBtn setImage:[UIImage imageNamed:@"cart_bag"] forState:UIControlStateNormal];
        _addToBagButton = addToBagBtn;
        _addToBagButton.sensor_element_id = @"add_to_cart";
        [self.contentView addSubview:addToBagBtn];
        [addToBagBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentImageView.mas_trailing).offset(-6);
            make.top.mas_equalTo(self.contentImageView.mas_bottom).offset(6);
        }];
        [_addToBagButton setEnlargeEdgeWithTop:8 right:6 bottom:8 left:8];

        [addToBagBtn addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)addToCart{
    if (self.addToCartDelegate) {
        NSDictionary *item = nil;
        if (self.model) {
            item = @{
                @"goodsId": STLToString(self.model.goodsId),
                @"wid": STLToString(self.model.wid),
                @"model":self.model,
            };
        }
        [self.addToCartDelegate fastAddItemCell:self addToCart:item];
    }
}

@end
