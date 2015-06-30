  var analyser = null;
  var audioContext = null;
  var mediaStreamSource = null;
  var filter = null;
  var frequencyData = null;
  var timeIntervall = null;
  var tabMessage = [];
  var compteur = 0;
  var frequency = 0;

  var repeat = 0;


    // success callback when requesting audio input stream
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

  function errorStream(){
    alert('Something went wrong :/');
  }


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
      //console.log(Math.round(currentFrequency));
      if (currentFrequency>17500){
        console.log(String.fromCharCode(32 + Math.round(((currentFrequency-17959)/43.066))));
        if (frequency >= currentFrequency-5 || frequency <= currentFrequency+5){
          compteur++;
        }
        else{
          compteur = 0;
        }

        if (compteur>10){
          //console.log("valide :" + frequency);
          compteur = 0;
          changeImage(frequency);
        }

        frequency=currentFrequency;
        /*
        console.log(currentFrequency);
        tabMessage[tabMessage.length]=String.fromCharCode(32 + Math.round(((currentFrequency-17959)/43.066)));
        */
        //console.log(String.fromCharCode(32 + Math.round(((currentFrequency-17959)/43.066))));
        
      }
    }

    raf(update);
  }

  function raf(callback) {
    setTimeout(callback, 10);

  }

  function kill(){
    console.log("Arret de la boucle");
    clearInterval(timeIntervall);
  }


  //Fonction use to change the image in function of the received frequency
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







