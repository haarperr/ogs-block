var phoneOpen = false;
var playerId = 0;
var notifications = false;
var oldContainerHistory = [];
var currentContainer = "home";

let gpsFilters = [];
let keyFilters = [];

/* Call info */
let currentCallState = 0;
let currentCallInfo = "";

const callStates = {
    0: "isNotInCall",
    1: "isDialing",
    2: "isReceivingCall",
    3: "isCallInProgress"
}

var decodeHTML = function (html) {
	var txt = document.createElement('textarea');
	txt.innerHTML = html;
	return txt.value;
};

var decodeEntities = (function () {
    // this prevents any overhead from creating the object each time
    var element = document.createElement('div');

    function decodeHTMLEntities(str) {
        if (str && typeof str === 'string') {
            // strip script/html tags
            str = str.replace(/<script[^>]*>([\S\s]*?)<\/script>/gmi, '');
            str = str.replace(/<\/?\w(?:[^"'>]|"[^"]*"|'[^']*')*>/gmi, '');
            element.innerHTML = str;
            str = element.textContent;
            element.textContent = '';
        }

        return str;
    }

    return decodeHTMLEntities;
})();

const calendarFormatDate = {
    sameDay: '[Today at] HH:mm',
    nextDay: '[Tomorrow at] HH:mm',
    nextWeek: 'dddd [at] HH:mm',
    lastDay: '[Yesterday at] HH:mm',
    lastWeek: '[Last] dddd [at] HH:mm',
    sameElse: 'YYYY-MM-DD HH:mm:ss'
}

moment.updateLocale('en', {
    relativeTime: {
        past: function (input) {
            return input === 'now'
                ? input
                : input + ' ago'
        },
        s: 'now',
        future: "in %s",
        ss: '%ds',
        m: "1m",
        mm: "%dm",
        h: "1h",
        hh: "%dh",
        d: "1d",
        dd: "%dd",
        M: "1mo",
        MM: "%dmo",
        y: "1y",
        yy: "%dy"
    }
});

var debounce = function (func, wait, immediate) {
    var timeout;
    return function () {
        var context = this, args = arguments;
        var later = function () {
            timeout = null;
            if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(context, args);
    };
};

$(document).ready(function () {
    $('.collapsible').collapsible();
    $('.modal').modal();

    $.post('https://caue-phone/getWeather', JSON.stringify({}));

    setInterval(function () {
        $.post('https://caue-phone/getWeather', JSON.stringify({}));
    }, 60 * 1000);

    /* This handles keyEvents - ESC etc */
    document.onkeyup = function (data) {
        // If Key == ESC -> Close Phone
        if (data.which == 27) {
            $.post('https://caue-phone/close', JSON.stringify({}));
        }
    }

    $(".phone-screen").on('click', '.phone-button', function (e) {
        var action = $(this).data('action');
        var actionButton = $(this).data('action-button');
        if (actionButton !== undefined) {
            switch (actionButton) {
                case "notifications":
                    if (notifications == true) {
                        notifications = false;
                    } else {
                        notifications = true;
                    }

                    let icon = $(this).find("i");
                    icon.toggleClass("fa-bell fa-bell-slash")

                    $.post("https://caue-phone/btnMute");
                    break;
                case "selfie":
                    $.post("https://caue-phone/phone:selfie");
                    break;
                case "home":
                    if (currentContainer !== "home") {
                        openContainer('home');
                    }
                    break;
                case "back":
                    if (oldContainerHistory.length > 0)
                        openContainer(oldContainerHistory.pop(), null, currentContainer);
                    break;
                case "browser":
                    openBrowser($(this).data("site"));
                    break;
            }
        }
        if (action !== undefined) {
            switch (action) {
                case "yellow-pages-delete":
                    $.post('https://caue-phone/deleteYP', JSON.stringify({}));
                    break;
                case "racing-create":
                    openContainer('racing-create');
                    $('#racing-start-tracks').empty();
                    $('#racing-create-type').append(`<option value="" disabled selected>Select the type</option>`);
                    $('#racing-create-type').append(`<option value="Point">Point</option>`);
                    $('#racing-create-type').append(`<option value="Lap">Lap</option>`);
                    $('select').formSelect();
                    break;
                case "newPostSubmit":
                    e.preventDefault();
                    $.post('https://caue-phone/newPostSubmit', JSON.stringify({
                        advert: escapeHtml($("#yellow-pages-form #yellow-pages-form-advert").val())
                    }));
                    $("#yellow-pages-form #yellow-pages-form-advert").attr("style", "").val('')
                    break;
                case "group-manage":
                    $.post('https://caue-phone/manageGroup', JSON.stringify({
                        GroupID: $(this).data('action-data')
                    }));
                    break;
                case "getCallHistory":
                    if (callStates[currentCallState] === "isCallInProgress" && currentContainer !== "incoming-call")
                        openContainer("incoming-call");
                    else
                        $.post('https://caue-phone/' + action, JSON.stringify({}));
                    break;
                case "spotify":
                    openBrowser('http://mysound.ge/index.php');
                    break;
                default:
                    $.post('https://caue-phone/' + action, JSON.stringify({}));
                    break;
            }
        }
    });

    window.addEventListener('message', function (event) {
        var item = event.data;

        if (item.newContact === true) {
            addContact(item.contact);
        }

        if (item.removeContact === true) {
            removeContact(item.contact);
        }

        if (item.emptyContacts === true) {
            contactList = [];
            $(".contacts-entries").empty();
        }

        if (item.playerId !== undefined) {
            playerId = item.playerId;
            $('.status-bar-player-id').text(item.playerId);
        }

        if (item.openPhone === true) {
            openPhoneShell();
            openContainer("home");

            if(callStates[currentCallState] !== "isNotInCall") {
                phoneCallerScreenSetup()
            }
        }

        if (item.openPhone === false) {
            closePhoneShell();
            $('#browser').fadeOut(300);
            closeContainer("home");
        }

        if (item.isRealEstateAgent === true) {
            $('.btn-real-estate').hide().fadeIn(150);
        }

        if (item.hasDecrypt === true) {
            $('.btn-decrypt').hide().fadeIn(150);
        }

        if (item.hasDecrypt2 === true) {
            $('.btn-vpn').hide().fadeIn(150);
        }

        switch (item.openSection) {
            case "notification":
                notification(item.icon, item.title, item.text, item.timeout);
                break;
            case "timeheader":
                $(".status-bar-time").empty();
                $(".status-bar-time").html(item.timestamp);
                break;
            case "server-time":
                setBatteryLevel(item.serverTime);
                break;
            case "notificationsYP":
                addYellowPages(item.list);
                break;
            case "messages":
                addMessages(item.list, item.clientNumber);
                break;
            case "messageRead":
                addMessagesRead(item.displayName, item.messages, item.clientNumber)
                break;
            case "messagesOther":
                addMessagesOther(item.list, item.clientNumber)
                break;
            case "contacts":
                openContainer("contacts");
                break;
            case "callHistory":
                addCallHistoryEntries(item.callHistory);
                break;
            case "twatter":
                addTweets(item.twats, item.name);
                break;
            case "accountInformation":
                addAccountInformation(item.response);
                break;
            case "GPS":
                if (item.locations !== undefined) {
                    addGPSLocations(item.locations);
                }
                openContainer("gps")
                break;
            case "Garage":
                addVehicles(item.vehicleData)
                break;
            case "addStocks":
                addStocks(item.stocksData);
                break;
            case "loadBank":
                loadBank(item.accounts);
                break;
            case "weather":
                setWeather(item.weather);
                break;
            case "deepweb":
                openBrowser("http://www.nopixel.online/morbrowser/mor-browser-setup-1/");
                break;
            case "keys":
                $('.keys-entries').empty();
                openContainer("keys");
                addKeys(item.keys);
                break;
            case "notifications":
                $('.notification-email').fadeOut(150);
                addEmails(item.list);
                break;
            case "newemail":
                $('.notification-email').css("display", "flex").hide().fadeIn(150);
                break;
            case "newsms":
                $('.notification-sms').css("display", "flex").hide().fadeIn(150);
                break;
            case "newtweet":
                $('.notification-twatter').css("display", "flex").hide().fadeIn(150);
                break;
            case "newpager":
                let pagerNotification = $('#pager-notification')
                $(pagerNotification).css("display", "flex").hide().fadeIn(2000);
                this.setTimeout(function() {
                    $(pagerNotification).fadeOut(2000);
                }, 8000);
                break;
            case "groups":
                addGroups(item.groups);
                break;
            case "groupManage":
                addGroupManage(item.groupData);
                break;
            case "RealEstate":
                openContainer("real-estate");
                if(item.RERank >= 4) {
                    $('.btn-evict-house').css("visibility", "visible").hide().fadeIn(150);
                    $('.btn-transfer-house').css("visibility", "visible").hide().fadeIn(150);
                }
                break;
            case "callState":
                currentCallState = item.callState;
                currentCallInfo = item.callInfo;
                phoneCallerScreenSetup();
                break;
            case "notify":
                $('#twatter-notification').fadeIn(300);
                $('.twatter-notification-title').text(item.handle);
                $('.twatter-notitication-body').text(decodeEntities(item.message));
                $('#twatter-notification').fadeOut(10000);
                break;
            case "showOutstandingPayments":
                addOutstandingPayments(item.outstandingPayments);
                break;
            case "manageKeys":
                $('.manage-keys-entries').empty();
                addManageKeys(item.sharedKeys);
                openContainer('manage-keys')
                break;
            case "settings":
                addSettings(item);
                break;
            case "racing:events:aliases":
                $('#racing-aliases-modal').modal('open');
                M.updateTextFields();
                break;
            case "racing:events:list":
                addRaces(item.races, item.canMakeMap);
                openContainer('racing');
                break;
            case "racing-start":
                $("#racing-laps #racing-start-laps").prop("disabled", true);
                $('#racing-start-tracks').empty();
                maps = item.maps;
                addRacingTracks(maps);
                openContainer('racing-start');
                break;
            case "racing:event:update":
                addRaces(item.races, item.canMakeMap);
                break;
            case "racing:events:highscore":
                addRacingHighScores(item.highScoreList);
                break;
        }
    });
});

$('.phone-screen').on('copy', '.number-badge', function (event) {
    if (event.originalEvent.clipboardData) {
        let selection = document.getSelection();
        selection = selection.toString().replace(/-/g, "")
        event.originalEvent.clipboardData.setData('text/plain', selection);
        event.preventDefault();
    }
});





function setBatteryLevel(serverTime) {
    let restartTimes = ["00:00:00", "08:00:00", "16:00:00"];
    restartTimes = restartTimes.map(time => moment(time, "HH:mm:ss"));
    serverTime = moment(serverTime, "HH:mm:ss")

    let timeUntilRestarts = restartTimes.map(time => moment.duration(time.diff(serverTime)));
    timeUntilRestarts = timeUntilRestarts.map(time => time.asHours());
    let timeUntilRestart = timeUntilRestarts.filter(time => 0 <= time && time < 8);

    if (timeUntilRestart.length == 0) {
        timeUntilRestarts = timeUntilRestarts.map(time => time + 24);
        timeUntilRestart = timeUntilRestarts.filter(time => 0 <= time && time < 8);
    }
    timeUntilRestart = timeUntilRestart[0];

    if (timeUntilRestart >= 4.5)
        $('#status-bar-time').removeClass().addClass('fas fa-battery-full')
    else if (timeUntilRestart >= 3)
        $('#status-bar-time').removeClass().addClass('fas fa-battery-three-quarters')
    else if (timeUntilRestart >= 1.5)
        $('#status-bar-time').removeClass().addClass('fas fa-battery-half')
    else if (timeUntilRestart < 1.5 && timeUntilRestart > 0.16)
        $('#status-bar-time').removeClass().addClass('fas fa-battery-quarter')
    else
        $('#status-bar-time').removeClass().addClass('fas fa-battery-empty')
}








function addManageKeys(keys) {
    for (let key in keys) {
        $('.manage-keys-house').text(keys[key].sharedHouseName);
        let manageHouseKey = `
            <li class="collection-item">
                <div class="row no-padding">
                    <div class="col s9" aria-label="${keys[key].sharedName}" data-balloon-pos="down">
                        <span  class="truncate" style="font-weight:bold">${keys[key].sharedName + "Longernamehereoklolasdasd"}</span>
                    </div>
                    <div class="col s3 right-align">
                        <span class="phone-button manage-keys-remove" data-target-id="${keys[key].sharedId}" aria-label="Remove Key" data-balloon-pos="left"><i class="fas red-text fa-user-times fa-2x"></i></span>
                    </div>
                </div>
                <div class="row no-padding">
                    <div class="col s12">
                        <span>Citizen ID: ${keys[key].sharedId}</span>
                    </div>
                </div>
            </li>
        `

        $('.manage-keys-entries').append(manageHouseKey);
    }
}



function addKeys(keys) {
    for (const [ keyType, value ] of Object.entries(keys)) {
        for (const [ data, v ] of Object.entries(value)) {
            let penis = keys[keyType][data][0]
            var keyElement = `
            <li data-key-type="${keyType}">
                <div class="collapsible-header">
                    <span class="left">
                    <i class="fas ${keyType === "sharedKeys" ? "fa-handshake" : "fa-key"}"> </i>
                    ${penis.house_name}</span>
                    <div class="col s2 right-align">
                        <i class="fas fa-map-marker-alt teal-text gps-location-click" data-house-type="${penis.house_model}" data-house-id="${penis.house_id}"></i>
                    </div>
                </div>
                <div class="collapsible-body garage-body">
                    <div class="row">
                        <div class="col s12">
                            <ul class="collection">`
                keyElement += `
                                </ul>
                            </div>
                        </div>
                        `
            if (keyType === "ownedKeys") {
                keyElement += `
                        <div class="row no-padding">
                            <div class="col s12 center-align no-padding button-row" >
                            <button class="waves-effect waves-light btn-small phone-button" data-action="btnGiveKey" aria-label="Give Keys" data-balloon-pos="up"><i class="fas fa-key"></i></button>
                            <button class="waves-effect waves-light btn-small manage-keys" aria-label="Manage Keys" data-balloon-pos="up"><i class="fas fa-user-slash"></i></button>
                            <button class="waves-effect waves-light btn-small phone-button" data-action="btnPayMortgage" aria-label="Pay Mortgage" data-balloon-pos="up-left"><i class="fas fa-dollar-sign"></i></button>
                            <button class="waves-effect waves-light btn-small phone-button" data-action="btnFurniture" aria-label="Furniture" data-balloon-pos="up"><i class="fas fa-couch"></i></button>
                            <button class="waves-effect waves-light btn-small phone-button" data-action="btnPropertyOutstanding" aria-label="Check Mortgage" data-balloon-pos="up-left"><i class="fas fa-check"></i></button>
                            </div>
                        </div>
                        `
            } else if (keyType == "sharedKeys") {
                keyElement += `
                <div class="row no-padding">
                    <div class="col s12 center-align no-padding">
                        <button class="waves-effect waves-light btn-small remove-shared-key" data-house-id="${penis.house_id}" data-house-model="${penis.house_model}" aria-label="Remove key" data-balloon-pos="up"><i class="fas fa-user-slash"></i></button>
                    </div>
                </div>
                `
            }

            keyElement += `
                </div>
            </li>
        `
            $('.keys-entries').append(keyElement);
        }
    }

}

function openBrowser(url) {
    $("#browser object").attr("data", url);
    closePhoneShell();
    $.post('https://caue-phone/btnCamera', JSON.stringify({}));
    $("#browser").fadeIn(300);
}

function setWeather(weather) {
    let weatherIcon = "fas fa-sun"
    switch (weather) {
        case "EXTRASUNNY":
        case "CLEAR":
            weatherIcon = "fas fa-sun"
            break;
        case "THUNDER":
            weatherIcon = "fas fa-poo-storm"
            break;
        case "CLEARING":
        case "OVERCAST":
            weatherIcon = "fas fa-cloud-sun-rain"
            break;
        case "CLOUD":
            weatherIcon = "fas fa-cloud"
            break;
        case "RAIN":
            weatherIcon = "fas fa-cloud-rain"
            break;
        case "SMOG":
        case "FOGGY":
            weatherIcon = "fas fa-smog"
            break;
    }
    $('.status-bar-weather').empty();
    $('.status-bar-weather').append(`<i class="${weatherIcon}"></i>`);
}

function addGPSLocations(locations) {
    let unorderedAdressess = []
    for (let location of Object.keys(locations)) {
        let houseType = parseInt(locations[location].houseType);
        let houseInfo = locations[location].info;
        if (houseInfo !== undefined) {
            for (let i = 0; i < houseInfo.length; i++) {

                const houseMapping = {
                    1: { type: 'House', icon: 'fas fa-home' },
                    2: { type: 'Mansion', icon: 'fas fa-hotel' },
                    3: { type: 'Rented', icon: 'fas fa-key' },
                    69: { type: 'Misc', icon: 'fas fa-info' }
                }
                let address = escapeHtml(houseType == 3 ? houseInfo[i].name : houseInfo[i].info)
                unorderedAdressess.push({
                    address: address.trimStart(),
                    houseId: i + 1,
                    houseIcon: houseMapping[houseType].icon,
                    houseType: houseMapping[houseType].type,
                    houseTypeId: houseType
                })
            }
        }
    }
    unorderedAdressess.sort((a, b) => a.address.localeCompare(b.address))
    for (let j = 0; j < unorderedAdressess.length; j++) {
        let htmlData = `<li class="collection-item" data-house-type="${unorderedAdressess[j].houseType}">
                            <div>
                                <span aria-label="${unorderedAdressess[j].houseType}" data-balloon-pos="right"><i class="${unorderedAdressess[j].houseIcon}"></i></span> ${unorderedAdressess[j].address}
                                <span class="secondary-content gps-location-click" data-house-type=${unorderedAdressess[j].houseTypeId} data-house-id="${unorderedAdressess[j].houseId}"><i class="fas fa-map-marker-alt"></i></span>
                            </div>
                        </li>`
        $('.gps-entries').append(htmlData);
    }
}

function KeysFilter() {
    var filter = $('#keys-search').val();
    $("ul.keys-entries li").each(function () {
        if ($(this).text().search(new RegExp(filter, "i")) < 0) {
            $(this).hide();
        } else {
            if (keyFilters.includes($(this).data('key-type')))
                $(this).hide();
            else
                $(this).show()
        }
    });
}

function GPSFilter() {
    var filter = $('#gps-search').val();
    $("ul.gps-entries li").each(function () {
        if ($(this).text().search(new RegExp(filter, "i")) < 0) {
            $(this).hide();
        } else {
            if (gpsFilters.includes($(this).data('house-type')))
                $(this).hide();
            else
                $(this).show()
        }
    });
}

function ManageKeysFilter() {
    var filter = $('#manage-keys-search').val();
    $("ul.manage-keys-entries li").each(function () {
        if ($(this).text().search(new RegExp(filter, "i")) < 0) {
            $(this).hide();
        } else {
            $(this).show()
        }
    });
}




























$('#manage-keys-search').keyup(debounce(function () {
    ManageKeysFilter();
}, 500));

$('#keys-search').keyup(debounce(function () {
    KeysFilter();
}, 500));

$('#gps-search').keyup(debounce(function () {
    GPSFilter();
}, 500));














$("#real-estate-sell-form").submit(function (e) {
    e.preventDefault();
    $.post('https://caue-phone/btnAttemptHouseSale', JSON.stringify({
        cid: escapeHtml($("#real-estate-sell-form #real-estate-sell-id").val()),
        price: escapeHtml($("#real-estate-sell-form #real-estate-sell-amount").val()),
    }));

    $('#real-estate-sell-form').trigger('reset');
    $('#real-estate-sell-modal').modal('close');
});

$('#real-estate-transfer-form').submit(function (e) {
    e.preventDefault();
    $.post('https://caue-phone/btnTransferHouse', JSON.stringify({
        cid: escapeHtml($("#real-estate-transfer-form #real-estate-transfer-id").val()),
    }));
    $('#real-estate-transfer-form').trigger('reset');
    $('#real-estate-transfer-modal').modal('close');
});








$("#contacts-form").submit(function (e) {
    e.preventDefault();
    var escapedName = escapeHtml($("#contacts-form #contacts-new-name").val());
    var clean = escapedName.replace(/[^0-9A-Z]+/gi, "");

    $.post('https://caue-phone/newContactSubmit', JSON.stringify({
        name: clean,
        number: escapeHtml($("#contacts-form #contacts-new-number").val())
    }));

    if (currentContainer === "message") {
        $(".message-recipient").empty();
        $(".message-recipient").append(clean);
    }

    $('#contacts-form').trigger('reset');
    $('#contacts-add-new').modal('close');
});

$("#call-form").submit(function (event) {
    event.preventDefault();
    $.post('https://caue-phone/callContact', JSON.stringify({
        name: '',
        number: escapeHtml($("#call-form #call-number").val())
    }));
    $("#call-form").trigger("reset");
    $('#call-modal').modal('close');
});

$("#yellow-pages-form").submit(function (event) {
    event.preventDefault();
    $.post('https://caue-phone/newPostSubmit', JSON.stringify({
        advert: escapeHtml($("#yellow-pages-form #yellow-pages-body").val())
    }));
    $("#yellow-pages-form #yellow-pages-body").attr("style", "").val('')
    $('#yellow-pages-modal').modal('close');
});

$("#new-message-form").submit(function (event) {
    event.preventDefault();

    $.post('https://caue-phone/newMessageSubmit', JSON.stringify({
        number: escapeHtml($("#new-message-form #new-message-number").val()),
        message: escapeHtml($("#new-message-form #new-message-body").val())
    }));

    $('#new-message-form').trigger('reset');
    M.textareaAutoResize($('#new-message-body'));
    $('#messages-send-modal').modal('close');
    switch (currentContainer) {
        case "message":
            setTimeout(function () {
                let sender = $('.message-entries').data("sender");
                let receiver = $('.message-entries').data("clientNumber")
                let displayName = $('.message-entries').data("displayName")
                $.post('https://caue-phone/messageRead', JSON.stringify({ sender: sender, receiver: receiver, displayName: displayName }));
            }, 300);
            break;
        case "messages":
            setTimeout(function () {
                $.post('https://caue-phone/messages', JSON.stringify({}));
            }, 300);
            break;
    }
    //M.toast({ html: 'Message Sent!' });
});




$('#real-estate-evict-modal-accept').click(function () {
    $.post('https://caue-phone/btnEvictHouse', JSON.stringify({}));
    $('#real-estate-evict-modal-').modal('close');
});


$('.keys-toggle-filter').click(function () {
    let filterData = $(this).data('filter');

    if ($(this).hasClass("grey-text")) {
        if (!keyFilters.includes(filterData))
            keyFilters.push(filterData);
    }
    else
        keyFilters = keyFilters.filter(filter => filter !== filterData);

    KeysFilter();
    $(this).toggleClass("grey-text white-text");
});

$('.gps-toggle-filter').click(function () {
    let filterData = $(this).data('filter');

    if ($(this).hasClass("grey-text")) {
        if (!gpsFilters.includes(filterData))
            gpsFilters.push(filterData);
    }
    else
        gpsFilters = gpsFilters.filter(filter => filter !== filterData);

    GPSFilter();
    $(this).toggleClass("grey-text white-text");
});



$('.messages-call-contact').click(function () {
    $.post('https://caue-phone/callContact', JSON.stringify({
        name: $('.message-entries').data('displayName'),
        number: $('.message-entries').data('sender')
    }));
});

$('.messages-add-new-contact').click(function () {
    $('#contacts-add-new').modal('open');
    $('#contacts-add-new #contacts-new-number').val($('.message-entries').data('sender'));
    M.updateTextFields();
});



$('.keys-entries').on('click', '.manage-keys', function () {
    $.post('https://caue-phone/retrieveHouseKeys', JSON.stringify({}));
});

$('.keys-entries').on('click', '.remove-shared-key', function(e) {
    $.post('https://caue-phone/removeSharedKey', JSON.stringify({
        house_id: $(this).data('house-id'),
        house_model: $(this).data('house-model')
    }))
    $(this).closest('li').remove()
});

$('.manage-keys-entries').on('click', '.manage-keys-remove', function () {
    $.post('https://caue-phone/removeHouseKey', JSON.stringify({
        targetId: $(this).data('target-id')
    }))
    $.post('https://caue-phone/retrieveHouseKeys', JSON.stringify({}));
})

$('.yellow-pages-entries').on('click', '.yellow-pages-call', function () {
    $.post('https://caue-phone/callContact', JSON.stringify({
        name: '',
        number: $(this).data('number')
    }));
});











$('.gps-entries, .keys-entries').on('click', '.gps-location-click', function () {
    $.post('https://caue-phone/loadUserGPS', JSON.stringify({ house_id: $(this).data('house-id'), house_type: $(this).data('house-type') }));
})



$('#confirm-modal-accept').click(function (event) {
    $.post('https://caue-phone/removeContact', JSON.stringify({ name: $(this).data('name'), number: $(this).data('number') }));
    $('#confirm-modal').modal('close');
});

$('.dial-button').click(function (e) {
    if ($('#call-number').val().length < 10)
        $('#call-number').val(parseInt($('#call-number').val().toString() + $(this).text()));
    M.updateTextFields();
});




function openContainer(containerName, fadeInTime = 500, ...args) {
    closeContainer(currentContainer, (currentContainer !== containerName ? 300 : 0));
    $("." + containerName + "-container").hide().fadeIn((currentContainer !== containerName ? fadeInTime : 0));
    if (containerName === "home") {
        $(".phone-screen .rounded-square:not('.hidden-buttons')").each(function () {
            $(this).fadeIn(1000);
        });
        $(".navigation-menu").fadeTo("slow", 0.5, null);
    }
    else
        $(".navigation-menu").fadeTo("slow", 1, null);

    if (containerName === "message")
        $('.message-entries-wrapper').animate({
            scrollTop: $('.message-entries-wrapper')[0].scrollHeight
        }, 0);

    if (args[0] === undefined) {
        oldContainerHistory.push(currentContainer);
    }
    currentContainer = containerName;
}

function closeContainer(containerName, fadeOutTime = 500) {
    $.when($("." + containerName + "-container").fadeOut(fadeOutTime).hide()).then(function () {
        if (containerName === "home")
            $(".phone-screen .rounded-square").each(function () {
                $(this).fadeIn(300);
            });
    });
}

function phoneCallerScreenSetup() {
    switch (callStates[currentCallState]) {
        case "isNotInCall":
            if (currentContainer === "incoming-call") {
                currentCallState = 0;
                currentCallInfo = "";
                openContainer("home");
            }
            break;
        case "isDialing":
            $('.incoming-call-header-caller').text("Outgoing call");
            $('.caller').text(currentCallInfo);
            $(".btnAnswer").fadeOut(0);
            $(".btnHangup").fadeIn(0);
            openContainer('incoming-call');
            break;
        case "isReceivingCall":
            $('.incoming-call-header-caller').text("Incoming call");
            $('.caller').text(currentCallInfo);
            $(".btnAnswer").fadeIn(0);
            $(".btnHangup").fadeIn(0);
            openContainer('incoming-call');
            break;
        case "isCallInProgress":
            $('.incoming-call-header-caller').text("Ongoing call");
            $('.caller').text(currentCallInfo);
            $(".btnAnswer").fadeOut(0);
            $(".btnHangup").fadeIn(0);
            break;
    }
}

function openPhoneShell() {
    BottomSlideUp(".phone-shell", 350, 0);

    phoneOpen = true;
}

function closePhoneShell() {
    if (NotificationOpen == true) {
        BottomSlideUp(".phone-shell", 350, -55);
    } else {
        BottomSlideDown(".phone-shell", 350, -70);
    }

    phoneOpen = false;
}



var entityMap = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
    '/': '&#x2F;',
    '`': '&#x60;',
    '=': '&#x3D;'
};

function escapeHtml(string) {
    return String(string).replace(/[&<>"'`=\/]/g, function (s) {
        return entityMap[s];
    });
}