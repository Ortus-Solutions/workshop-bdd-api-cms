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
component extends="tests.resources.BaseIntegrationSpec"{
	
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

		story( "Quiero registrar usuarios en mi sistema de cms", function(){

			beforeEach(function( currentSpec ){
				// Setup as a new ColdBox request for this suite, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			});

			given( "datos validos y mi usuario esta valido", function(){
				then( "puedo registrar un usuario", function(){
					// Pruebo que mi usuario no exista
					expect( 
						queryExecute( 
							"select * from users where username = :username", 
							{ username : "testadmin" }, 
							{ returntype = "array" } 
						) 
					).toBeEmpty();

					var event = post( "/registration", {
						"name"					= "Mi Nombre",
						"email"                	= "testadmin@ortussolutions.com",
						"username"             	= "testadmin",
						"password"             	= "testadmin"
					} );
					var response = event.getPrivateValue( "Response" );
					
					expect( response.getError() ).toBeFalse();
					expect( response.getData().id ).toBeNumeric();
					expect( response.getData().name ).toBe( "Mi Nombre" );
				});
			});
		});

	}

}
