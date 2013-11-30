#import "YapCollectionsDatabaseFilteredView.h"
#import "YapCollectionsDatabaseFilteredViewPrivate.h"
#import "YapAbstractDatabaseExtensionPrivate.h"
#import "YapDatabaseLogging.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * Define log level for this file: OFF, ERROR, WARN, INFO, VERBOSE
 * See YapDatabaseLogging.h for more information.
**/
#if DEBUG
  static const int ydbLogLevel = YDB_LOG_LEVEL_WARN;
#else
  static const int ydbLogLevel = YDB_LOG_LEVEL_WARN;
#endif


@implementation YapCollectionsDatabaseFilteredView

#pragma mark Invalid

- (id)initWithGroupingBlock:(YapCollectionsDatabaseViewGroupingBlock)inGroupingBlock
          groupingBlockType:(YapCollectionsDatabaseViewBlockType)inGroupingBlockType
               sortingBlock:(YapCollectionsDatabaseViewSortingBlock)inSortingBlock
           sortingBlockType:(YapCollectionsDatabaseViewBlockType)inSortingBlockType
{
	return [self initWithGroupingBlock:inGroupingBlock
	                 groupingBlockType:inGroupingBlockType
	                      sortingBlock:inSortingBlock
	                  sortingBlockType:inSortingBlockType
	                           version:0
	                           options:nil];
}

- (id)initWithGroupingBlock:(YapCollectionsDatabaseViewGroupingBlock)inGroupingBlock
          groupingBlockType:(YapCollectionsDatabaseViewBlockType)inGroupingBlockType
               sortingBlock:(YapCollectionsDatabaseViewSortingBlock)inSortingBlock
           sortingBlockType:(YapCollectionsDatabaseViewBlockType)inSortingBlockType
                    version:(int)inVersion
{
	return [self initWithGroupingBlock:inGroupingBlock
	                 groupingBlockType:inGroupingBlockType
	                      sortingBlock:inSortingBlock
	                  sortingBlockType:inSortingBlockType
	                           version:inVersion
	                           options:nil];
}

- (id)initWithGroupingBlock:(YapCollectionsDatabaseViewGroupingBlock)inGroupingBlock
          groupingBlockType:(YapCollectionsDatabaseViewBlockType)inGroupingBlockType
               sortingBlock:(YapCollectionsDatabaseViewSortingBlock)inSortingBlock
           sortingBlockType:(YapCollectionsDatabaseViewBlockType)inSortingBlockType
                    version:(int)inVersion
                    options:(YapCollectionsDatabaseViewOptions *)inOptions
{
	// Todo: Throw exception
	return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Instance
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@synthesize parentViewName = parentViewName;

@synthesize filteringBlock = filteringBlock;
@synthesize filteringBlockType = filteringBlockType;

@synthesize tag = tag;

- (id)initWithParentViewName:(NSString *)inParentViewName
              filteringBlock:(YapCollectionsDatabaseViewFilteringBlock)inFilteringBlock
          filteringBlockType:(YapCollectionsDatabaseViewBlockType)inFilteringBlockType
{
	return [self initWithParentViewName:inParentViewName
	                     filteringBlock:inFilteringBlock
	                 filteringBlockType:inFilteringBlockType
	                                tag:nil
	                            options:nil];
}

- (id)initWithParentViewName:(NSString *)inParentViewName
              filteringBlock:(YapCollectionsDatabaseViewFilteringBlock)inFilteringBlock
          filteringBlockType:(YapCollectionsDatabaseViewBlockType)inFilteringBlockType
                         tag:(NSString *)inTag
{
	return [self initWithParentViewName:inParentViewName
	                     filteringBlock:inFilteringBlock
	                 filteringBlockType:inFilteringBlockType
	                                tag:inTag
	                            options:nil];
}

- (id)initWithParentViewName:(NSString *)inParentViewName
              filteringBlock:(YapCollectionsDatabaseViewFilteringBlock)inFilteringBlock
          filteringBlockType:(YapCollectionsDatabaseViewBlockType)inFilteringBlockType
                         tag:(NSString *)inTag
                     options:(YapCollectionsDatabaseViewOptions *)inOptions
{
	NSAssert(inParentViewName != nil, @"Invalid parentViewName");
	NSAssert(inFilteringBlock != NULL, @"Invalid filteringBlock");
	
	NSAssert(inFilteringBlockType == YapCollectionsDatabaseViewBlockTypeWithKey ||
	         inFilteringBlockType == YapCollectionsDatabaseViewBlockTypeWithObject ||
	         inFilteringBlockType == YapCollectionsDatabaseViewBlockTypeWithMetadata ||
	         inFilteringBlockType == YapCollectionsDatabaseViewBlockTypeWithRow,
	         @"Invalid filteringBlockType");
	
	if ((self = [super init]))
	{
		parentViewName = [inParentViewName copy];
		
		filteringBlock = inFilteringBlock;
		filteringBlockType = inFilteringBlockType;
		
		version = 0; // version isn't used
		
		if (inTag)
			tag = [inTag copy];
		else
			tag = @"";
		
		options = inOptions ? [inOptions copy] : [[YapCollectionsDatabaseViewOptions alloc] init];
	}
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Registration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)supportsDatabase:(YapAbstractDatabase *)database withRegisteredExtensions:(NSDictionary *)registeredExtensions
{
	if (![super supportsDatabase:database withRegisteredExtensions:registeredExtensions])
		return NO;
	
	YapAbstractDatabaseExtension *ext = [registeredExtensions objectForKey:parentViewName];
	if (ext == nil)
	{
		YDBLogWarn(@"The specified parentViewName (%@) isn't registered", parentViewName);
		return NO;
	}
	
	if (![ext isKindOfClass:[YapCollectionsDatabaseView class]])
	{
		YDBLogWarn(@"The specified parentViewName (%@) isn't a view", parentViewName);
		return NO;
	}
	
	return YES;
}

- (NSSet *)dependencies
{
	return [NSSet setWithObject:parentViewName];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connections
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (YapAbstractDatabaseExtensionConnection *)newConnection:(YapAbstractDatabaseConnection *)databaseConnection
{
	__unsafe_unretained YapCollectionsDatabaseConnection *dbConnection =
	  (YapCollectionsDatabaseConnection *)databaseConnection;
	
	return [[YapCollectionsDatabaseFilteredViewConnection alloc] initWithView:self databaseConnection:dbConnection];
}

@end