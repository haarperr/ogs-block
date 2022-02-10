var currentIndex = null;
var IsAllMuted = false;
var soundList = [];
var closeToPlayer = [];

var playerPos = [-90000,-90000,-90000];

var vueJS = new Vue({
	el: '.radio_cont',
	data: 
	{
		songs: [],
		visible: false,
		page: "custom",
		locales: localesex,
		volume: 30,
	},
	
	methods: {
	    changeVolume: function(minus){
	        if(minus){
                $.post('https://rcore_radiocar/volumedown', JSON.stringify({}));
	            }else{
	            $.post('https://rcore_radiocar/volumeup', JSON.stringify({}));
	        }
	    },

	    turnOffMusic: function(){
            $("#status").text(localesex.nothing);
            $("#nameSong").text(localesex.nameSong);
            $("#timeSong").text("00:00:00")
            $.post('https://rcore_radiocar/stop', JSON.stringify({}));
	    },

	    changePage: function(pg){
	        this.page = pg;
	    },

	    playCustomMusic: function(){
	        $("#status").text(localesex.playing);
            updateName($("#url").val());
            $.post('https://rcore_radiocar/play', JSON.stringify(
            {
                url: $("#url").val(),
            }));
	    },

		showIndex: function (index) {
			currentIndex = index;
		},	
		
		playMusic: function (index) {
			var url = this.songs[index].url
			updateName(url);
			$("#status").text(localesex.playing);
			$.post('https://rcore_radiocar/play', JSON.stringify({
				url: url,
			}));
		}
	}
}) 

function editSong(){
	vueJS.songs[currentIndex].label = $("#AddName").val();
	vueJS.songs[currentIndex].url = $("#AddUrl").val();
	$.post('https://rcore_radiocar/editSong', JSON.stringify({
		index: currentIndex,
		label: $("#AddName").val(),
		url: $("#AddUrl").val(),
	}));
}

$(function(){
	window.addEventListener('message', function(event) {
		var item = event.data;

        if(item.type === "volume"){
            $("#volume").text((item.volume * 100).toFixed(0) + "%")
        }

        switch(item.type)
        {
            case "position":
                playerPos = [item.x,item.y,item.z];
                break;

            case "volume":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.setVolume(item.volume);
                    sound.setMaxVolume(item.volume);
                }
                break;

            case "timestamp":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.setTimeStamp(item.timestamp);
                }
                break;

            case "max_volume":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.setMaxVolume(item.volume);
                }
                break;

            case "url":
                var sound = soundList[item.name];

                if(sound != null)
                {
                    sound.destroyYoutubeApi();
                    sound.delete();
                    sound = null;
                }

                var sd = new SoundPlayer();
                sd.setName(item.name);
                sd.setSoundUrl(item.url);
                sd.setDynamic(item.dynamic);
                sd.setLocation(item.x,item.y,item.z);
                sd.setLoop(item.loop)
                sd.create();
                sd.setVolume(item.volume);
                sd.play();
                soundList[item.name] = sd;
                break;

            case "distance":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.setDistance(item.distance);
                }
                break;

            case "play":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.delete();
                    sound.create();
                    sound.setVolume(item.volume);
                    sound.setDynamic(item.dynamic);
                    sound.setLocation(item.x,item.y,item.z);
                    sound.play();
                }
                break;

            case "soundPosition":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.setLocation(item.x,item.y,item.z);
                }
                break;

            case "resume":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.resume();
                }
                break;

            case"pause":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.pause();
                }
                break;

            case "delete":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.destroyYoutubeApi();
                    sound.delete();
                }
                break;
            case "repeat":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.setTimeStamp(0);
                    sound.play();
                }
                break;
            case "changedynamic":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.unmute()
                    sound.setDynamic(item.bool);
                    sound.setVolume(sound.getMaxVolume());
                }
                break;
            case "changeurl":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.destroyYoutubeApi();
                    sound.delete();
                    sound.setSoundUrl(item.url);
                    sound.setLoaded(false);
                    sound.create();

                    sound.play();
                }
                break;
            case "loop":
                var sound = soundList[item.name];
                if(sound != null)
                {
                    sound.setLoop(item.loop);
                }
                break;
            case "unmuteAll":
                IsAllMuted = false;
                for (var soundName in soundList)
                {
                    sound = soundList[soundName];
                    if(sound.isDynamic()){
                        sound.unmuteSilent();
                    }
                }
                updateVolumeSounds();
                break;
            case "muteAll":
                IsAllMuted = true;
                for (var soundName in soundList)
                {
                    sound = soundList[soundName];
                    if(sound.isDynamic()){
                        sound.mute();
                    }
                }
                break;

            case "ui":
			    vueJS.visible = item.status
                break;

            case "edit":
                vueJS.songs[item.index].label = item.label;
                vueJS.songs[item.index].url = item.url;
                break;

            case "clear":
                vueJS.songs = []
                break;

            case "add":
                vueJS.songs.push({
                    label: item.label,
                    url: item.url,
                });
                break;

            case "timeSong":
                var leftTime = (item.timeSong + "").toHHMMSS();
                $("#timeSong").text(leftTime.format("00:00:00"))
                break;

            case "update":
                $("#status").text(localesex.playing);
                updateName(item.url);
                break;

            case "reset":
                vueJS.locales.nothing = localesex.nothing;
                vueJS.locales.nameSong = localesex.nameSong;
                vueJS.locales.timeSong = localesex.timeSong.format("00:00:00");
                break;

            case "timeWorld":
                $("#time").text(item.timeWorld)
                break;
		}
	})

});

$(document).keyup(function(e) {
	if (e.key === "Escape") {
		$.post('https://rcore_radiocar/exit', JSON.stringify({}));
    }
});

String.prototype.toHHMMSS = function () {
    var sec_num = parseInt(this, 10); // don't forget the second param
    var hours   = Math.floor(sec_num / 3600);
    var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
    var seconds = sec_num - (hours * 3600) - (minutes * 60);

    if (hours   < 10) {hours   = "0"+hours;}
    if (minutes < 10) {minutes = "0"+minutes;}
    if (seconds < 10) {seconds = "0"+seconds;}
    return hours+':'+minutes+':'+seconds;
}

if (!String.prototype.format) {
  String.prototype.format = function(...args) {
    return this.replace(/(\{\d+\})/g, function(a) {
      return args[+(a.substr(1, a.length - 2)) || 0];
    });
  };
}


function Between(loc1,loc2)
{
	var deltaX = loc1[0] - loc2[0];
	var deltaY = loc1[1] - loc2[1];
	var deltaZ = loc1[2] - loc2[2];

	var distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);
	return distance;
}

function addToCache()
{
    if(!IsAllMuted){
        closeToPlayer = [];
        var sound = null;
        for (var soundName in soundList)
        {
            sound = soundList[soundName];
            if(sound.isDynamic())
            {
                var distance = Between(playerPos,sound.getLocation());
                var distance_max = sound.getDistance();
                if(distance < distance_max + 40)
                {
                    closeToPlayer[soundName] = soundName;
                }
                else
                {
                    if(sound.loaded()) {
                        sound.mute();
                    }
                }
            }
        }
	}
}

setInterval(addToCache, 1000);

function updateVolumeSounds()
{
    if(!IsAllMuted){
        var sound = null;
        for (var name in closeToPlayer)
        {
            sound = soundList[name];
            if(sound.isDynamic())
            {
                var distance = Between(playerPos,sound.getLocation());
                var distance_max = sound.getDistance();
                if(distance < distance_max)
                {
                    sound.updateVolume(distance,distance_max);
                    continue;
                }
                sound.mute();
            }
        }
    }
}

setInterval(updateVolumeSounds, refreshTime);