component {
    
    function up( schema, queryBuilder ) {
        schema.create( "content", function( table ){
            table.increments( "id" );
            table.string( "slug" ).unique();
            table.string( "title" );
            table.longText( "body" );
            table.boolean( "isPublished" ).default( false );
            table.datetime( "publishedDate" ).nullable();
            table.timestamp( "createdDate" );
            table.timestamp( "modifiedDate" );
            table.unsignedInteger( "FK_userID" );
            table.foreignKey( "FK_userID" ).references( "id" ).onTable( "users" );
            table.index( [ "isPublished", "publishedDate" ], "idx_publishing" );
        } );
    }

    function down( schema, queryBuilder ) {
        schema.drop( "content" );
    }

}
