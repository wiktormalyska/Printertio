global class OpportunityTerritoryAssignmentFilter implements TerritoryMgmt.OpportunityTerritory2AssignmentFilter {
    global OpportunityTerritoryAssignmentFilter() {}

    global Map<Id,Id> getOpportunityTerritory2Assignments(List<Id> opportunityIds) {
        Map<Id, Id> OppIdTerritoryIdResult = new Map<Id, Id>();

        // Get the active territory model Id
        Id activeModelId = getActiveModelId();

        if(activeModelId != null){
            List<Opportunity> opportunities =
            [Select Id, AccountId, Territory2Id from Opportunity where Id IN :opportunityIds];
            Set<Id> accountIds = new Set<Id>();
            // Create set of parent accountIds
            for(Opportunity opp:opportunities){
                if(opp.AccountId != null){
                    accountIds.add(opp.AccountId);
                }
            }

            Map<Id,Territory2Priority> accountMaxPriorityTerritory = getAccountMaxPriorityTerritory(activeModelId, accountIds);

            // For each opportunity, assign the highest priority territory if there is no conflict, else assign null.
            for(Opportunity opp: opportunities){
                Territory2Priority tp = accountMaxPriorityTerritory.get(opp.AccountId);
                // Assign highest priority territory if there is only 1.
                if((tp != null) && (tp.moreTerritoriesAtPriority == false) && (tp.territory2Id != opp.Territory2Id)){
                    OppIdTerritoryIdResult.put(opp.Id, tp.territory2Id);
                }else{
                    OppIdTerritoryIdResult.put(opp.Id, null);
                }
            }
        }
        return OppIdTerritoryIdResult;
    }

    private Map<Id,Territory2Priority> getAccountMaxPriorityTerritory(Id activeModelId, Set<Id> accountIds){
        Map<Id,Territory2Priority> accountMaxPriorityTerritory = new Map<Id,Territory2Priority>();
        for(ObjectTerritory2Association ota:[Select ObjectId, Territory2Id, Territory2.Territory2Type.Priority from ObjectTerritory2Association where objectId IN :accountIds and Territory2.Territory2ModelId = :activeModelId]){
            Territory2Priority tp = accountMaxPriorityTerritory.get(ota.ObjectId);

            if((tp == null) || (ota.Territory2.Territory2Type.Priority > tp.priority)){
                // If this is the first territory examined for account or it has greater priority than current highest priority territory, then set this as new highest priority territory.
                tp = new Territory2Priority(ota.Territory2Id,ota.Territory2.Territory2Type.priority,false);
            }else if(ota.Territory2.Territory2Type.priority == tp.priority){
                // The priority of current highest territory is same as this, so set moreTerritoriesAtPriority to indicate multiple highest priority territories seen so far.
                tp.moreTerritoriesAtPriority = true;
            }

            accountMaxPriorityTerritory.put(ota.ObjectId, tp);
        }
        return accountMaxPriorityTerritory;
    }

    private Id getActiveModelId() {
        List<Territory2Model> models = [Select Id from Territory2Model where State = 'Active'];
        Id activeModelId = null;
        if(models.size() == 1){
            activeModelId = models.get(0).Id;
        }

        return activeModelId;
    }

    private class Territory2Priority {
        public Id territory2Id { get; set; }
        public Integer priority { get; set; }
        public Boolean moreTerritoriesAtPriority { get; set; }

        Territory2Priority(Id territory2Id, Integer priority, Boolean moreTerritoriesAtPriority){
            this.territory2Id = territory2Id;
            this.priority = priority;
            this.moreTerritoriesAtPriority = moreTerritoriesAtPriority;
        }
    }
}


