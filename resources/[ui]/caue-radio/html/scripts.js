$(document).ready(function () {
    var RadioChannel = "0.0";
    var Emergency = false;
    var Powered = false;

    $("#RadioChannel").attr("disabled", "disabled");
    $("#RadioChannel").val("");
    $("#RadioChannel").attr("placeholder", "Off");

    window.addEventListener("message", function (event) {
        var item = event.data;

        if (item.set === true) {
            RadioChannel = item.setChannel
        }

        if (item.open === true) {
            Emergency = item.jobType

            if (RadioChannel != "0.0" && Powered) {
                $("#RadioChannel").val(RadioChannel)
            } else {
                if (Powered) {
                    $("#RadioChannel").val("")
                    $("#RadioChannel").attr("placeholder", "100.0-999.9");
                } else {
                    $("#RadioChannel").val("")
                    $("#RadioChannel").attr("placeholder", "Off");
                }
            }

            $(".full-screen").fadeIn(100);
            $(".radio-container").fadeIn(100);
            $("#cursor").css("display", "block");
            $("#RadioChannel").focus()
        }

        if (item.open === false) {
            $(".full-screen").fadeOut(100);
            $(".radio-container").fadeOut(100);
            $("#cursor").css("display", "none");
        }
    });

    $("#Radio-Form").submit(function (e) {
        e.preventDefault();
        $.post("https://caue-radio/close");
    });

    $("#power").click(function () {
        if (Powered === false) {
            Powered = true;

            $("#RadioChannel").removeAttr("disabled");
            $("#RadioChannel").val(RadioChannel);

            $.post("https://caue-radio/poweredOn");
        } else {
            Powered = false;

            $.post("https://caue-radio/poweredOff");

            $("#RadioChannel").attr("disabled", "disabled");
            $("#RadioChannel").val("");
            $("#RadioChannel").attr("placeholder", "Off");
        }
    });

    $("#setChannel").click(function () {
        RadioChannel = parseFloat($("#RadioChannel").val())

        if (!RadioChannel) {
            RadioChannel = "0.0"
        }

        if (RadioChannel < 100.0 || RadioChannel > 999.9) {
            if (RadioChannel < 10 && Emergency) {} else {
                RadioChannel = "0.0"
            }
        }

        $.post("https://caue-radio/setRadioChannel", JSON.stringify({
            channel: RadioChannel
        }));
    });

    $("#volumeUp").click(function () {
        $.post("https://caue-radio/volumeUp");
    });

    $("#volumeDown").click(function () {
        $.post("https://caue-radio/volumeDown");
    });

    document.onkeyup = function (data) {
        if (data.which == 27) {
            $.post("https://caue-radio/close");
        }
    };
});