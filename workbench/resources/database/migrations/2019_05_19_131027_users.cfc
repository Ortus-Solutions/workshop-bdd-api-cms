component {
    
    function up( schema, queryBuilder ) {
        schema.create( "users", function( table ) {
            table.increments( "id" );
            table.string( "name" );
            table.string( "email" ).unique();
            table.string( "username" ).unique();
            table.string( "password" );
            table.timestamp( "createdDate" );
            table.timestamp( "modifiedDate" );
        } );
    }

    function down( schema, queryBuilder ) {
        schema.drop( "users" );
    }

}
