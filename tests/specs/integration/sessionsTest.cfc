/*******************************************************************************
*	Integration Test as BDD (CF10+ or Railo 4.1 Plus)
*
*	Extends the integration class: coldbox.system.testing.BaseTestCase
*
*	so you can test your ColdBox application headlessly. The 'appMapping' points by default to 
*	the '/root' mapping created in the test folder Application.cfc.  Please note that this 
*	Application.cfc must mimic the real one in your root, including ORM settings if needed.
*
*	The 'execute()' method is used to execute a ColdBox event, with the following arguments
*	* event : the name of the event
*	* private : if the event is private or not
*	* prePostExempt : if the event needs to be exempt of pre post interceptors
*	* eventArguments : The struct of args to pass to the event
*	* renderResults : Render back the results of the event
*******************************************************************************/
component extends="tests.resources.BaseIntegrationSpec" {
	
	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		// do your own stuff here
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/
	
	function run(){

		story( "Quiero poder autenticar un usuario ocupando username/password y recibir un token JWT que expiren cada hora", function(){

			beforeEach(function( currentSpec ){
				// Setup as a new ColdBox request for this suite, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			});

			
			given( "usuario y password validos", function(){
				then( "me autenticare y recibire mi token JWT que expira en 1 hora", function(){
					var event = post(
						route = "/sessions",
						params = {
							username = "Milkshake10",
							password = "test"
						}
					);
					var response = event.getPrivateValue( "Response" );
					expect( response.getError() ).toBeFalse( response.getMessages().toString() );
					expect( response.getData() ).toBeString();
					
					var decoded = getInstance( "UserService" ).decodeAuth( response.getData() );
					expect( decoded.id ).toBe( 10 );
					expect( decoded.expires ).toBe( dateAdd( "h", 1, decoded.created ) );
				});
			});

			given( "usuario o password invalidos", function(){
				then( "recibire un error y mensaje", function(){
					var event = post(
						route = "/sessions",
						params = {
							username = "invalido",
							password = "invalido"
						}
					);
					var response = event.getPrivateValue( "Response" );
					expect( response.getError() ).toBeTrue();
				});
			});
		
		});

	}

}
