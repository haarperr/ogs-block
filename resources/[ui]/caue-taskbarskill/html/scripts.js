$(document).ready(function () {
    let canvas = document.getElementById("canvas");
    let ctx = canvas.getContext("2d");

    let W = canvas.width;
    let H = canvas.height;
    let degrees = 0;
    let new_degrees = 0;
    let time = 0;
    let color = "#bfb89c";
    let bgcolor = "#ffffff00";
    let bgcolor2 = "#cabd73";
    let key_to_press;
    let g_start, g_end;
    let animation_loop;

    function getRandomInt(min, max) {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min + 1) + min); //The maximum is inclusive and the minimum is inclusive
    }

    function init() {
        // Clear the canvas every time a chart is drawn
        ctx.clearRect(0, 0, W, H);

        // Background 360 degree arc
        ctx.beginPath();
        ctx.strokeStyle = bgcolor;
        ctx.lineWidth = 40;
        ctx.arc(W / 2, H / 2, 100, 0, Math.PI * 2, false);
        ctx.stroke();

        // Green zone
        ctx.beginPath();
        ctx.strokeStyle = bgcolor2;
        ctx.lineWidth = 30;
        ctx.arc(W / 2, H / 2, 100, g_start - 90 * Math.PI / 180, g_end - 90 * Math.PI / 180, false);
        ctx.stroke();

        // Angle in radians = angle in degrees * PI / 180
        let radians = degrees * Math.PI / 180;
        ctx.beginPath();
        ctx.strokeStyle = color;
        ctx.lineWidth = 30;
        ctx.arc(W / 2, H / 2, 100, 0 - 90 * Math.PI / 180, radians - 90 * Math.PI / 180, false);
        ctx.stroke();

        // Adding the key_to_press
        ctx.fillStyle = color;
        ctx.font = "100px arial black";
        let text_width = ctx.measureText(key_to_press).width;
        ctx.fillText(key_to_press, W / 2 - text_width / 2, H / 2 + 35);
    }

    function draw(_difficulty, _duration) {
        //Cancel any movement animation if a new chart is requested
        if (typeof animation_loop !== undefined) clearInterval(animation_loop);

        g_start = getRandomInt(15, 30) / 10;
        g_end = _difficulty / 10;
        g_end = g_start + g_end;

        degrees = 0;
        new_degrees = 360;

        key_to_press = "" + getRandomInt(1, 4);

        time = _duration / 1000;

        animation_loop = setInterval(animate_to, time);
    }

    //Function to make the chart move to new degrees
    function animate_to() {
        //Clear animation loop if degrees reaches to new_degrees
        if (degrees >= new_degrees) {
            wrong();
            return;
        }

        degrees += 1;
        init();
    }

    function correct() {
        $.post(`https://${GetParentResourceName()}/taskBarSkillResult`, JSON.stringify({
            success: true
        }));
    }

    function wrong() {
        $.post(`https://${GetParentResourceName()}/taskBarSkillResult`, JSON.stringify({
            success: false
        }));
    }

    function open() {
        $("#canvas").fadeIn(10);
    }

    function close() {
        $("#canvas").css("display", "none");
        if (typeof animation_loop !== undefined) clearInterval(animation_loop);
    }

    window.addEventListener("message", function (event) {
        var item = event.data;

        if (item.display == true) {
            open();
            draw(item.difficulty, item.duration);
        } else if (item.display == false) {
            close();
        }
    });

    $(document).on("keydown", function (e) {
        let key_pressed = e.originalEvent.key;
        let valid_keys = ["1", "2", "3", "4"];

        // Pressed a valid key
        if (valid_keys.includes(key_pressed)) {
            if (key_pressed === key_to_press) {
                // Pressed the correct key
                let d_start = (180 / Math.PI) * g_start;
                let d_end = (180 / Math.PI) * g_end;
                if (degrees < d_start) {
                    wrong();
                } else if (degrees > d_end) {
                    wrong();
                } else {
                    correct();
                }
            } else {
                wrong();
            }
        }
		//COMANDO PARA TESTAR NO NAVEGADOR
		// if (key_pressed == "e") {
		// 	open();
        //     draw(20, 1000);
        // }
    });
});