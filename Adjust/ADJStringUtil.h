//
//  ADJStringUtil.h
//  Adjust
//

#import <Foundation/Foundation.h>

@interface ADJStringUtil : NSObject

+ (NSString *)adjTrim:(NSString *)string;
+ (NSString *)adjMd5:(NSString *)string;
+ (NSString *)adjSha1:(NSString *)string;
+ (NSString *)adjUrlEncode:(NSString *)string;
+ (NSString *)adjRemoveColons:(NSString *)string;

+ (NSString *)adjJoin:(NSString *)strings, ...;
+ (BOOL) adjIsEqual:(NSString *)first toString:(NSString *)second;

@end