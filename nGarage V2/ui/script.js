$(function() {
    $('body').hide();
    $('#container').hide();
    window.addEventListener('message', function(event) {
        var data = event.data;
  
        if (data.action == "open") {
            var sound = new Audio('sound/popup.mp3');
            sound.volume = 0.1;
            sound.play();
            $('body').fadeIn(500);
            $('#container').fadeIn(500);
            $('.garage-name').html(data.garageName);
            showVeh(data.name, data.plate, data.bodyHealth, data.engineHealth, data.fuelLevel, data.stored, data.info, data.realBody, data.realEngine, data.realFuel);
        } else {
            $('body').hide();
            $('#container').hide();
        }
    });
})

function showVeh(array, plate, bodyHealth, engineHealth, fuelLevel, stored, info, realBody, realEngine, realFuel) {
    var elem = document.getElementById("vehlist");
    if (array.length >= 1) {
        if (stored == true) {
            elem.innerHTML += `
                    <div class="vehlist">
                        <img class="stored-icon" src="img/stored.png">
                        <h1 class="veh-name">${array}</h1>
                        <h2 class="plate">Plaque : ${plate}</h2>
                        <img class="fuel" src="img/fuel.png">
                        <h3 class="fuel-lvl">Essence : ${fuelLevel}%</h3>
                        <img class="body-icon" src="img/body.png">
                        <h3 class="body-lvl">Carrosserie : ${bodyHealth}%</h3>
                        <img class="engine-icon" src="img/engine.png">
                        <h3 class="engine-lvl">Moteur : ${engineHealth}%</h3>
                        <button class="btn" onclick="takeOut('${array}', '${plate}', '${info}', '${realBody}', '${realEngine}', '${realFuel}')">Sortir le véhicule</button>
                    </div>
                `
        } else {
            elem.innerHTML += `
                    <div class="vehlist">
                        <img class="stored-icon" src="img/not-stored.png">
                        <h1 class="veh-name">${array}</h1>
                        <h2 class="plate">Plaque : ${plate}</h2>
                        <img class="fuel" src="img/fuel.png">
                        <h3 class="fuel-lvl">Essence : ${fuelLevel}%</h3>
                        <img class="body-icon" src="img/body.png">
                        <h3 class="body-lvl">Carrosserie : ${bodyHealth}%</h3>
                        <img class="engine-icon" src="img/engine.png">
                        <h3 class="engine-lvl">Moteur : ${engineHealth}%</h3>
                        <button class="btn-sort">Véhicule déjà sortie</button>
                    </div>
                `
        }
    } 
}

function takeOut(name, plate, info, realBody, realEngine, realFuel) {
    var sound = new Audio('sound/sound.mp3');
    sound.volume = 0.7;
    sound.play();
    $.post('http://nGarage/close', JSON.stringify({}));
    $.post('http://nGarage/takeOut', JSON.stringify({
        name: name,
        plate: plate,
        info: info,
        realBody: realBody,
        realEngine: realEngine,
        realFuel: realFuel
    }));
    $("body").fadeOut();
    setTimeout(function(){
		$(".vehlist").remove();
	}, 400);
}

$('#close-btn').click(function() {
    var sound = new Audio('sound/popupreverse.mp3');
    sound.volume = 0.5;
    sound.play();
    $.post('http://nGarage/close', JSON.stringify({}));
    $("body").fadeOut();
    setTimeout(function(){
		$(".vehlist").remove();
	}, 400);
})