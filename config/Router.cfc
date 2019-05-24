component{

	function configure(){
		setFullRewrites( true );

		resources( "registration" );
		resources( "sessions" );
		resources( "content" );

		route( ":handler/:action?" ).end();
	}

}