//
// Created by lancy on 26/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSArray+CYHelper.h"


@implementation NSArray (CYHelper)

- (NSArray *)subarrayFromIndex:(NSUInteger)index
{
    NSRange range = {index, [self count] - index};
    return [self subarrayWithRange:range];
    
}

- (NSArray *)subarrayToIndex:(NSUInteger)index
{
    NSRange range = {0, index};
    return [self subarrayWithRange:range];
}

- (NSArray *)shuffledArray {
    NSMutableArray *shuffledArray = [self mutableCopy];
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; i++) {
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        NSUInteger n = arc4random() % nElements + i;
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return shuffledArray;
}

@end