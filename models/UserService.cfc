/**
* I am a new Model Object
*/
component singleton accessors="true"{
	
	// Properties
	property name="bcrypt" 		inject="@BCrypt";
	property name="jwt"		 	inject="JWTService@jwt";

	/**
	 * Constructor
	 */
	UserService function init(){
		variables.encodingKey = "03CB417D-5CA6-4F67-808654E354FE2322";
		return this;
	}

	boolean function authenticate( required username, required password ){
		var qUser = findByUsername( arguments.username );
		try{ 
			return bcrypt.checkPassword( arguments.password, qUser.password );
		} catch( any e ){
			return false;
		}
	}

	query function findByUsername( required username ){
		return queryExecute(
			"SELECT * FROM users WHERE `username` = ?",
			[ arguments.username ]
		);
	}

	string function generateAuth( required username ){
		var rightNow = now();
		return jwt.encode(
			{
				"id" 		: findByUsername( arguments.username ).id,
				"created" : rightNow,
				"expires" : dateAdd( "h", 1, rightNow )
			},
			variables.encodingKey
		);
	}

	/**
	 * Decode the jwt auth token and retrieve a representation of in in struct format.
	 * If the token cannot be decoded or it is invalid, it will return a new return struct with an empty id.
	 *
	 * @token The jwt token to decode
	 * 
	 * @return { id:numeric, created:datetime, expires:datetime }
	 */
	struct function decodeAuth( required token ){
		if( jwt.verify( arguments.token, variables.encodingKey ) ){
			return jwt.decode( arguments.token, variables.encodingKey );
		} 
		return {
			"id" : "",
			"created" : now(),
			"expires" : now()
		};
	}

	/**
	* create
	*/
	function create( required user ){
		
		queryExecute( 
			"
				INSERT INTO `users` ( `name`, `email`, `username`, `password` )
				VALUES ( ?, ?, ?, ? )
			",
			[
				arguments.user.getName(),
				arguments.user.getEmail(), 
				arguments.user.getUsername(), 
				bcrypt.hashPassword( arguments.user.getPassword() )
			],
			{
				result : "local.result"
			}
		);

		user.setId( result.generatedKey );
    	return user;
	}


}