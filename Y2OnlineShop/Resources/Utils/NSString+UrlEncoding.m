//
//  NSString+UrlEncoding.m
//  Y2OnlineShop
//
//  Created by maverick on 4/2/15.
//  Copyright (c) 2015 DIOS. All rights reserved.
//

#import "NSString+UrlEncoding.h"

@implementation NSString (UrlEncoding)

/*
 * http://stackoverflow.com/questions/8088473/url-encode-an-nsstring
 */
- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
