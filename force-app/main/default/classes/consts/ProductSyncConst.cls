public class ProductSyncConst {
    public ProductSyncLogConst LOGS { get {return new ProductSyncLogConst();} }

    public class ProductSyncLogConst {
        public ProductSyncLogEmail EMAIL { get {return new ProductSyncLogEmail();} }
        public ProductSyncLogStatus STATUS { get {return new ProductSyncLogStatus();} }
        public final Integer MAX_RETRY_ATTEMPTS { get {return 3;} }
    }
    public class ProductSyncLogStatus {
        public final String SUCCESS { get {return 'SUCCESS';} }
        public final String ERROR { get {return 'ERROR';} }
        public final String FAILED { get {return 'FAILED';} }
    }

    public class ProductSyncLogEmail {
        public final String RECEIVER_EMAIL { get {return 'wiktormalyska03@gmail.com';} }
    }
}