var HasCooldown = false;
var Username    = null;

var SelectedJob = null;

var SelectedApplicationId = null;

function CloseNUI() {
  toggleUI(false);

	$("#create-job-applications-list").html('');
	$("#management-submitted-applications").html('');

  $(".create").fadeOut();
  $(".overview").fadeOut();

  $(".management").fadeOut();

  HasCooldown = false;
  Username    = null;
  SelectedJob = null;
  SelectedApplicationId = null;

  $("#overview-job-application-receive").hide();
  $("#overview-job-application-delete").hide();
  $("#overview-job-application-approve").hide();
  $("#overview-job-application-reject").hide();

  $(".management").fadeOut();
  $(".management").fadeOut();

  $.post("http://tpz_job_applications/close", JSON.stringify({}));

}

function toggleUI(bool) {
  bool ? $("#applications").fadeIn() :$("#applications").fadeOut();
}

$(function() {
	window.addEventListener('message', function(event) {
		var item = event.data;

		if (item.action == "toggle") {

      toggleUI(item.toggle);

      if (item.type == "REQUEST"){

        const image = 'img/background_form.png';

        load(image).then(() => {
          document.getElementById("applications").style.backgroundImage = `url(${image})`;

          $("#title").text(Locales.Title);

          $("#create-job-application-message").val("");
  
          $("#create-job-applications-submit").text(Locales.SignToSubmit);
          $("#create-job-applications-submit").css('color', 'rgba(34, 34, 34, 0.74)');
          $("#create-job-applications-submit").css('font-family', '"Handwritten", Handwritten, serif');
          
          $(".create").fadeIn();

        });

      } else if (item.type == "APPLICATION_OVERVIEW"){


      }else if (item.type == "MANAGEMENT"){

        $('#management-submitted-applications').fadeIn();

        const image = 'img/background.png';

        load(image).then(() => {

          document.getElementById("applications").style.backgroundImage = `url(${image})`;

          $("#title").text(Locales.TitleManagement);

          $(".management").fadeIn();
          
        });

      }
		
    }

    else if (item.action == 'loadPersonalInformation'){
      Username = event.data.username;
    }

    else if (item.action == 'loadJobApplicationFromList'){

      $("#create-job-applications-list").append(
        `<div id = "content"> ` +
          `<div id="create-job-applications-list-name"> ` + item.application + "," + ` </div>` +
        `</div>` + `<div> &nbsp; </div> `
      );

    }

    else if (item.action == 'loadJobApplicationsRequest'){
      var prod_app = item.application;

      $("#management-submitted-applications").append(
        `<div id = "content"> ` +
          `<div id="management-submitted-applications-name">[` + prod_app.job + `] At ` + prod_app.date + ', ' + prod_app.username + Locales.SubmittedInfoManagement + ` </div>` +
          `<div applicationId = "` + prod_app.id + `" id="management-submitted-applications-button"> ` + Locales.PressToViewManagement + ` </div>` +
         
          `</div>` + `<div> &nbsp; </div> `
      );

    }

    else if (item.action == 'loadPersonalApplicationInformation'){

      const image = item.approved == -1 ? 'img/background_form.png' : item.approved == 0 ? 'img/background_form_pending.png' : item.approved == 1 ? 'img/background_form_approved.png' : 'img/background_form_not_approved.png'; 

      
      if (item.approved == -1) {

        $("#overview-job-application-approve").show();
        $("#overview-job-application-reject").show();

      } else if (item.approved == 1 && item.received == 0) {

        $("#overview-job-application-receive").show();

      }else if (item.approved == 2 && item.received == 0){

        $("#overview-job-application-delete").show();
      }

      load(image).then(() => {
        document.getElementById("applications").style.backgroundImage = `url(${image})`;

        $("#overview-job-application").text(item.job);
        $("#overview-job-application-message").val(item.description);
  
        $("#overview-job-application-signature").text(item.username);

        $("#title").text(Locales.TitleOverview + item.date);

        $(".overview").fadeIn();

      });
  
    }

		else if (item.action == 'clearJobApplications'){
			$("#management-submitted-applications").html('');
		}

		else if (item.action == 'close'){
			CloseNUI();
		}

	});


  $("body").on("keyup", function (key) {
    if (key.which == 27){ 

      if (SelectedApplicationId == null){
        CloseNUI(); 

      }else{
        CloseNUI(); 
        $.post("http://tpz_job_applications/openManagementList", JSON.stringify({ }));
      }
      
    } 
  });

  $("#applications").on("click", "#create-job-applications-list-name", function() {
    playAudio("button_click.wav");

    var $job = $(this).text().replace(',', '');

    SelectedJob = $job;

    let querySelectorAll = document.querySelectorAll('#create-job-applications-list-name');
    [].forEach.call(querySelectorAll, function (el) { el.style.color = "rgba(34, 34, 34, 0.74)"; });

    $(this).css('color', '#002b59');
  });


  $("#applications").on("click", "#create-job-applications-submit", function() {

    if (HasCooldown){
      return;
    }

    if (SelectedJob == null){
      return
    }

    HasCooldown = true;

    var message  = document.getElementById("create-job-application-message").value;
    let $message = message.replace(/\n/g, "\r\n"); // To retain the Line breaks.

    $("#create-job-applications-submit").text('');
    $("#create-job-applications-submit").css('color', '#0e253b');
    $("#create-job-applications-submit").css('font-family', '"Signature", Signature, serif');
    
    var text = Username;

    var writer = ""; writer.length = 0; //Clean the string
    var maxLength = text.length;
    var count = 0;
    var speed = 1000 / maxLength; //The speed of the writing depends of the quantity of text

    playAudio("scribble.mp3"); // play hand write

    var write = setInterval(function() {

      document.getElementById("create-job-applications-submit").innerHTML += text[count++];

      if ($("#create-job-applications-submit").text() == Username) {
        clearInterval(write); 

        $.post("http://tpz_job_applications/submit", JSON.stringify({ 
          job : SelectedJob,
          description : $message
        }));

      }

    }, speed);


  });


  $("#applications").on("click", "#overview-job-application-receive", function() {

    playAudio("button_click.wav");
    $.post("http://tpz_job_applications/receive", JSON.stringify({ }));

  });

  $("#applications").on("click", "#overview-job-application-delete", function() {

    playAudio("button_click.wav");
    $.post("http://tpz_job_applications/delete", JSON.stringify({ }));

  });

  /* Management */

  $("#applications").on("click", "#management-submitted-applications-button", function() {
    playAudio("button_click.wav");

    var $button = $(this);
		var $applicationId = $button.attr('applicationId');

    SelectedApplicationId = $applicationId;

    $.post("http://tpz_job_applications/manage", JSON.stringify({ 
      applicationId : $applicationId,
    }));

    $('#management-submitted-applications').fadeOut();

  });


  $("#applications").on("click", "#overview-job-application-approve", function() {

    playAudio("button_click.wav");

    $.post("http://tpz_job_applications/approve", JSON.stringify({ applicationId : SelectedApplicationId }));

  });

  $("#applications").on("click", "#overview-job-application-reject", function() {

    playAudio("button_click.wav");

    $.post("http://tpz_job_applications/reject", JSON.stringify({ applicationId : SelectedApplicationId }));

  });

});
