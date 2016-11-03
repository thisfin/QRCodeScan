//
//  HistoryDataCache.h
//  QRCodeScan
//
//  Created by wenyou on 2016/11/2.
//  Copyright © 2016年 wenyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryDataCache : NSObject
+ (instancetype)sharedInstance;
- (void)addCacheValue:(NSString *)value;
- (void)deleteCacheValueAtIndex:(NSUInteger)index;
- (void)deleteAllCacheValue;
- (NSArray *)getCacheValues;
@end
