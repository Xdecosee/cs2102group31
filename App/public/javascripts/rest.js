/* ---- USEFUL: you can implement input validation if you want  or any javascript funcs you saw online---- */
function checkFood(event) {
	// Get Values from <form> in ejs file
	var food  = document.getElementById('foodname' ).value;
	var price = document.getElementById('price').value;
	//var numbers = /^[0-9]+$/;
	var numbers = /^\d*\.?\d{1,2}$/;
	

	if( food.length > 100) {
		/*-------USEFUL: create popup through alert -------- */
		alert("food name too long");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if( !price.match(numbers)) {
		alert("price format invalid!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
}