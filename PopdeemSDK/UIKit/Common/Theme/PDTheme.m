//
// Created by John Doran Home on 25/11/2015.
// Copyright (c) 2015 Popdeem. All rights reserved.
//

#import "PDTheme.h"

@interface PDTheme ()
@property(nonatomic, copy) NSDictionary *theme;
@end

static const NSString *kVariablesKey = @"Variables";


@implementation PDTheme

/**
 * Setup
 */
+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (instancetype)setupWithFileName:(NSString *)file {
    [[self sharedInstance] setTheme:[self loadThemeFromFile:file]];
    return [self sharedInstance];
}

+ (NSDictionary *)loadThemeFromFile:(NSString *)fileName {
    return [self jsonDictionaryFromData:[self readFileWithName:fileName extension:@"json"]];
}


- (UIImage *)imageForKey:(NSString *)key {
    UIImage *image = nil;
    id value = [self objectForKey:key];
    if (value){
        if ([value isKindOfClass:[NSString class]]){
            image = [UIImage imageNamed:value];
        }
    }
    return image;
}


- (id)objectForKey:(NSString *)key {
    if (self.theme == nil) {
        [NSException raise:@"Theme not setup" format:@""];
        return nil;
    }


    id value = [self.theme valueForKeyPath:key];

    if (value == nil) {
        [NSException raise:@"Value is not defined!" format:@""];
    }

    return [self resolveVariable:value];
}


+ (NSDictionary *)jsonDictionaryFromData:(NSData *)data {
    if (!data) {
        return nil;
    }

    NSError *error = nil;

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

    if (error) {
        [NSException raise:@"JSON Error - can't parse" format:@""];
        return nil;
    }

    return json;
}

- (id)resolveVariable:(id)value {
    id resolvedValue = value;
    if ([value isKindOfClass:[NSString class]] && [value hasPrefix:@"$"]) {
        resolvedValue = [[self variables] valueForKeyPath:[value substringFromIndex:1]];
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableValue = [NSMutableArray array];
        for (id subValue in value) {
            [mutableValue addObject:[self resolveVariable:subValue]];
        }
        resolvedValue = mutableValue;
    }
    return resolvedValue;
}

- (NSDictionary *)variables {
    return self.theme[kVariablesKey];
}

+ (NSData *)readFileWithName:(NSString *)fileName extension:(NSString *)ext {
    NSError *error = nil;

    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:ext];
    if (!filePath) {
        [NSException raise:@"Theme not found" format:@""];
    }

    NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        [NSException raise:error.debugDescription format:@""];
    }
    return data;
}

/**
 * Colors
 */
- (UIColor *)findColorFromValue:(id)value {
    UIColor *color = nil;
    if ([value isKindOfClass:[NSString class]]) {
        color = [self colorFromHexString:value];
        if (!color) color = [self colorFromPatternImageString:value];
    } else if ([value isKindOfClass:[NSArray class]] && [value count] == 2) {
        color = [self findColorFromValue:value[0]];
        if (color) color = [color colorWithAlphaComponent:[(NSString *) value[1] floatValue]];
    }
    return color;
}


- (UIColor *)colorForKey:(NSString *)key {
    UIColor *color = nil;
    id value = [self objectForKey:key];
    if (value) {
        color = [self findColorFromValue:value];
    }
    return color;
}

- (UIColor *)colorFromPatternImageString:(NSString *)patternImageString {
    UIImage *patternImage = [UIImage imageNamed:patternImageString];
    if (patternImage) {
        return [UIColor colorWithPatternImage:patternImage];
    }
    return nil;
}


- (UIColor *)colorFromHexString:(NSString *)colorString {

    if ([colorString hasPrefix:@"#"]) {
        NSScanner *scanner = [NSScanner scannerWithString:[colorString substringFromIndex:1]];
        unsigned long long hexValue;
        if ([scanner scanHexLongLong:&hexValue]) {
            CGFloat red = ((hexValue & 0xFF0000) >> 16) / 255.0f;
            CGFloat green = ((hexValue & 0x00FF00) >> 8) / 255.0f;
            CGFloat blue = (hexValue & 0x0000FF) / 255.0f;
            return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        }
    }
    return nil;
}

@end