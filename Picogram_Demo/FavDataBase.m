//
//  FavDataBase.m
//  Sup
//
//  Created by Rahul Sharma on 7/7/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "FavDataBase.h"
#import "MacroFile.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "AppDelegate.h"


static FavDataBase *favClass = nil;

@implementation FavDataBase
@synthesize favPropertydict;



+(instancetype)sharedInstance{
    
    
    if (!favClass) {
        static dispatch_once_t tocken;
        dispatch_once(&tocken, ^{
             favClass = [[FavDataBase alloc]init];
        });
    }
    
    return favClass;
}


//get databaseObject
-(CBLDatabase*)getDataBaseObject{
    
    AppDelegate *appdeleget = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    CBLManager* bgMgr = [[appdeleget manager] copy];
    NSError *error;
    CBLDatabase* bgDB = [bgMgr databaseNamed:@"couchbasenew" error: &error];
    
    return bgDB;
}

-(void)getDocumentInfoForID:(NSString *)docID{
    
    docID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:favDBdocumentID]];
    
    CBLDatabase* bgDB = [self getDataBaseObject];
    CBLDocument *document = [bgDB documentWithID:docID];
    
    [self getDetailsForDocument:document];
    
}

-(NSDictionary *)getDetailsForDocument:(CBLDocument *) document {
    
    //NSError *Error;
    // NSLog(@"hello =%@",[document getRevisionHistory:&Error]);
    // return document.currentRevision.properties;
   
    
    favPropertydict = document.properties;
   // NSLog(@"kkk =%@",favPropertydict);
    
    return document.properties;
}


//get data From db
-(NSArray *)getDataFavDataFromDB{
    
    if (favPropertydict ==nil) {
        [self getDocumentInfoForID:@""];
    }
    
    
    
//   NSString *docID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:favDBdocumentID]];
//    
//    CBLDatabase* bgDB = [self getDataBaseObject];
//    CBLDocument *document = [bgDB documentWithID:docID];
//    
//    NSDictionary *dict = [self getDetailsForDocument:document];
    
    return [favPropertydict objectForKey:@"messages"];
}


//update document
-(void)saveDataInDocument:(NSString *)documentID withMessages:(NSMutableArray *)messages{
    
    
    static CouchbaseEvents *cbEvent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cbEvent = [[CouchbaseEvents alloc] init];
    });
    
    
    CBLDatabase* bgDB =[self getDataBaseObject];
    documentID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:favDBdocumentID]];
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:favPropertydict];
    [dict setValue:[messages copy] forKey:@"messages"];
    favPropertydict = [dict copy];
    
    [cbEvent updateDocument:bgDB documentId:documentID withMessages:[messages copy]];
    
}


-(void)updateContacDatabase:(NSDictionary *)dict contacID:(NSString*)contcID{
    
    NSMutableDictionary *contactObj = [NSMutableDictionary new];
    
    NSArray *contacAlldata = [[NSArray alloc]initWithArray:[self getDataFavDataFromDB]];
    NSMutableArray *tempArr = [NSMutableArray new];
    [tempArr addObjectsFromArray:contacAlldata];
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"supNumber == %@",contcID];
    NSArray *contactsArray = [contacAlldata filteredArrayUsingPredicate:bPredicate];
    
    
    if (contactsArray.count>0) {
        
      NSDictionary *contactObj1 = [contactsArray firstObject];
        NSInteger indexOfdict = [contacAlldata indexOfObject:contactObj1];
        [contactObj setValue:[dict objectForKey:@"status"]  forKey:@"status"];
        [contactObj setValue:[dict objectForKey:@"image"]  forKey:@"image"];
        [contactObj setValue:[dict objectForKey:@"supNumber"]  forKey:@"supNumber"];
        [contactObj setValue:[dict objectForKey:@"fullName"]  forKey:@"fullName"];
        
        [tempArr replaceObjectAtIndex:indexOfdict withObject:[contactObj copy]];
    
        [self saveDataInDocument:@"" withMessages:[tempArr copy]];
        
    }
    
    
    
}


-(void)deleteObjectFromDB:(NSDictionary *)dict favID:(NSString *)favID{
    
    NSArray *contacAlldata = [[NSArray alloc]initWithArray:[self getDataFavDataFromDB]];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"supNumber == %@",favID];
    NSArray *contactsArray = [contacAlldata filteredArrayUsingPredicate:bPredicate];
    
    if (contactsArray.count>0) {
        dict = [contactsArray firstObject];
    }
    
    NSInteger indexOfdict = [contacAlldata indexOfObject:dict];
   // NSLog(@"index =%ld",(long)indexOfdict);
    
    if (contacAlldata.count >indexOfdict) {
        
        NSMutableArray *tempArr = [[NSMutableArray alloc]initWithArray:contacAlldata];
        [tempArr removeObjectAtIndex:indexOfdict];
        [self saveDataInDocument:@"" withMessages:[tempArr copy]];
    }
    
    
}


@end
