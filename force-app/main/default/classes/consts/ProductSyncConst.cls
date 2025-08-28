public class ProductSyncConst {
    public ProductSyncLog LOGS { get {return new ProductSyncLog();} }
    public final Integer SYNCHRONIZE_BATCH_SIZE { get {return 100;} }
    public final Integer DEACTIVATE_BATCH_SIZE { get {return 100;} }
    public final Integer RETRY_SYNCHRONIZATION_BATCH_SIZE { get {return 100;} }

    public class ProductSyncLog {
        public ProductSyncLogRetry RETRY { get {return new ProductSyncLogRetry();}}
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

    public class ProductSyncLogRetry {
        public final String CRON_EXPRESSION { get {return '0 0 0 * * ?';}}
        public final String JOB_NAME { get {return 'Product Sync Retry Job';}}
    }
}