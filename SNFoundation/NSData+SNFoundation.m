//
//  NSData+SNFoundation.m
//  SNFoundation
//
//  Created by liukun on 14-3-4.
//  Copyright (c) 2014年 liukun. All rights reserved.
//

#import "NSData+SNFoundation.h"

@implementation NSData (SNFoundation)

- (NSString *)hexString
{
    NSUInteger len = [self length];
    
    if (len == 0)
    {
        return nil;
    }
    
    const Byte *p = [self bytes];

    NSMutableString *hexString = [[NSMutableString alloc] initWithCapacity:len*2];
    
    for (int i=0; i < len; i++)
    {
        [hexString appendFormat:@"%02x", *p++];
    }
    
    return [hexString uppercaseString];
}

@end
