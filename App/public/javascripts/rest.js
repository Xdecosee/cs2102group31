/* ---- USEFUL: you can implement input validation if you want  or any javascript funcs you saw online---- */
function emptyValues(str){

	if (!str.trim()|| str.trim().length === 0) {
		return true;
	}
}

function checkMonth(event) {

	var month = document.getElementById('month').value;

	if(emptyValues(month)){
		alert("Please select a month!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}

}
function checkFood(event) {
	// Get Values from <form> in ejs file
	var food  = document.getElementById('foodname').value;
	var price = document.getElementById('price').value;
	var limit = document.getElementById('limit').value;
	var category = document.getElementById('category').value;
	var numbers = /^\d*\.?\d{1,2}$/;
	
	if(emptyValues(food) || emptyValues(price.toString()) || emptyValues(limit.toString()) || emptyValues(category)){
		alert("Please key in all information!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}

	if( food.length > 100) {
		/*-------USEFUL: create popup through alert -------- */
		alert("food name too long");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if( !price.match(numbers) || price <= 0.00) {
		alert("price format invalid!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
}

function updateFood(event) {
	// Get Values from <form> in ejs file
	var price = document.getElementById('price').value;
	var limit = document.getElementById('limit').value;
	var category = document.getElementById('category').value;
	var numbers = /^\d*\.?\d{1,2}$/;
	
	if(emptyValues(price.toString()) || emptyValues(limit.toString()) || emptyValues(category)){
		alert("Please key in all information!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	
	if( !price.match(numbers) || price <= 0.00) {
		alert("price format invalid!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
}

function checkPromo(event) {

	var startnorm = document.getElementById('startdt' ).value;
	var endnorm = document.getElementById('enddt').value;
	var start  = new Date(document.getElementById('startdt' ).value).getTime();
	var end = new Date(document.getElementById('enddt').value).getTime();
	var type = document.getElementById('type').value;
	var discount = document.getElementById('discount').value;
	var twodecimal = /^\d*\.?\d{1,2}$/;
	var whole = /^\d{1,3}$/;
	
	if(emptyValues(startnorm) || emptyValues(endnorm) || emptyValues(type) || emptyValues(discount.toString())){
		alert("Please key in all information!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	
	if( end <= start) {
		alert("End date and time need to be after the start date and time!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}

	if(type == "percentage"){
		if(!discount.match(whole) || (discount > 100) || discount <= 0) {
			alert("discount format invalid!");
			event.preventDefault();
			event.stopPropagation();
			return false;
		}
	} else if(type == "fixed"){
		if( !discount.match(twodecimal) || discount <= 0.00) {
			alert("discount format invalid!");
			event.preventDefault();
			event.stopPropagation();
			return false;
		}
	}
	
}

