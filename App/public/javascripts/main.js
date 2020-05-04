function emptyValues(str){
	if (!str.trim() || str.trim().length === 0) {
		return true;
	}
}

function checkCF(){

	var username  = document.getElementById('username').value;
	var name = document.getElementById('name').value;
	var password = document.getElementById('password').value;

	if(username.length >= 255 || password.length >= 255 || name.length >= 255)  {
		alert("one of your inputs is too long");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(emptyValues(username) || emptyValues(name) || emptyValues(password)){
		alert("Please key in all information!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}

}

function checkR(){

	var username  = document.getElementById('username').value;
	var name = document.getElementById('name').value;
	var password = document.getElementById('password').value;
	var restaurant = document.getElementById('restaurant').value;
	var location = document.getElementById('location').value;
	var threshold = document.getElementById('threshold').value;
	var twodecimal = /^\d*\.?\d{1,2}$/;


	if(username.length >= 255 || password.length >= 255 || name.length >= 255
		|| location.length >= 255 || restaurant.length >= 255)  {
		alert("one of your inputs is too long");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(emptyValues(username) || emptyValues(name) || emptyValues(password)
		|| emptyValues(location) || emptyValues(threshold.toString())){
		alert("Please key in all information!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}

	if( !threshold.match(twodecimal) || threshold <= 0.00) {
		alert("min threshold format invalid!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}

}


function checkD(){

	var username  = document.getElementById('username').value;
	var name = document.getElementById('name').value;
	var password = document.getElementById('password').value;
	var type = document.getElementById('ridertype').value;

	if(username.length >= 255 || password.length >= 255 || name.length >= 255)  {
		alert("one of your inputs is too long");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(emptyValues(username) || emptyValues(name) || emptyValues(password)
		|| emptyValues(type)){
		alert("Please key in all information!");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}

}