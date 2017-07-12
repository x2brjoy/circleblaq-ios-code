//
//  CouchbaseEvents.m
//  CouchbaseDb
//
//  Created by Bhavuk Jain on 02/11/15.
//  Copyright (c) 2015 Bhavuk Jain. All rights reserved.
//

#import "CouchbaseEvents.h"
#import "ChatHelper.h"
#import "Database.h"
#import "StoreIDs+CoreDataClass.h"
#import "PicogramSocketIOWrapper.h"

@implementation CouchbaseEvents

-(BOOL)helloCBL {
    
//    NSString* docID = [self createDocument:CBObjects.sharedInstance.database];
    
//    [[CBObjects sharedInstance] startReplications];
//    
//    [self createOrderedByDateView];
//    
//    [self outputOrderedByDate];
    
//    CBLLiveQuery* liveQuery = [[[self getView] createQuery] asLiveQuery];
//    [liveQuery addObserver:self forKeyPath:@"rows" options:0 context:nil];
////    [liveQuery addObserver: self forKeyPath:@"rows" options:0 context: NULL];
//    [liveQuery start];
    
    return NO;
}

//- (void)observeValueForKeyPath: (NSString *)keyPath ofObject: (id)object change: (NSDictionary *)change context: (void *)context {
//    NSLog(@"Observe event received");
//}


// creates the Document
- (NSString *)createDocument: (CBLDatabase *)database {
    
    NSError *error;
    // create an object that contains data for the new document
    NSDictionary *myDictionary = @{@"name":@"Big Party",
                                   @"location":@"My House",
                                   };
//   Create an empty document
    CBLDocument *doc = [database createDocument];
    
    CBLModel *model = [CBLModel modelForDocument:doc];
    [model setType:@"person"];
    // Save the ID of the new document
    NSString *docID = doc.documentID;
    // Write the document to the database
    CBLRevision *newRevision = [doc putProperties: myDictionary error:&error];
    if (newRevision) {
       // NSLog(@"Document created and written to database, ID = %@", docID);
    }
    return docID;
}

-(NSString *)createDocument:(CBLDatabase *)database forReceivingUser:(NSString *)receivingUser andSendingUser:(NSString *)sendingUser withMessages:(NSArray *)messagesArray newMessageCount:(NSString*)newMessagecount {
    
    NSError *error;
    // create an object that contains data for the new document
    NSDictionary *myDictionary = @{@"messages":messagesArray,
                                   @"receivingUser":receivingUser,
                                   @"sendingUser":sendingUser};
    //   Create an empty document
    CBLDocument *doc = [database createDocument];
    // Save the ID of the new document
    CBLModel *model = [CBLModel modelForDocument:doc];
    [model setType:@"person"];
    NSString *docID = doc.documentID;
    // Write the document to the database
    CBLRevision *newRevision = [doc putProperties: myDictionary error:&error];
    if (newRevision) {
       // NSLog(@"Document created and written to database, ID = %@", docID);
    }
    
    
 
    
    //added when newChat Created so put at first position
    NSMutableArray *documentIDArr = [NSMutableArray new];
    [documentIDArr addObject:docID];
    [documentIDArr addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:StorDocIDArray]];
    [[NSUserDefaults standardUserDefaults]setObject:documentIDArr forKey:StorDocIDArray];
   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewChatCreated" object:nil];
   
  
    
    if (_delegate && [_delegate respondsToSelector:@selector(newDocumentCreatedID:)]) {
        [_delegate newDocumentCreatedID:docID];
    }
    
    return docID;
    
}

-(void)createDocForGroupChat:(CBLDatabase *)database sendingUser:(NSString *)sendingUser withMessages:(NSArray*)messagesArray groupID:(NSString *)groupID  groupName:(NSString*)groupName groupPic:(NSString*)groupPic groupMems:(NSArray *)groupArray groupAdmin:(NSString *)groupAdmin {
    
    NSError *error;
    NSDictionary *myDict = @{@"messages":messagesArray,
                             @"createdBy":sendingUser,
                             @"groupID":groupID ,
                             @"groupName":groupName,
                             @"groupPic":groupPic,
                             @"groupMembers":groupArray,
                             @"groupAdmin":groupAdmin,
                             @"isRemoveFromgp":@"NO",
                             };
    
    CBLDocument *doc = [database createDocument];
    CBLModel *model = [CBLModel modelForDocument:doc];
    [model setType:@"person"];
    NSString *docID = doc.documentID;
    CBLRevision *newRevision = [doc putProperties:myDict error:&error];
    
    if (newRevision) {
       //  NSLog(@"Document created for Group to database, ID = %@", docID);
    }
    
   
    [self getDocumentIDWith:groupID onDatabase:docID];
    
    //new group created so Reorder ListView
    NSMutableArray *documentIDArr = [NSMutableArray new];
    [documentIDArr addObject:docID];
    [documentIDArr addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:StorDocIDArray]];
    [[NSUserDefaults standardUserDefaults]setObject:documentIDArr forKey:StorDocIDArray];
    
//    NSString *post = [[NSUserDefaults standardUserDefaults]valueForKey:@"PostShare"];
//    if([post isEqualToString:@"Yes"])
//    {
////        [[NSNotificationCenter defaultCenter]postNotificationName:@"PostChatCreate" object:nil];
//        [[NSUserDefaults standardUserDefaults]setObject:@"No" forKey:@"PostShare"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//    }
//    else
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NewChatCreated" object:nil];
    
    
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
        [client getofflineDataForAnotherTimeAddtoGroup];
    }];
    
}

//creat cbView for query in group
-(void)getDocumentIDWith:(NSString*)groupID onDatabase:(NSString*)db{
   /*
    CBLView *productView = [db viewNamed:@"products"];
    [productView setMapBlock:^(NSDictionary *doc,CBLMapEmitBlock emit){
        
        emit(@"name",doc[@"groupID"]);
    }version:@"3"];
    
    
    CBLQuery *query = [[db viewNamed:@"products"] createQuery];
    [query setMapOnly:YES];
    
    CBLQueryEnumerator *result = [query run:nil];
    CBLQueryRow *filteredRow;
    
    for (CBLQueryRow *row in  result) {
        
        if ([[row value] isEqualToString:groupID]) {
            filteredRow = row;
            break;
        }
        NSString *productName = [row value];
        NSLog(@"value =%@",productName);
    }
    
    return filteredRow.documentID;
    */
    
   // [[NSUserDefaults standardUserDefaults]setObject:db forKey:groupID];
    
    NSDictionary *dict =@{@"groupid":groupID,
                          @"documentid":db,
                          };
    
    Database *database = [[Database alloc]init];
    [database makeDataBaseEntryforStoreID:dict];
    
    
//    NSString *docID;
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupid == %@",[NSString stringWithFormat:@"%@",groupID]];
//    NSArray *arr = [Database storeIdobjectWithMatchingStoreID:predicate];
//    if (arr.count>0) {
//        StoreID *store = [arr firstObject];
//        docID = store.documentid;
//         NSLog(@"id =%@",store.documentid);
//        NSLog(@"kk =%@",store.groupid);
//    }
   
    
}


-(BOOL)updateDoc:(CBLDatabase*)database documentId:(NSString*)documentId withmessage:(NSArray *)messagesArray{
    
    
    CBLDocument* getDocument = [database documentWithID: documentId];
    NSError* error;
    @synchronized(self) {
        if (![getDocument update: ^BOOL(CBLUnsavedRevision *newRev) {
            
            newRev[@"messages"] = messagesArray;
           // NSLog(@"updated =%@",newRev[@"messages"]);
            NSError *error1;
            [newRev save:&error1];
            return YES;
        }
        error: &error])
        {
            //[self handleError: error];
            NSLog(@"error occur");
        }
    }
    
    return YES;
    
    
}


-(void)deletDocument
{
//    CBLDatabase *database=[[CBLManager sharedInstance]databaseNamed:kCBLDataBaseName error:&error];
//    BOOL status= [database deleteDatabase:&error];
//    if(!status){
//        NSLog(@"error while deleting the database =%@",error.localizedDescription)
//    }
}
-(BOOL)updateDocumentForGroupData:(CBLDatabase *)database documentId:(NSString *)documentId data:(NSDictionary*)responseDict{
    //updateGroupData
    
    CBLDocument *getDocument = [database documentWithID:documentId];
    NSMutableDictionary *docContent = [getDocument.properties mutableCopy];
    
    if ([responseDict[@"groupType"] integerValue] ==5) {
        
        NSArray *members = docContent[@"groupMembers"];
        NSMutableArray *addmem = [[NSMutableArray alloc]initWithArray:members];
        [addmem addObject:responseDict[@"memNum"]];
        
        docContent[@"groupMembers"] = [addmem copy];
    }
    else if ([responseDict[@"groupType"] integerValue] == 2){
    
        docContent[@"groupPic"] = responseDict[@"profilePic"];
    }
    else if([responseDict[@"groupType"]integerValue] == 6){
        
        docContent[@"groupName"] = responseDict[@"groupName"];
    }
    else if ([responseDict[@"groupType"]integerValue] == 7){
        
        docContent[@"groupAdmin"] = responseDict[@"admin"];
    }
    else if ([responseDict[@"groupType"]integerValue] == 4){
        
        NSArray *members = docContent[@"groupMembers"];
        NSMutableArray *addmem = [[NSMutableArray alloc]initWithArray:members];
        for (int i =0;i<addmem.count; i++) {
            if ([addmem[i] isEqualToString:responseDict[@"memNum"]]) {
                [addmem removeObjectAtIndex:i];
            }
        }
        
        NSArray *members1 = docContent[@"groupAdmin"];
        NSMutableArray *addmem1 = [[NSMutableArray alloc]initWithArray:members1];
        for (int i =0;i<addmem1.count; i++) {
            if ([addmem1[i] isEqualToString:responseDict[@"memNum"]]) {
                [addmem1 removeObjectAtIndex:i];
            }
        }

        docContent[@"groupMembers"] = [addmem copy];
        docContent[@"groupAdmin"] = [addmem1 copy];
       
        //remove that person and block Msg
    NSString *userNum = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        if ([userNum isEqualToString:responseDict[@"memNum"]])
        {
            docContent[@"isRemoveFromgp"] = @"YES";
        }
        
    }
    else if ([responseDict[@"groupType"]integerValue] == 8)
    {
        
        NSArray *members = docContent[@"groupMembers"];
        NSMutableArray *addmem = [[NSMutableArray alloc]initWithArray:members];
        for (int i =0;i<addmem.count; i++) {
            if ([addmem[i] isEqualToString:responseDict[@"memNum"]]) {
                [addmem removeObjectAtIndex:i];
            }
        }
        
        NSArray *members1 = docContent[@"groupAdmin"];
        NSMutableArray *addmem1 = [[NSMutableArray alloc]initWithArray:members1];
        for (int i =0;i<addmem1.count; i++) {
            if ([addmem1[i] isEqualToString:responseDict[@"memNum"]]) {
                [addmem1 removeObjectAtIndex:i];
            }
        }
        
        docContent[@"groupMembers"] = [addmem copy];
        docContent[@"groupAdmin"] = [addmem1 copy];

        
        
        NSString *userNum = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        if ([userNum isEqualToString:responseDict[@"memNum"]])
        {
            docContent[@"isRemoveFromgp"] = @"YES";
        }

    }
    else if ([responseDict[@"groupType"]integerValue] == 16){
        
        docContent[@"groupMembers"] = [responseDict[@"groupMembers"] copy];
        docContent[@"groupPic"] = responseDict[@"profilePic"];
        docContent[@"groupName"] = responseDict[@"groupName"];
        docContent[@"groupAdmin"] = responseDict[@"admin"];
        docContent[@"isRemoveFromgp"] = @"NO";
        
    }
    
    
    NSError *error;
    @synchronized(self) {
        CBLSavedRevision *newRev = [getDocument putProperties:[docContent copy] error:&error];
        
        if (!newRev) {
           // NSLog(@"Cannot update document. Error message: %@", error.localizedDescription);
        }
    }
    
    return YES;
    
    
    
}

-(BOOL) updateDocument:(CBLDatabase *) database documentId:(NSString *) documentId withMessages:(NSArray *)messagesArray{
   
    
    // 1. Retrieve the document from the database
    CBLDocument *getDocument = [database documentWithID: documentId];
    
    // 2. Make a mutable copy of the properties from the document we just retrieved
    NSMutableDictionary *docContent = [getDocument.properties mutableCopy];
    // 3. Modify the document properties
    docContent[@"messages"] = messagesArray;
//    docContent[@"receivingUser"] = receivingUser;
//    docContent[@"sendingUser"] = sendingUser;
    // 4. Save the Document revision to the database
    NSError *error;
    @synchronized(self) {
        CBLSavedRevision *newRev = [getDocument putProperties:[docContent copy] error:&error];

        if (!newRev) {
          //  NSLog(@"Cannot update document. Error message: %@", error.localizedDescription);
        }
       
        
    }
    
//    NSError *error1;
//    [getDocument.newRevision saveAllowingConflict:&error1];
    // 5. Display the new revision of the document
    // NSLog(@"The new revision of the document contains: %@", newRev.properties);
    
    return YES;
    
    
   /*
    CBLDocument* getDocument = [database documentWithID: documentId];
    NSError* error;
    @synchronized(self) {
    if (![getDocument update: ^BOOL(CBLUnsavedRevision *newRev) {

        newRev[@"messages"] = messagesArray;
        
        return YES;
    }
    error: &error])
    {
        //[self handleError: error];
        NSLog(@"error occur");
    }
    }
    
    return YES;
    */
}



//- (CBLView *)getView {
//    CBLDatabase* database = [CBObjects sharedInstance].database;
//    return [database viewNamed:@"couchbasenew"];
//}

//- (void) createOrderedByDateView {
//    CBLView* orderedByDateView = [self getView];
//    [orderedByDateView setMapBlock: MAPBLOCK({
//        emit(doc[@"date"], nil);
//    }) version: @"1" /* Version of the mapper */ ];
//    NSLog(@"Ordered By Date View created.");
//}


//-(void) outputOrderedByDate {
////    OrderedByDateView *orderedByDateView = [[OrderedByDateView alloc] init];
//    CBLQuery *orderedByDateQuery = [[self getView] createQuery];
//    orderedByDateQuery.descending = YES;
//    orderedByDateQuery.startKey = @"2015";
//    orderedByDateQuery.endKey = @"2014";
//    orderedByDateQuery.limit = 20;
//    NSError *error;
//    CBLQueryEnumerator *result = [orderedByDateQuery run: &error];
//    if (!error) {
//        for (CBLQueryRow * row in result) {
////            Event *event = [repository get: row.documentID];
//            NSLog(@"Found party:%@", result.description);
//        }
//    } else {
//        NSLog(@"Error querying view %@", error.localizedDescription);
//    }
//}




@end
