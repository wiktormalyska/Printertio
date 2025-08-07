public class OrderConst {
    public final Status STATUS { get { return new Status(); } }

    public class Status {
        public final String DRAFT = 'Draft';
        public final String ACTIVATED = 'Activated';
    }
}