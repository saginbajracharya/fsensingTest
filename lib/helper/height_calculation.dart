actualheightCalculation(a,b,c,d){
  dynamic pressureValue = a;
  dynamic masterPressureValue = b;
  dynamic userMasterPressureValue = c;
  dynamic baseMasterPressureValue = d;
  if(userMasterPressureValue!=null&&userMasterPressureValue!="" && baseMasterPressureValue!=null && userMasterPressureValue!=""){
    var pressure = double.parse(pressureValue); 
    var masterPressure= double.parse(masterPressureValue);
    var userMasterPressure= double.parse(userMasterPressureValue); 
    var baseMasterPressure= double.parse(baseMasterPressureValue);
    var formulaResult = ((pressure-masterPressure)-(userMasterPressure-baseMasterPressure))*(-8.33);
    return formulaResult;
  }
  else{
    return null;
  }
}

displayheightCalculation(a,b,c,d){
  dynamic pressureValue = a;
  dynamic masterPressureValue = b;
  dynamic userMasterPressureValue = c;
  dynamic baseMasterPressureValue = d;
  if(userMasterPressureValue!=null && baseMasterPressureValue!=null){
    var pressure = double.parse(pressureValue); 
    var masterPressure= double.parse(masterPressureValue);
    var userMasterPressure= double.parse(userMasterPressureValue); 
    var baseMasterPressure= double.parse(baseMasterPressureValue);
    var formulaResult = ((pressure-masterPressure)-(userMasterPressure-baseMasterPressure))*(-8.33);
    if(formulaResult<0){
      return 0.0;
    }
    else{
      return double.parse(formulaResult.toStringAsFixed(1));
    }
  }
  else{
    return null;
  }
}