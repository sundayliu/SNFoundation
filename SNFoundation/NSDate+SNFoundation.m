//
//  NSDate+SNFoundation.m
//  SNFoundation
//
//  Created by liukun on 14-3-4.
//  Copyright (c) 2014年 liukun. All rights reserved.
//

#import "NSDate+SNFoundation.h"

@implementation NSDate (SNFoundation)

+ (NSDate *)getDate:(NSString *)dateStr pattern:(NSString *)ptn
{
    NSLocale *locale = [NSLocale currentLocale];
    
    return [self getDate:dateStr pattern:ptn locale:locale];
}

+ (NSDate *)getDate:(NSString *)sDate pattern:(NSString *)ptn locale:(NSLocale *)loc
{
    if (!sDate || !sDate.length)
    {
        return nil;
    }
    
    NSString *dateStr = sDate;
    
    NSDate *date = nil;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.dateFormat = ptn;
    dateFormatter.locale = loc;
    
    date = [dateFormatter dateFromString:dateStr];
        
    return date;
}

@end
