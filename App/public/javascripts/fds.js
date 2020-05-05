function checkMonth(event) {
    var month = document.getElementById('month').value;
    if (emptyValues(month)) {
        alert("Please select a month!");
        event.preventDefault();
        event.stopPropagation();
        return false;
    }
}

function emptyValues(str) {
    if (!str.trim() || str.trim().length === 0) {
        return true;
    }
}

function checkPromo(event) {
    var start = new Date(document.getElementById('startdate').value).getTime();
    var end = new Date(document.getElementById('enddate').value).getTime();
    var type = document.getElementById('type').value;
    var discount = document.getElementById('discount').value;
    var twodecimal = /^\d*\.?\d{1,2}$/;
    var whole = /^\d{1,3}$/;

    console.log(start);
    console.log(discount);
  
    if (emptyValues(start) || emptyValues(end) || emptyValues(type) || emptyValues(discount.toString())) {
        alert("Please key in all information!");
        event.preventDefault();
        event.stopPropagation();
        return false;
    }

    if (end <= start) {
        alert("End date need to be after the start date!");
        event.preventDefault();
        event.stopPropagation();
        return false;
    }

    if (type == "percentage") {
        if (!discount.match(whole) || (discount > 100) || discount <= 0) {
            alert("Discount Format Invalid!");
            event.preventDefault();
            event.stopPropagation();
            return false;
        }
    } else if (type == "fixed") {
        if (!discount.match(twodecimal) || discount <= 0.00) {
            alert("Discount Format Invalid!");
            event.preventDefault();
            event.stopPropagation();
            return false;
        }
    }
}