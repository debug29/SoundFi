
  var audioContext = null;

    // success callback when requesting audio input stream
  function gotStream(stream) {
      window.AudioContext = window.AudioContext || window.webkitAudioContext;
      audioContext = new AudioContext();
      console.log(audioContext.sampleRate);

  }

  function errorStream(){
    alert('Something went wrong :/');
  }


function sendTone(freq, startTime, duration){
  
  if (startTime==null)
    startTime=audioContext.currentTime;
  if (duration==null)
    duration=0.5;

  console.log("Freq :" +freq);
  console.log("Debut :" +startTime);
  console.log("Duree :" +duration);

  var gainNode = audioContext.createGainNode();
  // Gain => Merger
  gainNode.gain.value = 1;

  
  gainNode.gain.setValueAtTime(0, startTime);
  gainNode.gain.linearRampToValueAtTime(1, startTime + 0.001);
  gainNode.gain.setValueAtTime(1, startTime + duration - 0.001);
  gainNode.gain.linearRampToValueAtTime(0, startTime + duration);
  
  gainNode.connect(audioContext.destination);

  var osc = audioContext.createOscillator();
  osc.frequency.value = freq;
  osc.connect(gainNode);

  osc.start(startTime);
}

  navigator.getUserMedia = navigator.getUserMedia       ||
                          navigator.webkitGetUserMedia  ||
                          navigator.mozGetUserMedia     ||
                          navigator.msGetUserMedia;

  navigator.getUserMedia( {audio:true}, gotStream,errorStream);



