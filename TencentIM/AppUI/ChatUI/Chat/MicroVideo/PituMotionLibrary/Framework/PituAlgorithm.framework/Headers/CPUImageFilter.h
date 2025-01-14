//
//  CPUImageFilter.h
//  FilterShowcase
//
//  Created by Patrick Yang on 12-6-27.
//  Copyright (c) 2012年 Cell Phone. All rights reserved.
//

#include <UIKit/UIKit.h>
#import "UIImageUtils.h"

struct _Image;

@class SubImageInfo;

@protocol CPUImageFilterDelegate <NSObject>
@required
- (void)processFinished:(UIImage *)image;
@end

@interface CPUImageFilter : NSObject
{
}

@property (nonatomic, retain) NSArray *images;
@property (nonatomic, weak) NSObject<CPUImageFilterDelegate> *delegate;
@property (nonatomic, assign) BOOL orientationSensitive;
@property (nonatomic, assign) UIInterfaceOrientation deviceOrientation;

- (void)applyFilter;
- (UIImage *)main;
- (UIImage *)processImageInstantly:(UIImage *)image;
- (void)setProperty:(NSString *)name value:(NSObject *)value;
- (NSObject *)getProperty:(NSString *)name;

+ (void)applyFilter:(int)filterId withImages:(NSArray *)images whenComplete:(void(^)(UIImage *result))block;
+ (void)cancelAllIncompleteOperations;

//bigImageProcess
- (unsigned char *)processOneSlicePixels:(SubImageInfo *)sliceInfo;
@end

