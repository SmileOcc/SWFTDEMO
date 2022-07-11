//
//  OSSVCheckOutAdressCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCheckOutAdressCellModel.h"
#import "Adorawe-Swift.h"

@interface OSSVCheckOutAdressCellModel ()

@property (nonatomic, copy, readwrite) NSString *personInfo;
@property (nonatomic, copy, readwrite) NSString *addressInfo;

@end

@implementation OSSVCheckOutAdressCellModel
@synthesize indexPath = _indexPath;
@synthesize showSeparatorStyle = _showSeparatorStyle;

-(instancetype)init {
    self = [super init];
    
    if (self) {
        self.showSeparatorStyle = NO;
    }
    return self;
}

+(NSString *)cellIdentifier {
    return NSStringFromClass(self.class);
}

-(NSString *)cellIdentifier {
    return NSStringFromClass(self.class);
}

-(void)setAddressModel:(OSSVAddresseBookeModel *)addressModel {
    _addressModel = addressModel;
    
    self.personInfo = [NSString stringWithFormat:@"%@ %@", STLToString(addressModel.firstName), STLToString(addressModel.lastName)];
    self.phoneStr = [NSString stringWithFormat:@"%@ %@", STLToString(addressModel.phoneHead), STLToString(addressModel.phone)];
    
    self.addressInfo = [NSString addressStringWithAddres:addressModel];
}

@end
