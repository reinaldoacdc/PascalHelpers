function splitAdressFromNumber(endereco) {
  var arr = endereco.split(',');
  
  var numero = '';
  var endereco = arr[0];
  
  if (arr.length == 1){ 
    numero = '' 
  } else {
    numero = arr[1];
  }  
    
  return [endereco, numero];    
}

function splitCpfFromCnpj(texto){
  var cpf = '';
  var cnpj = '';
  
  
  if (texto.length = 14) {
    cnpj = texto
  }
  else if (texto.length = 11){
    cpf = texto
  }
  
  return [cpf, cnpj];
}