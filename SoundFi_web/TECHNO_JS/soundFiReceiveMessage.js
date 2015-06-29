  /**
    * SoundFi.js est une démonstration de la techno SoundFi sur une techno web.
    * Ce script permet la réception d'un message envoyer par ultrason sur une plage 
    * de fréquence spécifique de 18kHz à 22kHz avec 43 Hz d'interval.
    @author François Le Brun
  */

  var analyser = null;
  var audioContext = null;
  var mediaStreamSource = null;
  var filter = null;
  var frequencyData = null;
  var timeIntervall = null;
  var message = "";
  var compteur = 0;
  var frequency = 0;
  var dateTimeOut = null;

  var DEBUG = false;
  var repeat = 0;

  var messageStart = false;

  
    /**
      * @function
      * @name gotStream
      * @description Cette fonction permet d'initialiser le chemin audio (le graph) qui va définir le chemin qu'un échetillon audio va effectuer de l'entrée à la sortie.
      * @param  Stream utilisé par le navigateur
      * @see [navigator.getUserMedia]{@link https://developer.mozilla.org/en-US/docs/Web/API/Navigator.getUserMedia}
    */
  function gotStream(stream) {
      window.AudioContext = window.AudioContext || window.webkitAudioContext;
      audioContext = new AudioContext();
      console.log(audioContext.sampleRate);
      // Create an AudioNode from the stream.
      mediaStreamSource = audioContext.createMediaStreamSource( stream );

      //Create an high pass filter
      filter = audioContext.createBiquadFilter();
      filter.frequency.value = 17500.0;
      filter.type = "highpass";
      filter.Q = 10.0;

      mediaStreamSource.connect(filter)
      
      //Create an analyser
      analyser = audioContext.createAnalyser();
      analyser.fftSize=2048;
      analyser.minDecibels = -90;
      console.log(analyser.fftSize);
      console.log(analyser.frequencyBinCount);
      frequencyData = new Float32Array(analyser.frequencyBinCount);
      filter.connect(analyser);

      raf(update);    
  }

    /**
      * @function
      * @name errorStream
      * @description Cette fonction est appelé lorsque le stream n'a pas réussi à s'initialiser
      * @see [navigator.getUserMedia]{@link https://developer.mozilla.org/en-US/docs/Web/API/Navigator.getUserMedia}
    */
  function errorStream(){
    alert('Something went wrong :/');
  }

    /**
      * @function
      * @name update
      * @description Cette fonction est appelé régulièrement et permet la récupération périodique des informations en provenance du graph audio
      * @see {@link raf}
    */
  function update(){
    analyser.getFloatFrequencyData(frequencyData);
    var maxBin=frequencyData[0];
    var index=0;
    var nbrRepeatRequire = null;

    // Recherche du pic
    for(var i=0;i<frequencyData.length;i++){
      if(frequencyData[i]>maxBin && frequencyData[i]>-100){
        maxBin=frequencyData[i];
        index=i;
      }
      i++;

    }

    if (index!=0){
      var currentFrequency = ((audioContext.sampleRate / 2.) / frequencyData.length) * index;
      currentFrequency = Math.round(currentFrequency);
      if (currentFrequency>17500){
        dateTimeOut = new Date();
        if (DEBUG) {
          console.log(Math.round(currentFrequency));
          console.log(String.fromCharCode(32 + Math.round(((currentFrequency-17959)/43.066))));
        }
        if (frequency >= currentFrequency-5 || frequency <= currentFrequency+5){
          compteur++;
        }
        else{
          compteur = 0;
        }

        if (messageStart)
          nbrRepeatRequire = 3;
        else
          nbrRepeatRequire = 15;

        if (compteur>nbrRepeatRequire){
            if (DEBUG)
              console.log("true Story  " + currentFrequency);
            if(currentFrequency==17829 && !messageStart){
              messageStart = true;
            }
            else if (currentFrequency==17700){
              if (messageStart)
                analysis(message);
              messageStart = false;
            }

            if (messageStart && currentFrequency>=17959 && currentFrequency<=22007){
              if (DEBUG)
                console.log(String.fromCharCode(32 + Math.round(((currentFrequency-17959)/43.066))));
              message = message + String.fromCharCode(32 + Math.round(((currentFrequency-17959)/43.066)));
            }
            compteur = 0;
        }

        frequency=currentFrequency;
        
      }
    }

    if (messageStart) {
      var testDate = new Date();
      if ( testDate.getTime() - dateTimeOut.getTime() > 1000) {
        console.log("TimeOut");
        messageStart=false;
        analysis(message);
      }
    }

    raf(update);
  }

    /**
      * @function
      * @name raf
      * @description Cette fonction est appelé afin de gérer le temps entre deux appels de la fonction update
      * @see {@link update}
    */
  function raf(callback) {
    setTimeout(callback, 10);

  }

  // Useless should be deleted
  function kill(){}


    /**
      * @function
      * @name analysis
      * @description Cette fonction est appelé afin d'analyser le message qui a été reçu 
      * @param  message_ Le message non traité qui à été reçu lors de la phase d'écoute et qui va être parsé afin de supprimé les erreurs
        et les doublons.
      * @see {@link update}
    */
  function analysis(message_){
    console.log("This is : " + message_);
    var currentChar = null;
    var previousChar = null;
    var lastValideChar = null;
    var finalMessage = "";
    var repeatCount = 0;

    for (var i = 0; i < message_.length; i++) {
      currentChar = message_[i];
      if(currentChar==previousChar){
        if (currentChar != lastValideChar){
          lastValideChar = currentChar;
          finalMessage = finalMessage + currentChar;
          repeatCount = 0;
        }
        else {
          repeatCount ++;
          if (DEBUG)
            console.log("plop" + repeatCount);
          if (repeatCount >= 8) {
            finalMessage = finalMessage + lastValideChar;
            repeatCount = 0;
          }
        }
      }

      if (DEBUG)
        console.log(message_[i]);
      previousChar = currentChar;
    };

    console.log(finalMessage);
    message= "";

    document.getElementById('listeMessage').innerHTML = document.getElementById('listeMessage').innerHTML + "</br>" + finalMessage;

  }


    /**
      * @function
      * @name info
      * @description Cette fonction est utile seulement pour debug, elle permet l'affichage des données en temps réel lors de son appelle. 
        Attention cette fonction lance un grand nombre de log, ne pas en abuser ^^
    */
  function info(){
    var arrayTemp = new Float32Array(1024);
    var arrayTemp2 = new Float32Array(2048);
    analyser.getFloatFrequencyData(arrayTemp);
    analyser.getFloatTimeDomainData(arrayTemp2);
    console.log("FrequencyDomain");
    for(var i=0;i<arrayTemp.length;i++){
      console.log(arrayTemp[i]);
    }
    console.log("TimeDomain");
    for(var i=0;i<arrayTemp2.length;i++){
      console.log(arrayTemp2[i]);
    }

  }


  navigator.getUserMedia = navigator.getUserMedia       ||
                          navigator.webkitGetUserMedia  ||
                          navigator.mozGetUserMedia     ||
                          navigator.msGetUserMedia;

  navigator.getUserMedia( {audio:true}, gotStream,errorStream);







