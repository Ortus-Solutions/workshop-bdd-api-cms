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