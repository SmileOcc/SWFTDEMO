//
//  UIColor+Extension.swift
//  MADBase
//
//  Created by MountainZhu on 2020/6/11.
//  Copyright © 2020 md. All rights reserved.
//

//使用说明
//使用UIColor.name()
//

import Foundation
import UIKit

public extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a)
    }
  
    convenience init(hex: Int) {
        self.init(r: (hex & 0xff0000) >> 16, g: (hex & 0xff00) >> 8, b: (hex & 0xff), a: 1)
    }
    
    convenience init(hex: Int, alpha: CGFloat) {
        self.init(r: (hex & 0xff0000) >> 16, g: (hex & 0xff00) >> 8, b: (hex & 0xff), a: alpha)
    }
    /// 背景灰色
    static func BackgroundColor() -> UIColor {
        return UIColor(r: 255, g: 255, b: 255, a: 1)
    }

    /// 红色
    static func RedColor() -> UIColor {
        return UIColor(r: 245, g: 80, b: 83, a: 1.0)
    }
    
    ///
    static func TintColor() -> UIColor {
        return UIColor(hex: 0x3b5998)
        
    }
    
    /// 阴影
    static func VisualColor() -> UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 102.0 / 255)
    }
    
    /// TextField background Color
    static func TextFieldBKColor() -> UIColor {
        return UIColor(hex: 0xf1f2f7)
    }
    
    /// Blue Text  Color
    static func BlueTextColor() -> UIColor {
        return HDConst.ColorManager("WC_BlueBG_Color")
    }
    
    /// Green Text  Color
    static func GreenTextColor() -> UIColor {
        return HDConst.ColorManager("WC_GreenBG_Color")
    }
    
    /// Yellow Text  Color
    static func YellowTextColor() -> UIColor {
        return HDConst.ColorManager("WC_YellowBG_Color")
    }
    
    /// 早班 Text  Color
    static func ZaoBanTextColor() -> UIColor {
        return HDConst.ColorManager("WC_ZaoBanBG_Color")
    }
    
    /// 晚班 Text  Color
    static func WanBanTextColor() -> UIColor {
        return HDConst.ColorManager("WC_WanBanBG_Color")
    }
    
    /// disable Color
    static func DisableColor() -> UIColor {
        return HDConst.ColorManager("WC_Disable_Button")
    }
    
    //TODO: Tabbar
    static func TabbarTitleNormal() -> UIColor {
        return HDConst.ColorManager("WC_Tabbar_Title_Normal");
    }
    
    static func TabbarTitleSelect() -> UIColor {
        return HDConst.ColorManager("WC_Tabbar_Title_Select");
    }
    
    //TODO: Base
    //所有试图的灰色底图
    static func AllBaseViewBg() -> UIColor {
        return HDConst.ColorManager("VC_Main_Bg_Color");
    }
    
    //亮色背景下是白色，暗色背景下是黑色
    static func WhiteToBlack() -> UIColor {
        return HDConst.ColorManager("VC_White_To_Black");
    }
    
    //亮色背景下字体是黑色的
    static func BlackTitle() -> UIColor {
        return HDConst.ColorManager("WC_Title_Black");
    }
    
    //亮色背景下字体是灰色666666的
    static func GrayTitle() -> UIColor {
        return HDConst.ColorManager("WC_Title_DarkLightGray");
    }
    
    //亮色背景下字体是浅灰色999999的
    static func LightGrayTitle() -> UIColor {
        return HDConst.ColorManager("WC_Title_LightGray");
    }
    
    //亮色背景下字体是浅灰色BBBBBB的
    static func PlaceholderGrayTitle() -> UIColor {
        return HDConst.ColorManager("WC_Title_PlaceholderGray");
    }
    
    //亮色背景下字体是深灰色333333的
    static func DarkGrayTitle() -> UIColor {
        return HDConst.ColorManager("WC_Title_DarkGray");
    }
    //线条颜色
    static func lineColor() -> UIColor {
        return HDConst.ColorManager("WC_Line_Bg").withAlphaComponent(0.25);
    }
    
    //TODO: WorkStations
    //首页消息背景
    static func WorkStationMessageBg() -> UIColor {
        return HDConst.ColorManager("WC_Main_Message_Bg");
    }
    //首页消息背景
    static func WorkStationMessageLineBg() -> UIColor {
        return HDConst.ColorManager("WC_Main_Message_Line_Bg");
    }
    
    //首页头部4个文字字体
    static func WorkStationHeaderTitleOne() -> UIColor {
        return HDConst.ColorManager("WC_Main_Header_Title1");
    }
    static func WorkStationHeaderTitleTwo() -> UIColor {
        return HDConst.ColorManager("WC_Main_Header_Title2");
    }
    static func WorkStationHeaderTitleThree() -> UIColor {
        return HDConst.ColorManager("WC_Main_Header_Title3");
    }
    static func WorkStationHeaderTitleFour() -> UIColor {
        return HDConst.ColorManager("WC_Main_Header_Title4");
    }
    
    //首页搜索框取消字体 蓝色
    static func WorkStationSearchTitleBlue() -> UIColor {
        return HDConst.ColorManager("WC_Search_Cancel_Title");
    }
    
    //TODO: Application
    //红色字体
    static func ApplicationTitleRed() -> UIColor {
        return HDConst.ColorManager("WC_Application_Red");
    }
    
    //语音播报背景
    static func ApplicationAudioBg() -> UIColor {
        return HDConst.ColorManager("WC_Application_Audio_BG");
    }
    
    //TODO: Person
    //头像下在岗背景颜色 蓝色
    static func PersonHeaderWorkTitleBlue() -> UIColor {
        return HDConst.ColorManager("WC_Person_Header_Work");
    }
}
