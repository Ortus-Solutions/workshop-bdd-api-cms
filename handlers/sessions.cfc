/**
* I am a new handler
*/
component extends="BaseHandler"{

	property name="userService"	inject="UserService";
	 
	/**
	 * authenticate in the system
	 */
	function create( event, rc, prc ){
		event
			.paramValue( "username", "" )
			.paramValue( "password", "" );
		
		if( userService.authenticate( rc.username, rc.password ) ){
			prc.response
				.setData( 
					userService.generateAuth( rc.username )
				);
		} else {
			prc.response
				.setError( true )
				.addMessage( "Usuario o contraseña invalida! Intenta de nuevo!" );
		}
	}
	
}
