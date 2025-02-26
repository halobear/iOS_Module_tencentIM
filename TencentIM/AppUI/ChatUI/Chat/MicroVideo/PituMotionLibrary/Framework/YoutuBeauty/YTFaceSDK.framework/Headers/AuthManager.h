//
//  NSObject+AuthManager.h
//  YoutuFaceSDK
//
//  Created by PanCheng on 10/21/16.
//  Copyright © 2016 Patrick Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* licenceStr =@"";

@interface AuthManager : NSObject 

+(NSString*)getLicenceStr;
+(int)setLicenceStr:(NSString*)licStr;
+(void)clearLicenceStr;
+(bool)checkIsLicStrExist;

@end
