({
	myInit : function(component, event, helper) {
        component.set("v.Columns",[
            {label:"Subject", fieldName:"Subject", type:"text"},
            {label:"Status", fieldName:"Status", type:"text"},
            {label:"Due Date", fieldName:"ActivityDate", type:"date"},
            {label:"Comments", fieldName:"Description", type:"text"}
        ]);
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userId", userId);
        
        var getTasksAction = component.get("c.getTasks");
        getTasksAction.setParams({
    		userId: component.get("v.userId")
		});
        
		getTasksAction.setCallback(this, function(data) {
    		component.set("v.Tasks", data.getReturnValue());
		});
        
		$A.enqueueAction(getTasksAction);
	},
    
    openModalChangeStatus : function(component, event, helper) {

        let selectedRows = component.find('taskTable').getSelectedRows();
       
        if(selectedRows){
        	component.set("v.SelectedRows",selectedRows);
			component.set("v.showModal", true);
        }else{
            alert('Please select any tasks before press Complete button');
        }
	},
    
    closeModalChangeStatus : function(component, event, helper) {
        //check param closeModal
        
        var closeModalParam = event.getParam("closeStatus");
        
        if(closeModalParam === "changed"){
            //show toast
            var toastEvent = $A.get("e.force:showToast");
    		toastEvent.setParams({
        				"title": "Success!",
        				"message": "Selected Task record has been updated successfully."
    		});
    		toastEvent.fire();
        }
		component.set("v.showModal", false);
	},
})