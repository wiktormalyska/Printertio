public class OrganizationInfoController {
    public List<User> usersList { get; set; }
    public String selectedUserId { get; set; }
    public List<LicenseWrapper> licenseInfo { get; set; }
    public Integer apexClassCount { get; set; }
    public Integer visualforcePageCount { get; set; }
    
    // Constructor
    public OrganizationInfoController() {
        init();
    }
    
    public void init() {
        refreshUsers();
        loadLicenseInfo();
        loadMetadataInfo();
    }
    
    public void refreshUsers() {
        try {
            usersList = [SELECT Id, Username, Email, IsActive, UserType, LastLoginDate 
                         FROM User 
                         ORDER BY Username];
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Error loading users: ' + e.getMessage()));
        }
    }
    
    private void loadLicenseInfo() {
        licenseInfo = new List<LicenseWrapper>();
        
        try {
            // Get User License information
            Map<Id, UserLicense> userLicenses = new Map<Id, UserLicense>(
                [SELECT Id, Name, TotalLicenses, UsedLicenses 
                 FROM UserLicense]);
            
            // Get Permission Set License information
            List<PermissionSetLicense> psLicenses = 
                [SELECT Id, MasterLabel, TotalLicenses, UsedLicenses 
                 FROM PermissionSetLicense];
            
            // Add User License information
            for(UserLicense ul : userLicenses.values()) {
                licenseInfo.add(new LicenseWrapper(
                    ul.Name,
                    ul.TotalLicenses,
                    ul.UsedLicenses,
                    ul.TotalLicenses - ul.UsedLicenses
                ));
            }
            
            // Add Permission Set License information
            for(PermissionSetLicense psl : psLicenses) {
                licenseInfo.add(new LicenseWrapper(
                    'PSL: ' + psl.MasterLabel,
                    psl.TotalLicenses,
                    psl.UsedLicenses,
                    psl.TotalLicenses - psl.UsedLicenses
                ));
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.WARNING, 'Error loading license info: ' + e.getMessage()));
        }
    }
    
    private void loadMetadataInfo() {
        try {
            // Count Apex Classes
            apexClassCount = [SELECT COUNT() FROM ApexClass];
            
            // Count Visualforce Pages
            visualforcePageCount = [SELECT COUNT() FROM ApexPage];
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.WARNING, 'Error loading metadata info: ' + e.getMessage()));
        }
    }

    public void deleteUser() {
        if (String.isBlank(selectedUserId)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'No user was selected.'));
            return;
        }
        
        try {
            User u = [SELECT Id, IsActive FROM User WHERE Id = :selectedUserId LIMIT 1];
            u.IsActive = false;
            update u;
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.CONFIRM, 'User has been deactivated successfully.'));
                
            // Refresh the user list
            refreshUsers();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Error deactivating user: ' + e.getMessage()));
        }
    }
    
    // Wrapper class for license information
    public class LicenseWrapper {
        public String name { get; set; }
        public Integer total { get; set; }
        public Integer used { get; set; }
        public Integer available { get; set; }
        
        public LicenseWrapper(String name, Integer total, Integer used, Integer available) {
            this.name = name;
            this.total = total;
            this.used = used;
            this.available = available;
        }
    }

    public List<MetadataWrapper> getMetadataItems() {
        List<MetadataWrapper> items = new List<MetadataWrapper>();
        items.add(new MetadataWrapper('Apex Classes', apexClassCount));
        items.add(new MetadataWrapper('Visualforce Pages', visualforcePageCount));
        return items;
    }

    // Inner class for metadata items
    public class MetadataWrapper {
        public String name { get; set; }
        public Integer count { get; set; }
        
        public MetadataWrapper(String name, Integer count) {
            this.name = name;
            this.count = count;
        }
    }

    public String sessionId { 
        get { 
            return UserInfo.getSessionId(); 
        } 
    }
}