({
	showToast : function() {
		var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
            			type:'success',
        				title: 'Success!',
        				message: 'Selected Task record has been updated successfully.'
    		});
    	toastEvent.fire();
	}
})