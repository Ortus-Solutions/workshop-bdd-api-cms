component{

	function configure(){
		setFullRewrites( true );

		resources( "registration" );
		resources( "sessions" );

		route( ":handler/:action?" ).end();
	}

}