$(document).ready(function () {

    var curTask = 0;

    function openMain() {
        $(".divwrap").fadeIn(10);
    }

    function closeMain() {
        $(".divwrap").css("display", "none");
    }

    window.addEventListener("message", function (event) {

        var item = event.data;
        if (item.runProgress === true) {
            openMain();
            
            $(".cicleDisplay").css("stroke-dashoffset","100");
            $(".nicesexytext,.divwrap p").empty();
            $(".divwrap p").append("0%");
            $(".nicesexytext").append(item.name);
        }

        if (item.runUpdate === true) {
            var percent = parseInt(item.Length);

            $(".cicleDisplay").css("stroke-dashoffset",100-percent);
            $(".nicesexytext,.divwrap p").empty();
            $(".divwrap p").append(percent+"%");
            $(".nicesexytext").append(item.name);

        }
        
        if (item.closeFail === true) {
            closeMain()

            $.post("https://caue-taskbar/taskCancel", JSON.stringify({
                tasknum: curTask
            }));
        }

        if (item.closeProgress === true) {
            closeMain();
        }

    });
    //teste navegador
    // var  porc = 90
    // var  text = "Processando"
    // $(".divwrap").fadeIn(10);



    // $(".cicleDisplay").css("stroke-dashoffset",100-porc);
    // $(".nicesexytext,.divwrap p").empty();
    // $(".divwrap p").append(porc+"%");
    // $(".nicesexytext").append(text);

});