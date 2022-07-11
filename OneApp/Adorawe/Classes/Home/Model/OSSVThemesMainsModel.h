//
//  STLThemeMainModel.h
// XStarlinkProject
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface OSSVThemesMainsModel : NSObject

@property (nonatomic, copy) NSString *specialName;
@property (nonatomic, copy) NSString *bg_color;

@property (nonatomic, strong) NSArray *mutiProtogene;
@property (nonatomic, strong) NSDictionary *pageProtogene;
@end

//
//"pageProtogene":{
//"sort":"99",
//"type":"18",
//"colour":"#FFFFFF",
//"bg_color":""
//}
