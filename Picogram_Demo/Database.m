//
//  Database.m
//  privMD
//
//  Created by Rahul Sharma on 20/03/14.
//  Copyright (c) 2014 Rahul Sharma. All rights reserved.
//

#import "Database.h"
#import "AppDelegate.h"
#import "StoreIDs+CoreDataClass.h"
//#import "Contacts.h"
//#import "Favorites+CoreDataProperties.h"
//#import "ChatMessages.h"


@implementation Database

#pragma mark - To fetch data from data base

+ (NSManagedObjectContext *)context {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    return context;
}


+ (NSArray *)dataFromTable:(NSString *)table condition:(NSString *)condition orderBy:(NSString *)column ascending:(BOOL)asc {
   
 //   AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  //  NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *mainMOC =[appDelegate managedObjectContext];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = [appDelegate managedObjectContext];
    
   
    

    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //[fetchRequest setReturnsObjectsAsFaults:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    if (condition) {
        //NSLog(@" condition-->%@",condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition];
        [fetchRequest setPredicate:predicate];
    }
    
    if (column) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:column ascending:asc];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    
    if (error) {
        //NSLog(@"Core Data: %@", [error description]);
    }
    
    

    [mainMOC performBlock:^{
        NSError *error;
        if (![mainMOC save:&error])
        {
            NSLog(@"in mainMOC saved handle error");
            // handle error
        }
    }];
    
   // NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   // [nc addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
    

    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];

    
    return result;
}


#pragma mark - Adding in Data base

//for status

//-(BOOL)makeDataBaseEntryForContacts:(NSDictionary *)dictionary{
//    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *mainMOC =[appDelegate managedObjectContext];
//    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    context.parentContext = [appDelegate managedObjectContext];
//    
//    
//    [context performBlockAndWait:^{
//        
//        Contacts *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:context];
//        [entity setFirstName:[dictionary objectForKey:@"firstName"]];
//        [entity setLastName:[dictionary objectForKey:@"lastName"]];
//        [entity setFullName:[dictionary objectForKey:@"fullName"]];
//        [entity setProfilePic:[dictionary objectForKey:@"profilePic"]];
//        [entity setSupNumber:[dictionary objectForKey:@"supNumber"]];
//        [entity setAlternateNumbers:[dictionary objectForKey:@"alternateNumbers"]];
//        [entity setStatus:[dictionary objectForKey:@"status"]];
//        [entity setContactID:[dictionary objectForKey:@"contactID"]];
//        [entity setModificationDate:[dictionary objectForKey:@"modificationDate"]];
//        [entity setArrayOfalternateNumbers:[dictionary objectForKey:@"arrayOfalternateNumbers"]];
//        
//        NSError *error;
//        BOOL isSaved = (BOOL)[context save:&error];
//        if (isSaved)
//        {
//           // NSLog(@"data is saved");
//        }
//        else
//        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Saving failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertView show];
//        }
//        
//        
//        
//        
//       // NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//      //  [nc addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
//        
//
//       
//        //[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
//
//        
//                [mainMOC performBlock:^{
//                    NSError *error;
//                    if (![mainMOC save:&error])
//                    {
//                        NSLog(@"in mainMOC saved handle error");
//                        // handle error
//                    }
//                }];
//        
//    }];
//    
//    return YES;
//}




//-(BOOL)makeDataBaseEntryForContacts:(NSDictionary *)dictionary{
//    NSError *error;
//	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//	
//	NSManagedObjectContext *context = [appDelegate managedObjectContext];
//    	
//    /*
//     @dynamic firstName;
//     @dynamic lastName;
//     @dynamic profilePic;
//     @dynamic supNumber;
//     @dynamic alternateNumbers;
//     @dynamic status;
//     @dynamic contactID;lastContactUpdate
//     */
//    
//    Contacts *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Contacts" inManagedObjectContext:context];
//    [entity setFirstName:[dictionary objectForKey:@"firstName"]];
//    [entity setLastName:[dictionary objectForKey:@"lastName"]];
//    [entity setFullName:[dictionary objectForKey:@"fullName"]];
//    [entity setProfilePic:[dictionary objectForKey:@"profilePic"]];
//    [entity setSupNumber:[dictionary objectForKey:@"supNumber"]];
//    [entity setAlternateNumbers:[dictionary objectForKey:@"alternateNumbers"]];
//    [entity setStatus:[dictionary objectForKey:@"status"]];
//    [entity setContactID:[dictionary objectForKey:@"contactID"]];
//    [entity setModificationDate:[dictionary objectForKey:@"modificationDate"]];
//    [entity setArrayOfalternateNumbers:[dictionary objectForKey:@"arrayOfalternateNumbers"]];
//
//    
//	BOOL isSaved = (BOOL)[context save:&error];
//	if (isSaved)
//    {
//        NSLog(@"data is saved");
//    }
//	else
//    {
//        	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Saving failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        	[alertView show];
//	}
//    
//    
//    return isSaved;
//}



//-(BOOL)makeDataBaseEntryForFavorites:(NSDictionary *)dictionary
//{
//    
//    
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *mainMOC =[appDelegate managedObjectContext];
//    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    context.parentContext = mainMOC;
//    
//    
//    [context performBlockAndWait:^{
//        
//        Favorites *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:context];
//        [entity setStatus:[dictionary objectForKey:@"status"]];
//        [entity setImage:[dictionary objectForKey:@"image"]];
//        [entity setSupNumber:[dictionary objectForKey:@"supNumber"]];
//        [entity setFullName:[dictionary objectForKey:@"fullName"]];
//        
//        NSError *error;
//        BOOL isSaved = [context save:&error];
//        if (isSaved)
//        {
//            NSLog(@"data is saved");
//        }
//        else
//        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Saving failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertView show];
//        }
//        
//        
//       
//       // NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//       // [nc addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
//        
//
//        
//   //     [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
//
//        
//                [mainMOC performBlock:^{
//                    NSError *error;
//                    if (![mainMOC save:&error])
//                    {
//                        NSLog(@"in mainMOC saved handle error");
//                        // handle error
//                    }
//                }];
//        
//        
//    }];
//    
//    return YES;
//}

-(BOOL)makeDataBaseEntryforStoreID:(NSDictionary *)dictionary{
    
     AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
     NSManagedObjectContext *context =[appDelegate managedObjectContext];
    
    /* @dynamic groupid;*/
    
    StoreIDs *entity = [NSEntityDescription insertNewObjectForEntityForName:@"StoreIDs" inManagedObjectContext:context];
    [entity setGroupid:[dictionary objectForKey:@"groupid"]];
    [entity setDocumentid:[dictionary objectForKey:@"documentid"]];
    
    NSError *error;
    BOOL isSaved = [context save:&error];
    
    if (isSaved) {
        
    }
    
    return isSaved;
}

//-(BOOL)makeDataBaseEntryForFavorites:(NSDictionary *)dictionary
//{
//    NSError *error;
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *context = [appDelegate managedObjectContext];
//    
////    //added
////    NSManagedObjectContext *context1 = [appDelegate managedObjectContext];
////    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
////    context.parentContext = context1;
//
//    
//    /*
//     @dynamic firstName;
//     @dynamic fullName;
//     @dynamic image;
//     @dynamic lastName;
//     @dynamic status;
//     @dynamic supNumber;
//     */
//    
//    Favorites *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:context];
//    
//    [entity setStatus:[dictionary objectForKey:@"status"]];
//    [entity setImage:[dictionary objectForKey:@"image"]];
//    [entity setSupNumber:[dictionary objectForKey:@"supNumber"]];
//    [entity setFullName:[dictionary objectForKey:@"fullName"]];  
//    
//    BOOL isSaved = [context save:&error];
//    if (isSaved)
//    {
//        NSLog(@"data is saved");
//    }
//    else
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Saving failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertView show];
//    }
//    
////    
////    [context1 performBlock:^{
////        NSError *error;
////        if (![context1 save:&error])
////        {
////            NSLog(@"in mainMOC saved handle error");
////            // handle error
////        }
////    }];
//
//    
//    
//    return isSaved;
//}

//-(BOOL)makeDataBaseEntryforChatMessages:(NSDictionary *)dictionary
//{
//    NSError *error;
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *context = [appDelegate managedObjectContext];
//    ChatMessages *messageEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ChatMessages" inManagedObjectContext:context];
//    [messageEntity setMessage:dictionary[@"message"]];
//    [messageEntity setMessageType:dictionary[@"messageType"]];
//    [messageEntity setDateAndTime:dictionary[@"dateAndTime"]];
//    [messageEntity setChatID:dictionary[@"chatID"]];
//    [messageEntity setSenderID:dictionary[@"senderID"]];
//    [messageEntity setThumbnailPath:dictionary[@"thumbnailPath"]];
//        
//    BOOL isSaved = [context save:&error];
//    if (isSaved)
//    {
//        NSLog(@"data is saved");
//    }
//    else
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Saving failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertView show];
//    }
//    return isSaved;
//}


#pragma mark - Get Contact for Matching  Property

+(NSArray *)favoriteObjectWithMatchingPhoneNumber:(NSPredicate *)phoneumber{
    
   // AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   // NSManagedObjectContext *context = [appDelegate managedObjectContext];
    

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *mainMOC =[appDelegate managedObjectContext];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = mainMOC;
    
    
    
    NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"Favorites" inManagedObjectContext:context];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity1];   
    [fetch setPredicate:phoneumber];
    //... add sorts if you want them
    NSError *fetchError;
    NSArray *fetchedProducts = [context executeFetchRequest:fetch error:&fetchError];
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
    

   
    [mainMOC performBlock:^{
                NSError *error;
                if (![mainMOC save:&error])
               {
                    NSLog(@"in mainMOC saved handle error");
                    // handle error
                }
    }];
  // [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
   
    
    
    return fetchedProducts;
}

+(NSArray *)storeIdobjectWithMatchingStoreID:(NSPredicate *)storeID{

    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"StoreIDs" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity1];
    [fetch setPredicate:storeID];
    //... add sorts if you want them
    NSError *fetchError;
    NSArray *fetchedProducts = [context executeFetchRequest:fetch error:&fetchError];
    
    return fetchedProducts;
    
    
}

+(NSArray *)contactObjectWithMatchingPhoneNumebr:(NSPredicate *)phoneumber{
   
  //  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   // NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *mainMOC =[appDelegate managedObjectContext];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = mainMOC;
    
    
   
    
    NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"Contacts" inManagedObjectContext:context];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity1];
    [fetch setPredicate:phoneumber];
    //... add sorts if you want them
    NSError *fetchError;
    NSArray *fetchedProducts = [context executeFetchRequest:fetch error:&fetchError];
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
    
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
   
    [mainMOC performBlock:^{
        NSError *error;
        if (![mainMOC save:&error])
        {
            NSLog(@"in mainMOC saved handle error");
            // handle error
        }
    }];
    
    return fetchedProducts;

}

+(NSArray *)contacobjectWithMatchingContacID:(NSPredicate*)contactID{
    
    
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
 //   NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *mainMOC =[appDelegate managedObjectContext];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = mainMOC;
    

    
    NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"Contacts" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity1];
    [fetch setPredicate:contactID];
    
    NSError *fetchError;
    NSArray *fetchedProducts = [context executeFetchRequest:fetch error:&fetchError];
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
    

    
    [mainMOC performBlock:^{
        NSError *error;
        if (![mainMOC save:&error])
        {
            NSLog(@"in mainMOC saved handle error");
            // handle error
        }
    }];
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
    
    
    return fetchedProducts;
    
}


+(NSArray *)chatMessageObjectWithMatchingMessageID:(NSPredicate *)messageID
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"ChatMessages" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity1];
    [fetch setPredicate:messageID];
    //... add sorts if you want them
    NSError *fetchError;
    NSArray *fetchedProducts = [context executeFetchRequest:fetch error:&fetchError];
    
    return fetchedProducts;
}

#pragma mark - Delete Data Base

//Delete address from DataBase
+(BOOL)deleteRowFromDataBaseWithTableName:(NSString*)tableName andKeys:(NSString *)keys
{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *mainMOC =[appDelegate managedObjectContext];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = [appDelegate managedObjectContext];
    
   
    
    [context performBlockAndWait:^{
        
        NSEntityDescription *entity1 = [NSEntityDescription entityForName:tableName inManagedObjectContext:context];
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:entity1];
        NSPredicate *pred = [NSPredicate predicateWithFormat:keys];
        [fetch setPredicate:pred];
        //... add sorts if you want them
        NSError *fetchError;
        NSError *error;
        NSArray *fetchedProducts = [context executeFetchRequest:fetch error:&fetchError];
        //    NSManagedObject *products = [fetchedProducts objectAtIndex:0];
        for (NSManagedObject *product in fetchedProducts) {
            [context deleteObject:product];
            // break;
        }
        
        
        if ([context save:&error]) {
            
            NSLog(@"deleted");
            // return YES;
        }
        else {
            // return NO;
        }
        
        
        
        
                [mainMOC performBlock:^{
                    NSError *error;
                    if (![mainMOC save:&error])
                    {
                        NSLog(@"in mainMOC saved handle error");
                        // handle error
                    }
                }];
        
        
        
       // NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
       // [nc addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
        

        
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
      
        
    }];
    
    return YES;
    
}




//+ (BOOL)deleteRowFromDataBaseWithTableName:(NSString*)tableName andKeys:(NSString *)keys
//{
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *context = [appDelegate managedObjectContext];
//    
////   //added
////    NSManagedObjectContext *context1 = [appDelegate managedObjectContext];
////    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
////    context.parentContext = context1;
//    
//    
//    NSEntityDescription *entity1 = [NSEntityDescription entityForName:tableName inManagedObjectContext:context];
//    
//    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
//    [fetch setEntity:entity1];
//    NSPredicate *pred = [NSPredicate predicateWithFormat:keys];
//    [fetch setPredicate:pred];
//    //... add sorts if you want them
//    NSError *fetchError;
//    NSError *error;
//    NSArray *fetchedProducts = [context executeFetchRequest:fetch error:&fetchError];
////    NSManagedObject *products = [fetchedProducts objectAtIndex:0];
//    for (NSManagedObject *product in fetchedProducts) {
//        [context deleteObject:product];
//       // break;
//    }
//    
//    if ([context save:&error]) {
//    
//        return YES;
//    }
//    else {
//        return NO;
//    }
//    return NO;
//    
//    
////    [context1 performBlock:^{
////        NSError *error;
////        if (![context1 save:&error])
////        {
////            
////            NSLog(@"in mainMOC saved handle error");
////            // handle error
////        }
////        
////    }];
////
////    return NO;
//
//
//}



+(void)deleteAllRowsFromDataBaseTableWithTableName: (NSString *)tableName
{
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *mainMOC =[appDelegate managedObjectContext];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = mainMOC;
    
   
    
    
    [context performBlockAndWait:^{
        
        
        NSEntityDescription *entity1=[NSEntityDescription entityForName:tableName inManagedObjectContext:context];
        NSFetchRequest *fetch=[[NSFetchRequest alloc]init];
        
        [fetch setEntity:entity1];
        NSError *fetchError;
        NSError *error;
        NSArray *fetchedProducts=[context executeFetchRequest:fetch error:&fetchError];
        
        for (NSManagedObject *product in fetchedProducts) {
            [context deleteObject:product];
        }
        [context save:&error];
        
        
        
        
               [mainMOC performBlock:^{
                   NSError *error;
                   if (![mainMOC save:&error])
                   {
                       NSLog(@"in mainMOC saved handle error");
                       // handle error
                   }
               }];
        
        
      //  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
       // [nc addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
    
        
       // [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
       
        
    }];
    
}




//+ (void)deleteAllRowsFromDataBaseTableWithTableName: (NSString *)tableName
//{
// 
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *context= [appDelegate managedObjectContext];
//    
//    NSEntityDescription *entity1=[NSEntityDescription entityForName:tableName inManagedObjectContext:context];
//    NSFetchRequest *fetch=[[NSFetchRequest alloc]init];
//    
//    [fetch setEntity:entity1];
//    NSError *fetchError;
//    NSError *error;
//    NSArray *fetchedProducts=[context executeFetchRequest:fetch error:&fetchError];
//    
//    for (NSManagedObject *product in fetchedProducts) {
//        [context deleteObject:product];
//    }
//    [context save:&error];
//    
//}
//

- (void)mergeChanges:(NSNotification *)notification {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *mainThreadMOC = [appDelegate managedObjectContext];
    
    //this tells the main thread moc to run on the main thread, and merge in the changes there
    [mainThreadMOC performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
    
    
}

//+(void)updateContacDatabase:(NSDictionary *)dictionary contac:(Contacts*)entity{
//    
//
//    
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *mainMOC =[appDelegate managedObjectContext];
//    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    context.parentContext = mainMOC;
//    
//    
//    [context performBlockAndWait:^{
//
//            [entity setFirstName:[dictionary objectForKey:@"firstName"]];
//            [entity setLastName:[dictionary objectForKey:@"lastName"]];
//            [entity setFullName:[dictionary objectForKey:@"fullName"]];
//            [entity setProfilePic:[dictionary objectForKey:@"profilePic"]];
//            [entity setSupNumber:[dictionary objectForKey:@"supNumber"]];
//            [entity setAlternateNumbers:[dictionary objectForKey:@"alternateNumbers"]];
//            [entity setStatus:[dictionary objectForKey:@"status"]];
//            [entity setContactID:[dictionary objectForKey:@"contactID"]];
//            [entity setModificationDate:[dictionary objectForKey:@"modificationDate"]];
//            [entity setArrayOfalternateNumbers:[dictionary objectForKey:@"arrayOfalternateNumbers"]];
//
//    
//        NSError *error;
//        BOOL isSaved = [context save:&error];
//        if (isSaved)
//        {
//            NSLog(@"data is saved");
//        }
//        else
//        {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Saving failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertView show];
//        }
//        
//        
//        
//        [mainMOC performBlock:^{
//            NSError *error;
//            if (![mainMOC save:&error])
//            {
//                NSLog(@"in mainMOC saved handle error");
//                // handle error
//            }
//        }];
//      //  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//       // [nc addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
//        
//        
//        //[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
//
//        
//    
//    }];
//    
//}

//+(void)updateFavDatabase:(NSDictionary *)dictionary fav:(Favorites*)entity{
//    
//    
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *mainMOC =[appDelegate managedObjectContext];
//    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    context.parentContext = mainMOC;
//    
//    
//    [context performBlockAndWait:^{
//       
//        
//        [entity setStatus:[dictionary objectForKey:@"status"]];
//        [entity setImage:[dictionary objectForKey:@"image"]];
//        [entity setSupNumber:[dictionary objectForKey:@"supNumber"]];
//        [entity setFullName:[dictionary objectForKey:@"fullName"]];
//        
//         NSError *error;
//        BOOL isSaved = [context save:&error];
//        if (isSaved)
//        {
//            NSLog(@"data is saved");
//        }
//        else
//        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Saving failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertView show];
//        }
//        
//        
//        
//        [mainMOC performBlock:^{
//            NSError *error;
//            if (![mainMOC save:&error])
//            {
//                NSLog(@"in mainMOC saved handle error");
//                // handle error
//            }
//        }];
//      //  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//       // [nc addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
//        
//
//     //  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
//
//        
//    }];
//    
//    
//    
//    
//}



@end
