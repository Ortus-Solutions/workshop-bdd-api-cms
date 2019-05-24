/**
* I am a new handler
*/
component extends="BaseHandler"{
	
	property name="userService"	inject="UserService";
		
	/**
	 * create
	 */
	function create( event, rc, prc ) {
		prc.oUser = populateModel( "User" );
		userService.create( prc.oUser );
		
		prc.response.setData( prc.oUser.getMemento() );
	}

}