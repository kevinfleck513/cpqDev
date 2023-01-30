/**
 * 
 * TriggerHandler class
 *
 * Versioning: 
 *   9/9/20 : stevelohrenz : File Created
 */

public virtual class TriggerHandler {

    // static map of handlername, times run() was invoked
        private static Map<String, LoopCount> loopCountMap;
        private static Set<String> bypassedHandlers;
    
        // the current context of the trigger, overridable in tests
        @TestVisible
        private TriggerContext context;
    
        // the current context of the trigger, overridable in tests
        @TestVisible
        private Boolean isTriggerExecuting;
    
        private String handlerName {get; set;}
    
        // static initialization
        static {
            loopCountMap = new Map<String, LoopCount>();
            bypassedHandlers = new Set<String>();
        }
    
        // constructor
        public TriggerHandler() {
            this.setTriggerContext();
        }
    
        public TriggerHandler(String handlerName) {
            this.handlerName = handlerName;
            this.setTriggerContext();
        }
    
        /***************************************
         * public instance methods
         ***************************************/
    
        // main method that will be called during execution
        public void run() {
    
            if (!validateRun()) return;
    
            addToLoopCount();
    
            // dispatch to the correct handler method
            if (this.context == TriggerContext.BEFORE_INSERT) {
                this.beforeInsert();
            } else if (this.context == TriggerContext.BEFORE_UPDATE) {
                this.beforeUpdate();
            } else if (this.context == TriggerContext.BEFORE_DELETE) {
                this.beforeDelete();
            } else if (this.context == TriggerContext.AFTER_INSERT) {
                this.afterInsert();
            } else if (this.context == TriggerContext.AFTER_UPDATE) {
                this.afterUpdate();
            } else if (this.context == TriggerContext.AFTER_DELETE) {
                this.afterDelete();
            } else if (this.context == TriggerContext.AFTER_UNDELETE) {
                this.afterUndelete();
            }
    
        }
    
        public void setMaxLoopCount(Integer max) {
            String handlerName = getHandlerName();
            if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
                TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
            } else {
                TriggerHandler.loopCountMap.get(handlerName).setMax(max);
            }
        }
    
        public void clearMaxLoopCount() {
            this.setMaxLoopCount(-1);
        }
    
        /***************************************
         * public static methods
         ***************************************/
    
        public static void bypass(String handlerName) {
            TriggerHandler.bypassedHandlers.add(handlerName);
        }
    
        public static void clearBypass(String handlerName) {
            TriggerHandler.bypassedHandlers.remove(handlerName);
        }
    
        public static Boolean isBypassed(String handlerName) {
            return TriggerHandler.bypassedHandlers.contains(handlerName);
        }
    
        public static void clearAllBypasses() {
            TriggerHandler.bypassedHandlers.clear();
        }
    
        /***************************************
         * private instancemethods
         ***************************************/
    
        @TestVisible
        private void setTriggerContext() {
            this.setTriggerContext(null, false);
        }
    
        @TestVisible
        private void setTriggerContext(String ctx, Boolean testMode) {
            if (!Trigger.isExecuting && !testMode) {
                this.isTriggerExecuting = false;
                return;
            } else {
                this.isTriggerExecuting = true;
            }
    
            if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
                (ctx != null && ctx == 'before insert')) {
                this.context = TriggerContext.BEFORE_INSERT;
            } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                (ctx != null && ctx == 'before update')) {
                this.context = TriggerContext.BEFORE_UPDATE;
            } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                (ctx != null && ctx == 'before delete')) {
                this.context = TriggerContext.BEFORE_DELETE;
            } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                (ctx != null && ctx == 'after insert')) {
                this.context = TriggerContext.AFTER_INSERT;
            } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                (ctx != null && ctx == 'after update')) {
                this.context = TriggerContext.AFTER_UPDATE;
            } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                (ctx != null && ctx == 'after delete')) {
                this.context = TriggerContext.AFTER_DELETE;
            } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                (ctx != null && ctx == 'after undelete')) {
                this.context = TriggerContext.AFTER_UNDELETE;
            }
        }
    
        // increment the loop count
        @TestVisible
        private void addToLoopCount() {
            String handlerName = getHandlerName();
            if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
                Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
                if (exceeded) {
                    Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
                    throw new SFBNSCJ_TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
                }
            }
        }
    
        // make sure this trigger should continue to run
        @TestVisible
        private Boolean validateRun() {
            if (!this.isTriggerExecuting || this.context == null) {
                throw new SFBNSCJ_TriggerHandlerException('Trigger handler called outside of Trigger execution');
            }
            if (TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
                return false;
            }
            return true;
        }
    
        @TestVisible
        protected String getHandlerName() {
            if(String.isBlank(this.handlerName)) {
                this.handlerName = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
            }
            return this.handlerName;
        }
    
        /***************************************
         * context methods
         ***************************************/
    
        // context-specific methods for override
        @TestVisible
        protected virtual void beforeInsert() {
        }
        @TestVisible
        protected virtual void beforeUpdate() {
        }
        @TestVisible
        protected virtual void beforeDelete() {
        }
        @TestVisible
        protected virtual void afterInsert() {
        }
        @TestVisible
        protected virtual void afterUpdate() {
        }
        @TestVisible
        protected virtual void afterDelete() {
        }
        @TestVisible
        protected virtual void afterUndelete() {
        }
    
        protected virtual Boolean isEnabled() {
            return true;
        }
    
        /***************************************
         * inner classes
         ***************************************/
    
        // inner class for managing the loop count per handler
        @TestVisible
        private class LoopCount {
            private Integer max;
            private Integer count;
    
            public LoopCount() {
                this.max = 5;
                this.count = 0;
            }
    
            public LoopCount(Integer max) {
                this.max = max;
                this.count = 0;
            }
    
            public Boolean increment() {
                this.count++;
                return this.exceeded();
            }
    
            public Boolean exceeded() {
                if (this.max < 0) return false;
                if (this.count > this.max) {
                    return true;
                }
                return false;
            }
    
            public Integer getMax() {
                return this.max;
            }
    
            public Integer getCount() {
                return this.count;
            }
    
            public void setMax(Integer max) {
                this.max = max;
            }
        }
    
        // possible trigger contexts
        @TestVisible
        private enum TriggerContext {
            BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
            AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
            AFTER_UNDELETE
        }
    
        // exception class
        public class SFBNSCJ_TriggerHandlerException extends Exception {
        }
    
        public String objectName {
            get {
                if (objectName == null) {
                    if (Trigger.new != null && Trigger.new[0] != null) {
                        objectName = Trigger.new[0].getSObjectType().getDescribe().getName().toUpperCase();
                    } else if (Trigger.old != null && Trigger.old[0] != null) {
                        objectName = Trigger.old[0].getSObjectType().getDescribe().getName().toUpperCase();
                    }
                }
                return objectName;
            }
            set;
        }
    
        public boolean validField(String fieldName) {
            if (!validObjectName(objectName)) {
                return false;
            }
            return globalDescribe.get(objectName).getDescribe().fields.getMap().containsKey(fieldName.toLowerCase());
        }
    
        public Boolean isChanged(String fieldName, sObject newRecord) {
            sObject oldRecord = Trigger.oldMap != null ? Trigger.oldMap.get((Id) newRecord.get('id')) : null;
            if (oldRecord == null) {
                return true;
            }
            if (newRecord == null) {
                return null;
            }
            if (validField(objectName, fieldName)) {
                System.debug(fieldName);
                System.debug(oldRecord.get(fieldName));
                System.debug(newRecord.get(fieldName));
                System.debug(oldRecord.get(fieldName) != newRecord.get(fieldName));
                return oldRecord.get(fieldName) != newRecord.get(fieldName);
            }
            return false;
        }
    
        public static boolean validObjectName(String objName) {
            if (globalDescribe.get(objName) == null) {
                return false;
            } else {
                return true;
            }
        }
    
        public static boolean validField(String objName, String fieldName) {
            if (!validObjectName(objName)) {
                return false;
            }
            return globalDescribe.get(objName).getDescribe().fields.getMap().containsKey(fieldName);
        }
    
        private static Map<String, Schema.SObjectType> globalDescribe {
            get {
                if (globalDescribe == null) {
                    globalDescribe = Schema.getGlobalDescribe();
                }
                return globalDescribe;
            }
            set;
        }
    
    }