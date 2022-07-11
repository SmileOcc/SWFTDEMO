//
//  OSSVSwitchCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSwitchCellModel.h"


@implementation OSSVSwitchCellModel
@synthesize indexPath = _indexPath;
@synthesize showSeparatorStyle = _showSeparatorStyle;

- (instancetype)init{
    self = [super init];
    if (self) {
        self.depenDentModelList = [[NSMutableArray alloc] init];
        self.cellType = SwitchCellTypeNormal;
        self.depenType = TotalDetailTypeNoromal;
        self.showSeparatorStyle = NO;
        self.valueContent = @"";
    }
    return self;
}

#pragma mark - protocol

+(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

-(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}
- (void)setCheckModel:(OSSVCartCheckModel *)checkModel {
    _checkModel = checkModel;
}

#pragma mark - setter and getter

-(void)setDataSourceModel:(NSObject *)dataSourceModel{
    _dataSourceModel = dataSourceModel;
    
    //这里的显示，在对应cell特殊处理了一下
    if ([_dataSourceModel isKindOfClass:[OSSVPointsModel class]]) {
        
        OSSVPointsModel *point = (OSSVPointsModel *)_dataSourceModel;
        point.points = point.points == nil ? @"0" : point.points;
        point.save = point.save == nil ? @"0" : point.save;
        
        ///商品价格调整  后台功能暂时没有，还是APP换算
        NSString *showSave = [ExchangeManager changeRateModel:self.rateModel transforPrice:point.save priceType:PriceType_Point];
        NSString *pointsLocali = STLLocalizedString_(@"pointsSave", nil);
        self.titleContent = [NSString stringWithFormat:@"%@ %@ %@%@", point.points, pointsLocali, self.rateModel.symbol, showSave];
        
        self.depenType = TotalDetailTypeYpoint;
        self.cellType = SwitchCellTypeNormal;
        
    }else if ([_dataSourceModel isKindOfClass:[OSSVCartCheckModel class]]){
        
        OSSVCartCheckModel *checkModel = (OSSVCartCheckModel *)_dataSourceModel;
        NSString *shippingLocali = STLLocalizedString_(@"shipInsurance", nil);
        
        ///商品价格调整  后台功能暂时没有，还是APP换算
//        NSString *showInsurance = [ExchangeManager changeRateModel:self.rateModel transforPrice:checkModel.insurance priceType:PriceType_Insurance];
//        self.titleContent = [NSString stringWithFormat:@"%@ +%@%@",shippingLocali, self.rateModel.symbol, showInsurance];
        
        //接入V站，不需要汇率换算
        self.titleContent = [NSString stringWithFormat:@"%@: %@",shippingLocali, STLToString(checkModel.fee_data.shipping_insurance_converted_origin)];

        self.depenType = TotalDetailTypeShippingInsurance;
        self.cellType = SwitchCellTypeExplain;
        
    }
}

@end
