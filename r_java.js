//because identity is in base
ocpu.seturl("//public.opencpu.org/ocpu/library/base/R")

//actual handler
$("#submitbutton").on("click", function(){

    //arguments
    var mysnippet = new ocpu.Snippet($("#input").val());
    
    //disable button
    $("button").attr("disabled", "disabled");

    //perform the request
    var req = ocpu.call("identity", {
        "x" : mysnippet
    }, function(session){
        session.getConsole(function(outtxt){
            $("#output").text(outtxt); 
        });
    });
        
    //if R returns an error, alert the error message
    req.fail(function(){
        alert("Server error: " + req.responseText);
    });      
    
    req.always(function(){
        $("button").removeAttr("disabled");    
    });
});    