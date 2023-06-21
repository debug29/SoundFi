# SoundFi - Ultrasound-based Data Transfer Engine

SoundFi is an application that enables data transfer through ultrasound signals between different devices. This data transfer engine utilizes a customized version of the Fast Fourier Transform (FFT) algorithm to analyze and process audio data with high accuracy.

## How It Works

The SoundFi application follows two main steps: audio transmission and audio reception.

### Audio Transmission

During data transmission, the application generates an ultrasound signal at a specific frequency using a customized version of the FFT algorithm. This algorithm applies a high-pass filter and other modifications to the audio data before converting it into an array of numerical values representing the amplitudes of the ultrasound signal at different frequencies.

The customized FFT algorithm used for audio transmission enhances the accuracy and reliability of the ultrasound signal generation. It applies a high-pass filter to remove unwanted low-frequency components and focuses on the specific frequency range required for ultrasound communication. The algorithm also incorporates other modifications to optimize the signal generation process.

### Audio Reception

Other devices capture the ultrasound signal emitted by the SoundFi application. The received audio signal is then converted into a series of numerical values representing the amplitudes of the signal at different frequencies.

The audio reception process involves capturing the incoming audio signal and extracting the relevant frequency information. The captured audio data is then processed to identify the amplitudes of the signal at various frequencies, allowing the detection and extraction of the transmitted information.

### Audio Analysis

Once the audio signal is received, it undergoes frequency analysis to extract the transferred information. In the provided code, two functions are available for frequency analysis: `fftGetFrequencyHighAccuracy` and `fftGetFrequencyLowAccuracy`.

The `fftGetFrequencyHighAccuracy` function utilizes a modified version of the FFT algorithm to achieve high accuracy in frequency analysis. It applies oversampling and pitch-shifting techniques to enhance the precision of the frequency estimation. This function is suitable for foreground processing or occasional background processing, as it provides frequencies close to 1Hz but consumes more CPU resources.

The `fftGetFrequencyLowAccuracy` function, on the other hand, is designed for background processing. It provides frequencies close to 50Hz with lower CPU usage. However, it may not be as accurate as the high-accuracy version for message processing.

These frequency analysis functions play a crucial role in extracting the transmitted information from the received audio signal. By analyzing the amplitudes of the signal at different frequencies, the functions determine the dominant frequency components, which represent the encoded data.

### Data Conversion

After the audio data is analyzed, it is converted into different formats for further processing. The code includes functions for converting between data types such as Int16 and Float32. These conversions are necessary to ensure compatibility with various data processing algorithms or systems.

Additionally, a function named `fixedPointToSInt16` is available to convert fixed-point 8.24 format to Int16 format. This conversion allows for the correct interpretation of the fixed-point audio data, enabling further analysis or manipulation.

The data conversion functions provided in the code facilitate the seamless integration of the analyzed audio data into existing data processing pipelines or systems.
