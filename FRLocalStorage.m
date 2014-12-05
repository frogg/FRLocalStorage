//
//  FRLocalStorage.m
//  Server
//
//  Created by Frederik Riedel on 05.12.14.
//  Copyright (c) 2014 Frederik Riedel. All rights reserved.
//

#import "FRLocalStorage.h"

@implementation FRLocalStorage
static NSMutableDictionary *dictionary;
static NSString *filePath;

#pragma mark public methods
+(void) initializeStorage {
    dictionary = [[NSMutableDictionary alloc] init];
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filePath = [documentsPath stringByAppendingPathComponent:@"localStorage.txt"];

    NSLog(@"Check this file in Finder: %@",filePath);
    [FRLocalStorage loadDictionaryFromDisc];
}


+(NSString *) objectForKey:(NSString *) key {
    return [dictionary objectForKey:key];
}


+(void) storeObject:(NSString *) object forKey:(NSString *) key {
    [dictionary setObject:object forKey:key];
    [FRLocalStorage saveDictionaryToDisc];
}

#pragma mark
#pragma mark private methods
+(void) saveDictionaryToDisc {
    NSString *saveDataString = @"";
    for(NSString *key in dictionary) {
        
        NSString *object = [dictionary objectForKey:key];
        NSData *nsdata = [object dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64Object = [nsdata base64EncodedStringWithOptions:0];
        
        
        saveDataString = [NSString stringWithFormat:@"%@%@==^==^==%@\n",saveDataString,key,base64Object];
    }
    [saveDataString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+(void) loadDictionaryFromDisc {
    [dictionary removeAllObjects];
    NSString *loadDataString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];

    for(NSString *keyValuePair in [loadDataString componentsSeparatedByString:@"\n"]) {
        
        if([[keyValuePair componentsSeparatedByString:@"==^==^=="] count]>1) {
            NSString *key = [[keyValuePair componentsSeparatedByString:@"==^==^=="] objectAtIndex:0];
            NSString *base64Object = [[keyValuePair componentsSeparatedByString:@"==^==^=="] objectAtIndex:1];
            NSData *nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64Object options:0];
            NSString *object = [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
            
            [dictionary setObject:object forKey:key];
        }
    }
}




@end
