/**
* I am a new Model Object
*/
component singleton accessors="true"{
	
	// Properties
	// To populate objects from data
    property name="populator" inject="wirebox:populator";
    // To create new User instances
    property name="wirebox" inject="wirebox";

	/**
	 * Constructor
	 */
	ContentService function init(){
		
		return this;
	}

	Content function new() provider="Content";
	
	/**
	* list
	*/
	array function list( orderBy="" ){
		if( !arguments.orderBy.len() ){
			arguments.orderBy = "publishedDate desc";
		}
		return queryExecute(
			"SELECT * FROM content
				  ORDER BY ?",
			[ arguments.orderBy ],
			{
				returnType : "array"
			}
		).map( ( content ) => {
			return populator.populateFromStruct(
                new(),
                content
            );
		} )
	}

	/**
	* findBySlug
	*/
	Content function findBySlug( required slug ){
		return populator.populateFromQuery(
            new(),
            queryExecute( "SELECT * FROM `content` WHERE `slug` = ?", [ arguments.slug ] )
        );
	}


}