function padZero(num, size) {
    var s = num+"";
    while (s.length < size) s = "0" + s;
    return s;
}

function padSpace(num, size) {
    var s = num+"";
    while (s.length < size) s = " " + s;
    return s;
}

function padFloat(num, size){  
    var s = String(num.toFixed(2));
    s = s.replace(".", "");
  
    while (s.length < size) s = "0" + s;
    return s;  
}

function formata_data(data){
  var ano = padZero(data.getFullYear(), 4);
  var mes = padZero(data.getMonth()+1, 2);
  var dia = padZero(data.getDate(), 2);
  
  var str_data = "";
  str_data = str_data.concat(ano, mes, dia);
  return str_data;
}