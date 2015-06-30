  /**
    * SoundFi.js est une démonstration de la techno SoundFi sur une techno web.
    * Ce script permet l'affichage d'une image en fonction de la fréquence reçu d'un
    * téléphone mobile ou d'un autre ordinateur utilisant soundFi.
    @author François Le Brun
  */

  var analyser = null;
  var audioContext = null;
  var mediaStreamSource = null;
  var filter = null;
  var frequencyData = null;
  var timeIntervall = null;
  var tabMessage = [];
  var compteur = 0;
  var frequency = 0;
  var DEBUG = false;
  var repeat = 0;


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
      if (DEBUG)
        console.log(Math.round(currentFrequency));
      if (currentFrequency>17500){
        console.log(String.fromCharCode(32 + Math.round(((currentFrequency-17959)/43.066))));
        if (frequency >= currentFrequency-5 || frequency <= currentFrequency+5){
          compteur++;
        }
        else{
          compteur = 0;
        }

        if (compteur>10){
          if (DEBUG)
            console.log("valide :" + frequency);
          compteur = 0;
          changeImage(frequency);
        }

        frequency=currentFrequency;
        if (DEBUG){
          console.log(currentFrequency);
          tabMessage[tabMessage.length]=String.fromCharCode(32 + Math.round(((currentFrequency-17959)/43.066)));
          console.log(String.fromCharCode(32 + Math.round(((currentFrequency-17959)/43.066))));
        }
        
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
      * @name changeImage
      * @description Cette fonction n'est pas partie intégrante de la technologie soundfi et permet une simple représentation visuel de ce que l'on peut en faire,
        elle permet l'affichage d'une image en fonction d'une fréquence reçu.
      * @param  freq La fréquence que l'on souhaite transformer en image
    */
  function changeImage(freq){
    var indexFreq = Math.round((freq - 17959)/43);
    var img = document.getElementById("imageTest");

    switch(indexFreq){
      case 48:
        img.src="./img/fr.png";
        console.log("48");
      break;
      case 49:
        img.src="./img/al.png";
        console.log("49");
      break;
      case 50:
        img.src="./img/it.png";
        console.log("50");
      break;
      case 51:
        img.src="./img/sp.png";
        console.log("51");
      break;
      case 52:
        img.src="./img/uk.png";
        console.log("52");
      break;
      case 53:
        img.src="./img/yolo.png";
        console.log("53");
        document.getElementById("mp3").play();
        document.body.style.background = "pink";
      break;

    }

  }


  // Use only for DEBUG
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







