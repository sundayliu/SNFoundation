//
//  SNSandBox.m
//  SNFoundation
//
//  Created by  liukun on 13-1-14.
//  Copyright (c) 2013年 liukun. All rights reserved.
//

#import "SNSandBox.h"


SN_EXTERN NSString* TouchPath(NSString *path)
{
    if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:path] )
	{
        [[NSFileManager defaultManager] createDirectoryAtPath:path
								  withIntermediateDirectories:YES
												   attributes:nil
														error:NULL];
	}
	return path;
}