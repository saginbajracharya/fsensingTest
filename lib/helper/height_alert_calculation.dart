heightAlertCalculation(displayResultValue){
  if(displayResultValue!=null){
    // var displayResult = displayResultValue.toInt();
    var alert = '';
    if(displayResultValue>=0 && displayResultValue<2)
    {
      alert = "normal-state";
    }
    else if(displayResultValue>=2 && displayResultValue<5){
      alert = "alert-state";
    }
    else if(displayResultValue>=5 && displayResultValue<10){
      alert = "warning-state";
    }
    else if(displayResultValue>=10){
      alert = "danger-state";
    }
    return alert;
  }
  else{
    return null;
  }
}