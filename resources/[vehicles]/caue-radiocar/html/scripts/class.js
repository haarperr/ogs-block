var yPlayer = null;

function updateName(url){
    if(getYoutubeUrlId(url) === "")
	{
        $("#nameSong").text(editString(url));
    }else{
		yPlayer = new YT.Player("trash",
        {
            height: '0',
            width: '0',
            videoId: getYoutubeUrlId(url),
            events:
            {
                'onReady': function(event){
                    getName(event.target.getVideoData().title);
                },
            }
        });
    }
}

function getYoutubeUrlId(url)
{
    var videoId = "";
    if( url.indexOf("youtube") !== -1 ){
        var urlParts = url.split("?v=");
        videoId = urlParts[1].substring(0,11);
    }

    if( url.indexOf("youtu.be") !== -1 ){
        var urlParts = url.replace("//", "").split("/");
        videoId = urlParts[1].substring(0,11);
    }
    return videoId;
}

function editString(string){
    var str = string;
    var res = str.split("/");
    var final = res[res.length - 1];
    final = final.replace(".mp3", " ");
    final = final.replace(".wav", " ");
    final = final.replace(".wma", " ");
    final = final.replace(".wmv", " ");

    final = final.replace(".aac", " ");
    final = final.replace(".ac3", " ");
    final = final.replace(".aif", " ");
    final = final.replace(".ogg", " ");
    final = final.replace("%20", " ");
    final = final.replace("-", " ");
    final = final.replace("_", " ");
    return final;
}

function getName(name){
    $("#nameSong").text(name);
    if (this.yPlayer) {
        if (typeof this.yPlayer.stopVideo === "function" && typeof this.yPlayer.destroy === "function") {
            yPlayer.stopVideo();
            yPlayer.destroy();
        }
    }
}