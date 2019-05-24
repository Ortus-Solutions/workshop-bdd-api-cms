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
		reset();
		super.beforeAll();
		// do your own stuff here
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/
	
	function run(){

		story( "Quiero poder ver contenido con diferentes tipos de opciones", function(){

			beforeEach(function( currentSpec ){
				// Setup as a new ColdBox request for this suite, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			});

			it( "pude mostrar todas los contenidos en el sistema", function(){
				var event = get( route = "/content" );
				var response = event.getPrivateValue( "Response" );
				expect( response.getError() ).toBeFalse();
				expect( response.getData() ).toBeArray();
			});

			it( "mostrar un contenido por slug", function(){
				var testSlug = "Spoon-School-Staircase";
				var event = get( route = "/content/#testSlug#" );
				var response = event.getPrivateValue( "Response" );
				debug( response.getMessages() );
				expect( response.getError() ).toBeFalse();
				expect( response.getData() ).toBeStruct();
				expect( response.getData().slug ).toBe( testSlug );
			});

			xit( "crear un nuevo contenido", function(){
				var event = execute( event="content.create", renderResults=true );
				// expectations go here.
				expect( false ).toBeTrue();
			});

			xit( "editar un contenido", function(){
				var event = execute( event="content.update", renderResults=true );
				// expectations go here.
				expect( false ).toBeTrue();
			});

			xit( "puedo borrar un contenido", function(){
				var event = execute( event="content.delete", renderResults=true );
				// expectations go here.
				expect( false ).toBeTrue();
			});

		
		});

	}

}
