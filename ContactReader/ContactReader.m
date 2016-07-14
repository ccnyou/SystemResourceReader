#import "ContactReader.h"
#import <AddressBook/AddressBook.h>
#import "Contact.h"

@implementation ContactReader {
    ABAddressBookRef    _addressBook;
}

+ (instancetype)reader {
    ContactReader* instance = [[ContactReader alloc] init];
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _addressBook = ABAddressBookCreate();
    if (!_addressBook) {
        return nil;
    }
    
    return self;
}

- (void)dealloc {
    if (_addressBook) {
        CFRelease(_addressBook);
    }
}

- (void)requestAuthorized:(ContactReaderSuccessBlock)success
                  failure:(ContactReaderFailureBlock)failure
{
    ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef errorRef) {
        if (granted) {
            if (success) {
                success();
            }
        } else {
            NSLog(@"%s %d 通讯录授权失败", __FUNCTION__, __LINE__);
            if (failure) {
                NSError* error = (__bridge NSError *)(errorRef);
                failure(error);
            }
        }
    });
}

- (NSArray *)allPeople {
    NSMutableArray* contacts = [[NSMutableArray alloc] init];
    CFArrayRef allPeooleRef = ABAddressBookCopyArrayOfAllPeople(_addressBook);
    if (!allPeooleRef) {
        goto Exit0;
    }
    
    NSInteger count = CFArrayGetCount(allPeooleRef);
    for (NSInteger i = 0; i < count; i++) {
        ABRecordRef recordRef = CFArrayGetValueAtIndex(allPeooleRef, i);
        Contact* contact = [self _contactWithRecord:recordRef];
        if (contact) {
            [contacts addObject:contact];
        }
    }
    
Exit0:
    if (allPeooleRef) {
        CFRelease(allPeooleRef);
    }
    
    return contacts;
}

- (NSString *)_nameWithRecord:(ABRecordRef)recordRef {
    NSString* result = nil;
    CFStringRef firstName = NULL;
    CFStringRef lastName = NULL;
    
    firstName = ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
    if (!firstName) {
        firstName = (__bridge CFStringRef)@"";
    }
    
    lastName = ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
    if (!lastName) {
        lastName = (__bridge CFStringRef)@"";
    }
    
    result = [NSString stringWithFormat:@"%@%@", lastName, firstName];
    
Exit0:
    if (firstName) {
        CFRelease(firstName);
    }
    
    if (lastName) {
        CFRelease(lastName);
    }
    
    return result;
}

- (NSArray *)_phoneNumbersWithRecord:(ABRecordRef)recordRef {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    ABMultiValueRef phonesRef = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
    NSInteger count = ABMultiValueGetCount(phonesRef);
    for (NSInteger i = 0; i < count; i++) {
        CFStringRef phoneRef = ABMultiValueCopyValueAtIndex(phonesRef, i);
        NSString* phoneValue = (__bridge NSString *)phoneRef;
        if (phoneValue) {
            [results addObject:phoneValue];
        }
        
        if (phoneRef) {
            CFRelease(phoneRef);
        }
    }
    
Exit0:
    if (phonesRef) {
        CFRelease(phonesRef);
    }
    
    return results;
}

- (Contact *)_contactWithRecord:(ABRecordRef)recordRef {
    Contact* result = nil;
    NSString* name = [self _nameWithRecord:recordRef];
    NSArray* numbers = [self _phoneNumbersWithRecord:recordRef];
    
    result = [[Contact alloc] init];
    result.name = name;
    result.phone = [numbers componentsJoinedByString:@"|"];
    NSLog(@"%s %d contact = %@", __FUNCTION__, __LINE__, result);
    
    return result;
}

@end
