# Taller Construyendo un API con BDD

En este taller construiremos un API con BDD

## Clonar Repositorio

```bash
git clone git@github.com:Ortus-Solutions/workshop-bdd-api-cms.git
```

Revisemos lo que trae este repositorio.

## Empezar Base de Datos MySQL

```
docker-compose up
```

Ahora ocupa tu herramiento de SQL favorita y revisa la base de datos con las siguientes credenciales:

```
servidor: 127.0.0.1
puerto: 3307
base de datos: cms
usuario: cms
password: coldbox
```

Tu base de datos estara creada y populada.

> Tip: Puedes encontrar el dump de la base de datos en `/workbench/db/cms.sql`. Tambien podras encontrar en el `workbench` las migraciones que se ocuparon para la base de datos y el "Seeder" que populo la base de datos.


## Instalar Dependencias Globales

Ahora comenzemos el CLI CommandBox e instalemos las dependencias globales para poder ocupar variables de entorno y configuraciones de lenguage CFML portatil (cfconfig - https://cfconfig.ortusbooks.com/):
```
# Comienza el CLI
box
# Instala dependencias globales
install commandbox-dotenv,commandbox-cfconfig
```

## Creaer Nuestra Aplicacion REST

Ahora crearemos la aplicacion REST ocupando CommandBox.  Este comando creara una aplicacion REST configurada para ti con un `Response` object y un `BaseHandler` para uniformidad y manipulacion de datos. Tambien te instalara las siguientes dependencias:

* `coldbox` - Tu framework HMVC
* `testbox` - Tu libreria para hacer BDD
* `modules/cbSwagger` - Soporte de Swagger para tu aplicacion
* `modules/relax` - Nuestro module para documentar y probar APIs

```
coldbox create app name=“cms” skeleton=“rest”
```

update .gitignore again, due to overrides

    * .env
    * Build/**

## Crear Variables de Entorno

Create a `.env` according to the `.env.template` update as needed.

```bash
#Environment
ENVIRONMENT=development 

# DB
DB_HOST=127.0.0.1
DB_PORT=3307
DB_DATABASE=cms
DB_USER=cms
DB_PASSWORD=coldbox
```

Show cfconfig. Engine settings

## Empezar Servidor

Empezaremos la aplicacion en un puerto especifico para que podamos compartir URIs.

```bash
server start port=42518
```

> Tip: `server log --follow` podran ver los logs del servidor y seguirlos si es necesario. Tambien mensajes de `console` se mostraran aca.


Add to CommandBox tests

```sh
testbox run "http://localhost:42518/tests/runner.cfm"
```

```sh
package set testbox.runner="http://localhost:42518/tests/runner.cfm"
testbox run
```

## Instalar Modulos de Desarollo

  * `route-visualizer` : Visualizador de rutas (https://www.forgebox.io/view/route-visualizer)
  * `bcrypt` - Para poder encryptar contraseñas (https://www.forgebox.io/view/BCrypt)
  * `jwt` - Para poder ocupar Json web tokens (https://www.forgebox.io/view/jwt)
  * `mementifier` - Para poder convertir objectos en representaciones nativas (arrays/structs) (https://www.forgebox.io/view/mementifier)

```bash
install route-visualizer,bcrypt,mementifier,jwt
coldbox reinit
```

## Agregar Datasource

Abre `Application.cfc`  para agregar el datasource para tu aplicacion que fue creado por el `.cfconfig.json`

```java
// App datasource
this.datasource = "cms";
```

Ahora hagamos lo mismo en el tests: `/tests/Application.cfc` y agregemos una funcion para que limpie la aplicacion cada vez que corramos nuestras pruebas.

```java
// App datasource
this.datasource = "cms";

public void function onRequestEnd() { 
    structDelete( application, "cbController" );
    structDelete( application, "wirebox" );
}
```

## La Base de Pruebas

```java
component extends="coldbox.system.testing.BaseTestCase" appMapping="/root"{

    this.loadColdBox    = true;
    this.unloadColdBox  = false;

    /**
     * Run Before all tests
     */
    function beforeAll() {
        super.beforeAll();
        // Wire up this object
        application.wirebox.autowire( this );
    }

    /**
     * This function is tagged as an around each handler.  All the integration tests we build
     * will be automatically rolledbacked
     * 
     * @aroundEach
     */
    function wrapInTransaction( spec ) {
        transaction action="begin" {
            try {
                arguments.spec.body();
            } catch ( any e ){
                rethrow;
            } finally {
                transaction action="rollback";
            }
        }
    }

}
```

## Registracion

Ahora concentremonos en la registracion de usuarios.  La historia que ocuparemos sera la siguiente:

```java
story( "Quiero poder registrar usuarios en mi sistema" );
```

Lo primero es que vamos a representar un usuario de acuerdo a nuestros requisitos de usuario:

### User.cfc

* id
* name
* email
* username
* password
* createdDate:date
* modifiedDate:date

Crearemos el modelo, un test basico y luego nos vamos a los requisitos:

```bash
coldbox create model name="User"  properties="id,name,email,username,password,createdDate:date,modifiedDate:date"
```

Ahora, abramos el archivo y agreguemos inicializacion para las fechas, un metodo de utilidad para saber si el modelo es nuevo o viene de la base de datos `isLoaded()`, e instrucciones para el `mementifier` para saber como convertir este modelo a una represenacion nativa para Json.

```java
/**
* I am a new Model Object
*/
component accessors="true"{
	
	// Properties
	property name="id"           type="string";
	property name="name"         type="string";
	property name="email"        type="string";
	property name="username"     type="string";
	property name="password"     type="string";
	property name="createdDate"  type="date";
	property name="modifiedDate" type="date";
	
    this.memento = {
		defaultIncludes = [ "id", "name", "email", "username", "createdDate", "modifiedDate" ],
		neverInclude = [ "password" ]
	};

	/**
	 * Constructor
	 */
	User function init(){

		variables.createdDate = now();
		variables.modifiedDate = now();
		
		return this;
	}

	boolean function isLoaded(){
		return ( !isNull( variables.id ) && len( variables.id ) );
	}

}
```

Ahora abre la prueba: `/tests/specs/unit/UserTest.cfc`:

```java
describe( "Usuario", function(){
			
    it( "puede ser creado", function(){
        expect( model ).toBeComponent();
    });

});
```

Corre tus tests!

### BDD e Integración

Ahora que tenemos el modelo empezaremos por la integracion y requisitos.  Con la prueba BDD hecha, entonces empezaremos a construir el requisito. Crearemos un controlador llamado `registration` que tendra un solo metodo `create()` el cual se llamara desde el API ocupando un `POST`:

```bash
coldbox create handler name="registration" actions="create"
```

Este comando creara la prueba BDD tambien bajo: `/tests/specs/integration/registrationTest.cfc` el cual lo rellenaremos:

```java
story( "Quiero registrar usuarios en mi sistema de cms", function(){

    beforeEach(function( currentSpec ){
        // Setup as a new ColdBox request for this suite, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
        setup();
    });

    given( "datos validos y mi usuario esta disponible", function(){
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
```

### Controlador

Ahora terminemos el controlador con esta funcionalidad:

```java
property name="userService"	inject="UserService";
		
	/**
	 * create
	 */
	function create( event, rc, prc ){
		prc.oUser = populateModel( "User" );
		userService.create( prc.oUser );
		
		prc.response.setData( prc.oUser.getMemento() );
	}
```

Si tienes el tiempo agrega los siguientes pasos:

```java
given( "datos invalidos", function(){
    then( "recibire un error y un mensaje", function(){

    });
} );
given( "datos validos pero un usuario ya en uso", function(){
    then( "recibire un error y un mensaje que el usuario ya esta registrado", function(){

    });
} );
```

### Rutas

Agreguemos la ruta para la registracion como un ColdBox URL resource: `config/Router.cfc`. Aca puedes ver toda la informacion sobre rutas resourceful: https://coldbox.ortusbooks.com/the-basics/routing/routing-dsl/resourceful-routes

```bash
resources( "registration" );
```

Visualizala en el route visualizer.

### UserService.cfc

Ahora crearemos el servicio que nos ayudara a soportar los requisitos de registracion:

```bash
coldbox create model name="UserService" persistence="singleton" methods="create"
```

Abre la prueba y chequemos que podamos crear el servicio:

```java
describe( "UserService", function(){
    it( "puede ser creado", function(){
        expect( model ).toBeComponent();
    });
});
```
Recuerda que ocuparemos BDD y pruebas de integracion.  Todos los metodos que agregaremos aca seran probados por medio de integracion y no por medio de "unit testing".

```java
/**
* I am a new Model Object
*/
component singleton accessors="true"{
	
	// Properties
	property name="bcrypt" inject="@BCrypt";

	/**
	 * Constructor
	 */
	UserService function init(){
		
		return this;
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
```

Ahora vamonos a nuestro console `testbox run` o runner de pruebas: http://127.0.0.1:42518/tests/runner.cfm. Y comprobemos que nuestro requisito esta completo.  Si esta completo y tenemos luz verde, pasemos al siguiente paso.

## Autenticacion

Ahora nos enfocaremos en creaer la autenticacion de nuestro servicio.  Crearemos esto basada en la siguiente historia de requisito:

```java
story( "Quiero poder autenticar un usuario ocupando username/password y recibir un token JWT que expiren cada hora" )
```

### BDD e Integracion

Para esto ocuparemos el module `jwt` el cual pueden encontrar la informacion aca: https://www.forgebox.io/view/jwt

```bash
coldbox create handler name="sessions" actions="create"
```

Ahora abramos la prueba BDD: `/tests/specs/integration/sessionsTest.cfc` y modifiquemsla para que tenga dos escenarios:

```java
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
```

Corre tus pruebas y empezemos la implementacion.

### Rutas

Agreguemos la ruta para la registracion como un ColdBox URL resource: `config/Router.cfc`. Aca puedes ver toda la informacion sobre rutas resourceful: https://coldbox.ortusbooks.com/the-basics/routing/routing-dsl/resourceful-routes

```bash
resources( "sessions" );
```

Visualizala en el route visualizer.

### Controlador

Ahora terminemos el controlador con esta funcionalidad:

```java
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
```

### Modelos

Ahora tendremos que actualizar el modelo de `UserService` para poder soportar la funcionalidad de JWT tokens. Primero injectaremos el servicio de JWT del module `jwt` que instalamos y las siguientes funciones:

* `authenticate( username, password )` - Con la cual verificaremos que el usuario pueda log in
* `findByUsername( username )` - Con la cual devolveremos un record de usuario por username
* `generateAuth( username )` - Con la cual crearemos un JTW token packet con la informacion de usuario y expiracion.
* `decodeAuth( token )` - Con la cual obtendremos un packete de login nativo (struct) de acuerdo al token pasado.

Tambien haremos un `encodingKey` que sera nuestro key secreto de encripcion para nuestros tokens.  Este key fue creado en CommandBox CLI ocupando en el siguiente comando: `#createUUID`.

```java
    // JWT Service
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
```

Hemos terminado toda la funcionalidad, corre las pruebas y verifica que todo este en orden!  Ahora podemos registrar usuarios y podemos autenticarlos.  El siguiente paso sera crear el contenido y por ultimo protegeremos las rutas de contenido para solo usuarios con este token JWT.

## Ver Contenido

Empezaremos con historias para consumir el contenido que esta ya en la base de datos.

```java
story( "Quiero poder ver contenido con diferentes tipos de opciones" )
story( "Quiero poder ver un solo contenido por medio de su slug" )
```

Empezaremos modelando el contenido

### Content.cfc

* id
* slug
* title
* body
* isPublished:boolean
* publishedDate:date
* createdDate:date
* modifiedDate:date
* userId

Crearemos el modelo, un test basico y luego nos vamos a los requisitos:

```bash
coldbox create model name="Content" properties="id,slug,title,body,isPublished:boolean,publishedDate:date,createdDate:date,modifiedDate:date,FK_userID,user"
```

Ahora hagamos las siguientes modificaciones para soportar los siguientes requisitos:

* Fechas inicializadas en init
* Agregar un `isLoaded()` para verificar si el contenido es nuevo o viene de la base de datos
* Agregar un `getUser()` para poder devolver un objeto de usuario al cual este contenido pertenece

```java
/**
* I am a new Model Object
*/
component accessors="true"{

	// inject the user service
	property name="userService" inject="UserService";
	
	// Properties
	property name="id"            type="string";
	property name="slug"          type="string";
	property name="title"         type="string";
	property name="body"          type="string";
	property name="isPublished"   type="boolean";
	property name="publishedDate" type="date";
	property name="createdDate"   type="date";
	property name="modifiedDate"  type="date";
	property name="FK_userId" 		default="";
	property name="user";

	this.memento = {
		defaultIncludes = [ "*" ],
		defaultExcludes = [ "fk_UserID" ]
	};
	

	/**
	 * Constructor
	 */
	Content function init(){
		variables.createdDate 	= now();
		variables.modifiedDate 	= now();
		variables.FK_userID 	= "";
		return this;
	}

	boolean function isLoaded(){
		return ( !isNull( variables.id ) && len( variables.id ) );
	}

	User function getUser(){
		return userService.findById( variables.FK_userId );
	}
	

}
```

Ahora abre la prueba: `/tests/specs/unit/UserTest.cfc`:

```java
describe( "Usuario", function(){
			
    it( "puede ser creado", function(){
        expect( model ).toBeComponent();
    });

});
```

Corre tus tests!  

### BDD e Integración

Ahora que tenemos el modelo empezaremos por la integracion y requisitos.  Ademas de ver contenido agregaremos todas las funciones que necesitaremos:

* `index` : Ver todos los contenidos
* `create` : Crear un contenido
* `show` : Ver un solo contenido
* `update` : Editar un contenido
* `delete` : Borrar un contenido

```bash
coldbox create handler name="content" actions="index,create,show,update,delete"
```

Este comando creara la prueba BDD tambien bajo: `/tests/specs/integration/contentTest.cfc` el cual lo rellenaremos:

```java
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

```

### Rutas

Agreguemos la ruta para la registracion como un ColdBox URL resource: `config/Router.cfc`. Aca puedes ver toda la informacion sobre rutas resourceful: https://coldbox.ortusbooks.com/the-basics/routing/routing-dsl/resourceful-routes

```bash
resources( "content" );
```

Visualizala en el route visualizer.

### Controlador

Ahora terminemos el controlador con esta funcionalidad:

```java
/**
* I am a new handler
*/
component extends="BaseHandler"{
	
	property name="contentService" inject="contentService";
		
	/**
	* index
	*/
	function index( event, rc, prc ){
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
```

### Modelos

Ahora crearemos el servicio que nos ayudara a soportar los requisitos de contenido:

```bash
coldbox create model name="ContentService" persistence="singleton" methods="list,get"
```

Abre la prueba y chequemos que podamos crear el servicio:

```java
describe( "ContentService", function(){
    it( "puede ser creado", function(){
        expect( model ).toBeComponent();
    });
});
```

Recuerda que ocuparemos BDD y pruebas de integracion.  Todos los metodos que agregaremos aca seran probados por medio de integracion y no por medio de "unit testing".

```java
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
	array function list( orderBy="publishedDate" ){
		return queryExecute(
			"SELECT * FROM content ORDER BY ?",
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
```

Ahora vamonos a nuestro console `testbox run` o runner de pruebas: http://127.0.0.1:42518/tests/runner.cfm. Y comprobemos que nuestro requisito esta completo.  Si esta completo y tenemos luz verde y hemos acabado nuestro simple headless cms.

Para extra credito terminen las siguientes historias:

```java
story( "Quiero poder crear una pieza de contenido" )
story( "Quiero poder editar una pieza de contenido" )
story( "Quiero poder publicar una pieza de contenido" );
story( "Quiero poder poner en draft una pieza de contenido" ); 
story( "Quiero poder remover una pieza de contenido" ); 
story( "Quiero poder devolver contenido solamente publicado" )
story( "Quiero poder devolver contenido solamente en draft" )
```