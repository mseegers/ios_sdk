//
//  ADJStringUtil.m
//  Adjust
//

#import "ADJStringUtil.h"

#import "CommonCrypto/CommonDigest.h"

@implementation ADJStringUtil

+ (NSString *)adjTrim:(NSString*)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)adjMd5:(NSString*)string {
    const char *cStr = [string UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return  output;
}

+ (NSString *)adjSha1:(NSString*)string {
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

+ (NSString *)adjUrlEncode:(NSString*)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

+ (NSString *)adjRemoveColons:(NSString*)string {
    return [string stringByReplacingOccurrencesOfString:@":" withString:@""];
}

+ (NSString *)adjJoin:(NSString *)first, ... {
    NSString *iter, *result = first;
    va_list strings;
    va_start(strings, first);
    
    while ((iter = va_arg(strings, NSString*))) {
        NSString *capitalized = iter.capitalizedString;
        result = [result stringByAppendingString:capitalized];
    }
    
    va_end(strings);
    return result;
}

+ (BOOL) adjIsEqual:(NSString *)first toString:(NSString *)second {
    if (first == nil && second == nil) {
        return YES;
    }
    
    return [first isEqualToString:second];
}

@end