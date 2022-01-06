window.addEventListener('message', function(event) {
    let item = event.data;

    if (item.response == 'openTarget') {
        $(".target-label").html("");

        $('.target-wrapper').show();

        // $(".target-eye").css("color", "grey");
        $(".target-eye").attr("src", "peek.png");
    } else if (item.response == 'closeTarget') {
        $(".target-label").html("");

        $('.target-wrapper').hide();
    } else if (item.response == 'validTarget') {
        $(".target-label").html("");

        $.each(item.data, function (index, item) {
            $(".target-label").append("<div id='target-"+index+"'<li><span class='target-icon'><i class='fas fa-"+item.icon+"'></i></span>&nbsp"+item.label+"</li></div>");
            $("#target-"+index).hover((e)=> {
                $("#target-"+index).css("color",e.type === "mouseenter"?"rgb(0, 248, 185)":"white")
            })

            $("#target-"+index+"").css("padding-top", "7px");

            $("#target-"+index).data('TargetData', item);
        });

        // $(".target-eye").css("color", "rgb(0, 248, 185)");
        $(".target-eye").attr("src", "peek-active-1.png");
    } else if (item.response == 'leftTarget') {
        $(".target-label").html("");

        // $(".target-eye").css("color", "grey");
        $(".target-eye").attr("src", "peek.png");
    }
});

$(document).on('mousedown', (event) => {
    let element = event.target;

    if (element.id.split("-")[0] === 'target') {
        let TargetData = $("#"+element.id).data('TargetData');

        $.post('https://caue-eye/selectTarget', JSON.stringify(TargetData));

        $(".target-label").html("");
        $('.target-wrapper').hide();
    }
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESC
            $(".target-label").html("");
            $('.target-wrapper').hide();
            $.post('https://caue-eye/closeTarget');
            break;
        case 18: // ALT
            $(".target-label").html("");
            $('.target-wrapper').hide();
            $.post('https://caue-eye/closeTarget');
            break;
    }
});
