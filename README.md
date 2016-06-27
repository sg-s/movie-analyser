# movieAnalyser

a MATLAB class to help you bootstrap your image analysis problem.

## The problem

1. Writing GUIs is a pain. 
2. In most image(movie) analysis problems, you typically operate frame by frame, and you want to see how your algorithm performs
3. your algorithm makes a mistake. Quick -- which frame did if break down at? Wouldn't it be great to go back one frame?
4. Damn it, the code is still running! I want to pause it, to debug the problem frame.

## The solution 

`movieAnalyser` is a barebones MATLAB class that, in its simplest form, acts as a movie player. But the nice thing is that it comes with a `pause` button, as well as `next` and `previous` buttons. Drop your image analysis code in the region indicated, and suddenly you've got a way to step through your horribly complicated image analysis pipeline, and even go back in time. 

Debugging got a lot simpler, and you can spend more time writing actually useful code. 

Since `movieAnalyser` inherits from the `handle` class in MATLAB, all `movieAnalyser` objects have two dual representations: as a GUI object that you can see, and also as a object in your workspace. Changes to the GUI reflect on the object in your workspace. You can switch effortlessly between the GUI and the command line. It's awesome. 


## Installation

The recommended way to install this is to use my package manager:

```matlab
urlwrite('http://srinivas.gs/install.m','install.m'); 
install movie-analyser
install srinivas.gs_mtools  
```

## Usage

### 1. build a interface to read your movie/data file

By default, `movieAnalyser` assumes your movies are HDF5 (.mat v7.3+) files with the images stored in a 3D matrix called `frames`. `movieAnalyser` uses `matfile` to speed up data reads. If your movie is in a 3D matrix with a different name, set the `variable_name` property correctly. 

### 2. add your tracking/analysis code 

`movieAnalyser` uses  `movieAnalyser.operateOnFrame` to read each image frame by frame. Simply add your code to that function and it will be called for each frame. Here is an example class that you can define that inherits from `movieAnalyser` and uses it:

```matlab

classdef superTrack < movieAnalyser

	properties
		% define your properties here
	end

	methods
		% define your methods here

		function obj = operateOnFrame(obj) 
			operateOnFrame@movieAnalyser(obj); % first call the method from the parent class

			% now insert your own code here. it will run on every frame. 
		end

	end

end
```

# License 

movie-analyser is free software. 
[GPL v3](https://www.gnu.org/licenses/gpl-3.0.txt)
