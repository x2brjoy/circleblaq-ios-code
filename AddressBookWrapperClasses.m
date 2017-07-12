//
//  AddressBookWrapperClasses.m
//  Sup
//
//  Created by Rahul Sharma on 9/24/15.
//  Copyright © 2015 3embed. All rights reserved.
//

//#import "AddressBookWrapperClasses.h"
//#import "APContact.h"
//#import "APPhone.h"
//#import  "APName.h"
//#import "APRecordDate.h"
////#import "Database.h"
//#import "APAddressBook.h"
////#import "ProgressIndicator.h"
////#import "Contacts.h"
////#import "Favorites.h"
////#import "FavDataBase.h"
////#import "ContacDataBase.h"
////#import "ChatSocketIOClient.h"
//
//
//static AddressBookWrapperClasses *addressBookObj = nil;
//
//@interface AddressBookWrapperClasses()
//
//@property (strong, atomic) APAddressBook *aPAddressBookObj;
//@property (strong,nonatomic) NSArray *contactsArray;
//@property (strong, nonatomic) NSMutableArray *contactIdArray;
//@property (strong,nonatomic) NSDate *lastUpdatedDate;
//@property (strong,nonatomic) NSDate *lastLoadDate;
//
////@property (strong,nonatomic) FavDataBase *favDataBase;
////@property (strong,nonatomic) ContacDataBase *contacDataBase;
//
//@end
//
//@implementation AddressBookWrapperClasses
//
//@synthesize firstTimePhoneNumbers,modifiedPhoneNumbers,contactIdArray;
//
//+ (instancetype) sharedInstance :(BOOL)isContactModified
//{
//    if (!addressBookObj)
//    {
//        addressBookObj = [[self alloc] init];
//    }
//    
//    if (isContactModified == NO) {
//        [addressBookObj initialFetch];
//        [addressBookObj startObservingChanges];
//    }
//   
//  
//    return addressBookObj;
//}
//
//
///**
// * @brief for fetching data first time
// */
//-(void)initialFetch
//{
////      _favDataBase = [FavDataBase sharedInstance];
////    _contacDataBase = [ContacDataBase sharedInstance];
////    
////    [_contacDataBase getDocumentInfoForID:@""];
//    
//    
//    _aPAddressBookObj = [[APAddressBook alloc] init];
//   // _aPAddressBookObj.fieldsMask = APContactFieldDefault|APContactFieldRecordDate;  //APContactFieldAll;//APContactFieldDefault;
//     _aPAddressBookObj.fieldsMask = APContactFieldDefault|APContactFieldRecordDate|APContactFieldPhonesWithLabels;  //APContactFieldAll;//
//    
//    
////    NSArray *contatcData = [[NSArray alloc] initWithArray:[_contacDataBase getDataContacDataFromDB]];
//    
//    NSNumber *checkBool = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstResponseCameFromGetContact"];
//    if ((contatcData.count !=0) && (checkBool.boolValue == YES))
//    {
//
//        [self checkContacisChanged];
//    }
//    else
//    {
//        [self fetchContactData];
//    }
//    
//}
//
///**
// *  @brief changes after appearing the view
// */
//-(void)startObservingChanges
//{
//    //__block int i = 0;
//    [_aPAddressBookObj startObserveChangesWithCallback:^{
//       // if(i<=1)
//       // {
//        
//       // static dispatch_once_t once;
//       // dispatch_once(&once, ^{
//          NSNumber *num =   [[NSUserDefaults standardUserDefaults]objectForKey:@"callMethodeFirstTimeOnly"];
//        if (num.boolValue  ==YES) {
//
//            [self checkContacisChanged];
//            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"callMethodeFirstTimeOnly"];
//            
//        }
//        
//       // });
//        
//        
//            //[self addressChnged];
//         //   i++;
//       // }
//    }];
//}
//
///**
// *  @brief used for setting up a time for checkng the last updation of contacts
// */
//
//-(void)setlastUpdate
//{
//    //perform action with the passed variables
//    if(![[NSUserDefaults standardUserDefaults]valueForKey:@"lastUpdate"])
//    {
//        [[NSUserDefaults standardUserDefaults]setValue:[NSDate date] forKey:@"lastUpdate"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//    }
//    else
//    {
//        self.lastUpdatedDate = [[NSUserDefaults standardUserDefaults]valueForKey:@"lastUpdate"];
//        [[NSUserDefaults standardUserDefaults]setValue:[NSDate date] forKey:@"lastUpdate"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//    }
//    
//}
//
//
///**
// *  @brief it will fetch contacts for the first time from phone memory
// */
//-(void)fetchContactData
//{
//    //about loading contacts to the database
//    [_aPAddressBookObj loadContactsOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completion:^(NSArray<APContact *> * _Nullable contacts, NSError * _Nullable error) {
//        
//         if (!error)
//         {
//             self.contactsArray = contacts;
//           //  NSLog(@"number of contact in phone memory =%@",contacts);
//             NSArray *contactsData = [[NSArray alloc] initWithArray:[_contacDataBase getDataContacDataFromDB]];
//             
//             if(![contactsData count])
//             {
//                 [self contactLoading];
//             }else{
//                 [_contacDataBase deleteAllContacDataFromDB];
//                 [self contactLoading];
//             }
//         }
//         else
//         {
//             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"unable to fetch contacts go to Settings and allow access" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//             [alert show];
//         }
//         [self delegateCallingAfterModification];
//     }];
//}
//
//
///*!
// *  @brief used for fetching contacts first time from the phone memory
// */
//-(void)contactLoading
//{
//    
//     NSMutableArray *saveArr = [[NSMutableArray alloc]initWithArray:[_contacDataBase getDataContacDataFromDB]];
//   
//    for (APContact *contDict in self.contactsArray)
//    {
//        if(contDict.phones.count > 0)
//        {
//
//            NSDictionary *dbDictionary =  [self addContact:contDict contactLoadingAtFirstTime:YES];
//           
//            [saveArr addObject:dbDictionary];
//            if(dbDictionary)
//            {
//
//               //[_contacDataBase saveDataInDocument:@"" withMessages:saveArr];
//            }
//        }
//    }
//    
//    
//    [_contacDataBase saveDataInDocument:@"" withMessages:saveArr];
//    
//
//}
//
///**
// *  @brief this method is used for add a contact to the database whenever it calls
// *
// *  @param contactData object of contact data
// *
// *  @return a dictionary for saving it to the database.
// */
//-(NSDictionary *)addContact:(APContact *)contactData contactLoadingAtFirstTime :(BOOL)isFirstTimeContactAreLoading
//{
//    
//        NSMutableDictionary *databseDictionary = [[NSMutableDictionary alloc]init];
//        NSString *fullName;
//        if(contactData.name.firstName)
//        {
//            [databseDictionary setValue:[NSString stringWithFormat:@"%@",contactData.name.firstName]  forKey:@"firstName"];
//            fullName = [NSString stringWithFormat:@"%@",contactData.name.firstName];
//        }
//        if(contactData.name.lastName)
//        {
//            [databseDictionary setValue:contactData.name.lastName forKey:@"lastName"];
//            fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@",contactData.name.lastName]];
//        }
//        //        [databseDictionary setValue:contactData.thumbnail forKey:@"profilePic"];
//        if(fullName)
//        {
//            [databseDictionary setValue:fullName forKey:@"fullName"];
//        }
//        else if (!fullName)
//        {
//            [databseDictionary setValue:@" " forKey:@"fullName"];
//        }
//        NSString *phnumbers;
//        NSMutableArray *phNumerArray = [[NSMutableArray alloc] init];
//        if(isFirstTimeContactAreLoading)
//        {
//            phnumbers = [self contactPhones:contactData isContactUpdated:NO];
//            //chnaged
//            [phNumerArray addObject:phnumbers];
//        }
//        else{
//            phnumbers = [self contactPhones:contactData isContactUpdated:YES];
//            
//            //changed
//            [phNumerArray addObject:phnumbers];
//            
//        }
//        [databseDictionary setValue:phNumerArray forKey:@"arrayOfalternateNumbers"];
//        [databseDictionary setValue:phnumbers forKey:@"alternateNumbers"];
//        
//        [databseDictionary setValue:[NSString stringWithFormat:@"%@",contactData.recordID] forKey:@"contactID"];
//        [databseDictionary setValue:[NSString stringWithFormat:@"%@",contactData.recordDate.modificationDate] forKey:@"modificationDate"];
//
//        return databseDictionary;
//}
//
//
//
//
///**
// *  @brief used for fetching the contact details in a specific format
// *
// *  @param contact it will pass an object which will contain the info
// *
// *  @return it will return a string of numbers with comma saperated with the localized label
// */
//- (NSString *)contactPhones:(APContact *)contact isContactUpdated :(BOOL)updateContact
//{
//    if (contact.phones.count > 0)
//    {
//        NSMutableString *result = [[NSMutableString alloc] init];
//        for (APPhone *phoneWithLabel in contact.phones)
//        {
//            
//            NSString *cleanedString = [[phoneWithLabel.number componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
//            
//            NSString *cleanNumLbl = [NSString stringWithFormat:@"%@",phoneWithLabel.number];
//            cleanNumLbl = [cleanNumLbl stringByReplacingOccurrencesOfString:@"-" withString:@""];
//            cleanNumLbl = [cleanNumLbl stringByReplacingOccurrencesOfString:@" " withString:@""];
//            
//            //changed here cleanNumLbl to cleanedString
//            
//            NSString *string = phoneWithLabel.localizedLabel.length == 0 ? cleanedString:
//            [NSString stringWithFormat:@"%@/%@", cleanedString,phoneWithLabel.localizedLabel];
//            if (!updateContact)
//            {
//                
//                if(firstTimePhoneNumbers.count == 0)
//                {
//                    firstTimePhoneNumbers = [[NSMutableArray alloc] init];
//                    [firstTimePhoneNumbers addObject:[NSString stringWithFormat:@"%@",cleanedString]];
//                }
//                else{
//                    [firstTimePhoneNumbers addObject:[NSString stringWithFormat:@",%@",cleanedString]];
//                }
//            }
//            else{
//                if(modifiedPhoneNumbers.count == 0)
//                {
//                    modifiedPhoneNumbers = [[NSMutableArray alloc] init ];
//                    [modifiedPhoneNumbers addObject:[NSString stringWithFormat:@"%@",cleanedString]];
//                }
//                else{
//                    [modifiedPhoneNumbers  addObject: [NSString stringWithFormat:@",%@",cleanedString]];
//                }
//            }
//            [result appendFormat:@"%@, ", string];
//        }
//        return result;
//    }
//    return nil;
//}
//
//
//
//
//
//-(void)checkContacisChanged{
//    
//    
//    __weak typeof(self) weakSelf = self;
//    // contactIdArray  = [[NSMutableArray alloc]init];
//    
//    [_aPAddressBookObj loadContactsOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completion:^(NSArray<APContact *> * _Nullable contacts, NSError * _Nullable error) {
//        
//        NSLog(@"chnage address methode called");
//        
//        contactIdArray = [[NSMutableArray alloc] init];
//        NSMutableArray *temp  = [[NSMutableArray alloc]initWithArray:[_contacDataBase getDataContacDataFromDB]];
//        NSArray *modifyArr;
//        BOOL isNewCame = NO;
//        BOOL ismodify = NO;
//        
//        weakSelf.lastLoadDate = [NSDate date];
//        
//        for (APContact *apContacObj in contacts) {
//            
//            NSDictionary *contactObj;
//            if (apContacObj.recordID) {
//                // NSLog(@"recordID =%@",apContacObj.recordID); //contains[cd]
//                
//                NSArray *contacAlldata = [[NSArray alloc]initWithArray:[_contacDataBase getDataContacDataFromDB]];
//                NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"contactID == %@",[NSString stringWithFormat:@"%@",apContacObj.recordID]];
//                NSArray *contactsArray = [contacAlldata filteredArrayUsingPredicate:bPredicate];
//                
//                // NSLog(@"found contactsArray =%@",contactsArray);
//                
//                NSString *modiDate =[NSString stringWithFormat:@"%@",apContacObj.recordDate.modificationDate];
//                NSString *modiDateFromDB = [NSString new];
//                if (contactsArray.count>0) {
//                    contactObj = [contactsArray firstObject];
//                    modiDateFromDB  = [NSString stringWithFormat:@"%@",contactObj[@"modificationDate"]];
//                   // NSLog(@"record id =%@",[NSString stringWithFormat:@"%@",apContacObj.recordID]);
//                    [contactIdArray addObject:[NSString stringWithFormat:@"%@",apContacObj.recordID]];
//                }
//                
//                //NSLog(@"modiDateFromDB =%@",modiDateFromDB);
//                // NSLog(@"modiDate =%@",modiDate);
//                //  [contactIdArray addObject:[NSString stringWithFormat:@"%@",apContacObj.recordID]];
//                
//                if (contactsArray.count == 0) {
//                    //new contact is added to addressBook
//                    if(apContacObj.phones.count > 0)
//                    {
//                        
//                        [contactIdArray addObject:[NSString stringWithFormat:@"%@",apContacObj.recordID]];
//                        NSDictionary *dbDictionary =  [self addContact:apContacObj contactLoadingAtFirstTime:YES];
//                        [temp addObject:dbDictionary];
//                        
//                        if(dbDictionary)
//                        {
//                            isNewCame = YES;
//                            // BOOL isSaved = [dbObj makeDataBaseEntryForContacts:dbDictionary];
//                           // NSLog(@"dbDictionary added =%@",dbDictionary);
//                           // [_contacDataBase saveDataInDocument:@"" withMessages:temp];
//                            
//                        }
//                    }
//                }
//                else if (![modiDate isEqualToString:modiDateFromDB]){
//                   // NSLog(@"datemodifyied");
//                    if (contactsArray.count>0) {
//                        ismodify = YES;
//                        modifyArr = [self storemodifyValuetoDB:apContacObj contact:contactObj];
//                    
//                    }
//                    
//                }
//                
//            }
//            
//            
//        }//for loop
//        
//        
//        if (isNewCame == YES) {
//            [_contacDataBase saveDataInDocument:@"" withMessages:temp];
//            if(self.updateDelegate && [self.updateDelegate respondsToSelector:@selector(reloadFavtableView)])
//                            {
//                                [self.updateDelegate reloadFavtableView];
//                            }
//        }
//        
//        if (ismodify == YES) {
//            [_contacDataBase saveDataInDocument:@"" withMessages:[modifyArr mutableCopy]];
//            if(self.updateDelegate && [self.updateDelegate respondsToSelector:@selector(reloadFavtableView)])
//            {
//                [self.updateDelegate reloadFavtableView];
//            }
//        }
//        
//        
//        [self delegateCallingAfterModification];
//        
//        
////        BOOL isDelete = NO;
////        NSArray *deletedArr;
////        
////        //delete contac from db
////        NSArray *contactsArray =[[NSArray alloc]initWithArray:[_contacDataBase getDataContacDataFromDB]];
////        NSMutableArray *dbArray = [[NSMutableArray alloc]initWithArray:contactsArray];
////
////        //change use NSArray to remove crash in containsObject
////        
////        NSArray *copyContacIdArr = [contactIdArray copy];
////        if (copyContacIdArr.count == dbArray.count) {
////        }else{
////            
////            for (NSDictionary *obj in dbArray) {
////                
////                if (copyContacIdArr.count >0) {
////                    if ([copyContacIdArr containsObject:[NSString stringWithFormat:@"%@",obj[@"contactID"]]]) {
////                        // NSLog(@"in db =%@",obj);
////                    }else{
////                        
////                        
////                        NSString *supNum = [NSString stringWithFormat:@"%@",obj[@"supNumber"]];
////                        NSString *contId = [NSString stringWithFormat:@"%@",obj[@"contactID"]];
////                        NSLog(@"deleted =%@",obj);
////                        [contactIdArray removeObject:contId];
////                        
////                        NSArray *contacAlldata = [[NSArray alloc]initWithArray:[_contacDataBase getDataContacDataFromDB]];
////                        NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"contactID == %@",contId];
////                        NSArray *contactsArray = [contacAlldata filteredArrayUsingPredicate:bPredicate];
////                        
////                        if (contactsArray.count>0) {
////
////                                isDelete = YES;
////                           // [_contacDataBase deleteObjectFromDB:obj contacID:contId];
////                               deletedArr = [_contacDataBase deleteObjectFromDBtoRemove:obj contacID:contId];
////                            
////                            if ([supNum isEqualToString:@"(null)"]) {
////                                
////                            }else{
////                                [_favDataBase deleteObjectFromDB:nil favID:supNum];}
////                            
////                            
////                        }
////                        
////                        
////                        
////                    }
////                    
////                    
////                }
////                
////                
////            }
////            
////        }
////        
////        
////        
////        
////        
////        if (isDelete == YES) {
////            
////            [_contacDataBase saveDataInDocument:@"" withMessages:[deletedArr mutableCopy]];
////            if(self.updateDelegate && [self.updateDelegate respondsToSelector:@selector(reloadFavtableView)])
////            {
////                [self.updateDelegate reloadFavtableView];
////            }
////            
////        }
//        
//        
//    }];
//    
//    
//    
//}
//
//
//-(NSArray*)storemodifyValuetoDB:(APContact*)aPcontact  contact:(NSDictionary *)Contact{
//    
//    NSArray *contacArry ;
//    
//    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
//    [dict setValue:[NSString stringWithFormat:@"%@",Contact[@"profilePic"]] forKey:@"profilePic"];
//    [dict setValue:[NSString stringWithFormat:@"%@",Contact[@"supNumber"]] forKey:@"supNumber"];
//    [dict setValue:[NSString stringWithFormat:@"%@",Contact[@"status"]] forKey:@"status"];
//    
//    
//    NSDictionary *dbDictionary = [self addContact:aPcontact contactLoadingAtFirstTime:NO];
//    
//    [dict setValue:[dbDictionary objectForKey:@"firstName"] forKey:@"firstName"];
//    [dict setValue:[dbDictionary objectForKey:@"lastName"] forKey:@"lastName"];
//    [dict setValue:[dbDictionary objectForKey:@"fullName"] forKey:@"fullName"];
//    [dict setValue:[dbDictionary objectForKey:@"alternateNumbers"] forKey:@"alternateNumbers"];
//    [dict setValue:[dbDictionary objectForKey:@"contactID"] forKey:@"contactID"];
//    [dict setValue:[dbDictionary objectForKey:@"modificationDate"] forKey:@"modificationDate"];
//    [dict setValue:[dbDictionary objectForKey:@"arrayOfalternateNumbers"] forKey:@"arrayOfalternateNumbers"];
//    
//    if(dbDictionary)
//    {
//       // [_contacDataBase updateContacDatabase:[dict copy] contacID:[NSString stringWithFormat:@"%@",[dbDictionary objectForKey:@"contactID"]]];
//        contacArry = [_contacDataBase updateContacDBtoRemove:[dict copy] contacID:[NSString stringWithFormat:@"%@",[dbDictionary objectForKey:@"contactID"]]];
//        
//    }
//    
//    
//    //also change Fav database
//    
//    NSArray *contacAlldata = [[NSArray alloc]initWithArray:[_favDataBase getDataFavDataFromDB]];
//    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"supNumber == %@",[dict objectForKey:@"supNumber"]];
//    NSArray *array = [contacAlldata filteredArrayUsingPredicate:bPredicate];
//    
//    
//    NSMutableDictionary *favDict  =[[NSMutableDictionary alloc]init];
//    if (array.count>0) {
//        NSDictionary *fav = [array firstObject];
//        [favDict setValue:fav[@"status"] forKey:@"status"];
//        [favDict setValue:fav[@"image"] forKey:@"image"];
//        [favDict setValue:fav[@"supNumber"] forKey:@"supNumber"];
//        [favDict setValue:[dict objectForKey:@"fullName"] forKey:@"fullName"];
//        
//    
//        if (favDict) {
//            
//            [_favDataBase updateContacDatabase:[favDict copy] contacID:[NSString stringWithFormat:@"%@",favDict[@"supNumber"]]];
//            
//            if(self.updateDelegate && [self.updateDelegate respondsToSelector:@selector(reloadFavtableView)])
//            {
//                [self.updateDelegate reloadFavtableView];
//            }
//            
//        }
//    }
//    
//    
//    
//    return contacArry;
//    
//}
//
//
//
///**
// *  @brief updation, deletion , modificaion of contacts in phone memory
// */
//-(void)addressChnged
//{
//    [_aPAddressBookObj loadContacts:^(NSArray *contacts, NSError *error)
//     {
//         [[ProgressIndicator sharedInstance]hideProgressIndicator];
//         if (!error)
//         {
//             self.contactsArray = contacts;
//             NSArray *contactsData = [Database dataFromTable:@"Contacts" condition:nil orderBy:nil ascending:NO];
//             
//             if(![contactsData count])
//             {
//                 [self contactLoading];
//             }
//             else if(contactsData.count>self.contactIdArray.count)
//             {
//                 [self createAContact:contacts];
//             }
//             else if (contactsData.count == self.contactIdArray.count)
//             {
//                //take long time
//                 
//                                                /*take long so commented*/
//                 bool isContactNotDeleted = NO;//[self deleteAContact:contacts];
//                 BOOL isContactodified = NO;
//                 if(!isContactNotDeleted)
//                 {
//                     //[self setlastUpdate];
//                     isContactodified = [self modifyingContact:contacts];
//                     //                     [self modifyingContact:contacts chngesDoneLstTime:self.lastUpdatedDate];
//                 }
//                 if (isContactodified) {
//                     [self createAContact:contacts];
//                 }
//             }
//             else{
//                 /*take log so commented*/
//                // [self deleteAContact:contacts];
//             }
//         }
//         [self delegateCallingAfterModification];
//     }];
//}
//
//
//
//
//
///*!
// *  @brief this will create a contact from observing a change in contact book
// *
// *  @param contacts array of contacts
// */
//-(void)createAContact :(NSArray *)contacts
//{
//    for (APContact *contDict in contacts)
//    {
//        if(contDict.phones.count > 0)
//        {
//            NSArray *contactIDsArr = [[NSArray alloc] initWithArray:self.contactIdArray];
//            
//            if(![contactIDsArr containsObject:[NSString stringWithFormat:@"%@",contDict.recordID]])
//            {
//                Database *dbObj = [[Database alloc]init];
//                NSDictionary *dbDictionary =  [self addContact:contDict contactLoadingAtFirstTime:YES];
//                if(dbDictionary)
//                {
//                    [dbObj makeDataBaseEntryForContacts:dbDictionary];
//                }
//            }
//        }
//    }
//}
//
//
///**
// *  @brief modifyi a perticular contact which is got changed
// *
// *  @param contacts array of contacts
// */
//-(BOOL)modifyingContact : (NSArray *)contacts
//{
//    BOOL  isContactModified = NO;
//    NSMutableArray *deleteObjectArray = [NSMutableArray array];
//    for (APContact *contact in contacts)
//    {
//        if(contact.phones.count > 0)
//        {
//            NSTimeInterval datemodifiedtime =[contact.recordDate.modificationDate timeIntervalSince1970];
//            NSNumber *modifiedDateNumber= [NSNumber numberWithDouble:datemodifiedtime];
//            NSTimeInterval lastUpdatedDate =[self.lastUpdatedDate timeIntervalSince1970];
//            NSNumber *lastUpdatedNumber= [NSNumber numberWithDouble:lastUpdatedDate];
//            if ([modifiedDateNumber intValue]>[lastUpdatedNumber intValue])
//            {
//                Database *dbObj = [[Database alloc]init];
//                [Database deleteRowFromDataBaseWithTableName:@"Contacts"
//                                                     andKeys:[NSString
//                                                              stringWithFormat:@"contactID = %@",contact.recordID]];
//                NSDictionary *dbDictionary =  [self addContact:contact contactLoadingAtFirstTime:YES];
//                if(dbDictionary)
//                {
//                    [dbObj makeDataBaseEntryForContacts:dbDictionary];
//                    isContactModified = YES;
//                }
//            }
//        }
//        else
//        {
//            [Database deleteRowFromDataBaseWithTableName:@"Contacts"
//                                                 andKeys:[NSString
//                                                          stringWithFormat:@"contactID = %@",contact.recordID]];
//            [deleteObjectArray addObject:contact.recordID];
//        }
//    }
//    [self.contactIdArray removeObjectsInArray:deleteObjectArray];
//    
//    return isContactModified;
//    
//}
//
///**
// *  @brief it will delete the contact which is not available in contact book
// *
// *  @param contacts array of contacts
// *
// *  @return bool value deleted or not.
// */
//-(BOOL)deleteAContact :(NSArray *)contacts
//{
//    BOOL isAnyContactDelete = NO;
//    NSMutableArray *array1 = [NSMutableArray array];
//    
//   
//    for (APContact *contDict in contacts) {
//        int i=0;
//        // NSLog(@"contactIdArrayDB =  and contacInPhone %@",contDict.recordID);
//        for (NSString *str in self.contactIdArray) {
//            
//            if ([str isEqualToString:[NSString stringWithFormat:@"%@",contDict.recordID]]) {
//                
//                i++;
//            }
//        }
//        
//        if (i==0) {
//            
//            [Database deleteRowFromDataBaseWithTableName:@"Contacts" andKeys:[NSString
//                                                                              stringWithFormat:@"contactID = %@",contDict.recordID]];
//            [array1 addObject:contDict.recordID];
//            isAnyContactDelete = YES;
//        }
//        
//    }
//    
//    [self.contactIdArray removeObjectsInArray:array1];
//    return  isAnyContactDelete;
//    
//}
//
//
//
//
//
//
//
//
//
///**
// *  @brief delegate will send the contact string to sup socket string class.
// */
//-(void)delegateCallingAfterModification
//{
//    if(firstTimePhoneNumbers.count>0)
//    {
//        
//        ChatSocketIOClient *client =[ChatSocketIOClient sharedInstance];
//        [client syncContacts:firstTimePhoneNumbers];
//         firstTimePhoneNumbers = [NSMutableArray new];
//
//        
////        if(self.updateDelegate && [self.updateDelegate respondsToSelector:@selector(updateContact:)])
////        {
////            [self.updateDelegate updateContact:firstTimePhoneNumbers];
////            firstTimePhoneNumbers = [NSMutableArray new];
////        }
//    }
//}
//
//
//
//-(void)sendLeftnumberToServer{
//    
//  //  NSArray *contactsArray =[[NSArray alloc]initWithArray:[Database dataFromTable:@"Contacts" condition:nil orderBy:@"fullName" ascending:YES]];
//    NSArray *contactsArray = [[NSArray alloc]initWithArray:[_contacDataBase getDataContacDataFromDB]];
//    NSMutableArray *dbArray = [[NSMutableArray alloc]initWithArray:contactsArray];
//    NSMutableArray *arrayOfnum = [NSMutableArray new];
//    
//    for (NSDictionary *obj in dbArray){
//        
//        NSLog(@"obj =%@",obj[@"alternateNumbers"]);
//        NSArray *phoneNumbers = [[NSString stringWithFormat:@"%@",obj[@"alternateNumbers"]] componentsSeparatedByString:@","];
//       NSMutableArray *phNumbers  = [phoneNumbers mutableCopy];
//        for (NSString *str in phNumbers)
//        {
//            if(str.length == 1)
//            {
//                [phNumbers removeObjectAtIndex:[phNumbers indexOfObject:str]];
//            }
//        }
//
//        
//        NSArray *phoneLabels = [phNumbers[0] componentsSeparatedByString:@"/"];
//        NSString  *netphoneNumber =[NSString stringWithFormat:@"%@",phoneLabels[0]];
//
//       // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"supNumber = %@",[NSString stringWithFormat:@"%@",netphoneNumber]];
//       // NSArray *array = [Database favoriteObjectWithMatchingPhoneNumber:predicate];
//
//            NSLog(@"store number send to server ");
//            if(arrayOfnum.count == 0)
//            {
//                [arrayOfnum addObject:[NSString stringWithFormat:@"%@",netphoneNumber]];
//            }
//            else{
//                [arrayOfnum addObject:[NSString stringWithFormat:@",%@",netphoneNumber]];
//            }
//
//    }
//    
//    
//    if(arrayOfnum.count>0)
//    {
//       
//        ChatSocketIOClient *socket =[ChatSocketIOClient sharedInstance];
//        [socket syncContacts:arrayOfnum];
//        firstTimePhoneNumbers = [NSMutableArray new];
//        
//        //commented
////        if(self.updateDelegate && [self.updateDelegate respondsToSelector:@selector(updateContact:)])
////        {
////            NSLog(@"send number agina goto favcontroller =%@",arrayOfnum);
////            [self.updateDelegate updateContact:arrayOfnum];
////            firstTimePhoneNumbers = [NSMutableArray new];
////        }
//   
//    }
//
//    
//    
//    
//}
//
//
//
//
//
//
//@end
