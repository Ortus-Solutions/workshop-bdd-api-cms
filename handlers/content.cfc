/**
* I am a new handler
*/
component extends="BaseHandler"{
	
	property name="contentService" inject="contentService";
		
	/**
	* index
	*/
	function index( event, rc, prc ){
		event.paramValue( "orderBy", "" );
		prc.response.setData(
			contentService.list()
				.map( ( item ) => { return item.getMemento(); } )
		);
	}

	/**
	* create
	*/
	function create( event, rc, prc ){
		event.setView( "content/create" );
	}

	/**
	* show
	*/
	function show( event, rc, prc ){
		event.paramValue( "id", "" );
		prc.response.setData(
			contentService.findBySlug( rc.id ).getMemento()
		);
	}

	/**
	* update
	*/
	function update( event, rc, prc ){
		event.setView( "content/update" );
	}

	/**
	* delete
	*/
	function delete( event, rc, prc ){
		event.setView( "content/delete" );
	}


	
}
