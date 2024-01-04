function swapmenu() {
	var menuc = document.getElementById('menuc');
	var menu  = document.getElementById('menu');
	var menub = document.getElementById('menub');

	if (menuc.style.display != 'none') {
		menuc.style.display = 'none';
		menu.style.width = '6px';
		menub.style.left = '3px';
		menub.style.backgroundImage = "url('expand.png')";
	} else {
		menuc.style.display = 'block';
		menu.style.width = '160px';
		menub.style.left = '157px';
		menub.style.backgroundImage = "url('contract.png')";
	}
}
