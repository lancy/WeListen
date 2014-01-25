//
//  CYSystemInfo.h
//  CYHelper
//
//  Created by Lancy on 26/11/12.
//
//

#import <Foundation/Foundation.h>

#define IOS7_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define IOS6_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"6.0"] != NSOrderedAscending )
#define IOS5_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"5.0"] != NSOrderedAscending )
#define IOS4_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"4.0"] != NSOrderedAscending )
#define IOS3_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"3.0"] != NSOrderedAscending )
#define IS_IPHONE                       ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_IPAD                         ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


@interface CYSystemInfo : NSObject

+ (NSString *)osVersion;
+ (NSString *)appVersion;

+ (NSString *)deviceModel;

+ (BOOL)isJailBroken;
+ (NSString *)jailBreaker;

@end

