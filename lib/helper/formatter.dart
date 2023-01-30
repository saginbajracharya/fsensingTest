String format(value){
  var subString ='';
  if(value.length>=5)
  {
    subString =value.substring(0,5);
  }
  else{
    subString = value; 
  }
  return subString;
}
