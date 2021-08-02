public virtual class TriggerHandler {

    public void run(System.TriggerOperation triggerEvent){
        switch on triggerEvent{
            when BEFORE_INSERT{
                this.beforeInsert();
            }
            when BEFORE_UPDATE{
                this.beforeUpdate();
            }
            when BEFORE_DELETE{
                this.beforeDelete();
            }
            when AFTER_INSERT{
                this.afterInsert();
            }
            when AFTER_UPDATE{
                this.afterUpdate();
            }
            when AFTER_DELETE{
                this.afterDelete();
            }
            when AFTER_UNDELETE{
                this.afterUndelete();
            }
        }
    }
    
    @TestVisible
    protected virtual void beforeInsert() {}
    @TestVisible
    protected virtual void beforeUpdate() {}
    @TestVisible
    protected virtual void beforeDelete() {}
    @TestVisible
    protected virtual void afterInsert() {}
    @TestVisible
    protected virtual void afterUpdate() {}
    @TestVisible
    protected virtual void afterDelete() {}
    @TestVisible
    protected virtual void afterUndelete() {}

}