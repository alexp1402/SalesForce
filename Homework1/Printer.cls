public class Printer {
    
    private String textToPrint;
    
    public Printer(String text){
        textToPrint = text;
    }
    
    public String getTextToPrint(){
        return textToPrint;
    }
    
    public Integer hashCode() {
        return getTextToPrint().hashcode();
	}

    public Boolean equals(Object o) {
        if ((o == null) || !(o instanceof Printer)){
            return false;
        } 
        
        if(((Printer) o).getTextToPrint().hashCode() == this.getTextToPrint().hashCode()){
            return true;
        }else{
            return false;
        }
	}
    
    public void printText(){
        System.debug(getTextToPrint());
    }
}