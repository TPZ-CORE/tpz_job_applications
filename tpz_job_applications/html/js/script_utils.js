
function playAudio(sound) {
	var audio = new Audio('./audio/' + sound);
	audio.volume = Config.DefaultClickSoundVolume;
	audio.play();
}

const loadScript = (FILE_URL, async = true, type = "text/javascript") => {
  return new Promise((resolve, reject) => {
      try {
          const scriptEle = document.createElement("script");
          scriptEle.type = type;
          scriptEle.async = async;
          scriptEle.src =FILE_URL;

          scriptEle.addEventListener("load", (ev) => {
              resolve({ status: true });
          });

          scriptEle.addEventListener("error", (ev) => {
              reject({
                  status: false,
                  message: `Failed to load the script ${FILE_URL}`
              });
          });

          document.body.appendChild(scriptEle);
      } catch (error) {
          reject(error);
      }
  });
};

loadScript("js/locales/locales-" + Config.Locale + ".js").then( data  => { 

  $("#applications").hide();

  displayPage("create", "visible");
  $(".create").fadeOut();

  displayPage("overview", "visible");
  $(".overview").fadeOut();

  displayPage("management", "visible");
  $(".management").fadeOut();

  $("#title").text(Locales.Title);
  $("#description").text(Locales.Description);

  $("#author-date").text(Locales.Date);
  $("#author-signature").text(Locales.Signature);

  $("#create-job-applications-submit").text(Locales.SignToSubmit);

  $("#overview-job-application-receive").text(Locales.Receive);
  $("#overview-job-application-delete").text(Locales.Delete);

  $("#overview-job-application-approve").text(Locales.Approve);
  $("#overview-job-application-reject").text(Locales.Reject);

  $("#overview-job-application-receive").hide();
  $("#overview-job-application-delete").hide();

  $("#overview-job-application-approve").hide();
  $("#overview-job-application-reject").hide();

}) .catch( err => { console.error(err); });

function displayPage(page, cb){
  document.getElementsByClassName(page)[0].style.visibility = cb;

  [].forEach.call(document.querySelectorAll('.' + page), function (el) {
    el.style.visibility = cb;
  });
}

function load(src) {
  return new Promise((resolve, reject) => {
      const image = new Image();
      image.addEventListener('load', resolve);
      image.addEventListener('error', reject);
      image.src = src;
  });
}