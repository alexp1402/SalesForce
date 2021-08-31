({
	init : function(component, event, helper) {
		var getStatusAction = component.get("c.getStatus");
       	getStatusAction.setCallback(this, function(data) {
    		component.set("v.statuses", data.getReturnValue());
		});
        
		$A.enqueueAction(getStatusAction);
	},
    saveStatus : function(component, event,helper){
        var statusId = component.find('statusId').get('v.value');
        if (statusId){
            console.log("Status id = "+statusId);
            console.log("Selected tasks "+JSON.stringify(component.get('v.tasks')));
            //change status
            var setStatusEvent = component.get("c.setStatus");
            setStatusEvent.setParams({
    						status: statusId,
                			tasks: component.get("v.tasks")
			});
            $A.enqueueAction(setStatusEvent);
            console.log("fire change status");
            //close modal
            let closeEvent = component.getEvent("closeModal");
        	closeEvent.setParams({ "closeStatus": "changed" });
       		closeEvent.fire();
        }else{
            alert('Please check status first. Then press Save button');
        }
	},
    cancel : function(component, event, helper) {
		let closeEvent = component.getEvent("closeModal");
        closeEvent.setParams({ "closeStatus": "close" });
        closeEvent.fire();
	},
    
})