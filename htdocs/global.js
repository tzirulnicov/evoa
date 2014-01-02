function OpenCloseSec(secid) {
 LiId = "Li"+secid;
 UlId = "Ul"+secid;

 if (document.getElementById(UlId).style.display == "block"){
  document.getElementById(LiId).className="";
  document.getElementById(UlId).style.display="none";
 } else{
  document.getElementById(LiId).className="Open";
  document.getElementById(UlId).style.display="block";
 }
 Footer();
}

$(document).ready(function(){
 Footer();
 
 $("div#ChooseRegion").hover(function () {
  $("div#RegionAndLanguage").slideDown("slow");
 }, function () {
  $("div#RegionAndLanguage").slideUp("slow");
 }); 

});

$(window).resize(function(){ Footer(); });

function Footer(){
 var heightbody = $(window).height() - 107;
 var heightcontentleft = $("div#ContentLeft").height()+180;
 var heightcontentcenter = $("div#ContentCenter").height()+180;
 var heightcontentright = $("div#ContentRight").height()+225;
 var footertop = heightbody;
 if (footertop < heightcontentleft) {footertop = heightcontentleft;}
 if (footertop < heightcontentcenter) {footertop = heightcontentcenter;}
 if (footertop < heightcontentright) {footertop = heightcontentright;}
 $("div#Footer").css("top",footertop+"px");
 $("div#Footer").css("display","block");
 $("div#Main").css("height",footertop+90+"px");
}

$(document).ready(function(){  
 // When a link is clicked  
 $("li.Tab").click(function () {
  // switch all tabs off  
  $(".Activ").removeClass("Activ");  
  // switch this tab on  
  $(this).addClass("Activ");  
 });  

 $("li.TabCh").click(function () {
  $("li.TabCh").removeClass("Activ");  
  $(this).addClass("Activ");  
 }); 
 $("li#Tab1").click(function () {
  $("div#TabContent1").removeClass("Off");  
  $("div#TabContent2").addClass("Off");  
 });  
 $("li#Tab2").click(function () {
  $("div#TabContent2").removeClass("Off");  
  $("div#TabContent1").addClass("Off");  
 });  
				   
});  
