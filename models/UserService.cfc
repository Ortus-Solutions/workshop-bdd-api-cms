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
		return jwt.encode(
			{
				id 		: findByUsername( arguments.username ).id,
				created : now(),
				expires : dateAdd( "h", 1, now() )
			},
			variables.encodingKey
		);
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