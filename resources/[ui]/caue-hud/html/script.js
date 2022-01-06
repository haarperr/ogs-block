$(document).ready(function () {
    VoiceIndicator = new ProgressBar.Circle("#VoiceIndicator", {
        color: "rgba(255, 255, 255, 1)",
        trailColor: "rgba(255, 255, 255, 0.35)",
        strokeWidth: 12.5,
        trailWidth: 12.5,
        duration: 250,
        easing: "easeInOut",
    });

    HealthIndicator = new ProgressBar.Circle("#HealthIndicator", {
        color: "rgba(59, 178, 115, 1)",
        trailColor: "rgba(59, 178, 115, 0.35)",
        strokeWidth: 12.5,
        trailWidth: 12.5,
        duration: 250,
        easing: "easeInOut",
    });

    ArmorIndicator = new ProgressBar.Circle("#ArmorIndicator", {
        color: "rgba(21, 101, 192, 1)",
        trailColor: "rgba(21, 101, 192, 0.35)",
        strokeWidth: 12.5,
        trailWidth: 12.5,
        duration: 250,
        easing: "easeInOut",
    });

    HungerIndicator = new ProgressBar.Circle("#HungerIndicator", {
        color: "rgba(255, 109, 0, 1)",
        trailColor: "rgba(255, 109, 0, 0.35)",
        strokeWidth: 12.5,
        trailWidth: 12.5,
        duration: 250,
        easing: "easeInOut",
    });

    ThirstIndicator = new ProgressBar.Circle("#ThirstIndicator", {
        color: "rgba(2, 119, 189, 1)",
        trailColor: "rgba(2, 119, 189, 0.35)",
        strokeWidth: 12.5,
        trailWidth: 12.5,
        duration: 250,
        easing: "easeInOut",
    });

    OxygenIndicator = new ProgressBar.Circle("#OxygenIndicator", {
        color: "rgba(144, 164, 174, 1)",
        trailColor: "rgba(144, 164, 174, 0.35)",
        strokeWidth: 12.5,
        trailWidth: 12.5,
        duration: 250,
        easing: "easeInOut",
    });

    StressIndicator = new ProgressBar.Circle("#StressIndicator", {
        color: "rgba(213, 0, 0, 1)",
        trailColor: "rgba(213, 0, 0, 0.35)",
        strokeWidth: 12.5,
        trailWidth: 12.5,
        duration: 250,
        easing: "easeInOut",
    });

    HarnessIndicator = new ProgressBar.Circle("#HarnessIndicator", {
        color: "rgba(171, 71, 188, 1)",
        trailColor: "rgba(171, 71, 188, 0.35)",
        strokeWidth: 12.5,
        trailWidth: 12.5,
        duration: 250,
        easing: "easeInOut",
    });

    NitrousIndicator = new ProgressBar.Circle("#NitrousIndicator", {
        color: "rgba(228, 63, 90, 1)",
        trailColor: "rgba(228, 63, 90, 0.35)",
        strokeWidth: 12.5,
        trailWidth: 12.5,
        duration: 100,
        easing: "easeInOut",
    });

    DeveloperIndicator = new ProgressBar.Circle("#DeveloperIndicator", {
        color: "rgba(0, 0, 0, 1)",
        trailColor: "rgba(0, 0, 0, 0.35)",
        strokeWidth: 12.5,
        trailWidth: 12.5,
        duration: 100,
        easing: "easeInOut",
    });

    DebugIndicator = new ProgressBar.Circle("#DebugIndicator", {
        color: "rgba(0, 0, 0, 1)",
        trailColor: "rgba(0, 0, 0, 0.35)",
        strokeWidth: 12.5,
        trailWidth: 12.5,
        duration: 100,
        easing: "easeInOut",
    });

    VoiceIndicator.animate(66 / 100);

    $("#HarnessIndicator").hide();
    $("#NitrousIndicator").hide();
    $("#DeveloperIndicator").hide();
    $("#DebugIndicator").hide();
});

window.addEventListener("message", function (event) {
    let data = event.data;

    if (data.showUi == true) {
        $(".container").css("display", "block");
    } else if (data.showUi == false) {
        $(".container").css("display", "none");
    }

    if (data.action == "dev") {
        if (data.developer == true) {
            $("#DeveloperIndicator").show();
        } else {
            $("#DeveloperIndicator").hide();
        }
    }

    if (data.action == "debug") {
        if (data.debug == true) {
            $("#DebugIndicator").show();
        } else {
            $("#DebugIndicator").hide();
        }
    }

    if (data.action == "hud") {
        HealthIndicator.animate(data.health / 100);
        ArmorIndicator.animate(data.armor / 100);
        HungerIndicator.animate(data.hunger / 100);
        ThirstIndicator.animate(data.thirst / 100);
        OxygenIndicator.animate(data.oxygen / 100);
        StressIndicator.animate(data.stress / 100);

        if (data.health == 100) {
            $("#HealthIndicator").hide();
        } else {
            $("#HealthIndicator").show();

            if (data.health < 25) {
                HealthIndicator.trail.setAttribute("stroke", "rgba(255, 0, 0, 0.35)");
            } else {
                HealthIndicator.trail.setAttribute("stroke", "rgba(59, 178, 115, 0.35)");
            }
        }

        if (data.armor == 0) {
            $("#ArmorIndicator").hide();
        } else {
            $("#ArmorIndicator").show();

            if (data.armor < 25) {
                ArmorIndicator.trail.setAttribute("stroke", "rgba(255, 0, 0, 0.35)");
            } else {
                ArmorIndicator.trail.setAttribute("stroke", "rgba(21, 101, 192, 0.35)");
            }
        }

        if (data.hunger == 100) {
            $("#HungerIndicator").hide();
        } else {
            $("#HungerIndicator").show();

            if (data.hunger < 25) {
                HungerIndicator.trail.setAttribute("stroke", "rgba(255, 0, 0, 0.35)");
            } else {
                HungerIndicator.trail.setAttribute("stroke", "rgba(255, 109, 0, 0.35)");
            }
        }

        if (data.thirst == 100) {
            $("#ThirstIndicator").hide();
        } else {
            $("#ThirstIndicator").show();

            if (data.thirst < 25) {
                ThirstIndicator.trail.setAttribute("stroke", "rgba(255, 0, 0, 0.35)");
            } else {
                ThirstIndicator.trail.setAttribute("stroke", "rgba(2, 119, 189, 0.35)");
            }
        }

        if (data.oxygenShow == true) {
            $("#OxygenIndicator").show();
        } else if (data.oxygenShow == false) {
            $("#OxygenIndicator").hide();
        }

        if (data.stress == 0) {
            $("#StressIndicator").hide();
        } else {
            $("#StressIndicator").show();
        }
    }

    if (data.action == "voice") {
        let voice = 0;

        switch (data.voice) {
            case 1:
                voice = 33
                break;
            case 2:
                voice = 66
                break;
            case 3:
                voice = 100
                break;
        }

        VoiceIndicator.animate(voice / 100);
    }

    if (data.action == "talking") {
        if (data.talking) {
            if (data.radio) {
                VoiceIndicator.path.setAttribute("stroke", "rgba(255, 61, 65, 1)");
                VoiceIndicator.trail.setAttribute("stroke", "rgba(255, 61, 65, 0.35)");
            } else {
                VoiceIndicator.path.setAttribute("stroke", "rgba(255, 255, 102, 1)");
                VoiceIndicator.trail.setAttribute("stroke", "rgba(255, 255, 102, 0.35)");
            }
        } else {
            VoiceIndicator.path.setAttribute("stroke", "rgba(255, 255, 255, 1)");
            VoiceIndicator.trail.setAttribute("stroke", "rgba(255, 255, 255, 0.35)");
        }
    }

    if (data.action == "harness") {
        if (data.harness == 0) {
            $("#HarnessIndicator").hide();
        } else {
            $("#HarnessIndicator").show();

            HarnessIndicator.animate(data.harness / 100);
        }
    }

    if (data.action == "nitrous") {
        if (data.nitrous == 0) {
            $("#NitrousIndicator").hide();
        } else {
            $("#NitrousIndicator").show();

            NitrousIndicator.path.setAttribute("stroke", "rgba(228, 63, 90, 1)");
            NitrousIndicator.animate(data.nitrous / 100);

            if (data.delay === true) {
                $("#NitrousIcon").css("color", "grey");
            } else {
                $("#NitrousIcon").css("color", "white");
            }
        }
    }

    if (data.action == "nitrousactive") {
        NitrousIndicator.path.setAttribute("stroke", "rgba(254, 37, 78, 1)");
        NitrousIndicator.animate(data.nitrous / 100);
    }

    if (data.vehicleUi == true) {
        $(".VehicleContainer").css("display", "block");
    } else if (data.vehicleUi == false) {
        $(".VehicleContainer").css("display", "none");
    }

    if (data.action == "vehicle") {
        $(".direction").css("display", "block");
        $(".direction").find(".image").attr("style", "transform: translate3d(" + data.direction + "px, 0px, 0px)");

        $(".street-txt1").css("display", "block");
        $(".street-txt1").html(data.district);

        $(".street-txt2").css("display", "block");
        $(".street-txt2").html(data.street);

        setProgressSpeed(data.speed, ".progress-speed");
    }

    if (data.action == "vehiclemisc") {
        setProgressSpeed(data.fuel, ".progress-fuel");

        if (data.seatbelt) {
            $(".seatbelt img").fadeOut(750);
        } else {
            $(".seatbelt img").fadeIn(750);
        }
    }
});

function setProgressSpeed(value, element) {
    var circle = document.querySelector(element);
    var radius = circle.r.baseVal.value;
    var circumference = radius * 2 * Math.PI;
    var html = $(element).parent().parent().find('span');
    var percent = value * 100 / 450;

    circle.style.strokeDasharray = `${circumference} ${circumference}`;
    circle.style.strokeDashoffset = `${circumference}`;

    const offset = circumference - ((-percent * 73) / 100) / 100 * circumference;
    circle.style.strokeDashoffset = -offset;

    html.text(value);
}

function setProgressFuel(percent, element) {
    var circle = document.querySelector(element);
    var radius = circle.r.baseVal.value;
    var circumference = radius * 2 * Math.PI;
    var html = $(element).parent().parent().find("span");

    circle.style.strokeDasharray = `${circumference} ${circumference}`;
    circle.style.strokeDashoffset = `${circumference}`;

    const offset = circumference - ((-percent * 73) / 100 / 100) * circumference;
    circle.style.strokeDashoffset = -offset;

    html.text(Math.round(percent));
}