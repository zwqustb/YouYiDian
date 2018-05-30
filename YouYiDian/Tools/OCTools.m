//
//  OCTools.m
//  YouYiDian
//
//  Created by zhangwenqiang on 2017/12/18.
//  Copyright © 2017年 zhangwenqiang. All rights reserved.
//

#import "OCTools.h"
#import "JZLocationConverter.h"
@implementation OCTools
//高德(国家火星)坐标转成百度坐标
+(CLLocationCoordinate2D)bd09Encrypt:(double)ggLat bdLon:(double)ggLon
{
//    CLLocationCoordinate2D bdPt;
//    double x = ggLon, y = ggLat;
//    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
//    double theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
//    bdPt.longitude = z * cos(theta) + 0.0065;
//    bdPt.latitude = z * sin(theta) + 0.006;
//    return bdPt;
    CLLocationCoordinate2D ggPt = CLLocationCoordinate2DMake(ggLat, ggLon);
    return [JZLocationConverter gcj02ToBd09:ggPt];
}
//百度坐标转成高德坐标
+ (CLLocationCoordinate2D)bd09Decrypt:(double)bdLat bdLon:(double)bdLon
{
//    CLLocationCoordinate2D gcjPt;
//    double x = bdLon - 0.0065, y = bdLat - 0.006;
//    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
//    double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
//    gcjPt.longitude = z * cos(theta);
//    gcjPt.latitude = z * sin(theta);
//    return gcjPt;
    CLLocationCoordinate2D BdPt = CLLocationCoordinate2DMake(bdLat, bdLon);
    return [JZLocationConverter bd09ToGcj02:BdPt];
}
@end
