//
//  HCTest.m
//  URLDEMO
//
//  Created by odd on 7/13/22.
//

#import "HCTest.h"

@implementation HCTest

@end


UIColor* STLRandomColor(void)
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
