//
//  OCTools.h
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/18.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface OCTools : NSObject
//加密成百度坐标
+(CLLocationCoordinate2D)bd09Encrypt:(double)ggLat bdLon:(double)ggLon;
//百度坐标转成高德坐标
+ (CLLocationCoordinate2D)bd09Decrypt:(double)bdLat bdLon:(double)bdLon;

@end
