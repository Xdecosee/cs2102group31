function check(event) {
	// Get Values
	var name  = document.getElementById('name' ).value;
	var username    = document.getElementById('username'   ).value;
	var password = document.getElementById('password').value;
	var numbers = /^[0-9]+$/;
	
	// Simple Check
	if(name.length > 255) {
		alert("name too long");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(username.length > 255) {
		alert("username too long");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if( !password.match(numbers)) {
		alert("password should only have numbers");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
}