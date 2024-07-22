//
//  ZFPorductSectionModule.h
//  ZZZZZ
//
//  Created by YW on 2019/6/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCollectionSectionProtocol.h"
#import "ZFCustomerBackgroundCRView.h"

@interface ZFPorductSectionModule : NSObject
<
    ZFCollectionSectionProtocol
>

- (CustomerBackgroundAttributes *)gainCustomeSetionBackgroundAttributes:(NSIndexPath *)indexPath;

@end

