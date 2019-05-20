/**
 * Task that seeds my database
 */
component{

    property name="packageService"  inject="PackageService";
    property name="JSONService"     inject="JSONService";

    function init(){
        variables.mockData = new mockdatacfc.MockData();
        // Bcrypt hash of the word "test"
        variables.bcryptTest = '$2a$12$FE2J7ZLWaI2rSqejAu/84uLy7qlSufQsDsSE1lNNKyA05GG30gr8C';
        return this;
    }

    function onDIComplete(){
        
        variables.cfmigrationsInfo = getCFMigrationsInfo();
        print.cyanLine( "Please wait, connecting to your database: #variables.cfmigrationsInfo.schema#" );

        var appSettings = getApplicationSettings();
        var dataSources = appSettings.datasources ?: {};
        dataSources[ "seeder" ] = variables.cfmigrationsInfo.connectionInfo
        
        // Update APP so we can use the datasource in our task
        application action='update' datasources=dataSources;
        application action='update' datasource='seeder';

        print.greenLine( "Connection success!" );
    }

    function run(){

        transaction{
            // Generate 10 users
            print.line().cyanLine( "Generating 10 mock users..." );
            var aMockUsers = mockData.mock(
                id = "autoincrement",
                name = "name",
                email = "email",
                username = "words",
                password = "oneof:#variables.bcryptTest#"
            );
            
            aMockusers
                .each( ( row, index ) => {
                    print.cyanLine( "   ==> Inserting mock user (#index#)" );
                    queryExecute( 
                        "INSERT INTO users ( id, name, email, username, password )
                            VALUES  ( ?, ?, ?, ?, ? )",
                        [ row.id, row.name, row.email, row.username & index, row.password ],
                        {
                            datasource : "seeder"
                        }
                    );
            } );

            print.line().cyanLine( "Generating 10 mock content objects..." );

            // Generate Content
            mockData.mock(
                id = "autoincrement",
                slug = "words:3",
                title = "sentence",
                body = "baconlorem",
                isPublished = "oneof:1:0",
                publishedDate = "datetime"
            ).each( ( row, index ) => {
                print.cyanLine( "   ==> Inserting mock content (#index#)" );
                queryExecute( 
                    "INSERT INTO content ( id, slug, title, body, isPublished, publishedDate, FK_userID )
                        VALUES  ( ?, ?, ?, ?, ?, ?, ? )",
                    [ 
                        row.id, 
                        replace( row.slug.trim(), " ", "-", "all" ),
                        row.title, 
                        row.body,
                        row.isPublished, 
                        { value = row.publishedDate, sqltype = "TIMESTAMP" },
                        aMockUsers[ randRange( 1, aMockUsers.len() ) ].id 
                    ],
                    {
                        datasource : "seeder"
                    }
                );
            } );
        }
        
        return;
    }

    /************************* PRIVATE METHODS ************************************/

    private function getCFMigrationsInfo() {
        var directory = getCWD();

        // Check and see if box.json exists
        if( ! packageService.isPackage( directory ) ) {
            return error( "File [#packageService.getDescriptorPath( directory )#] does not exist." );
        }

        var boxJSON = packageService.readPackageDescriptor( directory );

        if ( ! JSONService.check( boxJSON, "cfmigrations" ) ) {
            return error( "There is no `cfmigrations` key in your box.json. Please create one with the necessary values. See https://github.com/elpete/commandbox-migrations" );
        }

        return JSONService.show( boxJSON, "cfmigrations" );
    }

}