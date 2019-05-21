Migrations
* Add user
* Add content with foreign key 
* Add data via mock data and bcrypt
* Add to docker mysql compose to populate the DB.

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

### Controladores y BDD

Para esto ocuparemos el module `jwt` el cual pueden encontrar la informacion aca: https://www.forgebox.io/view/jwt

```bash
coldbox create handler name="sessions" actions="create"
```





* Build out auth feature with tokens. Secure will be later. 
* List published items order by date
    * /content?orderBy=publishedDate&isPublished=Boolean&userid=x - get
* List a content item by slug
    * /content/:slug - get
* Create a new item
    * /content/:slug - post
* Edit an item by slug
    * /content/:slug - put
* Publish an item by slug
    * /content/:slug/publish - post
* Unpublish an item by slug
    * /content/:slug/publish - delete