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

  var repeat = 0;

  var messageStart = false;

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
        //console.log(Math.round(currentFrequency));
        //console.log(String.fromCharCode(32 + Math.round(((currentFrequency-17959)/43.066))));
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
            //console.log("true Story  " + currentFrequency);
            if(currentFrequency==17829 && !messageStart){
              messageStart = true;
            }
            else if (currentFrequency==17700){
              if (messageStart)
                analysis(message);
              messageStart = false;
            }

            if (messageStart && currentFrequency>=17959 && currentFrequency<=22007){
              //console.log(String.fromCharCode(32 + Math.round(((currentFrequency-17959)/43.066))));
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

  function raf(callback) {
    setTimeout(callback, 10);

  }

  function kill(){
    console.log("Arret de la boucle");
    clearInterval(timeIntervall);
  }

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
          //console.log("plop" + repeatCount);
          if (repeatCount >= 8) {
            finalMessage = finalMessage + lastValideChar;
            repeatCount = 0;
          }
        }
      }

      //console.log(message_[i]);
      previousChar = currentChar;
    };

    console.log(finalMessage);
    message= "";

    document.getElementById('listeMessage').innerHTML = document.getElementById('listeMessage').innerHTML + "</br>" + finalMessage;

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







