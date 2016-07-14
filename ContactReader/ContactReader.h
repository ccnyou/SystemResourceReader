#import <Foundation/Foundation.h>

typedef void (^ContactReaderSuccessBlock)(void);
typedef void (^ContactReaderFailureBlock)(NSError *error);

@interface ContactReader : NSObject

+ (instancetype)reader;
- (void)requestAuthorized:(ContactReaderSuccessBlock)success
                  failure:(ContactReaderFailureBlock)failure;
- (NSArray *)allPeople;

@end
