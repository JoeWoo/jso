 var wsServer = 'ws://localhost:10081/';

 $(document).ready(function() {
    $('#showstat4').modal('toggle');
     Connection();
 });

 var ws;
 var SocketCreated = false;
 var oldactiveli = "liall";

 function Connection() {
     if (SocketCreated && (ws.readyState == 0 || ws.readyState == 1)) {
         ws.close();
     } else {
         console.log("准备连接到服务器 ...");
         try {
             var Socket = "MozWebSocket" in window ? MozWebSocket : WebSocket;
             ws = new Socket(wsServer);

             SocketCreated = true;
         } catch (ex) {
             console.log(ex, "ERROR");
             return;
         }
         //$("#ToggleConnection").innerHTML = "断开";
         ws.onopen = WSonOpen;
         ws.onmessage = WSonMessage;
         ws.onclose = WSonClose;
         ws.onerror = WSonError;
     }
 };


 function WSonOpen() {
     console.log("连接已经建立。", "OK");
     $('#showstat4').modal('toggle');

 };

 function WSonClose() {
     console.log("连接关闭。", "ERROR");
 };

 function WSonError() {
     console.log("WebSocket错误。", "ERROR");
     Connection();
 };

  function show_page(type,pagei,size) {
    if (type == "all"){
        var start = (pagei-1) * 10;
        var end = start + 9;
        if (end > size) {
            end = size;
        }
        var result="";
        for (var i = start; i <= end; i++) {
            result += $("#hidden-result #"+i).prop('outerHTML');
        }
        $("#result").html(result);
    }
 };

 function WSonMessage(evt) {
     var data = evt.data;
     if (!data) return;
     data = JSON.parse(data);
     if (!data) return;

     var cmd = data.cmd
     var stat = data.stat

     if (cmd == "get_olddir") {
         if (stat == "true") {
             $('#olddir').html(data.result)
             $('#myModal').modal('toggle')
             $('#hidden-add').html("");
         } else {
             alert("获取已有目录列表失败！");
         }


     } else if (cmd == "add_dir") {
         if (stat == "true") {
             if (data.result == "false") {
                 alert("路径已包含or路径不合法！")
             } else {
                 $('#olddir').append(data.result)
                 $('#hidden-add').append(data.result)
                 alert("添加成功！");
             }
         } else {
             alert("添加失败！");
         }


     } else if (cmd == "save_settings") {
         if (stat == "true") {
             $("#process").css("width", "100%");
             $("#process").text("100%");
             $("#pbtn").removeAttr("disabled");
         } else {
             alert("索引失败！");
         }

     } else if (cmd == "search") {
         if (stat == "true") {
             $("#count").text(data.count);
             $("#timecost").text(data.timecost);
             //$("#result").html(data.result);
             if (data.ok=="yes"){
                 $("#hidden-result").html(data.result);
                 var size = parseInt($("#hidden-result li:last-child").attr("id"));
                 var total = parseInt((size+1)/10);
                    if ((size+1)%10 != 0){
                        total += 1;
                    }
                    show_page("all",1,size);
                        var options = {
                            currentPage: 1,
                            totalPages: total,
                            bootstrapMajorVersion:3,
                            onPageClicked: function(e,originalEvent,type,page){
                                 show_page("all",page,size);
                            }
                        }
                    $('#pager').bootstrapPaginator(options);               
            }else{
                $("#result").html(data.result);
            }
            // show_page("all",1);
         } else {
             alert("查找失败！");
         }

     } else if (cmd == "bigsearch") {
         if (stat == "true") {
             var keyword = $('#querysentence').val();
             $("#big-search").css("display", "none");
             $("#search-result").css("display", "block");
             $("#keyword").val(keyword);
             $("#count").text(data.count);
             $("#timecost").text(data.timecost);
             //$("#result").html(data.result);
             if (data.ok=="yes"){
                 $("#hidden-result").html(data.result);
                    var size = parseInt($("#hidden-result li:last-child").attr("id"));
                    var total = parseInt((size+1)/10);
                    if ((size+1)%10 != 0){
                        total += 1;
                    }
                    show_page("all",1,size);
                    var options = {
                            currentPage: 1,
                            totalPages: total,
                            bootstrapMajorVersion:3,
                            onPageClicked: function(e,originalEvent,type,page){
                                 show_page("all",page,size);
                            }
                        }

                    $('#pager').bootstrapPaginator(options);      
             }else{
                $("#result").html(data.result);
             }
               
         } else {
             alert("查找失败！");
         }
     }else if (cmd == "init"){
        if (stat == "true") {
            $("#process2").css("width", "100%");
             $("#process2").text("100%");
             $("#pbtn2").removeAttr("disabled");
        }else {
            alert("初始化失败！")
        }
     }else if (cmd == "rebuild"){
        if (stat == "true") {
            $("#process3").css("width", "100%");
             $("#process3").text("100%");
             $("#pbtn3").removeAttr("disabled");
        }else {
            alert("重建失败！")
        }
     }

 };



 //click func
 function get_olddir() {
     var markers = {
         "cmd": "get_olddir"
     };
     var msg = JSON.stringify(markers);
     ws.send(msg);
     $('#hidden-add').html("");
 };

 function add_dir() {
     var dirpath = $('#dirpath').val();
     var count = $('#olddir tr:last-child td:first-child').text();
     var markers = {
         "cmd": "add_dir",
         "text": dirpath,
         "count": count
     };
     var msg = JSON.stringify(markers);
     ws.send(msg);
 };

 function search() {
     var keyword = $('#keyword').val();
     var type = oldactiveli.substring(2,oldactiveli.length);
     var markers = {
         "cmd": "search",
         "text": keyword,
         "type": type
     };
     var msg = JSON.stringify(markers);
     ws.send(msg);

 };

 function bigsearch() {
     var keyword = $('#querysentence').val();
     var markers = {
         "cmd": "bigsearch",
         "text": keyword
     };
     var msg = JSON.stringify(markers);
     ws.send(msg);

 };

 function save_settings() {
     var i = 1
     var m = ""
     $('#hidden-add tr td').each(function() {
         if (i % 2 == 0) {
             m += ($(this).text());
             m += "#";
         }
         i++;
     });
     var markers = {
         "cmd": "save_settings",
         "text": m
     };
     $("#process").css("width", "15%");
     $("#process").text("15%");
     $('#myModal').modal('toggle');
     $('#showstat').modal('toggle');
     var msg = JSON.stringify(markers);
     ws.send(msg);
 };

 function init(){
    var markers = {
         "cmd": "init",
         "text": "init"
     };
     $("#process2").css("width", "15%");
     $("#process2").text("15%");
     $('#myModal').modal('toggle');
     $('#showstat2').modal('toggle');
     var msg = JSON.stringify(markers);
     ws.send(msg);
 };

  function rebuild(){
    var markers = {
         "cmd": "rebuild",
         "text": "rebuild"
     };
     $("#process3").css("width", "15%");
     $("#process3").text("15%");
     $('#myModal').modal('toggle');
     $('#showstat3').modal('toggle');
     var msg = JSON.stringify(markers);
     ws.send(msg);
 }

 function judge_enter(father) {
     var event = arguments.callee.caller.arguments[0] || window.event;
     if (event.keyCode == 13) {
         if (father == "keyword") {
             search();
         } else if (father == "querysentence") {
             bigsearch();
         }
     }
 };

 //////////////////////////////////
 function clear_checkbox() {
     var title = $('#control-check').text();
     head = "inlineCheckbox"
     if (title == "全选") {
         for (var i = 1; i <= 8; i++) {
             $("#" + head + i).click();
             $("#" + head + i).attr("checked", "true");
         }
         $('#control-check').text("反选");
     }
     if (title == "反选") {
         for (var i = 1; i <= 8; i++) {
             $("#" + head + i).removeAttr("checked");
         }
         $('#control-check').text("全选");
     }
 };

 function direct_to_bigsearch() {
     $("#big-search").css("display", "block");
     $("#search-result").css("display", "none");
     $("#hidden-result").css("display", "none");
 };

 function active(liactive) {
    $("#"+ oldactiveli).removeClass("active");
    $("#"+liactive).addClass("active");
    oldactiveli = liactive;
    search();
 };