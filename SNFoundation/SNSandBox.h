//
//  SNSandBox
//  SNFoundation
//
//  Created by  liukun on 13-1-14.
//  Copyright (c) 2013年 liukun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDefines.h"

// 程序目录，不能存任何东西
SN_INLINE NSString* AppPath();

// 文档目录，需要ITUNES同步备份的数据存这里
SN_INLINE NSString* DocPath();

// 配置目录，配置文件存这里
SN_INLINE NSString* LibPrefPath();

// 缓存目录，系统永远不会删除这里的文件，ITUNES会删除
SN_INLINE NSString* LibCachePath();

// 缓存目录，APP退出后，系统可能会删除这里的内容
SN_INLINE NSString* TmpPath();

// 创建目录
SN_EXTERN NSString* TouchPath(NSString *path);


#pragma mark -

SN_INLINE NSString* AppPath()
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

SN_INLINE NSString* DocPath()
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

SN_INLINE NSString* LibPrefPath()
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Preference"];
}

SN_INLINE NSString* LibCachePath()
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
}

SN_INLINE NSString* TmpPath()
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [[paths objectAtIndex:0] stringByAppendingFormat:@"/tmp"];
}

